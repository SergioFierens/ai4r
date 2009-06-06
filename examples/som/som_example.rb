require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require File.dirname(__FILE__) + '/som_data'
require 'benchmark'

som = Ai4r::Som::Som.new 4, 8, Ai4r::Som::TwoPhaseLayer.new(4)
som.initiate_map

som.nodes.each do |node|
  p node.weights
end

puts

som.train SOM_DATA

som.nodes.each do |node|
  p node.weights
end