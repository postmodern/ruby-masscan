module Masscan
  module Parsers
    module Common
      STATUSES = {
        'open'   => :open,
        'closed' => :closed
      }

      def parse_status(status)
        STATUSES[status] || status
      end

      IP_PROTOCOLS = {
        'tcp'  => :tcp,
        'udp'  => :udp,
        'icmp' => :icmp,
        'sctp' => :sctp
      }

      def parse_ip_protocol(proto)
        IP_PROTOCOLS[proto] || proto
      end

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

      def parse_app_protocol(proto)
        APP_PROTOCOLS[proto] || proto
      end

      def parse_timestamp(timestamp)
        Time.at(timestamp.to_i)
      end

      def parse_ip(ip)
        IPAddr.new(ip)
      end
    end
  end
end
