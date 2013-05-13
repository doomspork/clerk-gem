require 'test/unit'
require 'clerk'

class ClerkTest < Test::Unit::TestCase
  def test_template_required_to_process_data
    c = Clerk.new
    assert_raise RuntimeError do
      c.process %w(test data)
    end

    assert_raise RuntimeError do
      c.organize %w(test data)
    end
  end

  def test_elements_matched_with_named_template_position 
    template = [:a]
    csv = %w(test)
    res = {:a => 'test'} 
    assert_transformation template, csv, res
  end

  def test_element_ignored_when_corresponding_nil_in_template
    template = [:a, nil, :b]
    csv = %w(test ignore not)
    res = {:a => 'test', :b => 'not'} 
    assert_transformation template, csv, res
  end

  def test_elements_grouped_per_template
    template = [{:group => [:a, :b]}]
    csv = %w(a b c d e f)
    res = {:group => [
      {:a => 'a', :b => 'b'},
      {:a => 'c', :b => 'd'},
      {:a => 'e', :b => 'f'}]}
    assert_transformation template, csv, res
  end

  def test_grouping_uneven_number_of_elements_fils_with_nil
    template = [{:group => [:a, :b, :c]}]
    csv = %w(a b c d e f g)
    res = {:group => [
      {:a => 'a', :b => 'b', :c => 'c'},
      {:a => 'd', :b => 'e', :c => 'f'},
      {:a => 'g', :b => nil, :c => nil}]}
    assert_transformation template, csv, res
  end

  def test_all
    template = [:named, nil, {:group => [:a, :b]}]
    csv = %w(word ignore a b c d e f)
    res = {:named => 'word',
           :group => [
             {:a => 'a', :b => 'b'},
             {:a => 'c', :b => 'd'},
             {:a => 'e', :b => 'f'}]}
    assert_transformation template, csv, res
  end

  def test_string_input_parsed_as_csv_input
    template = [:a, nil, :b]
    csv = 'test,ignored,value'
    res = {:a => 'test', :b => 'value'}
    assert_transformation template, csv, res
  end

  def assert_transformation(template, values, result)
    c = Clerk.new template
    assert_equal c.organize(values), result
  end
end
