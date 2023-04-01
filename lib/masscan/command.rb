# frozen_string_literal: true

require 'command_mapper/command'

require 'ipaddr'

module Masscan
  #
  # Provides an interface for invoking the `masscan` utility.
  #
  # ## Example
  #
  #     require 'masscan/command'
  #
  #     Masscan::Command.sudo do |masscan|
  #       masscan.output_format = :list
  #       masscan.output_file   = 'masscan.txt'
  #
  #       masscan.ips   = '192.168.1.1/24'
  #       masscan.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080]
  #     end
  #
  # ## `masscan` options:
  #
  # * `--range` - `masscan.range`
  # * `-p` - `masscan.ports`
  # * `--banners` - `masscan.banners`
  # * `--rate` - `masscan.rate`
  # * `--conf` - `masscan.config_file`
  # * `--resume` - `masscan.resume`
  # * `--echo` - `masscan.echo`
  # * `--adapter` - `masscan.adapter`
  # * `--adapter-ip` - `masscan.adapter_ip`
  # * `--adapter-port` - `masscan.adapter_port`
  # * `--adapter-mac` - `masscan.adapter_mac`
  # * `--adapter-vlan` - `masscan.adapter_vlan`
  # * `--router-mac` - `masscan.router_mac`
  # * `--ping` - `masscan.ping`
  # * `--exclude` - `masscan.exclude`
  # * `--excludefile` - `masscan.exclude_file`
  # * `--includefile` - `masscan.include_file`
  # * `--append-output` - `masscan.append_output`
  # * `--iflist` - `masscan.list_interfaces`
  # * `--retries` - `masscan.retries`
  # * `--nmap` - `masscan.nmap_help`
  # * `--pcap-payloads` - `masscan.pcap_payloads`
  # * `--nmap-payloads` - `masscan.nmap_payloads`
  # * `--http-method` - `masscan.http_method`
  # * `--http-url` - `masscan.http_url`
  # * `--http-version` - `masscan.http_version`
  # * `--http-host` - `masscan.http_host`
  # * `--http-user-agent` - `masscan.http_user_agent`
  # * `--http-field` - `masscan.http_field`
  # * `--http-field-remove` - `masscan.http_field_remove`
  # * `--http-cookie` - `masscan.http_cookie`
  # * `--http-payload` - `masscan.http_payload`
  # * `--show` - `masscan.show`
  # * `--noshow` - `masscan.hide`
  # * `--pcap` - `masscan.pcap`
  # * `--packet-trace` - `masscan.packet_trace`
  # * `--pfring` - `masscan.pfring`
  # * `--resume-index` - `masscan.resume_index`
  # * `--resume-count` - `masscan.resume_count`
  # * `--shards` - `masscan.shards`
  # * `--rotate` - `masscan.rotate`
  # * `--rotate-offset` - `masscan.rotate_offset`
  # * `--rotate-size` - `masscan.rotate_size`
  # * `--rotate-dir` - `masscan.rotate_dir`
  # * `--seed` - `masscan.seed`
  # * `--regress` - `masscan.regress`
  # * `--ttl` - `masscan.ttl`
  # * `--wait` - `masscan.wait`
  # * `--offline` - `masscan.offline`
  # * `-sL` - `masscan.print_list`
  # * `--interactive` - `masscan.interactive`
  # * `--output-format` - `masscan.output_format`
  # * `--output-filename` - `masscan.output_file`
  # * `-oB` - `masscan.output_binary`
  # * `-oX` - `masscan.output_xml`
  # * `-oG` - `masscan.output_grepable`
  # * ` -oJ` - `masscan.output_json`
  # * `-oL` - `masscan.output_list`
  # * `--readscan` - `masscan.read_scan`
  # * `-V` - `masscan.version`
  # * `-h` - `masscan.help`
  #
  # @see https://github.com/robertdavidgraham/masscan/blob/master/doc/masscan.8.markdown
  #
  # @since 0.2.0
  #
  class Command < CommandMapper::Command

    #
    # Represents a port number.
    #
    # @api private
    #
    # @since 0.3.0
    #
    class Port < CommandMapper::Types::Num

      # Regular expression that validates a port number.
      PORT_REGEXP = /[1-9][0-9]{0,3}|[1-5][0-9][0-9][0-9][0-9]|6[0-4][0-9][0-9][0-9]|65[0-4][0-9][0-9]|655[0-2][0-9]|6553[0-5]/

      # Regular expression that validates either a port number or service name.
      REGEXP = /\A#{PORT_REGEXP}\z/

      #
      # Initializes the port type.
      #
      def initialize
        super(range: 1..65535)
      end

      #
      # Validates the given value.
      #
      # @param [Object] value
      #   The value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when String
          unless value =~ REGEXP
            return [false, "must be a valid port number (#{value.inspect})"]
          end

          return true
        else
          super(value)
        end
      end

      #
      # Formats the given port number.
      #
      # @param [Integer, String] value
      #   The given port number.
      #
      # @return [String]
      #   The formatted port number.
      #
      def format(value)
        case value
        when String
          value
        else
          super(value)
        end
      end

    end

    #
    # Represents a port range.
    #
    # @api private
    #
    # @since 0.3.0
    #
    class PortRange < Port

      # Regular expression to validate either a port or a port range.
      PORT_RANGE_REGEXP = /#{PORT_REGEXP}-#{PORT_REGEXP}|#{PORT_REGEXP}/

      # Regular expression to validate either a port or a port range.
      REGEXP = /\A#{PORT_RANGE_REGEXP}\z/

      #
      # Validates the given port or port range value.
      #
      # @param [Object] value
      #   The port or port range value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when Range
          valid, message = super(value.begin)

          unless valid
            return [valid, message]
          end

          valid, message = super(value.end)

          unless valid
            return [valid, message]
          end

          return true
        when String
          unless value =~ REGEXP
            return [false, "must be a valid port range or port number (#{value.inspect})"]
          end

          return true
        else
          super(value)
        end
      end

      #
      # Formats the given port or port range value.
      #
      # @param [Range, Integer, String] value
      #   The port or port range value to format.
      #
      # @return [String]
      #   The formatted port or port range.
      #
      def format(value)
        case value
        when Range
          "#{value.begin}-#{value.end}"
        else
          super(value)
        end
      end

    end

    #
    # Represents the type for the `-p,--ports` option.
    #
    # @api private
    #
    class PortList < CommandMapper::Types::List

      # Regular expression for validating a port or port range.
      PORT_RANGE_REGEXP = PortRange::PORT_RANGE_REGEXP

      # Regular expression that validates port list String values.
      REGEXP = /\A(?:(?:U:)?#{PORT_RANGE_REGEXP})(?:,(?:U:)?#{PORT_RANGE_REGEXP})*\z/

      #
      # Initializes the port list type.
      #
      def initialize
        super(type: PortRange.new)
      end

      #
      # Validates a given value.
      #
      # @param [Array, Range, String, Object] value
      #   The port list value.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when Range
          @type.validate(value)
        when String
          unless value =~ REGEXP
            return [false, "not a valid port list (#{value.inspect})"]
          end

          return true
        else
          super(value)
        end
      end

      #
      # Formats a port list value into a String.
      #
      # @param [Array<String, Integer, Range>, Range<Integer,Integer>, String, #to_s] value
      #   The port list value to format.
      #
      # @return [String]
      #   The formatted port list string.
      #
      def format(value)
        case value
        when Range
          # format an individual port range
          @type.format(value)
        when String
          # pass strings directly through
          value
        else
          super(value)
        end
      end

    end

    #
    # Represents the type for the `--shards` option.
    #
    # @api private
    #
    class Shards < CommandMapper::Types::Str

      #
      # Validates a shards value.
      #
      # @param [Array, Object] value
      #   The shards value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when Array
          if value.length > 2
            return [false, "cannot contain more tha two elements (#{value.inspect})"]
          end

          return true
        else
          super(value)
        end
      end

      #
      # Formats a shards value into a String.
      #
      # @param [(#to_s, #to_s), #to_s] value
      #   The shards value to format.
      #
      # @return [String]
      #   The formatted shards value.
      #
      def format(value)
        case value
        when Array
          "#{value[0]}/#{value[1]}"
        else
          super(value)
        end
      end

    end

    #
    # Represents the type for the `--rotate` option.
    #
    # @api private
    #
    # @since 0.3.0
    #
    class RotateTime < CommandMapper::Types::Str

      # Regular expression to validate the `--rotate` time value.
      REGEXP = /\A(?:\d+|hourly|\d+hours|\d+min)\z/

      #
      # Validates a `--rotate` time value.
      #
      # @param [Integer, String, #to_s] value
      #   The time value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when Integer
          return true
        else
          valid, message = super(value)

          unless valid
            return [valid, message]
          end

          string = value.to_s

          unless string =~ REGEXP
            return [false, "invalid rotation time (#{value.inspect})"]
          end

          return true
        end
      end

    end

    #
    # Represents the type for the `--adapter-mac` and `--router-mac` options.
    #
    # @api private
    #
    # @since 0.3.0
    #
    class MACAddress < CommandMapper::Types::Str

      # Regular expression to validate a MAC address.
      REGEXP = /\A[A-Fa-f0-9]{2}(?::[A-Fa-f0-9]{2}){5}\z/

      #
      # Validates a MAC address value.
      #
      # @param [String, #to_s] value
      #   The MAC address value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        valid, message = super(value)

        unless valid
          return [valid, message]
        end

        string = value.to_s

        unless string =~ REGEXP
          return [false, "invalid MAC address (#{value.inspect})"]
        end

        return true
      end

    end

    #
    # Represents the type for the `--range` option and `ips` argument(s).
    #
    # @api private
    #
    # @since 0.3.0
    #
    class Target < CommandMapper::Types::Str

      # Regular expression for validating decimal octets (0-255).
      DECIMAL_OCTET_REGEXP = /(?<=[^\d]|^)(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])(?=[^\d]|$)/

      # Regular expression for validating IPv4 addresses or CIDR ranges.
      IPV4_REGEXP = %r{#{DECIMAL_OCTET_REGEXP}(?:\.#{DECIMAL_OCTET_REGEXP}){3}(?:/\d{1,2})?}

      # Regular expression for validating IPv6 addresses or CIDR ranges.
      IPV6_REGEXP = %r{
       (?:[0-9a-f]{1,4}:){6}#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){5}[0-9a-f]{1,4}:#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){5}:[0-9a-f]{1,4}:#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){1,1}(?::[0-9a-f]{1,4}){1,4}:#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){1,2}(?::[0-9a-f]{1,4}){1,3}:#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){1,3}(?::[0-9a-f]{1,4}){1,2}:#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){1,4}(?::[0-9a-f]{1,4}){1,1}:#{IPV4_REGEXP}|
       :(?::[0-9a-f]{1,4}){1,5}:#{IPV4_REGEXP}|
       (?:(?:[0-9a-f]{1,4}:){1,5}|:):#{IPV4_REGEXP}|
       (?:[0-9a-f]{1,4}:){1,1}(?::[0-9a-f]{1,4}){1,6}(?:/\d{1,3})?|
       (?:[0-9a-f]{1,4}:){1,2}(?::[0-9a-f]{1,4}){1,5}(?:/\d{1,3})?|
       (?:[0-9a-f]{1,4}:){1,3}(?::[0-9a-f]{1,4}){1,4}(?:/\d{1,3})?|
       (?:[0-9a-f]{1,4}:){1,4}(?::[0-9a-f]{1,4}){1,3}(?:/\d{1,3})?|
       (?:[0-9a-f]{1,4}:){1,5}(?::[0-9a-f]{1,4}){1,2}(?:/\d{1,3})?|
       (?:[0-9a-f]{1,4}:){1,6}(?::[0-9a-f]{1,4}){1,1}(?:/\d{1,3})?|
       [0-9a-f]{1,4}(?::[0-9a-f]{1,4}){7}(?:/\d{1,3})?|
       :(?::[0-9a-f]{1,4}){1,7}(?:/\d{1,3})?|
       (?:(?:[0-9a-f]{1,4}:){1,7}|:):(?:/\d{1,3})?
      }x

      # Regular expression for validating masscan target IPs or IP ranges.
      REGEXP = /\A(?:#{IPV4_REGEXP}|#{IPV6_REGEXP})\z/

      #
      # Validates a IP or IP range target value.
      #
      # @param [IPAddr, String, #to_s] value
      #   The IP or IP range value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when IPAddr
          return true
        else
          valid, message = super(value)

          unless valid
            return [valid, message]
          end

          string = value.to_s

          unless string =~ REGEXP
            return [false, "invalid IP or IP range (#{value.inspect})"]
          end

          return true
        end
      end

    end

    command "masscan" do
      option '--range', name: :range, value: {type: Target.new}, repeats: true
      option '-p', name: :ports, value: {type: PortList.new}
      option '--banners', name: :banners
      option '--rate',    name: :rate, value: {type: Num.new}
      option '--conf',    name: :config_file, value: {type: InputFile.new}
      option '--resume',  name: :resume, value: {type: InputFile.new}
      option '--echo',    name: :echo, value: true
      option '--adapter', name: :adapter, value: true
      option '--adapter-ip',   name: :adapter_ip, value: true
      option '--adapter-port', name: :adapter_port, value: {type: PortRange.new}
      option '--adapter-mac',  name: :adapter_mac, value: {type: MACAddress.new}
      option '--adapter-vlan', name: :adapter_vlan, value: true
      option '--router-mac', name: :router_mac, value: {type: MACAddress.new}
      option '--ping', name: :ping
      option '--exclude', name: :exclude, value: true, repeats: true
      option '--excludefile', name: :exclude_file, value: {type: InputFile.new}, repeats: true
      option '--includefile', name: :include_file, value: {type: InputFile.new}, repeats: true
      option '--append-output', name: :append_output
      option '--iflist', name: :list_interfaces
      option '--retries', name: :retries, value: {type: Num.new}
      option '--nmap', name: :nmap_help
      option '--pcap-payloads', name: :pcap_payloads, value: {type: InputFile.new}
      option '--nmap-payloads', name: :nmap_payloads, value: {type: InputFile.new}

      option '--http-method',     name: :http_method, value: true
      option '--http-url',        name: :http_url, value: true
      option '--http-version',    name: :http_version, value: true
      option '--http-host',       name: :http_host, value: true
      option '--http-user-agent', name: :http_user_agent, value: true

      option '--http-field', value: {type: KeyValue.new}, repeats: true

      option '--http-field-remove', name: :http_field_remove
      option '--http-cookie', name: :http_cookie
      option '--http-payload', name: :http_payload

      option '--show', name: :show
      option '--noshow', name: :hide
      option '--pcap', name: :pcap, value: true
      option '--packet-trace', name: :packet_trace
      option '--pfring', name: :pfring
      option '--resume-index', name: :resume_index
      option '--resume-count', name: :resume_count
      option '--shards', name: :shards, value: {type: Shards.new}
      option '--rotate', name: :rotate, value: {type: RotateTime.new}
      option '--rotate-offset', name: :rotate_offset, value: true
      option '--rotate-size',   name: :rotate_size, value: true
      option '--rotate-dir',    name: :rotate_dir, value: {type: InputDir.new}
      option '--seed', name: :seed, value: {type: Num.new}
      option '--regress', name: :regress
      option '--ttl', name: :ttl, value: {type: Num.new}
      option '--wait', name: :wait, value: {type: Num.new}
      option '--offline', name: :offline
      option '-sL', name: :print_list
      option '--interactive', name: :interactive
      option '--output-format', name: :output_format, value: {
                                                        type: Enum[
                                                          :xml,
                                                          :binary,
                                                          :grepable,
                                                          :list,
                                                          :JSON
                                                        ]
                                                      }
      option '--output-filename', name: :output_file, value: true
      option '-oB', name: :output_binary, value: true
      option '-oX', name: :output_xml, value: true
      option '-oG', name: :output_grepable, value: true
      option '-oJ', name: :output_json, value: true
      option '-oL', name: :output_list, value: true
      option '--readscan', name: :read_scan, value: {type: InputFile.new}
      option '-V', name: :version
      option '-h', name: :help

      argument :ips, repeats: true, type: Target.new
    end

  end
end
