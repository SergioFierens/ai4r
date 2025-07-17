# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/classifier/classifier_bench'

class ClassifierLoadDatasetTest < Minitest::Test
  DATA_PATH = File.expand_path('../../bench/classifier/datasets/play_tennis.csv', __dir__)

  def test_load_dataset
    ds = Bench::Classifier.load_dataset(DATA_PATH)
    refute_empty ds.data_items
    assert_equal %w[Outlook Temperature Humidity Wind Play], ds.data_labels
  end
end
