require 'csv'

module Clerk
  class CSVParser < Clerk::Parser
 
    def initialize(options = {})
      super(options)
    end

    def parse(path, options = {})
      @data = CSV.parse(path, options)
    end

    def each(&block)
      @data.each(&block) 
    end
  end
end

Clerk::ParserRegistry.register(:csv, Clerk::CSVParser)
