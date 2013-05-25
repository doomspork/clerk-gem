# Clerk

Clerk is that helpful cube jocky who transforms your data into a structured, verified, and formatted object collection.

### Example
```
class MyClerk < Clerk::Base
  template do |t|
    t.named :date, :transform => :to_date
    t.ignored
    t.named :name
    t.grouped(:skills) do |group|
      group.named :name
      group.named :level
  end

  validate_presence_of :date, :name
  validates_numericality_of :level
end

data = %w(2013-05-10 Sir Steve Coding 5 Eating 10 Running 0)

clerk = MyClerk.new 
clerk.load data
clerk.results

 => {:date=>"2013-05-10", 
 	 :name=>"Steve", 
 	 :skills=>[
 	 	{:name=>"Coding", :level=>"5"}, 
 	 	{:name=>"Eating", :level=>"10"}, 
 	 	{:name=>"Running", :level=>"0"}]}
```

### Templates

Clerk requires a template in order to properly transform your data, these templates can include name-value pairs, repeated groups, and ignored columns.

##### Name-value pair

Template names can be defined as either a String or Symbol: `[:date, 'price']`

```
template.named :date
template.named 'price'
```

##### Repeated group

Repeated groups are used to group sets of data together in an array of hashes. One example would be a list of people and their age in sequence like `Jeff,27,Bill,34,George,23`. To group these together you would use the `grouped` method as follows.


`template.grouped :people, [:name, :age]`

This grouping would yield the end result:

```
[{ :people => [
  { :name => "Jeff",   :age => "27" },
  { :name => "Bill",   :age => "34" },
  { :name => "George", :age => "23" }]}]
```

##### Ignored values

Using the `ignored` option you can specify that the corresponding data should be omitted form the transformed hash.

```
template.named :date
template.ignored
template.named :name
```

### Validations

`Clerk::Base` includes `ActiveModel::Validations` so it's the same validators you've (probably) used before!  For documentation on the validators head over to `ActiveModel::Validations` API [docs](http://api.rubyonrails.org/classes/ActiveModel/Validations.html).

```

### (Known) Limitations

1. Only one repeated group is supported
2. The repeated group must come at the end
