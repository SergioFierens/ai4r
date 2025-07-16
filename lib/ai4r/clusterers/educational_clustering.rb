# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative 'clusterer'
require_relative '../data/data_set'

module Ai4r
  module Clusterers
    # Educational clustering framework designed for students and teachers
    # to understand, experiment with, and visualize clustering algorithms
    class EducationalClustering < Clusterer
      attr_reader :algorithm, :monitor, :configuration, :history

      def initialize(algorithm_type = :k_means, config = {})
        super()
        @algorithm_type = algorithm_type
        @configuration = ClusteringConfiguration.new(config)
        @monitor = ClusteringMonitor.new
        @history = []
        @step_mode = false
        @visualization_enabled = false

        # Initialize the specific algorithm
        @algorithm = create_algorithm(algorithm_type)
      end

      # Enable step-by-step execution for educational purposes
      def enable_step_mode
        @step_mode = true
        self
      end

      # Enable visualization output
      def enable_visualization
        @visualization_enabled = true
        self
      end

      # Configure algorithm parameters with educational explanations
      def configure(params)
        @configuration.update(params)
        @configuration.explain_changes if @configuration.verbose
        self
      end

      # Main clustering method with educational features
      def build(data_set, number_of_clusters)
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        @monitor.start_monitoring(data_set, number_of_clusters)

        puts "Starting #{@algorithm_type} clustering..." if @configuration.verbose
        puts "Dataset: #{data_set.data_items.length} points, #{number_of_clusters} clusters" if @configuration.verbose

        if @step_mode
          build_step_by_step
        else
          build_normal
        end

        @monitor.finish_monitoring(@clusters)
        self
      end

      # Evaluate clustering quality with multiple metrics
      def evaluate_quality
        return nil unless @clusters && @data_set

        ClusteringEvaluator.new(@data_set, @clusters, @configuration.distance_function).evaluate
      end

      # Compare this clustering with another
      def compare_with(other_clustering)
        ClusteringComparator.new(self, other_clustering).compare
      end

      # Export clustering results for external analysis
      def export_data(filename)
        ClusteringExporter.new(@data_set, @clusters, @history).export(filename)
      end

      # Visualize clustering results
      def visualize
        ClusteringVisualizer.new(@data_set, @clusters, @history).visualize
      end

      # Get clusters for compatibility with existing API
      attr_reader :clusters

      # Classify a data item (existing API compatibility)
      def eval(data_item)
        return nil unless @clusters

        min_distance = Float::INFINITY
        best_cluster = 0

        @clusters.each_with_index do |cluster, index|
          distance = calculate_distance_to_cluster(data_item, cluster)
          if distance < min_distance
            min_distance = distance
            best_cluster = index
          end
        end

        best_cluster
      end

      private

      def create_algorithm(algorithm_type)
        case algorithm_type
        when :k_means
          EducationalKMeans.new(@configuration, @monitor)
        when :hierarchical_single
          EducationalHierarchical.new(@configuration, @monitor, :single)
        when :hierarchical_complete
          EducationalHierarchical.new(@configuration, @monitor, :complete)
        when :diana
          EducationalDiana.new(@configuration, @monitor)
        else
          raise ArgumentError, "Unknown algorithm type: #{algorithm_type}"
        end
      end

      def build_step_by_step
        puts "\n=== Step-by-step clustering execution ===" if @configuration.verbose
        @algorithm.build_with_steps(@data_set, @number_of_clusters) do |step_info|
          @history << step_info

          if @configuration.verbose
            puts "\nStep #{step_info[:step]}: #{step_info[:description]}"
            puts step_info[:details] if step_info[:details]
          end

          visualize_step(step_info) if @visualization_enabled

          if @step_mode
            puts 'Press Enter to continue...'
            gets
          end
        end

        @clusters = @algorithm.clusters
      end

      def build_normal
        @algorithm.build(@data_set, @number_of_clusters)
        @clusters = @algorithm.clusters
      end

      def calculate_distance_to_cluster(data_item, cluster)
        case @algorithm_type
        when :k_means
          # Distance to centroid
          centroid = cluster.get_mean_or_mode
          @configuration.distance_function.call(data_item, centroid)
        else
          # Average distance to all points in cluster
          return Float::INFINITY if cluster.data_items.empty?

          total_distance = cluster.data_items.sum do |cluster_item|
            @configuration.distance_function.call(data_item, cluster_item)
          end
          total_distance / cluster.data_items.length
        end
      end

      def visualize_step(step_info)
        ClusteringVisualizer.new(@data_set, step_info[:clusters], @history).visualize_step(step_info)
      end
    end

    # Configuration class for clustering parameters
    class ClusteringConfiguration
      attr_accessor :distance_function, :max_iterations, :tolerance, :verbose, :initialization_strategy, :linkage_type

      def initialize(params = {})
        # Default parameters
        @distance_function = params[:distance_function] || default_distance_function
        @max_iterations = params[:max_iterations] || 100
        @tolerance = params[:tolerance] || 1e-4
        @verbose = params[:verbose] || false
        @initialization_strategy = params[:initialization_strategy] || :random
        @linkage_type = params[:linkage_type] || :single

        @explanations = {}
      end

      def update(params)
        params.each do |key, value|
          next unless respond_to?("#{key}=")

          old_value = send(key)
          send("#{key}=", value)
          @explanations[key] = explain_parameter_change(key, old_value, value)
        end
      end

      def explain_changes
        @explanations.each do |param, explanation|
          puts "#{param}: #{explanation}"
        end
        @explanations.clear
      end

      def explain_all_parameters
        puts "\n=== Clustering Parameters Explanation ==="
        puts "distance_function: #{explain_distance_function}"
        puts "max_iterations: Maximum number of iterations before stopping (current: #{@max_iterations})"
        puts "tolerance: Convergence threshold for stopping criteria (current: #{@tolerance})"
        puts "initialization_strategy: How to choose initial cluster centers (current: #{@initialization_strategy})"
        puts "linkage_type: For hierarchical clustering, how to measure cluster distance (current: #{@linkage_type})"
      end

      private

      def default_distance_function
        ->(a, b) do
          # Euclidean distance for numeric attributes
          numeric_a = a.select { |attr| attr.is_a?(Numeric) }
          numeric_b = b.select { |attr| attr.is_a?(Numeric) }

          sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y)**2 }
          Math.sqrt(sum)
        end
      end

      def explain_parameter_change(param, old_value, new_value)
        case param
        when :distance_function
          'Changed distance function - this affects how similarity between points is calculated'
        when :max_iterations
          "Changed max iterations from #{old_value} to #{new_value} - affects convergence time"
        when :tolerance
          "Changed tolerance from #{old_value} to #{new_value} - affects convergence sensitivity"
        when :initialization_strategy
          "Changed initialization from #{old_value} to #{new_value} - affects starting point selection"
        else
          "Changed #{param} from #{old_value} to #{new_value}"
        end
      end

      def explain_distance_function
        'Function used to calculate distance between data points. Default is Euclidean distance.'
      end
    end

    # Monitoring class for tracking clustering progress
    class ClusteringMonitor
      attr_reader :start_time, :iterations, :convergence_history

      def initialize
        @iterations = 0
        @convergence_history = []
        @step_history = []
      end

      def start_monitoring(data_set, number_of_clusters)
        @start_time = Time.now
        @data_set = data_set
        @number_of_clusters = number_of_clusters
        @iterations = 0
        @convergence_history.clear
        @step_history.clear
      end

      def record_iteration(clusters, centroids = nil, change_measure = nil)
        @iterations += 1

        step_info = {
          iteration: @iterations,
          timestamp: Time.now,
          clusters: clusters,
          centroids: centroids,
          change_measure: change_measure
        }

        @step_history << step_info

        if change_measure
          @convergence_history << {
            iteration: @iterations,
            change: change_measure,
            converged: change_measure < 1e-4
          }
        end

        step_info
      end

      def finish_monitoring(final_clusters)
        @end_time = Time.now
        @final_clusters = final_clusters
        @total_time = @end_time - @start_time
      end

      def summary
        return 'Monitoring not started' unless @start_time

        summary = {
          total_time: @total_time,
          iterations: @iterations,
          converged: @convergence_history.last&.dig(:converged) || false,
          final_clusters: @final_clusters&.length || 0
        }

        summary[:convergence_rate] = calculate_convergence_rate if @convergence_history.any?

        summary
      end

      def plot_convergence
        return 'No convergence data available' if @convergence_history.empty?

        puts "\n=== Convergence Plot ==="
        puts 'Iteration | Change'
        puts '-' * 20

        @convergence_history.each do |point|
          bar_length = [(point[:change] * 50).to_i, 50].min
          bar = '█' * bar_length
          puts format('%9d | %s %.6f', point[:iteration], bar, point[:change])
        end

        puts "\nConverged: #{@convergence_history.last[:converged] ? 'Yes' : 'No'}"
      end

      private

      def calculate_convergence_rate
        return 0 if @convergence_history.length < 2

        changes = @convergence_history.map { |h| h[:change] }
        return 0 if changes.first == 0

        # Calculate average rate of change reduction
        rate_sum = 0
        (1...changes.length).each do |i|
          rate_sum += (changes[i - 1] - changes[i]) / changes[i - 1] if changes[i - 1] > 0
        end

        rate_sum / (changes.length - 1)
      end
    end

    # Clustering quality evaluation
    class ClusteringEvaluator
      def initialize(data_set, clusters, distance_function)
        @data_set = data_set
        @clusters = clusters
        @distance_function = distance_function
      end

      def evaluate
        {
          silhouette_score: calculate_silhouette_score,
          within_cluster_sum_of_squares: calculate_wcss,
          between_cluster_sum_of_squares: calculate_bcss,
          davies_bouldin_index: calculate_davies_bouldin_index,
          calinski_harabasz_index: calculate_calinski_harabasz_index,
          cluster_sizes: @clusters.map { |c| c.data_items.length },
          total_points: @data_set.data_items.length
        }
      end

      private

      def calculate_silhouette_score
        return 0 if @clusters.length < 2

        total_silhouette = 0
        total_points = 0

        @clusters.each_with_index do |cluster, cluster_index|
          cluster.data_items.each do |point|
            a = average_intra_cluster_distance(point, cluster)
            b = min_inter_cluster_distance(point, cluster_index)

            silhouette = b == 0 ? 0 : (b - a) / [a, b].max
            total_silhouette += silhouette
            total_points += 1
          end
        end

        total_points > 0 ? total_silhouette / total_points : 0
      end

      def calculate_wcss
        @clusters.sum do |cluster|
          return 0 if cluster.data_items.empty?

          centroid = cluster.get_mean_or_mode
          cluster.data_items.sum do |point|
            @distance_function.call(point, centroid)**2
          end
        end
      end

      def calculate_bcss
        return 0 if @clusters.empty?

        overall_centroid = @data_set.get_mean_or_mode

        @clusters.sum do |cluster|
          return 0 if cluster.data_items.empty?

          cluster_centroid = cluster.get_mean_or_mode
          cluster.data_items.length * (@distance_function.call(cluster_centroid, overall_centroid)**2)
        end
      end

      def calculate_davies_bouldin_index
        return 0 if @clusters.length < 2

        cluster_dispersions = @clusters.map { |cluster| calculate_cluster_dispersion(cluster) }

        total_db = 0
        @clusters.each_with_index do |cluster_i, i|
          max_ratio = 0
          @clusters.each_with_index do |cluster_j, j|
            next if i == j

            centroid_i = cluster_i.get_mean_or_mode
            centroid_j = cluster_j.get_mean_or_mode
            centroid_distance = @distance_function.call(centroid_i, centroid_j)

            ratio = centroid_distance > 0 ? (cluster_dispersions[i] + cluster_dispersions[j]) / centroid_distance : 0
            max_ratio = [max_ratio, ratio].max
          end
          total_db += max_ratio
        end

        total_db / @clusters.length
      end

      def calculate_calinski_harabasz_index
        return 0 if @clusters.length < 2

        bcss = calculate_bcss
        wcss = calculate_wcss

        n = @data_set.data_items.length
        k = @clusters.length

        return 0 if wcss == 0 || k == 1

        (bcss / (k - 1)) / (wcss / (n - k))
      end

      def average_intra_cluster_distance(point, cluster)
        other_points = cluster.data_items.reject { |p| p == point }
        return 0 if other_points.empty?

        total_distance = other_points.sum { |p| @distance_function.call(point, p) }
        total_distance / other_points.length
      end

      def min_inter_cluster_distance(point, current_cluster_index)
        min_distance = Float::INFINITY

        @clusters.each_with_index do |cluster, cluster_index|
          next if cluster_index == current_cluster_index

          avg_distance = cluster.data_items.sum { |p| @distance_function.call(point, p) } / cluster.data_items.length
          min_distance = [min_distance, avg_distance].min
        end

        min_distance == Float::INFINITY ? 0 : min_distance
      end

      def calculate_cluster_dispersion(cluster)
        return 0 if cluster.data_items.empty?

        centroid = cluster.get_mean_or_mode
        total_distance = cluster.data_items.sum { |point| @distance_function.call(point, centroid) }
        total_distance / cluster.data_items.length
      end
    end

    # Visualization helper for clustering results
    class ClusteringVisualizer
      def initialize(data_set, clusters, history = [])
        @data_set = data_set
        @clusters = clusters
        @history = history
      end

      def visualize
        puts "\n=== Clustering Results Visualization ==="
        puts "Dataset: #{@data_set.data_items.length} points"
        puts "Clusters: #{@clusters.length}"

        visualize_cluster_summary
        visualize_2d_plot if can_visualize_2d?
      end

      def visualize_step(step_info)
        puts "\n--- Step #{step_info[:step]} Visualization ---"
        puts step_info[:description]

        return unless step_info[:clusters]

        step_info[:clusters].each_with_index do |cluster, index|
          puts "  Cluster #{index}: #{cluster.data_items.length} points"
        end
      end

      private

      def visualize_cluster_summary
        puts "\nCluster Summary:"
        puts '=' * 40

        @clusters.each_with_index do |cluster, index|
          puts "Cluster #{index}:"
          puts "  Points: #{cluster.data_items.length}"

          unless cluster.data_items.empty?
            centroid = cluster.get_mean_or_mode
            puts "  Centroid: #{centroid.map { |v| v.is_a?(Numeric) ? v.round(3) : v }.join(', ')}"

            # Calculate cluster statistics
            if cluster.data_items.length > 1
              distances = cluster.data_items.map do |point|
                numeric_point = point.select { |attr| attr.is_a?(Numeric) }
                numeric_centroid = centroid.select { |attr| attr.is_a?(Numeric) }

                sum = numeric_point.zip(numeric_centroid).sum { |x, y| (x - y)**2 }
                Math.sqrt(sum)
              end

              puts "  Avg distance to centroid: #{(distances.sum / distances.length).round(3)}"
              puts "  Max distance to centroid: #{distances.max.round(3)}"
            end
          end
          puts
        end
      end

      def can_visualize_2d?
        return false if @data_set.data_items.empty?

        # Check if we have at least 2 numeric attributes
        first_item = @data_set.data_items.first
        numeric_attrs = first_item.select { |attr| attr.is_a?(Numeric) }
        numeric_attrs.length >= 2
      end

      def visualize_2d_plot
        puts "\n2D Scatter Plot (using first 2 numeric attributes):"
        puts '=' * 50

        # Create a simple ASCII plot
        plot_width = 40
        plot_height = 20

        # Get x and y coordinates (first 2 numeric attributes)
        points = @data_set.data_items.map do |item|
          numeric_attrs = item.select { |attr| attr.is_a?(Numeric) }
          [numeric_attrs[0], numeric_attrs[1]]
        end

        # Calculate bounds
        x_values = points.map(&:first)
        y_values = points.map(&:last)

        x_min, x_max = x_values.minmax
        y_min, y_max = y_values.minmax

        # Create plot grid
        plot = Array.new(plot_height) { Array.new(plot_width, '.') }

        # Plot points
        @clusters.each_with_index do |cluster, cluster_index|
          symbol = ('A'.ord + cluster_index).chr

          cluster.data_items.each do |item|
            numeric_attrs = item.select { |attr| attr.is_a?(Numeric) }
            x, y = numeric_attrs[0], numeric_attrs[1]

            # Scale to plot coordinates
            plot_x = ((x - x_min) / (x_max - x_min) * (plot_width - 1)).to_i
            plot_y = ((y - y_min) / (y_max - y_min) * (plot_height - 1)).to_i

            plot[plot_height - 1 - plot_y][plot_x] = symbol
          end
        end

        # Print plot
        plot.each { |row| puts row.join(' ') }

        puts "\nLegend:"
        @clusters.each_with_index do |cluster, index|
          symbol = ('A'.ord + index).chr
          puts "  #{symbol} = Cluster #{index} (#{cluster.data_items.length} points)"
        end
      end
    end

    # Export clustering results to various formats
    class ClusteringExporter
      def initialize(data_set, clusters, history = [])
        @data_set = data_set
        @clusters = clusters
        @history = history
      end

      def export(filename)
        case File.extname(filename).downcase
        when '.csv'
          export_csv(filename)
        when '.json'
          export_json(filename)
        else
          export_text(filename)
        end
      end

      private

      def export_csv(filename)
        require 'csv'

        CSV.open(filename, 'w') do |csv|
          # Header
          headers = ['cluster_id'] + @data_set.data_labels
          csv << headers

          # Data points with cluster assignments
          @clusters.each_with_index do |cluster, cluster_index|
            cluster.data_items.each do |item|
              csv << ([cluster_index] + item)
            end
          end
        end

        puts "Exported clustering results to #{filename}"
      end

      def export_json(filename)
        require 'json'

        result = {
          clusters: @clusters.map.with_index do |cluster, index|
            {
              id: index,
              size: cluster.data_items.length,
              centroid: cluster.get_mean_or_mode,
              points: cluster.data_items
            }
          end,
          summary: {
            total_points: @data_set.data_items.length,
            num_clusters: @clusters.length,
            data_labels: @data_set.data_labels
          }
        }

        File.write(filename, JSON.pretty_generate(result))
        puts "Exported clustering results to #{filename}"
      end

      def export_text(filename)
        File.open(filename, 'w') do |file|
          file.puts 'Clustering Results'
          file.puts '=' * 50
          file.puts "Dataset: #{@data_set.data_items.length} points"
          file.puts "Clusters: #{@clusters.length}"
          file.puts

          @clusters.each_with_index do |cluster, index|
            file.puts "Cluster #{index}:"
            file.puts "  Size: #{cluster.data_items.length}"
            file.puts "  Centroid: #{cluster.get_mean_or_mode}"
            file.puts '  Points:'
            cluster.data_items.each { |point| file.puts "    #{point}" }
            file.puts
          end
        end

        puts "Exported clustering results to #{filename}"
      end
    end

    # Comparison tool for different clustering results
    class ClusteringComparator
      def initialize(clustering1, clustering2)
        @clustering1 = clustering1
        @clustering2 = clustering2
      end

      def compare
        puts "\n=== Clustering Comparison ==="

        quality1 = @clustering1.evaluate_quality
        quality2 = @clustering2.evaluate_quality

        puts "Algorithm 1: #{@clustering1.algorithm_type}"
        puts "Algorithm 2: #{@clustering2.algorithm_type}"
        puts

        puts 'Quality Metrics Comparison:'
        puts '-' * 40

        quality1.each do |metric, value1|
          value2 = quality2[metric]
          if value1.is_a?(Numeric) && value2.is_a?(Numeric)
            better = value1 > value2 ? 'Algorithm 1' : 'Algorithm 2'
            puts format('%-25s: %.4f vs %.4f (%s)', metric, value1, value2, better)
          else
            puts format('%-25s: %s vs %s', metric, value1, value2)
          end
        end

        {
          algorithm1: @clustering1.algorithm_type,
          algorithm2: @clustering2.algorithm_type,
          quality1: quality1,
          quality2: quality2
        }
      end
    end
  end
end
