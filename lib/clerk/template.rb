module Clerk
  ##
  # Template DSL for creating structure templates which define
  # how lines of input data are restructured by Clerk
  class Template
    def initialize
      @template_array = []
    end

    ##
    # Coercion method turn Clerk::Template into Array
    #
    # This method returns the Clerk::Template in an Array represntation which
    # is useful for quick iteration over the structure in a simple way.
    #
    # Example, suppose you have defined a template in your Clerk instance which
    # has a named element, and ignored element, and a set of grouped elements.
    #
    #   template.named :a
    #   template.ignored
    #   template.grouped(:b) do |group|
    #     group.named :c
    #     group.named :d
    #   end
    #
    # Calling the Template.to_a method will return the template represented
    # as the following array.
    #
    #   [:a, nil, {:b => [:c, :d]}]
    #
    # * *Returns* :
    #   - template as an Array
    def to_a
      @template_array.map do |element|
        if element.is_a? Clerk::TemplateGroup
          element = element.to_hash
        end
        element
      end
    end

    ##
    # Apply the template to the given data
    #
    # This method will take in an array of values and return a Hash representing
    # that data structured according to the template. For example, suppose you have
    # the following data and template defined.
    #
    #    template.named :a
    #    template.ignored
    #    template.grouped :c do |group|
    #      group.named :d
    #      group.named :e
    #    end
    #
    #    data = ["a", "ignore", "d1", "e1", "d2", "e2"]
    #
    # The call to Template.apply would produce the following hash.
    #
    #   {
    #     :a => "a",
    #     :c => [
    #       { :d => "d1", :e => "e1" },
    #       { :d => "d2", :e => "e2" }
    #     ]
    #   }
    #
    # * *Args* :
    #   - +data+ -> the data upon which the template should be applied
    # * *Returns* :
    #   - data structured into a Hash
    def apply(data)
      @structured_data = Hash.new

      @template_array.each_with_index do |value,index|
        case value
        when NilClass
          next
        when Symbol, String
          @structured_data[value] = data[index]
        when TemplateGroup
          template = value.template.to_a

          data_group = Array.new

          data[index, data.length].each_slice(template.length) do |slice|
            grouped = Hash.new
            if slice.length < template.length
              slice.fill(nil, slice.length, template.length - 1)
            end
            slice.each_with_index do |element,idx|
              grouped[template[idx]] = element
            end

            data_group << grouped
          end

          @structured_data[value.name] = data_group
        end
      end

      @structured_data
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
    #
    # * *Args* :
    #   - +key+ -> the key value for this named element (String or Symbol)
    #   - +options+ -> hash of options, ex., {:position => 3}
    # * *Returns* :
    #   - current template array
    # * *Raises* :
    #   - +Clerk::GroupedNotLastError+ -> if there is a grouped element in the template
    #   - +TypeError+ -> if the position option is not an integer or is less than 1
    def named(key, options = {})
      raise GroupedNotLastError if has_grouped_element?
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
    #
    # * *Returns* :
    #   - current template array
    # * *Raises* :
    #   - +Clerk::GroupedNotLastError+ -> if there is a grouped element in the template
    def ignored
      raise GroupedNotLastError if has_grouped_element?
      @template_array << nil
    end

    ##
    # Helper method to see if a grouped element is in the template
    #
    # This is mainly used to verify that the grouped element is the
    # last one added to the template. This might change in the future
    # but Clerk currently doesn't support grouped elements followed
    # by other elements
    def has_grouped_element?
      @template_array.any? { |i| i.kind_of? Clerk::TemplateGroup }
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
    #   template.grouped(:items) do |g|
    #     g.named :price
    #     g.named :quantity
    #   end
    #
    #   { :items => [
    #     { :price => "29.99", :quantity => 10  } ,
    #     { :price => "19.95", :quantity => 100 } ,
    #   ]}
    #
    # * *Args* :
    #   - +name+ -> the name to assign to the group, ex., +:logins+
    # * *Returns* :
    #   - current template array
    def grouped(name)
      group = Clerk::TemplateGroup.new name
      yield group
      @template_array << group
    end
  end

  ##
  # TemplateGroup defines grouped DSL
  #
  # Inside a template, to define a set of grouped elements, a
  # conveninence DSL is provided through the Template.grouped
  # method. Clerk::TemplateGroup exposes that DSL API.
  class TemplateGroup
    attr_accessor :name, :template

    def initialize(name, template = nil)
      @name = name
      @template = template || Clerk::Template.new
    end

    ##
    # Coercion from Clerk::TemplateGroup to Hash
    #
    # For example, given a grouped set of elements defined by the
    # Template DSL:
    #
    #   template.grouped(:a) do |group|
    #     group.named :b
    #     group.named :c
    #   end
    #
    # When the TemplateGroup.to_hash method is called, the resulting
    # data structure will be:
    #
    #   {:a => [:b, :c]}
    #
    # * *Returns* :
    #   - TemplateGroup as Hash
    def to_hash
      { @name => @template.to_a }
    end

    ##
    # Delegate method calls to Clerk::Template
    #
    # Since the DSL for grouped elements is effectively just a wrapper
    # on top of Clerk::Template, calls to allowed methods are simply
    # delegate to an internal instance of Clerk::Template.
    def method_missing(method, *args, &block)
      raise NoMethodError if method === :grouped

      if @template.respond_to?(method)
        @template.send(method, *args, &block)
      else
        raise NoMethodError
      end
    end

  end

  class GroupedNotLastError < Exception; end
end
