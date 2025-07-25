# frozen_string_literal: true

# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'
require_relative '../data/proximity'
require_relative '../clusterers/clusterer'
require_relative '../clusterers/cluster_tree'

module Ai4r
  module Clusterers
    # Implementation of a Hierarchical clusterer with single linkage (Everitt et
    # al., 2001 ; Johnson, 1967 ; Jain and Dubes, 1988 ; Sneath, 1957 )
    # Hierarchical clusterer create one cluster per element, and then
    # progressively merge clusters, until the required number of clusters
    # is reached.
    # With single linkage, the distance between two clusters is computed as the
    # distance between the two closest elements in the two clusters.
    #
    #   D(cx, (ci U cj) = min(D(cx, ci), D(cx, cj))
    class SingleLinkage < Clusterer
      include ClusterTree

      attr_reader :data_set, :number_of_clusters, :clusters

      parameters_info distance_function:
          'Custom implementation of distance function. ' \
          'It must be a closure receiving two data items and return the ' \
          'distance between them. By default, this algorithm uses ' \
          'euclidean distance of numeric attributes to the power of 2.'

      # @return [Object]
      def initialize(*args)
        super(*args)
        @distance_function = lambda do |a, b|
          Ai4r::Data::Proximity.squared_euclidean_distance(
            a.select { |att_a| att_a.is_a? Numeric },
            b.select { |att_b| att_b.is_a? Numeric }
          )
        end
      end

      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      #
      # If you specify :distance options, it will stop whether
      # number_of_clusters are reached or no distance among clusters are below :distance
      # @param data_set [Object]
      # @param number_of_clusters [Object]
      # @param *options [Object]
      # @return [Object]
      def build(data_set, number_of_clusters = 1, **options)
        @data_set = data_set
        distance = options[:distance] || Float::INFINITY

        @index_clusters = create_initial_index_clusters
        create_distance_matrix(data_set)
        while @index_clusters.length > number_of_clusters
          ci, cj = get_closest_clusters(@index_clusters)
          break if read_distance_matrix(ci, cj) > distance

          update_distance_matrix(ci, cj)
          merge_clusters(ci, cj, @index_clusters)
        end

        @number_of_clusters = @index_clusters.length
        @distance_matrix = nil
        @clusters = build_clusters_from_index_clusters @index_clusters
        self
      end

      # @param clusters [Object]
      # @return [Object]
      def draw_map(clusters)
        map = Array.new(11) { Array.new(11, 0) }
        clusters.each_index do |i|
          clusters[i].data_items.each do |point|
            map[point.first][point.last] = (i + 1)
          end
        end
        map
      end

      # Classifies the given data item, returning the cluster index it belongs
      # to (0-based).
      # @param data_item [Object]
      # @return [Object]
      def eval(data_item)
        get_min_index(@clusters.collect do |cluster|
          distance_between_item_and_cluster(data_item, cluster)
        end)
      end

      protected

      # @param i [Object]
      # @param j [Object]
      # @return [Object]
      def distance_between_indexes(i, j)
        @distance_function.call(@data_set.data_items[i], @data_set.data_items[j])
      end

      public

      # Compute mean silhouette coefficient of the clustering result.
      # Returns a float between -1 and 1. Only valid after build.
      # @return [Object]
      def silhouette
        return nil unless @index_clusters && @data_set

        total = 0.0
        count = @data_set.data_items.length

        @index_clusters.each_with_index do |cluster, ci|
          cluster.each do |index|
            a = 0.0
            if cluster.length > 1
              cluster.each do |j|
                next if j == index

                a += distance_between_indexes(index, j)
              end
              a /= (cluster.length - 1)
            end

            b = nil
            @index_clusters.each_with_index do |other_cluster, cj|
              next if ci == cj

              dist = 0.0
              other_cluster.each do |j|
                dist += distance_between_indexes(index, j)
              end
              dist /= other_cluster.length
              b = dist if b.nil? || dist < b
            end
            s = b&.positive? ? (b - a) / [a, b].max : 0.0
            total += s
          end
        end

        total / count
      end

      protected

      # returns [ [0], [1], [2], ... , [n-1] ]
      # where n is the number of data items in the data set
      # @return [Object]
      def create_initial_index_clusters
        index_clusters = []
        @data_set.data_items.length.times { |i| index_clusters << [i] }
        index_clusters
      end

      # Create a partial distance matrix:
      #   [
      #     [d(1,0)],
      #     [d(2,0), d(2,1)],
      #     [d(3,0), d(3,1), d(3,2)],
      #     ...
      #     [d(n-1,0), d(n-1,1), d(n-1,2), ... , d(n-1,n-2)]
      #   ]
      # where n is the number of data items in the data set
      # @param data_set [Object]
      # @return [Object]
      def create_distance_matrix(data_set)
        @distance_matrix = Array.new(data_set.data_items.length - 1) do |index|
          Array.new(index + 1)
        end
        data_set.data_items.each_with_index do |a, i|
          i.times do |j|
            b = data_set.data_items[j]
            @distance_matrix[i - 1][j] = @distance_function.call(a, b)
          end
        end
      end

      # Returns the distance between element data_item[index_a] and
      # data_item[index_b] using the distance matrix
      # @param index_a [Object]
      # @param index_b [Object]
      # @return [Object]
      def read_distance_matrix(index_a, index_b)
        return 0 if index_a == index_b

        index_a, index_b = index_b, index_a if index_b > index_a
        @distance_matrix[index_a - 1][index_b]
      end

      # ci and cj are the indexes of the clusters that are going to
      # be merged. We need to remove distances from/to ci and cj,
      # and add distances from/to new cluster (ci U cj)
      # @param ci [Object]
      # @param cj [Object]
      # @return [Object]
      def update_distance_matrix(ci, cj)
        ci, cj = cj, ci if cj > ci
        distances_to_new_cluster = []
        (@distance_matrix.length + 1).times do |cx|
          distances_to_new_cluster << linkage_distance(cx, ci, cj) if cx != ci && cx != cj
        end
        if cj.zero? && ci == 1
          @distance_matrix.delete_at(1)
          @distance_matrix.delete_at(0)
        elsif cj.zero?
          @distance_matrix.delete_at(ci - 1)
          @distance_matrix.delete_at(0)
        else
          @distance_matrix.delete_at(ci - 1)
          @distance_matrix.delete_at(cj - 1)
        end
        @distance_matrix.each do |d|
          d.delete_at(ci)
          d.delete_at(cj)
        end
        @distance_matrix << distances_to_new_cluster
      end

      # return distance between cluster cx and new cluster (ci U cj),
      # using single linkage
      # @param cx [Object]
      # @param ci [Object]
      # @param cj [Object]
      # @return [Object]
      def linkage_distance(cluster_x, cluster_i, cluster_j)
        [read_distance_matrix(cluster_x, cluster_i),
         read_distance_matrix(cluster_x, cluster_j)].min
      end

      # cluster_a and cluster_b are removed from index_cluster,
      # and a new cluster with all members of cluster_a and cluster_b
      # is added.
      # It modifies index clusters array.
      # @param index_a [Object]
      # @param index_b [Object]
      # @param index_clusters [Object]
      # @return [Object]
      def merge_clusters(index_a, index_b, index_clusters)
        index_a, index_b = index_b, index_a if index_b > index_a
        new_index_cluster = index_clusters[index_a] +
                            index_clusters[index_b]
        index_clusters.delete_at index_a
        index_clusters.delete_at index_b
        index_clusters << new_index_cluster
        index_clusters
      end

      # Given an array with clusters of data_items indexes,
      # it returns an array of data_items clusters
      # @param index_clusters [Object]
      # @return [Object]
      def build_clusters_from_index_clusters(index_clusters)
        index_clusters.collect do |index_cluster|
          Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels,
                                  data_items: index_cluster.collect do |i|
                                    @data_set.data_items[i]
                                  end)
        end
      end

      # Returns ans array with the indexes of the two closest
      # clusters => [index_cluster_a, index_cluster_b]
      # @param index_clusters [Object]
      # @return [Object]
      def get_closest_clusters(index_clusters)
        min_distance = Float::INFINITY
        closest_clusters = [1, 0]
        index_clusters.each_index do |index_a|
          index_a.times do |index_b|
            cluster_distance = read_distance_matrix(index_a, index_b)
            if cluster_distance < min_distance
              closest_clusters = [index_a, index_b]
              min_distance = cluster_distance
            end
          end
        end
        closest_clusters
      end

      # @param data_item [Object]
      # @param cluster [Object]
      # @return [Object]
      def distance_between_item_and_cluster(data_item, cluster)
        min_dist = Float::INFINITY
        cluster.data_items.each do |another_item|
          dist = @distance_function.call(data_item, another_item)
          min_dist = dist if dist < min_dist
        end
        min_dist
      end
    end
  end
end
