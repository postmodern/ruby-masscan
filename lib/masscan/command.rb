require 'command_mapper/command'

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

    class PortList < CommandMapper::Types::Num

      def validate(value)
        case value
        when Array
          value.each do |element|
            valid, message = validate(element)

            unless valid
              return [valid, message]
            end
          end

          return true
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
        else
          super(value)
        end
      end

      def format(value)
        case value
        when Array
          value.map(&method(:format)).join(',')
        when Range
          "#{value.begin}-#{value.end}"
        else
          super(value)
        end
      end

    end

    class Shards < CommandMapper::Types::Str

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

      def format(value)
        case value
        when Array
          "#{value[0]}/#{value[1]}"
        else
          super(value)
        end
      end

    end

    command "masscan" do
      option '--range', name: :range, value: true
      option '-p', name: :ports, value: {type: PortList.new}
      option '--banners', name: :banners
      option '--rate',    name: :rate, value: {type: Num.new}
      option '--conf',    name: :config_file, value: {type: InputFile.new}
      option '--resume',  name: :resume, value: {type: InputFile.new}
      option '--echo',    name: :echo, value: true
      option '--adapter', name: :adapter, value: true
      option '--adapter-ip',   name: :adapter_ip, value: true
      option '--adapter-port', name: :adapter_port, value: {type: Num.new}
      option '--adapter-mac',  name: :adapter_mac, value: true
      option '--adapter-vlan', name: :adapter_vlan, value: true
      option '--router-mac', name: :router_mac, value: true
      option '--ping', name: :ping
      option '--exclude', name: :exclude, value: {type: List.new}
      option '--excludefile', name: :exclude_file, value: {type: InputFile.new}
      option '--includefile', name: :include_file, value: {type: InputFile.new}
      option '--append-output', name: :append_output
      option '--iflist', name: :list_interfaces
      option '--retries', name: :retries
      option '--nmap', name: :nmap_help
      option '--pcap-payloads', name: :pcap_payloads
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
      option '--rotate', name: :rotate, value: true
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

      argument :ips, repeats: true
    end

  end
end
