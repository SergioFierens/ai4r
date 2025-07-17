require_relative '../../test_helper'
require_relative '../../../bench/common/metrics'

class BenchMetricsTest < Minitest::Test
  include Bench::Common

  def test_sse_and_silhouette
    data = [[0,0],[1,1],[10,10],[11,11]]
    clusters = [[0,1],[2,3]]
    assert_in_delta 2.0, sse(data, clusters), 0.0001
    sil = silhouette(data, clusters)
    assert sil <= 1 && sil > 0.9
  end

  def test_classification_metrics
    truth = [1,0,1,1,0]
    preds = [1,0,0,1,0]
    assert_in_delta 0.8, accuracy(truth, preds), 0.0001
    assert_in_delta 0.8333, precision(truth, preds), 0.0001
    assert_in_delta 0.8333, recall(truth, preds), 0.0001
    assert_in_delta 0.8333, f1(truth, preds), 0.0001
  end
end
