# this example shows the impact of the size of a som on the global error distance
require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require File.dirname(__FILE__) + '/som_data'
require 'benchmark'

10.times do |t|
  t += 3 # minimum number of nodes

  puts "Nodes: #{t}"
  som = Ai4r::Som::Som.new 4, 8, Ai4r::Som::TwoPhaseLayer.new(t)
  som.initiate_map

  puts "global error distance: #{som.global_error(SOM_DATA)}"
  puts "\ntraining the som\n"

  times = Benchmark.measure do
    som.train SOM_DATA
  end

  puts "Elapsed time for training: #{times}"
  puts "global error distance: #{som.global_error(SOM_DATA)}\n\n"
end