require "zip"

module Buildkiq
  class ZipReader
    def initialize(zip_io)
      @zip_io = zip_io
    end

    def find_by_name(filename)
      entry = find_by { |e| e.name == filename }
      entry ? entry.get_input_stream : nil
    end

    def find_by
      Zip::File.open_buffer(@zip_io) do |zip|
        zip.each { |e| return e if yield(e) }
      end

      nil
    end
  end
end
