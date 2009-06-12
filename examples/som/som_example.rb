require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require File.dirname(__FILE__) + '/som_data'
require 'benchmark'

10.times do |t|
  t += 3

  puts "Nodes: #{t}"
  som = Ai4r::Som::Som.new 4, 8, Ai4r::Som::Layer.new(t, t - 1, 200, 0.95)
  som.initiate_map

  som.nodes.each do |node|
    #p node.weights
  end

  puts "global error distance: #{som.global_error(SOM_DATA)}"
  puts "\ntraining the som\n"

  times = Benchmark.measure do
    som.train SOM_DATA
  end

  som.nodes.each do |node|
    p node.weights
  end

  puts "Elapsed time for training: #{times}"
  puts "global error distance: #{som.global_error(SOM_DATA)}\n\n"
end