# Author::    Peter Lubell-Doughtie
# License::   BSD 3 Clause
# Project::   ai4r
# Url::       http://peet.ldee.org

require File.dirname(__FILE__) + '/../clusterers/ward_linkage'

module Ai4r
  module Clusterers

    # Hierarchical version to store classes as merges occur.
    class WardLinkageHierarchical < WardLinkage

      attr_reader :cluster_tree
     
      def initialize
        @cluster_tree = []
        super
      end

      protected

      def merge_clusters(index_a, index_b, index_clusters)
        # store current index_clusters
        @cluster_tree << index_clusters.dup
        super
      end
    end
  end
end

