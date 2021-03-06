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

    # Public: Pass data off to your Clerk for processing
    #
    # This is the main method for giving data to Clerk which will then
    # be transformed into the structure specified by the Template and
    # according to any transformations specified for individual data
    # elements/columns.
    #
    # data - data which Clerk should act upon
    #
    # Examples:
    #
    #   my_clerk = ClerkImplementation.new
    #   my_clerk.load %(A B C D)
    #
    # Returns nothing
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

    # Public: Retrieves the transformed data from the Clerk
    #
    # Use this method to retrieve the final transformed data from the
    # Clerk. This method should be called after you have verified the
    # data passes validation described in your clerk using the `valid?`
    # method.
    #
    # Examples:
    # 
    #   my_clerk = ClerkImplementation.new
    #   my_clerk.load %(A B C D)
    #   my_clerk.results
    #   # => [{:a => "A", :b => "B", :c => "C", :d => "D"}]
    #
    # Returns Array containing each row of data in the described structure
    def results
      results = []

      if self.class.template.has_grouped_element?
        results.concat embiggen_grouped_results @transformed_values
      else
        @transformed_values.each do |resultset|
          results.concat resultset.map { |s| s.data }
        end
      end

      results
    end

    # Public: Checks data against described Validators
    #
    # Returns Boolean representing valid (true) or invalid (false)
    def valid?(*args)
      valid = true
      @transformed_values.each do |sets| 
        sets.each do |set| 
          valid = false unless set.valid?
        end
      end
      valid
    end

    # Public: Retrieve validation error messages
    #
    # Returns Hash of error messages
    def errors
      error_messages = {}
      @transformed_values.each_with_index do |sets, index|
        messages = sets.map { |set| set.errors.full_messages }.flatten.uniq
        error_messages[index + 1] = messages unless messages.empty?
      end
      error_messages
    end

    # Internal: Apply the template to the loaded data
    def apply_template(data)
      self.class.template.apply(data)
    end

    # Public: Define the Template with a Block
    #
    # Examples:
    #
    #   my_clerk.template do |t|
    #     t.named :a
    #     t.ignored
    #   end
    #
    # Returns Template
    def self.template
      @template ||= Clerk::Template.new 
      yield @template if block_given?
      @template
    end

    private
    def result_sets(record)
      data = record.dup
      sets = []
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

    # Internal: Clears the internal transformed data storage
    #
    # Returns nothing
    def clear_transformed_data!
      @transformed_values = []
    end

    # Internal: Converts internal, flattened data structure back into the
    # expected structure for return
    #
    # Returns Array of Hashes
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
