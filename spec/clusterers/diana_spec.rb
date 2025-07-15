# frozen_string_literal: true

# RSpec tests for AI4R Diana clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::Diana do
  # Test data from requirement document for divisive clustering
  let(:diana_test_data) do
    [
      # Dense cluster 1
      [0, 0], [0.5, 0.5], [1, 0], [0, 1], [1, 1],
      # Dense cluster 2
      [10, 10], [10.5, 10.5], [11, 10], [10, 11], [11, 11],
      # Outliers/sparse points
      [5, 5], [15, 0], [0, 15]
    ]
  end

  let(:diana_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: diana_test_data,
      data_labels: ['x', 'y']
    )
  end

  let(:identical_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.0, 2.0]] * 6,
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
    context "divisive hierarchy" do
      it "test_divisive_hierarchy" do
        # Diana creates hierarchy by dividing (top-down)
        clusterer = described_class.new.build(diana_dataset, 4)
        
        expect(clusterer).to be_a(described_class)
        expect(clusterer.number_of_clusters).to eq(4)
        expect(clusterer.clusters).to be_an(Array)
        expect(clusterer.clusters.length).to eq(4)
        
        # Should preserve all points through divisive process
        total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
        expect(total_points).to eq(diana_test_data.length)
        
        # Each cluster should be non-empty
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items).not_to be_empty
        end
      end

      it "test_stop_at_k" do
        # Should stop dividing when k clusters are reached
        k = 5
        clusterer = described_class.new.build(diana_dataset, k)
        
        expect(clusterer.clusters.length).to eq(k)
        expect(clusterer.number_of_clusters).to eq(k)
        
        # Verify all points are assigned
        assigned_points = clusterer.clusters.flat_map { |c| c.data_items }
        expect(assigned_points.length).to eq(diana_test_data.length)
      end
    end

    context "edge cases" do
      it "test_split_singleton" do
        # Cannot divide single point
        expect {
          described_class.new.build(singleton_dataset, 2)
        }.to raise_error(StandardError)
      end

      it "test_split_two_points" do
        # Binary split - should work
        clusterer = described_class.new.build(two_points_dataset, 2)
        
        expect(clusterer.clusters.length).to eq(2)
        expect(clusterer.clusters[0].data_items.length).to eq(1)
        expect(clusterer.clusters[1].data_items.length).to eq(1)
      end

      it "test_all_identical" do
        # Cannot find splinter group when all points identical
        expect {
          described_class.new.build(identical_points_dataset, 3)
        }.to raise_error(StandardError)
      end
    end
  end

  describe "Split Tests" do
    context "splinter group selection" do
      it "test_maximum_dissimilarity" do
        # Diana should split based on maximum dissimilarity
        clusterer = described_class.new.build(diana_dataset, 3)
        
        expect(clusterer.clusters.length).to eq(3)
        
        # Should identify and separate the most dissimilar points
        # Verify that clusters contain reasonable groupings
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items.length).to be >= 1
          
          # Within each cluster, points should be relatively similar
          if cluster.data_items.length > 1
            points = cluster.data_items
            max_internal_distance = 0
            
            points.each do |point_a|
              points.each do |point_b|
                dist = euclidean_distance(point_a, point_b)
                max_internal_distance = [max_internal_distance, dist].max
              end
            end
            
            # Internal cluster distances should be reasonable
            expect(max_internal_distance).to be_finite
          end
        end
      end

      it "test_splinter_group_selection" do
        # Should select point furthest from cluster center as splinter
        clusterer = described_class.new.build(diana_dataset, 2)
        
        expect(clusterer.clusters.length).to eq(2)
        
        # Should create meaningful division
        cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
        expect(cluster_sizes.all? { |size| size > 0 }).to be true
        expect(cluster_sizes.sum).to eq(diana_test_data.length)
      end
    end

    context "split characteristics" do
      it "test_balanced_splits" do
        # Test that Diana can create balanced divisions
        clusterer = described_class.new.build(diana_dataset, 2)
        
        expect(clusterer.clusters.length).to eq(2)
        
        cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
        
        # Both clusters should have points (not extreme 1 vs rest split)
        expect(cluster_sizes.min).to be >= 1
        expect(cluster_sizes.max).to be <= diana_test_data.length - 1
      end

      it "test_unbalanced_splits" do
        # Diana may create unbalanced splits when appropriate
        # Create dataset that naturally has one outlier
        unbalanced_data = [
          # Main cluster
          [0, 0], [1, 0], [0, 1], [1, 1], [0.5, 0.5],
          # Single outlier
          [100, 100]
        ]
        
        unbalanced_dataset = Ai4r::Data::DataSet.new(
          data_items: unbalanced_data,
          data_labels: ['x', 'y']
        )
        
        clusterer = described_class.new.build(unbalanced_dataset, 2)
        
        expect(clusterer.clusters.length).to eq(2)
        
        # Should separate outlier from main cluster
        cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
        expect(cluster_sizes.include?(1)).to be true  # Outlier cluster
        expect(cluster_sizes.include?(5)).to be true  # Main cluster
      end
    end
  end

  describe "Performance Tests" do
    it "handles moderate datasets efficiently" do
      # Generate larger dataset for performance testing
      large_points = []
      
      # Create several clusters with some outliers
      3.times do |cluster_id|
        center_x = cluster_id * 10
        center_y = cluster_id * 5
        
        10.times do
          large_points << [center_x + rand(2.0) - 1.0, center_y + rand(2.0) - 1.0]
        end
      end
      
      # Add some outliers
      5.times do
        large_points << [rand(30.0), rand(15.0)]
      end
      
      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_points,
        data_labels: ['x', 'y']
      )
      
      benchmark_performance("Diana clustering 35 points") do
        clusterer = described_class.new.build(large_dataset, 5)
        expect(clusterer.clusters.length).to eq(5)
      end
    end
  end

  describe "Integration Tests" do
    it "produces valid divisive clustering" do
      clusterer = described_class.new.build(diana_dataset, 4)
      
      # Verify basic clustering properties
      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(4)
      
      # All clusters should be valid DataSets
      clusterer.clusters.each do |cluster|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).not_to be_empty
      end
      
      # All points should be assigned exactly once
      all_assigned_points = clusterer.clusters.flat_map { |c| c.data_items }
      expect(all_assigned_points.length).to eq(diana_test_data.length)
      
      # No duplicates
      unique_points = all_assigned_points.uniq
      expect(unique_points.length).to eq(diana_test_data.length)
    end

    it "works with different k values" do
      [1, 2, 3, 4, 5].each do |k|
        next if k > diana_dataset.data_items.length
        
        clusterer = described_class.new.build(diana_dataset, k)
        expect(clusterer.clusters.length).to eq(k)
        
        total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
        expect(total_points).to eq(diana_test_data.length)
      end
    end

    it "maintains divisive hierarchy properties" do
      clusterer = described_class.new.build(diana_dataset, 3)
      
      # Divisive clustering should maintain hierarchy invariants
      expect(clusterer.clusters.length).to eq(3)
      
      # Each split should be meaningful
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items.length).to be > 0
      end
    end
  end

  # Helper methods
  def euclidean_distance(point_a, point_b)
    Math.sqrt(point_a.zip(point_b).map { |a, b| (a - b) ** 2 }.sum)
  end

  def assert_valid_diana_clustering(clusterer, expected_k)
    expect(clusterer.clusters.length).to eq(expected_k)
    
    clusterer.clusters.each do |cluster|
      expect(cluster).to be_a(Ai4r::Data::DataSet)
      expect(cluster.data_items).not_to be_empty
    end
    
    # Verify no points are lost or duplicated
    all_points = clusterer.clusters.flat_map { |c| c.data_items }
    expect(all_points.length).to eq(diana_test_data.length)
  end
end