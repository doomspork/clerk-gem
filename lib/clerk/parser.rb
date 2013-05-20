module Clerk
  class Parser
    include Enumerable

    attr_accessor :options

    def initialize(options = {})
      @options = options.freeze
    end

    def parse(path, options = {})
      raise NotImplementedError, "Subclasses must implement a parse method"
    end

    def each
      raise NotImplementedError, "Subclasses must implement a each method"
    end

  end
end

Dir[File.dirname(__FILE__) + "/parsers/*.rb"].each { |file| require file }
