require 'spec_helper'
require 'masscan/command'

describe Masscan::Command do
  describe described_class::PortList do
    describe "#validate" do
      context "when given a single port number" do
        let(:value) { 443 }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "when given a Range of port numbers" do
        let(:value) { (1..1024) }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "when given an Array of port numbers" do
        let(:value) { [80, 443] }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "and the Array contains Ranges" do
          let(:value) { [80, (1..42), 443] }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end
    end

    describe "#format" do
      context "when given a single port number" do
        let(:value) { 443 }

        it "must return the formatted port number" do
          expect(subject.format(value)).to eq(value.to_s)
        end
      end

      context "when given a Range of port numbers" do
        let(:value) { (1..1024) }

        it "must return the formatted port number range (ex: 1-102)" do
          expect(subject.format(value)).to eq("#{value.begin}-#{value.end}")
        end
      end

      context "when given an Array of port numbers" do
        let(:value) { [80, 443] }

        it "must return the formatted list of port numbers" do
          expect(subject.format(value)).to eq(value.join(','))
        end

        context "and the Array contains Ranges" do
          let(:value) { [80, (1..42), 443] }

          it "must return the formatted list of port numbers and port ranges" do
            expect(subject.format(value)).to eq("#{value[0]},#{value[1].begin}-#{value[1].end},#{value[2]}")
          end
        end
      end
    end
  end

  describe described_class::Shards do
    describe "#validate" do
      context "when given a Rational value" do
        let(:value) { (1/2r) }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "when given an Array value" do
        let(:value) { [1, 2] }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but the Array length is > 2" do
          let(:value) { [1,2,3] }

          it "must return a validation error" do
            expect(subject.validate(value)).to eq(
              [false, "cannot contain more tha two elements (#{value.inspect})"]
            )
          end
        end
      end

      context "otherwise" do
        let(:value) { :"1/2" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end
    end

    describe "#format" do
      context "when given a Rational value" do
        let(:value) { (1/2r) }

        it "must format it into \#{numerator}/\#{denominator}" do
          expect(subject.format(value)).to eq(
            "#{value.numerator}/#{value.denominator}"
          )
        end
      end

      context "when given an Array value" do
        let(:value) { [1, 2] }

        it "must format it into \#{array[0]}/\#{array[1]}" do
          expect(subject.format(value)).to eq(
            "#{value[0]}/#{value[1]}"
          )
        end
      end

      context "otherwise" do
        let(:value) { :"1/2" }

        it "must convert the value to a String" do
          expect(subject.format(value)).to eq(value.to_s)
        end
      end
    end
  end
end
