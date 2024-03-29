# frozen_string_literal: true

module Masscan
  module Parsers
    #
    # Common methods for parsing plain-text data.
    #
    # @api private
    #
    module PlainText
      # Mapping of status strings to their keywords.
      STATUSES = {
        'open'   => :open,
        'closed' => :closed
      }

      #
      # Parses a status string.
      #
      # @param [String] status
      #   The status string to parse.
      #
      # @return [:open, :closed, String]
      #   The status keyword or a String if the status wasn't in {STATUSES}.
      #
      def parse_status(status)
        STATUSES[status] || status
      end

      REASONS = {
        'fin' => :fin,
        'syn' => :syn,
        'rst' => :rst,
        'psh' => :psh,
        'ack' => :ack,
        'urg' => :urg,
        'ece' => :ece,
        'cwr' => :cwr
      }

      #
      # Parses a reason string.
      #
      # @param [String] reason
      #   The reason string to parse.
      #
      # @return [Array<:fin, :syn, :rst, :psh, :ack, :urg, :ece, :cwr>]
      #   The reason keywords or a String if the flag wasn't in {REASONS}.
      #
      def parse_reason(reason)
        flags = reason.split('-')
        flags.map! { |flag| REASONS[flag] || flag }
        flags
      end

      # Mapping of IP protocol names to their keywords.
      IP_PROTOCOLS = {
        'tcp'  => :tcp,
        'udp'  => :udp,
        'icmp' => :icmp,
        'sctp' => :sctp
      }

      #
      # Parses an IP protocol name.
      #
      # @param [String] proto
      #   The IP protocol name.
      #
      # @return [:tcp, :udp, :icmp, :sctp, String]
      #   The IP protocol keyword or a String if the IP protocol wasn't in
      #   {IP_PROTOCOLS}.
      #
      def parse_ip_protocol(proto)
        IP_PROTOCOLS[proto] || proto
      end

      # Mapping of application protocol names to their keywords.
      APP_PROTOCOLS = {
        "ssh1" => :ssh1,
        "ssh2" => :ssh2,
        "ssh"  => :ssh,
        "http" => :http,
        "ftp"  => :ftp,
        "dns-ver" => :dns_ver,
        "snmp" => :smtp,
        "nbtstat" => :nbtstat,
        "ssl" => :ssl3,
        "smtp" => :smtp,
        "smb" => :smb,
        "pop" => :pop,
        "imap" => :imap,
        "X509" => :x509,
        "zeroaccess" => :zeroaccess,
        "title" => :html_title,
        "html" => :html,
        "ntp" => :ntp,
        "vuln" => :vuln,
        "heartbleed" => :heartbleed,
        "ticketbleed" => :ticketbleed,
        "vnc" => :vnc,
        "safe" => :safe,
        "memcached" => :memcached,
        "scripting" => :scripting,
        "versioning" => :versioning,
        "coap"        => :coap,
        "telnet"      => :telnet,
        "rdp"         => :rdp,
        "http.server" => :http_server
      }

      #
      # Parses an application protocol name.
      #
      # @param [String] proto
      #   The application protocol name.
      #
      # @return [Symbol, String]
      #   The IP protocol keyword or a String if the application protocol wasn't
      #   in {APP_PROTOCOLS}.
      #
      def parse_app_protocol(proto)
        APP_PROTOCOLS[proto] || proto
      end

      #
      # Parses a timestamp.
      #
      # @param [String] timestamp
      #   The numeric timestamp value.
      #
      # @return [Time]
      #   The parsed timestamp value.
      #
      def parse_timestamp(timestamp)
        Time.at(timestamp.to_i)
      end

      #
      # Parses an IP address.
      #
      # @param [String] ip
      #   The string representation of the IP address.
      #
      # @return [IPAddr]
      #   The parsed IP address.
      #
      def parse_ip(ip)
        IPAddr.new(ip)
      end
    end
  end
end
