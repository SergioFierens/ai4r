# frozen_string_literal: true

# Demonstrates recording the merge tree using WardLinkageHierarchical
# and printing a simple dendrogram.

require 'ai4r'

points = [[1, 1], [1, 2], [2, 1], [2, 2], [8, 8], [8, 9], [9, 8], [9, 9]]
data_set = Ai4r::Data::DataSet.new(data_items: points)

clusterer = Ai4r::Clusterers::WardLinkageHierarchical.new
clusterer.build(data_set, 1)

puts 'Dendrogram:'
clusterer.cluster_tree.each_with_index do |clusters, level|
  puts "Level #{level}:"
  clusters.each_with_index do |cluster, idx|
    puts "  Cluster #{idx}: #{cluster.data_items.inspect}"
  end
end
