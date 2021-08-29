require 'spec_helper'
require 'masscan/task'

describe Masscan::Task do
  describe "#ports=" do
    context "when given an empty Array" do
      before { subject.ports = [] }

      it "should ignore empty port Arrays" do
        subject.ports = []

        expect(subject.arguments).to eq([])
      end
    end

    context "when given a String" do
      let(:ports) { '80,21,25' }

      before { subject.ports = ports }

      it "should emit the String as is" do
        expect(subject.arguments).to eq(['-p', ports])
      end
    end

    context "when given an Array of Strings" do
      let(:ports) { %w[80 21 25] }

      before { subject.ports = ports }

      it "should format an Array of String ports" do
        expect(subject.arguments).to eq(['-p', ports.join(',')])
      end
    end

    context "when given an Array of Integers" do
      let(:ports) { [80, 21, 25] }

      before { subject.ports = ports }

      it "should format an Array of Integer ports" do
        expect(subject.arguments).to eq(['-p', ports.join(',')])
      end
    end

    context "when given an Array containing a Range" do
      let(:ports) { [80, 21..25] }

      before { subject.ports = ports }

      it "should format the Range" do
        expect(subject.arguments).to eq([
          '-p', "#{ports[0]},#{ports[1].begin}-#{ports[1].end}"
        ])
      end
    end
  end

  describe "#shards=" do
    context "when given a Rational value" do
      let(:rational) { (1/2r) }

      before { subject.shards = rational }

      it "must format it into \#{numerator}/\#{denominator}" do
        expect(subject.arguments).to eq([
          "--shards", "#{rational.numerator}/#{rational.denominator}"
        ])
      end
    end

    context "when given an Array value" do
      let(:array) { [1, 2] }

      before { subject.shards = array }

      it "must format it into \#{array[0]}/\#{array[1]}" do
        expect(subject.arguments).to eq([
          "--shards", "#{array[0]}/#{array[1]}"
        ])
      end

      context "but the Array length is > 2" do
        let(:array) { [1,2,3] }

        before { subject.shards = array }

        it do
          expect {
            subject.arguments
          }.to raise_error(ArgumentError,"#{described_class}#shards= does not accept more than two values")
        end
      end
    end

    context "otherwise" do
      let(:object) { :"1/2" }

      before { subject.shards = object }

      it "must convert the value to a String" do
        expect(subject.arguments).to eq([
          "--shards", object.to_s
        ])
      end
    end
  end

  describe "#http_field=" do
    let(:name)  { 'X-Foo' }
    let(:value) { 'bar'   }

    before { subject.http_field = [ [name, value] ] }

    it "must join two values together with a ':'" do
      expect(subject.arguments).to eq([
        "--http-field", "#{name}:#{value}"
      ])
    end
  end
end
