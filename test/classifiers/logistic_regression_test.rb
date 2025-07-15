# frozen_string_literal: true

require 'ai4r/classifiers/logistic_regression'
require 'ai4r/data/data_set'
require_relative '../test_helper'

include Ai4r::Classifiers
include Ai4r::Data

class LogisticRegressionTest < Minitest::Test
  DATA_LABELS = %w[x1 x2 class].freeze
  DATA_ITEMS = [
    [0, 0, 0],
    [0, 1, 1],
    [1, 0, 1],
    [1, 1, 1]
  ].freeze

  def setup
    @data_set = DataSet.new(data_items: DATA_ITEMS, data_labels: DATA_LABELS)
    @classifier = LogisticRegression.new
    @classifier.set_parameters(learning_rate: 0.5, iterations: 2000)
    @classifier.build(@data_set)
  end

  def test_eval
    assert_equal 0, @classifier.eval([0, 0])
    assert_equal 1, @classifier.eval([1, 0])
    assert_equal 1, @classifier.eval([0, 1])
    assert_equal 1, @classifier.eval([1, 1])
  end

  def test_weights_present
    assert_equal 3, @classifier.weights.length
  end

  def test_get_rules
    classifier = LogisticRegression.new
    assert_equal 'LogisticRegression does not support rule extraction.',
                 classifier.get_rules
  end
end
