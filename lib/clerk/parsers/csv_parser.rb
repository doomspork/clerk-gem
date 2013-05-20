require 'csv'

module Clerk
  class CSVParser < Clerk::Parser
 
    def initialize(options = {})
      super(options)
    end

    def parse(path, options = {})
      @data = CSV.parse(path, options)
    end

    def each
      line = @data.read_line
      yield line if block_given? 
    end

    def enum_of
  end
end

Clerk::Parser.register(:csv, Clerk::CSVParser)
