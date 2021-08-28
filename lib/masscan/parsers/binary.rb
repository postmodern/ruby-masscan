require 'masscan/status'
require 'masscan/banner'

require 'socket'

module Masscan
  module Parsers
    #
    # Parses the `masscan -oB` output format.
    #
    # @note Ported from https://github.com/robertdavidgraham/masscan/blob/1.3.2/src/in-binary.c
    #
    module Binary
      #
      # Opens a binary file for parsing.
      #
      # @param [String] path
      #
      # @yield [file]
      #
      # @yieldparam [File]
      #
      # @return [File]
      #
      def self.open(path,&block)
        File.open(path,'rb',&block)
      end

      class CorruptedFile < RuntimeError
      end

      BUF_MAX = 1024 * 1024

      #
      # Parses masscan binary data.
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
        return enum_for(__method__) unless block_given?

        pseudo = read_pseudo_record(io)

        # look for the start time
        if (match = pseudo.match(/s:(\d+)/))
          start_time = decode_timestamp(match[1].to_i)
        end

        total_records = 0

        # read all records
        loop do
          # read the TYPE field
          unless (type = read_multibyte_uint(io))
            return
          end

          # read the LENGTH field
          unless (length = read_multibyte_uint(io))
            return
          end

          if length > BUF_MAX
            raise(CorruptedFile,"file corrupted")
          end

          # read the remainder of the record
          buffer = io.read(length)

          if buffer.length < length
            return
          end

          # parse the specific record type
          record = case type
                   when 1 # STATUS: open
                     parse_status(buffer,:open)
                   when 2 # STATUS: closed
                     parse_status(buffer,:closed)
                   when 3 # BANNER
                     parse_banner3(buffer)
                   when 4
                     io.getbyte
                     parse_banner4(buffer)
                   when 5
                     parse_banner4(buffer)
                   when 6 # STATUS: open
                     parse_status2(buffer,:open)
                   when 7 # STATUS: closed
                     parse_status2(buffer,:closed)
                   when 9
                     parse_banner9(buffer)
                   when 10 # Open6
                     parse_status6(buffer,:open)
                   when 11 # Closed6
                     parse_status6(buffer,:closed)
                   when 13 # Banner6
                     parse_banner6(buffer)
                   when 109 # 'm'.ord # FILEHEADER
                     next
                   else
                     raise(CorruptedFile,"unknown type: #{type.inspect}")
                   end

          if record
            start_time ||= record.timestamp

            yield record

            total_records += 1
          end
        end

        return total_records
      end

      PSEUDO_RECORD_SIZE = 99 # 'a'.ord + 2

      MASSCAN_VERSION_FAMILY = "1.1"

      MASSCAN_MAGIC = "masscan/#{MASSCAN_VERSION_FAMILY}"

      #
      # @return [String]
      #
      def self.read_pseudo_record(io)
        buffer = io.read(PSEUDO_RECORD_SIZE)

        if buffer.length < PSEUDO_RECORD_SIZE
          raise(CorruptedFile,"invalid masscan binary format")
        end

        unless buffer.start_with?(MASSCAN_MAGIC)
          raise(CorruptedFile,"unknown file format (expected #{MASSCAN_MAGIC}")
        end

        return buffer
      end

      #
      # @return [Integer, nil]
      #
      def self.read_multibyte_uint(io)
        unless (b = io.getbyte)
          return
        end

        type = b & 0x7f

        while (b & 0x80) != 0
          unless (b = io.getbyte)
            return
          end

          type = (type << 7) | (b & 0x7f)
        end

        return type
      end

      #
      # @param [Integer] timestamp
      #
      # @return [Time]
      #
      def self.decode_timestamp(timestamp)
        Time.at(timestamp)
      end

      #
      # @param [Integer] ip
      #
      # @return [IPAddr]
      #
      def self.decode_ipv4(ip)
        IPAddr.new(ip,Socket::AF_INET)
      end

      #
      # @param [Integer] ipv6_hi
      #
      # @param [Integer] ipv6_lo
      #
      # @return [IPAddr]
      #
      def self.decode_ipv6(ipv6_hi,ipv6_lo)
        IPAddr.new((ipv6_hi << 64) | ipv6_lo,Socket::AF_INET6)
      end

      IP_PROTOCOLS = {
        Socket::IPPROTO_ICMP   => :icmp,
        Socket::IPPROTO_ICMPV6 => :icmp,

        Socket::IPPROTO_TCP => :tcp,
        Socket::IPPROTO_UDP => :udp,

        132 => :sctp # Socket::IPPROTO_SCTP might not always be defined
      }

      #
      # @param [Integer] proto
      #
      # @return [:icmp, :tcp, :udp, :sctp]
      #
      def self.lookup_ip_protocol(proto)
        IP_PROTOCOLS[proto]
      end

      APP_PROTOCOLS = [
        nil,
        :heur,
        :ssh1,
        :ssh2,
        :http,
        :ftp,
        :dns_versionbind,
        :snmp,             # simple network management protocol, udp/161
        :nbtstat,          # netbios, udp/137
        :ssl3,
        :smb,              # SMB tcp/139 and tcp/445
        :smtp,
        :pop3,
        :imap4,
        :udp_zeroaccess,
        :x509_cert,
        :html_title,
        :html_full,
        :ntp,              # network time protocol, udp/123
        :vuln,
        :heartbleed,
        :ticketbleed,
        :vnc_rfb,
        :safe,
        :memcached,
        :scripting,
        :versioning,
        :coap,         # constrained app proto, udp/5683, RFC7252
        :telnet,
        :rdp,          # Microsoft Remote Desktop Protocol tcp/3389
        :http_server,  # HTTP "Server:" field
      ]

      #
      # @param [Integer] proto
      #
      # @return [Symbol, nil]
      #
      # @see APP_PROTOCOLS
      #
      def self.lookup_app_protocol(proto)
        APP_PROTOCOLS[proto]
      end

      #
      # @param [String] buffer
      #
      # @param [:open, :closed] status
      #
      def self.parse_status(buffer,status)
        if buffer.length < 12
          return
        end

        timestamp, ip, port, reason, ttl = buffer.unpack("L>L>S>CC")

        timestamp = decode_timestamp(timestamp)
        ip        = decode_ipv4(ip)

        # if ARP, there will be a MAC address after the record
        mac = if ip == 0 && buffer.length >= 12+6
                buffer[12+6,6]
              end

        protocol = case port
                   when 53, 123, 137, 161 then  :udp
                   when 36422, 36412, 2905 then :sctp
                   else                         :tcp
                   end

        return Status.new(
          status,
          protocol,
          port,
          ip,
          timestamp,
          mac
        )
      end

      #
      # @param [String] buffer
      #
      def self.parse_banner3(buffer)
        timestamp, ip, port, app_proto = buffer.unpack('L>L>S>S>')

        timestamp = decode_timestamp(timestamp)
        ip        = decode_ipv4(ip)
        app_proto = lookup_app_protocol(app_proto)

        # defaults
        ip_proto = :tcp
        ttl = 0

        banner = buffer[12..]

        return Banner.new(
          ip_proto,
          port,
          ip,
          timestamp,
          app_proto,
          banner
        )
      end

      #
      # @param [String] buffer
      #
      def self.parse_banner4(buffer)
        if buffer.length < 13
          return
        end

        timestamp, ip, ip_prot, port, app_proto = buffer.unpack('L>L>CS>S>')

        timestamp = decode_timestamp(timestamp)
        ip        = decode_ipv4(ip)
        ip_proto  = lookup_ip_protocol(ip_proto)
        app_proto = lookup_app_protocol(app_proto)

        # defaults
        ttl = 0

        banner = buffer[13..]

        return Banner.new(
          ip_proto,
          port,
          ip,
          timestamp,
          app_proto,
          banner
        )
      end

      #
      # @param [String] buffer
      #
      # @param [:open, :closed] status
      #
      def self.parse_status2(buffer,status)
        if buffer.length < 13
          return
        end

        timestamp, ip, ip_proto, port, reason, ttl = buffer.unpack('L>L>CS>CC')
        timestamp = decode_timestamp(timestamp)
        ip        = decode_ipv4(ip)
        ip_proto  = lookup_ip_protocol(ip_proto)

        mac = if ip == 0 && buffer.length >= 13+6
                buffer[13,6]
              end

        return Status.new(
          status,
          ip_proto,
          port,
          ip,
          timestamp,
          mac
        )
      end

      #
      # @param [String] buffer
      #
      def self.parse_banner9(buffer)
        if buffer.length < 14
          return
        end

        timestamp, ip, ip_proto, port, app_proto, ttl = buffer.unpack('L>L>CS>S>C')
        timestamp = decode_timestamp(timestamp)
        ip        = decode_ipv4(ip)
        ip_proto  = lookup_ip_protocol(ip_proto)
        app_proto = lookup_app_protocol(app_proto)

        banner = buffer[14..]

        return Banner.new(
          ip_proto,
          port,
          ip,
          timestamp,
          app_proto,
          banner
        )
      end

      #
      # @param [String] buffer
      #
      # @param [:open, :closed] status
      #
      def self.parse_status6(buffer,status)
        timestamp, ip_proto, port, reason, ttl, ip_version, ipv6_hi, ipv6_lo = buffer.unpack('L>CS>CCCQ>Q>')
        timestamp  ||= 0xffffffff
        ip_proto   ||= 0xff
        port       ||= 0xffff
        reason     ||= 0xff
        ttl        ||= 0xff
        ip_version ||= 0xff
        ipv6_hi    ||= 0xffffffff_ffffffff
        ipv6_lo    ||= 0xffffffff_ffffffff

        unless ip_version == 6
          raise(CorruptedFile,"expected ip_version to be 6: #{ip_version.inspect}")
        end

        timestamp = decode_timestamp(timestamp)
        ip_proto  = lookup_ip_protocol(ip_proto)
        ipv6      = decode_ipv6(ipv6_hi,ipv6_lo)

        return Status.new(
          status,
          ip_proto,
          port,
          ipv6,
          timestamp
        )
      end

      #
      # @param [String] buffer
      #
      def self.parse_banner6(buffer)
        timestamp, ip_proto, port, app_proto, ttl, ip_version, ipv6_hi, ipv6_lo = buffer.unpack('L>CS>S>CCQ>Q>')
        timestamp  ||= 0xffffffff
        protocol   ||= 0xff
        port       ||= 0xffff
        app_proto  ||= 0xffff
        ttl        ||= 0xff
        ip_version ||= 0xff
        ipv6_hi    ||= 0xffffffff_ffffffff
        ipv6_lo    ||= 0xffffffff_ffffffff

        timestamp = decode_timestamp(timestamp)
        ip_proto  = lookup_ip_protocol(ip_proto)
        app_proto = lookup_app_protocol(app_proto)
        ipv6      = decode_ipv6(ipv6_hi,ipv6_lo)

        return Banner.new(
          ip_proto,
          port,
          ipv6,
          timestamp,
          app_proto,
          banner
        )
      end

    end
  end
end
