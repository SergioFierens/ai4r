# frozen_string_literal: true

# Feature engineering and preprocessing tools for classification
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../data/data_set'

module Ai4r
  module Classifiers
    # Feature engineering and preprocessing tools
    class FeatureEngineering
      # Discretize continuous features into categorical bins
      def self.discretize_feature(data_set, feature_index, bins = 3, method = :equal_width)
        feature_values = data_set.data_items.map { |item| item[feature_index] }
        numeric_values = feature_values.select { |v| v.is_a?(Numeric) }

        return data_set if numeric_values.empty?

        case method
        when :equal_width
          bin_boundaries = equal_width_binning(numeric_values, bins)
        when :equal_frequency
          bin_boundaries = equal_frequency_binning(numeric_values, bins)
        when :manual
          bin_boundaries = bins # Assume bins is array of boundaries
        end

        # Create new data items with discretized feature
        new_data_items = data_set.data_items.map do |item|
          new_item = item.dup
          if item[feature_index].is_a?(Numeric)
            new_item[feature_index] = discretize_value(item[feature_index], bin_boundaries)
          end
          new_item
        end

        # Create new dataset
        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: new_data_items
        )
      end

      # Normalize numeric features
      def self.normalize_feature(data_set, feature_index, method = :min_max)
        feature_values = data_set.data_items.map { |item| item[feature_index] }
        numeric_values = feature_values.select { |v| v.is_a?(Numeric) }

        return data_set if numeric_values.empty?

        case method
        when :min_max
          min_val = numeric_values.min
          max_val = numeric_values.max
          range = max_val - min_val

          new_data_items = data_set.data_items.map do |item|
            new_item = item.dup
            if item[feature_index].is_a?(Numeric) && range > 0
              new_item[feature_index] = (item[feature_index] - min_val) / range
            end
            new_item
          end
        when :z_score
          mean = numeric_values.sum / numeric_values.length.to_f
          std_dev = Math.sqrt(numeric_values.sum { |v| (v - mean)**2 } / numeric_values.length.to_f)

          new_data_items = data_set.data_items.map do |item|
            new_item = item.dup
            if item[feature_index].is_a?(Numeric) && std_dev > 0
              new_item[feature_index] = (item[feature_index] - mean) / std_dev
            end
            new_item
          end
        end

        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: new_data_items
        )
      end

      # Create dummy variables for categorical features
      def self.create_dummy_variables(data_set, feature_index)
        feature_values = data_set.data_items.map { |item| item[feature_index] }
        unique_values = feature_values.uniq.sort

        return data_set if unique_values.length <= 2

        # Create new labels
        original_label = data_set.data_labels[feature_index]
        new_labels = data_set.data_labels.dup
        new_labels.delete_at(feature_index)

        # Add dummy variable labels
        dummy_labels = unique_values.map { |value| "#{original_label}_#{value}" }
        new_labels.insert(feature_index, *dummy_labels)

        # Create new data items
        new_data_items = data_set.data_items.map do |item|
          new_item = item.dup
          original_value = new_item.delete_at(feature_index)

          # Create dummy variables
          dummy_values = unique_values.map { |value| value == original_value ? 1 : 0 }
          new_item.insert(feature_index, *dummy_values)

          new_item
        end

        Ai4r::Data::DataSet.new(
          data_labels: new_labels,
          data_items: new_data_items
        )
      end

      # Feature selection using information gain
      def self.select_features_by_information_gain(data_set, k = 5)
        feature_scores = calculate_information_gain_scores(data_set)

        # Sort by score and take top k
        sorted_features = feature_scores.sort_by { |_, score| -score }
        selected_indices = sorted_features.take(k).map { |index, _| index }

        # Create new dataset with selected features
        new_labels = selected_indices.map { |i| data_set.data_labels[i] } + [data_set.data_labels.last]
        new_data_items = data_set.data_items.map do |item|
          selected_indices.map { |i| item[i] } + [item.last]
        end

        Ai4r::Data::DataSet.new(
          data_labels: new_labels,
          data_items: new_data_items
        )
      end

      # Handle missing values
      def self.handle_missing_values(data_set, strategy = :mode)
        case strategy
        when :mode
          fill_with_mode(data_set)
        when :mean
          fill_with_mean(data_set)
        when :remove
          remove_missing_values(data_set)
        end
      end

      # Remove outliers using IQR method
      def self.remove_outliers(data_set, feature_index, method = :iqr)
        feature_values = data_set.data_items.map { |item| item[feature_index] }
        numeric_values = feature_values.select { |v| v.is_a?(Numeric) }

        return data_set if numeric_values.empty?

        case method
        when :iqr
          sorted_values = numeric_values.sort
          q1 = sorted_values[sorted_values.length / 4]
          q3 = sorted_values[3 * sorted_values.length / 4]
          iqr = q3 - q1

          lower_bound = q1 - (1.5 * iqr)
          upper_bound = q3 + (1.5 * iqr)

          new_data_items = data_set.data_items.select do |item|
            value = item[feature_index]
            !value.is_a?(Numeric) || value.between?(lower_bound, upper_bound)
          end
        when :z_score
          mean = numeric_values.sum / numeric_values.length.to_f
          std_dev = Math.sqrt(numeric_values.sum { |v| (v - mean)**2 } / numeric_values.length.to_f)

          new_data_items = data_set.data_items.select do |item|
            value = item[feature_index]
            !value.is_a?(Numeric) || (value - mean).abs / std_dev <= 3
          end
        end

        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: new_data_items
        )
      end

      # Create interaction features
      def self.create_interaction_features(data_set, feature_indices)
        return data_set if feature_indices.length < 2

        # Create interaction label
        interaction_label = feature_indices.map { |i| data_set.data_labels[i] }.join('_x_')
        new_labels = data_set.data_labels + [interaction_label]

        # Create interaction feature
        new_data_items = data_set.data_items.map do |item|
          interaction_value = feature_indices.map { |i| item[i] }.join('_')
          item + [interaction_value]
        end

        Ai4r::Data::DataSet.new(
          data_labels: new_labels,
          data_items: new_data_items
        )
      end

      def self.equal_width_binning(values, bins)
        min_val = values.min
        max_val = values.max
        width = (max_val - min_val) / bins.to_f

        (0..bins).map { |i| min_val + (i * width) }
      end

      def self.equal_frequency_binning(values, bins)
        sorted_values = values.sort
        bin_size = sorted_values.length / bins.to_f

        boundaries = [sorted_values.first]
        (1...bins).each do |i|
          index = (i * bin_size).to_i
          boundaries << sorted_values[index]
        end
        boundaries << sorted_values.last

        boundaries.uniq
      end

      def self.discretize_value(value, boundaries)
        (0...(boundaries.length - 1)).each do |i|
          return "bin_#{i}" if value >= boundaries[i] && value < boundaries[i + 1]
        end

        # Handle edge case for maximum value
        "bin_#{boundaries.length - 2}"
      end

      def self.calculate_information_gain_scores(data_set)
        feature_scores = {}

        (0...(data_set.data_labels.length - 1)).each do |feature_index|
          feature_scores[feature_index] = calculate_information_gain(data_set, feature_index)
        end

        feature_scores
      end

      def self.calculate_information_gain(data_set, feature_index)
        # Calculate entropy of the target variable
        class_counts = Hash.new(0)
        data_set.data_items.each { |item| class_counts[item.last] += 1 }

        total_entropy = 0
        class_counts.each_value do |count|
          probability = count.to_f / data_set.data_items.length
          total_entropy -= probability * Math.log2(probability) if probability > 0
        end

        # Calculate weighted entropy after splitting by feature
        feature_values = Hash.new { |h, k| h[k] = Hash.new(0) }
        data_set.data_items.each do |item|
          feature_value = item[feature_index]
          class_value = item.last
          feature_values[feature_value][class_value] += 1
        end

        weighted_entropy = 0
        feature_values.each_value do |class_counts|
          subset_size = class_counts.values.sum
          subset_entropy = 0

          class_counts.each_value do |count|
            probability = count.to_f / subset_size
            subset_entropy -= probability * Math.log2(probability) if probability > 0
          end

          weighted_entropy += (subset_size.to_f / data_set.data_items.length) * subset_entropy
        end

        # Information gain
        total_entropy - weighted_entropy
      end

      def self.fill_with_mode(data_set)
        new_data_items = data_set.data_items.map(&:dup)

        (0...data_set.data_labels.length).each do |feature_index|
          feature_values = data_set.data_items.map { |item| item[feature_index] }
          non_null_values = feature_values.compact

          next if non_null_values.empty?

          # Find mode
          mode = non_null_values.group_by(&:itself).max_by { |_, v| v.length }[0]

          # Fill missing values
          new_data_items.each do |item|
            item[feature_index] = mode if item[feature_index].nil?
          end
        end

        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: new_data_items
        )
      end

      def self.fill_with_mean(data_set)
        new_data_items = data_set.data_items.map(&:dup)

        (0...data_set.data_labels.length).each do |feature_index|
          feature_values = data_set.data_items.map { |item| item[feature_index] }
          numeric_values = feature_values.select { |v| v.is_a?(Numeric) }

          next if numeric_values.empty?

          mean = numeric_values.sum / numeric_values.length.to_f

          # Fill missing numeric values
          new_data_items.each do |item|
            item[feature_index] = mean if item[feature_index].nil?
          end
        end

        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: new_data_items
        )
      end

      def self.remove_missing_values(data_set)
        new_data_items = data_set.data_items.select do |item|
          item.none?(&:nil?)
        end

        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: new_data_items
        )
      end
    end

    # Data preprocessing pipeline
    class PreprocessingPipeline
      def initialize
        @steps = []
      end

      def add_step(step_name, processor, *args)
        @steps << { name: step_name, processor: processor, args: args }
        self
      end

      def fit_transform(data_set)
        result = data_set

        @steps.each do |step|
          puts "Applying preprocessing step: #{step[:name]}" if @verbose
          result = step[:processor].call(result, *step[:args])
        end

        result
      end

      def verbose!
        @verbose = true
        self
      end

      # Predefined pipelines
      def self.create_basic_pipeline
        pipeline = new
        pipeline.add_step('Handle missing values', ->(ds) { FeatureEngineering.handle_missing_values(ds, :mode) })
        pipeline.add_step('Remove outliers', ->(ds) { ds }) # Placeholder
        pipeline
      end

      def self.create_numeric_pipeline
        pipeline = new
        pipeline.add_step('Handle missing values', ->(ds) { FeatureEngineering.handle_missing_values(ds, :mean) })
        pipeline.add_step('Normalize features', ->(ds) { ds }) # Would need to know which features are numeric
        pipeline
      end

      def self.create_categorical_pipeline
        pipeline = new
        pipeline.add_step('Handle missing values', ->(ds) { FeatureEngineering.handle_missing_values(ds, :mode) })
        pipeline.add_step('Create dummy variables', ->(ds) { ds }) # Would need to know which features are categorical
        pipeline
      end
    end

    # Feature analysis and exploration
    class FeatureAnalyzer
      def initialize(data_set)
        @data_set = data_set
      end

      def analyze_features
        puts '=== Feature Analysis ==='
        puts "Dataset: #{@data_set.data_items.length} examples, #{@data_set.data_labels.length} features"
        puts

        analyze_basic_statistics
        analyze_class_distribution
        analyze_feature_correlations
        analyze_missing_values
        suggest_preprocessing
      end

      private

      def analyze_basic_statistics
        puts '=== Basic Feature Statistics ==='
        puts 'Feature               | Type        | Unique Values | Missing'
        puts '----------------------|-------------|---------------|--------'

        @data_set.data_labels.each_with_index do |label, index|
          values = @data_set.data_items.map { |item| item[index] }

          # Determine type
          type = if values.all?(Numeric)
                   'Numeric'
                 elsif values.uniq.length <= 10
                   'Categorical'
                 else
                   'Text'
                 end

          unique_count = values.uniq.length
          missing_count = values.count(&:nil?)

          puts format('%-21s | %-11s | %13d | %7d', label, type, unique_count, missing_count)
        end
        puts
      end

      def analyze_class_distribution
        puts '=== Class Distribution ==='
        class_values = @data_set.data_items.map(&:last)
        class_counts = class_values.group_by(&:itself).transform_values(&:length)

        class_counts.each do |class_name, count|
          percentage = (count.to_f / @data_set.data_items.length * 100).round(2)
          puts "#{class_name}: #{count} examples (#{percentage}%)"
        end
        puts
      end

      def analyze_feature_correlations
        puts '=== Feature-Class Correlations ==='
        puts 'Feature               | Information Gain'
        puts '----------------------|----------------'

        scores = FeatureEngineering.send(:calculate_information_gain_scores, @data_set)
        scores.sort_by { |_, score| -score }.each do |feature_index, score|
          feature_name = @data_set.data_labels[feature_index]
          puts format('%-21s | %14.4f', feature_name, score)
        end
        puts
      end

      def analyze_missing_values
        puts '=== Missing Values Analysis ==='
        total_missing = 0

        @data_set.data_labels.each_with_index do |label, index|
          values = @data_set.data_items.map { |item| item[index] }
          missing_count = values.count(&:nil?)

          next unless missing_count > 0

          percentage = (missing_count.to_f / @data_set.data_items.length * 100).round(2)
          puts "#{label}: #{missing_count} missing values (#{percentage}%)"
          total_missing += missing_count
        end

        puts 'No missing values detected' if total_missing == 0
        puts
      end

      def suggest_preprocessing
        puts '=== Preprocessing Suggestions ==='

        # Check for missing values
        has_missing = @data_set.data_items.any? { |item| item.any?(&:nil?) }
        puts '• Handle missing values using mode (categorical) or mean (numeric)' if has_missing

        # Check for numeric features that might need normalization
        @data_set.data_labels.each_with_index do |label, index|
          values = @data_set.data_items.map { |item| item[index] }
          numeric_values = values.select { |v| v.is_a?(Numeric) }

          next if numeric_values.empty?

          range = numeric_values.max - numeric_values.min
          puts "• Consider normalizing feature '#{label}' (range: #{range})" if range > 100

          # Check for categorical features with many values
          values = @data_set.data_items.map { |item| item[index] }
          unique_values = values.uniq

          if unique_values.length > 10 && unique_values.length < @data_set.data_items.length / 2
            puts "• Consider creating dummy variables for feature '#{label}'"
          end
        end

        # Check for class imbalance
        class_values = @data_set.data_items.map(&:last)
        class_counts = class_values.group_by(&:itself).transform_values(&:length)

        if class_counts.values.max > class_counts.values.min * 3
          puts '• Dataset has class imbalance - consider balancing techniques'
        end

        puts
      end
    end
  end
end
