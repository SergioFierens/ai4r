# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/prism'
require_relative '../../lib/ai4r/data/data_set'

items = [
  [20, 70, 'N'],
  [25, 80, 'N'],
  [30, 60, 'Y'],
  [35, 65, 'Y']
]
labels = %w[temperature humidity play]

data = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)

classifier = Ai4r::Classifiers::Prism.new.build(data)

puts 'Rules:'
puts classifier.get_rules
puts
puts "Prediction for [30, 70]: #{classifier.eval([30, 70])}"
