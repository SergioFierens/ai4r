require 'test/unit'
require 'ai4r/classifiers/validation'
require 'ai4r/classifiers/id3'
require 'ai4r/data/data_set'

class ValidationTest < Test::Unit::TestCase
  include Ai4r::Classifiers
  include Ai4r::Data

  DATA_LABELS = %w(city age_range gender marketing_target)
  DATA_ITEMS = [
    ['New York', '<30', 'M', 'Y'],
    ['Chicago', '<30', 'M', 'Y'],
    ['Chicago', '<30', 'F', 'Y'],
    ['New York', '<30', 'M', 'Y'],
    ['New York', '<30', 'M', 'Y'],
    ['Chicago', '[30-50)', 'M', 'Y'],
    ['New York', '[30-50)', 'F', 'N'],
    ['Chicago', '[30-50)', 'F', 'Y'],
    ['New York', '[30-50)', 'F', 'N'],
    ['Chicago', '[50-80]', 'M', 'N'],
    ['New York', '[50-80]', 'F', 'N'],
    ['New York', '[50-80]', 'M', 'N'],
    ['Chicago', '[50-80]', 'M', 'N'],
    ['New York', '[50-80]', 'F', 'N'],
    ['Chicago', '>80', 'F', 'Y']
  ]

  def setup
    @data_set = DataSet.new(data_items: DATA_ITEMS, data_labels: DATA_LABELS)
  end

  def test_train_test_split
    train, test = Validation.train_test_split(@data_set, 0.2)
    assert_equal @data_set.data_labels, train.data_labels
    assert_equal @data_set.data_labels, test.data_labels
    assert_equal DATA_ITEMS.length, train.data_items.length + test.data_items.length
  end

  def test_evaluate_k_fold
    accuracies = Validation.evaluate_k_fold(ID3, @data_set, 5, on_unknown: :most_frequent)
    assert_equal 5, accuracies.length
    accuracies.each { |acc| assert_operator acc, :>=, 0.0 }
    accuracies.each { |acc| assert_operator acc, :<=, 1.0 }
    mean = accuracies.inject(:+) / accuracies.length
    assert_in_delta 0.8, mean, 0.2
  end
end
