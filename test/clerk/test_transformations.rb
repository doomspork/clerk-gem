require 'test/unit'
require 'clerk/base'

class TestClerk < Clerk::Base
  template do |t| 
    t.named :a 
    t.named :b
  end
end

class TestTransformation < Test::Unit::TestCase
  def test_transformation_of_template_named_value

  end
end
