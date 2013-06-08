module Clerk
  # Public: Template DSL for creating structure templates which define
  # how lines of input data are restructured by Clerk
  #
  # Examples:
  # 
  #   template = template.new
  #
  #   template.named :a
  #   template.ignored
  #   template.named :b
  #   template.ignored 3
  #   template.grouped(:c) do |g|
  #     group.named :d
  #     group.ignored
  #     group.named :e
  #   end
  #
  #   template.to_a
  #   # => [:a, nil, :b, nil, nil, nil, :c => [:d, nil, :e]]
  #
  #   data = %w(A I B I I I D1 I E1 D2 I E2)
  #
  #   template.apply data
  #   # =>  {
  #           :a => 'A',
  #           :b => 'B',
  #           :c => [
  #             { :d => 'D1', :e => 'E1' },
  #             { :d => 'D2', :e => 'E2' }
  #           ]
  #         }
  class Template
    def initialize
      @template_elements = []
    end

    # Public: Coercion method returns the Clerk::Template in an Array represntation which
    # is useful for quick iteration over the structure in a simple way.
    #
    # Examples
    #
    #   template.named :a
    #   template.ignored
    #   template.grouped(:b) do |group|
    #     group.named :c
    #     group.named :d
    #   end
    #
    #   template.to_a
    #   # => [:a, nil, {:b => [:c, :d]}]
    #
    # Returns Template as an Array
    def to_a
      @template_elements.map do |element|
        if element.is_a? Clerk::TemplateGroup
          element = element.to_hash
        end
        element
      end
    end

    # Public: Apply the template to the given data
    #
    # data - the data to which the template should be applied as an Array
    #
    # Examples
    #    template.named :a
    #    template.ignored
    #    template.grouped :c do |group|
    #      group.named :d
    #      group.named :e
    #    end
    #
    #    data = ["a", "ignore", "d1", "e1", "d2", "e2"]
    #
    #   template.apply data
    #   # => {
    #          :a => "a",
    #          :c => [
    #            { :d => "d1", :e => "e1" },
    #            { :d => "d2", :e => "e2" }
    #          ]
    #        }
    #
    # Returns data structured into a Hash
    def apply(data)
      @structured_data = {}

      @template_elements.each_with_index do |value,index|
        case value
        when NilClass
          next
        when Symbol, String
          @structured_data[value] = data[index]
        when TemplateGroup
          template = value.template.to_a

          data_group = []

          data[index, data.length].each_slice(template.length) do |slice|
            grouped = {}
            if slice.length < template.length
              slice.fill(nil, slice.length, template.length - 1)
            end
            slice.each_with_index do |element,idx|
              grouped[template[idx]] = element
            end
            unless grouped.all? { |k, v| v.nil? }
              data_group << grouped
            end
          end

          @structured_data[value.name] = data_group
        end
      end

      @structured_data
    end

    # Public: Add a named parameter to the template.
    #
    # The named parameter represents a keyed element within the
    # final data structure. 
    #
    # key - the key value for this named element (String or Symbol)
    # options - Hash of options (default: {}):
    #           :position - The specific position the named parameter should be
    #                       located within the final structure. (optional)
    #
    # Examples:
    #
    #   template = Clerk::Template.new
    #   template.named :message
    #   template.to_a
    #   # => [:message]
    #
    #   template.named :message, {:position => 3}
    #   template.to_a
    #   # => [nil, nil, :message]
    #
    # Returns nothing
    # Raises Clerk::GroupedNotLastError when a group already exists in the
    #   Template and adding a named element is attempted
    # Raises TypeError if the :position option is given but is not an integer
    # Raises IndexError if the :position option is given but is less than 0
    def named(key, options = {})
      raise GroupedNotLastError if has_grouped_element?
      if options.has_key? :position
        raise TypeError, "'#{options[:position]}' is not an integer" unless options[:position].is_a? Integer

        position = options[:position] - 1
        raise IndexError, "Position #{options[:position]} is invalid" if position < 0

        @template_elements[position] = key
      else
        @template_elements << key
      end
    end

    # Public: Ignore the data element in the corresponding position
    #
    # If a specific piece of data within a given data line should be
    # discarded on transformation, the ignored directive should be
    # used to ignore it in the resulting structure.
    #
    # num - Number of columns to ignore (default:  1)
    #
    # Examples:
    #   
    #   template.ignored
    #   template.to_a
    #   # => [nil]
    #
    #   template.ignored 2
    #   template.to_a
    #   # => [nil, nil]
    #
    #   template.named :a
    #   template.ignored 2
    #   template.named :b
    #   template.apply %w(A I I B)
    #   # => { :a => "A", :b => "B" }
    #
    # Returns nothing
    # Raises GroupedNotLastError when a group is added to the template and an
    #   attempt is made to add an igonred element
    # Raises ArgumentError if the number of ignored elements attempted to be
    #   added is less than 1
    def ignored(num = 1)
      raise GroupedNotLastError if has_grouped_element?
      raise ArgumentError if num < 1
      @template_elements.concat(Array.new(num))
    end

    # Public: Helper method to see if a grouped element is in the template
    #
    # This is mainly used to verify that the grouped element is the
    # last one added to the template. This might change in the future
    # but Clerk currently doesn't support grouped elements followed
    # by other elements
    #
    # Returns boolean indicating the Template has or does not have a group
    def has_grouped_element?
      @template_elements.any? { |i| i.kind_of? Clerk::TemplateGroup }
    end

    # Public: Group the next n elements into a named group
    #
    # This template option is used when you have data that should
    # be grouped into chunks. For example, if you have data that
    # represents pairs of information like quantity and price of
    # items you can use the grouped option to collect them into
    # logical groups.
    #
    # name - the name to assign to the group
    #
    # Examples:
    #
    #   template = Clerk::Template.new
    #   template.grouped(:items) do |g|
    #     g.named :price
    #     g.named :quantity
    #   end
    #
    #   template.apply [ "29.99", 10, "19.95", 100 ]
    #
    #   # => { :items => [
    #     { :price => "29.99", :quantity => 10  } ,
    #     { :price => "19.95", :quantity => 100 } ,
    #   ]}
    #
    # Returns nothing
    def grouped(name)
      group = Clerk::TemplateGroup.new name
      yield group
      @template_elements << group
    end
  end

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

    # Public: Coercion from Clerk::TemplateGroup to Hash
    #
    # Examples:
    #
    #   template.grouped(:a) do |group|
    #     group.named :b
    #     group.named :c
    #   end
    #
    #   # => {:a => [:b, :c]}
    #
    # Returns TemplateGroup as Hash
    def to_hash
      { @name => @template.to_a }
    end

    # Internal: Delegate method calls to Clerk::Template
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
