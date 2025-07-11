require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/hyperpipes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

# Load the training data
file = File.dirname(__FILE__) + '/hyperpipes_data.csv'
data = DataSet.new.parse_csv_with_labels(file)

# Build the classifier using custom parameters
classifier = Hyperpipes.new.set_parameters(:tie_strategy => :random).build(data)

# Inspect the generated pipes
pipes_summary = classifier.pipes
puts 'Pipes summary:'
pp pipes_summary

# Classify new instances
puts "Prediction for ['Chicago', 85, 'F']: #{classifier.eval(['Chicago', 85, 'F'])}"
puts "Prediction for ['New York', 25, 'M']: #{classifier.eval(['New York', 25, 'M'])}"
