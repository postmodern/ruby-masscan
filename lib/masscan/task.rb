require 'rprogram/task'

module Masscan
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
  class Task < RProgram::Task

    long_option flag: '--range', name: :range, separator: ','
    short_option flag: '-p', name: :ports do |opt,value|
      unless value.empty?
        [opt.flag, format_port_list(value)]
      end
    end
    long_option flag: '--banners', name: :banners
    long_option flag: '--rate',    name: :rate
    long_option flag: '--conf',    name: :config_file
    long_option flag: '--resume',  name: :resume
    long_option flag: '--echo',    name: :echo
    long_option flag: '--adapter', name: :adapter
    long_option flag: '--adapter-ip',   name: :adapter_ip
    long_option flag: '--adapter-port', name: :adapter_port
    long_option flag: '--adapter-mac',  name: :adapter_mac
    long_option flag: '--adapter-vlan', name: :adapter_vlan
    long_option flag: '--router-mac', name: :router_mac
    long_option flag: '--ping', name: :ping
    long_option flag: '--exclude', name: :exclude, separator: ','
    long_option flag: '--excludefile', name: :exclude_file
    long_option flag: '--includefile', name: :include_file
    long_option flag: '--append-output', name: :append_output
    long_option flag: '--iflist', name: :list_interfaces
    long_option flag: '--retries', name: :retries
    long_option flag: '--nmap', name: :nmap_help
    long_option flag: '--pcap-payloads', name: :pcap_payloads
    long_option flag: '--nmap-payloads', name: :nmap_payloads

    long_option flag: '--http-method',     name: :http_method
    long_option flag: '--http-url',        name: :http_url
    long_option flag: '--http-version',    name: :http_version
    long_option flag: '--http-host',       name: :http_host
    long_option flag: '--http-user-agent', name: :http_user_agent

    long_option flag: '--http-field', multiple: true do |opt,value|
      name, value = value.first

      [opt.flag, "#{name}:#{value}"]
    end

    long_option flag: '--http-field-remove', name: :http_field_remove
    long_option flag: '--http-cookie', name: :http_cookie
    long_option flag: '--http-payload', name: :http_payload

    long_option flag: '--show', name: :show
    long_option flag: '--noshow', name: :hide
    long_option flag: '--pcap', name: :pcap
    long_option flag: '--packet-trace', name: :packet_trace
    long_option flag: '--pfring', name: :pfring
    long_option flag: '--resume-index', name: :resume_index
    long_option flag: '--resume-count', name: :resume_count
    long_option flag: '--shards', name: :shards do |opt,value|
      case value.length
      when 2 then [opt.flag, "#{value[0]}/#{value[1]}"]
      when 1 then [opt.flag, "#{value[0]}"]
      else
        raise(ArgumentError,"#{self}#shards= does not accept more than two values")
      end
    end
    long_option flag: '--rotate', name: :rotate
    long_option flag: '--rotate-offset', name: :rotate_offset
    long_option flag: '--rotate-size',   name: :rotate_size
    long_option flag: '--rotate-dir',    name: :rotate_dir
    long_option flag: '--seed', name: :seed
    long_option flag: '--regress', name: :regress
    long_option flag: '--ttl', name: :ttl
    long_option flag: '--wait', name: :wait
    long_option flag: '--offline', name: :offline
    short_option flag: '-sL', name: :print_list
    long_option flag: '--interactive', name: :interactive
    long_option flag: '--output-format', name: :output_format
    long_option flag: '--output-filename', name: :output_file
    short_option flag: '-oB', name: :output_binary
    short_option flag: '-oX', name: :output_xml
    short_option flag: '-oG', name: :output_grepable
    short_option flag:' -oJ', name: :output_json
    short_option flag: '-oL', name: :output_list
    long_option flag: '--readscan', name: :read_scan
    short_option :flag => '-V', :name => :version
    short_option :flag => '-h', :name => :help

    non_option :tailing => true, :name => :ips

    private

    #
    # Formats a port list.
    #
    # @param [Array<Integer,Range>] ports
    #   The port ranges.
    #
    # @return [String]
    #   Comma separated string.
    #
    def self.format_port_list(ports)
      ports.map { |port|
        case port
        when Range
          "#{port.first}-#{port.last}"
        else
          port.to_s
        end
      }.join(',')
    end

  end
end
