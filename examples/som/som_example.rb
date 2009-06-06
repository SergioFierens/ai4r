require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require 'benchmark'


som = Ai4r::Som::Som.new 2, 5, Ai4r::Som::TwoPhaseLayer.new(4,3)
som.initiate_map

som.nodes.each do |node|
  p node.weights
end

puts

som.train [[0.1, 0.8], [0.3, 0.4], [0.9538, 0.91236]]

som.nodes.each do |node|
  p node.weights
end