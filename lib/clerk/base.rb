module Clerk
  class Base
    include ActiveModel::Validations

    class << self
      attr_accessor :template, :parser
    end

    def self.template
      @template = Clerk::Template.new 
      #We could do `block_given?` here but it might be better to let it error if nothing is provided
      yield @template 
    end

    def self.parser(parser, *options)
      parser = Clerk::Parser.lookup(parser.to_sym) if [Symbol, String].any? { |t| parser.kind_of? t }
      #TODO Should we enforce Clerk::Parser subclassing here?
      @parser = parser.new(options)
    end
  end
end
