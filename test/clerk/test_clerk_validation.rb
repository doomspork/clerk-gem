require 'test/unit'
require 'clerk/base'

class ClerkValidationTest < Test::Unit::TestCase
  def test_validation_of_template_named_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a 
      t.named :b
    end
  
    klass.validates_presence_of :a

    clerk = klass.new
    clerk.load([["A!","B!"]])
    assert clerk.valid?

    clerk.load([["","B!"]])
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
  
    klass.validates_presence_of :ga

    clerk = klass.new
    clerk.load([["A!", "A!","B!"]])
    assert clerk.valid?

    clerk.load([["A!","","B!"]])
    assert clerk.invalid?
  end

end
