# frozen_string_literal: true

# This small tutorial shows how changing parameters of ZeroR and OneR
# affects the generated rules. Run it with `ruby parameter_tutorial.rb`.

require_relative '../../lib/ai4r/classifiers/zero_r'
require_relative '../../lib/ai4r/classifiers/one_r'
require_relative '../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

# Load the demonstration data set
file = "#{File.dirname(__FILE__)}/zero_one_r_data.csv"
set = DataSet.new.load_csv_with_labels file

puts '== ZeroR with default parameters =='
zero_default = ZeroR.new.build(set)
puts zero_default.get_rules

puts "\n== ZeroR with :tie_strategy => :random =="
zero_rand = ZeroR.new.set_parameters(tie_strategy: :random).build(set)
puts zero_rand.get_rules

puts "\n== OneR default behaviour =="
one_default = OneR.new.build(set)
puts one_default.get_rules

puts "\n== OneR forcing first attribute and :last tie break =="
one_custom = OneR.new.set_parameters(selected_attribute: 0, tie_break: :last).build(set)
puts one_custom.get_rules
