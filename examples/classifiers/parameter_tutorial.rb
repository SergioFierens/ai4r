# frozen_string_literal: true

# This small tutorial shows how changing parameters of ZeroR and OneR
# affects the generated rules. Run it with `ruby parameter_tutorial.rb`.

require_relative '../../lib/ai4r/classifiers/zero_r'
require_relative '../../lib/ai4r/classifiers/one_r'
require_relative '../../lib/ai4r/data/data_set'

# Load the demonstration data set
file = "#{File.dirname(__FILE__)}/zero_one_r_data.csv"
set = Ai4r::Data::DataSet.new.load_csv_with_labels file

puts '== ZeroR with default parameters =='
zero_default = Ai4r::Classifiers::ZeroR.new.build(set)
puts zero_default.get_rules

puts "\n== ZeroR with :tie_break => :random =="
zero_rand = Ai4r::Classifiers::ZeroR.new.set_parameters(tie_break: :random).build(set)
puts zero_rand.get_rules

puts "\n== OneR default behaviour =="
one_default = Ai4r::Classifiers::OneR.new.build(set)
puts one_default.get_rules

puts "\n== OneR forcing first attribute and :last tie break =="
one_custom = Ai4r::Classifiers::OneR.new.set_parameters(selected_attribute: 0,
                                                        tie_break: :last).build(set)
puts one_custom.get_rules
