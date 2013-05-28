require 'test/unit'
require 'clerk/base'

class TestValidation < Test::Unit::TestCase
  def test_validation_of_template_named_value
    klass = Class.new(Clerk::Base) 
    klass.template do |t| 
      t.named :a 
      t.named :b
    end
  
    klass.validates_presence_of :a

    clerk = klass.new
    clerk.load([{:a => "A!", :b => "B!"}])
    assert clerk.valid?

    clerk.load([{:a => "", :b => "B!"}])
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
    clerk.load([{:a => "A!", :group_name => [{:ga => "A!", :gb => "B!"}]}])
    assert clerk.valid?

    clerk.load([{:a => "A!", :group_name => [{:ga => "", :gb => "B!"}]}])
    assert clerk.invalid?
  end

end
