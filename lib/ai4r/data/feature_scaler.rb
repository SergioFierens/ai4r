# frozen_string_literal: true

# Feature scaling utilities for machine learning preparation
# Author::    Claude (AI Assistant)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    # Educational feature scaler with comprehensive scaling methods
    class FeatureScaler
      def initialize(dataset, educational_config = {})
        @dataset = dataset
        @config = educational_config
        @verbose = educational_config.fetch(:verbose, false)
        @explain_operations = educational_config.fetch(:explain_operations, false)
      end

      # Scale features using specified method
      def scale(data_items, method = :standardize)
        explain_scaling_method(method) if @explain_operations

        case method
        when :standardize, :z_score
          standardize_features(data_items)
        when :normalize, :min_max
          normalize_features(data_items)
        when :robust_scale
          robust_scale_features(data_items)
        when :quantile_uniform
          quantile_uniform_transform(data_items)
        when :quantile_normal
          quantile_normal_transform(data_items)
        when :power_transform
          power_transform_features(data_items)
        when :unit_vector
          unit_vector_scale(data_items)
        else
          raise ArgumentError, "Unknown scaling method: #{method}"
        end
      end

      # Explain different scaling methods
      def self.explain_method(method)
        explanations = {
          standardize: 'Standardization (Z-score normalization) transforms features to have mean=0 and std=1. ' \
                       'Best for: Normally distributed features, algorithms sensitive to scale (SVM, Neural Networks).',

          normalize: 'Min-Max normalization scales features to [0,1] range. ' \
                     'Best for: When you know feature bounds, neural networks, distance-based algorithms.',

          robust_scale: 'Robust scaling uses median and IQR instead of mean and std, less sensitive to outliers. ' \
                        'Best for: Data with outliers, skewed distributions.',

          quantile_uniform: 'Quantile transformation maps features to uniform distribution [0,1]. ' \
                            'Best for: Non-linear transformations, making distributions more uniform.',

          quantile_normal: 'Quantile transformation maps features to normal distribution. ' \
                           'Best for: Algorithms assuming normality, reducing impact of outliers.',

          power_transform: 'Power transformation (Box-Cox, Yeo-Johnson) makes data more normal. ' \
                           'Best for: Skewed data, improving normality assumptions.',

          unit_vector: 'Scales each sample to have unit norm (L2 normalization). ' \
                       'Best for: Text data, when direction matters more than magnitude.'
        }

        explanations[method] || 'Unknown scaling method'
      end

      # Recommend scaling method based on data characteristics
      def recommend_scaling_method(target_algorithm = nil)
        analysis = analyze_feature_characteristics

        recommendations = []

        # Algorithm-specific recommendations
        if target_algorithm
          algo_recommendations = get_algorithm_specific_recommendations(target_algorithm)
          recommendations.concat(algo_recommendations)
        end

        # Data-driven recommendations
        data_recommendations = get_data_driven_recommendations(analysis)
        recommendations.concat(data_recommendations)

        display_scaling_recommendations(recommendations, analysis) if @verbose

        recommendations
      end

      private

      def explain_scaling_method(method)
        puts "\n⚖️  Feature Scaling Method: #{method.to_s.humanize}"
        puts "Purpose: #{self.class.explain_method(method)}"

        show_scaling_warnings(method) if @config[:show_warnings]
      end

      def show_scaling_warnings(method)
        warnings = {
          standardize: '⚠️  Assumes features are normally distributed. May not work well with highly skewed data.',
          normalize: '⚠️  Sensitive to outliers. New data outside training range may cause values outside [0,1].',
          robust_scale: '✅ Good choice for data with outliers.',
          quantile_uniform: '⚠️  Changes the shape of the distribution. May lose interpretability.',
          quantile_normal: '⚠️  Complex transformation. May overfit to training data distribution.',
          power_transform: '⚠️  May not work with negative values (Box-Cox). Use Yeo-Johnson for mixed signs.',
          unit_vector: '⚠️  Changes the meaning of individual features. Good for similarity-based algorithms.'
        }

        puts warnings[method] if warnings[method]
      end

      def standardize_features(data_items)
        return data_items if data_items.empty?

        scaled_data = []
        feature_stats = calculate_standardization_params(data_items)

        if @verbose
          puts '📊 Standardization parameters:'
          feature_stats.each_with_index do |stats, idx|
            next unless stats[:numeric]

            puts "  Feature #{idx}: μ=#{stats[:mean].round(4)}, σ=#{stats[:std].round(4)}"
          end
        end

        data_items.each do |item|
          scaled_item = item.map.with_index do |value, idx|
            stats = feature_stats[idx]

            if stats[:numeric] && value.is_a?(Numeric)
              if stats[:std] == 0
                0.0
              else
                (value - stats[:mean]) / stats[:std]
              end
            else
              value
            end
          end

          scaled_data << scaled_item
        end

        scaled_data
      end

      def normalize_features(data_items)
        return data_items if data_items.empty?

        scaled_data = []
        feature_ranges = calculate_normalization_params(data_items)

        if @verbose
          puts '📊 Normalization parameters:'
          feature_ranges.each_with_index do |range, idx|
            next unless range[:numeric]

            puts "  Feature #{idx}: [#{range[:min].round(4)}, #{range[:max].round(4)}] → [0, 1]"
          end
        end

        data_items.each do |item|
          scaled_item = item.map.with_index do |value, idx|
            range = feature_ranges[idx]

            if range[:numeric] && value.is_a?(Numeric)
              if range[:range] == 0
                0.5
              else
                (value - range[:min]) / range[:range]
              end
            else
              value
            end
          end

          scaled_data << scaled_item
        end

        scaled_data
      end

      def robust_scale_features(data_items)
        return data_items if data_items.empty?

        scaled_data = []
        robust_params = calculate_robust_params(data_items)

        if @verbose
          puts '📊 Robust scaling parameters:'
          robust_params.each_with_index do |params, idx|
            next unless params[:numeric]

            puts "  Feature #{idx}: median=#{params[:median].round(4)}, IQR=#{params[:iqr].round(4)}"
          end
        end

        data_items.each do |item|
          scaled_item = item.map.with_index do |value, idx|
            params = robust_params[idx]

            if params[:numeric] && value.is_a?(Numeric)
              if params[:iqr] == 0
                0.0
              else
                (value - params[:median]) / params[:iqr]
              end
            else
              value
            end
          end

          scaled_data << scaled_item
        end

        scaled_data
      end

      def quantile_uniform_transform(data_items)
        return data_items if data_items.empty?

        scaled_data = []
        quantile_params = calculate_quantile_params(data_items)

        if @verbose
          puts '📊 Quantile uniform transformation applied'
          puts '   Features transformed to uniform distribution [0,1]'
        end

        data_items.each do |item|
          scaled_item = item.map.with_index do |value, idx|
            params = quantile_params[idx]

            if params[:numeric] && value.is_a?(Numeric)
              transform_to_uniform_quantile(value, params[:sorted_values])
            else
              value
            end
          end

          scaled_data << scaled_item
        end

        scaled_data
      end

      def quantile_normal_transform(data_items)
        return data_items if data_items.empty?

        # First transform to uniform, then to normal
        uniform_data = quantile_uniform_transform(data_items)

        if @verbose
          puts '📊 Quantile normal transformation applied'
          puts '   Features transformed to approximate normal distribution'
        end

        # Transform uniform values to normal using inverse normal CDF
        uniform_data.map do |item|
          item.map do |value|
            if value.is_a?(Numeric) && value >= 0 && value <= 1
              inverse_normal_cdf(value)
            else
              value
            end
          end
        end
      end

      def power_transform_features(data_items)
        return data_items if data_items.empty?

        scaled_data = []
        power_params = calculate_power_transform_params(data_items)

        if @verbose
          puts '📊 Power transformation parameters:'
          power_params.each_with_index do |params, idx|
            next unless params[:numeric]

            puts "  Feature #{idx}: λ=#{params[:lambda].round(4)} (#{params[:method]})"
          end
        end

        data_items.each do |item|
          scaled_item = item.map.with_index do |value, idx|
            params = power_params[idx]

            if params[:numeric] && value.is_a?(Numeric)
              apply_power_transform(value, params)
            else
              value
            end
          end

          scaled_data << scaled_item
        end

        scaled_data
      end

      def unit_vector_scale(data_items)
        return data_items if data_items.empty?

        scaled_data = []

        if @verbose
          puts '📊 Unit vector scaling applied'
          puts '   Each sample scaled to unit norm (L2)'
        end

        data_items.each do |item|
          numeric_values = item.select { |v| v.is_a?(Numeric) }

          if numeric_values.empty?
            scaled_data << item
            next
          end

          norm = Math.sqrt(numeric_values.sum { |v| v**2 })

          if norm == 0
            scaled_data << item
            next
          end

          scaled_item = item.map do |value|
            if value.is_a?(Numeric)
              value / norm
            else
              value
            end
          end

          scaled_data << scaled_item
        end

        scaled_data
      end

      def calculate_standardization_params(data_items)
        params = []
        num_features = data_items.first.length

        num_features.times do |feature_idx|
          values = extract_numeric_values(data_items, feature_idx)

          if values.empty?
            params << { numeric: false }
          else
            mean = values.sum.to_f / values.length
            variance = values.sum { |v| (v - mean)**2 } / values.length
            std = Math.sqrt(variance)

            params << {
              numeric: true,
              mean: mean,
              std: std,
              count: values.length
            }
          end
        end

        params
      end

      def calculate_normalization_params(data_items)
        params = []
        num_features = data_items.first.length

        num_features.times do |feature_idx|
          values = extract_numeric_values(data_items, feature_idx)

          if values.empty?
            params << { numeric: false }
          else
            min_val = values.min
            max_val = values.max
            range = max_val - min_val

            params << {
              numeric: true,
              min: min_val,
              max: max_val,
              range: range
            }
          end
        end

        params
      end

      def calculate_robust_params(data_items)
        params = []
        num_features = data_items.first.length

        num_features.times do |feature_idx|
          values = extract_numeric_values(data_items, feature_idx).sort

          if values.empty?
            params << { numeric: false }
          else
            n = values.length
            median = if n.odd?
                       values[n / 2]
                     else
                       (values[(n / 2) - 1] + values[n / 2]) / 2.0
                     end

            q1_idx = (n * 0.25).floor
            q3_idx = (n * 0.75).floor
            q1 = values[q1_idx]
            q3 = values[q3_idx]
            iqr = q3 - q1

            params << {
              numeric: true,
              median: median,
              q1: q1,
              q3: q3,
              iqr: iqr
            }
          end
        end

        params
      end

      def calculate_quantile_params(data_items)
        params = []
        num_features = data_items.first.length

        num_features.times do |feature_idx|
          values = extract_numeric_values(data_items, feature_idx).sort.uniq

          params << if values.empty?
                      { numeric: false }
                    else
                      {
                        numeric: true,
                        sorted_values: values
                      }
                    end
        end

        params
      end

      def calculate_power_transform_params(data_items)
        params = []
        num_features = data_items.first.length

        num_features.times do |feature_idx|
          values = extract_numeric_values(data_items, feature_idx)

          if values.empty?
            params << { numeric: false }
          else
            # Determine appropriate method
            has_negative = values.any? { |v| v < 0 }
            has_zero = values.any?(0)

            method = if has_negative || has_zero
                       :yeo_johnson
                     else
                       :box_cox
                     end

            # Estimate optimal lambda (simplified)
            lambda = estimate_optimal_lambda(values, method)

            params << {
              numeric: true,
              lambda: lambda,
              method: method
            }
          end
        end

        params
      end

      def extract_numeric_values(data_items, feature_idx)
        data_items.filter_map { |row| row[feature_idx] }.select { |v| v.is_a?(Numeric) }
      end

      def transform_to_uniform_quantile(value, sorted_values)
        # Find position in sorted values
        position = sorted_values.bsearch_index { |v| v >= value } || sorted_values.length
        position.to_f / sorted_values.length
      end

      def inverse_normal_cdf(p)
        # Simplified inverse normal CDF approximation
        # In production, would use more accurate implementation
        return -6.0 if p <= 0.001
        return 6.0 if p >= 0.999

        # Beasley-Springer-Moro algorithm approximation
        a0 = 2.515517
        a1 = 0.802853
        a2 = 0.010328
        b1 = 1.432788
        b2 = 0.189269
        b3 = 0.001308

        if p > 0.5
          t = Math.sqrt(-2.0 * Math.log(1.0 - p))
          (t - ((a0 + (a1 * t) + (a2 * t * t)) / (1.0 + (b1 * t) + (b2 * t * t) + (b3 * t * t * t))))
        else
          t = Math.sqrt(-2.0 * Math.log(p))
          -(t - ((a0 + (a1 * t) + (a2 * t * t)) / (1.0 + (b1 * t) + (b2 * t * t) + (b3 * t * t * t))))
        end
      end

      def estimate_optimal_lambda(values, method)
        # Simplified lambda estimation
        # In production, would use maximum likelihood estimation

        case method
        when :box_cox
          # Box-Cox works only with positive values
          positive_values = values.select { |v| v > 0 }
          return 1.0 if positive_values.empty?

          # Simple heuristic: if highly skewed, use log transform (lambda=0)
          # Otherwise, use lambda=0.5 (square root) or lambda=1 (no transform)
          log_values = positive_values.map { |v| Math.log(v) }
          skewness = calculate_skewness(log_values)

          if skewness.abs < 0.5
            0.0  # Log transform
          elsif skewness > 0
            0.5  # Square root
          else
            1.0  # No transform
          end

        when :yeo_johnson
          # Yeo-Johnson works with any values
          # Similar logic but different transformation
          skewness = calculate_skewness(values)

          if skewness.abs < 0.5
            1.0  # No transform
          elsif skewness > 0
            0.0  # Log-like transform
          else
            2.0  # Inverse transform
          end
        end
      end

      def calculate_skewness(values)
        return 0.0 if values.length < 3

        mean = values.sum.to_f / values.length
        variance = values.sum { |v| (v - mean)**2 } / values.length
        std = Math.sqrt(variance)

        return 0.0 if std == 0

        values.sum { |v| ((v - mean) / std)**3 } / values.length
      end

      def apply_power_transform(value, params)
        lambda = params[:lambda]
        method = params[:method]

        case method
        when :box_cox
          return value if value <= 0 # Box-Cox requires positive values

          if lambda == 0
            Math.log(value)
          else
            ((value**lambda) - 1) / lambda
          end

        when :yeo_johnson
          if value >= 0
            if lambda == 0
              Math.log(value + 1)
            else
              (((value + 1)**lambda) - 1) / lambda
            end
          elsif lambda == 2
            -Math.log(-value + 1)
          else
            -(((-value + 1)**(2 - lambda)) - 1) / (2 - lambda)
          end
        end
      end

      def analyze_feature_characteristics
        analysis = {
          numeric_features: 0,
          skewed_features: [],
          features_with_outliers: [],
          feature_scales: []
        }

        return analysis if @dataset.data_items.empty?

        num_features = @dataset.data_items.first.length

        num_features.times do |feature_idx|
          values = extract_numeric_values(@dataset.data_items, feature_idx)
          next if values.empty?

          analysis[:numeric_features] += 1

          # Check skewness
          skewness = calculate_skewness(values)
          analysis[:skewed_features] << { index: feature_idx, skewness: skewness } if skewness.abs > 1.0

          # Check for outliers (simple IQR method)
          sorted_values = values.sort
          n = sorted_values.length
          q1 = sorted_values[(n * 0.25).floor]
          q3 = sorted_values[(n * 0.75).floor]
          iqr = q3 - q1
          outlier_bounds = [q1 - (1.5 * iqr), q3 + (1.5 * iqr)]

          outliers = values.count { |v| v < outlier_bounds[0] || v > outlier_bounds[1] }
          if outliers > values.length * 0.05 # More than 5% outliers
            analysis[:features_with_outliers] << { index: feature_idx, outlier_count: outliers }
          end

          # Check scale
          range = values.max - values.min
          analysis[:feature_scales] << { index: feature_idx, range: range, min: values.min, max: values.max }
        end

        analysis
      end

      def get_algorithm_specific_recommendations(algorithm)
        recommendations = []

        case algorithm.to_s.downcase
        when 'svm', 'neural_network', 'logistic_regression', 'linear_regression'
          recommendations << {
            method: :standardize,
            reason: "#{algorithm} is sensitive to feature scales. Standardization ensures all features contribute equally.",
            priority: :high
          }

        when 'knn', 'kmeans', 'dbscan'
          recommendations << {
            method: :normalize,
            reason: "Distance-based algorithms like #{algorithm} work best with normalized features [0,1].",
            priority: :high
          }

        when 'random_forest', 'xgboost', 'decision_tree'
          recommendations << {
            method: :none,
            reason: "Tree-based algorithms like #{algorithm} are scale-invariant. Scaling optional.",
            priority: :low
          }

        when 'naive_bayes'
          recommendations << {
            method: :standardize,
            reason: 'Naive Bayes assumes features are normally distributed. Standardization helps.',
            priority: :medium
          }

        else
          recommendations << {
            method: :standardize,
            reason: 'Standardization is a safe default for most algorithms.',
            priority: :medium
          }
        end

        recommendations
      end

      def get_data_driven_recommendations(analysis)
        recommendations = []

        # Scale differences
        if analysis[:feature_scales].length > 1
          ranges = analysis[:feature_scales].map { |f| f[:range] }
          max_range = ranges.max
          min_range = ranges.min

          if max_range > min_range * 100
            recommendations << {
              method: :normalize,
              reason: "Large scale differences detected (#{max_range.round(2)} vs #{min_range.round(2)}). Normalization recommended.",
              priority: :high
            }
          end
        end

        # Skewed features
        if analysis[:skewed_features].any?
          highly_skewed = analysis[:skewed_features].select { |f| f[:skewness].abs > 2.0 }
          if highly_skewed.any?
            recommendations << {
              method: :power_transform,
              reason: "#{highly_skewed.length} highly skewed features detected. Power transformation can improve normality.",
              priority: :medium
            }
          end
        end

        # Features with outliers
        if analysis[:features_with_outliers].any?
          recommendations << {
            method: :robust_scale,
            reason: "#{analysis[:features_with_outliers].length} features have significant outliers. Robust scaling recommended.",
            priority: :medium
          }
        end

        recommendations
      end

      def display_scaling_recommendations(recommendations, analysis)
        puts "\n🎯 Feature Scaling Recommendations"
        puts '=' * 50

        puts "\nData Characteristics:"
        puts "  Numeric features: #{analysis[:numeric_features]}"
        puts "  Skewed features: #{analysis[:skewed_features].length}"
        puts "  Features with outliers: #{analysis[:features_with_outliers].length}"

        if analysis[:feature_scales].length > 1
          ranges = analysis[:feature_scales].map { |f| f[:range] }
          puts "  Scale range: #{ranges.min.round(2)} - #{ranges.max.round(2)}"
        end

        puts "\nRecommendations:"
        recommendations.each do |rec|
          priority_icon = case rec[:priority]
                          when :high then '🔴'
                          when :medium then '🟡'
                          when :low then '🟢'
                          else '⚪'
                          end

          puts "  #{priority_icon} #{rec[:method].to_s.humanize}: #{rec[:reason]}"
        end
      end
    end
  end
end
