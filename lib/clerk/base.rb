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

    ##
    # Pass data off to your Clerk for processing
    #
    # This is the main method for giving data to Clerk which will then
    # be transformed into the structure specified by the Template and
    # according to any transformations specified for individual data
    # elements/columns.
    #
    # * *Args* :
    #   - +data+ -> Data which Clerk should act upon
    # * *Returns* :
    #   - self
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

    ##
    # Retrieves the transformed data from the Clerk
    #
    # Use this method to retrieve the final transformed data from the
    # Clerk. This method should be called after you have verified the
    # data passes validation described in your clerk using the `valid?`
    # method.
    #
    # * *Returns* :
    #   - Array containing each row of data in the described structure
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

    ##
    # Checks data against described Validators
    #
    # * *Returns* :
    #   - Boolean true or false
    def valid?(*args)
      @transformed_values.all? do |sets| 
        sets.all? { |set| set.valid? } 
      end
    end

    ##
    # Used to retrieve validation error messages
    #
    # * *Returns* :
    #   - Hash of error messages
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
          if values.empty?
            sets.push self.class._result_set_klass.new(data.merge(Hash[key, {}]))
          else
            values.each do |value|
              group = Hash[key, value]
              sets.push self.class._result_set_klass.new(data.merge(group))
            end
          end
        end
      else
        sets.push self.class._result_set_klass.new(data)
      end
      sets
    end

    def clear_transformed_data!
      @transformed_values = []
    end

    def embiggen_grouped_results(values)
      embiggened_results = []
      values.each do |resultset|
        container = {} 
        resultset.each do |set|
          data = {}
          set.data.each do |key, value|
            if value.kind_of? Hash
              if value.empty?
                value = []
              else 
                value = [value] if value.kind_of? Hash
              end
            end
            data[key] = value
          end
          container.merge!(data) do |key, old, nue|
            if old.kind_of? Array
              old.push nue.first
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
