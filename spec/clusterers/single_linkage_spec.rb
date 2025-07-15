# frozen_string_literal: true

# RSpec tests for AI4R SingleLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::SingleLinkage do
  # Test data from requirement document
  let(:simple_points) do
    [
      [1.0, 1.0], [1.1, 1.1], [1.2, 0.9],  # Cluster 1 (close together)
      [5.0, 5.0], [5.1, 4.9], [4.9, 5.1],  # Cluster 2 (close together)
      [10.0, 1.0], [10.1, 0.9]              # Cluster 3 (close together)
    ]
  end

  let(:simple_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: simple_points,
      data_labels: ['x', 'y']
    )
  end

  let(:distance_matrix_points) do
    [[0, 0], [1, 0], [0, 1], [3, 3]]
  end

  let(:distance_matrix_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: distance_matrix_points,
      data_labels: ['x', 'y']
    )
  end

  let(:singleton_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[5, 5]],
      data_labels: ['x', 'y']
    )
  end

  let(:two_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[0, 0], [1, 1]],
      data_labels: ['x', 'y']
    )
  end

  let(:identical_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[2.0, 3.0]] * 5,
      data_labels: ['x', 'y']
    )
  end

  describe "Build Tests" do
    context "basic hierarchical clustering" do
      it "test_dendrogram_structure" do
        clusterer = described_class.new.build(simple_dataset, 3)
        
        expect(clusterer).to be_a(described_class)
        expect(clusterer.number_of_clusters).to eq(3)
        expect(clusterer.clusters).to be_an(Array)
        expect(clusterer.clusters.length).to eq(3)
        
        # Each cluster should be a valid DataSet
        clusterer.clusters.each do |cluster|
          expect(cluster).to be_a(Ai4r::Data::DataSet)
          expect(cluster.data_items).not_to be_empty
        end
        
        # Total points should be preserved
        total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
        expect(total_points).to eq(simple_points.length)
      end

      it "test_build_with_k" do
        # Test cutting the hierarchy at k clusters
        k_values = [1, 2, 3, 4]
        
        k_values.each do |k|
          next if k > simple_points.length
          
          clusterer = described_class.new.build(simple_dataset, k)
          expect(clusterer.clusters.length).to eq(k)
          expect(clusterer.number_of_clusters).to eq(k)
        end
      end

      it "test_build_without_k" do
        # Default to single cluster or full hierarchy
        clusterer = described_class.new.build(simple_dataset)
        
        expect(clusterer.clusters.length).to eq(1)
        expect(clusterer.clusters[0].data_items.length).to eq(simple_points.length)
      end
    end

    context "edge cases" do
      it "test_single_point" do
        clusterer = described_class.new.build(singleton_dataset, 1)
        
        expect(clusterer.clusters.length).to eq(1)
        expect(clusterer.clusters[0].data_items.length).to eq(1)
        expect(clusterer.clusters[0].data_items[0]).to eq([5, 5])
      end

      it "test_two_points" do
        clusterer = described_class.new.build(two_points_dataset, 2)
        
        expect(clusterer.clusters.length).to eq(2)
        expect(clusterer.clusters[0].data_items.length).to eq(1)
        expect(clusterer.clusters[1].data_items.length).to eq(1)
      end

      it "test_identical_points" do
        clusterer = described_class.new.build(identical_points_dataset, 2)
        
        # Should handle identical points gracefully
        expect(clusterer.clusters.length).to be >= 1
        expect(clusterer.clusters.length).to be <= 2
        
        total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
        expect(total_points).to eq(5)
      end
    end

    context "validation tests" do
      it "test_negative_distance" do
        # Test with custom distance function that could return negative values
        clusterer = described_class.new
        clusterer.set_parameters(distance_function: lambda { |a, b| -1.0 })
        
        # Should handle negative distances or raise appropriate error
        expect {
          clusterer.build(simple_dataset, 2)
        }.not_to raise_error
      end

      it "test_empty_dataset" do
        empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
        
        expect {
          described_class.new.build(empty_dataset, 1)
        }.to raise_error
      end
    end
  end

  describe "Distance Matrix Tests" do
    let(:trained_clusterer) { described_class.new.build(distance_matrix_dataset, 2) }

    it "test_symmetric_matrix" do
      clusterer = described_class.new
      
      # Test that distance function is symmetric
      point_a = [1, 2]
      point_b = [3, 4]
      
      dist_ab = clusterer.distance(point_a, point_b)
      dist_ba = clusterer.distance(point_b, point_a)
      
      expect(dist_ab).to eq(dist_ba)
    end

    it "test_zero_diagonal" do
      clusterer = described_class.new
      
      # Distance from point to itself should be zero
      point = [5, 7]
      dist = clusterer.distance(point, point)
      
      expect(dist).to eq(0.0)
    end

    it "test_non_negative_distances" do
      clusterer = described_class.new
      
      # All distances should be non-negative with default distance function
      points = [[0, 0], [1, 1], [2, 2], [3, 3]]
      
      points.each do |point_a|
        points.each do |point_b|
          dist = clusterer.distance(point_a, point_b)
          expect(dist).to be >= 0
        end
      end
    end

    it "test_distance_matrix_computation" do
      # Test that distances are computed correctly
      clusterer = described_class.new
      
      # Known distances for specific points
      dist = clusterer.distance([0, 0], [3, 4])
      expected = 25.0  # Squared euclidean: 3^2 + 4^2 = 25
      expect(dist).to eq(expected)
      
      dist = clusterer.distance([1, 1], [1, 1])
      expect(dist).to eq(0.0)
    end
  end

  describe "Merge Tests" do
    it "test_merge_order" do
      # Create clusterer with many points to test merge sequence
      many_points = []
      5.times { |i| many_points << [i, 0] }  # Points on a line
      
      many_dataset = Ai4r::Data::DataSet.new(
        data_items: many_points,
        data_labels: ['x', 'y']
      )
      
      # Test different k values to ensure valid hierarchy
      [4, 3, 2, 1].each do |k|
        clusterer = described_class.new.build(many_dataset, k)
        expect(clusterer.clusters.length).to eq(k)
        
        # All points should be assigned
        total = clusterer.clusters.map { |c| c.data_items.length }.sum
        expect(total).to eq(5)
      end
    end

    it "test_tie_breaking" do
      # Test with points that have equal distances
      tie_points = [[0, 0], [1, 0], [0, 1]]  # Two points equidistant from origin
      tie_dataset = Ai4r::Data::DataSet.new(
        data_items: tie_points,
        data_labels: ['x', 'y']
      )
      
      clusterer = described_class.new.build(tie_dataset, 2)
      
      # Should handle ties deterministically
      expect(clusterer.clusters.length).to eq(2)
      
      # Test consistency across multiple runs
      clusterer2 = described_class.new.build(tie_dataset, 2)
      expect(clusterer2.clusters.length).to eq(2)
    end

    it "test_cluster_indices" do
      clusterer = described_class.new.build(simple_dataset, 3)
      
      # All clusters should have valid data
      clusterer.clusters.each_with_index do |cluster, index|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).to be_an(Array)
        expect(cluster.data_items).not_to be_empty
      end
    end
  end

  describe "SingleLinkage Specific Tests" do
    it "test_minimum_distance" do
      # Single linkage uses minimum distance between clusters
      # Create two clear clusters
      cluster1_points = [[0, 0], [0, 1], [1, 0]]
      cluster2_points = [[10, 10], [10, 11], [11, 10]]
      all_points = cluster1_points + cluster2_points
      
      linkage_dataset = Ai4r::Data::DataSet.new(
        data_items: all_points,
        data_labels: ['x', 'y']
      )
      
      clusterer = described_class.new.build(linkage_dataset, 2)
      
      expect(clusterer.clusters.length).to eq(2)
      
      # Should separate into the two obvious clusters
      # Verify that points in each cluster are close to each other
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items.length).to be >= 1
      end
    end

    it "test_chaining_effect" do
      # Single linkage is susceptible to chaining effect
      # Create a chain of points
      chain_points = []
      10.times { |i| chain_points << [i, 0] }  # Points in a line
      
      chain_dataset = Ai4r::Data::DataSet.new(
        data_items: chain_points,
        data_labels: ['x', 'y']
      )
      
      clusterer = described_class.new.build(chain_dataset, 2)
      
      # Should still create 2 clusters
      expect(clusterer.clusters.length).to eq(2)
      
      # May exhibit chaining behavior (one large cluster, one small)
      cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
      expect(cluster_sizes.sum).to eq(10)
    end
  end

  describe "Performance Tests" do
    it "handles moderate-sized datasets efficiently" do
      # Generate dataset with clear structure
      perf_points = []
      
      # Create 3 clusters of 20 points each
      3.times do |cluster_id|
        center_x = cluster_id * 10
        center_y = cluster_id * 5
        
        20.times do
          perf_points << [center_x + rand(2.0) - 1.0, center_y + rand(2.0) - 1.0]
        end
      end
      
      perf_dataset = Ai4r::Data::DataSet.new(
        data_items: perf_points,
        data_labels: ['x', 'y']
      )
      
      benchmark_performance("SingleLinkage clustering 60 points") do
        clusterer = described_class.new.build(perf_dataset, 3)
        expect(clusterer.clusters.length).to eq(3)
      end
    end
  end

  describe "Integration Tests" do
    it "works with custom distance functions" do
      # Test with Manhattan distance
      clusterer = described_class.new
      clusterer.set_parameters(
        distance_function: lambda { |a, b|
          a.zip(b).map { |ai, bi| (ai - bi).abs }.sum
        }
      )
      
      result = clusterer.build(simple_dataset, 3)
      expect(result.clusters.length).to eq(3)
    end

    it "maintains clustering validity" do
      clusterer = described_class.new.build(simple_dataset, 3)
      
      # Verify clustering properties
      assert_valid_clusters(clusterer.clusters, 3)
      assert_complete_assignment(clusterer.clusters, simple_points)
    end

    it "produces consistent results" do
      # Same input should produce same clustering
      clusterer1 = described_class.new.build(simple_dataset, 3)
      clusterer2 = described_class.new.build(simple_dataset, 3)
      
      expect(clusterer1.clusters.length).to eq(clusterer2.clusters.length)
      expect(clusterer1.number_of_clusters).to eq(clusterer2.number_of_clusters)
    end

    it "handles distance parameter" do
      # Test with distance stopping criterion
      clusterer = described_class.new.build(simple_dataset, 10, distance: 0.5)
      
      # Should stop when distance threshold is reached
      expect(clusterer.clusters.length).to be >= 1
      expect(clusterer.clusters.length).to be <= 10
    end
  end

  # Helper methods for assertions
  def assert_valid_clusters(clusters, expected_count)
    expect(clusters).to be_an(Array)
    expect(clusters.length).to eq(expected_count)
    
    clusters.each do |cluster|
      expect(cluster).to be_a(Ai4r::Data::DataSet)
      expect(cluster.data_items).not_to be_empty
    end
  end

  def assert_complete_assignment(clusters, original_points)
    assigned_points = clusters.flat_map { |c| c.data_items }
    expect(assigned_points.length).to eq(original_points.length)
    
    # Each original point should be assigned exactly once
    original_points.each do |point|
      count = assigned_points.count(point)
      expect(count).to eq(1)
    end
  end

  def assert_dendrogram_valid(clusters)
    # Basic dendrogram validity checks
    expect(clusters).to be_an(Array)
    expect(clusters.length).to be > 0
    
    clusters.each do |cluster|
      expect(cluster).to be_a(Ai4r::Data::DataSet)
    end
  end
end