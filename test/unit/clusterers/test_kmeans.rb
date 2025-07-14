# frozen_string_literal: true

require_relative '../../test_helper'
require 'ai4r/clusterers/k_means'

class TestKMeans < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers

  DATA = [[1, 1], [1, 2], [2, 1], [2, 2]].freeze

  def dataset(items = DATA)
    DataSet.new(data_items: items)
  end

  def test_k_greater_than_items
    ds = dataset(DATA.first(2))
    assert_raises(ArgumentError) { KMeans.new.build(ds, 3) }
  end

  def test_fixed_seed_deterministic
    ds = dataset
    c1 = KMeans.new.set_parameters(random_seed: 1).build(ds, 2)
    c2 = KMeans.new.set_parameters(random_seed: 1).build(ds, 2)
    assert_equal c1.centroids, c2.centroids
  end

  def test_sse_monotonic
    ds = dataset
    km = KMeans.new.set_parameters(track_history: true, random_seed: 1).build(ds, 2)
    sse_series = km.history.map do |snap|
      centroids = snap[:centroids]
      assigns   = snap[:assignments]
      ds.data_items.each_with_index.sum do |item, idx|
        Ai4r::Data::Proximity.squared_euclidean_distance(item, centroids[assigns[idx]])
      end
    end
    sse_series << km.sse
    assert_sse_decreases sse_series
  end

  def test_empty_dataset
    assert_raises(ArgumentError) { KMeans.new.build(DataSet.new(data_items: []), 1) }
  end

  def test_single_point_centroid
    ds = DataSet.new(data_items: [[5, 5]])
    km = KMeans.new.build(ds, 1)
    assert_equal [5, 5], km.centroids.first
  end
end
