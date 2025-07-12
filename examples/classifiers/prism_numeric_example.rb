require_relative '../../lib/ai4r/classifiers/prism'
require_relative '../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

items = [
  [20, 70, 'N'],
  [25, 80, 'N'],
  [30, 60, 'Y'],
  [35, 65, 'Y']
]
labels = ['temperature', 'humidity', 'play']

data = DataSet.new(data_items: items, data_labels: labels)

classifier = Prism.new.build(data)

puts 'Rules:'
puts classifier.get_rules
puts
puts "Prediction for [30, 70]: #{classifier.eval([30, 70])}"

