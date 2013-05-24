module Clerk
  class Base
    include ActiveModel::Validations
    include Clerk::Transformations

    class << self
      attr_accessor :_result_set_klass
    end

    def initialize
      clear_transformed_data!
      result_klass = Class.new(Clerk::ResultSet)
      result_klass.copy_validations_from(self.class)
      self.class._result_set_klass = result_klass
    end

    def load(data)
      clear_transformed_data!
      raw_values = data.freeze
      @transformed_values = raw_values.map do |record|
        templated_data = self.class.apply_template(record) 
        transformed_data = self.class.apply_transformations(templated_data)
        self.class.result_sets(transformed_data)
      end
      self
    end

    def valid?(*args)
      @transformed_values.all? do |sets| 
        sets.all? { |set| set.valid? } 
      end
    end

    def errors
      error_messages = Hash.new
      @transformed_values.each_with_index do |sets, index|
        messages = sets.map { |set| set.errors.full_messages }.flatten.uniq
        error_messages[index + 1] = messages unless messages.empty?
      end
      error_messages
    end

    def self.apply_template(data)
      data
    end

    def self.apply_transformations(data)
      data
    end

    def self.template
      @template ||= Clerk::Template.new 
      yield @template if block_given?
      @template
    end

    private

    def self.result_sets(record)
      data = record.dup
      sets = Array.new
      if template.has_grouped_element?
        grouped_data = data.select { |key, value| value.kind_of? Array }
        grouped_data.keys.each { |key| data.delete(key) }
        grouped_data.each do |key, values|
          values.each do |value|
            sets.push _result_set_klass.new(data.merge(value))
          end
        end
      else
        sets.push _result_set_klass.new(data)
      end
      sets
    end

    def clear_transformed_data!
      @transformed_values = Array.new
    end

  end
end
