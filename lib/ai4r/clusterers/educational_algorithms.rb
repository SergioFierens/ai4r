# frozen_string_literal: true

# Educational implementations of clustering algorithms with step-by-step execution
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'educational_clustering'
require_relative '../data/data_set'

module Ai4r
  module Clusterers
    # Educational K-Means implementation with step-by-step execution
    class EducationalKMeans
      attr_reader :clusters, :centroids, :configuration, :monitor

      def initialize(configuration, monitor)
        @configuration = configuration
        @monitor = monitor
        @clusters = []
        @centroids = []
      end

      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters

        # Initialize centroids
        initialize_centroids

        iteration = 0
        converged = false

        while iteration < @configuration.max_iterations && !converged
          old_centroids = @centroids.dup

          # Assign points to clusters
          assign_points_to_clusters

          # Update centroids
          update_centroids

          # Check convergence
          converged = check_convergence(old_centroids, @centroids)

          iteration += 1

          # Record iteration for monitoring
          change_measure = calculate_centroid_change(old_centroids, @centroids)
          @monitor.record_iteration(@clusters, @centroids, change_measure)
        end

        self
      end

      def build_with_steps(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters

        # Step 1: Initialize centroids
        initialize_centroids
        yield({
          step: 1,
          description: 'Initialize centroids',
          details: "Randomly selected #{@number_of_clusters} points as initial centroids using #{@configuration.initialization_strategy} strategy",
          clusters: @clusters.dup,
          centroids: @centroids.dup
        })

        iteration = 0
        converged = false

        while iteration < @configuration.max_iterations && !converged
          old_centroids = @centroids.dup

          # Step 2a: Assign points to clusters
          assign_points_to_clusters
          yield({
            step: 2 + (iteration * 2),
            description: "Assign points to nearest centroids (Iteration #{iteration + 1})",
            details: "Each point assigned to cluster with nearest centroid. Cluster sizes: #{@clusters.map do |c|
              c.data_items.length
            end.join(', ')}",
            clusters: @clusters.dup,
            centroids: @centroids.dup
          })

          # Step 2b: Update centroids
          update_centroids
          centroid_change = calculate_centroid_change(old_centroids, @centroids)
          yield({
            step: 3 + (iteration * 2),
            description: "Update centroids (Iteration #{iteration + 1})",
            details: "New centroids calculated as cluster means. Total change: #{centroid_change.round(6)}",
            clusters: @clusters.dup,
            centroids: @centroids.dup
          })

          # Check convergence
          converged = check_convergence(old_centroids, @centroids)

          if converged
            yield({
              step: 4 + (iteration * 2),
              description: 'Convergence achieved',
              details: "Centroids changed by less than #{@configuration.tolerance}. Algorithm complete.",
              clusters: @clusters.dup,
              centroids: @centroids.dup
            })
          end

          iteration += 1

          # Record iteration for monitoring
          @monitor.record_iteration(@clusters, @centroids, centroid_change)
        end

        unless converged
          yield({
            step: 4 + (iteration * 2),
            description: 'Maximum iterations reached',
            details: "Algorithm stopped after #{@configuration.max_iterations} iterations without full convergence",
            clusters: @clusters.dup,
            centroids: @centroids.dup
          })
        end

        self
      end

      private

      def initialize_centroids
        @centroids = []
        @clusters = Array.new(@number_of_clusters) do
          Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels)
        end

        case @configuration.initialization_strategy
        when :random
          initialize_random_centroids
        when :k_means_plus_plus
          initialize_k_means_plus_plus
        when :manual
          initialize_manual_centroids
        else
          initialize_random_centroids
        end
      end

      def initialize_random_centroids
        selected_indices = []

        @number_of_clusters.times do
          loop do
            index = rand(@data_set.data_items.length)
            next if selected_indices.include?(index)

            selected_indices << index
            @centroids << @data_set.data_items[index].dup
            break
          end
        end
      end

      def initialize_k_means_plus_plus
        # K-means++ initialization for better initial centroid selection
        @centroids << @data_set.data_items[rand(@data_set.data_items.length)].dup

        (@number_of_clusters - 1).times do
          distances = @data_set.data_items.map do |point|
            min_distance = @centroids.map { |centroid| @configuration.distance_function.call(point, centroid) }.min
            min_distance**2
          end

          total_distance = distances.sum
          return if total_distance == 0

          target = rand * total_distance
          cumulative = 0

          @data_set.data_items.each_with_index do |point, index|
            cumulative += distances[index]
            if cumulative >= target
              @centroids << point.dup
              break
            end
          end
        end
      end

      def initialize_manual_centroids
        # For educational purposes, allow manual centroid specification
        # This would be set via configuration in a real implementation
        initialize_random_centroids
      end

      def assign_points_to_clusters
        # Clear existing clusters
        @clusters.each { |cluster| cluster.data_items.clear }

        @data_set.data_items.each do |point|
          distances = @centroids.map { |centroid| @configuration.distance_function.call(point, centroid) }
          closest_cluster = distances.each_with_index.min_by { |distance, _| distance }[1]
          @clusters[closest_cluster] << point
        end
      end

      def update_centroids
        @centroids = @clusters.map do |cluster|
          if cluster.data_items.empty?
            # Handle empty clusters by reinitializing
            @data_set.data_items[rand(@data_set.data_items.length)].dup
          else
            cluster.get_mean_or_mode
          end
        end
      end

      def check_convergence(old_centroids, new_centroids)
        total_change = calculate_centroid_change(old_centroids, new_centroids)
        total_change < @configuration.tolerance
      end

      def calculate_centroid_change(old_centroids, new_centroids)
        total_change = 0

        old_centroids.zip(new_centroids).each do |old_centroid, new_centroid|
          total_change += @configuration.distance_function.call(old_centroid, new_centroid)
        end

        total_change
      end
    end

    # Educational Hierarchical Clustering implementation
    class EducationalHierarchical
      attr_reader :clusters, :configuration, :monitor, :linkage_type

      def initialize(configuration, monitor, linkage_type = :single)
        @configuration = configuration
        @monitor = monitor
        @linkage_type = linkage_type
        @clusters = []
        @dendrogram = []
      end

      def build(data_set, number_of_clusters)
        @data_set = data_set
        @target_clusters = number_of_clusters

        # Initialize - each point is its own cluster
        initialize_clusters

        # Build distance matrix
        build_distance_matrix

        # Merge clusters until we reach the target number
        merge_closest_clusters while @clusters.length > @target_clusters

        self
      end

      def build_with_steps(data_set, number_of_clusters)
        @data_set = data_set
        @target_clusters = number_of_clusters

        # Step 1: Initialize clusters
        initialize_clusters
        yield({
          step: 1,
          description: 'Initialize clusters',
          details: "Created #{@clusters.length} clusters, each containing one data point",
          clusters: @clusters.dup
        })

        # Step 2: Build distance matrix
        build_distance_matrix
        yield({
          step: 2,
          description: 'Build distance matrix',
          details: "Calculated pairwise distances between all clusters using #{@linkage_type} linkage",
          clusters: @clusters.dup
        })

        step = 3
        while @clusters.length > @target_clusters
          # Find closest clusters
          closest_pair = find_closest_clusters
          distance = @distance_matrix[closest_pair[0]][closest_pair[1]]

          # Merge them
          merge_clusters(closest_pair[0], closest_pair[1])

          yield({
            step: step,
            description: 'Merge closest clusters',
            details: "Merged clusters #{closest_pair[0]} and #{closest_pair[1]} (distance: #{distance.round(4)}). Now have #{@clusters.length} clusters",
            clusters: @clusters.dup
          })

          step += 1

          # Record iteration for monitoring
          @monitor.record_iteration(@clusters)
        end

        yield({
          step: step,
          description: 'Clustering complete',
          details: "Reached target of #{@target_clusters} clusters",
          clusters: @clusters.dup
        })

        self
      end

      def get_dendrogram
        @dendrogram
      end

      private

      def initialize_clusters
        @clusters = @data_set.data_items.map do |item|
          Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels, data_items: [item])
        end
      end

      def build_distance_matrix
        @distance_matrix = Array.new(@clusters.length) { Array.new(@clusters.length, 0) }

        @clusters.each_with_index do |cluster_i, i|
          @clusters.each_with_index do |cluster_j, j|
            next if i == j

            @distance_matrix[i][j] = calculate_cluster_distance(cluster_i, cluster_j)
          end
        end
      end

      def calculate_cluster_distance(cluster_a, cluster_b)
        case @linkage_type
        when :single
          single_linkage_distance(cluster_a, cluster_b)
        when :complete
          complete_linkage_distance(cluster_a, cluster_b)
        when :average
          average_linkage_distance(cluster_a, cluster_b)
        when :ward
          ward_linkage_distance(cluster_a, cluster_b)
        else
          single_linkage_distance(cluster_a, cluster_b)
        end
      end

      def single_linkage_distance(cluster_a, cluster_b)
        min_distance = Float::INFINITY

        cluster_a.data_items.each do |point_a|
          cluster_b.data_items.each do |point_b|
            distance = @configuration.distance_function.call(point_a, point_b)
            min_distance = [min_distance, distance].min
          end
        end

        min_distance
      end

      def complete_linkage_distance(cluster_a, cluster_b)
        max_distance = 0

        cluster_a.data_items.each do |point_a|
          cluster_b.data_items.each do |point_b|
            distance = @configuration.distance_function.call(point_a, point_b)
            max_distance = [max_distance, distance].max
          end
        end

        max_distance
      end

      def average_linkage_distance(cluster_a, cluster_b)
        total_distance = 0
        total_pairs = 0

        cluster_a.data_items.each do |point_a|
          cluster_b.data_items.each do |point_b|
            total_distance += @configuration.distance_function.call(point_a, point_b)
            total_pairs += 1
          end
        end

        total_pairs > 0 ? total_distance / total_pairs : 0
      end

      def ward_linkage_distance(cluster_a, cluster_b)
        # Ward's method minimizes within-cluster sum of squares
        centroid_a = cluster_a.get_mean_or_mode
        centroid_b = cluster_b.get_mean_or_mode

        size_a = cluster_a.data_items.length
        size_b = cluster_b.data_items.length

        # Calculate merged centroid
        merged_centroid = centroid_a.zip(centroid_b).map do |a, b|
          if a.is_a?(Numeric) && b.is_a?(Numeric)
            ((a * size_a) + (b * size_b)) / (size_a + size_b)
          else
            a # For non-numeric attributes, take first cluster's value
          end
        end

        # Calculate increase in within-cluster sum of squares
        ess_a = cluster_a.data_items.sum { |point| @configuration.distance_function.call(point, centroid_a)**2 }
        ess_b = cluster_b.data_items.sum { |point| @configuration.distance_function.call(point, centroid_b)**2 }

        all_points = cluster_a.data_items + cluster_b.data_items
        ess_merged = all_points.sum { |point| @configuration.distance_function.call(point, merged_centroid)**2 }

        ess_merged - ess_a - ess_b
      end

      def find_closest_clusters
        min_distance = Float::INFINITY
        closest_pair = [0, 1]

        @clusters.each_with_index do |_, i|
          @clusters.each_with_index do |_, j|
            next if i >= j

            distance = @distance_matrix[i][j]
            if distance < min_distance
              min_distance = distance
              closest_pair = [i, j]
            end
          end
        end

        closest_pair
      end

      def merge_closest_clusters
        closest_pair = find_closest_clusters
        merge_clusters(closest_pair[0], closest_pair[1])
      end

      def merge_clusters(index_a, index_b)
        # Ensure index_a < index_b for consistent merging
        index_a, index_b = index_b, index_a if index_b < index_a

        # Record merge in dendrogram
        @dendrogram << {
          cluster_a: index_a,
          cluster_b: index_b,
          distance: @distance_matrix[index_a][index_b],
          size: @clusters[index_a].data_items.length + @clusters[index_b].data_items.length
        }

        # Merge cluster_b into cluster_a
        @clusters[index_a].data_items.concat(@clusters[index_b].data_items)

        # Remove cluster_b
        @clusters.delete_at(index_b)

        # Update distance matrix
        update_distance_matrix(index_a, index_b)
      end

      def update_distance_matrix(kept_index, removed_index)
        # Remove row and column for the removed cluster
        @distance_matrix.delete_at(removed_index)
        @distance_matrix.each { |row| row.delete_at(removed_index) }

        # Recalculate distances for the merged cluster
        @clusters.each_with_index do |cluster, index|
          next if index == kept_index

          new_distance = calculate_cluster_distance(@clusters[kept_index], cluster)
          @distance_matrix[kept_index][index] = new_distance
          @distance_matrix[index][kept_index] = new_distance
        end
      end
    end

    # Educational DIANA (Divisive Analysis) implementation
    class EducationalDiana
      attr_reader :clusters, :configuration, :monitor

      def initialize(configuration, monitor)
        @configuration = configuration
        @monitor = monitor
        @clusters = []
      end

      def build(data_set, number_of_clusters)
        @data_set = data_set
        @target_clusters = number_of_clusters

        # Start with all points in one cluster
        @clusters = [@data_set.dup]

        # Split clusters until we reach the target number
        split_largest_cluster while @clusters.length < @target_clusters

        self
      end

      def build_with_steps(data_set, number_of_clusters)
        @data_set = data_set
        @target_clusters = number_of_clusters

        # Step 1: Initialize with all points in one cluster
        @clusters = [@data_set.dup]
        yield({
          step: 1,
          description: 'Initialize with single cluster',
          details: "Starting with all #{@data_set.data_items.length} points in one cluster",
          clusters: @clusters.dup
        })

        step = 2
        while @clusters.length < @target_clusters
          # Find largest cluster
          largest_index = find_largest_cluster_index

          # Split it
          split_cluster(largest_index)

          yield({
            step: step,
            description: 'Split largest cluster',
            details: "Split cluster #{largest_index} into 2 clusters. Now have #{@clusters.length} clusters",
            clusters: @clusters.dup
          })

          step += 1

          # Record iteration for monitoring
          @monitor.record_iteration(@clusters)
        end

        yield({
          step: step,
          description: 'Clustering complete',
          details: "Reached target of #{@target_clusters} clusters",
          clusters: @clusters.dup
        })

        self
      end

      private

      def split_largest_cluster
        largest_index = find_largest_cluster_index
        split_cluster(largest_index)
      end

      def find_largest_cluster_index
        max_size = 0
        max_index = 0

        @clusters.each_with_index do |cluster, index|
          if cluster.data_items.length > max_size
            max_size = cluster.data_items.length
            max_index = index
          end
        end

        max_index
      end

      def split_cluster(cluster_index)
        cluster_to_split = @clusters[cluster_index]

        # Find the point most distant from cluster center
        splinter_point = find_most_distant_point(cluster_to_split)

        # Create new cluster with this point
        new_cluster = Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels, data_items: [splinter_point])

        # Remove point from original cluster
        cluster_to_split.data_items.delete(splinter_point)

        # Iteratively move points to the splinter cluster
        moved_points = true
        while moved_points
          moved_points = false

          cluster_to_split.data_items.each do |point|
            # Calculate average distance to each cluster
            dist_to_original = average_distance_to_cluster(point, cluster_to_split)
            dist_to_splinter = average_distance_to_cluster(point, new_cluster)

            # Move point if it's closer to splinter cluster
            next unless dist_to_splinter < dist_to_original

            new_cluster << point
            cluster_to_split.data_items.delete(point)
            moved_points = true
            break # Restart the iteration
          end
        end

        # Add the new cluster to our list
        @clusters << new_cluster
      end

      def find_most_distant_point(cluster)
        return cluster.data_items.first if cluster.data_items.length == 1

        centroid = cluster.get_mean_or_mode
        max_distance = 0
        most_distant_point = cluster.data_items.first

        cluster.data_items.each do |point|
          distance = @configuration.distance_function.call(point, centroid)
          if distance > max_distance
            max_distance = distance
            most_distant_point = point
          end
        end

        most_distant_point
      end

      def average_distance_to_cluster(point, cluster)
        return 0 if cluster.data_items.empty?

        total_distance = cluster.data_items.sum do |cluster_point|
          @configuration.distance_function.call(point, cluster_point)
        end

        total_distance / cluster.data_items.length
      end
    end
  end
end
