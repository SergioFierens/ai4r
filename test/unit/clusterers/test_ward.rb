# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/clusterers/ward_linkage'

class TestWard < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers

  DATA = [[1,1],[1,2],[2,1],[2,2],[8,8],[8,9],[9,8],[9,9]].freeze

  class WardMonitor < WardLinkage
    attr_reader :merge_count, :sse_history
    def initialize
      super()
      @merge_count = 0
      @sse_history = []
    end
    protected
    def merge_clusters(a,b,ic)
      super
      clusters = build_clusters_from_index_clusters(ic)
      sse = clusters.sum do |cl|
        cen = cl.get_mean_or_mode
        cl.data_items.sum { |it| Ai4r::Data::Proximity.squared_euclidean_distance(it, cen) }
      end
      @sse_history << sse
      @merge_count += 1
    end
  end

  def test_sse_non_decreasing
    ds = DataSet.new(data_items: DATA)
    w = WardMonitor.new.build(ds, 1)
    assert w.sse_history.each_cons(2).all? { |a,b| b >= a }
  end

  def test_merge_count
    ds = DataSet.new(data_items: DATA.first(5))
    w = WardMonitor.new.build(ds, 1)
    assert_equal ds.data_items.length - 1, w.merge_count
  end
end
