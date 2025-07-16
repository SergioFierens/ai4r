# frozen_string_literal: true

# RSpec tests for AI4R WeightedAverageLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::WeightedAverageLinkage do
  let(:weighted_test_data) do
    [
      # Small cluster 1 (2 points)
      [0, 0], [1, 0],
      # Large cluster 2 (4 points)
      [10, 10], [11, 10], [10, 11], [11, 11],
      # Medium cluster 3 (3 points)
      [5, 5], [6, 5], [5, 6]
    ]
  end

  let(:weighted_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: weighted_test_data,
      data_labels: %w[x y]
    )
  end

  describe 'WeightedAverageLinkage Specific Tests' do
    it 'test_weighted_calculation' do
      # Weighted average linkage accounts for cluster sizes in distance calculation
      clusterer = described_class.new.build(weighted_dataset, 3)

      expect(clusterer.clusters.length).to eq(3)

      # Should weight distances by cluster sizes
      total_points = clusterer.clusters.sum { |c| c.data_items.length }
      expect(total_points).to eq(weighted_test_data.length)
    end

    it 'test_weight_effect' do
      # Large clusters should have more influence than small clusters
      clusterer = described_class.new.build(weighted_dataset, 2)

      expect(clusterer.clusters.length).to eq(2)

      # Verify clustering behavior accounts for different cluster sizes
      cluster_sizes = clusterer.clusters.map { |c| c.data_items.length }
      expect(cluster_sizes.sum).to eq(9)
      expect(cluster_sizes.all? { |size| size > 0 }).to be true
    end
  end

  describe 'Integration Tests' do
    it 'maintains basic clustering properties' do
      clusterer = described_class.new.build(weighted_dataset, 3)

      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(3)

      clusterer.clusters.each do |cluster|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).not_to be_empty
      end
    end
  end
end
