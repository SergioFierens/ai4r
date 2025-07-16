# frozen_string_literal: true

# Enhanced k-Nearest Neighbors implementation for educational purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'classifier'
require_relative '../data/data_set'

module Ai4r
  module Classifiers
    # Educational k-Nearest Neighbors implementation
    #
    # Enhanced version of k-NN with multiple distance metrics, weighting schemes,
    # and comprehensive educational features for understanding instance-based learning.
    #
    # Educational Features:
    # - Distance calculation visualization
    # - Neighbor selection explanation
    # - Different weighting schemes demonstration
    # - Cross-validation for optimal k selection
    # - Curse of dimensionality illustration
    #
    # = Usage
    #   knn = EnhancedKNearestNeighbors.new
    #   knn.configure(k: 5, distance_metric: :euclidean, weighting: :distance)
    #   knn.enable_educational_mode
    #   knn.build(training_data)
    #   prediction = knn.eval([feature_vector])
    class EnhancedKNearestNeighbors < Classifier
      attr_reader :k, :distance_metric, :weighting_scheme, :training_data, :training_labels, :educational_mode,
                  :prediction_explanations, :distance_calculations, :feature_weights, :normalization_params

      def initialize
        # Core k-NN parameters
        @k = 3
        @distance_metric = :euclidean
        @weighting_scheme = :uniform

        # Distance function parameters
        @minkowski_p = 2
        @feature_weights = []

        # Data preprocessing
        @normalize_features = true
        @normalization_params = { means: [], stds: [] }

        # Educational features
        @educational_mode = false
        @verbose = false
        @show_distances = false
        @explain_predictions = false

        # Training data storage
        @training_data = []
        @training_labels = []
        @class_labels = []

        # Prediction tracking
        @prediction_explanations = []
        @distance_calculations = []

        # Performance optimization
        @use_kd_tree = false
        @leaf_size = 30
      end

      # Configure k-NN parameters with educational explanations
      def configure(params = {})
        params.each do |key, value|
          case key
          when :k
            set_k_value(value)
          when :distance_metric, :distance, :metric
            set_distance_metric(value, params)
          when :weighting, :weight_scheme
            set_weighting_scheme(value)
          when :normalize_features, :normalize
            @normalize_features = value
          when :feature_weights
            @feature_weights = value
          when :verbose
            @verbose = value
          when :show_distances
            @show_distances = value
          when :explain_predictions
            @explain_predictions = value
          when :use_kd_tree
            @use_kd_tree = value
          when :leaf_size
            @leaf_size = value
          end
        end

        explain_configuration if @educational_mode && @verbose
        self
      end

      # Enable educational mode with detailed explanations
      def enable_educational_mode
        @educational_mode = true
        @verbose = true
        @explain_predictions = true
        puts "\n=== Educational k-NN Mode Activated ==="
        puts 'This mode provides detailed explanations of k-NN concepts and predictions.'
        puts "You'll see distance calculations, neighbor selection, and voting processes."
        self
      end

      # Train the k-NN model (store training data)
      def build(data_set)
        @data_set = data_set
        prepare_training_data

        puts "\n=== Building k-NN Classifier ===" if @verbose
        puts "Training examples: #{@training_data.length}" if @verbose
        puts "Features: #{@training_data.first.length}" if @verbose
        puts "Classes: #{@class_labels.inspect}" if @verbose
        puts "k value: #{@k}" if @verbose
        puts "Distance metric: #{@distance_metric}" if @verbose
        puts "Weighting scheme: #{@weighting_scheme}" if @verbose

        if @educational_mode
          explain_knn_concepts
          analyze_training_data
        end

        # Normalize features if requested
        normalize_training_features if @normalize_features

        # Build spatial index if requested
        build_kd_tree if @use_kd_tree && @training_data.first.length <= 10

        puts "\nk-NN model ready!" if @verbose
        self
      end

      # Predict class for new data point
      def eval(data_item)
        return nil unless trained?

        # Preprocess the query point
        query_point = preprocess_query_point(data_item)

        # Find k nearest neighbors
        neighbors = find_k_nearest_neighbors(query_point)

        # Make prediction based on neighbors
        prediction = predict_from_neighbors(neighbors, query_point)

        explain_prediction(data_item, query_point, neighbors, prediction) if @educational_mode && @explain_predictions

        prediction
      end

      # Get prediction with confidence scores and neighbor details
      def predict_with_details(data_item)
        return nil unless trained?

        query_point = preprocess_query_point(data_item)
        neighbors = find_k_nearest_neighbors(query_point)
        prediction = predict_from_neighbors(neighbors, query_point)

        # Calculate class probabilities based on neighbors
        class_votes = calculate_class_votes(neighbors)
        total_weight = class_votes.values.sum
        class_probabilities = {}
        @class_labels.each do |label|
          class_probabilities[label] = class_votes[label] / total_weight
        end

        confidence = class_probabilities.values.max

        {
          prediction: prediction,
          confidence: confidence,
          class_probabilities: class_probabilities,
          neighbors: neighbors,
          k_used: neighbors.length
        }
      end

      # Find optimal k value using cross-validation
      def find_optimal_k(k_range = (1..20), cv_folds = 5)
        return nil unless trained?

        puts "\n=== Finding Optimal k Value ===" if @verbose
        puts "Testing k values: #{k_range}" if @verbose
        puts "Cross-validation folds: #{cv_folds}" if @verbose

        results = {}

        k_range.each do |test_k|
          puts "Testing k = #{test_k}..." if @verbose

          # Perform cross-validation
          fold_accuracies = []
          cv_folds.times do |fold|
            train_indices, val_indices = create_cv_fold(fold, cv_folds)

            # Create temporary classifier with test_k
            temp_classifier = self.class.new
            temp_classifier.configure(
              k: test_k,
              distance_metric: @distance_metric,
              weighting: @weighting_scheme,
              normalize_features: @normalize_features
            )

            # Train on fold
            fold_train_data = train_indices.map { |i| @training_data[i] + [@training_labels[i]] }
            fold_data_set = Ai4r::Data::DataSet.new(
              data_labels: @data_set.data_labels,
              data_items: fold_train_data
            )
            temp_classifier.build(fold_data_set)

            # Test on validation set
            correct = 0
            val_indices.each do |i|
              prediction = temp_classifier.eval(@training_data[i])
              correct += 1 if prediction == @training_labels[i]
            end

            accuracy = correct.to_f / val_indices.length
            fold_accuracies << accuracy
          end

          avg_accuracy = fold_accuracies.sum / fold_accuracies.length
          std_accuracy = Math.sqrt(fold_accuracies.sum { |acc| (acc - avg_accuracy)**2 } / fold_accuracies.length)

          results[test_k] = {
            accuracy: avg_accuracy,
            std: std_accuracy,
            fold_accuracies: fold_accuracies
          }

          puts "  k=#{test_k}: #{(avg_accuracy * 100).round(2)}% ± #{(std_accuracy * 100).round(2)}%" if @verbose
        end

        # Find best k
        best_k = results.max_by { |_k, result| result[:accuracy] }[0]

        explain_k_selection(results, best_k) if @educational_mode

        results
      end

      # Analyze curse of dimensionality effects
      def analyze_curse_of_dimensionality
        return unless trained?

        puts "\n=== Curse of Dimensionality Analysis ===" if @verbose

        num_features = @training_data.first.length
        num_samples = @training_data.length

        # Calculate average pairwise distances
        distances = []
        sample_size = [100, num_samples].min # Sample for efficiency

        sample_size.times do |i|
          ((i + 1)...sample_size).each do |j|
            distance = calculate_distance(@training_data[i], @training_data[j])
            distances << distance
          end
        end

        avg_distance = distances.sum / distances.length
        min_distance = distances.min
        max_distance = distances.max
        distance_std = Math.sqrt(distances.sum { |d| (d - avg_distance)**2 } / distances.length)

        # Calculate distance concentration ratio
        concentration_ratio = distance_std / avg_distance

        analysis = {
          num_features: num_features,
          num_samples: num_samples,
          avg_distance: avg_distance,
          min_distance: min_distance,
          max_distance: max_distance,
          distance_std: distance_std,
          concentration_ratio: concentration_ratio,
          samples_per_dimension: num_samples.to_f / num_features
        }

        explain_curse_of_dimensionality(analysis) if @educational_mode

        analysis
      end

      # Compare different distance metrics
      def compare_distance_metrics(test_point = nil)
        return unless trained?

        test_point ||= @training_data.first
        metrics = %i[euclidean manhattan chebyshev minkowski]

        puts "\n=== Distance Metric Comparison ===" if @verbose
        puts "Test point: #{test_point.inspect}" if @verbose

        results = {}

        metrics.each do |metric|
          puts "\n#{metric.to_s.capitalize} Distance:" if @verbose
          distances = []

          @training_data.each_with_index do |train_point, idx|
            distance = case metric
                       when :euclidean
                         euclidean_distance(test_point, train_point)
                       when :manhattan
                         manhattan_distance(test_point, train_point)
                       when :chebyshev
                         chebyshev_distance(test_point, train_point)
                       when :minkowski
                         minkowski_distance(test_point, train_point, 3)
                       end

            distances << { distance: distance, index: idx, label: @training_labels[idx] }
          end

          distances.sort_by! { |item| item[:distance] }
          top_k = distances.first(@k)

          results[metric] = {
            distances: distances,
            top_k_neighbors: top_k,
            avg_distance: distances.sum { |item| item[:distance] } / distances.length
          }

          next unless @verbose

          puts "  Average distance: #{results[metric][:avg_distance].round(4)}"
          puts "  Top #{@k} neighbors:"
          top_k.each_with_index do |neighbor, idx|
            puts "    #{idx + 1}. Distance: #{neighbor[:distance].round(4)}, Label: #{neighbor[:label]}"
          end
        end

        results
      end

      private

      def set_k_value(k_value)
        raise ArgumentError, 'k must be a positive integer' unless k_value.is_a?(Integer) && k_value > 0

        @k = k_value
      end

      def set_distance_metric(metric, params = {})
        valid_metrics = %i[euclidean manhattan chebyshev minkowski cosine hamming]

        raise ArgumentError, "Unsupported distance metric: #{metric}" unless valid_metrics.include?(metric)

        @distance_metric = metric

        @minkowski_p = params[:p] || params[:minkowski_p] || 2 if metric == :minkowski
      end

      def set_weighting_scheme(scheme)
        valid_schemes = %i[uniform distance inverse_distance]

        raise ArgumentError, "Unsupported weighting scheme: #{scheme}" unless valid_schemes.include?(scheme)

        @weighting_scheme = scheme
      end

      def prepare_training_data
        @training_data = @data_set.data_items.map { |item| item[0...-1] }
        @training_labels = @data_set.data_items.map(&:last)
        @class_labels = @training_labels.uniq.sort
      end

      def normalize_training_features
        puts 'Normalizing features...' if @verbose

        num_features = @training_data.first.length
        @normalization_params[:means] = Array.new(num_features, 0.0)
        @normalization_params[:stds] = Array.new(num_features, 0.0)

        # Calculate means
        @training_data.each do |example|
          example.each_with_index do |feature, idx|
            @normalization_params[:means][idx] += feature
          end
        end
        @normalization_params[:means].map! { |mean| mean / @training_data.length }

        # Calculate standard deviations
        @training_data.each do |example|
          example.each_with_index do |feature, idx|
            diff = feature - @normalization_params[:means][idx]
            @normalization_params[:stds][idx] += diff * diff
          end
        end
        @normalization_params[:stds].map! { |var| Math.sqrt(var / @training_data.length) }

        # Normalize training data
        @training_data.each do |example|
          example.each_with_index do |feature, idx|
            std = @normalization_params[:stds][idx]
            example[idx] = if std > 0
                             (feature - @normalization_params[:means][idx]) / std
                           else
                             0.0
                           end
          end
        end
      end

      def preprocess_query_point(data_item)
        query_point = data_item.dup

        if @normalize_features && !@normalization_params[:means].empty?
          query_point.each_with_index do |feature, idx|
            std = @normalization_params[:stds][idx]
            query_point[idx] = if std > 0
                                 (feature - @normalization_params[:means][idx]) / std
                               else
                                 0.0
                               end
          end
        end

        query_point
      end

      def find_k_nearest_neighbors(query_point)
        # Calculate distances to all training points
        distances = []

        @training_data.each_with_index do |train_point, idx|
          distance = calculate_distance(query_point, train_point)
          distances << {
            distance: distance,
            index: idx,
            features: train_point,
            label: @training_labels[idx]
          }
        end

        # Sort by distance and take k nearest
        distances.sort_by! { |item| item[:distance] }

        # Handle case where k > number of training examples
        k_to_use = [@k, distances.length].min
        neighbors = distances.first(k_to_use)

        @distance_calculations = distances if @educational_mode

        neighbors
      end

      def calculate_distance(point1, point2)
        case @distance_metric
        when :euclidean
          euclidean_distance(point1, point2)
        when :manhattan
          manhattan_distance(point1, point2)
        when :chebyshev
          chebyshev_distance(point1, point2)
        when :minkowski
          minkowski_distance(point1, point2, @minkowski_p)
        when :cosine
          cosine_distance(point1, point2)
        when :hamming
          hamming_distance(point1, point2)
        else
          raise ArgumentError, "Unknown distance metric: #{@distance_metric}"
        end
      end

      def euclidean_distance(point1, point2)
        sum_squared_diff = 0.0
        point1.each_with_index do |coord1, idx|
          diff = coord1 - point2[idx]

          # Apply feature weights if specified
          weight = @feature_weights[idx] || 1.0
          sum_squared_diff += weight * diff * diff
        end
        Math.sqrt(sum_squared_diff)
      end

      def manhattan_distance(point1, point2)
        sum_abs_diff = 0.0
        point1.each_with_index do |coord1, idx|
          diff = (coord1 - point2[idx]).abs
          weight = @feature_weights[idx] || 1.0
          sum_abs_diff += weight * diff
        end
        sum_abs_diff
      end

      def chebyshev_distance(point1, point2)
        max_diff = 0.0
        point1.each_with_index do |coord1, idx|
          diff = (coord1 - point2[idx]).abs
          weight = @feature_weights[idx] || 1.0
          weighted_diff = weight * diff
          max_diff = [max_diff, weighted_diff].max
        end
        max_diff
      end

      def minkowski_distance(point1, point2, p)
        sum_powered_diff = 0.0
        point1.each_with_index do |coord1, idx|
          diff = (coord1 - point2[idx]).abs
          weight = @feature_weights[idx] || 1.0
          sum_powered_diff += weight * (diff**p)
        end
        sum_powered_diff**(1.0 / p)
      end

      def cosine_distance(point1, point2)
        dot_product = 0.0
        magnitude1 = 0.0
        magnitude2 = 0.0

        point1.each_with_index do |coord1, idx|
          coord2 = point2[idx]
          dot_product += coord1 * coord2
          magnitude1 += coord1 * coord1
          magnitude2 += coord2 * coord2
        end

        magnitude1 = Math.sqrt(magnitude1)
        magnitude2 = Math.sqrt(magnitude2)

        if magnitude1 == 0.0 || magnitude2 == 0.0
          return 1.0 # Maximum distance for zero vectors
        end

        cosine_similarity = dot_product / (magnitude1 * magnitude2)
        1.0 - cosine_similarity # Convert similarity to distance
      end

      def hamming_distance(point1, point2)
        differences = 0
        point1.each_with_index do |coord1, idx|
          differences += 1 if coord1 != point2[idx]
        end
        differences.to_f
      end

      def predict_from_neighbors(neighbors, _query_point)
        class_votes = calculate_class_votes(neighbors)

        # Return class with highest vote
        class_votes.max_by { |_label, weight| weight }[0]
      end

      def calculate_class_votes(neighbors)
        votes = Hash.new(0.0)

        neighbors.each do |neighbor|
          weight = calculate_neighbor_weight(neighbor)
          votes[neighbor[:label]] += weight
        end

        votes
      end

      def calculate_neighbor_weight(neighbor)
        case @weighting_scheme
        when :uniform
          1.0
        when :distance
          # Higher weight for closer neighbors
          max_distance = @distance_calculations&.last&.[](:distance) || 1.0
          1.0 - (neighbor[:distance] / max_distance)
        when :inverse_distance
          # Inverse distance weighting
          distance = neighbor[:distance]
          distance == 0.0 ? Float::INFINITY : 1.0 / distance
        else
          1.0
        end
      end

      def explain_knn_concepts
        puts "\n=== k-Nearest Neighbors Educational Concepts ==="
        puts "\n1. INSTANCE-BASED LEARNING:"
        puts '   - k-NN is a lazy learning algorithm (no explicit training)'
        puts '   - Stores all training examples and defers computation until prediction'
        puts '   - Makes predictions based on similarity to stored examples'
        puts '   - Non-parametric: makes no assumptions about data distribution'

        puts "\n2. DISTANCE METRICS:"
        puts '   - Euclidean: Straight-line distance (most common)'
        puts '   - Manhattan: Sum of absolute differences (L1 norm)'
        puts '   - Chebyshev: Maximum difference across dimensions'
        puts '   - Cosine: Angle between vectors (good for text/sparse data)'

        puts "\n3. CHOOSING k:"
        puts '   - Small k: More sensitive to noise, complex decision boundaries'
        puts '   - Large k: Smoother decision boundaries, less sensitive to outliers'
        puts '   - Odd k values help avoid ties in binary classification'
        puts '   - Use cross-validation to find optimal k'

        puts "\n4. WEIGHTING SCHEMES:"
        puts '   - Uniform: All neighbors vote equally'
        puts '   - Distance: Closer neighbors have higher influence'
        puts '   - Inverse distance: Weight = 1/distance'

        puts "\n5. FEATURE SCALING:"
        puts '   - Features with larger scales dominate distance calculations'
        puts '   - Normalization/standardization is usually essential'
        puts '   - Feature weights can emphasize important attributes'
      end

      def analyze_training_data
        puts "\n=== Training Data Analysis ==="

        # Class distribution
        class_counts = Hash.new(0)
        @training_labels.each { |label| class_counts[label] += 1 }

        puts 'Class distribution:'
        class_counts.each do |label, count|
          percentage = (count.to_f / @training_labels.length * 100).round(1)
          puts "  #{label}: #{count} examples (#{percentage}%)"
        end

        # Feature statistics
        unless @training_data.empty?
          num_features = @training_data.first.length
          puts "\nFeature statistics:"

          num_features.times do |feat_idx|
            values = @training_data.map { |example| example[feat_idx] }
            min_val = values.min
            max_val = values.max
            avg_val = values.sum / values.length

            puts "  Feature #{feat_idx + 1}: min=#{min_val.round(3)}, max=#{max_val.round(3)}, avg=#{avg_val.round(3)}"
          end
        end

        # Data density analysis
        density_analysis = analyze_curse_of_dimensionality
        puts "\nData density: #{density_analysis[:samples_per_dimension].round(2)} samples per dimension"

        if density_analysis[:samples_per_dimension] < 10
          puts 'WARNING: Low sample density may lead to poor k-NN performance'
        end
      end

      def explain_prediction(original_point, query_point, neighbors, prediction)
        puts "\n=== k-NN Prediction Explanation ==="
        puts "Query point: #{original_point.inspect}"

        puts "Normalized query: #{query_point.map { |x| x.round(4) }.inspect}" if @normalize_features

        puts "\nDistance metric: #{@distance_metric}"
        puts "k value: #{@k}"
        puts "Weighting scheme: #{@weighting_scheme}"

        puts "\nNearest neighbors:"
        neighbors.each_with_index do |neighbor, idx|
          weight = calculate_neighbor_weight(neighbor)
          puts format('  %d. Distance: %8.4f, Label: %s, Weight: %6.3f',
                      idx + 1, neighbor[:distance], neighbor[:label], weight)
        end

        # Show voting process
        class_votes = calculate_class_votes(neighbors)
        puts "\nClass voting:"
        class_votes.each do |label, total_weight|
          percentage = (total_weight / class_votes.values.sum * 100).round(1)
          puts "  #{label}: #{total_weight.round(3)} votes (#{percentage}%)"
        end

        puts "\nPrediction: #{prediction}"

        # Show decision boundary insight
        if neighbors.length > 1
          winner_neighbors = neighbors.select { |n| n[:label] == prediction }
          puts "Decision confidence: #{winner_neighbors.length}/#{neighbors.length} neighbors agree"
        end
      end

      def explain_k_selection(results, best_k)
        puts "\n=== Optimal k Selection Analysis ==="
        puts 'Cross-validation results:'
        puts 'k  | Accuracy | Std Dev'
        puts '---|----------|--------'

        results.each do |k, result|
          marker = k == best_k ? ' *' : '  '
          puts format('%2d%s| %7.2f%% | %6.2f%%',
                      k, marker, result[:accuracy] * 100, result[:std] * 100)
        end

        puts "\n* = Best k value"
        puts "\nRecommended k: #{best_k}"
        puts "Best accuracy: #{(results[best_k][:accuracy] * 100).round(2)}%"

        puts "\nInterpretation:"
        puts '- Look for k with highest accuracy and reasonable stability'
        puts '- Very low k may overfit to noise'
        puts '- Very high k may oversimplify decision boundaries'
        puts '- Consider computational cost vs. accuracy trade-off'
      end

      def explain_curse_of_dimensionality(analysis)
        puts "\n=== Curse of Dimensionality Analysis ==="
        puts "Dimensions: #{analysis[:num_features]}"
        puts "Training samples: #{analysis[:num_samples]}"
        puts "Samples per dimension: #{analysis[:samples_per_dimension].round(2)}"

        puts "\nDistance statistics:"
        puts "  Average distance: #{analysis[:avg_distance].round(4)}"
        puts "  Distance std dev: #{analysis[:distance_std].round(4)}"
        puts "  Concentration ratio: #{analysis[:concentration_ratio].round(4)}"

        puts "\nInterpretation:"

        if analysis[:concentration_ratio] < 0.1
          puts '- HIGH CURSE: Distances become very similar'
          puts '- k-NN may perform poorly due to distance concentration'
          puts '- Consider dimensionality reduction or feature selection'
        elsif analysis[:concentration_ratio] < 0.3
          puts '- MODERATE CURSE: Some distance concentration present'
          puts '- k-NN should work but may benefit from feature engineering'
        else
          puts '- LOW CURSE: Good distance discrimination'
          puts '- k-NN should perform well in this space'
        end

        if analysis[:samples_per_dimension] < 5
          puts '- SPARSE DATA: Very few samples per dimension'
          puts '- Consider increasing training data or reducing dimensions'
        elsif analysis[:samples_per_dimension] < 20
          puts '- MODERATE DENSITY: Reasonable sample density'
        else
          puts '- DENSE DATA: Good sample density for k-NN'
        end
      end

      def explain_configuration
        puts "\n=== k-NN Configuration Explanation ==="
        puts "k value: #{@k}"
        puts '  - Number of nearest neighbors to consider'
        puts '  - Odd values avoid ties in binary classification'

        puts "\nDistance metric: #{@distance_metric}"
        case @distance_metric
        when :euclidean
          puts '  - Standard geometric distance'
          puts '  - Sensitive to feature scales - normalization recommended'
        when :manhattan
          puts '  - Sum of coordinate differences'
          puts '  - Less sensitive to outliers than Euclidean'
        when :chebyshev
          puts '  - Maximum coordinate difference'
          puts '  - Good when any single feature difference matters most'
        when :cosine
          puts '  - Based on angle between vectors'
          puts '  - Good for high-dimensional sparse data'
        end

        puts "\nWeighting scheme: #{@weighting_scheme}"
        case @weighting_scheme
        when :uniform
          puts '  - All neighbors vote equally'
        when :distance
          puts '  - Closer neighbors have more influence'
        when :inverse_distance
          puts '  - Weight inversely proportional to distance'
        end

        puts "\nFeature normalization: #{@normalize_features ? 'Enabled' : 'Disabled'}"
        puts '  - Recommended when features have different scales'
      end

      def create_cv_fold(fold_index, num_folds)
        total_samples = @training_data.length
        fold_size = total_samples / num_folds

        val_start = fold_index * fold_size
        val_end = fold_index == num_folds - 1 ? total_samples : val_start + fold_size

        val_indices = (val_start...val_end).to_a
        train_indices = (0...total_samples).to_a - val_indices

        [train_indices, val_indices]
      end

      def build_kd_tree
        # Placeholder for kd-tree implementation
        # This would be a more advanced feature for efficiency
        puts 'kd-tree indexing not implemented in educational version' if @verbose
      end

      def trained?
        !@training_data.empty?
      end
    end
  end
end
