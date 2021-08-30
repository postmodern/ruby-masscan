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
end
