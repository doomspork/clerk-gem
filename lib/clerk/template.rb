module Clerk
  ##
  # Template DSL for creating transformation templates which define
  # how lines of data are transformed into a structure by Clerk
  class Template
    attr_accessor :template_array

    def initialize
      @template_array = []
    end

    ##
    # Add a named parameter to the template.
    #
    # The named parameter represents a keyed element within the
    # final data structure. For example, suppose there is a line
    # of data containing a single element, hello, and you want to 
    # transform that line to be a hash with the first key being
    # :message, you can use the named parameter as follows:
    #
    #   template = Clerk::Template.new
    #   template.named :message
    #
    # The resulting template will assign the first position to the
    # key :message in the resulting transformed hash.
    def named(key, options = {})
      if options.has_key? :position
        raise TypeError, "'#{options[:position]}' is not an integer" unless options[:position].is_a? Integer

        position = options[:position] - 1
        raise IndexError, "Position #{options[:position]} is invalid" if position < 0

        @template_array[position] = key
      else
        @template_array << key
      end
    end

    ##
    # Ignore the data element in the corresponding position
    #
    # If a specific piece of data within a given data line should be
    # discarded on transformation, the ignored directive should be
    # used to ignore it in the resulting structure.
    def ignored
      @template_array << nil
    end

    ##
    # Group the next n elements into a named group
    #
    # This template option is used when you have data that should
    # be grouped into chunks. For example, if you have data that
    # represents pairs of information like quantity and price of
    # items you can use the grouped option to collect them into
    # logical groups.
    #
    # Suppose the data looks as follows.
    #
    #   [ "29.99", 10, "19.95", 100 ]
    #
    # Using the following template will result in the hash that
    # follows the template.
    #
    #   template = Clerk::Template.new
    #   template.grouped :items, [ :price, :quantity ]
    #
    #   { :items => [
    #     { :price => "29.99", :quantity => 10  } ,
    #     { :price => "19.95", :quantity => 100 } ,
    #   ]}
    def grouped(name, groups)
      @template_array << { name => groups }
    end
  end
end
