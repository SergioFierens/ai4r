# frozen_string_literal: true

# Author::    Gwénaël Rault (implementation)
# License::   AGPL-3.0
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require "#{File.dirname(__FILE__)}/../data/data_set"
require "#{File.dirname(__FILE__)}/../data/proximity"
require "#{File.dirname(__FILE__)}/../clusterers/clusterer"

module Ai4r
  module Clusterers
    # More about DBSCAN algorithm:
    # https://en.wikipedia.org/wiki/DBSCAN
    class DBSCAN < Clusterer
      attr_reader :data_set, :number_of_clusters, :clusters, :cluster_indices, :labels

      parameters_info epsilon: 'radius around the current point ' \
                               'within min_points must be in order to build a cluster.',
                      min_points: 'Minimum number of points within a neighborhood' \
                                  'in order to build a cluster',
                      distance_function: 'Custom implementation of distance function. ' \
                                         'It must be a closure receiving two data items and return the ' \
                                         'distance between them. By default, this algorithm uses ' \
                                         'euclidean distance of numeric attributes to the power of 2.'

      def initialize
        @distance_function = nil
        @epsilon = nil
        @min_points = 5
        @clusters = []
        @cluster_indices = []
      end

      def build(data_set)
        @data_set = data_set
        @clusters = []
        @cluster_indices = []
        @labels = Array.new(data_set.data_items.size)
        @number_of_clusters = 0

        raise ArgumentError, 'epsilon must be defined' if @epsilon.nil?

        # Detect if the neighborhood of the current item
        # is dense enough
        data_set.data_items.each_with_index do |data_item, data_index|
          next unless @labels[data_index].nil?

          neighbors = range_query(data_item) - [data_index]
          if neighbors.size < @min_points
            @labels[data_index] = :noise
          else
            @number_of_clusters += 1
            @labels[data_index] = @number_of_clusters
            @clusters.push([data_item])
            @cluster_indices.push([data_index])
            extend_cluster(neighbors, @number_of_clusters)
          end
        end
        @number_of_clusters = number_of_clusters

        @number_of_clusters = number_of_clusters
        self
      end

      # This algorithm cannot classify new data items once it has been built.
      # Rebuild the cluster with your new data item instead.
      # @param _data_item [Object]
      # @return [Object]
      def eval(_data_item)
        raise NotImplementedError, 'Eval of new data is not supported by this algorithm.'
      end

      # @return [Object]
      def supports_eval?
        false
      end

      def distance(a, b)
        return @distance_function.call(a, b) if @distance_function

        Ai4r::Data::Proximity.squared_euclidean_distance(
          a.select { |att_a| att_a.is_a? Numeric },
          b.select { |att_b| att_b.is_a? Numeric }
        )
      end

      protected

      # Scan the data set and return the indices of all points
      # belonging to the neighborhood of the current item
      def range_query(evaluated_data_item)
        neighbors = []
        @data_set.data_items.each_with_index do |data_item, data_index|
          neighbors << data_index if distance(evaluated_data_item, data_item) <= @epsilon
        end
        neighbors
      end

      # If the neighborhood is dense enough, it propagates.
      # This applies only to items that don't belong to an
      # existing cluster.
      # If any neighbor was previously classified as noise,
      # it becomes part of the current cluster.
      def extend_cluster(neighbors, current_cluster)
        while neighbors.any?
          data_index = neighbors.shift
          if @labels[data_index] == :noise
            @labels[data_index] = current_cluster
            @clusters.last << @data_set.data_items[data_index]
            @cluster_indices.last << data_index
          elsif @labels[data_index].nil?
            @labels[data_index] = current_cluster
            @clusters.last << @data_set.data_items[data_index]
            @cluster_indices.last << data_index
            new_neighbors = range_query(@data_set.data_items[data_index]) - [data_index]
            if new_neighbors.size >= @min_points
              neighbors.concat(new_neighbors)
              neighbors.uniq!
            end
          end
        end
      end
    end
  end
end
