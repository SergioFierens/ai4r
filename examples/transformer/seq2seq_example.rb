require_relative '../../lib/ai4r/neural_network/transformer'

# Simple demo of the seq2seq architecture.
# The model returns random vectors but shows how
# to provide encoder and decoder inputs.
model = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 10,
  max_len: 5,
  architecture: :seq2seq
)

encoder_input = [1, 2, 3]
decoder_input = [4, 5]

output = model.eval(encoder_input, decoder_input)
puts "Output length: #{output.length}"
