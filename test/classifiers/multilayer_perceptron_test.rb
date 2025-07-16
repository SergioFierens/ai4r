# frozen_string_literal: true

require_relative '../test_helper'
require 'ai4r/classifiers/multilayer_perceptron'
require 'ai4r/data/data_set'

class MultilayerPerceptronTest < Minitest::Test
  include Ai4r::Classifiers
  include Ai4r::Data

  DATA_SET = DataSet.new(data_items: [
                             ['New York',  '<30', 'M', 'Y'],
                             ['Chicago',   '<30',     'M', 'Y'],
                             ['New York',  '<30',     'M', 'Y'],
                             ['New York',  '[30-50)', 'F', 'N'],
                             ['Chicago',   '[30-50)', 'F', 'Y'],
                             ['New York',  '[30-50)', 'F', 'N'],
                             ['Chicago',   '[50-80]', 'M', 'N']
                           ]).freeze

  def test_initialize
    classifier = MultilayerPerceptron.new
    assert_equal 1, classifier.active_node_value
    assert_equal 0, classifier.inactive_node_value
    assert_equal Ai4r::NeuralNetwork::Backpropagation, classifier.network_class
    assert_equal [], classifier.hidden_layers
    assert classifier.network_parameters
    assert classifier.network_parameters.empty?
    assert classifier.training_iterations > 1
  end

  def test_build
    assert_raises(ArgumentError) { MultilayerPerceptron.new.build(DataSet.new) }
    classifier = MultilayerPerceptron.new
    classifier.training_iterations = 1
    classifier.build(DATA_SET)
    assert_equal [7, 2], classifier.network.structure
    classifier.hidden_layers = [6, 4]
    classifier.build(DATA_SET)
    assert_equal [7, 6, 4, 2], classifier.network.structure
  end

  def test_eval
    classifier = MultilayerPerceptron.new.build(DATA_SET)
    assert classifier
    assert_equal('N', classifier.eval(['Chicago', '[50-80]', 'M']))
    assert_equal('N', classifier.eval(['New York', '[30-50)', 'F']))
    assert_equal('Y', classifier.eval(['New York', '<30', 'M']))
    assert_equal('Y', classifier.eval(['Chicago',  '[30-50)', 'F']))
  end

  def test_get_rules
    assert_match(/raise/, MultilayerPerceptron.new.get_rules)
  end

  def test_get_max_index
    classifier = MultilayerPerceptron.new
    assert_equal(0, classifier.send(:get_max_index, [3, 1, 0.2, -9, 0, 2.99]))
    assert_equal(2, classifier.send(:get_max_index, [3, 1, 5, -9, 0, 2.99]))
    assert_equal(5, classifier.send(:get_max_index, [3, 1, 5, -9, 0, 6]))
  end

  def test_data_to_output
    classifier = MultilayerPerceptron.new
    classifier.instance_variable_set(:@outputs, 4)
    classifier.instance_variable_set(:@outputs, 4)
    classifier.instance_variable_set(:@domains,
                                     [nil, nil, nil, %w[A B C D]])
    assert_equal([1, 0, 0, 0], classifier.send(:data_to_output, 'A'))
    assert_equal([0, 0, 1, 0], classifier.send(:data_to_output, 'C'))
    assert_equal([0, 0, 0, 1], classifier.send(:data_to_output, 'D'))
  end
end
