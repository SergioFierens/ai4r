# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../../lib/ai4r/neural_network/hopfield'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'

patterns = [
  [1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1],
  [-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1],
  [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,1],
  [1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1]
]

noisy_patterns = [
  [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1],
  [-1,-1,1,1,1,-1,1,1,-1,-1,1,-1,-1,-1,1,1],
  [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1],
  [-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,1,-1,-1,-1]
]

data = Ai4r::Data::DataSet.new(data_items: patterns)
net = Ai4r::NeuralNetwork::Hopfield.new.train(data)

puts 'Evaluation of noisy patterns:'
noisy_patterns.each do |p|
  puts "#{p.inspect} => #{net.eval(p).inspect}"
end
