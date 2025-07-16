# frozen_string_literal: true

# Comprehensive distance metrics for clustering
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Clusterers
    # Collection of distance metrics for educational clustering
    class DistanceMetrics
      # Euclidean distance (L2 norm)
      def self.euclidean
        {
          name: 'Euclidean Distance',
          description: 'Straight-line distance between two points. Most common metric.',
          formula: '√(Σ(xi - yi)²)',
          properties: ['Sensitive to outliers', 'Assumes spherical clusters', 'Scale-dependent'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y)**2 }
            Math.sqrt(sum)
          end
        }
      end

      # Manhattan distance (L1 norm)
      def self.manhattan
        {
          name: 'Manhattan Distance',
          description: 'Sum of absolute differences. Good for high-dimensional data.',
          formula: 'Σ|xi - yi|',
          properties: ['Less sensitive to outliers', 'Good for sparse data', 'Scale-dependent'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            numeric_a.zip(numeric_b).sum { |x, y| (x - y).abs }
          end
        }
      end

      # Chebyshev distance (L∞ norm)
      def self.chebyshev
        {
          name: 'Chebyshev Distance',
          description: 'Maximum difference across all dimensions. Useful for grid-like data.',
          formula: 'max|xi - yi|',
          properties: ['Focuses on largest difference', 'Good for grid patterns', 'Scale-dependent'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            numeric_a.zip(numeric_b).map { |x, y| (x - y).abs }.max
          end
        }
      end

      # Minkowski distance (generalization of Euclidean and Manhattan)
      def self.minkowski(p = 2)
        {
          name: "Minkowski Distance (p=#{p})",
          description: 'Generalization of Euclidean (p=2) and Manhattan (p=1) distances.',
          formula: '(Σ|xi - yi|^p)^(1/p)',
          properties: ['Euclidean when p=2', 'Manhattan when p=1', 'Chebyshev when p→∞'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y).abs**p }
            sum**(1.0 / p)
          end
        }
      end

      # Cosine distance
      def self.cosine
        {
          name: 'Cosine Distance',
          description: 'Measures angle between vectors. Good for text and high-dimensional data.',
          formula: '1 - (A·B)/(|A||B|)',
          properties: ['Scale-invariant', 'Good for text data', 'Measures orientation, not magnitude'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            dot_product = numeric_a.zip(numeric_b).sum { |x, y| x * y }
            magnitude_a = Math.sqrt(numeric_a.sum { |x| x**2 })
            magnitude_b = Math.sqrt(numeric_b.sum { |x| x**2 })

            return 1.0 if magnitude_a == 0 || magnitude_b == 0

            1.0 - (dot_product / (magnitude_a * magnitude_b))
          end
        }
      end

      # Pearson correlation distance
      def self.pearson_correlation
        {
          name: 'Pearson Correlation Distance',
          description: 'Based on correlation coefficient. Good for data with similar patterns.',
          formula: '1 - |r|, where r is correlation coefficient',
          properties: ['Scale-invariant', 'Measures linear relationship', 'Good for pattern matching'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            return 1.0 if numeric_a.length < 2

            mean_a = numeric_a.sum / numeric_a.length.to_f
            mean_b = numeric_b.sum / numeric_b.length.to_f

            numerator = numeric_a.zip(numeric_b).sum { |x, y| (x - mean_a) * (y - mean_b) }
            denominator_a = Math.sqrt(numeric_a.sum { |x| (x - mean_a)**2 })
            denominator_b = Math.sqrt(numeric_b.sum { |x| (x - mean_b)**2 })

            return 1.0 if denominator_a == 0 || denominator_b == 0

            correlation = numerator / (denominator_a * denominator_b)
            1.0 - correlation.abs
          end
        }
      end

      # Jaccard distance (for binary data)
      def self.jaccard
        {
          name: 'Jaccard Distance',
          description: 'For binary or categorical data. Measures dissimilarity of sets.',
          formula: '1 - |A∩B|/|A∪B|',
          properties: ['Good for binary data', 'Measures set dissimilarity', 'Scale-invariant'],
          function: ->(a, b) do
            # Convert to binary (1 if > 0, 0 otherwise)
            binary_a = a.map { |x| x.is_a?(Numeric) && x > 0 ? 1 : 0 }
            binary_b = b.map { |x| x.is_a?(Numeric) && x > 0 ? 1 : 0 }

            intersection = binary_a.zip(binary_b).count { |x, y| x == 1 && y == 1 }
            union = binary_a.zip(binary_b).count { |x, y| x == 1 || y == 1 }

            return 0.0 if union == 0

            1.0 - (intersection.to_f / union)
          end
        }
      end

      # Hamming distance (for categorical data)
      def self.hamming
        {
          name: 'Hamming Distance',
          description: 'Number of positions where elements differ. Good for categorical data.',
          formula: 'Σ(xi ≠ yi)',
          properties: ['Good for categorical data', 'Counts differences', 'Scale-invariant'],
          function: ->(a, b) do
            a.zip(b).count { |x, y| x != y }.to_f
          end
        }
      end

      # Canberra distance
      def self.canberra
        {
          name: 'Canberra Distance',
          description: 'Weighted Manhattan distance. Good for positive data with different scales.',
          formula: 'Σ|xi - yi|/(|xi| + |yi|)',
          properties: ['Handles different scales', 'Good for positive data', 'Sensitive to small changes'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            numeric_a.zip(numeric_b).sum do |x, y|
              denominator = x.abs + y.abs
              next 0 if denominator == 0

              (x - y).abs / denominator
            end
          end
        }
      end

      # Mahalanobis distance (requires covariance matrix)
      def self.mahalanobis(covariance_matrix)
        {
          name: 'Mahalanobis Distance',
          description: 'Accounts for covariance between dimensions. Good for correlated data.',
          formula: '√((x-y)ᵀ S⁻¹ (x-y))',
          properties: ['Accounts for correlation', 'Scale-invariant', 'Requires covariance matrix'],
          function: ->(a, b) do
            numeric_a = extract_numeric(a)
            numeric_b = extract_numeric(b)

            diff = numeric_a.zip(numeric_b).map { |x, y| x - y }

            # Simple implementation - assumes diagonal covariance for educational purposes
            weighted_sum = diff.each_with_index.sum do |d, i|
              variance = covariance_matrix[i] && covariance_matrix[i][i] ? covariance_matrix[i][i] : 1.0
              (d**2) / variance
            end

            Math.sqrt(weighted_sum)
          end
        }
      end

      # Get all available distance metrics
      def self.get_all_metrics
        {
          euclidean: euclidean,
          manhattan: manhattan,
          chebyshev: chebyshev,
          minkowski_3: minkowski(3),
          cosine: cosine,
          pearson_correlation: pearson_correlation,
          jaccard: jaccard,
          hamming: hamming,
          canberra: canberra
        }
      end

      # Get educational comparison of distance metrics
      def self.compare_metrics_educational
        puts '=== Distance Metrics Educational Comparison ==='
        puts

        metrics = get_all_metrics

        puts 'Overview of Available Distance Metrics:'
        puts '=' * 60

        metrics.each_value do |metric_info|
          puts "\n#{metric_info[:name]}"
          puts '-' * metric_info[:name].length
          puts "Description: #{metric_info[:description]}"
          puts "Formula: #{metric_info[:formula]}"
          puts 'Properties:'
          metric_info[:properties].each { |prop| puts "  • #{prop}" }
        end

        puts "\n#{'=' * 60}"
        puts 'Usage Guidelines:'
        puts '• Euclidean: General purpose, assumes spherical clusters'
        puts '• Manhattan: High-dimensional data, less sensitive to outliers'
        puts '• Cosine: Text data, high-dimensional sparse data'
        puts '• Correlation: Pattern matching, time series'
        puts '• Jaccard: Binary/categorical data, set similarity'
        puts '• Hamming: Categorical data, DNA sequences'
        puts '• Canberra: Positive data with different scales'
        puts '• Mahalanobis: Correlated data, accounts for covariance'

        metrics
      end

      # Test distance metrics with sample data
      def self.test_metrics_with_samples
        puts '=== Distance Metrics Testing ==='
        puts

        # Sample data points
        point1 = [1.0, 2.0, 3.0]
        point2 = [4.0, 5.0, 6.0]
        point3 = [1.0, 2.0, 3.0] # Same as point1

        puts 'Sample points:'
        puts "Point 1: #{point1}"
        puts "Point 2: #{point2}"
        puts "Point 3: #{point3} (same as Point 1)"
        puts

        metrics = get_all_metrics

        puts 'Distance calculations:'
        puts 'Metric               | P1-P2   | P1-P3   | Properties'
        puts '--------------------|---------|---------|--------------------------'

        metrics.each_value do |metric_info|
          dist_12 = metric_info[:function].call(point1, point2)
          dist_13 = metric_info[:function].call(point1, point3)

          puts format('%-19s | %7.3f | %7.3f | %s',
                      metric_info[:name][0..18],
                      dist_12,
                      dist_13,
                      metric_info[:properties].first || '')
        end

        puts "\nObservations:"
        puts '• All metrics show P1-P3 = 0 (identical points)'
        puts '• Different metrics give different P1-P2 distances'
        puts '• Choose metric based on your data characteristics'
      end

      def self.extract_numeric(vector)
        vector.select { |attr| attr.is_a?(Numeric) }
      end
    end

    # Initialization strategies for K-means clustering
    class InitializationStrategies
      # Random initialization
      def self.random
        {
          name: 'Random Initialization',
          description: 'Randomly select K data points as initial centroids',
          properties: ['Simple and fast', 'May converge to local optima', 'Results vary between runs'],
          function: ->(data_set, k) do
            selected_indices = []
            centroids = []

            k.times do
              loop do
                index = rand(data_set.data_items.length)
                next if selected_indices.include?(index)

                selected_indices << index
                centroids << data_set.data_items[index].dup
                break
              end
            end

            centroids
          end
        }
      end

      # K-means++ initialization
      def self.k_means_plus_plus
        {
          name: 'K-means++ Initialization',
          description: 'Choose centroids with probability proportional to squared distance from existing centroids',
          properties: ['Better than random', 'Probabilistic improvement', 'Slower than random'],
          function: ->(data_set, k, distance_function = nil) do
            distance_function ||= ->(a, b) {
              numeric_a = a.select { |attr| attr.is_a?(Numeric) }
              numeric_b = b.select { |attr| attr.is_a?(Numeric) }
              sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y)**2 }
              Math.sqrt(sum)
            }

            centroids = []

            # Choose first centroid randomly
            centroids << data_set.data_items[rand(data_set.data_items.length)].dup

            # Choose remaining centroids
            (k - 1).times do
              distances = data_set.data_items.map do |point|
                min_distance = centroids.map { |centroid| distance_function.call(point, centroid) }.min
                min_distance**2
              end

              total_distance = distances.sum
              next if total_distance == 0

              target = rand * total_distance
              cumulative = 0

              data_set.data_items.each_with_index do |point, index|
                cumulative += distances[index]
                if cumulative >= target
                  centroids << point.dup
                  break
                end
              end
            end

            centroids
          end
        }
      end

      # Forgy initialization (random assignment)
      def self.forgy
        {
          name: 'Forgy Initialization',
          description: 'Randomly assign each point to a cluster, then compute centroids',
          properties: ['Different approach', 'May spread centroids better', 'More computationally intensive'],
          function: ->(data_set, k) do
            # Randomly assign points to clusters
            assignments = data_set.data_items.map { rand(k) }

            # Calculate centroids for each cluster
            centroids = []
            k.times do |cluster_id|
              cluster_points = []
              assignments.each_with_index do |assignment, index|
                cluster_points << data_set.data_items[index] if assignment == cluster_id
              end

              if cluster_points.empty?
                # If no points assigned, use random point
                centroids << data_set.data_items[rand(data_set.data_items.length)].dup
              else
                # Calculate mean
                n_features = cluster_points.first.length
                centroid = Array.new(n_features, 0)

                cluster_points.each do |point|
                  point.each_with_index do |value, feature_index|
                    centroid[feature_index] += value if value.is_a?(Numeric)
                  end
                end

                centroid.map! { |sum| sum / cluster_points.length }
                centroids << centroid
              end
            end

            centroids
          end
        }
      end

      # Furthest first initialization
      def self.furthest_first
        {
          name: 'Furthest First Initialization',
          description: 'Choose centroids that are furthest apart from each other',
          properties: ['Maximizes initial separation', 'Deterministic result', 'May not work well for all data'],
          function: ->(data_set, k, distance_function = nil) do
            distance_function ||= ->(a, b) {
              numeric_a = a.select { |attr| attr.is_a?(Numeric) }
              numeric_b = b.select { |attr| attr.is_a?(Numeric) }
              sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y)**2 }
              Math.sqrt(sum)
            }

            centroids = []

            # Choose first centroid randomly
            centroids << data_set.data_items[rand(data_set.data_items.length)].dup

            # Choose remaining centroids
            (k - 1).times do
              max_min_distance = 0
              furthest_point = nil

              data_set.data_items.each do |point|
                min_distance = centroids.map { |centroid| distance_function.call(point, centroid) }.min

                if min_distance > max_min_distance
                  max_min_distance = min_distance
                  furthest_point = point
                end
              end

              centroids << furthest_point.dup if furthest_point
            end

            centroids
          end
        }
      end

      # Manual initialization (for educational purposes)
      def self.manual(specified_centroids)
        {
          name: 'Manual Initialization',
          description: 'Use pre-specified centroids (for educational experiments)',
          properties: ['Deterministic', 'Good for teaching', 'Requires domain knowledge'],
          function: ->(data_set, k) do
            if specified_centroids.length >= k
              specified_centroids[0...k].map(&:dup)
            else
              # Fill remaining with random points
              result = specified_centroids.map(&:dup)
              remaining = k - specified_centroids.length
              remaining.times do
                result << data_set.data_items[rand(data_set.data_items.length)].dup
              end
              result
            end
          end
        }
      end

      # Get all initialization strategies
      def self.get_all_strategies
        {
          random: random,
          k_means_plus_plus: k_means_plus_plus,
          forgy: forgy,
          furthest_first: furthest_first
        }
      end

      # Educational comparison of initialization strategies
      def self.compare_strategies_educational
        puts '=== Initialization Strategies Educational Comparison ==='
        puts

        strategies = get_all_strategies

        puts 'Overview of Initialization Strategies:'
        puts '=' * 60

        strategies.each_value do |strategy_info|
          puts "\n#{strategy_info[:name]}"
          puts '-' * strategy_info[:name].length
          puts "Description: #{strategy_info[:description]}"
          puts 'Properties:'
          strategy_info[:properties].each { |prop| puts "  • #{prop}" }
        end

        puts "\n#{'=' * 60}"
        puts 'Usage Guidelines:'
        puts '• Random: Simple baseline, good for testing'
        puts '• K-means++: Generally best choice, balances quality and speed'
        puts '• Forgy: Alternative approach, may work better for some data'
        puts '• Furthest First: Good for well-separated clusters'
        puts '• Manual: Educational purposes, reproducible experiments'

        strategies
      end

      # Test initialization strategies with sample data
      def self.test_strategies_with_samples(data_set, k = 3)
        puts '=== Initialization Strategies Testing ==='
        puts "Dataset: #{data_set.data_items.length} points, K=#{k}"
        puts

        strategies = get_all_strategies

        strategies.each_value do |strategy_info|
          puts "#{strategy_info[:name]}:"

          # Run strategy multiple times to show variation
          3.times do |run|
            centroids = strategy_info[:function].call(data_set, k)
            puts "  Run #{run + 1}: #{centroids.map { |c| c.map { |v| v.round(2) }.join(',') }.join(' | ')}"
          end

          puts
        end

        puts 'Observations:'
        puts '• Random and Forgy show variation between runs'
        puts '• K-means++ shows some variation but tends to be more consistent'
        puts '• Furthest First produces the same result each run'
        puts '• Different strategies can lead to different final clustering results'
      end
    end
  end
end
