# Clerk

Clerk is that helpful cube jocky who transform your CSV input into a structured object collection.

### How to use

- Create a class which extends `Clerk::Base` and creates a template using the `Clerk::Template` DSL. For example:

```
class MyClerk < Clerk::Base
  template do |t|
    t.named :date
    t.ignored
    t.named :product_id
  end
end
```
 	
### Example
```
data = "2013-05-10,Sir,Steve,Coding,5,Eating,10,Running,0"

class MyClerk < Clerk::Base
  template do |t|
    t.named :date
    t.ignored
    t.named :name
    t.grouped :skills, [:name, :level]
  end

  parser :csv
end

clerk = MyClerk.new 
clerk.parser.open_file '/path/to/data.csv'

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
	
### (Known) Limitations

1. Only one repeated group is supported
2. The repeated group must come at the end
