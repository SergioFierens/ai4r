# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../../lib/ai4r/neural_network/hopfield'
require_relative '../../lib/ai4r/data/data_set'

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

# Use random asynchronous updates instead of the default sequential
# strategy.  Random updates are closer to the original Hopfield
# formulation and may help the network escape shallow local minima.
net = Ai4r::NeuralNetwork::Hopfield.new
net.set_parameters(update_strategy: :async_random)
net.train(data)

puts 'Evaluation of noisy patterns:'
noisy_patterns.each do |p|
  # Pass `trace: true` to record the energy of each iteration so we can
  # inspect how the network converges to a memorized pattern.
  trace = net.eval(p, trace: true)
  puts "#{p.inspect} => #{trace[:states].last.inspect}"
  puts "Energy trace: #{trace[:energies].inspect}"
end
