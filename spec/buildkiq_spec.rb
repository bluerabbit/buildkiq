require "spec_helper"

describe ".run" do
  specify "executable on AWS CodeBuild", aws: true do
    jobs = Buildkiq.run(project:              ENV["PROJECT"],
                        jobs:                 [{ environments: [{ name: "NODE_INDEX", value: "0" }] },
                                               { environments: [{ name: "NODE_INDEX", value: "1" }] }],
                        default_environments: [
                          { name: "BUILDKIQ", value: "true" }
                        ],
                        build_cmd:            "ruby -v",
                        source_version:       ENV["SOURCE_VERSION"])

    expect(jobs.size).to eq(2)

    jobs.each.with_index do |job, i|
      expect(job.status).to eq("IN_PROGRESS")
      expect(job.build_url).not_to be_empty
      expect(job.build.source.buildspec).to match("ruby -v")

      environments = job.build.environment.environment_variables
      expect(environments.find { |e| e.name == "NODE_INDEX" }.value).to eq(i.to_s)
      expect(environments.find { |e| e.name == "BUILDKIQ" }.value).to eq("true")
    end

    jobs.each do |job|
      job.wait_for_job
      expect(job.status).to eq("SUCCEEDED")
      expect(job.watch_log_url).not_to be_empty
    end
  end
end
