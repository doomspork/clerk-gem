module Clerk
  module Transformations

    def transform(record)
      dup = record.dup
      self.class.transformations.each do |field, transformers|
        orig_value = record.get(field)
        transformed_value = transformers.inject(orig_value) do |memo, transformer|
          transformer.tranform(memo)
        end
        record.set(field, transformed_value)
      end
    end

    module ClassMethods
      def transforms(*fields, &block)
        klz = Class.new(BlockTransformer)
        klz.block = block
        transforms_with klz, fields
      end

      def transforms_with(klass, *fields)
        fields.each do |field|
          self.transformations[field].push(klass)
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
    def self.block=(&block)
      @block = block
    end

    def self.transform(value)
      @block.call(value)
    end
  end
end
