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

    # Implementation of an Agglomerative Hierarchical clusterer with
    # median linkage algorithm, aka weighted pair group method centroid
    # or WPGMC (Everitt et al., 2001 ; Gower, 1967 ; Jain and Dubes, 1988 ).
    # Hierarchical clusterer create one cluster per element, and then
    # progressively merge clusters, until the required number of clusters
    # is reached.
    # Similar to centroid linkages, but using fix weight:
    #
    #   D(cx, (ci U cj)) =  (1/2)*D(cx, ci) +
    #                       (1/2)*D(cx, cj) -
    #                       (1/4)*D(ci, cj)
    class MedianLinkage < SingleLinkage

      include ClusterTree

    parameters_info distance_function:
          "Custom implementation of distance function. " +
          "It must be a closure receiving two data items and return the " +
          "distance between them. By default, this algorithm uses " +
          "euclidean distance of numeric attributes to the power of 2."

      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters = 1, **options)
        super
      end

      # This algorithms does not allow classification of new data items
      # once it has been built. Rebuild the cluster including you data element.
      def eval(_data_item)
        raise NotImplementedError, 'Eval of new data is not supported by this algorithm.'
      end

      def supports_eval?
        false
      end

      protected

      # return distance between cluster cx and cluster (ci U cj),
      # using median linkage
      def linkage_distance(cx, ci, cj)
        ( 0.5  * read_distance_matrix(cx, ci) +
          0.5  * read_distance_matrix(cx, cj) -
          0.25 * read_distance_matrix(ci, cj))
      end

    end
  end
end
