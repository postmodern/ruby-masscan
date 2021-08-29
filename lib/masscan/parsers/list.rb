require 'masscan/parsers/common'
require 'masscan/status'
require 'masscan/banner'

module Masscan
  module Parsers
    #
    # Parses the `masscan -oL` output format.
    #
    # @api semipublic
    #
    module List
      extend Common

      #
      # Opens a list file for parsing.
      #
      # @param [String] path
      #   The path to the file.
      #
      # @yield [file]
      #   If a block is given, it will be passed the opened file.
      #   Once the block returns, the file will be closed.
      #
      # @yieldparam [File] file
      #   The opened file.
      #
      # @return [File]
      #   If no block was given, the opened file will be returned.
      #
      def self.open(path,&block)
        File.open(path,&block)
      end

      extend Common

      #
      # Parses the masscan simple list data.
      #
      # @param [#each_line] io
      #   The IO object to read from.
      #
      # @yield [record]
      #   If a block is given, it will be passed each parsed record.
      #
      # @yieldparam [Status, Banner] record
      #   A parsed record, either a {Status} or a {Banner} object.
      #
      # @return [Enumerator]
      #   If no block is given, it will return an Enumerator.
      #
      def self.parse(io)
        return enum_for(__method__,io) unless block_given?

        io.each_line do |line|
          line.chomp!

          if line.start_with?('open ') || line.start_with?('closed ')
            type, ip_proto, port, ip, timestamp = line.split(' ',5)

            yield Status.new(
              parse_status(type),
              parse_ip_protocol(ip_proto),
              port.to_i,
              parse_ip(ip),
              parse_timestamp(timestamp)
            )
          elsif line.start_with?('banner ')
            type, ip_proto, port, ip, timestamp, app_proto, banner = line.split(' ',7)

            yield Banner.new(
              parse_ip_protocol(ip_proto),
              port.to_i,
              parse_ip(ip),
              parse_timestamp(timestamp),
              parse_app_protocol(app_proto),
              banner
            )
          end
        end
      end
    end
  end
end
