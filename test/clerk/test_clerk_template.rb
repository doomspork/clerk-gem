require 'test/unit'
require 'clerk/template'

class ClerkTemplateTest < Test::Unit::TestCase
  def test_named_param_added_to_template
    t = Clerk::Template.new
    t.named :param
    assert_equal [:param], t.arr
  end

  def test_ignored_adds_nil_to_template
    t = Clerk::Template.new
    t.ignored
    assert_equal [nil], t.arr
  end

  def test_grouped_adds_group_hash_to_template
    t = Clerk::Template.new
    t.grouped :group_name, [ :a, :b ]  
    expected = {
      :group_name => [:a, :b]
    }
    assert_equal [expected], t.arr
  end

  def test_multiple_templated_parameters
    t = Clerk::Template.new

    t.named :a
    t.ignored
    t.named :b
    t.grouped :c, [ :d, :e ]

    expected = [
      :a,
      nil,
      :b,
      { :c => [ :d, :e ] },
    ]

    assert_equal expected, t.arr
  end

  # TODO implement
  def test_grouped_must_be_at_the_end_of_the_template
    
  end
end
