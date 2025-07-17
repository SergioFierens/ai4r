# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/clusterer/runners/dbscan_runner'

class DbscanRunnerTest < Minitest::Test
  def test_call_returns_metrics
    ds = Ai4r::Data::DataSet.new(data_items: [[0, 0], [0, 0.1], [3, 3], [3.1, 3.1]])
    runner = Bench::Clusterer::Runners::DbscanRunner.new(ds, 0.05, 1)
    metrics = runner.call

    assert_equal 'dbscan', metrics.algorithm
    assert_equal [[0, 1], [2, 3]], metrics[:clusters]
    assert metrics[:silhouette] <= 1 && metrics[:silhouette] >= -1
    assert_equal 'eps=0.05', metrics[:notes]
  end
end
