require "aws-sdk"
require "buildkiq/zip_reader"

class Artifact
  def initialize(job)
    @s3_client = Aws::S3::Client.new
    @job       = job
  end

  def upload_success?
    @job.artifact_upload_success?
  end

  def find_by(path)
    io = if packaging_zip?
           fetch_zip_file.find_by_name(path)
         else
           fetch_s3_object("/#{path}")
         end

    io.read
  end

  private

  def packaging_zip?
    @job.project.artifacts.packaging == "ZIP"
  end

  def fetch_zip_file
    @zip_reader ||= Buildkiq::ZipReader.new(fetch_s3_object)
  end

  def fetch_s3_object(path = "")
    @s3_client.get_object(bucket: bucket_name, key: "#{file_key}#{path}").body
  end

  def bucket_name
    @bucket_name ||= @job.build.artifacts.location.split(":::").last.split("/").first
  end

  def file_key
    @file_key ||= @job.build.artifacts.location.split(":::").last.split("/")[1..-1].join("/")
  end
end
