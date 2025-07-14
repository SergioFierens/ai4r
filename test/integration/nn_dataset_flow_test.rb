# frozen_string_literal: true
require_relative '../test_helper'
require 'ai4r/neural_network/backpropagation'

class NNDatasetFlowTest < Minitest::Test
  def test_load_params
    yml = {'epochs'=>3,'lr'=>0.05}
    File.write('tmp.yml', yml.to_yaml)
    params = YAML.safe_load(File.read('tmp.yml'))
    nn = Ai4r::NeuralNetwork::Backpropagation.new([2,1])
    nn.learning_rate = params['lr']
    assert_equal 0.05, nn.learning_rate
    File.delete('tmp.yml')
  end
end
