require "logger"
require "aws-sdk"

module Buildkiq
  class Job
    attr_reader :logger, :project_name, :environments, :build

    def initialize(project_name:, environments:, logger: Logger.new(STDOUT))
      @client       = Aws::CodeBuild::Client.new
      @project_name = project_name
      @environments = environments
      @logger       = logger
    end

    def start(source_version: nil, build_cmd: nil)
      params = {project_name: project_name, environment_variables_override: environments}

      if source_version && source_type == "S3"
        raise ArgumentError.new("source_version parameter can not be used, project source type is S3")
      end

      params[:source_version]     = source_version if source_version
      params[:buildspec_override] = build_spec(build_cmd) if build_cmd
      logger.info("build parameter: #{params}")

      @build = @client.start_build(params).build
    end

    def wait_for_job(timeout_sec: build.timeout_in_minutes * 60, sleep_sec: 5)
      Timeout.timeout(timeout_sec) do
        sleep(sleep_sec) until done?
      end

      self
    end

    def status
      fetch_build.build_status
    end

    def build_url
      "https://#{@client.config.region}.console.aws.amazon.com/codebuild/home#/builds/#{build[:id]}/view/new"
    end

    def watch_log_url
      build.logs.deep_link if build
    end

    def artifact_upload_success?
      !fetch_build.phases.select { |v|
        v.phase_type == "UPLOAD_ARTIFACTS" && v.phase_status == "SUCCEEDED"
      }.empty?
    end

    def project
      @project ||= @client.batch_get_projects(names: [project_name])[0][0]
    end

    def artifact
      @artifact ||= Artifact.new(self)
    end

    private

    def fetch_build
      @build = @client.batch_get_builds(ids: [build[:id]]).builds[0]
    end

    def source_type
      project.source.type
    end

    def done?
      fetch_build.build_complete
    end

    def build_spec(cmd)
      <<~EOS
        version: 0.2
        phases:
          build:
            commands:
               - #{cmd}
      EOS
    end
  end
end
