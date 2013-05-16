module Clerk
  class AbstractParser
    include Enumerable
    include ActiveModel::Validations
    include ActiveModel::Callbacks

    def initialize(params = {})
      params.each do |attr, value|
        self.public_send("#{attr}=", value) 
      end
    end

    def each(&block)
      raise NotImplementedError, "Subclasses must implement a each(&block) method"
    end
  end
end

Dir[File.dirname(__FILE__) + "/parsers/*.rb"].each { |file| require file }
