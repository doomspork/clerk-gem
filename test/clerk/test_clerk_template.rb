require 'test/unit'
require 'clerk/template'

class ClerkTemplateTest < Test::Unit::TestCase
  def setup
    @template = Clerk::Template.new
  end

  def teardown
    @template = nil
  end

  def test_named_param_added_to_template
    @template.named :param
    assert_equal [:param], @template.template_array
  end

  def test_named_with_position
    @template.named :a, :position => 2
    assert_equal [nil, :a], @template.template_array
  end

  def test_named_position_raises_exception_if_not_integer
    assert_raise TypeError do     
      @template.named :a, :position => "Not an integer"
      "TypeError not raised when position was not integer"
    end
  end

  def test_named_position_raises_indexerror_for_position_zero
    assert_raise IndexError do
      @template.named :a, :position => 0
      "IndexError not raised when position is zero"
    end
  end

  def test_named_with_position_overwrites_existing
    @template.named :b, :position => 2
    @template.named :c
    assert_equal [nil, :b, :c], @template.template_array

    @template.named :a, :position => 1
    assert_equal [:a, :b, :c], @template.template_array
  end

  def test_named_with_position_expands_existing
    @template.named :a
    @template.named :b, :position => 3
    assert_equal [:a, nil, :b], @template.template_array
  end

  def test_ignored_adds_nil_to_template
    @template.ignored
    assert_equal [nil], @template.template_array
  end

  def test_grouped_adds_group_hash_to_template
    @template.grouped :group_name, [ :a, :b ]  
    expected = {
      :group_name => [:a, :b]
    }
    assert_equal [expected], @template.template_array
  end

  def test_multiple_templated_parameters
    @template.named :a
    @template.ignored
    @template.named :b
    @template.grouped :c, [ :d, :e ]

    expected = [
      :a,
      nil,
      :b,
      { :c => [ :d, :e ] },
    ]

    assert_equal expected, @template.template_array
  end

  # TODO implement
  def test_grouped_must_be_at_the_end_of_the_template
    
  end
end
