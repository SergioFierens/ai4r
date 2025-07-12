# Author::    Example contributor
# License::   MPL 1.1
# Project::   ai4r
#
# Simple example showing how to use Backpropagation#train_epochs with a callback.

require_relative '../../lib/ai4r/neural_network/backpropagation'

inputs  = [[0,0], [0,1], [1,0], [1,1]]
outputs = [[0], [1], [1], [0]]

net = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])

loss_history = []
net.train_epochs(inputs, outputs, epochs: 200, batch_size: 1) do |epoch, loss, acc|
  loss_history << [epoch, loss, acc]
  puts "Epoch #{epoch}: loss #{format('%.4f', loss)} accuracy #{(acc*100).round(2)}%" if epoch % 50 == 0
end

puts 'Training finished.'
