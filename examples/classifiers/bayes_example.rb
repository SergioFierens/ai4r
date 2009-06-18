require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/csv_data_set'
require 'benchmark'

include Ai4r::Classifiers
include Ai4r::Data

data = CsvDataSet.new
data.load_csv_with_labels File.dirname(__FILE__) + "/bayes_data.csv"

b = Bayes.new data, 3
p b.eval(["Red", "SUV", "Domestic"])
