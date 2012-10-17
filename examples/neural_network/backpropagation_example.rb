# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/training_patterns'
require File.dirname(__FILE__) + '/patterns_with_noise'
require File.dirname(__FILE__) + '/patterns_with_base_noise'
require File.dirname(__FILE__) + '/../../lib/ai4r/neural_network/backpropagation'
require 'benchmark'

times = Benchmark.measure do
  
    srand 1

    # creating network with 256 input-neurons, 3-neurons and 0 hidden layers
    net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3])
  
    tr_input = TRIANGLE.flatten.collect { |input| input.to_f / 5.0}
    sq_input = SQUARE.flatten.collect { |input| input.to_f / 5.0}
    cr_input = CROSS.flatten.collect { |input| input.to_f / 5.0}

    tr_with_noise = TRIANGLE_WITH_NOISE.flatten.collect { |input| input.to_f / 5.0}
    sq_with_noise = SQUARE_WITH_NOISE.flatten.collect { |input| input.to_f / 5.0}
    cr_with_noise = CROSS_WITH_NOISE.flatten.collect { |input| input.to_f / 5.0}

    tr_with_base_noise = TRIANGLE_WITH_BASE_NOISE.flatten.collect { |input| input.to_f / 5.0}
    sq_with_base_noise = SQUARE_WITH_BASE_NOISE.flatten.collect { |input| input.to_f / 5.0}
    cr_with_base_noise = CROSS_WITH_BASE_NOISE.flatten.collect { |input| input.to_f / 5.0}

    puts "Training the network, please wait."
    101.times do |i|
      error = net.train(tr_input, [1,0,0])
      error = net.train(sq_input, [0,1,0])
      error = net.train(cr_input, [0,0,1])
      puts "Error after iteration #{i}:\t#{error}" if i%20 == 0
    end

    def result_label(result)
      if result[0] > result[1] && result[0] > result[2]
        "TRIANGLE"
      elsif result[1] > result[2] 
        "SQUARE"
      else    
        "CROSS"
      end
    end

    puts "Training Examples"
    puts "#{net.eval(tr_input).inspect} => #{result_label(net.eval(tr_input))}"
    puts "#{net.eval(sq_input).inspect} => #{result_label(net.eval(sq_input))}"
    puts "#{net.eval(cr_input).inspect} => #{result_label(net.eval(cr_input))}"
    puts "Examples with noise"
    puts "#{net.eval(tr_with_noise).inspect} => #{result_label(net.eval(tr_with_noise))}"
    puts "#{net.eval(sq_with_noise).inspect} => #{result_label(net.eval(sq_with_noise))}"
    puts "#{net.eval(cr_with_noise).inspect} => #{result_label(net.eval(cr_with_noise))}"
    puts "Examples with base noise"
    puts "#{net.eval(tr_with_base_noise).inspect} => #{result_label(net.eval(tr_with_base_noise))}"
    puts "#{net.eval(sq_with_base_noise).inspect} => #{result_label(net.eval(sq_with_base_noise))}"
    puts "#{net.eval(cr_with_base_noise).inspect} => #{result_label(net.eval(cr_with_base_noise))}"
  
end

puts "Elapsed time: #{times}"
