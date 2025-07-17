require_relative '../test_helper'
require 'ai4r/clusterers/cluster_tree'

class ClusterTreeTest < Minitest::Test
  include Ai4r::Clusterers
  include Ai4r::Data

  class DummyClusterer < Clusterer
    prepend Ai4r::Clusterers::ClusterTree
    attr_reader :clusters

    def build(data_set, number_of_clusters = 1, **_options)
      @data_set = data_set
      @distance_matrix = []
      index_clusters = data_set.data_items.each_index.map { |i| [i] }
      merge_clusters(index_clusters.length - 1, 0, index_clusters) while index_clusters.length > number_of_clusters
      @clusters = build_clusters_from_index_clusters(index_clusters)
      self
    end

    protected

    def merge_clusters(index_a, index_b, index_clusters)
      index_clusters[index_b] += index_clusters[index_a]
      index_clusters.delete_at(index_a)
      index_clusters
    end

    def build_clusters_from_index_clusters(index_clusters)
      index_clusters.map do |indices|
        Ai4r::Data::DataSet.new(data_items: indices.map { |i| @data_set.data_items[i] })
      end
    end
  end

  DATA = [[0, 0], [0, 1], [1, 0], [1, 1]].freeze

  def setup
    @data_set = DataSet.new(data_items: DATA)
  end

  def test_records_all_merges_by_default
    clusterer = DummyClusterer.new.build(@data_set, 1)
    assert_equal 4, clusterer.cluster_tree.length
    final_items = clusterer.clusters.map(&:data_items)
    assert_equal final_items, clusterer.cluster_tree.first.map(&:data_items)
  end

  def test_depth_limits_history
    clusterer = DummyClusterer.new(2).build(@data_set, 1)
    assert_equal 2, clusterer.cluster_tree.length
    assert_equal 1, clusterer.cluster_tree.first.length
  end
end
