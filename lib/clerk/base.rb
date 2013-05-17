module Clerk
  class Base
    include ActiveModel::Validations
    include ActiveModel::Callbacks

    def template
      #TODO Create template instance here
      t = nil
      #We could do `block_given?` here but it might be better to let it error if nothing is provided
      yield t 
    end

    def parser(parser, *options)
      parser = Clerk::Parser.lookup(parser.to_sym) if [Symbol, String].any? { |t| parser.kind_of? t }
      #TODO Should we enforce Clerk::Parser subclassing here?
      @parser = parser.new(options)
    end
  end
end
