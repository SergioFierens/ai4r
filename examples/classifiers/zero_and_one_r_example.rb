require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/zero_r'
require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/one_r'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

# Load tutorial data
data_file = File.dirname(__FILE__) + '/zero_one_r_data.csv'
data = DataSet.new.load_csv_with_labels data_file

puts "Data labels: #{data.data_labels.inspect}"
puts

# Build a default ZeroR classifier
zero_default = ZeroR.new.build(data)
puts "ZeroR default prediction: #{zero_default.eval(data.data_items.first)}"
puts "Generated rule: #{zero_default.get_rules}"

# Build ZeroR with custom tie strategy
zero_random = ZeroR.new.set_parameters(:tie_strategy => :random).build(data)
puts "ZeroR random tie strategy prediction: #{zero_random.eval(data.data_items.first)}"

puts

# Build a default OneR classifier
one_default = OneR.new.build(data)
puts "OneR chose attribute index #{one_default.rule[:attr_index]}"
puts "OneR rules:\n#{one_default.get_rules}"

# Build OneR selecting the first attribute and using :last tie break
one_custom = OneR.new.set_parameters(:selected_attribute => 0, :tie_break => :last).build(data)
puts "OneR forced attribute: #{one_custom.rule[:attr_index]}"
puts "Custom rules:\n#{one_custom.get_rules}"

