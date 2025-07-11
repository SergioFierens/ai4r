# frozen_string_literal: true
# Author::    Peter Lubell-Doughtie
# License::   BSD 3 Clause
# Project::   ai4r
# Url::       http://peet.ldee.org

require_relative '../clusterers/ward_linkage'
require_relative '../clusterers/cluster_tree'

module Ai4r
  module Clusterers

    # Hierarchical version to store classes as merges occur.
    class WardLinkageHierarchical < WardLinkage

      include ClusterTree

    end
  end
end
