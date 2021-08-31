require 'spec_helper'
require_relative 'parser_examples'

require 'masscan/parsers/json'
require 'stringio'

describe Masscan::Parsers::JSON do
  let(:path) { Fixtures.join('masscan.json') }

  describe ".open" do
    include_examples "Parser.open"
  end

  let(:io) { subject.open(path) }

  describe ".parse" do
    include_examples "Parser.parse"

    context "when the line is a '[' character" do
      let(:lines) do
        [
          "[",
          %{{   "ip": "93.184.216.34",   "timestamp": "1629960621", "ports": [ {"port": 80, "proto": "tcp", "status": "open", "reason": "syn-ack", "ttl": 54} ] }}
        ]
      end

      let(:io) { StringIO.new(lines.join("\n")) }

      it "must skip it" do
        yielded_records = []

        subject.parse(io) do |record|
          yielded_records << record
        end

        expect(yielded_records.length).to eq(1)
        expect(yielded_records.first).to be_kind_of(Masscan::Status)
      end
    end

    context "when the line is a ',' character" do
      let(:lines) do
        [
          ",",
          %{{   "ip": "93.184.216.34",   "timestamp": "1629960621", "ports": [ {"port": 80, "proto": "tcp", "status": "open", "reason": "syn-ack", "ttl": 54} ] }}
        ]
      end

      let(:io) { StringIO.new(lines.join("\n")) }

      it "must skip it" do
        yielded_records = []

        subject.parse(io) do |record|
          yielded_records << record
        end

        expect(yielded_records.length).to eq(1)
        expect(yielded_records.first).to be_kind_of(Masscan::Status)
      end
    end

    context "when the line is a ']' character" do
      let(:lines) do
        [
          %{{   "ip": "93.184.216.34",   "timestamp": "1629960621", "ports": [ {"port": 80, "proto": "tcp", "status": "open", "reason": "syn-ack", "ttl": 54} ] }},
          "]",
        ]
      end

      let(:io) { StringIO.new(lines.join("\n")) }

      it "must skip it" do
        yielded_records = []

        subject.parse(io) do |record|
          yielded_records << record
        end

        expect(yielded_records.length).to eq(1)
        expect(yielded_records.first).to be_kind_of(Masscan::Status)
      end
    end

    context "when the line starts with a '{'" do
      context "and contains a \"ports\": JSON Hash" do
        let(:protocol)  { :tcp }
        let(:status)    { :open }
        let(:port)      { 443 }
        let(:ip)        { IPAddr.new("93.184.216.34") }
        let(:timestamp) { Time.at(1629960470) }
        let(:reason)    { [:syn, :ack] }
        let(:ttl)       { 54 }

        let(:line) do
          %{{   "ip": "#{ip}",   "timestamp": "#{timestamp.to_i}", "ports": [ {"port": #{port}, "proto": "#{protocol}", "status": "#{status}", "reason": "#{reason.join('-')}", "ttl": #{ttl}} ] }}
        end
        let(:io) { StringIO.new(line) }

        it "must parse the line into a Masscan::Status object" do
          yielded_records = []

          subject.parse(io) do |record|
            yielded_records << record
          end

          expect(yielded_records.length).to eq(1)
          expect(yielded_records.first).to be_kind_of(Masscan::Status)

          yielded_status = yielded_records.first

          expect(yielded_status.status).to    be(status)
          expect(yielded_status.protocol).to  be(protocol)
          expect(yielded_status.port).to      be(port)
          expect(yielded_status.reason).to    eq(reason)
          expect(yielded_status.ttl).to       be(ttl)
          expect(yielded_status.ip).to        eq(ip)
          expect(yielded_status.timestamp).to eq(timestamp)
        end

        context "but also contains a \"service\": JSON Hash" do
          let(:service_name)    { "http.server" }
          let(:service_keyword) { :http_server  }

          let(:payload) { "ECS (sec/974D)" }

          let(:line) do
            %{{   "ip": "#{ip}",   "timestamp": "#{timestamp.to_i}", "ports": [ {"port": #{port}, "proto": "#{protocol}", "service": {"name": "#{service_name}", "banner": "#{payload}"} } ] }}
          end

          let(:io) { StringIO.new(line) }

          it "must parse the line into a Masscan::Banner object" do
            yielded_records = []

            subject.parse(io) do |record|
              yielded_records << record
            end

            expect(yielded_records.length).to eq(1)
            expect(yielded_records.first).to be_kind_of(Masscan::Banner)

            yielded_banner = yielded_records.first

            expect(yielded_banner.protocol).to  be(protocol)
            expect(yielded_banner.port).to      be(port)
            expect(yielded_banner.ip).to        eq(ip)
            expect(yielded_banner.timestamp).to eq(timestamp)

            expect(yielded_banner.service).to eq(service_keyword)
            expect(yielded_banner.payload).to eq(payload)
          end
        end
      end
    end
  end
end
