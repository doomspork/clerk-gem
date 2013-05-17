require 'csv'

module Clerk
  class CSVParser < Clerk::Parser
 
    def initialize(path, options = {})
      super(params)
      @path = path
      open_file
    end

    def open_file(path)
      @csv = CSV.open(path)
    end

    def each(&block)
      line = @csv.read_line
      yield block(line)
    end
  end
end

Clerk::Parser.register(:csv, Clerk::CSVParser)
