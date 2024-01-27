require_relative 'parsers/list'
require_relative 'parsers/json'
require_relative 'parsers/binary'

module Masscan
  #
  # Represents an output file.
  #
  # ## Example
  #
  #     output_file = Masscan::OutputFile.new('masscan.json')
  #     output_file.each do |record|
  #       p record
  #     end
  #
  class OutputFile

    # Mapping of formats to parsers.
    #
    # @api semipublic
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

    # The parser for the output file format.
    #
    # @return [Parsers::Binary, Parsers::JSON, Parsers::List]
    #
    # @api private
    attr_reader :parser

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

    # Mapping of file extensions to formats
    #
    # @api semipublic
    FILE_FORMATS = {
      '.bin' => :binary,
      '.dat' => :binary,

      '.txt' => :list,
      '.list' => :list,

      '.json'   => :json,
      '.ndjson' => :ndjson,

      '.xml' => :xml
    }

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
    # @api semipublic
    #
    def self.infer_format(path)
      FILE_FORMATS.fetch(File.extname(path)) do
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

    #
    # Converts the output file to a String.
    #
    # @return [String]
    #   The path to the output file.
    #
    # @since 0.2.0
    #
    def to_s
      @path
    end

  end
end
