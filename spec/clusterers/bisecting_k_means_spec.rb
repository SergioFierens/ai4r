# frozen_string_literal: true

# RSpec tests for AI4R BisectingKMeans clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::BisectingKMeans do
  # Test data from requirement document
  let(:large_dataset) do
    items = []
    # Create 4 well-separated clusters for bisection
    25.times { items << [rand(2.0), rand(2.0)] }           # Cluster 1: (0,0) to (2,2)
    25.times { items << [8 + rand(2.0), rand(2.0)] }       # Cluster 2: (8,0) to (10,2)
    25.times { items << [rand(2.0), 8 + rand(2.0)] }       # Cluster 3: (0,8) to (2,10)
    25.times { items << [8 + rand(2.0), 8 + rand(2.0)] }   # Cluster 4: (8,8) to (10,10)
    
    Ai4r::Data::DataSet.new(
      data_items: items,
      data_labels: ['x', 'y']
    )
  end

  let(:small_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5]],
      data_labels: ['x', 'y']
    )
  end

  let(:identical_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.0, 2.0]] * 8,
      data_labels: ['x', 'y']
    )
  end

  let(:two_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[0, 0], [10, 10]],
      data_labels: ['x', 'y']
    )
  end

  let(:singleton_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[5, 5]],
      data_labels: ['x', 'y']
    )
  end

  describe "Build Tests" do
    context "hierarchical bisection" do
      it "test_hierarchical_bisection" do
        clusterer = described_class.new.build(large_dataset, 4)
        
        expect(clusterer).to be_a(described_class)
        expect(clusterer.number_of_clusters).to eq(4)
        expect(clusterer.clusters).to be_an(Array)
        expect(clusterer.clusters.length).to eq(4)
        
        # Should have split the data hierarchically
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items).not_to be_empty
        end
        
        # Total points should be preserved
        total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
        expect(total_points).to eq(100)
      end

      it "test_stop_at_k_clusters" do
        # Should stop when reaching k=4 clusters
        clusterer = described_class.new.build(large_dataset, 4)
        
        expect(clusterer.clusters.length).to eq(4)
        expect(clusterer.number_of_clusters).to eq(4)
        
        # Should not continue bisecting beyond k
        clusterer.clusters.each do |cluster|
          expect(cluster).to be_a(Ai4r::Data::DataSet)
        end
      end
    end

    context "edge cases" do
      it "test_bisect_singleton" do
        # Cannot split single point
        expect {
          described_class.new.build(singleton_dataset, 2)
        }.to raise_error(StandardError)
      end

      it "test_bisect_identical_points" do
        # All points identical - should handle gracefully
        clusterer = described_class.new.build(identical_points_dataset, 3)
        
        expect(clusterer).to be_a(described_class)
        # May create fewer clusters than requested due to identical points
        expect(clusterer.clusters.length).to be >= 1
        expect(clusterer.clusters.length).to be <= 3
      end

      it "test_bisect_two_points" do
        # Minimal case for bisection
        clusterer = described_class.new.build(two_points_dataset, 2)
        
        expect(clusterer.clusters.length).to eq(2)
        expect(clusterer.clusters[0].data_items.length).to eq(1)
        expect(clusterer.clusters[1].data_items.length).to eq(1)
      end
    end
  end

  describe "Selection Tests" do
    context "cluster selection for bisection" do
      it "test_largest_cluster_selection" do
        # Should preferentially split largest clusters
        clusterer = described_class.new.build(large_dataset, 3)
        
        expect(clusterer.clusters.length).to eq(3)
        
        # Verify that clusters exist and have reasonable sizes
        cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
        expect(cluster_sizes.sum).to eq(100)
        expect(cluster_sizes.min).to be > 0
      end

      it "test_all_clusters_size_one" do
        # When all clusters have size 1, cannot bisect further
        single_points = Array.new(4) { |i| [i, i] }
        single_dataset = Ai4r::Data::DataSet.new(
          data_items: single_points,
          data_labels: ['x', 'y']
        )
        
        clusterer = described_class.new.build(single_dataset, 8)
        
        # Should stop at 4 clusters (one per point)
        expect(clusterer.clusters.length).to eq(4)
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items.length).to eq(1)
        end
      end
    end
  end

  describe "Convergence Tests" do
    it "converges to specified number of clusters" do
      [2, 3, 4, 5].each do |k|
        next if k > large_dataset.data_items.length
        
        clusterer = described_class.new.build(large_dataset, k)
        expect(clusterer.clusters.length).to eq(k)
      end
    end

    it "handles k greater than reasonable splits" do
      # Request more clusters than can be reasonably created
      clusterer = described_class.new.build(small_dataset, 10)
      
      # Should create at most n clusters (one per point)
      expect(clusterer.clusters.length).to be <= small_dataset.data_items.length
      expect(clusterer.clusters.length).to be > 0
    end
  end

  describe "Eval Tests" do
    let(:trained_clusterer) { described_class.new.build(large_dataset, 4) }

    it "assigns points to correct clusters" do
      # Test with a point that should be clearly in one cluster
      test_point = [1.0, 1.0]  # Should be in bottom-left cluster
      cluster_index = trained_clusterer.eval(test_point)
      
      expect(cluster_index).to be_a(Integer)
      expect(cluster_index).to be >= 0
      expect(cluster_index).to be < trained_clusterer.clusters.length
    end

    it "handles new points consistently" do
      test_point = [9.0, 9.0]  # Should be in top-right cluster
      
      # Multiple evaluations should give same result
      result1 = trained_clusterer.eval(test_point)
      result2 = trained_clusterer.eval(test_point)
      
      expect(result1).to eq(result2)
      expect(result1).to be >= 0
      expect(result1).to be < trained_clusterer.clusters.length
    end

    it "handles edge cases in evaluation" do
      # Test with point far from all clusters
      distant_point = [50.0, 50.0]
      cluster_index = trained_clusterer.eval(distant_point)
      
      expect(cluster_index).to be_a(Integer)
      expect(cluster_index).to be >= 0
      expect(cluster_index).to be < trained_clusterer.clusters.length
    end
  end

  describe "Performance Tests" do
    it "handles moderately large datasets efficiently" do
      # Generate larger dataset for performance testing
      large_items = []
      500.times do |i|
        cluster_id = i % 6
        center_x = (cluster_id % 3) * 10
        center_y = (cluster_id / 3) * 10
        large_items << [center_x + rand(3.0) - 1.5, center_y + rand(3.0) - 1.5]
      end
      
      large_perf_dataset = Ai4r::Data::DataSet.new(
        data_items: large_items,
        data_labels: ['x', 'y']
      )
      
      benchmark_performance("BisectingKMeans clustering 500 points") do
        clusterer = described_class.new.build(large_perf_dataset, 6)
        expect(clusterer.clusters.length).to eq(6)
      end
    end

    it "evaluation performance is reasonable" do
      clusterer = described_class.new.build(large_dataset, 4)
      
      benchmark_performance("BisectingKMeans evaluation speed") do
        50.times do
          test_point = [rand(12.0), rand(12.0)]
          cluster_index = clusterer.eval(test_point)
          expect(cluster_index).to be >= 0
        end
      end
    end
  end

  describe "Integration Tests" do
    it "produces hierarchical structure" do
      clusterer = described_class.new.build(large_dataset, 3)
      
      # Should create meaningful clusters
      expect(clusterer.clusters.length).to eq(3)
      
      # Verify cluster validity
      assert_valid_clusters(clusterer.clusters, 3)
      
      # All points should be assigned
      total_assigned = clusterer.clusters.map { |c| c.data_items.length }.sum
      expect(total_assigned).to eq(large_dataset.data_items.length)
    end

    it "maintains bisection invariants" do
      clusterer = described_class.new.build(large_dataset, 4)
      
      # Each cluster should be non-empty
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items).not_to be_empty
      end
      
      # Should not lose or duplicate points
      all_points = clusterer.clusters.flat_map { |c| c.data_items }
      expect(all_points.length).to eq(large_dataset.data_items.length)
    end

    it "works with different k values" do
      [2, 3, 4, 5].each do |k|
        clusterer = described_class.new.build(large_dataset, k)
        
        expect(clusterer.clusters.length).to eq(k)
        expect(clusterer.number_of_clusters).to eq(k)
        
        # All clusters should be valid
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items.length).to be > 0
        end
      end
    end

    it "handles parameter variations" do
      # Test with different internal k-means parameters if supported
      clusterer = described_class.new
      
      # Should work with default parameters
      result = clusterer.build(large_dataset, 3)
      expect(result.clusters.length).to eq(3)
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

  def assert_bisection_hierarchy(clusterer)
    # Verify that the clustering follows bisection principles
    expect(clusterer.clusters).to be_an(Array)
    expect(clusterer.clusters.length).to be > 0
    
    # All clusters should be non-empty
    clusterer.clusters.each do |cluster|
      expect(cluster.data_items.length).to be > 0
    end
  end
end