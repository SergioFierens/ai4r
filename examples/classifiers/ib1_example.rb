# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/ib1'
require_relative '../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

file = "#{File.dirname(__FILE__)}/hyperpipes_data.csv"
data = DataSet.new.parse_csv_with_labels(file)

classifier = IB1.new.build(data)

sample = ['Chicago', 55, 'M']
puts "Prediction for #{sample.inspect}: #{classifier.eval(sample)}"
