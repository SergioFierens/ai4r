# frozen_string_literal: true

# Example showcasing DBSCAN clustering with custom parameters.
require 'ai4r'

points = [
  [1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3],
  [8, 8], [8, 9], [8, 10], [9, 8], [9, 9], [9, 10],
  [5, 5], [1, 9], [10, 0]
]
set = Ai4r::Data::DataSet.new(data_items: points)

clusterer = Ai4r::Clusterers::DBSCAN.new
clusterer.set_parameters(epsilon: 10, min_points: 2).build(set)

pp clusterer.labels
pp clusterer.clusters.map(&:data_items)
