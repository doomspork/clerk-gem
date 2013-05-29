module Clerk
  module Transformations
    def transform(record)
      self.class.transformations.each do |field, transformers|
        orig_value = record.get(field)
        transformed_value = transformers.inject(orig_value) do |memo, transformer|
          transformer.transform(memo)
        end
        record.set(field, transformed_value)
      end
      record 
    end

    module ClassMethods
      def transforms(*fields, &block)
        klz = Class.new(BlockTransformer)
        klz.block(&block)
        transforms_with klz, *fields
      end

      def transforms_with(klass, *fields)
        #TODO check klass for .transform method!
        fields.each do |field|
          transformations[field].push(klass)
        end
      end

      def clear_transformations!
        self.transformations.clear
      end

      def transformations
        @transformations ||= Hash.new { |hash, key| hash[key] = Array.new }
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end

  class BlockTransformer
    def self.block(&block)
      @block = block
    end

    def self.transform(value)
      @block.call(value)
    end
  end
end
