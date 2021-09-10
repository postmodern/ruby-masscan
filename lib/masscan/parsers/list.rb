require 'masscan/parsers/plain_text'
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
      extend PlainText

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
              status:    parse_status(type),
              protocol:  parse_ip_protocol(ip_proto),
              port:      port.to_i,
              ip:        parse_ip(ip),
              timestamp: parse_timestamp(timestamp)
            )
          elsif line.start_with?('banner ')
            type, ip_proto, port, ip, timestamp, app_proto, banner = line.split(' ',7)

            yield Banner.new(
              protocol:     parse_ip_protocol(ip_proto),
              port:         port.to_i,
              ip:           parse_ip(ip),
              timestamp:    parse_timestamp(timestamp),
              app_protocol: parse_app_protocol(app_proto),
              payload:      banner
            )
          end
        end
      end
    end
  end
end
