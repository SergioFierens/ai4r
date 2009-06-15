require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/csv_data_set'
require 'benchmark'

include Ai4r::Classifiers
include Ai4r::Data

data = CsvDataSet.new
data.load_csv_with_labels "bayes_data.csv"

p data

b = Bayes.new data
p b.eval(["Blue", "Sports", "Imported"])
