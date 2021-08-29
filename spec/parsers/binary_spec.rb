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
end
