# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/naive_bayes'
require_relative '../../lib/ai4r/data/data_set'

file = "#{File.dirname(__FILE__)}/naive_bayes_data.csv"
set = Ai4r::Data::DataSet.new.load_csv_with_labels(file)

bayes = Ai4r::Classifiers::NaiveBayes.new.set_parameters(m: 3).build(set)

puts bayes.class_prob.inspect
puts bayes.pcc.inspect
puts bayes.pcp.inspect
