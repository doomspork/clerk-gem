require 'test_helper'

class ClerkValidationTest < Test::Unit::TestCase
  def test_validation_of_template_named_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a 
      t.named :b
    end

    klass.validates_presence_of :a

    clerk = klass.new
    clerk.load %w(A B)
    assert clerk.valid?

    clerk.load %W(#{} B)
    assert clerk.invalid?
  end

  def test_validation_of_template_group_named_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a
      t.grouped :group_name do |group|
        group.named :ga
        group.named :gb
      end
    end

    klass.validates_presence_of :'group_name/ga'

    clerk = klass.new
    clerk.load %w(A GA GB)
    assert clerk.valid?

    clerk.load %W(A #{} GB)
    assert clerk.invalid?
  end

  def test_block_validator
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named 'a'
      t.grouped :group_name do |group|
        group.named 'ga'
        group.named :gb
      end
    end

    klass.validates_each :'group_name/gb' do |record, attr, value|
      record.errors.add(attr, 'Value cannot be nil') if value.empty?
    end

    clerk = klass.new
    clerk.load %w(A GA GB)
    assert clerk.valid?

    clerk.load %W(A GA #{})
    assert clerk.invalid?
  end

  def test_validation_of_template_string_key_support
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named 'a'
      t.grouped :group_name do |group|
        group.named 'ga'
        group.named :gb
      end
    end

    klass.validates_presence_of 'a'
    klass.validates_presence_of :'group_name/ga'

    clerk = klass.new
    clerk.load %w(A GA GB)
    assert clerk.valid?

    clerk.load %W(A #{} GB)
    assert clerk.invalid?
  end

  def test_validation_of_multiple_errors_in_a_set
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named 'a'
      t.grouped :group_name do |group|
        group.named 'ga'
        group.named :gb
      end
    end

    klass.validates_presence_of 'a'
    klass.validates_presence_of :'group_name/ga'

    clerk = klass.new
    clerk.load [%W(A #{} GB), %W(#{} GA GB)]
    assert clerk.invalid?
    assert_equal 2, clerk.errors.size 
  end

end
