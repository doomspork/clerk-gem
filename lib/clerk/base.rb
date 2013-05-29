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
      data = [data] unless data[0].kind_of? Array
      data.each do |data| 
        templated_data = apply_template(data)
        sets = result_sets(templated_data)
        sets.map! do |set|
          transform(set)
        end
        @transformed_values.push sets
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

    def apply_template(data)
      self.class.template.apply(data)
    end

    def self.template
      @template ||= Clerk::Template.new 
      yield @template if block_given?
      @template
    end

    private
    def result_sets(record)
      data = record.dup
      sets = Array.new
      if self.class.template.has_grouped_element?
        grouped_data = data.select { |key, value| value.kind_of? Array }
        grouped_data.keys.each { |key| data.delete(key) }
        grouped_data.each do |key, values|
          values.each do |value|
            group = Hash[key, value]
            sets.push self.class._result_set_klass.new(data.merge(group))
          end
        end
      else
        sets.push self.class._result_set_klass.new(data)
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
