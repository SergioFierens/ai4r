# Author::    Example contributor
# License::   MPL 1.1
# Project::   ai4r
#
# Simple example showing how to use OneR with numeric attributes.

require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/one_r'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'

include Ai4r::Classifiers
include Ai4r::Data

items = [
  ['New York', 20, 'M', 'Y'],
  ['Chicago', 25, 'M', 'Y'],
  ['New York', 28, 'M', 'Y'],
  ['New York', 35, 'F', 'N'],
  ['Chicago', 40, 'F', 'Y'],
  ['New York', 45, 'F', 'N'],
  ['Chicago', 55, 'M', 'N']
]
labels = ['city', 'age', 'gender', 'marketing_target']

ds = DataSet.new(:data_items => items, :data_labels => labels)

classifier = OneR.new.build(ds)
puts classifier.get_rules
puts classifier.eval(['Chicago', 55, 'M'])
