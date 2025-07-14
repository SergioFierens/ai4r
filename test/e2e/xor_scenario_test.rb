# frozen_string_literal: true
require_relative '../test_helper'
require 'ai4r/neural_network/backpropagation'

class XorScenarioTest < Minitest::Test
  def test_learns_xor
    data = [[0,0,0],[0,1,1],[1,0,1],[1,1,0]]
    inputs = data.map{ |r| r[0,2] }
    outputs = data.map{ |r| [r[2]] }
    net = Ai4r::NeuralNetwork::Backpropagation.new([2,2,1])
    net.train_epochs(inputs, outputs, epochs: 5000)
    preds = inputs.map { |i| net.eval(i).first.round }
    assert_equal outputs.flatten, preds
  end
end
