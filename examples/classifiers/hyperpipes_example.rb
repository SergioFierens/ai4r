# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/hyperpipes'
require_relative '../../lib/ai4r/data/data_set'

# Use fully qualified class names instead of including modules.

# Load the training data
file = "#{File.dirname(__FILE__)}/hyperpipes_data.csv"
data = Ai4r::Data::DataSet.new.parse_csv_with_labels(file)

# Build the classifier using custom parameters
classifier = Ai4r::Classifiers::Hyperpipes.new.set_parameters(tie_break: :random).build(data)

# Inspect the generated pipes
pipes_summary = classifier.pipes
puts 'Pipes summary:'
pp pipes_summary

# Classify new instances
puts "Prediction for ['Chicago', 85, 'F']: #{classifier.eval(['Chicago', 85, 'F'])}"
puts "Prediction for ['New York', 25, 'M']: #{classifier.eval(['New York', 25, 'M'])}"
