require 'test_helper'

class ClerkTemplateTest < Test::Unit::TestCase
  def setup
    @template = Clerk::Template.new
  end

  def teardown
    @template = nil
  end

  def test_named_param_added_to_template
    @template.named :param
    assert_equal [:param], @template.to_a
  end

  def test_named_with_position
    @template.named :a, :position => 2
    assert_equal [nil, :a], @template.to_a
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
    assert_equal [nil, :b, :c], @template.to_a

    @template.named :a, :position => 1
    assert_equal [:a, :b, :c], @template.to_a
  end

  def test_named_with_position_expands_existing
    @template.named :a
    @template.named :b, :position => 3
    assert_equal [:a, nil, :b], @template.to_a
  end

  def test_named_accepts_string_or_symbol
    @template.named :a
    @template.named 'date'
    @template.named 'user', :position => 4
    assert_equal [:a, 'date', nil, 'user'], @template.to_a
  end

  def test_ignored_adds_nil_to_template
    @template.ignored
    assert_equal [nil], @template.to_a
  end

  def test_ignore_multiple_columns
    @template.ignored 3
    assert_equal [nil, nil, nil], @template.to_a
  end

  def test_ignore_requires_num_greater_than_zero
    assert_raise ArgumentError do
      @template.ignored 0
    end
  end

  def test_grouped_creates_template_group
    @template.grouped(:group_name) do |group|
      group.named :a
      group.named :b
    end

    expected = {
      :group_name => [:a, :b]
    }
    assert_equal [expected], @template.to_a
  end

  def test_multiple_templated_parameters
    @template.named :a
    @template.ignored
    @template.named :b
    @template.grouped :c do |group|
      group.named :d
      group.named :e
    end

    expected = [
      :a,
      nil,
      :b,
      { :c => [ :d, :e ] },
    ]

    assert_equal expected, @template.to_a
  end

  def test_apply_handles_named_params
    @template.named :a
    @template.named 'b'
    expected = {
      :a => "vala",
      'b' => "valb"
    }

    assert_equal expected, @template.apply(["vala", "valb"])
  end

  def test_apply_handles_ignored_params
    @template.named :a
    @template.ignored
    @template.named 'b'

    expected = {
      :a => "valuea",
      'b' => "valueb"
    }

    assert_equal expected, @template.apply(["valuea", "valueignored", "valueb"])
  end

  def test_apply_handles_grouped_params
    @template.grouped :a do |group|
      group.named :b
      group.named 'c'
    end

    expected = {
      :a => [
        { :b => "b1", 'c' => "c1" },
        { :b => "b2", 'c' => "c2" }
    ]
    }

    assert_equal expected, @template.apply(["b1","c1","b2","c2"])
  end

  def test_apply_fills_groups_with_null_when_data_length_does_not_match
    @template.grouped :a do |group|
      group.named :b
      group.named :c
    end

    expected = {
      :a => [
        { :b => "b1", :c => "c1" },
        { :b => "b2", :c => "c2" },
        { :b => "b3", :c => nil  }
    ]
    }

    data = [ "b1", "c1", "b2", "c2", "b3"]

    assert_equal expected, @template.apply(data)
  end

  def test_to_a_coerces_template_to_array
    @template.named :a
    @template.ignored
    @template.grouped(:b) do |group|
      group.named :c
      group.named :d
    end

    expected = [:a, nil, {:b => [:c, :d]}]

    assert_equal expected, @template.to_a
  end

  def test_group_not_allowed_to_have_grouped_elements
    assert_raise NoMethodError do
      @template.grouped(:a) do |group|
        group.named :b
        group.grouped(:c) do |groupception|
          groupception.named :d
          groupception.named :e
        end
      end
    end
  end

  def test_calling_invalid_method_on_group_raises_error
    assert_raise NoMethodError do
      @template.grouped(:a) do |group|
        group.method_does_not_exist
      end
    end
  end
end
