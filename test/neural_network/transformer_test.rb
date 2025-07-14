require 'minitest/autorun'
require 'ai4r/neural_network/transformer'

class TransformerTest < Minitest::Test
  def test_eval_shape
    srand 1
    model = Ai4r::NeuralNetwork::Transformer.new(
      vocab_size: 20,
      max_len: 5,
      embed_dim: 8,
      num_heads: 2,
      ff_dim: 16
    )
    out = model.eval([1, 2, 3])
    assert_equal 3, out.length
    out.each { |vec| assert_equal 8, vec.length }
  end

  def test_sequence_too_long
    model = Ai4r::NeuralNetwork::Transformer.new(vocab_size: 10, max_len: 2)
    assert_raises(ArgumentError) { model.eval([1, 2, 3]) }
  end
end
