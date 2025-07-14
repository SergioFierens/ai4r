# frozen_string_literal: true

require 'ai4r'
require 'dendrograms'

include Ai4r::Clusterers
include Ai4r::Data

points = [[0, 0], [0, 1], [1, 0], [1, 1]]
data = DataSet.new(data_items: points)

clusterer = WardLinkage.new.build(data, 1)

# Convert stored tree to a simple array of point sets
steps = clusterer.cluster_tree.map do |clusters|
  clusters.map(&:data_items)
end

Dendrograms::Dendrogram.new(steps).draw('dendrogram.png')
puts 'Dendrogram saved to dendrogram.png'
