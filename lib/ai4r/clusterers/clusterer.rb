# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/parameterizable'

module Ai4r
  module Clusterers
    # The purpose of this class is to define a common API for Clusterers.
    # All methods in this class (other than eval) must be implemented in
    # subclasses.
    class Clusterer
      include Ai4r::Data::Parameterizable

      # Build a new clusterer, using data examples found in data_set.
      # Data items will be clustered in "number_of_clusters" different
      # clusters.
      # @param data_set [Object]
      # @param number_of_clusters [Object]
      # @return [Object]
      def build(data_set, number_of_clusters)
        raise NotImplementedError
      end

      # Classifies the given data item, returning the cluster it belongs to.
      # @param data_item [Object]
      # @return [Object]
      def eval(data_item)
        raise NotImplementedError
      end

      # Returns +true+ if this clusterer supports evaluating new data items
      # with {#eval}. Hierarchical algorithms that only build a dendrogram
      # will override this method to return +false+.
      # @return [Object]
      def supports_eval?
        true
      end

      protected

      # @param array [Object]
      # @return [Object]
      def get_min_index(array)
        min = array.first
        index = 0
        array.each_index do |i|
          x = array[i]
          if x < min
            min = x
            index = i
          end
        end
        index
      end
    end
  end
end
