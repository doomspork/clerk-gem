require 'csv'

class Clerk 
  attr_accessor :template 

  def initialize(tpl = nil)
    self.template = tpl
  end

  def process_file(path)
    require_template!
    CSV.open(path, 'r').map do |line|
      organize(line)
    end
  end

  def process(data)
    require_template!
    CSV.parse(data).map do |line|
      organize(line)
    end
  end

  def organize(line)
    require_template!
    line = line.split(',') if line.instance_of? String
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

  def require_template!
    raise 'A template is required to process your paperwork!' if @template.nil?
  end

  def named_value(key, value)
    Hash[key, value]
  end

  def grouped_values(grouping, values)
    key, value_keys = grouping.shift

    slice_size = value_keys.length
    groups = Array.new
    values.each_slice(slice_size).each do |group|
      group = group + [nil] * (value_keys.length - group.length) if group.length < value_keys.length
      keyed_group = Hash.new
      group.each_with_index do |value, index|
        keyed_group[value_keys[index]] = value
      end
      groups << keyed_group
    end
    Hash[key, groups]
  end
end
