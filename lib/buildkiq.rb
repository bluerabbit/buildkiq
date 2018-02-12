require "logger"
require "buildkiq/version"
require "buildkiq/job"
require "buildkiq/artifact"

module Buildkiq
  class << self
    def run(project:, jobs:, default_environments: [], build_cmd: nil, source_version: nil, logger: Logger.new(STDOUT))
      jobs.each { |job| merge_environments!(job[:environments], default_environments) }

      jobs.map do |job|
        job = Buildkiq::Job.new(project_name: project, environments: job[:environments])
        job.start(source_version: source_version, build_cmd: build_cmd)
        logger.info("build_id: #{job.build.id}")
        job
      end
    end

    private

    def merge_environments!(job_environments, default_environments)
      default_environments.each do |env|
        unless job_environments.any? { |h| h[:name] == env[:name] }
          job_environments << env
        end
      end
    end
  end
end
