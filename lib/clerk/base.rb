module Clerk
  class Base
    include ActiveModel::Validations

    def initialize
      @transformed_values = Array.new
    end

    def load(data)
      @raw_values = data.freeze
    end

    def results
      Enumerator.new do |yielder|
        @transformed_values.each do |value|
          yielder << value
        end
      end
    end

    def errors
      @template.errors || []
    end

    def self.apply_template(data)
      @raw_values.each_with_index do |value, index|
        @transformed_values[index] ||= @template.apply(value)
      end
    end

    def self.template
      @template ||= Clerk::Template.new 
      #We could do `block_given?` here but it might be better to let it error if nothing is provided
      yield @template 
      @template
    end

  end
end
