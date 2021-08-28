require 'masscan/parsers/common'
require 'masscan/status'
require 'masscan/banner'

module Masscan
  module Parsers
    #
    # Parses the `masscan -oL` output format.
    #
    module List
      extend Common

      #
      # Opens a list file for parsing.
      #
      # @param [String] path
      #
      # @yield [file]
      #
      # @yieldparam [File] file
      #
      # @return [File]
      #
      def self.open(path,&block)
        File.open(path,&block)
      end

      extend Common

      #
      # Parses the masscan simple list data.
      #
      # @param [IO] io
      #
      # @yield [record]
      #
      # @yieldparam [Status, Banner] record
      #
      # @return [Enumerator]
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
