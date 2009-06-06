require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require 'benchmark'


som = Ai4r::Som::Som.new 2,3,Ai4r::Som::Layer.new(3)
som.initiate_map
som.train [[1,2], [3,4], [5,6]]
