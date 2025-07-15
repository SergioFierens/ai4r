require_relative '../../lib/ai4r/neural_network/transformer'

# Demonstrates deterministic initialization using the :seed parameter.
model_a = Ai4r::NeuralNetwork::Transformer.new(vocab_size: 5, max_len: 3, seed: 42)
model_b = Ai4r::NeuralNetwork::Transformer.new(vocab_size: 5, max_len: 3, seed: 42)

output_a = model_a.eval([0, 1, 2])
output_b = model_b.eval([0, 1, 2])

puts "Outputs identical? #{output_a == output_b}"
