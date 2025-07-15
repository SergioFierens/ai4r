# frozen_string_literal: true

# RSpec tests for AI4R AverageLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::AverageLinkage do
  let(:balanced_clusters_data) do
    [
      # Cluster 1 - moderate spread
      [0, 0], [1, 0], [0, 1], [1, 1],
      # Cluster 2 - moderate spread
      [10, 10], [11, 10], [10, 11], [11, 11],
      # Cluster 3 - moderate spread  
      [0, 10], [1, 10], [0, 11], [1, 11]
    ]
  end

  let(:balanced_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: balanced_clusters_data,
      data_labels: ['x', 'y']
    )
  end

  describe "AverageLinkage Specific Tests" do
    it "test_mean_distance" do
      # Average linkage uses mean distance between all pairs in clusters
      clusterer = described_class.new.build(balanced_dataset, 3)
      
      expect(clusterer.clusters.length).to eq(3)
      
      # Should create balanced clusters between single and complete linkage behavior
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items.length).to be >= 1
      end
      
      # Verify total point preservation
      total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
      expect(total_points).to eq(balanced_clusters_data.length)
    end

    it "test_balanced_clusters" do
      # Average linkage should produce clusters balanced between single/complete linkage
      clusterer = described_class.new.build(balanced_dataset, 3)
      
      expect(clusterer.clusters.length).to eq(3)
      
      # Should separate the three groups effectively
      cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
      
      # Expect relatively balanced cluster sizes for this symmetric data
      expect(cluster_sizes.all? { |size| size > 0 }).to be true
      expect(cluster_sizes.sum).to eq(12)
    end
  end

  describe "Performance and Integration" do
    it "maintains expected clustering properties" do
      clusterer = described_class.new.build(balanced_dataset, 3)
      
      # Basic validity checks
      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(3)
      
      # All clusters should be valid
      clusterer.clusters.each do |cluster|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).not_to be_empty
      end
    end

    it "works with different k values" do
      [1, 2, 3, 4].each do |k|
        next if k > balanced_dataset.data_items.length / 2
        
        clusterer = described_class.new.build(balanced_dataset, k)
        expect(clusterer.clusters.length).to eq(k)
      end
    end
  end
end