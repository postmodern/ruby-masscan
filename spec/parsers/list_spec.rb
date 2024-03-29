require 'spec_helper'
require_relative 'parser_examples'

require 'masscan/parsers/list'
require 'stringio'

describe Masscan::Parsers::List do
  let(:path) { Fixtures.join('masscan.list') }

  describe ".open" do
    include_examples "Parser.open"
  end

  let(:io) { subject.open(path) }

  describe ".parse" do
    include_examples "Parser.parse"

    context "when the line begins with a '#' character" do
      let(:lines) do
        [
          "#masscan",
          "open tcp 443 93.184.216.34 1629960470",
          "#end"
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

    context "when the line begins with 'open '" do
      let(:protocol)  { :tcp }
      let(:port)      { 443 }
      let(:ip)        { IPAddr.new("93.184.216.34") }
      let(:timestamp) { Time.at(1629960470) }
      let(:line)      { "open #{protocol} #{port} #{ip} #{timestamp.to_i}" }
      let(:io)        { StringIO.new(line) }

      it "must parse the line into a Masscan::Status object" do
        yielded_records = []

        subject.parse(io) do |record|
          yielded_records << record
        end

        expect(yielded_records.length).to eq(1)
        expect(yielded_records.first).to be_kind_of(Masscan::Status)

        yielded_status = yielded_records.first

        expect(yielded_status.status).to    be(:open)
        expect(yielded_status.protocol).to  be(protocol)
        expect(yielded_status.port).to      be(port)
        expect(yielded_status.ip).to        eq(ip)
        expect(yielded_status.timestamp).to eq(timestamp)
      end
    end

    context "when the line begins with 'banner '" do
      let(:protocol)  { :tcp }
      let(:port)      { 80 }
      let(:ip)        { IPAddr.new("93.184.216.34") }
      let(:timestamp) { Time.at(1629960472) }

      let(:service_name)    { "http.server" }
      let(:service_keyword) { :http_server  }

      let(:payload) { "ECS (sec/974D)" }

      let(:line) do
        "banner #{protocol} #{port} #{ip} #{timestamp.to_i} #{service_name} #{payload}"
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
        expect(yielded_banner.payload).to  eq(payload)
      end

      context "when the payload field contains '\\xXX' hex escaped characters" do
        let(:escaped_payload) do
          "HTTP/1.0 404 Not Found\\x0d\\x0aContent-Type: text/html\\x0d\\x0aDate: Thu, 26 Aug 2021 06:47:52 GMT\\x0d\\x0aServer: ECS (sec/974D)\\x0d\\x0aContent-Length: 345\\x0d\\x0aConnection: close\\x0d\\x0a\\x0d"
        end
        let(:unescaped_payload) do
          "HTTP/1.0 404 Not Found\r\nContent-Type: text/html\r\nDate: Thu, 26 Aug 2021 06:47:52 GMT\r\nServer: ECS (sec/974D)\r\nContent-Length: 345\r\nConnection: close\r\n\r"
        end

        let(:line) do
          "banner #{protocol} #{port} #{ip} #{timestamp.to_i} #{service_name} #{escaped_payload}"
        end

        it "must unescape the '\\xXX' hex escaped characters" do
          yielded_records = []

          subject.parse(io) do |record|
            yielded_records << record
          end

          yielded_banner = yielded_records.first

          expect(yielded_banner.payload).to eq(unescaped_payload)
        end
      end
    end
  end
end
