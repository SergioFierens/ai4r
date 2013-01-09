require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/simple_linear_regression'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'
require 'benchmark'

include Ai4r::Classifiers
include Ai4r::Data

data_set = DataSet.new
data_set.parse_csv_with_labels File.dirname(__FILE__) + "/simple_linear_regression_example.csv"

r = SimpleLinearRegression.new.build data_set
p r.eval([-1,95,109.1,188.8,68.9,55.5,3062,141,3.78,3.15,9.5,114,5400,19,25])

# => 11662.949367088606
#Actual price 22625