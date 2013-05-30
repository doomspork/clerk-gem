require 'pry'
module Clerk
  class ResultSet
    include ActiveModel::Validations

    attr_accessor :data

    def initialize(data)
      @data = data.dup
    end

    def get(attribute)
      parts = attribute.to_s.split('/')
      parts.inject(@data) do |memo, value| 
        if memo.key? value.to_sym
          memo[value.to_sym]
        elsif memo.key? value
          memo[value] 
        end
      end
    end

    def set(attribute, value)
      parts = attribute.to_s.split('/')
      lastkey = parts.pop
      hash = parts.inject(@data) do |memo, value| 
        memo[value.to_sym] 
      end
      hash[lastkey.to_sym] = value
    end

    def self.name
      self.class.to_s
    end

    def self.copy_validations_from(klass)
      klass.validators.each do |validator|
        validates_with validator.class, validator.options.merge({:attributes => validator.attributes})
      end
    end

    alias_method :read_attribute_for_validation, :get
  end
end
