# frozen_string_literal: true
require_relative '../test_helper'
require 'ai4r/neural_network/hopfield'

class HopfieldDigitsTest < Minitest::Test
  DIGITS = Array.new(10) { |i| Array.new(15) { ((i >> (_1/3)) & 1) * 2 - 1 } }

  def test_recall_from_noise
    data = Ai4r::Data::DataSet.new(data_items: DIGITS)
    net = Ai4r::NeuralNetwork::Hopfield.new.train(data)
    noisy = DIGITS[3].dup
    4.times { |i| noisy[i] *= -1 }
    result = net.eval(noisy)
    assert_equal 15, result.length
  end
end
