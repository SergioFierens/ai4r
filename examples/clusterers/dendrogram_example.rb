# frozen_string_literal: true

require 'ai4r'
require 'dendrograms'

points = [[0, 0], [0, 1], [1, 0], [1, 1]]
data = Ai4r::Data::DataSet.new(data_items: points)

clusterer = Ai4r::Clusterers::WardLinkage.new.build(data, 1)

# Convert stored tree to a simple array of point sets
steps = clusterer.cluster_tree.map do |clusters|
  clusters.map(&:data_items)
end

Dendrograms::Dendrogram.new(steps).draw('dendrogram.png')
puts 'Dendrogram saved to dendrogram.png'
