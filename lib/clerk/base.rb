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
        results.concat hydrate_grouped_results @transformed_values
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

    private
    def clear_transformed_data!
      @transformed_values = Array.new
    end

    private
    def hydrate_grouped_results(values)
      hydrated_results = Array.new

      template_as_array = self.class.template.to_a 
      group_hash = template_as_array.select { |x| x.kind_of? Hash }.shift
      
      group_name = group_hash.keys.first 
      group_keys = group_hash[group_name]

      values.each do |resultset|
        first_group = resultset[0].data.dup
        container = first_group.reject { |key,value| group_keys.include? key }

        container[group_name] = Array.new
        resultset.each do |set|
          raw_data = set.data.dup
          data = raw_data.keep_if { |key,value| group_keys.include? key }
          container[group_name].push data
        end
        hydrated_results.push container
      end

      hydrated_results
    end

  end
end
