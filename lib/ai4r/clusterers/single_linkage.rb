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
      
      attr_reader :data_set, :number_of_clusters, :clusters, :dendrogram
      
      parameters_info :distance_function => 
          "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance bewteen them. By default, this algorithm uses " + 
          "squared ecuclidean distance of numeric attributes",
          :complete_dendrogram => "If false, the clusterer will halt the "+
          "building when it reaches the required number of clusters. If true, "+
          "it will continue to complete the dendrogram with a unique root. " +
          "False by default"
      
      def initialize
        @distance_function = lambda {|a,b| euclidean_distance(a, b)}
        @complete_dendrogram = false
      end
      
      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        
        create_initial_dendrogram
        create_distance_matrix(data_set)
        while not complete_condition_met
          merge_clusters(get_closest_clusters)
        end
        @clusters = build_clusters_from_dendrogram
        
        return self
      end
      
      # Classifies the given data item, returning the cluster index it belongs 
      # to (0-based).
      def eval(data_item)
        get_min_index(@clusters.collect do |cluster| 
            distance_between_item_and_cluster(data_item, cluster)
        end)
      end
      
      ###########################
      protected
      
      # if complete_dendrogram is true, complete condition is met
      # when there is only one cluster in the dendrogram.
      # If complete_dendrogram is false, complete condition is met
      # when there are as many clusters in the dendrogram as required by user.
      def complete_condition_met
        (@dendrogram.last.length <= @number_of_clusters && 
            !@complete_dendrogram) ||
        (@dendrogram.last.length == 1 && 
            @complete_dendrogram)  
      end
      
      # Builds the first level of the dendrogram, with a
      # singleton cluster for each data item.
      # [[ [0], [1], [2], ... , [n-1] ]
      def create_initial_dendrogram
        index_clusters = []
        @data_set.data_items.length.times {|i| index_clusters << [i]}
        @dendrogram = [index_clusters]
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
            @distance_matrix[i-1][j] = @distance_function.call(a, b)
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

      # Return an array with the indexes in the previous dendrogram level of 
      # the two closest clusters => [index_cluster_a, index_cluster_b]
      def get_closest_clusters
        min_distance = 1.0/0
        closest_clusters = [1, 0]
        @dendrogram.last.each_with_index do |cluster_a, index_a|
          index_a.times do |index_b|
            cluster_b = @dendrogram.last[index_b]
            cluster_distance = calc_clusters_distance(cluster_a, cluster_b)
            if cluster_distance < min_distance
              closest_clusters = [index_a, index_b]
              min_distance = cluster_distance
            end
          end
        end
        return closest_clusters
      end
      
      # Calculate distance between clusters, browsing the dendrogram 
      # recursively. 
      # In each level of the dendrogram we have arrays with  1 item 
      # (i.e. index of the same cluster in the previous level) or 
      # with 2 items (indexes of the 2 merged clusters in the previous level).
      # The distance between 2 clusters with 1 item is calculated with 
      # the distance matrix, and the distance between a cluster with
      # one item and a cluster with the merge of two previous clusters is 
      # calculated with the linkage function.
      def calc_clusters_distance(cluster_a, cluster_b, level_a=nil, level_b=nil)
        level_a ||= @dendrogram.length-1
        level_b ||= @dendrogram.length-1
      
        if level_a==0 && level_b==0
          return read_distance_matrix(cluster_a.first, cluster_b.first)
        end

        if cluster_a.length > 1
          return linkage(
              calc_clusters_distance(@dendrogram[level_a-1][cluster_a.first], 
                cluster_b, level_a-1, level_b),
              calc_clusters_distance(@dendrogram[level_a-1][cluster_a.last], 
                cluster_b, level_a-1, level_b))
        elsif cluster_b.length > 1
          return linkage(  
              calc_clusters_distance(cluster_a, 
                @dendrogram[level_b-1][cluster_b.first], level_a, level_b-1),
              calc_clusters_distance(cluster_a, 
                @dendrogram[level_b-1][cluster_b.last], 
                level_a, level_b-1))
        elsif level_a > 0
          return calc_clusters_distance(@dendrogram[level_a-1][cluster_a.first], 
            cluster_b, level_a-1, level_b)
        elsif level_b > 0
          return calc_clusters_distance(cluster_a, 
              @dendrogram[level_b-1][cluster_b.first],
                level_a, level_b-1)
        end
      end
      
      # Use the single linkage method (Nearest-neighbor)
      def linkage(a, b)
        [a, b].min
      end
      
      # Adds a new level in the dendrogram, using the indexes
      # of clusters in the previous level.
      # clusters_to_merge = [index_cluster_a, index_cluster_b].
      def merge_clusters(clusters_to_merge)
        new_level = []
        @dendrogram.last.length.times do |i| 
          new_level << [i] if !clusters_to_merge.include? i
        end
        new_level << clusters_to_merge
        @dendrogram << new_level
      end

      def distance_between_item_and_cluster(data_item, cluster)
        min_dist = 1.0/0
        cluster.data_items.each do |another_item|
          dist = @distance_function.call(data_item, another_item)
          min_dist = dist if dist < min_dist
        end
        return min_dist
      end
      
      # it returns an array of data sets, representing each clusters 
      def build_clusters_from_dendrogram
        @dendrogram.each {|l| puts l.inspect}
        k_level = dendrogram_level_with_k_clusters(@number_of_clusters)
        puts "LEVEL: #{k_level}"
        cluster_items = @dendrogram[k_level].collect do |cluster_data|
          items = []
          collect_items(items, cluster_data, k_level)
          items
        end
        cluster_items.each {|l| puts l.inspect}
        return cluster_items.collect do |data_items|
          Ai4r::Data::DataSet.new(:data_labels => @data_set.data_labels,
            :data_items => data_items)
        end
      end
      
      # Return the dendrogram level that contains k clusters
      def dendrogram_level_with_k_clusters(k)
        @data_set.data_items.length-k
      end
      
      # return an array of data items, using the specified dendrogram level
      # [ item 0, item 1, ... item n]
      def collect_items(collection, indexes, level)
        if level == 0
          collection << @data_set.data_items[indexes.first] 
        else
          indexes.each do |i| 
            collect_items(collection, @dendrogram[level-1][i], level-1)
          end  
        end
      end
      
    end
  end
end

