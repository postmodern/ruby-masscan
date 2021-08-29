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
    # @api semipublic
    #
    module Binary
      #
      # Opens a binary file for parsing.
      #
      # @param [String] path
      #   The path to the file.
      #
      # @yield [file]
      #   If a block is given, it will be passed the opened file.
      #   Once the block returns, the file will be closed.
      #
      # @yieldparam [File]
      #   The opened file.
      #
      # @return [File]
      #   If no block was given, the opened file will be returned.
      #
      def self.open(path,&block)
        File.open(path,'rb',&block)
      end

      class CorruptedFile < RuntimeError
      end

      # Maximum buffer length for a single record.
      BUF_MAX = 1024 * 1024

      #
      # Parses masscan binary data.
      #
      # @param [IO] io
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

      # The "psecudo record" length
      PSEUDO_RECORD_SIZE = 99 # 'a'.ord + 2

      # Masscan binary format version compatability.
      MASSCAN_VERSION_FAMILY = "1.1"

      # The `masscan` binary format magic string.
      MASSCAN_MAGIC = "masscan/#{MASSCAN_VERSION_FAMILY}"

      #
      # Reads the "pseudo record" at the beginning of the file.
      #
      # @param [IO] io
      #   The IO object to read from.
      #
      # @return [String]
      #   The read buffer.
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
      # Reads a multi-byte unsigned integer.
      #
      # @param [IO] io
      #   The IO object to read from.
      #
      # @return [Integer, nil]
      #   The unsigned integer, or `nil` if End-of-Stream was reached.
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
      # Decodes a timestamp from an integer.
      #
      # @param [Integer] timestamp
      #   The raw UNIX timestamp integer.
      #
      # @return [Time]
      #   The decoded time value.
      #
      def self.decode_timestamp(timestamp)
        Time.at(timestamp)
      end

      #
      # Decodes an IPv4 address from an integer.
      #
      # @param [Integer] ip
      #   The IP in raw integer form.
      #
      # @return [IPAddr]
      #   The decoded IPv4 address.
      #
      def self.decode_ipv4(ip)
        IPAddr.new(ip,Socket::AF_INET)
      end

      #
      # Decodes an IPv6 address from two 64bit integers.
      #
      # @param [Integer] ipv6_hi
      #   The top-half of the 128bit IPv6 address.
      #
      # @param [Integer] ipv6_lo
      #   The top-half of the 128bit IPv6 address.
      #
      # @return [IPAddr]
      #   The decoded IPv6 address.
      #
      def self.decode_ipv6(ipv6_hi,ipv6_lo)
        IPAddr.new((ipv6_hi << 64) | ipv6_lo,Socket::AF_INET6)
      end

      # Mapping of IP protocol numbers to keywords.
      IP_PROTOCOLS = {
        Socket::IPPROTO_ICMP   => :icmp,
        Socket::IPPROTO_ICMPV6 => :icmp,

        Socket::IPPROTO_TCP => :tcp,
        Socket::IPPROTO_UDP => :udp,

        132 => :sctp # Socket::IPPROTO_SCTP might not always be defined
      }

      #
      # Looks up an IP protocol number.
      #
      # @param [Integer] proto
      #   The IP protocol number.
      #
      # @return [:icmp, :tcp, :udp, :sctp, nil]
      #   The IP protocol keyword.
      #
      # @see IP_PROTOCOLS
      #
      def self.lookup_ip_protocol(proto)
        IP_PROTOCOLS[proto]
      end

      # List of application protocol keywords.
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
      # Looks up an application protocol number.
      #
      # @param [Integer] proto
      #   The application protocol number.
      #
      # @return [Symbol, nil]
      #   The application protocol keyword.
      #
      # @see APP_PROTOCOLS
      #
      def self.lookup_app_protocol(proto)
        APP_PROTOCOLS[proto]
      end

      #
      # Parses a status record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @param [:open, :closed] status
      #   Indicates whether the port status is open or closed.
      #
      # @return [Status]
      #   The parsed status record.
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
      # Parses a banner record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @return [Buffer]
      #   The parsed buffer record.
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
      # Parses a banner record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @return [Buffer]
      #   The parsed buffer record.
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
      # Parses a status record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @param [:open, :closed] status
      #   Indicates whether the port status is open or closed.
      #
      # @return [Status]
      #   The parsed status record.
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
      # Parses a banner record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @return [Buffer]
      #   The parsed buffer record.
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
      # Parses a status record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @param [:open, :closed] status
      #   Indicates whether the port status is open or closed.
      #
      # @return [Status]
      #   The parsed status record.
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
      # Parses a banner record.
      #
      # @param [String] buffer
      #   The buffer to parse.
      #
      # @return [Buffer]
      #   The parsed buffer record.
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
