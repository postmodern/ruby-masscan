require 'rprogram/task'

module Masscan
  #
  # ## `masscan` options:
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
      [opt.flag, "#{value[0]}:#{value[1]}"]
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
      [opt.flag, case value
                 when Rational then "#{value.numerator}/#{value.denominator}"
                 when Array    then "#{value[0]}/#{value[1]}"
                 else               value.to_s
                 end]
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

    #
    # Formats a protocol list.
    #
    # @param [Array<Integer,Range>] protocols
    #   The IP protocol numbers.
    #
    # @return [String]
    #   Comma separated string.
    #
    def self.format_protocol_list(protocols)
      # NOTE: the man page says the protocol list is similar to the format of
      # a port range.
      format_port_list(protocols)
    end

  end
end
