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
    # With average linkage, the distance between two clusters is computed as 
    # the average distance between elements of each cluster.
    #
    #   D(cx, (ci U cj) = (D(cx, ci) + D(cx, cj)) / 2
    class AverageLinkage < SingleLinkage
      
      parameters_info :distance_function => 
          "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance bewteen them. By default, this algorithm uses " + 
          "ecuclidean distance of numeric attributes to the power of 2."
      
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
      
      # return distance between cluster cx and new cluster (ci U cj),
      # using average linkage
      def linkage_distance(cx, ci, cj)
        (read_distance_matrix(cx, ci)+
          read_distance_matrix(cx, cj))/2
      end
      
      def distance_between_item_and_cluster(data_item, cluster)
        dist_sum = 0.0
        cluster.data_items.each do |another_item|
          dist_sum += @distance_function.call(data_item, another_item)
        end
        return dist_sum/cluster.data_items.length
      end
      
    end
  end
end
