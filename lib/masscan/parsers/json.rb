require 'masscan/parsers/common'
require 'masscan/status'
require 'masscan/banner'

require 'json'

module Masscan
  module Parsers
    #
    # Parses the `masscan -oJ` and `masscan --output-format ndjson` output
    # formats.
    #
    # @api semipublic
    #
    module JSON
      #
      # Opens a JSON file for parsing.
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
      # Parses the masscan JSON or ndjson data.
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

          if line == "," || line == "[" || line == "]"
            # skip
          else
            json = ::JSON.parse(line)

            ip        = parse_ip(json['ip'])
            timestamp = parse_timestamp(json['timestamp'])

            if (ports_json = json['ports'])
              if (port_json = ports_json.first)
                proto  = parse_ip_protocol(port_json['proto'])
                port   = port_json['port']

                if (service_json = port_json['service'])
                  service_name   = parse_app_protocol(service_json['name'])
                  service_banner = service_json['banner']

                  yield Banner.new(
                    proto,
                    port,
                    ip,
                    timestamp,
                    service_name,
                    service_banner
                  )
                else
                  status = parse_status(port_json['status'])

                  yield Status.new(
                    status,
                    proto,
                    port,
                    ip,
                    timestamp
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
