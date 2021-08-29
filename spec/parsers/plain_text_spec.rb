require 'spec_helper'
require 'masscan/parsers/plain_text'

describe Masscan::Parsers::PlainText do
  module TestPlainText
    extend Masscan::Parsers::PlainText
  end

  subject { TestPlainText }

  describe "#parse_status" do
    context "when given 'open'" do
      it "must return :open" do
        expect(subject.parse_status("open")).to be(:open)
      end
    end

    context "when given 'closed'" do
      it "must return :closed" do
        expect(subject.parse_status("closed")).to be(:closed)
      end
    end

    context "when given an unknown String" do
      it "must return the String" do
        expect(subject.parse_status("foo")).to eq("foo")
      end
    end
  end

  describe "#parse_ip_protocol" do
    context "when given 'tcp'" do
      it "must return :tcp" do
        expect(subject.parse_ip_protocol("tcp")).to be(:tcp)
      end
    end

    context "when given 'udp'" do
      it "must return :udp" do
        expect(subject.parse_ip_protocol("udp")).to be(:udp)
      end
    end

    context "when given 'icmp'" do
      it "must return :icmp" do
        expect(subject.parse_ip_protocol("icmp")).to be(:icmp)
      end
    end

    context "when given 'sctp'" do
      it "must return :sctp" do
        expect(subject.parse_ip_protocol("sctp")).to be(:sctp)
      end
    end

    context "when given an unknown String" do
      it "must return the String" do
        expect(subject.parse_ip_protocol("foo")).to eq("foo")
      end
    end
  end

  describe "#parse_app_protocol" do
    described_class::APP_PROTOCOLS.each do |string,keyword|
      context "when given '#{string}'" do
        it "must return #{keyword.inspect}" do
          expect(subject.parse_app_protocol(string)).to be(keyword)
        end
      end
    end

    context "when given an unknown String" do
      it "must return the String" do
        expect(subject.parse_app_protocol("foo")).to eq("foo")
      end
    end
  end

  describe "#parse_timestamp" do
    let(:timestamp) { 1629960470         }
    let(:time)      { Time.at(timestamp) }

    it "must parse a given UNIX timestamp and return a Time object" do
      expect(subject.parse_timestamp(timestamp)).to eq(time)
    end
  end

  describe "#parse_ip" do
    let(:ip_string) { "1.2.3.4" }
    let(:ip_addr)   { IPAddr.new(ip_string) }

    it "must parse a given IP string and return an IPAddr" do
      expect(subject.parse_ip(ip_string)).to eq(ip_addr)
    end
  end
end
