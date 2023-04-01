require 'spec_helper'
require 'masscan/command'

describe Masscan::Command do
  describe described_class::Port do
    describe "#validate" do
      context "when given an Integer" do
        let(:value) { 443 }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but it's less than 1" do
          let(:value) { 0 }

          it "must return [false, \"(...) not within the range of acceptable values (1..65535)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "(#{value.inspect}) not within the range of acceptable values (1..65535)"]
            )
          end
        end

        context "but it's greater than 65535" do
          let(:value) { 65536 }

          it "must return [false, \"(...) not within the range of acceptable values (1..65535)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "(#{value.inspect}) not within the range of acceptable values (1..65535)"]
            )
          end
        end
      end

      context "when given a String" do
        context "and it's a number" do
          let(:value) { '443' }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "but it's less than 1" do
            let(:value) { '0' }

            it "must return [false, \"must be a valid port number (...)\"]" do
              expect(subject.validate(value)).to eq(
                [false, "must be a valid port number (#{value.inspect})"]
              )
            end
          end

          context "but it's greater than 65535" do
            let(:value) { '65536' }

            it "must return [false, \"must be a valid port number (...)\"]" do
              expect(subject.validate(value)).to eq(
                [false, "must be a valid port number (#{value.inspect})"]
              )
            end
          end
        end

        context "but it contains numbers" do
          let(:value) { "foo" }

          it "must return [false, \"must be a valid port number (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "must be a valid port number (#{value.inspect})"]
            )
          end
        end
      end
    end
  end

  describe described_class::PortRange do
    describe "#validate" do
      context "when given an Integer value" do
        let(:value) { 443 }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but it's less than 1" do
          let(:value) { 0 }

          it "must return [false, \"(...) not within the range of acceptable values (1..65535)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "(#{value.inspect}) not within the range of acceptable values (1..65535)"]
            )
          end
        end

        context "but it's greater than 65535" do
          let(:value) { 65536 }

          it "must return [false, \"(...) not within the range of acceptable values (1..65535)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "(#{value.inspect}) not within the range of acceptable values (1..65535)"]
            )
          end
        end
      end

      context "when given a String value" do
        let(:value) { '443' }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but it's less than 1" do
          let(:value) { '0' }

          it "must return [false, \"must be a valid port range or port number (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "must be a valid port range or port number (#{value.inspect})"]
            )
          end
        end

        context "but it's greater than 65535" do
          let(:value) { '65536' }

          it "must return [false, \"must be a valid port range or port number (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "must be a valid port range or port number (#{value.inspect})"]
            )
          end
        end
      end

      context "when given a Range of port numbers" do
        let(:value) { (1..1024) }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
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
        let(:value) { 1..1024 }

        it "must return the formatted port number range (ex: 1-102)" do
          expect(subject.format(value)).to eq("#{value.begin}-#{value.end}")
        end
      end
    end
  end

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

      context "when given a String" do
        context "and it contains a single number" do
          let(:value) { "443" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "and it's prefixed by 'U:'" do
            let(:value) { "U:#{super()}" }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end
        end

        context "and it contains a range of ports" do
          let(:value) { "1-1024" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "and it's prefixed by 'U:'" do
            let(:value) { "U:#{super()}" }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end
        end

        context "and it contains a comma separated list of port numbers" do
          let(:value) { "80,443" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "and it's prefixed by 'U:'" do
            let(:value) { "U:#{super()}" }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end
        end

        context "and it contains a comma separated list of port ranges" do
          let(:value) { "1-42,80-8080" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "and it's prefixed by 'U:'" do
            let(:value) { "U:#{super()}" }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end
        end

        context "and it contains a comma separated list of port numbers and ranges" do
          let(:value) { "1-42,50,60,70,80-8080,9000" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "and it's prefixed by 'U:'" do
            let(:value) { "U:#{super()}" }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end
        end

        context "when it contains non-digits" do
          let(:value) { "1,2,3,4,a,b,c" }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "not a valid port list (#{value.inspect})"]
            )
          end
        end

        context "when it contains whitespace" do
          let(:value) { "1,2, 3,4" }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "not a valid port list (#{value.inspect})"]
            )
          end
        end

        context "when it contains new-lines" do
          let(:value) { "1,2,\n3,4" }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "not a valid port list (#{value.inspect})"]
            )
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

      context "when given a String" do
        let(:value) { "22,25,80,443" }

        it "must return the String" do
          expect(subject.format(value)).to eq(value)
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

  describe described_class::RotateTime do
    describe "#validate" do
      context "when given an Integer" do
        let(:value) { 42 }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "when given a String" do
        context "but the String is a number" do
          let(:value) { '42' }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "but the String is 'hourly'" do
          let(:value) { 'hourly' }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "but the String is '<N>hours'" do
          let(:value) { '2hours' }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "but the String is '<N>min'" do
          let(:value) { '10min' }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "but the String is not a number" do
          let(:value) { "abc" }

          it "must return a validation error" do
            expect(subject.validate(value)).to eq([false, "invalid rotation time (#{value.inspect})"])
          end
        end

        context "but the String contains a new-line" do
          let(:value) { "10\nfoo" }

          it "must return a validation error" do
            expect(subject.validate(value)).to eq([false, "invalid rotation time (#{value.inspect})"])
          end
        end
      end
    end
  end
end
