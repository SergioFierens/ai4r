require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/naive_bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'
require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/id3'
require 'benchmark'

include Ai4r::Classifiers
include Ai4r::Data

data_set = DataSet.new
data_set.load_csv_with_labels File.dirname(__FILE__) + "/naive_bayes_data.csv"

b = NaiveBayes.new.
      set_parameters({:m=>3}).
      build data_set
p b.eval(["Red", "SUV", "Domestic"])
p b.get_probability_map(["Red", "SUV", "Domestic"])
