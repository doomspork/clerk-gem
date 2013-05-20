module Clerk
  class Base
    include ActiveModel::Validations

    def initialize
      @transformed_values = Array.new
    end

    def load(path)
      @raw_values = self.class.parser.parse(path).to_enum
    end

    def results
      Enumerator.new do |yielder|
        @raw_values.each_with_index do |value, index|
          yielder << @transformed_values[index] ||= self.class.apply_template(value)
        end
      end
    end

    def self.apply_template(data)
      # Apply template through the transformer
    end

    ##
    # Configuration helpers
    ##
    def self.template
      @template ||= Clerk::Template.new 
      #We could do `block_given?` here but it might be better to let it error if nothing is provided
      yield @template 
      @template
    end

    def self.parser(parser, *options)
      parser = Clerk::ParserRegistry.lookup(parser.to_sym) if [Symbol, String].any? { |t| parser.kind_of? t }
      #TODO Should we enforce Clerk::Parser subclassing here?
      @parser = parser.new(options)
    end

    def self.parser
      @parser
    end
  end
end
