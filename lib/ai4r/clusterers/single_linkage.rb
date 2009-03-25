# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../clusterers/clusterer'

module Ai4r
  module Clusterers
     
    # Implementation of a Hierarchical clusterer with single linkage.
    # Hierarchical clusteres create one cluster per element, and then 
    # progressively merge clusters, until the required number of clusters
    # is reached.
    # With single linkage, the distance between two clusters is computed as the 
    # distance between the two closest elements in the two clusters.
    class SingleLinkage < Clusterer
      
      attr_reader :data_set, :number_of_clusters, :clusters
      
      parameters_info :distance_function => 
          "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance bewteen them. By default, this algorithm uses " + 
          "ecuclidean distance of numeric attributes to the power of 2."
      
      def initialize
        @distance_function = nil
      end
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        
        index_clusters = create_initial_index_clusters
        create_distance_matrix(data_set)
        while index_clusters.length > @number_of_clusters
          clusters_to_merge = get_closest_clusters(index_clusters)
          index_clusters = merge_clusters(clusters_to_merge, index_clusters)
        end
        @clusters = build_clusters_from_index_clusters index_clusters
        
        return self
      end
      
      # Classifies the given data item, returning the cluster index it belongs 
      # to (0-based).
      def eval(data_item)
        get_min_index(@clusters.collect {|cluster| 
            distance_between_item_and_cluster(data_item, cluster)})
      end
      
      # This function calculates the distance between 2 different
      # instances. By default, it returns the euclidean distance to the 
      # power of 2.
      # You can provide a more convinient distance implementation:
      # 
      # 1- Overwriting this method
      # 
      # 2- Providing a closure to the :distance_function parameter
      def distance(a, b)
        return @distance_function.call(a, b) if @distance_function
        return euclidean_distance(a, b)
      end
      
      protected
      
      # returns [ [0], [1], [2], ... , [n-1] ]
      # where n is the number of data items in the data set
      def create_initial_index_clusters
        index_clusters = []
        @data_set.data_items.length.times {|i| index_clusters << [i]}
        return index_clusters
      end
      
      # Create a partial distance matrix:
      #   [ 
      #     [d(1,0)], 
      #     [d(2,0)], [d(2,1)],
      #     [d(3,0)], [d(3,1)], [d(3,2)],
      #     ... 
      #     [d(n-1,0)], [d(n-1,1)], [d(n-1,2)], ... , [d(n-1,n-2)]
      #   ]
      # where n is the number of data items in the data set
      def create_distance_matrix(data_set)
        @distance_matrix = Array.new(data_set.data_items.length-1) {|index| Array.new(index+1)}      
        data_set.data_items.each_with_index do |a, i|
          i.times do |j|
            b = data_set.data_items[j]
            @distance_matrix[i-1][j] = distance(a, b)
          end
        end
      end
      
      # Returns the distance between element data_item[index_a] and
      # data_item[index_b] using the distance matrix
      def read_distance_matrix(index_a, index_b)
        return 0 if index_a == index_b
        index_a, index_b = index_b, index_a if index_b > index_a
        return @distance_matrix[index_a-1][index_b]
      end

      # clusters_to_merge = [index_cluster_a, index_cluster_b].
      # cluster_a and cluster_b are removed from index_cluster, 
      # and a new cluster with all members of cluster_a and cluster_b
      # is added. 
      # It returns the new clusters array.
      def merge_clusters(clusters_to_merge, index_clusters)
        index_a = clusters_to_merge.first
        index_b = clusters_to_merge.last
        index_a, index_b = index_b, index_a if index_b > index_a
        new_index_cluster = index_clusters[index_a] +
          index_clusters[index_b]
        index_clusters.delete_at index_a
        index_clusters.delete_at index_b
        index_clusters << new_index_cluster
        return index_clusters
      end
   
      # Given an array with clusters of data_items indexes, 
      # it returns an array of data_items clusters 
      def build_clusters_from_index_clusters(index_clusters)
        @distance_matrix = nil
        return index_clusters.collect do |index_cluster|
          Ai4r::Data::DataSet.new(:data_labels => @data_set.data_labels,
            :data_items => index_cluster.collect {|i| @data_set.data_items[i]})
        end
      end
      
      # Returns ans array with the indexes of the two closest
      # clusters => [index_cluster_a, index_cluster_b]
      def get_closest_clusters(index_clusters)
        min_distance = 1.0/0
        closest_clusters = [1, 0]
        index_clusters.each_with_index do |cluster_a, index_a|
          index_a.times do |index_b|
            cluster_b = index_clusters[index_b]
            cluster_distance = calc_index_clusters_distance(cluster_a, cluster_b)
            if cluster_distance < min_distance
              closest_clusters = [index_a, index_b]
              min_distance = cluster_distance
            end
          end
        end
        return closest_clusters
      end
      
      # Calculate cluster distance using the single linkage method
      def calc_index_clusters_distance(cluster_a, cluster_b)
        min_dist = 1.0/0
        cluster_a.each do |index_a|
          cluster_b.each do |index_b|
            dist = read_distance_matrix(index_a, index_b)
            min_dist = dist if dist < min_dist
          end
        end
        return min_dist
      end
      
      def distance_between_item_and_cluster(data_item, cluster)
        min_dist = 1.0/0
        cluster.data_items.each do |another_item|
          dist = distance(data_item, another_item)
          min_dist = dist if dist < min_dist
        end
        return min_dist
      end
      
    end
  end
end

