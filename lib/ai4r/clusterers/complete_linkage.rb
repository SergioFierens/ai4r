# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../clusterers/single_linkage'

module Ai4r
  module Clusterers
     
    # Implementation of a Hierarchical clusterer with complete linkage.
    # Hierarchical clusteres create one cluster per element, and then 
    # progressively merge clusters, until the required number of clusters
    # is reached.
    # With complete linkage, the distance between two clusters is computed as 
    # the maximum distance between elements of each cluster.
    class CompleteLinkage < SingleLinkage
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        super
      end
      
      # Classifies the given data item, returning the cluster index it belongs 
      # to (0-based).
      def eval(data_item)
        super
      end
      
      protected
      
      # Calculate cluster distance using the complete linkage method
      def calc_index_clusters_distance(cluster_a, cluster_b)
        max_dist = 0
        cluster_a.each do |index_a|
          cluster_b.each do |index_b|
            dist = read_distance_matrix(index_a, index_b)
            max_dist = dist if dist > max_dist
          end
        end
        return max_dist
      end
      
      def distance_between_item_and_cluster(data_item, cluster)
        max_dist = 0
        cluster.data_items.each do |another_item|
          dist = distance(data_item, another_item)
          max_dist = dist if dist > max_dist
        end
        return max_dist
      end
      
    end
  end
end
