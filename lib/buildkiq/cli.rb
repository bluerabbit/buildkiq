require "thor"
require "buildkiq"
require "logger"

module Buildkiq
  class Cli < Thor
    default_command :run_builds

    desc "run_builds", "Run containers"
    method_option :project,             aliases: "-p", required: true, desc: 'AWS CodeBuild project name'
    method_option :builds_environments, aliases: "-b", required: true, type: :array, desc: 'builds environments(csv)'
    method_option :environments,        aliases: "-e", desc: 'common environments(csv)'
    method_option :source_version,      aliases: "-s", desc: 'git commit hash or github pullrequest'
    method_option :command,             aliases: "-c", desc: 'override buildspec.yml with shell command'

    def run_builds
      logger = Logger.new(STDOUT)
      jobs = Buildkiq.run(project:              options[:project],
                          jobs:                 options[:builds_environments].map {|job|
                            {environments: parse_environments_text(job)}
                          },
                          default_environments: parse_environments_text(options[:environments]),
                          source_version:       options[:source_version],
                          build_cmd:            options[:command],
                          logger:               logger)

      jobs.each {|job| logger.info(job.build_url) }
    end

    desc "version", "Show Version"

    def version
      say "Version: #{Buildkiq::VERSION}"
    end

    private

    def parse_environments_text(env_csv_text)
      env_csv_text.to_s.split(/,\s*/).map { |kv| kv.split("=") }.map do |k, v|
        { name: k, value: v }
      end
    end
  end
end
