require 'spec_helper'
require_relative 'parser_examples'

require 'masscan/parsers/binary'
require 'stringio'

describe Masscan::Parsers::Binary do
  let(:path) { Fixtures.join('masscan.bin') }

  describe ".open" do
    include_examples "Parser.open"

    it "must open the file in binary mode" do
      file = subject.open(path)

      expect(file.binmode?).to be(true)
    end
  end

  let(:io) { subject.open(path) }

  describe ".parse" do
    include_examples "Parser.parse"
  end

  describe "PSEUDO_RECORD_SIZE" do
    subject { super()::PSEUDO_RECORD_SIZE }

    it "must be 99 ('a'.ord + 2)" do
      expect(subject).to eq('a'.ord + 2)
    end
  end

  describe "MASSCAN_MAGIC" do
    subject { super()::MASSCAN_MAGIC }

    it "must be 'masscan/1.1'" do
      expect(subject).to eq("masscan/1.1")
    end
  end

  describe ".read_pseudo_record" do
    let(:io) { StringIO.new(buffer) }

    let(:pseudo_record_size) { subject::PSEUDO_RECORD_SIZE }

    context "when the read buffer length is < PSEUDO_RECORD_SIZE" do
      let(:buffer) { "\0" * (pseudo_record_size - 3) }

      it do
        expect {
          subject.read_pseudo_record(io)
        }.to raise_error(subject::CorruptedFile,"invalid masscan binary format")
      end
    end

    context "when the read buffer length is >= PSEUDO_RECORD_SIZE" do
      let(:masscan_magic) { subject::MASSCAN_MAGIC }

      context "but does not start with MASSCAN_MAGIC string (masscan/1.1)" do
        let(:buffer) { "\0" * pseudo_record_size }

        it do
          expect {
            subject.read_pseudo_record(io)
          }.to raise_error(subject::CorruptedFile,"unknown file format (expected #{masscan_magic})")
        end
      end

      context "and does start with MASSCAN_MAGIC" do
        let(:buffer) do
          buffer = "\0" * (pseudo_record_size + 1024)
          buffer[0,masscan_magic.length] = masscan_magic
          buffer
        end

        it "must return the read buffer with length of PSEUDO_RECORD_SIZE" do
          pseudo_record = subject.read_pseudo_record(io)

          expect(pseudo_record.length).to eq(pseudo_record_size)
          expect(pseudo_record).to eq(buffer[0,pseudo_record_size])
        end
      end
    end
  end

  describe ".decode_timestamp" do
    let(:timestamp) { 1629960470         }
    let(:time)      { Time.at(timestamp) }

    it "must convert the UNIX timestamp into a Time object" do
      expect(subject.decode_timestamp(timestamp)).to eq(time)
    end
  end

  describe ".decode_ipv4" do
    let(:ipaddr)  { IPAddr.new("1.2.3.4") }
    let(:ip_uint) { ipaddr.to_i           }

    it "must convert a IPv4 address in uint form into an IPAddr object" do
      expect(subject.decode_ipv4(ip_uint)).to eq(ipaddr)
    end
  end

  describe ".decode_ipv6" do
    let(:ipaddr) { IPAddr.new("2606:2800:220:1:248:1893:25c8:1946") }
    let(:ip_uint_hi) { (ipaddr.to_i & (0xffffffff_ffffffff << 64)) >> 64 }
    let(:ip_uint_lo) { (ipaddr.to_i & 0xffffffff_ffffffff) }

    it "must combine the hi and lo 64bit uints of an IPv6 address into an IPAddr object" do
      expect(subject.decode_ipv6(ip_uint_hi,ip_uint_lo)).to eq(ipaddr)
    end
  end

  describe ".lookup_ip_protocol" do
    context "when given 1 (IPPROTO_ICMP)" do
      it "must reutrn :icmp" do
        expect(subject.lookup_ip_protocol(1)).to be(:icmp)
      end
    end

    context "when given 58 (IPPROTO_ICMPV6)" do
      it "must reutrn :icmp" do
        expect(subject.lookup_ip_protocol(58)).to be(:icmp)
      end
    end

    context "when given 6 (IPPROTO_TCP)" do
      it "must reutrn :tcp" do
        expect(subject.lookup_ip_protocol(6)).to be(:tcp)
      end
    end

    context "when given 6 (IPPROTO_UDP)" do
      it "must reutrn :udp" do
        expect(subject.lookup_ip_protocol(17)).to be(:udp)
      end
    end

    context "when given 132 (IPPROTO_SCTP)" do
      it "must reutrn :udp" do
        expect(subject.lookup_ip_protocol(132)).to be(:sctp)
      end
    end
  end

  describe ".decode_reason" do
    context "when given 0" do
      it "must return []" do
        expect(subject.decode_reason(0)).to eq([])
      end
    end

    {
      fin: 0x01,
      syn: 0x02,
      rst: 0x04,
      psh: 0x08,
      ack: 0x10,
      urg: 0x20,
      ece: 0x40,
      cwr: 0x80
    }.each do |reason,bitflag|
      context "when given an integer with the #{"0x%x" % bitflag} bit set" do
        it "must include the #{reason.inspect} flag" do
          expect(subject.decode_reason(bitflag)).to eq([reason])
        end
      end
    end

    context "when given an integer containing multiple bits set" do
      it "must return the associated reason flags" do
        expect(subject.decode_reason(0x02 | 0x10)).to eq([:syn, :ack])
      end
    end
  end

  describe ".lookup_app_protocol" do
    context "when given 0" do
      it "must return nil" do
        expect(subject.lookup_app_protocol(0)).to be(nil)
      end
    end

    {
      1 => :heur,
      2 => :ssh1,
      3 => :ssh2,
      4 => :http,
      5 => :ftp,
      6 => :dns_versionbind,
      7 => :snmp,
      8 => :nbtstat,
      9 => :ssl3,
      10 => :smb,
      11 => :smtp,
      12 => :pop3,
      13 => :imap4,
      14 => :udp_zeroaccess,
      15 => :x509_cert,
      16 => :html_title,
      17 => :html_full,
      18 => :ntp,
      19 => :vuln,
      20 => :heartbleed,
      21 => :ticketbleed,
      22 => :vnc_rfb,
      23 => :safe,
      24 => :memcached,
      25 => :scripting,
      26 => :versioning,
      27 => :coap,
      28 => :telnet,
      29 => :rdp,
      30 => :http_server
    }.each do |index,keyword|
      context "when given #{index}" do
        it "must return #{keyword.inspect} keyword" do
          expect(subject.lookup_app_protocol(index)).to be(keyword)
        end
      end
    end
  end
end
