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
      def transform_with(klass, *fields)
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
end
