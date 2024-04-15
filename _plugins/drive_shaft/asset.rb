require "fileutils"
require "digest"

module Jekyll
  module DriveShaft
    class Asset
      attr_reader :url, :source_path, :destination_path

      def initialize(url:, source_path:, destination_path:)
        @url = url
        @source_path = source_path
        @destination_path = destination_path
      end

      def content
        File.binread(source_path)
      end

      def digest
        @digest ||= Digest::SHA1.hexdigest(content)[0..7]
      end

      def digested_path
        destination_path.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
      end

      def digested_url
        url.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
      end

      def create_fingerprinted_copy!
        FileUtils.copy source_path, digested_path
      end
    end
  end
end
