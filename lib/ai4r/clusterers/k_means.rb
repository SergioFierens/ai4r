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

module Ai4r
  module Clusterers
    # The k-means algorithm is an algorithm to cluster n objects
    # based on attributes into k partitions, with k < n.
    #
    # More about K Means algorithm:
    # http://en.wikipedia.org/wiki/K-means_algorithm
    class KMeans < Clusterer
      attr_reader :data_set, :number_of_clusters, :clusters, :centroids, :iterations, :history

      parameters_info(
        max_iterations: 'Maximum number of iterations to build the clusterer. By default it is uncapped.',
        distance_function: 'Custom implementation of distance function. ' \
                           'It must be a closure receiving two data items and return the ' \
                           'distance between them. By default, this algorithm uses ' \
                           'euclidean distance of numeric attributes to the power of 2.',
        centroid_function: 'Custom implementation to calculate the ' \
                           'centroid of a cluster. It must be a closure receiving an array of ' \
                           'data sets, and return an array of data items, representing the ' \
                           'centroids of for each data set. ' \
                           'By default, this algorithm returns a data items using the mode ' \
                           'or mean of each attribute on each data set.',
        centroid_indices: 'Indices of data items (indexed from 0) to be ' \
                          'the initial centroids.  Otherwise, the initial centroids will be ' \
                          'assigned randomly from the data set.',
        on_empty: 'Action to take if a cluster becomes empty, with values ' \
                  "'eliminate' (the default action, eliminate the empty cluster), " \
                  "'terminate' (terminate with error), 'random' (relocate the " \
                  "empty cluster to a random point), 'outlier' (relocate the " \
                  'empty cluster to the point furthest from its centroid).',
        random_seed: "Seed value used to initialize Ruby's random number " \
                     'generator when selecting random centroids.',
        init_method: 'Strategy to initialize centroids. Available values: ' \
                     ':random (default) and :kmeans_plus_plus.',
        restarts: 'Number of random initializations to perform. ' \
                  'The best run (lowest SSE) will be kept.',
        track_history: 'Keep centroids and assignments for each iteration ' \
                       'when building the clusterer.'
      )

      # @return [Object]
      def initialize
        @distance_function = nil
        @max_iterations = nil
        @centroid_function = lambda do |data_sets|
          data_sets.collect(&:get_mean_or_mode)
        end
        @centroid_indices = []
        @on_empty = 'eliminate' # default if none specified
        @random_seed = nil
        @rng = nil
        @init_method = :random
        @restarts = 1
        @track_history = false
      end

      # Build a new clusterer, using data examples found in data_set.
      # Items will be clustered in "number_of_clusters" different
      # clusters.
      # @param data_set [Object]
      # @param number_of_clusters [Object]
      # @return [Object]
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        if @number_of_clusters > @data_set.data_items.length
          raise ArgumentError, 'Number of clusters larger than data items'
        end

        unless @centroid_indices.empty? || @centroid_indices.length == @number_of_clusters
          raise ArgumentError,
                'Length of centroid indices array differs from the specified number of clusters'
        end
        unless @on_empty == 'eliminate' || @on_empty == 'terminate' || @on_empty == 'random' || @on_empty == 'outlier'
          raise ArgumentError,
                'Invalid value for on_empty'
        end

        seed_base = @random_seed
        best_sse = nil
        best_centroids = nil
        best_clusters = nil
        best_iterations = nil

        (@restarts || 1).times do |i|
          @random_seed = seed_base.nil? ? nil : seed_base + i
          @rng = @random_seed.nil? ? Random.new : Random.new(@random_seed)
          @iterations = 0
          @history = [] if @track_history
          calc_initial_centroids
          until stop_criteria_met
            calculate_membership_clusters
            if @track_history
              @history << {
                centroids: @centroids.collect(&:dup),
                assignments: @assignments.dup
              }
            end
            recompute_centroids
          end
          current_sse = sse
          next unless best_sse.nil? || current_sse < best_sse

          best_sse = current_sse
          best_centroids = Marshal.load(Marshal.dump(@centroids))
          best_clusters = Marshal.load(Marshal.dump(@clusters))
          best_iterations = @iterations
        end

        @random_seed = seed_base
        @rng = @random_seed.nil? ? Random.new : Random.new(@random_seed)
        @centroids = best_centroids
        @clusters = best_clusters
        @iterations = best_iterations
        self
      end

      # Classifies the given data item, returning the cluster index it belongs
      # to (0-based).
      # @param data_item [Object]
      # @return [Object]
      def eval(data_item)
        get_min_index(@centroids.collect do |centroid|
          distance(data_item, centroid)
        end)
      end

      # Sum of squared distances of all points to their respective centroids.
      # It can be used as a measure of cluster compactness (SSE).
      # @return [Object]
      def sse
        sum = 0.0
        @clusters.each_with_index do |cluster, i|
          centroid = @centroids[i]
          cluster.data_items.each do |item|
            sum += distance(item, centroid)
          end
        end
        sum
      end

      # This function calculates the distance between 2 different
      # instances. By default, it returns the euclidean distance to the
      # power of 2.
      # You can provide a more convenient distance implementation:
      #
      # 1- Overwriting this method
      #
      # 2- Providing a closure to the :distance_function parameter
      # @param a [Object]
      # @param b [Object]
      # @return [Object]
      def distance(a, b)
        return @distance_function.call(a, b) if @distance_function

        Ai4r::Data::Proximity.squared_euclidean_distance(
          a.select { |att_a| att_a.is_a? Numeric },
          b.select { |att_b| att_b.is_a? Numeric }
        )
      end

      protected

      # @return [Object]
      def calc_initial_centroids
        @centroids = []
        @old_centroids = nil
        if @centroid_indices.empty?
          if @init_method == :kmeans_plus_plus
            kmeans_plus_plus_init
          else
            populate_centroids('random')
          end
        else
          populate_centroids('indices')
        end
      end

      # @return [Object]
      def stop_criteria_met
        @old_centroids == @centroids ||
          (@max_iterations && (@max_iterations <= @iterations))
      end

      # @return [Object]
      def calculate_membership_clusters
        @clusters = Array.new(@number_of_clusters) do
          Ai4r::Data::DataSet.new data_labels: @data_set.data_labels
        end
        @cluster_indices = Array.new(@number_of_clusters) { [] }
        @assignments = Array.new(@data_set.data_items.length)

        @data_set.data_items.each_with_index do |data_item, data_index|
          c = eval(data_item)
          @clusters[c] << data_item
          @cluster_indices[c] << data_index if @on_empty == 'outlier'
          @assignments[data_index] = c
        end
        manage_empty_clusters if has_empty_cluster?
      end

      # @return [Object]
      def recompute_centroids
        @old_centroids = @centroids
        @iterations += 1
        @centroids = @centroid_function.call(@clusters)
      end

      # @return [Object]
      def kmeans_plus_plus_init
        chosen_indices = []
        first_index = (0...@data_set.data_items.length).to_a.sample(random: @rng)
        return if first_index.nil?

        @centroids << @data_set.data_items[first_index]
        chosen_indices << first_index
        while @centroids.length < @number_of_clusters &&
              chosen_indices.length < @data_set.data_items.length
          distances = []
          total = 0.0
          @data_set.data_items.each_with_index do |item, index|
            next if chosen_indices.include?(index)

            min_dist = @centroids.map { |c| distance(item, c) }.min
            distances << [index, min_dist]
            total += min_dist
          end
          break if distances.empty?

          r = @rng.rand * total
          cumulative = 0.0
          chosen = distances.find do |_idx, dist|
            cumulative += dist
            cumulative >= r
          end
          chosen_indices << chosen[0]
          @centroids << @data_set.data_items[chosen[0]]
        end
        @number_of_clusters = @centroids.length
      end

      # @param populate_method [Object]
      # @param number_of_clusters [Object]
      # @return [Object]
      def populate_centroids(populate_method, number_of_clusters = @number_of_clusters)
        tried_indexes = []
        case populate_method
        when 'random' # for initial assignment (without the :centroid_indices option) and for reassignment of empty cluster centroids (with :on_empty option 'random')
          while @centroids.length < number_of_clusters &&
                tried_indexes.length < @data_set.data_items.length
            random_index = (0...@data_set.data_items.length).to_a.sample(random: @rng)
            next if tried_indexes.include?(random_index)

            tried_indexes << random_index
            unless @centroids.include? @data_set.data_items[random_index]
              @centroids << @data_set.data_items[random_index]
            end
          end
        when 'indices' # for initial assignment only (with the :centroid_indices option)
          @centroid_indices.each do |index|
            unless (index.is_a? Integer) && index >= 0 && index < @data_set.data_items.length
              raise ArgumentError,
                    "Invalid centroid index #{index}"
            end

            next if tried_indexes.include?(index)

            tried_indexes << index
            unless @centroids.include? @data_set.data_items[index]
              @centroids << @data_set.data_items[index]
            end
          end
        when 'outlier' # for reassignment of empty cluster centroids only (with :on_empty option 'outlier')
          sorted_data_indices = sort_data_indices_by_dist_to_centroid
          i = sorted_data_indices.length - 1 # the last item is the furthest from its centroid
          while @centroids.length < number_of_clusters &&
                tried_indexes.length < @data_set.data_items.length
            outlier_index = sorted_data_indices[i]
            unless tried_indexes.include?(outlier_index)
              tried_indexes << outlier_index
              unless @centroids.include? @data_set.data_items[outlier_index]
                @centroids << @data_set.data_items[outlier_index]
              end
            end
            i.positive? ? i -= 1 : break
          end
        end
        @number_of_clusters = @centroids.length
      end

      # Sort cluster points by distance to assigned centroid.  Utilizes @cluster_indices.
      # Returns indices, sorted in order from the nearest to furthest.
      # @return [Object]
      def sort_data_indices_by_dist_to_centroid
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
        h.sort_by { |_k, v| v }.collect { |a, _b| a }
      end

      # @return [Object]
      def has_empty_cluster?
        found_empty = false
        @number_of_clusters.times do |c|
          found_empty = true if @clusters[c].data_items.empty?
        end
        found_empty
      end

      # @return [Object]
      def manage_empty_clusters
        # Do nothing to terminate with error. (The empty cluster will be assigned a nil centroid, and then calculating the distance from this centroid to another point will raise an exception.)
        return if on_empty == 'terminate'

        initial_number_of_clusters = @number_of_clusters
        eliminate_empty_clusters
        return if on_empty == 'eliminate'

        populate_centroids(on_empty, initial_number_of_clusters) # Add initial_number_of_clusters - @number_of_clusters
        calculate_membership_clusters
      end

      # @return [Object]
      def eliminate_empty_clusters
        old_clusters = @clusters
        old_centroids = @centroids
        old_cluster_indices = @cluster_indices
        old_assignments = @assignments
        @clusters = []
        @centroids = []
        @cluster_indices = []
        remap = {}
        new_index = 0
        @number_of_clusters.times do |i|
          next if old_clusters[i].data_items.empty?

          remap[i] = new_index
          @clusters << old_clusters[i]
          @cluster_indices << old_cluster_indices[i]
          @centroids << old_centroids[i]
          new_index += 1
        end
        @number_of_clusters = @centroids.length
        @assignments = old_assignments.map { |c| remap[c] }
      end
    end
  end
end
