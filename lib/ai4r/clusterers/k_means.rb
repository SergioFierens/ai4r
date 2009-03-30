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
     
    # The k-means algorithm is an algorithm to cluster n objects 
    # based on attributes into k partitions, with k < n.
    # 
    # More about K Means algorithm:
    # http://en.wikipedia.org/wiki/K-means_algorithm   
    class KMeans < Clusterer
      
      attr_reader :data_set, :number_of_clusters
      attr_reader :clusters, :centroids, :iterations
      
      parameters_info :max_iterations => "Maximum number of iterations to " + 
        "build the clusterer. By default it is uncapped.",
        :distance_function => "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance bewteen them. By default, this algorithm uses " + 
          "ecuclidean distance of numeric attributes to the power of 2.",
        :centroid_function => "Custom implementation to calculate the " +
          "centroid of a cluster. It must be a closure receiving an array of " +
          "data sets, and return an array of data items, representing the " + 
          "centroids of for each data set. " +
          "By default, this algorithm returns a data items using the mode "+
          "or mean of each attribute on each data set."
      
      def initialize
        @distance_function = nil
        @max_iterations = nil
        @old_centroids = nil
        @centroid_function = lambda do |data_sets| 
          data_sets.collect{ |data_set| data_set.get_mean_or_mode}
        end
      end
      
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        @iterations = 0
        
        calc_initial_centroids
        while(not stop_criteria_met)
          calculate_membership_clusters
          recompute_centroids
        end
        
        return self
      end
      
      # Classifies the given data item, returning the cluster index it belongs 
      # to (0-based).
      def eval(data_item)
        get_min_index(@centroids.collect {|centroid| 
            distance(data_item, centroid)})
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
      
      def calc_initial_centroids
        @centroids = []
        tried_indexes = []
        while @centroids.length < @number_of_clusters && 
            tried_indexes.length < @data_set.data_items.length
          random_index = rand(@data_set.data_items.length)
          if !tried_indexes.include?(random_index)
            tried_indexes << random_index
            if !@centroids.include? @data_set.data_items[random_index] 
              @centroids << @data_set.data_items[random_index] 
            end
          end
        end
        @number_of_clusters = @centroids.length
      end
      
      def stop_criteria_met
        @old_centroids == @centroids || 
          (@max_iterations && (@max_iterations <= @iterations))
      end
      
      def calculate_membership_clusters
        @clusters = Array.new(@number_of_clusters) do 
          Ai4r::Data::DataSet.new :data_labels => @data_set.data_labels
        end
        @data_set.data_items.each do |data_item|
          @clusters[eval(data_item)] << data_item
        end
      end
      
      def recompute_centroids
        @old_centroids = @centroids
        @iterations += 1
        @centroids = @centroid_function.call(@clusters) 
      end
  
    end
  end
end
