# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/clusterers/bisecting_k_means'
require 'ai4r/clusterers/k_means'

class TestBisectingKMeans < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers

  DATA = [[1,1],[1,2],[2,1],[2,2],[8,8],[8,9],[9,8],[9,9]].freeze

  def test_final_cluster_count
    ds = DataSet.new(data_items: DATA)
    clusterer = BisectingKMeans.new.build(ds, 3)
    assert_equal 3, clusterer.clusters.length
  end

  def test_split_reduces_sse
    ds = DataSet.new(data_items: DATA)
    sse1 = KMeans.new.build(ds,1).sse
    sse2 = BisectingKMeans.new.build(ds,2).sse
    assert_operator sse2, :<=, sse1 * 0.9
  end
end
