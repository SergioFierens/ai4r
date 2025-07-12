require_relative '../../lib/ai4r/classifiers/prism'
require_relative '../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

data_file = File.dirname(__FILE__) + '/zero_one_r_data.csv'
data = DataSet.new.load_csv_with_labels(data_file)

classifier = Prism.new.build(data)

puts 'Discovered rules:'
puts classifier.get_rules
puts
sample = data.data_items.first[0...-1]
puts "Prediction for #{sample.inspect}: #{classifier.eval(sample)}"

