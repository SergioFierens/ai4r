# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../data/proximity'
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
          "distance between them. By default, this algorithm uses " + 
          "euclidean distance of numeric attributes to the power of 2.",
        :centroid_function => "Custom implementation to calculate the " +
          "centroid of a cluster. It must be a closure receiving an array of " +
          "data sets, and return an array of data items, representing the " + 
          "centroids of for each data set. " +
          "By default, this algorithm returns a data items using the mode "+
          "or mean of each attribute on each data set.",
          :centroid_indices => "Indices of data items (indexed from 0) to be " +
          "the initial centroids.  Otherwise, the initial centroids will be " +
          "assigned randomly from the data set."
      
      def initialize
        @distance_function = nil
        @max_iterations = nil
        @old_centroids = nil
        @centroid_function = lambda do |data_sets| 
          data_sets.collect{ |data_set| data_set.get_mean_or_mode}
        end
        @centroid_indices = nil
      end
      
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        raise ArgumentError, 'Length of centroid indices array differs from the specified number of clusters' unless @centroid_indices.nil? || @centroid_indices.length == @number_of_clusters
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
      # You can provide a more convenient distance implementation:
      # 
      # 1- Overwriting this method
      # 
      # 2- Providing a closure to the :distance_function parameter
      def distance(a, b)
        return @distance_function.call(a, b) if @distance_function
        return Ai4r::Data::Proximity.squared_euclidean_distance(
                 a.select {|att_a| att_a.is_a? Numeric} , 
                 b.select {|att_b| att_b.is_a? Numeric})
      end
      
      protected      
      
      def calc_initial_centroids
        @centroids = []
        tried_indexes = []
        
        if @centroid_indices.nil?
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
        else         
          centroid_indices.each do |index|
            raise ArgumentError, "Invalid centroid index #{index}" unless (index.is_a? Integer) && index >=0 && index < @data_set.data_items.length
            if !tried_indexes.include?(index)
              tried_indexes << index
              if !@centroids.include? @data_set.data_items[index] 
                @centroids << @data_set.data_items[index] 
              end
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
        consolidate_clusters if has_empty_cluster?
      end
      
      def recompute_centroids
        @old_centroids = @centroids
        @iterations += 1
        @centroids = @centroid_function.call(@clusters)
      end

      def has_empty_cluster?
        found_empty = false
        @number_of_clusters.times do |i|
          found_empty = true if @clusters[i].data_items.empty?
        end
        found_empty
      end
      
      def consolidate_clusters
        old_clusters, old_centroids = @clusters, @centroids
        @clusters, @centroids = [],[] 
        @number_of_clusters.times do |i|
          if old_clusters[i].data_items.empty?
            puts "Removing empty cluster"
          else  
            @clusters << old_clusters[i]
            @centroids << old_centroids[i]
          end
        end
        @number_of_clusters = @centroids.length
      end
    end
  end
end
