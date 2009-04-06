# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
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
          "distance bewteen them. By default, this algorithm uses " + 
          "ecuclidean distance of numeric attributes to the power of 2."
      
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
        @clusters = [@data_set]
        
        while(@clusters.length < @number_of_clusters)
          cluster_index_to_split = max_diameter_cluster(@clusters)
          cluster_to_split = @clusters[cluster_index_to_split]
          splinter_group = init_splinter_group(cluster_to_split)
          while true
            index, max_distance_diff = max_distance_difference(cluster_to_split, splinter_group)
            break if max_distance_diff < 0
            splinter_group << cluster_to_split.data_item[index]
            cluster_to_split.data_item.delete_at(index)
          end
          @clusters << splinter_group
        end
        
        #TODO
        
        return self
      end
      
      # Classifies the given data item, returning the cluster index it belongs 
      # to (0-based).
      def eval(data_item)
        #TODO
      end
      
      protected
      
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
      
      def init_splinter_group(cluster_to_split)
        max = 0.0
        max_index = 0
        cluster_to_split.data_items.each_with_index do |item_a, index_a|
          sum = 0.0
          cluster_to_split.data_items.each_with_index do |item_b, index_b|
            sum += @distance_function.call(item_a, item_b) if index_a != index_b
          end  
          if sum > max
            max = sum 
            max_index = index_a 
          end
        end
        splinter_group = cluster_to_split[max_index]
        cluster_to_split.data_items.delete_at(max_index)
        return splinter_group
      end
      
      def max_distance_difference(cluster_to_split, splinter_group)
        distance_diffs = []
        cluster_to_split.each_with_index do |item, index|
          own_cluster_dist = cluster_to_split.inject(0) do |sum, item_b|
            sum+@distance_function.call(item_a, item_b) 
          end
          own_cluster_dist /= (cluster_to_split.length-1)
          #TODO
        end
      end
      
    end
  end
end
