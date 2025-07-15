# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/ib1'
require_relative '../../lib/ai4r/data/data_set'

file = "#{File.dirname(__FILE__)}/hyperpipes_data.csv"
data = Ai4r::Data::DataSet.new.parse_csv_with_labels(file)

classifier = Ai4r::Classifiers::IB1.new.build(data)

sample = ['Chicago', 55, 'M']
puts "Prediction for #{sample.inspect}: #{classifier.eval(sample)}"
