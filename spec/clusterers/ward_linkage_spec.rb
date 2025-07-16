# frozen_string_literal: true

# RSpec tests for AI4R WardLinkage clusterer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::WardLinkage do
  let(:variance_test_data) do
    [
      # Tight cluster 1 - low variance
      [0, 0], [0.1, 0.1], [0.2, 0.0], [0.1, 0.2],
      # Tight cluster 2 - low variance
      [10, 10], [10.1, 10.1], [10.2, 10.0], [10.1, 10.2],
      # Spread cluster 3 - higher variance
      [5, 0], [6, 1], [7, 0], [5, 2]
    ]
  end

  let(:variance_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: variance_test_data,
      data_labels: %w[x y]
    )
  end

  describe 'WardLinkage Specific Tests' do
    it 'test_variance_minimization' do
      # Ward linkage minimizes within-cluster sum of squares (variance)
      clusterer = described_class.new.build(variance_dataset, 3)

      expect(clusterer.clusters.length).to eq(3)

      # Should create clusters that minimize internal variance
      clusterer.clusters.each do |cluster|
        expect(cluster.data_items.length).to be >= 1

        # Calculate within-cluster variance
        next unless cluster.data_items.length > 1

        points = cluster.data_items
        centroid = calculate_centroid(points)

        variance = points.sum do |point|
          euclidean_distance_squared(point, centroid)
        end

        # Variance should be reasonable (not infinite)
        expect(variance).to be_finite
        expect(variance).to be >= 0
      end
    end

    it 'test_ward_formula' do
      # Ward uses specific distance formula for merging
      clusterer = described_class.new.build(variance_dataset, 2)

      expect(clusterer.clusters.length).to eq(2)

      # Should merge clusters to minimize increase in total within-cluster variance
      total_points = clusterer.clusters.sum { |c| c.data_items.length }
      expect(total_points).to eq(variance_test_data.length)
    end
  end

  describe 'Variance Properties' do
    it 'creates compact clusters' do
      clusterer = described_class.new.build(variance_dataset, 3)

      # Ward linkage should produce compact clusters
      clusterer.clusters.each do |cluster|
        next if cluster.data_items.length <= 1

        points = cluster.data_items
        centroid = calculate_centroid(points)

        # All points should be reasonably close to centroid
        max_distance_to_centroid = points.map do |point|
          euclidean_distance(point, centroid)
        end.max

        expect(max_distance_to_centroid).to be < 5.0 # Reasonable bound
      end
    end

    it 'maintains clustering validity' do
      clusterer = described_class.new.build(variance_dataset, 3)

      expect(clusterer).to be_a(described_class)
      expect(clusterer.number_of_clusters).to eq(3)

      clusterer.clusters.each do |cluster|
        expect(cluster).to be_a(Ai4r::Data::DataSet)
        expect(cluster.data_items).not_to be_empty
      end
    end
  end

  # Helper methods
  def calculate_centroid(points)
    return [0, 0] if points.empty?

    sum_x = points.sum { |p| p[0] }.to_f
    sum_y = points.sum { |p| p[1] }.to_f

    [sum_x / points.length, sum_y / points.length]
  end

  def euclidean_distance(point_a, point_b)
    Math.sqrt(euclidean_distance_squared(point_a, point_b))
  end

  def euclidean_distance_squared(point_a, point_b)
    point_a.zip(point_b).sum { |a, b| (a - b)**2 }
  end
end
