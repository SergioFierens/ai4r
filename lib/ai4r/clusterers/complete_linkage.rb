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
require_relative '../clusterers/single_linkage'
require_relative '../clusterers/cluster_tree'

module Ai4r
  module Clusterers
    # Implementation of a Hierarchical clusterer with complete linkage (Everitt
    # et al., 2001 ; Jain and Dubes, 1988 ; Sorensen, 1948 ).
    # Hierarchical clusterer create one cluster per element, and then
    # progressively merge clusters, until the required number of clusters
    # is reached.
    # With complete linkage, the distance between two clusters is computed as
    # the maximum distance between elements of each cluster.
    #
    #   D(cx, (ci U cj) = max(D(cx, ci), D(cx, cj))
    class CompleteLinkage < SingleLinkage
      include ClusterTree

      parameters_info distance_function:
          'Custom implementation of distance function. ' \
          'It must be a closure receiving two data items and return the ' \
          'distance between them. By default, this algorithm uses ' \
          'euclidean distance of numeric attributes to the power of 2.'

      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      # @param data_set [Object]
      # @param number_of_clusters [Object]
      # @param *options [Object]
      # @return [Object]
      def build(data_set, number_of_clusters = 1, **options)
        super
      end

      # Classifies the given data item, returning the cluster index it belongs
      # to (0-based).
      # @param data_item [Object]
      # @return [Object]

      protected

      # return distance between cluster cx and new cluster (ci U cj),
      # using complete linkage
      # @param cx [Object]
      # @param ci [Object]
      # @param cj [Object]
      # @return [Object]
      def linkage_distance(cluster_x, cluster_i, cluster_j)
        [read_distance_matrix(cluster_x, cluster_i),
         read_distance_matrix(cluster_x, cluster_j)].max
      end

      # @param data_item [Object]
      # @param cluster [Object]
      # @return [Object]
      def distance_between_item_and_cluster(data_item, cluster)
        max_dist = 0
        cluster.data_items.each do |another_item|
          dist = @distance_function.call(data_item, another_item)
          max_dist = dist if dist > max_dist
        end
        max_dist
      end
    end
  end
end
