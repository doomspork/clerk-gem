module Clerk
  class ParserRegistry
    @registry = Hash.new

    def self.register(sym, parser)
      raise ArgumentError, "Registered parsers must subclass Clerk::Parser"  if parser < self.class
      @registry[sym] = parser
    end

    def self.contains?(sym)
      !!lookup(sym)
    end

    def self.lookup(sym)
      @registry[sym] 
    end

  end
end
