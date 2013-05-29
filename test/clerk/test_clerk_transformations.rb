require 'test/unit'
require 'clerk/base'

class ClerkTransformationsTest < Test::Unit::TestCase
  def test_transformation_of_named_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a 
      t.named :b
    end

    klass.transforms :a do |value|
      value.upcase
    end

    clerk = klass.new
    clerk.load %w(a b)

    expected = {
      :a => 'A',
      :b => 'b'
    }

    assert_equal expected, clerk.results.first
  end
end
