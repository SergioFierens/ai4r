# frozen_string_literal: true

# RSpec tests for AI4R KMeans clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::KMeans do
  # Test data from requirement document
  let(:simple_clusters_data) do
    [
      # Cluster 1 around (0, 0)
      [0.1, 0.2], [0.3, 0.1], [-0.1, 0.0],
      # Cluster 2 around (5, 5)
      [5.1, 4.9], [4.8, 5.2], [5.0, 5.0],
      # Cluster 3 around (10, 0)
      [10.2, 0.1], [9.9, -0.1], [10.0, 0.0]
    ]
  end

  let(:simple_clusters_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: simple_clusters_data,
      data_labels: %w[x y]
    )
  end

  let(:large_dataset) do
    items = []
    # 30 points around (0, 0)
    30.times { items << [rand(2.0) - 1.0, rand(2.0) - 1.0] }
    # 30 points around (10, 10)
    30.times { items << [10 + rand(2.0) - 1.0, 10 + rand(2.0) - 1.0] }
    # 30 points around (20, 0)
    30.times { items << [20 + rand(2.0) - 1.0, rand(2.0) - 1.0] }

    Ai4r::Data::DataSet.new(
      data_items: items,
      data_labels: %w[x y]
    )
  end

  let(:identical_points_data) { [[1.0, 2.0]] * 10 }
  let(:identical_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: identical_points_data,
      data_labels: %w[x y]
    )
  end

  let(:high_dimensional_data) { Array.new(50) { Array.new(100) { rand(10.0) } } }
  let(:high_dimensional_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: high_dimensional_data,
      data_labels: Array.new(100) { |i| "dim_#{i}" }
    )
  end

  let(:single_dimension_data) { [[1], [2], [3], [4], [5], [6]] }
  let(:single_dimension_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: single_dimension_data,
      data_labels: ['x']
    )
  end

  describe 'Build Tests' do
    context 'normal clustering' do
      it 'test_build_3_clusters' do
        clusterer = described_class.new.build(large_dataset, 3)

        expect(clusterer).to be_a(described_class)
        expect(clusterer.number_of_clusters).to eq(3)
        expect(clusterer.clusters).to be_an(Array)
        expect(clusterer.clusters.length).to eq(3)
        expect(clusterer.centroids).to be_an(Array)
        expect(clusterer.centroids.length).to eq(3)

        # Each cluster should have points assigned
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items).not_to be_empty
        end
      end
    end

    context 'edge cases' do
      it 'test_build_k_greater_than_n' do
        # k=10, n=5 points - should handle gracefully
        small_data = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]]
        small_dataset = Ai4r::Data::DataSet.new(
          data_items: small_data,
          data_labels: %w[x y]
        )

        clusterer = described_class.new
        clusterer.set_parameters(on_empty: 'eliminate')
        clusterer.build(small_dataset, 10)

        # Should create clusters, some may be eliminated if empty
        expect(clusterer.clusters.length).to be <= 5
        expect(clusterer.clusters.length).to be > 0
      end

      it 'test_build_k_equals_1' do
        # Single cluster - all points in one cluster
        clusterer = described_class.new.build(simple_clusters_dataset, 1)

        expect(clusterer.number_of_clusters).to eq(1)
        expect(clusterer.clusters.length).to eq(1)
        expect(clusterer.clusters[0].data_items.length).to eq(simple_clusters_data.length)
      end

      it 'test_all_points_identical' do
        # All points are identical - degenerate case
        clusterer = described_class.new.build(identical_points_dataset, 3)

        expect(clusterer).to be_a(described_class)
        # Should handle identical points gracefully
        expect(clusterer.centroids).to be_an(Array)

        # All centroids should be the same or clusters eliminated
        expect(clusterer.clusters.length).to be >= 1
      end

      it 'test_high_dimensional_data' do
        # 100+ dimensions - scalability test
        clusterer = described_class.new
        clusterer.set_parameters(max_iterations: 10) # Limit for performance
        clusterer.build(high_dimensional_dataset, 5)

        expect(clusterer.clusters.length).to be <= 5
        expect(clusterer.centroids).to be_an(Array)

        # Each centroid should have correct dimensionality
        clusterer.centroids.each do |centroid|
          expect(centroid.length).to eq(100)
        end
      end

      it 'test_single_dimension_data' do
        # 1D clustering
        clusterer = described_class.new.build(single_dimension_dataset, 2)

        expect(clusterer.clusters.length).to be <= 2
        expect(clusterer.centroids).to be_an(Array)

        # Should work with 1D data
        clusterer.centroids.each do |centroid|
          expect(centroid.length).to eq(1)
        end
      end
    end

    context 'validation tests' do
      it 'test_build_k_equals_0' do
        expect do
          described_class.new.build(simple_clusters_dataset, 0)
        end.to raise_error
      end

      it 'test_build_empty_dataset' do
        empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])

        expect do
          described_class.new.build(empty_dataset, 3)
        end.to raise_error
      end

      it 'test_nan_values' do
        nan_data = [[1.0, 2.0], [Float::NAN, 3.0], [4.0, 5.0]]
        nan_dataset = Ai4r::Data::DataSet.new(
          data_items: nan_data,
          data_labels: %w[x y]
        )

        expect do
          described_class.new.build(nan_dataset, 2)
        end.to raise_error(StandardError)
      end
    end
  end

  describe 'Convergence Tests' do
    it 'test_convergence_stable_centroids' do
      clusterer = described_class.new
      clusterer.set_parameters(max_iterations: 100)
      clusterer.build(simple_clusters_dataset, 3)

      # Should converge (iterations < max_iterations for well-separated data)
      expect(clusterer.iterations).to be < 100
      expect(clusterer.iterations).to be > 0
    end

    it 'test_convergence_max_iterations' do
      # Force many iterations with poorly separated data
      clusterer = described_class.new
      clusterer.set_parameters(max_iterations: 5)
      clusterer.build(identical_points_dataset, 3)

      # Should stop at max iterations
      expect(clusterer.iterations).to eq(5)
    end
  end

  describe 'Centroid Tests' do
    let(:trained_clusterer) { described_class.new.build(simple_clusters_dataset, 3) }

    it 'test_centroid_calculation' do
      # Centroids should be means of assigned points
      expect(trained_clusterer.centroids).to be_an(Array)
      expect(trained_clusterer.centroids.length).to eq(3)

      # Each centroid should be a valid point
      trained_clusterer.centroids.each do |centroid|
        expect(centroid).to be_an(Array)
        expect(centroid.length).to eq(2)
        centroid.each do |coord|
          expect(coord).to be_a(Numeric)
          expect(coord).not_to be_nan
        end
      end
    end

    it 'test_empty_cluster_handling' do
      # Test with eliminate strategy (default)
      clusterer = described_class.new
      clusterer.set_parameters(on_empty: 'eliminate')
      clusterer.build(simple_clusters_dataset, 10) # More clusters than reasonable

      # Should handle empty clusters by eliminating them
      expect(clusterer.clusters.length).to be <= simple_clusters_data.length
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items).not_to be_empty
      end
    end

    it 'test_centroid_initialization_deterministic' do
      # Test with fixed seed for deterministic results
      clusterer1 = described_class.new
      clusterer1.set_parameters(centroid_indices: [0, 3, 6])
      result1 = clusterer1.build(simple_clusters_dataset, 3)

      clusterer2 = described_class.new
      clusterer2.set_parameters(centroid_indices: [0, 3, 6])
      result2 = clusterer2.build(simple_clusters_dataset, 3)

      # Same initial centroids should give same results
      expect(result1.centroids).to eq(result2.centroids)
    end
  end

  describe 'Distance Tests' do
    it 'test_euclidean_distance' do
      clusterer = described_class.new.build(simple_clusters_dataset, 3)

      # Default should use euclidean distance
      dist = clusterer.distance([0, 0], [3, 4])
      expect(dist).to eq(25.0) # 3^2 + 4^2 = 25 (squared euclidean)
    end
  end

  describe 'Eval Tests' do
    let(:trained_clusterer) { described_class.new.build(simple_clusters_dataset, 3) }

    it 'test_eval_assigns_cluster' do
      # Should return cluster index (0-based)
      cluster_index = trained_clusterer.eval([0.0, 0.0])

      expect(cluster_index).to be_a(Integer)
      expect(cluster_index).to be >= 0
      expect(cluster_index).to be < trained_clusterer.clusters.length
    end

    it 'test_eval_new_point' do
      # Point not in training data
      new_point = [2.5, 2.5]
      cluster_index = trained_clusterer.eval(new_point)

      expect(cluster_index).to be_a(Integer)
      expect(cluster_index).to be >= 0
      expect(cluster_index).to be < trained_clusterer.clusters.length
    end

    it 'test_eval_dimension_mismatch' do
      # Wrong number of dimensions
      expect do
        trained_clusterer.eval([1.0]) # Should be 2D
      end.to raise_error
    end

    it 'test_eval_before_build' do
      # No model built yet
      unbuild_clusterer = described_class.new

      expect do
        unbuild_clusterer.eval([1.0, 2.0])
      end.to raise_error
    end
  end

  describe 'Performance Tests' do
    it 'handles large datasets efficiently' do
      # Generate larger dataset
      large_items = []
      1000.times do |i|
        cluster_id = i % 4
        center_x = cluster_id * 5
        center_y = cluster_id * 3
        large_items << [center_x + rand(2.0) - 1.0, center_y + rand(2.0) - 1.0]
      end

      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_items,
        data_labels: %w[x y]
      )

      benchmark_performance('KMeans clustering 1000 points') do
        clusterer = described_class.new
        clusterer.set_parameters(max_iterations: 50)
        clusterer.build(large_dataset, 4)

        expect(clusterer.clusters.length).to eq(4)
      end
    end

    it 'evaluation performance is reasonable' do
      clusterer = described_class.new.build(simple_clusters_dataset, 3)

      benchmark_performance('KMeans evaluation speed') do
        100.times do
          cluster_index = clusterer.eval([rand(15.0), rand(10.0)])
          expect(cluster_index).to be >= 0
        end
      end
    end
  end

  describe 'Integration Tests' do
    it 'works with different distance functions' do
      # Test custom distance function (Manhattan distance)
      clusterer = described_class.new
      clusterer.set_parameters(
        distance_function: ->(a, b) {
          a.zip(b).sum { |ai, bi| (ai - bi).abs }
        }
      )
      clusterer.build(simple_clusters_dataset, 3)

      expect(clusterer.clusters.length).to be <= 3
      expect(clusterer.centroids).to be_an(Array)
    end

    it 'handles different empty cluster strategies' do
      strategies = %w[eliminate random outlier]

      strategies.each do |strategy|
        clusterer = described_class.new
        clusterer.set_parameters(on_empty: strategy, max_iterations: 10)

        expect do
          clusterer.build(simple_clusters_dataset, 8) # Force empty clusters
        end.not_to raise_error

        expect(clusterer.clusters).to be_an(Array)
      end
    end

    it 'maintains state consistency' do
      clusterer = described_class.new.build(simple_clusters_dataset, 3)

      # Multiple evaluations should be consistent
      test_point = [5.0, 5.0]
      result1 = clusterer.eval(test_point)
      result2 = clusterer.eval(test_point)

      expect(result1).to eq(result2)
    end

    it 'clusters are valid and complete' do
      clusterer = described_class.new.build(simple_clusters_dataset, 3)

      # All clusters should be valid
      assert_valid_clusters(clusterer.clusters, clusterer.number_of_clusters)

      # All original points should be assigned to exactly one cluster
      total_points = clusterer.clusters.sum { |c| c.data_items.length }
      expect(total_points).to eq(simple_clusters_data.length)
    end
  end

  # Helper methods for assertions
  def assert_valid_clusters(clusters, expected_count)
    expect(clusters).to be_an(Array)
    expect(clusters.length).to be <= expected_count
    expect(clusters.length).to be > 0

    clusters.each do |cluster|
      expect(cluster.data_items).to be_an(Array)
      expect(cluster.data_items).not_to be_empty
    end
  end

  def assert_cluster_assignment(point, clusters)
    # Point should be in exactly one cluster
    found_in_clusters = 0
    clusters.each do |cluster|
      found_in_clusters += 1 if cluster.data_items.include?(point)
    end
    expect(found_in_clusters).to eq(1)
  end

  def assert_centroids_stable(old_centroids, new_centroids, epsilon = 0.001)
    expect(old_centroids.length).to eq(new_centroids.length)

    old_centroids.zip(new_centroids).each do |old, new|
      distance = old.zip(new).sum { |a, b| (a - b)**2 }**0.5
      expect(distance).to be < epsilon
    end
  end
end
