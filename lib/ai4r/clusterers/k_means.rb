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
          "assigned randomly from the data set.",
        :on_empty => "Action to take if a cluster becomes empty, with values " +
          "'eliminate' (the default action, eliminate the empty cluster), " + 
          "'terminate' (terminate with error), 'random' (relocate the " +
          "empty cluster to a random point), 'outlier' (relocate the " + 
          "empty cluster to the point furthest from its centroid)."
      
      def initialize
        @distance_function = nil
        @max_iterations = nil
        @centroid_function = lambda do |data_sets| 
          data_sets.collect{ |data_set| data_set.get_mean_or_mode}
        end
        @centroid_indices = []
        @on_empty = 'eliminate' # default if none specified
      end
      
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        raise ArgumentError, 'Length of centroid indices array differs from the specified number of clusters' unless @centroid_indices.empty? || @centroid_indices.length == @number_of_clusters
        raise ArgumentError, 'Invalid value for on_empty' unless @on_empty == 'eliminate' || @on_empty == 'terminate' || @on_empty == 'random' || @on_empty == 'outlier'
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
        @centroids, @old_centroids = [], nil 
        if @centroid_indices.empty?
          populate_centroids('random')
        else
          populate_centroids('indices')
        end
      end
      
      def stop_criteria_met
        @old_centroids == @centroids || 
          (@max_iterations && (@max_iterations <= @iterations))
      end
      
      def calculate_membership_clusters
        @clusters = Array.new(@number_of_clusters) do 
          Ai4r::Data::DataSet.new :data_labels => @data_set.data_labels
        end
        @cluster_indices = Array.new(@number_of_clusters) {[]}
        
        @data_set.data_items.each_with_index do |data_item, data_index|
          c = eval(data_item)
          @clusters[c] << data_item
          @cluster_indices[c] << data_index if @on_empty == 'outlier'
        end
        manage_empty_clusters if has_empty_cluster?
      end
      
      def recompute_centroids
        @old_centroids = @centroids
        @iterations += 1
        @centroids = @centroid_function.call(@clusters) 
      end

      def populate_centroids(populate_method, number_of_clusters=@number_of_clusters)
        tried_indexes = []
        case populate_method
        when 'random' # for initial assignment (without the :centroid_indices option) and for reassignment of empty cluster centroids (with :on_empty option 'random')
          while @centroids.length < number_of_clusters && 
              tried_indexes.length < @data_set.data_items.length
            random_index = rand(@data_set.data_items.length)
            if !tried_indexes.include?(random_index)
              tried_indexes << random_index
              if !@centroids.include? @data_set.data_items[random_index] 
                @centroids << @data_set.data_items[random_index]
              end
            end
          end
        when 'indices' # for initial assignment only (with the :centroid_indices option)
          @centroid_indices.each do |index|
            raise ArgumentError, "Invalid centroid index #{index}" unless (index.is_a? Integer) && index >=0 && index < @data_set.data_items.length
            if !tried_indexes.include?(index)
              tried_indexes << index
              if !@centroids.include? @data_set.data_items[index] 
                @centroids << @data_set.data_items[index]
              end
            end
          end
        when 'outlier' # for reassignment of empty cluster centroids only (with :on_empty option 'outlier')
          sorted_data_indices = sort_data_indices_by_dist_to_centroid
          i = sorted_data_indices.length - 1 # the last item is the furthest from its centroid
          while @centroids.length < number_of_clusters && 
              tried_indexes.length < @data_set.data_items.length
            outlier_index = sorted_data_indices[i]     
            if !tried_indexes.include?(outlier_index)
              tried_indexes << outlier_index
              if !@centroids.include? @data_set.data_items[outlier_index] 
                @centroids << @data_set.data_items[outlier_index]
              end
            end
            i > 0 ? i -= 1 : break
          end
        end   
        @number_of_clusters = @centroids.length
      end  
      
       # Sort cluster points by distance to assigned centroid.  Utilizes @cluster_indices.
       # Returns indices, sorted in order from the nearest to furthest.
       def sort_data_indices_by_dist_to_centroid 
         sorted_data_indices = []
         h = {}
         @clusters.each_with_index do |cluster, c|
           centroid = @centroids[c]
           cluster.data_items.each_with_index do |data_item, i|
             dist_to_centroid = distance(data_item, centroid)
             data_index = @cluster_indices[c][i]
             h[data_index] = dist_to_centroid
           end  
         end
         # sort hash of {index => dist to centroid} by dist to centroid (ascending) and then return an array of only the indices
         sorted_data_indices = h.sort_by{|k,v| v}.collect{|a,b| a}
       end
      
      def has_empty_cluster?
        found_empty = false
        @number_of_clusters.times do |c|
          found_empty = true if @clusters[c].data_items.empty?
        end
        found_empty
      end
      
      def manage_empty_clusters
        return if self.on_empty == 'terminate' # Do nothing to terminate with error. (The empty cluster will be assigned a nil centroid, and then calculating the distance from this centroid to another point will raise an exception.)
        
        initial_number_of_clusters = @number_of_clusters
        eliminate_empty_clusters
        return if self.on_empty == 'eliminate'  
        populate_centroids(self.on_empty, initial_number_of_clusters) # Add initial_number_of_clusters - @number_of_clusters
        calculate_membership_clusters 
      end
      
      def eliminate_empty_clusters
        old_clusters, old_centroids, old_cluster_indices = @clusters, @centroids, @cluster_indices
        @clusters, @centroids, @cluster_indices = [], [], [] 
        @number_of_clusters.times do |i|
          if !old_clusters[i].data_items.empty?
            @clusters << old_clusters[i]
            @cluster_indices << old_cluster_indices[i]
            @centroids << old_centroids[i]
          end
        end
        @number_of_clusters = @centroids.length
      end

    end
  end
end
