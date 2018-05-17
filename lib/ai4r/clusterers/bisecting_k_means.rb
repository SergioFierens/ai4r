# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../clusterers/k_means'

module Ai4r
  module Clusterers
     
    # The Bisecting k-means algorithm is a variation of the "k-means" algorithm,
    # somewhat less sensitive to the initial election of centroids than the
    # original. 
    # 
    # More about K Means algorithm:
    # http://en.wikipedia.org/wiki/K-means_algorithm   
    class BisectingKMeans < KMeans
      
      attr_reader :data_set, :number_of_clusters, :clusters, :centroids
      attr_accessor :max_iterations, :distance_function, :refine
      
      parameters_info :max_iterations => "Maximum number of iterations to " + 
        "build the clusterer. By default it is uncapped.",
        :distance_function => "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance between them. By default, this algorithm uses " + 
          "euclidean distance of numeric attributes to the power of 2.",
        :centroid_function => "Custom implementation to calculate the " +
          "centroid of a cluster. It must be a closure receiving an array of " +
          "data sets, and return an array of data items, representing the " + 
          "centroids of for each data set. " +
          "By default, this algorithm returns a data items using the mode "+
          "or mean of each attribute on each data set.",
        :refine => "Boolean value. True by default. It will run the " +
            "classic K Means algorithm, using as initial centroids the " +
            "result of the bisecting approach."
      
      
      def intialize
        @refine = true
      end
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        
        @clusters = [@data_set]
        @centroids = [@data_set.get_mean_or_mode]
        while @clusters.length < @number_of_clusters
          biggest_cluster_index = find_biggest_cluster_index(@clusters)
          clusterer = KMeans.new.
            set_parameters(get_parameters).
            build(@clusters[biggest_cluster_index], 2)
          @clusters.delete_at(biggest_cluster_index)
          @centroids.delete_at(biggest_cluster_index)
          @clusters.concat(clusterer.clusters)
          @centroids.concat(clusterer.centroids)
        end
        
        super if @refine
        
        return self
      end      
      
      protected      
      def calc_initial_centroids
        @centroids # Use existing centroids
      end
      
      def find_biggest_cluster_index(clusters)
        max_index = 0
        max_length = 0
        clusters.each_index do |cluster_index|
          cluster = clusters[cluster_index]
          if max_length < cluster.data_items.length
            max_length = cluster.data_items.length
            max_index = cluster_index
          end
        end
        return max_index
      end
      
    end
  end
end
