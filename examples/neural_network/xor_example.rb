# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../../lib/ai4r/neural_network/backpropagation'
require 'benchmark'

times = Benchmark.measure do

    srand 1
    
    net = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])
      
    puts "Training the network, please wait."
    2001.times do |i|
      net.train([0,0], [0])
      net.train([0,1], [1])
      net.train([1,0], [1])
      error = net.train([1,1], [0])      
      puts "Error after iteration #{i}:\t#{error}" if i%200 == 0
    end
  
    puts "Test data"
    puts "[0,0] = > #{net.eval([0,0]).inspect}"
    puts "[0,1] = > #{net.eval([0,1]).inspect}"
    puts "[1,0] = > #{net.eval([1,0]).inspect}"
    puts "[1,1] = > #{net.eval([1,1]).inspect}"
end

  puts "Elapsed time: #{times}"
