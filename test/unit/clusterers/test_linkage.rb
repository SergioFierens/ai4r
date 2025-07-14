# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/clusterers/single_linkage'
require 'ai4r/clusterers/complete_linkage'
require 'ai4r/clusterers/average_linkage'
require 'ai4r/clusterers/median_linkage'
require 'ai4r/clusterers/centroid_linkage'
require 'ai4r/clusterers/weighted_average_linkage'

class TestLinkage < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers

  DATA4 = [[0,0],[0,1],[5,0],[5,1]]
  DATA_N = [[0],[1],[2],[3],[4]]

  LINKAGE_CLASSES = [SingleLinkage, CompleteLinkage, AverageLinkage,
                     MedianLinkage, CentroidLinkage, WeightedAverageLinkage]

  def test_first_merge_shortest_pair
    ds = DataSet.new(data_items: DATA4)
    LINKAGE_CLASSES.each do |klass|
      clusterer = klass.new.build(ds, 3)
      clusters = clusterer.clusters.map(&:data_items).map { |c| c.sort }
      assert clusters.include?([[0,0],[0,1]]) ||
             clusters.include?([[5,0],[5,1]])
    end
  end

  def test_merge_count
    ds = DataSet.new(data_items: DATA_N)
    LINKAGE_CLASSES.each do |klass|
      mc = Class.new(klass) do
        attr_reader :merge_count
        def initialize
          super()
          @merge_count = 0
        end
        protected
        def merge_clusters(a,b,ic)
          @merge_count += 1
          super
        end
      end
      clusterer = mc.new.build(ds,1)
      assert_equal DATA_N.length - 1, clusterer.merge_count
    end
  end
end
