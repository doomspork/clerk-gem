require 'test_helper'

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

  def test_transformation_of_grouped_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a 
      t.grouped(:b) do |group|
        group.named :c
      end
    end

    klass.transforms :'b/c' do |value|
      value.upcase
    end

    clerk = klass.new
    clerk.load %w(a c)

    expected = {
      :a => 'a',
      :b => [
        {:c => 'C'}
      ]
    }

    assert_equal expected, clerk.results.first
  end

  def test_transformation_of_group_with_no_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a 
      t.grouped(:b) do |group|
        group.named :c
      end
    end

    klass.transforms :'b/c' do |value|
      value.upcase
    end

    clerk = klass.new
    clerk.load %w(a) 

    expected = {
      :a => 'a',
      :b => []
    }

    assert_equal expected, clerk.results.first

  end
end
