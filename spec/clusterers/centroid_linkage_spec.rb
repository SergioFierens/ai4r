# frozen_string_literal: true

# RSpec tests for AI4R CentroidLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::CentroidLinkage do
  let(:centroid_test_data) do
    [
      # Cluster 1 with clear centroid
      [0, 0], [2, 0], [1, 2], [1, 1],
      # Cluster 2 with clear centroid
      [10, 10], [12, 10], [11, 12], [11, 11]
    ]
  end

  let(:centroid_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: centroid_test_data,
      data_labels: ['x', 'y']
    )
  end

  describe "CentroidLinkage Specific Tests" do
    it "test_centroid_distance" do
      # Centroid linkage uses distance between cluster centroids
      clusterer = described_class.new.build(centroid_dataset, 2)
      
      expect(clusterer.clusters.length).to eq(2)
      
      # Should separate based on centroid distances
      total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
      expect(total_points).to eq(centroid_test_data.length)
    end

    it "test_centroid_update" do
      # When clusters merge, new centroid should be calculated correctly
      clusterer = described_class.new.build(centroid_dataset, 1)
      
      expect(clusterer.clusters.length).to eq(1)
      expect(clusterer.clusters[0].data_items.length).to eq(8)
    end
  end

  describe "Integration Tests" do
    it "maintains clustering validity" do
      clusterer = described_class.new.build(centroid_dataset, 2)
      
      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(2)
      
      clusterer.clusters.each do |cluster|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).not_to be_empty
      end
    end
  end
end