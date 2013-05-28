require 'test/unit'
require 'clerk'

class ClerkTest < Test::Unit::TestCase
  def test_clerk_structures_grouped_data
    klass = Class.new(Clerk::Base)
    klass.template do |t|
      t.named :store_id
      t.ignored
      t.named :location
      t.grouped(:products) do |g|
        g.named :product
        g.named :price
      end
    end

    clerk = klass.new

    data = [
      ["1", "Store Name", "TX", "Product A", "$12.99", "Product B", "$19.99", "Product C", "$29.99"],
      ["2", "Store Name", "CA", "Product A", "$14.99", "Product B", "$22.99", "Product C", "$35.99"],
    ]

    clerk.load data
    assert clerk.valid?

    expected = [
      {
        :store_id => "1",
        :location => "TX",
        :products => [
          { :product => "Product A", :price => "$12.99" },
          { :product => "Product B", :price => "$19.99" },
          { :product => "Product C", :price => "$29.99" }
        ]
      },
      {
        :store_id => "2",
        :location => "CA",
        :products => [
          { :product => "Product A", :price => "$14.99" },
          { :product => "Product B", :price => "$22.99" },
          { :product => "Product C", :price => "$35.99" }
        ]
      },
    ]
    assert_equal expected, clerk.results
  end

  def test_clerk_structures_ungrouped_data
    klass = Class.new(Clerk::Base)
    klass.template do |t|
      t.named :a
      t.ignored
      t.named :b
    end

    clerk = klass.new
    clerk.load(["A!", "I", "B!"]);

    assert_equal [{:a => 'A!', :b => 'B!'}], clerk.results
  end

  def test_clerk_does_not_overwrite_keys_with_same_name
    klass = Class.new Clerk::Base
    klass.template do |t|
      t.named :a
      t.grouped(:z) do |g|
        g.named :a
        g.named :b
      end
    end

    clerk = klass.new
    clerk.load %w(A AZ BZ AY BY)

    expected = [{
      :a => "A", 
      :z => [
        { :a => "AZ", :b => "BZ" }, 
        { :a => "AY", :b => "BY" },
      ]
    }]

    assert_equal expected, clerk.results
  end
end
