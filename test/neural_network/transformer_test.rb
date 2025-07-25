require_relative '../test_helper'
require 'ai4r/neural_network/transformer'

class TransformerTest < Minitest::Test
  def test_encoder_eval_shape
    model = Ai4r::NeuralNetwork::Transformer.new(
      vocab_size: 20,
      max_len: 5,
      embed_dim: 8,
      num_heads: 2,
      ff_dim: 16,
      seed: 1
    )
    out = model.eval([1, 2, 3])
    assert_equal 3, out.length
    out.each { |vec| assert_equal 8, vec.length }
  end

  def test_decoder_eval_shape
    model = Ai4r::NeuralNetwork::Transformer.new(vocab_size: 10, max_len: 4, architecture: :decoder)
    out = model.eval([1, 2, 3])
    assert_equal 3, out.length
    out.each { |vec| assert_equal model.embed_dim, vec.length }
  end

  def test_seq2seq_eval_shape
    model = Ai4r::NeuralNetwork::Transformer.new(vocab_size: 10, max_len: 4, architecture: :seq2seq)
    out = model.eval([1, 2], [3, 4, 5])
    assert_equal 3, out.length
    out.each { |vec| assert_equal model.embed_dim, vec.length }
  end

  def test_sequence_too_long
    model = Ai4r::NeuralNetwork::Transformer.new(vocab_size: 10, max_len: 2)
    assert_raises(ArgumentError) { model.eval([1, 2, 3]) }
  end
end
