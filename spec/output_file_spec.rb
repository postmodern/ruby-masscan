require 'spec_helper'
require 'masscan/output_file'

describe Masscan::OutputFile do
  it { expect(described_class).to include(Enumerable) }

  describe ".infer_format" do
    subject { described_class.infer_format(path) }

    context "when the path ends in .json" do
      let(:path) { '/path/to/file.json' }

      it { expect(subject).to eq(:json) }
    end

    context "when the path ends in .ndjson" do
      let(:path) { '/path/to/file.ndjson' }

      it { expect(subject).to eq(:ndjson) }
    end

    context "when the path ends in .list" do
      let(:path) { '/path/to/file.list' }

      it { expect(subject).to eq(:list) }
    end

    context "when the path ends in .txt" do
      let(:path) { '/path/to/file.txt' }

      it { expect(subject).to eq(:list) }
    end

    context "when the path ends in .bin" do
      let(:path) { '/path/to/file.bin' }

      it { expect(subject).to eq(:binary) }
    end

    context "when the path ends in .dat" do
      let(:path) { '/path/to/file.dat' }

      it { expect(subject).to eq(:binary) }
    end

    context "when the path ends in .xml" do
      let(:path) { '/path/to/file.xml' }

      it { expect(subject).to eq(:xml) }
    end
  end

  describe "PARSERS" do
    subject { described_class::PARSERS }

    describe ":binary" do
      it { expect(subject[:binary]).to eq(Masscan::Parsers::Binary) }
    end

    describe ":list" do
      it { expect(subject[:list]).to eq(Masscan::Parsers::List) }
    end

    describe ":json" do
      it { expect(subject[:json]).to eq(Masscan::Parsers::JSON) }
    end

    describe ":ndjson" do
      it { expect(subject[:ndjson]).to eq(Masscan::Parsers::JSON) }
    end
  end

  describe "FILE_FORMATS" do
    subject { described_class::FILE_FORMATS }

    describe ".bin" do
      it { expect(subject['.bin']).to be(:binary) }
    end

    describe ".dat" do
      it { expect(subject['.dat']).to be(:binary) }
    end

    describe ".txt" do
      it { expect(subject['.txt']).to be(:list) }
    end

    describe ".list" do
      it { expect(subject['.list']).to be(:list) }
    end

    describe ".json" do
      it { expect(subject['.json']).to be(:json) }
    end

    describe ".ndjson" do
      it { expect(subject['.ndjson']).to be(:ndjson) }
    end

    describe ".xml" do
      it { expect(subject['.xml']).to be(:xml) }
    end
  end

  describe "#initialize" do
    let(:path) { "/path/to/file.json" }

    subject { described_class.new(path) }

    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    it "must infer the format from the file's extname" do
      expect(subject.format).to eq(:json)
    end

    it "must set #parser based on #format" do
      expect(subject.parser).to eq(described_class::PARSERS[subject.format])
    end

    context "when given an format: keyword" do
      let(:format) { :list }

      subject { described_class.new(path, format: format) }

      it "must set #format" do
        expect(subject.format).to be(format)
      end

      it "must set #parser based on the given format:" do
        expect(subject.parser).to eq(described_class::PARSERS[format])
      end
    end
  end

  let(:path) { Fixtures.join('masscan.list') }

  subject { described_class.new(path) }

  describe "#each" do
    context "when given a block" do
      it "must yield Masscan::Status and Masscan::Banner objects" do
        yielded_record_classes = []

        subject.each do |record|
          yielded_record_classes << record.class
        end

        expect(yielded_record_classes.uniq).to eq([
          Masscan::Status,
          Masscan::Banner
        ])
      end
    end

    context "when given no block" do
      let(:expected_records) do
        [].tap do |yielded_records|
          subject.each do |record|
            yielded_records << record
          end
        end
      end

      it "must return an Enumerator" do
        expect(subject.each.to_a).to eq(expected_records)
      end
    end
  end

  describe "#to_s" do
    it "must return #path" do
      expect(subject.to_s).to eq(path)
    end
  end
end
