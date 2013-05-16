# Clerk

Clerk is that helpful cube jocky who transform your CSV input into a structured object collection.

### How to use

- Create an instance (which can optionally accept a template)
 	
 	`clerk = Clerk.new`
 	
- Provide a template (if necessary)
	
	`clerk.template = [:date, nil, :name, {:tickets => [:price, :quantity]]}`
	
- Do some processing 
	- Process a file from path

		`clerk.process_file(_path_to_csv_file_)`
		
	- Process a chunk of CSV data
		
		`clerk.process(csv_data)`
	
	- Organize a single CSV line
	
		`clerk.organize(csv_line)`

### Example
```
data = "2013-05-10,Sir,Steve,Coding,5,Eating,10,Running,0"
clerk = Clerk.new [:date, nil, :name, {:skills => [:name, :level]}]
result = clerk.organize(data)
 => {:date=>"2013-05-10", 
 	 :name=>"Steve", 
 	 :skills=>[
 	 	{:name=>"Coding", :level=>"5"}, 
 	 	{:name=>"Eating", :level=>"10"}, 
 	 	{:name=>"Running", :level=>"0"}]}
```

### Templates

Clerk requires a template in order to properly transform your data, these templates can include name-value pairs, repeated groups, and ignored columns.

- ##### Name-value pair
	Template names can be defined as either a String or Symbol: `[:date, 'price']`

- ##### Repeated group
	Repeated groups are defined as a single keyed hash with an array of keys for the group.  The following group would match columns in groups of two to the keys `:name` and `:age`: `[{:group => [:name, :age]}]`

- ##### Ignored values
	Just toss a `nil` into your template array and that column won't be present in the transformed object: `[:date, nil, :name]`
	
	
### (Known) Limitations

1. Only one repeated group is supported
2. The repeated group must come at the end
