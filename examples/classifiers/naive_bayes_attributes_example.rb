require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/naive_bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

file = File.dirname(__FILE__) + '/naive_bayes_data.csv'
set = DataSet.new.load_csv_with_labels(file)

bayes = NaiveBayes.new.set_parameters(:m => 3).build(set)

puts bayes.class_prob.inspect
puts bayes.pcc.inspect
puts bayes.pcp.inspect

