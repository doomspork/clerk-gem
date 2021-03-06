require 'test_helper'

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

  def test_clerk_structures_grouped_data_with_one_result
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
      ["1", "Store Name", "TX", "Product A", "$12.99"],
      ["2", "Store Name", "CA", "Product A", "$14.99", "Product B", "$22.99", "Product C", "$35.99"],
    ]

    clerk.load data
    assert clerk.valid?

    expected = [
      {
        :store_id => "1",
        :location => "TX",
        :products => [
          { :product => "Product A", :price => "$12.99" }
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

  def test_clerk_handles_no_group_data_when_group_defined
    klass = Class.new Clerk::Base
    klass.template do |t|
      t.ignored
      t.named :name
      t.named :race
      t.named :gender
      t.named :class
      t.ignored
      t.grouped(:loot) do |g|
        g.named :name
        g.named :quantity
      end
    end

    data = [
      "1,Fhaemita Dewshining,Half-elf,Female,3,80".split(","),
      "2,George,Elf,Male,2,20,Gold,100,Rubies,20".split(",")
    ]

    clerk = klass.new
    clerk.load data

    expected = [{
        :name   => "Fhaemita Dewshining",
        :race   => "Half-elf",
        :gender => "Female",
        :class  => "3",
        :loot   => []
      },
      {
        :name => "George",
        :race => "Elf",
        :gender => "Male",
        :class=> "2", 
        :loot => [
          {:name => "Gold", :quantity => "100"},
          {:name => "Rubies",:quantity => "20" }
        ]
      }
    ]

    assert_equal expected, clerk.results
  end

  def test_clerk_exposes_validation_errors
    klass = Class.new Clerk::Base
    klass.template do |t|
      t.named :name
      t.named :age
    end

    klass.validates_presence_of :age

    data = [
      "Bob,25",
      "John,23",
      "Phillip",
    ].map! { |x| x.split(",") }

    clerk = klass.new
    clerk.load data
    
    assert clerk.invalid?
    assert clerk.errors.has_key? 3
  end

  def test_clerk_has_no_errors_when_valid
    klass = Class.new Clerk::Base
    klass.template do |t|
      t.named :a
      t.named :b
    end

    klass.validates_presence_of :a

    clerk = klass.new
    clerk.load %w(A B)

    assert clerk.valid?
    assert clerk.errors.empty?
  end
end
