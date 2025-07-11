require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/id3'
require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/validation'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

file = "#{File.dirname(__FILE__)}/id3_data.csv"
data_set = DataSet.new.load_csv_with_labels(file)

train_set, test_set = Validation.train_test_split(data_set, 0.3)
classifier = ID3.new.set_parameters(on_unknown: :most_frequent).build(train_set)

correct = test_set.data_items.count do |item|
  classifier.eval(item[0..-2]) == item.last
end
puts "Accuracy on test set: #{correct.to_f / test_set.data_items.length}"

accuracies = Validation.evaluate_k_fold(ID3, data_set, 5, on_unknown: :most_frequent)
puts "5-fold accuracies: #{accuracies.inspect}"
puts "Average accuracy: #{accuracies.inject(:+) / accuracies.length}"
