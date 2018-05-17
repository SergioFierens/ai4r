# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../data/proximity'
require File.dirname(__FILE__) + '/../clusterers/clusterer'

module Ai4r
  module Clusterers
     
    # DIANA (Divisive ANAlysis) (Kaufman and Rousseeuw, 1990; 
    # Macnaughton - Smith et al. 1964) is a Divisive Hierarchical
    # Clusterer. It begins with only one cluster with all data items,
    # and divides the clusters until the desired clusters number is reached.
    class Diana < Clusterer
      
      attr_reader :data_set, :number_of_clusters, :clusters
      
      parameters_info :distance_function => 
          "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance between them. By default, this algorithm uses " + 
          "euclidean distance of numeric attributes to the power of 2."
      
      def initialize
        @distance_function = lambda do |a,b| 
            Ai4r::Data::Proximity.squared_euclidean_distance(
              a.select {|att_a| att_a.is_a? Numeric} , 
              b.select {|att_b| att_b.is_a? Numeric})
          end
      end
      
      # Build a new clusterer, using divisive analysis (DIANA algorithm)
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        @clusters = [@data_set[0..-1]]
        
        while(@clusters.length < @number_of_clusters)
          cluster_index_to_split = max_diameter_cluster(@clusters)
          cluster_to_split = @clusters[cluster_index_to_split]
          splinter_cluster = init_splinter_cluster(cluster_to_split)
          while true
            dist_diff, index = max_distance_difference(cluster_to_split, splinter_cluster)
            break if dist_diff < 0
            splinter_cluster << cluster_to_split.data_items[index]
            cluster_to_split.data_items.delete_at(index)
          end
          @clusters << splinter_cluster
        end
       
        return self
      end
      
      # Classifies the given data item, returning the cluster index it belongs 
      # to (0-based).
      def eval(data_item)
        get_min_index(@clusters.collect do |cluster|
          distance_sum(data_item, cluster) / cluster.data_items.length
          end)
      end
      
      protected
      
      # return the cluster with max diameter
      def max_diameter_cluster(clusters)
        max_index = 0
        max_diameter = 0
        clusters.each_with_index do |cluster, index|
          diameter = cluster_diameter(cluster)
          if diameter > max_diameter
            max_index = index
            max_diameter = diameter
          end
        end
        return max_index
      end
      
      # Max distance between 2 items in a cluster
      def cluster_diameter(cluster)
        diameter = 0
        cluster.data_items.each_with_index do |item_a, item_a_pos|
          item_a_pos.times do |item_b_pos|
            d = @distance_function.call(item_a, cluster.data_items[item_b_pos])
            diameter = d if d > diameter
          end
        end
        return diameter
      end
      
      # Create a cluster with the item with mx distance
      # to the rest of the cluster's items.
      # That item is removed from the initial cluster.
      def init_splinter_cluster(cluster_to_split)
        max = 0.0
        max_index = 0
        cluster_to_split.data_items.each_with_index do |item, index|
          sum = distance_sum(item, cluster_to_split)
          max, max_index = sum, index if sum > max
        end
        splinter_cluster = cluster_to_split[max_index]
        cluster_to_split.data_items.delete_at(max_index)
        return splinter_cluster
      end
      
      # Return the max average distance between any item of 
      # cluster_to_split and the rest of items in that cluster,
      # minus the average distance with the items of splinter_cluster,
      # and the index of the item.
      # A positive value means that the items is closer to the
      # splinter group than to its current cluster.
      def max_distance_difference(cluster_to_split, splinter_cluster)
        max_diff = -1.0/0
        max_diff_index = 0
        cluster_to_split.data_items.each_with_index do |item, index|
          dist_a = distance_sum(item, cluster_to_split) / (cluster_to_split.data_items.length-1)
          dist_b = distance_sum(item, splinter_cluster) / (splinter_cluster.data_items.length)
          dist_diff = dist_a - dist_b
          max_diff, max_diff_index = dist_diff, index if dist_diff > max_diff
        end
        return max_diff, max_diff_index
      end
      
      # Sum up the distance between an item and all the items in a cluster
      def distance_sum(item_a, cluster)
        cluster.data_items.inject(0.0) do |sum, item_b|
          sum + @distance_function.call(item_a, item_b)
        end
      end
      
    end
  end
end
