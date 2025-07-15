# frozen_string_literal: true

require_relative '../test_helper'
require 'ai4r/clusterers/k_means'
require 'ai4r/clusterers/ward_linkage_hierarchical'
require 'ai4r/data/data_set'

class ClustererFlowTest < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers

  DATA = [[1, 1], [1, 2], [2, 1], [2, 2],
          [8, 8], [8, 9], [9, 8], [9, 9]].freeze

  def test_normalization_improves_sse
    ds = DataSet.new(data_items: DATA)
    raw_sse = KMeans.new.set_parameters(random_seed: 1).build(ds, 2).sse

    norm = DataSet.normalized(ds, method: :minmax)
    norm_sse = KMeans.new.set_parameters(random_seed: 1).build(norm, 2).sse
    assert norm_sse < raw_sse
  end

  def test_export_labels_to_dataset
    ds = DataSet.new(data_items: DATA, data_labels: %w[x y])
    km = KMeans.new.set_parameters(random_seed: 1).build(ds, 2)
    labeled_items = ds.data_items.map { |row| row + [km.eval(row)] }
    labeled = DataSet.new(data_items: labeled_items,
                          data_labels: ds.data_labels + ['cluster'])
    assert_equal ds.data_items.length, labeled.data_items.length
    assert(labeled.data_items.all? { |r| r.last.is_a?(Integer) })
  end

  def test_dendrogram_cut_to_three_clusters
    ds = DataSet.new(data_items: DATA.first(5))
    dendro = WardLinkageHierarchical.new.build(ds, 1)
    level = dendro.cluster_tree[2]
    assert_equal 3, level.length
  end
end
