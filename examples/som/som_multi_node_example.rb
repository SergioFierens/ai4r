# Demonstrates how map size impacts error and uses early stopping.
require_relative '../../lib/ai4r/som/som'
require_relative 'som_data'
require 'benchmark'

10.times do |t|
  nodes = t + 3 # minimum number of nodes

  puts "Nodes: #{nodes}"
  som = Ai4r::Som::Som.new 4, 8, 8, Ai4r::Som::TwoPhaseLayer.new(nodes)
  som.initiate_map

  puts "Initial error: #{som.global_error(SOM_DATA)}"
  times = Benchmark.measure do
    som.train(SOM_DATA, error_threshold: 1000)
  end
  puts "Elapsed time for training: #{times}"
  puts "Final error: #{som.global_error(SOM_DATA)}\n\n"
end
