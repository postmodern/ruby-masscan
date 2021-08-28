require 'masscan/parsers/list'
require 'masscan/parsers/json'
require 'masscan/parsers/binary'

module Masscan
  #
  # Represents an output file.
  #
  class OutputFile

    PARSERS = {
      binary: Parsers::Binary,
      list:   Parsers::List,
      json:   Parsers::JSON,
      ndjson: Parsers::JSON,
      # xml:    Parsers::XML,
    }

    # The path to the output file.
    #
    # @return [String]
    attr_reader :path

    # The format of the output file.
    #
    # @return [Symbol]
    attr_reader :format

    #
    # Initializes the output file.
    #
    # @param [String] path
    #
    # @param [:binary, :list, :json, :ndjson] format
    #
    # @raise [ArgumentError]
    #
    def initialize(path, format: self.class.infer_format(path))
      @path   = path
      @format = format

      @parser = PARSERS.fetch(format) do
        raise(ArgumentError,"unknown format: #{format.inspect}")
      end
    end

    #
    # Infers the format from the output file's extension name.
    #
    # @param [String] path
    #
    # @return [:binary, :list, :json, :ndjson]
    #
    # @raise [ArgumentError]
    #
    def self.infer_format(path)
      case File.extname(path)
      when '.bin', '.dat'     then :binary
      when '.txt', '.list'    then :list
      when '.json'            then :json
      when '.ndjson'          then :ndjson
      when '.xml'             then :xml
      else
        raise(ArgumentError,"could not infer format of #{path}")
      end
    end

    #
    # Parses the contents of the output file.
    #
    # @yield [record]
    #
    # @yield [Status, Banner] record
    #
    # @return [Enumerator]
    #
    def each(&block)
      return enum_for(__method__) unless block

      @parser.open(@path) do |file|
        @parser.parse(file,&block)
      end
    end

  end
end
