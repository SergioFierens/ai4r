require File.dirname(__FILE__) + '/../../lib/ai4r/som/som'
require File.dirname(__FILE__) + '/som_data'
require 'benchmark'

# Train a small SOM and stop early when the global error drops below 1000.
som = Ai4r::Som::Som.new 4, 8, 8, Ai4r::Som::TwoPhaseLayer.new(10)
som.initiate_map

puts "Initial global error: #{som.global_error(SOM_DATA)}"

puts "\nTraining the SOM (early stopping threshold = 1000)\n"
times = Benchmark.measure do
  som.train(SOM_DATA, error_threshold: 1000) do |error|
    puts "Epoch #{som.epoch}: error = #{error}"
  end
end

puts "Elapsed time for training: #{times}"
puts "Final global error: #{som.global_error(SOM_DATA)}\n"
