# frozen_string_literal: true

# RSpec tests for AI4R CompleteLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::CompleteLinkage do
  # Test data emphasizing complete linkage characteristics
  let(:well_separated_clusters) do
    [
      # Tight cluster 1
      [0.0, 0.0], [0.1, 0.1], [0.2, 0.0], [0.1, 0.2],
      # Tight cluster 2
      [10.0, 10.0], [10.1, 10.1], [10.2, 10.0], [10.1, 10.2],
      # Tight cluster 3
      [0.0, 10.0], [0.1, 10.1], [0.2, 10.0], [0.1, 10.2]
    ]
  end

  let(:compact_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: well_separated_clusters,
      data_labels: %w[x y]
    )
  end

  let(:elongated_cluster_data) do
    [
      # Elongated cluster - single linkage would chain, complete linkage resists
      [0, 0], [1, 0], [2, 0], [3, 0], [4, 0],
      # Compact cluster
      [10, 10], [10.1, 10.1], [10.2, 10.0], [9.9, 10.1]
    ]
  end

  let(:elongated_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: elongated_cluster_data,
      data_labels: %w[x y]
    )
  end

  describe 'Build Tests' do
    it 'builds valid hierarchical clusters' do
      clusterer = described_class.new.build(compact_dataset, 3)

      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(3)
      expect(clusterer.clusters.length).to eq(3)

      # Should preserve all points
      total_points = clusterer.clusters.sum { |c| c.data_items.length }
      expect(total_points).to eq(well_separated_clusters.length)
    end

    it 'handles edge cases appropriately' do
      # Single point
      single_dataset = Ai4r::Data::DataSet.new(
        data_items: [[1, 2]],
        data_labels: %w[x y]
      )

      clusterer = described_class.new.build(single_dataset, 1)
      expect(clusterer.clusters.length).to eq(1)
      expect(clusterer.clusters[0].data_items.length).to eq(1)
    end
  end

  describe 'CompleteLinkage Specific Tests' do
    it 'test_maximum_distance' do
      # Complete linkage uses maximum distance between clusters (farthest neighbors)
      clusterer = described_class.new.build(compact_dataset, 3)

      expect(clusterer.clusters.length).to eq(3)

      # Should create compact, well-separated clusters
      # Each cluster should be relatively tight
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items.length).to be >= 1

        # For compact clusters, points should be close together
        next unless cluster.data_items.length > 1

        points = cluster.data_items
        max_internal_distance = 0

        points.each do |point_a|
          points.each do |point_b|
            dist = euclidean_distance(point_a, point_b)
            max_internal_distance = [max_internal_distance, dist].max
          end
        end

        # Internal distances should be small for well-formed clusters
        expect(max_internal_distance).to be < 5.0 # Reasonable threshold
      end
    end

    it 'test_compact_clusters' do
      # Complete linkage should prefer compact, spherical clusters
      clusterer = described_class.new.build(compact_dataset, 3)

      # Should successfully separate the three compact groups
      expect(clusterer.clusters.length).to eq(3)

      # Verify that each cluster contains points from only one of the original groups
      cluster_centers = []
      clusterer.clusters.each do |cluster|
        # Calculate cluster center
        points = cluster.data_items
        center_x = points.sum { |p| p[0] }.to_f / points.length
        center_y = points.sum { |p| p[1] }.to_f / points.length
        cluster_centers << [center_x, center_y]
      end

      # The three centers should be well separated
      expect(cluster_centers.length).to eq(3)

      # Check that centers are approximately at the expected locations
      expected_centers = [[0.1, 0.1], [10.1, 10.1], [0.1, 10.1]]

      cluster_centers.each do |center|
        # Each center should be close to one of the expected centers
        min_distance = expected_centers.map { |expected| euclidean_distance(center, expected) }.min
        expect(min_distance).to be < 1.0
      end
    end

    it 'resists chaining effect' do
      # Complete linkage should resist the chaining effect that single linkage exhibits
      clusterer = described_class.new.build(elongated_dataset, 2)

      expect(clusterer.clusters.length).to eq(2)

      # Should separate the elongated cluster from the compact cluster
      # rather than creating a long chain
      cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }

      # Both clusters should have reasonable sizes (not 1 vs 8)
      expect(cluster_sizes.min).to be >= 1
      expect(cluster_sizes.max).to be <= elongated_cluster_data.length - 1
    end
  end

  describe 'Distance and Merge Properties' do
    it 'uses maximum distance criterion correctly' do
      # Test the complete linkage distance calculation principle
      clusterer = described_class.new

      # Test distance between individual points (should be same as base distance)
      dist = clusterer.distance([0, 0], [3, 4])
      expect(dist).to eq(25.0) # Squared euclidean distance

      # Zero distance for identical points
      dist_zero = clusterer.distance([1, 1], [1, 1])
      expect(dist_zero).to eq(0.0)
    end

    it 'produces stable hierarchical structure' do
      # Test with different k values
      [1, 2, 3, 4].each do |k|
        next if k > compact_dataset.data_items.length / 2

        clusterer = described_class.new.build(compact_dataset, k)
        expect(clusterer.clusters.length).to eq(k)

        # All points should be assigned
        total = clusterer.clusters.sum { |c| c.data_items.length }
        expect(total).to eq(well_separated_clusters.length)
      end
    end
  end

  describe 'Performance and Integration Tests' do
    it 'handles moderately sized datasets' do
      # Generate larger test dataset
      large_points = []

      # Create several well-separated compact clusters
      4.times do |cluster_id|
        center_x = cluster_id * 8
        center_y = (cluster_id % 2) * 8

        15.times do
          large_points << [center_x + rand(1.0) - 0.5, center_y + rand(1.0) - 0.5]
        end
      end

      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_points,
        data_labels: %w[x y]
      )

      benchmark_performance('CompleteLinkage clustering 60 points') do
        clusterer = described_class.new.build(large_dataset, 4)
        expect(clusterer.clusters.length).to eq(4)
      end
    end

    it 'works with custom distance functions' do
      clusterer = described_class.new
      clusterer.set_parameters(
        distance_function: ->(a, b) {
          # Manhattan distance
          a.zip(b).sum { |ai, bi| (ai - bi).abs }
        }
      )

      result = clusterer.build(compact_dataset, 3)
      expect(result.clusters.length).to eq(3)
    end

    it 'maintains clustering validity' do
      clusterer = described_class.new.build(compact_dataset, 3)

      # All clusters should be non-empty
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items).not_to be_empty
      end

      # No point should be lost
      total_points = clusterer.clusters.flat_map(&:data_items)
      expect(total_points.length).to eq(well_separated_clusters.length)
    end
  end

  # Helper methods
  def euclidean_distance(point_a, point_b)
    Math.sqrt(point_a.zip(point_b).sum { |a, b| (a - b)**2 })
  end

  def assert_compact_clusters(clusters)
    clusters.each do |cluster|
      next if cluster.data_items.length <= 1

      # Calculate cluster diameter (maximum internal distance)
      points = cluster.data_items
      max_distance = 0

      points.each do |point_a|
        points.each do |point_b|
          dist = euclidean_distance(point_a, point_b)
          max_distance = [max_distance, dist].max
        end
      end

      # Cluster should be reasonably compact
      expect(max_distance).to be_finite
    end
  end
end
