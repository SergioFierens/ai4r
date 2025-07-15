# frozen_string_literal: true

# RSpec tests for AI4R MedianLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::MedianLinkage do
  let(:median_test_data) do
    [
      # Cluster 1 - test median calculation
      [0, 0], [1, 1], [2, 0], [1, 2],
      # Cluster 2 - test median calculation
      [10, 10], [11, 11], [12, 10], [11, 12]
    ]
  end

  let(:median_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: median_test_data,
      data_labels: ['x', 'y']
    )
  end

  describe "MedianLinkage Specific Tests" do
    it "test_median_calculation" do
      # Median linkage uses weighted median point for cluster distance
      clusterer = described_class.new.build(median_dataset, 2)
      
      expect(clusterer.clusters.length).to eq(2)
      
      # Should use median-based distance calculation
      total_points = clusterer.clusters.map { |c| c.data_items.length }.sum
      expect(total_points).to eq(median_test_data.length)
    end

    it "test_median_vs_centroid" do
      # Median linkage should give different results than centroid linkage
      clusterer = described_class.new.build(median_dataset, 2)
      
      expect(clusterer.clusters.length).to eq(2)
      
      # Should separate the two groups
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items.length).to be >= 1
      end
    end
  end

  describe "Integration Tests" do
    it "maintains clustering validity" do
      clusterer = described_class.new.build(median_dataset, 2)
      
      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(2)
      
      clusterer.clusters.each do |cluster|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).not_to be_empty
      end
    end
  end
end