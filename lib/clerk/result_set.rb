module Clerk
  class ResultSet
    include ActiveModel::Validations

    def initialize(data)
      @data = data.freeze
    end

    def get(attribute)
      @data[attribute]
    end

    def set(attribute, value)
      @data[attribute] = value
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

    alias_method :read_attribute_for_validation, :get
  end
end
