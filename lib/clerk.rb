require 'csv'

class Clerk 
  def initialize(template)
    @template = template
  end

  def process(data)
    CSV.parse(data).map do |line|
      organize(line)
    end
  end

  def organize(line)
    result = Hash.new
    @template.each_with_index do |key, index|
      case key
      when Hash
        value = grouped_values(key, line.slice(index..line.length))
      when NilClass 
        next
      else
        value = named_value(key, line[index])
      end
      result.merge! value
    end
    result
  end

  private 

  def named_value(key, value)
    Hash[key, value]
  end

  def grouped_values(grouping, values)
    key, value_keys = grouping.shift

    slice_size = value_keys.length
    groups = Array.new
    values.each_slice(slice_size).each do |group|
      keyed_group = Hash.new
      group.each_with_index do |value, index|
        keyed_group[value_keys[index]] = value
      end
      groups << keyed_group
    end
    Hash[key, groups]
  end
end
