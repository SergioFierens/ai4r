# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/prism'
require_relative '../../lib/ai4r/data/data_set'

data_file = "#{File.dirname(__FILE__)}/zero_one_r_data.csv"
data = Ai4r::Data::DataSet.new.load_csv_with_labels(data_file)

classifier = Ai4r::Classifiers::Prism.new.build(data)

puts 'Discovered rules:'
puts classifier.get_rules
puts
sample = data.data_items.first[0...-1]
puts "Prediction for #{sample.inspect}: #{classifier.eval(sample)}"
