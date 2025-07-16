# frozen_string_literal: true

require 'ai4r/classifiers/simple_linear_regression'
require 'ai4r/data/data_set'
require_relative '../test_helper'

class SimpleLinearRegressionTest < Minitest::Test
  include Ai4r::Classifiers
  include Ai4r::Data
  @@data_labels = %w[symboling normalized-losses wheel-base length width height curb-weight
                     engine-size bore stroke compression-ratio horsepower peak-rpm city-mpg
                     highway-mpg class]

  @@data_items = [
    [2, 164, 99.8, 176.6, 66.2, 54.3, 2337, 109, 3.19, 3.4, 10, 102, 5500, 24, 30, 13_950],
    [2, 164, 99.4, 176.6, 66.4, 54.3, 2824, 136, 3.19, 3.4, 8, 115, 5500, 18, 22, 17_450],
    [1, 158, 105.8, 192.7, 71.4, 55.7, 2844, 136, 3.19, 3.4, 8.5, 110, 5500, 19, 25, 17_710],
    [1, 158, 105.8, 192.7, 71.4, 55.9, 3086, 131, 3.13, 3.4, 8.3, 140, 5500, 17, 20, 23_875],
    [2, 192, 101.2, 176.8, 64.8, 54.3, 2395, 108, 3.5, 2.8, 8.8, 101, 5800, 23, 29, 16_430],
    [0, 192, 101.2, 176.8, 64.8, 54.3, 2395, 108, 3.5, 2.8, 8.8, 101, 5800, 23, 29, 16_925],
    [0, 188, 101.2, 176.8, 64.8, 54.3, 2710, 164, 3.31, 3.19, 9, 121, 4250, 21, 28, 20_970],
    [0, 188, 101.2, 176.8, 64.8, 54.3, 2765, 164, 3.31, 3.19, 9, 121, 4250, 21, 28, 21_105],
    [2, 121, 88.4, 141.1, 60.3, 53.2, 1488, 61, 2.91, 3.03, 9.5, 48, 5100, 47, 53, 5151]
  ]

  def setup
    @data_set = DataSet.new
    @data_set = DataSet.new(data_items: @@data_items, data_labels: @@data_labels)
    @c = SimpleLinearRegression.new.build @data_set
  end

  def test_eval
    result = @c.eval([-1, 95, 109.1, 188.8, 68.9, 55.5, 3062, 141, 3.78, 3.15, 9.5, 114, 5400, 19,
                      25])
    assert_equal 18_607.025513298104, result
  end

  def test_selected_attribute
    classifier = SimpleLinearRegression.new
                                       .set_parameters(selected_attribute: 0)
                                       .build(@data_set)
    assert_equal 0, classifier.attribute_index
    expected = 14_084.580645161293
    result = classifier.eval(@data_set.data_items.first[0...-1])
    assert_in_delta expected, result, 0.0001
  end

  def test_get_rules
    classifier = SimpleLinearRegression.new
    assert_equal 'SimpleLinearRegression does not support rule extraction.',
                 classifier.get_rules
  end
end
