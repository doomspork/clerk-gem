module Clerk
  class ResultSet
    include ActiveModel::Validations

    attr_accessor :data

    def initialize(data)
      @data = data.freeze
    end

    def read_attribute_for_validation(attribute)
      parts = attribute.to_s.split('/')
      parts.inject(@data) do |memo, value| 
        memo[value] || memo[value.to_sym]  
      end
    end

    def self.name
      self.class.to_s
    end

    def self.copy_validations_from(klass)
      dup = klass.validators.dup
      dup.each do |validator|
        validates_with validator.class, validator.options.dup.merge({:attributes => validator.attributes.dup})
      end
    end
  end

  class Base
    include ActiveModel::Validations

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
      data.freeze 
      raw_data = data
      raw_data = [data] unless data[0].kind_of? Array
      raw_data.each do |d| 
        templated_data = self.class.apply_template(d)
        sets = self.class.result_sets(templated_data)
        @transformed_values.push self.class.apply_transformations(sets)
      end
      self
    end

    def results
      results = Array.new

      if self.class.template.has_grouped_element?
        results.concat embiggen_grouped_results @transformed_values
      else
        @transformed_values.each do |resultset|
          results.concat resultset.map { |s| s.data }
        end
      end

      results
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
      template.apply(data)
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
            group = Hash[key, value]
            sets.push _result_set_klass.new(data.merge(group))
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

    def embiggen_grouped_results(values)
      embiggened_results = Array.new

      values.each do |resultset|
        container = Hash.new
        resultset.each do |set|
          container.merge!(set.data) do |key, old, nue|
            if old.kind_of? Hash
              [old, nue]
            elsif old.kind_of? Array
              old.push nue
            else
              nue
            end 
          end
        end
        embiggened_results.push container
      end

      embiggened_results
    end

  end
end
