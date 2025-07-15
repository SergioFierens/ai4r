# frozen_string_literal: true

require 'ai4r/classifiers/gradient_boosting'
require 'ai4r/data/data_set'
require_relative '../test_helper'

include Ai4r::Classifiers
include Ai4r::Data

class GradientBoostingTest < Minitest::Test
  DATA_LABELS = %w[x target].freeze
  DATA_ITEMS = [[1, 2], [2, 4], [3, 6], [4, 8]].freeze

  def setup
    ds = DataSet.new(data_items: DATA_ITEMS, data_labels: DATA_LABELS)
    @gb = GradientBoosting.new.set_parameters(n_estimators: 5, learning_rate: 0.5).build(ds)
  end

  def test_eval
    assert_in_delta 10.0, @gb.eval([5]), 1.0
  end
end
