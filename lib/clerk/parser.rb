module Clerk
  class Parser
    include Enumerable

    attr_accessor :options

    @parser_registry = Hash.new

    def initialize(options = {})
      @options = options.freeze
    end

    def each(&block)
      raise NotImplementedError, "Subclasses must implement a each(&block) method"
    end

    def self.register(sym, parser)
      raise ArgumentError, "Registered parsers must subclass Clerk::Parser"  if parser < self.class
      @parser_registry[sym] = parser
    end

    def self.contains?(sym)
      !!lookup(sym)
    end

    def self.lookup(sym)
      @parser_registry[sym] 
    end
  end
end

Dir[File.dirname(__FILE__) + "/parsers/*.rb"].each { |file| require file }
