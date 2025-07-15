# frozen_string_literal: true

require 'ai4r/classifiers/support_vector_machine'
require 'ai4r/data/data_set'
require 'minitest/autorun'

include Ai4r::Classifiers
include Ai4r::Data

class SupportVectorMachineTest < Minitest::Test
  def setup
    labels = %w[x1 x2 class]
    items = [
      [1.0, 2.0, 'pos'],
      [2.0, 3.0, 'pos'],
      [2.0, 0.0, 'pos'],
      [-1.0, -1.0, 'neg'],
      [-2.0, -1.0, 'neg'],
      [-2.0, -3.0, 'neg']
    ]
    @data_set = DataSet.new(data_items: items, data_labels: labels)
  end

  def test_build_and_eval
    svm = SupportVectorMachine.new.set_parameters(iterations: 50, learning_rate: 0.1)
    svm.build(@data_set)
    assert_equal 'pos', svm.eval([2, 2])
    assert_equal 'neg', svm.eval([-1, -2])
  end

  def test_invalid_class_count
    labels = %w[x1 x2 class]
    items = [[0, 0, 'a'], [1, 1, 'b'], [2, 2, 'c']]
    ds = DataSet.new(data_items: items, data_labels: labels)
    assert_raises(ArgumentError) { SupportVectorMachine.new.build(ds) }
  end

  def test_get_rules
    svm = SupportVectorMachine.new
    assert_equal 'SupportVectorMachine does not support rule extraction.',
                 svm.get_rules
  end
  end
