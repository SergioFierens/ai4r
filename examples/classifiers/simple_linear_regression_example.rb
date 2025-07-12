require_relative '../../lib/ai4r/classifiers/simple_linear_regression'
require_relative '../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

# Load training data
file = File.dirname(__FILE__) + '/simple_linear_regression_example.csv'
data_set = DataSet.new.parse_csv_with_labels file

# Build the regression model and inspect its coefficients
r = SimpleLinearRegression.new.build data_set
puts "Selected attribute: #{r.attribute}"
puts "Slope: #{r.slope}, Intercept: #{r.intercept}"

# Predict a new sample
predicted = r.eval([-1,95,109.1,188.8,68.9,55.5,3062,141,3.78,3.15,9.5,114,5400,19,25])
puts "Predicted value: #{predicted}"

