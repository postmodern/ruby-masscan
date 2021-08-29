require 'rspec'

shared_examples_for "Parser.open" do
  context "when not given a block" do
    it "must return the opened file" do
      file = subject.open(path)

      expect(file).to be_kind_of(File)
      expect(file.closed?).to be(false)
    end
  end

  context "when given a block" do
    it "must yield the opened file" do
      file_class  = nil
      file_opened = nil

      subject.open(path) do |file|
        file_class  = file.class
        file_opened = !file.closed?
      end

      expect(file_class).to be(File)
      expect(file_opened).to be(true)
    end
  end
end

shared_examples_for "Parser.parse" do
  context "when given a block" do
    it "must yield Masscan::Status and Masscan::Banner objects" do
      yielded_record_classes = []

      subject.parse(io) do |record|
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
        subject.parse(subject.open(path)) do |record|
          yielded_records << record
        end
      end
    end

    it "must return an Enumerator" do
      expect(subject.parse(io).to_a).to eq(expected_records)
    end
  end
end
