# frozen_string_literal: true

# DBSCAN (Density-Based Spatial Clustering of Applications with Noise)
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'clusterer'
require_relative '../data/data_set'

module Ai4r
  module Clusterers
    # DBSCAN clustering algorithm implementation
    #
    # DBSCAN is a density-based clustering algorithm that groups together points
    # that are closely packed while marking points in low-density regions as outliers.
    #
    # Key concepts:
    # - ε (eps): Maximum distance between two points to be considered neighbors
    # - MinPts: Minimum number of points required to form a dense region
    # - Core point: Point with at least MinPts neighbors within ε distance
    # - Border point: Non-core point within ε distance of a core point
    # - Noise point: Point that is neither core nor border
    #
    # Educational advantages:
    # - Discovers clusters of arbitrary shape
    # - Handles noise and outliers naturally
    # - No need to specify number of clusters beforehand
    # - Deterministic results (given same parameters)
    class DBSCAN < Clusterer
      attr_reader :eps, :min_pts, :clusters, :noise_points, :core_points, :data_set, :point_types, :cluster_assignments

      # Point types for educational understanding
      UNVISITED = 0
      NOISE = -1
      CORE = 1
      BORDER = 2

      parameters_info eps: 'Maximum distance between two points to be considered neighbors. ' \
                           'Smaller values create more, tighter clusters. Larger values merge clusters.',
                      min_pts: 'Minimum number of points required to form a dense region. ' \
                               'Higher values require denser neighborhoods to form clusters.',
                      distance_function: 'Custom distance function. Default is Euclidean distance.',
                      educational_mode: 'Enable step-by-step execution with detailed explanations.'

      def initialize
        super
        @eps = 0.5
        @min_pts = 5
        @distance_function = nil
        @educational_mode = false
        @step_callback = nil
      end

      # Enable educational step-by-step mode
      def enable_educational_mode(&callback)
        @educational_mode = true
        @step_callback = callback if block_given?
        self
      end

      # Build clusters using DBSCAN algorithm
      def build(data_set, eps = @eps, min_pts = @min_pts)
        @data_set = data_set
        @eps = eps
        @min_pts = min_pts

        # Initialize data structures
        initialize_clustering

        if @educational_mode
          educational_explanation
          build_with_steps
        else
          build_normal
        end

        finalize_results
        self
      end

      # Classify a new data point
      def eval(data_item)
        return nil unless @clusters

        # Find the closest cluster
        min_distance = Float::INFINITY
        best_cluster = -1 # Default to noise

        @clusters.each_with_index do |cluster, cluster_id|
          cluster.data_items.each do |cluster_point|
            dist = distance(data_item, cluster_point)
            if dist <= @eps && dist < min_distance
              min_distance = dist
              best_cluster = cluster_id
            end
          end
        end

        best_cluster
      end

      # Get detailed clustering statistics
      def clustering_stats
        return nil unless @clusters

        {
          num_clusters: @clusters.length,
          num_noise_points: @noise_points.length,
          num_core_points: @core_points.length,
          cluster_sizes: @clusters.map { |c| c.data_items.length },
          noise_ratio: @noise_points.length.to_f / @data_set.data_items.length,
          parameters: { eps: @eps, min_pts: @min_pts }
        }
      end

      # Educational explanation of DBSCAN concepts
      def explain_concepts
        puts <<~EXPLANATION
          === DBSCAN Clustering Algorithm ===

          DBSCAN (Density-Based Spatial Clustering of Applications with Noise)

          Key Concepts:

          1. ε (epsilon): Maximum distance for points to be neighbors
             Current value: #{@eps}
          #{'   '}
          2. MinPts: Minimum points needed to form a dense region
             Current value: #{@min_pts}
          #{'   '}
          3. Point Types:
             • Core Point: Has ≥ MinPts neighbors within ε distance
             • Border Point: Within ε of a core point, but not core itself
             • Noise Point: Neither core nor border (outlier)
          #{'   '}
          4. Cluster Formation:
             • Start with a core point
             • Add all density-reachable points
             • Density-reachable = connected through core points
          #{'   '}
          Advantages:
          • Finds clusters of any shape
          • Automatically determines number of clusters
          • Handles noise and outliers
          • Deterministic results

          Disadvantages:
          • Sensitive to ε and MinPts parameters
          • Struggles with varying densities
          • Can be expensive for large datasets

          Parameter Guidelines:
          • ε: Use k-distance plot to find "knee"
          • MinPts: Often set to 2×dimensions, minimum 4

        EXPLANATION
      end

      # Visualize point types for educational purposes
      def visualize_point_types
        return unless @data_set && @point_types

        puts "\n=== Point Type Analysis ==="
        puts "Total points: #{@data_set.data_items.length}"

        type_counts = { core: 0, border: 0, noise: 0 }
        @point_types.each do |type|
          case type
          when CORE then type_counts[:core] += 1
          when BORDER then type_counts[:border] += 1
          when NOISE then type_counts[:noise] += 1
          end
        end

        puts "Core points: #{type_counts[:core]} (#{(type_counts[:core] * 100.0 / @data_set.data_items.length).round(1)}%)"
        puts "Border points: #{type_counts[:border]} (#{(type_counts[:border] * 100.0 / @data_set.data_items.length).round(1)}%)"
        puts "Noise points: #{type_counts[:noise]} (#{(type_counts[:noise] * 100.0 / @data_set.data_items.length).round(1)}%)"

        # Simple visualization for 2D data
        visualize_2d_clustering if can_visualize_2d?
      end

      protected

      def distance(a, b)
        return @distance_function.call(a, b) if @distance_function

        # Default Euclidean distance
        numeric_a = a.select { |attr| attr.is_a?(Numeric) }
        numeric_b = b.select { |attr| attr.is_a?(Numeric) }

        sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y)**2 }
        Math.sqrt(sum)
      end

      private

      def initialize_clustering
        @clusters = []
        @noise_points = []
        @core_points = []
        @visited = Array.new(@data_set.data_items.length, false)
        @cluster_assignments = Array.new(@data_set.data_items.length, -1)
        @point_types = Array.new(@data_set.data_items.length, UNVISITED)
        @current_cluster_id = 0
      end

      def educational_explanation
        puts "\n#{'=' * 60}"
        puts 'DBSCAN Educational Execution'
        puts '=' * 60
        puts "Dataset: #{@data_set.data_items.length} points"
        puts "Parameters: ε=#{@eps}, MinPts=#{@min_pts}"
        puts
        explain_concepts
        puts "\nStarting clustering process..."
        puts '=' * 60
      end

      def build_with_steps
        @data_set.data_items.each_with_index do |point, point_index|
          next if @visited[point_index]

          step_info = {
            step: "Examining point #{point_index}",
            point: point,
            point_index: point_index
          }

          @visited[point_index] = true
          neighbors = find_neighbors(point_index)

          step_info[:neighbors] = neighbors
          step_info[:neighbor_count] = neighbors.length

          if neighbors.length >= @min_pts
            # Core point - start new cluster
            @point_types[point_index] = CORE
            @core_points << point

            step_info[:point_type] = 'CORE'
            step_info[:action] = "Starting new cluster #{@current_cluster_id}"

            log_step(step_info)

            cluster = Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels)
            expand_cluster(cluster, point_index, neighbors)
            @clusters << cluster
            @current_cluster_id += 1
          else
            # Mark as noise (might be changed to border later)
            @point_types[point_index] = NOISE
            step_info[:point_type] = 'NOISE (tentative)'
            step_info[:action] = 'Not enough neighbors - marked as noise'
            log_step(step_info)
          end
        end

        # Second pass to identify border points
        identify_border_points
      end

      def build_normal
        @data_set.data_items.each_with_index do |point, point_index|
          next if @visited[point_index]

          @visited[point_index] = true
          neighbors = find_neighbors(point_index)

          if neighbors.length >= @min_pts
            @point_types[point_index] = CORE
            @core_points << point

            cluster = Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels)
            expand_cluster(cluster, point_index, neighbors)
            @clusters << cluster
            @current_cluster_id += 1
          else
            @point_types[point_index] = NOISE
          end
        end

        identify_border_points
      end

      def find_neighbors(point_index)
        neighbors = []
        point = @data_set.data_items[point_index]

        @data_set.data_items.each_with_index do |other_point, other_index|
          next if point_index == other_index

          neighbors << other_index if distance(point, other_point) <= @eps
        end

        neighbors
      end

      def expand_cluster(cluster, point_index, neighbors)
        # Add the core point to cluster
        cluster << @data_set.data_items[point_index]
        @cluster_assignments[point_index] = @current_cluster_id

        i = 0
        while i < neighbors.length
          neighbor_index = neighbors[i]

          unless @visited[neighbor_index]
            @visited[neighbor_index] = true
            neighbor_neighbors = find_neighbors(neighbor_index)

            if neighbor_neighbors.length >= @min_pts
              # This neighbor is also a core point
              @point_types[neighbor_index] = CORE
              @core_points << @data_set.data_items[neighbor_index]
              neighbors.concat(neighbor_neighbors)
            end
          end

          # Add to cluster if not already assigned
          if @cluster_assignments[neighbor_index] == -1
            cluster << @data_set.data_items[neighbor_index]
            @cluster_assignments[neighbor_index] = @current_cluster_id
          end

          i += 1
        end
      end

      def identify_border_points
        @data_set.data_items.each_with_index do |point, point_index|
          next unless @point_types[point_index] == NOISE

          # Check if this noise point is within ε of any core point
          @core_points.each do |core_point|
            if distance(point, core_point) <= @eps
              @point_types[point_index] = BORDER
              break
            end
          end

          # If still noise, add to noise points collection
          @noise_points << point if @point_types[point_index] == NOISE
        end
      end

      def finalize_results
        # Create final cluster structure compatible with existing API
        @clusters = @clusters.reject { |cluster| cluster.data_items.empty? }
      end

      def log_step(step_info)
        return unless @educational_mode

        puts "\nStep: #{step_info[:step]}"
        puts "Point: #{step_info[:point].map { |x| x.round(3) if x.is_a?(Numeric) }.join(', ')}"
        puts "Neighbors found: #{step_info[:neighbor_count]}"
        puts "Point type: #{step_info[:point_type]}"
        puts "Action: #{step_info[:action]}"

        @step_callback&.call(step_info)

        puts 'Press Enter to continue...' if @educational_mode
        gets if @educational_mode
      end

      def can_visualize_2d?
        return false if @data_set.data_items.empty?

        first_item = @data_set.data_items.first
        numeric_attrs = first_item.select { |attr| attr.is_a?(Numeric) }
        numeric_attrs.length >= 2
      end

      def visualize_2d_clustering
        puts "\n=== 2D DBSCAN Visualization ==="
        puts 'Legend: C=Core, B=Border, N=Noise, Numbers=Cluster ID'
        puts

        # Create simple ASCII visualization
        plot_width = 50
        plot_height = 20

        # Get coordinates
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
        @data_set.data_items.each_with_index do |item, index|
          numeric_attrs = item.select { |attr| attr.is_a?(Numeric) }
          x, y = numeric_attrs[0], numeric_attrs[1]

          # Scale to plot coordinates
          plot_x = ((x - x_min) / (x_max - x_min) * (plot_width - 1)).to_i
          plot_y = ((y - y_min) / (y_max - y_min) * (plot_height - 1)).to_i

          # Determine symbol based on point type and cluster
          symbol = case @point_types[index]
                   when CORE
                     cluster_id = @cluster_assignments[index]
                     cluster_id >= 0 ? cluster_id.to_s : 'C'
                   when BORDER
                     'B'
                   when NOISE
                     'N'
                   else
                     '?'
                   end

          plot[plot_height - 1 - plot_y][plot_x] = symbol
        end

        # Print plot
        plot.each { |row| puts row.join }

        puts "\nCluster Statistics:"
        puts "Clusters found: #{@clusters.length}"
        puts "Noise points: #{@noise_points.length}"
        @clusters.each_with_index do |cluster, id|
          puts "Cluster #{id}: #{cluster.data_items.length} points"
        end
      end
    end

    # Educational DBSCAN parameter helper
    class DBSCANParameterHelper
      # Suggest ε parameter using k-distance plot method
      def self.suggest_eps(data_set, k = 4, distance_function = nil)
        distance_function ||= ->(a, b) do
          numeric_a = a.select { |attr| attr.is_a?(Numeric) }
          numeric_b = b.select { |attr| attr.is_a?(Numeric) }
          sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y)**2 }
          Math.sqrt(sum)
        end

        k_distances = []

        data_set.data_items.each do |point|
          distances = []

          data_set.data_items.each do |other_point|
            next if point == other_point

            distances << distance_function.call(point, other_point)
          end

          distances.sort!
          k_distances << distances[k - 1] if distances.length >= k
        end

        k_distances.sort!

        # Find the "knee" point - simplified heuristic
        # In practice, you'd plot this and visually inspect
        knee_index = (k_distances.length * 0.95).to_i
        suggested_eps = k_distances[knee_index]

        {
          suggested_eps: suggested_eps,
          k_distances: k_distances,
          knee_index: knee_index,
          explanation: k_distance_explanation(k, suggested_eps)
        }
      end

      # Suggest MinPts parameter
      def self.suggest_min_pts(data_set)
        dimensions = count_numeric_dimensions(data_set)

        # Common heuristic: 2 * dimensions, with minimum of 4
        suggested = [2 * dimensions, 4].max

        {
          suggested_min_pts: suggested,
          dimensions: dimensions,
          explanation: min_pts_explanation(suggested, dimensions)
        }
      end

      # Run parameter analysis for educational purposes
      def self.analyze_parameters(data_set)
        puts '=== DBSCAN Parameter Analysis ==='
        puts

        eps_analysis = suggest_eps(data_set)
        min_pts_analysis = suggest_min_pts(data_set)

        puts "Dataset: #{data_set.data_items.length} points"
        puts "Dimensions: #{min_pts_analysis[:dimensions]}"
        puts
        puts eps_analysis[:explanation]
        puts
        puts min_pts_analysis[:explanation]
        puts

        # Test different parameter combinations
        puts 'Parameter Sensitivity Analysis:'
        puts '=' * 40

        test_parameters = [
          { eps: eps_analysis[:suggested_eps] * 0.5, min_pts: min_pts_analysis[:suggested_min_pts] },
          { eps: eps_analysis[:suggested_eps], min_pts: min_pts_analysis[:suggested_min_pts] },
          { eps: eps_analysis[:suggested_eps] * 1.5, min_pts: min_pts_analysis[:suggested_min_pts] },
          { eps: eps_analysis[:suggested_eps], min_pts: min_pts_analysis[:suggested_min_pts] / 2 },
          { eps: eps_analysis[:suggested_eps], min_pts: min_pts_analysis[:suggested_min_pts] * 2 }
        ]

        test_parameters.each_with_index do |params, index|
          dbscan = DBSCAN.new
          dbscan.build(data_set, params[:eps], params[:min_pts])
          stats = dbscan.clustering_stats

          puts "Test #{index + 1}: ε=#{params[:eps].round(3)}, MinPts=#{params[:min_pts]}"
          puts "  Clusters: #{stats[:num_clusters]}, Noise: #{stats[:num_noise_points]} (#{(stats[:noise_ratio] * 100).round(1)}%)"
        end

        {
          eps_analysis: eps_analysis,
          min_pts_analysis: min_pts_analysis,
          recommended: {
            eps: eps_analysis[:suggested_eps],
            min_pts: min_pts_analysis[:suggested_min_pts]
          }
        }
      end

      def self.count_numeric_dimensions(data_set)
        return 0 if data_set.data_items.empty?

        first_item = data_set.data_items.first
        first_item.count { |attr| attr.is_a?(Numeric) }
      end

      def self.k_distance_explanation(k, suggested_eps)
        <<~EXPLANATION
          ε (Epsilon) Parameter Selection:

          Method: k-distance plot
          • Calculate distance to #{k}th nearest neighbor for each point
          • Sort these distances in ascending order
          • Find the "knee" point where distances sharply increase
          • Points beyond the knee are likely outliers

          Suggested ε: #{suggested_eps.round(4)}

          Interpretation:
          • Smaller ε: More clusters, more noise points
          • Larger ε: Fewer clusters, points merge together
          • ε too small: All points become noise
          • ε too large: All points in one cluster

          Tips:
          • Plot k-distances and visually inspect the knee
          • Try ε values around the suggested value
          • Consider domain knowledge about natural separations
        EXPLANATION
      end

      def self.min_pts_explanation(suggested, dimensions)
        <<~EXPLANATION
          MinPts Parameter Selection:

          Suggested MinPts: #{suggested}

          Heuristic: 2 × dimensions (#{dimensions}) = #{2 * dimensions}, minimum 4

          Interpretation:
          • Smaller MinPts: More sensitive to local density variations
          • Larger MinPts: Requires denser neighborhoods
          • MinPts too small: Noisy data creates many small clusters
          • MinPts too large: Small meaningful clusters become noise

          Guidelines:
          • Minimum value: 3 (to form meaningful 2D cluster)
          • Common range: 4 to 10 for most applications
          • Higher dimensions: increase MinPts accordingly
          • Noisy data: use higher MinPts values
        EXPLANATION
      end
    end
  end
end
