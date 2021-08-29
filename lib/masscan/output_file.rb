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
    #   The path to the output file.
    #
    # @param [:binary, :list, :json, :ndjson] format
    #   The format of the output file. Defaults to {infer_format}.
    #
    # @raise [ArgumentError]
    #   The output format was not given and it cannot be inferred.
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
    #   The path to the output file.
    #
    # @return [:binary, :list, :json, :ndjson]
    #   The output format inferred from the file's extension name.
    #
    # @raise [ArgumentError]
    #   The output format could not be inferred from the file's name.
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
    #   If a block is given, it will be passed each parsed record.
    #
    # @yield [Status, Banner] record
    #   A parsed record, either a {Status} or a {Banner}.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each(&block)
      return enum_for(__method__) unless block

      @parser.open(@path) do |file|
        @parser.parse(file,&block)
      end
    end

  end
end
