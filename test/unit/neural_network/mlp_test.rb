# frozen_string_literal: true

require_relative '../../test_helper'
require 'ai4r/classifiers/multilayer_perceptron'

# == P-01 ===============================================================
# Build raises when dataset empty
class MLPBuildTest < Minitest::Test
  def test_build_requires_examples
    mlp = Ai4r::Classifiers::MultilayerPerceptron.new
    empty = Ai4r::Data::DataSet.new
    assert_raises(ArgumentError) { mlp.build(empty) }
  end
end

# == P-03 ===============================================================
# One training step must reduce mean-square error
class MLPTrainingTest < Minitest::Test
  def test_single_epoch_improves_mse
    dataset, params = load_fixture(1)
    net = Ai4r::NeuralNetwork::Backpropagation.new(params['topology'])
    inputs  = dataset.data_items.map { |row| row[0, 2] }
    outputs = dataset.data_items.map { |row| [row[2]] }
    preds = inputs.map { |i| net.eval(i).first }
    mse_before = preds.zip(outputs).map { |p, o| (p - o.first)**2 }.sum / outputs.length.to_f
    errors = net.train_epochs(inputs, outputs, epochs: 1)
    assert errors.last < mse_before
  end
end
