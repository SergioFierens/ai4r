# frozen_string_literal: true

# Educational DataSet framework designed for students and teachers
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'data_set'
require_relative 'statistics'
require_relative 'proximity'

module Ai4r
  module Data
    # Educational DataSet extends the basic DataSet with comprehensive
    # tools for learning data science concepts
    class EducationalDataSet < DataSet
      attr_reader :metadata, :quality_report, :transformation_history

      def initialize(options = {})
        super
        @metadata = DataMetadata.new
        @quality_report = nil
        @transformation_history = []
        @educational_config = {
          verbose: options.fetch(:verbose, false),
          explain_operations: options.fetch(:explain_operations, false),
          show_warnings: options.fetch(:show_warnings, true)
        }

        analyze_data unless @data_items.empty?
      end

      # Enable educational mode with explanations
      def enable_educational_mode
        @educational_config[:verbose] = true
        @educational_config[:explain_operations] = true
        @educational_config[:show_warnings] = true
        self
      end

      # Comprehensive data analysis for educational purposes
      def analyze_data
        return if @data_items.empty?

        puts '=== Analyzing Dataset ===' if @educational_config[:verbose]

        @metadata.analyze(@data_items, @data_labels)
        @quality_report = DataQualityAnalyzer.new(self, @educational_config).analyze

        if @educational_config[:verbose]
          puts "Dataset shape: #{shape.inspect}"
          puts "Data types detected: #{@metadata.attribute_types.inspect}"
          puts "Missing values detected: #{@quality_report[:missing_values_summary]}" if @quality_report[:has_missing_values]
        end

        self
      end

      # Get dataset dimensions [rows, columns]
      def shape
        return [0, 0] if @data_items.empty?

        [@data_items.length, @data_items.first&.length || 0]
      end

      # Get detailed information about the dataset
      def info
        DataProfiler.new(self, @educational_config).generate_report
      end

      # Statistical summary of numeric columns
      def describe
        DataProfiler.new(self, @educational_config).statistical_summary
      end

      # Check for missing values
      def missing_values_report
        DataQualityAnalyzer.new(self, @educational_config).missing_values_analysis
      end

      # Detect outliers using various methods
      def detect_outliers(method: :iqr, threshold: 1.5)
        if @educational_config[:explain_operations]
          puts "\n=== Outlier Detection ==="
          puts "Method: #{method}"
          puts "Explanation: #{OutlierDetector.explain_method(method)}"
        end

        OutlierDetector.new(self, @educational_config).detect(method, threshold)
      end

      # Data normalization with educational explanations
      def normalize!(method: :min_max)
        if @educational_config[:explain_operations]
          puts "\n=== Data Normalization ==="
          puts "Method: #{method}"
          puts "Explanation: #{DataNormalizer.explain_method(method)}"
        end

        normalizer = DataNormalizer.new(self, @educational_config)
        normalized_data = normalizer.normalize(@data_items, method)

        # Record transformation
        @transformation_history << {
          operation: 'normalize',
          method: method,
          timestamp: Time.now,
          parameters: { method: method }
        }

        @data_items = normalized_data
        analyze_data
        self
      end

      # Create a normalized copy
      def normalize(method: :min_max)
        copy = dup
        copy.normalize!(method: method)
      end

      # Handle missing values
      def handle_missing_values!(strategy: :mean)
        if @educational_config[:explain_operations]
          puts "\n=== Handling Missing Values ==="
          puts "Strategy: #{strategy}"
          puts "Explanation: #{MissingValueHandler.explain_strategy(strategy)}"
        end

        handler = MissingValueHandler.new(self, @educational_config)
        cleaned_data = handler.handle(@data_items, strategy)

        @transformation_history << {
          operation: 'handle_missing',
          strategy: strategy,
          timestamp: Time.now,
          parameters: { strategy: strategy }
        }

        @data_items = cleaned_data
        analyze_data
        self
      end

      # Feature scaling for machine learning
      def scale_features!(method: :standardize)
        if @educational_config[:explain_operations]
          puts "\n=== Feature Scaling ==="
          puts "Method: #{method}"
          puts "Explanation: #{FeatureScaler.explain_method(method)}"
        end

        scaler = FeatureScaler.new(self, @educational_config)
        scaled_data = scaler.scale(@data_items, method)

        @transformation_history << {
          operation: 'scale_features',
          method: method,
          timestamp: Time.now,
          parameters: { method: method }
        }

        @data_items = scaled_data
        analyze_data
        self
      end

      # Split dataset for training/testing
      def train_test_split(test_size: 0.2, random_seed: nil)
        if @educational_config[:explain_operations]
          puts "\n=== Train-Test Split ==="
          puts "Test size: #{(test_size * 100).round(1)}%"
          puts "Training size: #{((1 - test_size) * 100).round(1)}%"
          puts 'Purpose: Evaluate model performance on unseen data'
        end

        DataSplitter.new(self, @educational_config).split(test_size, random_seed)
      end

      # Cross-validation folds
      def cross_validation_folds(k: 5, random_seed: nil)
        if @educational_config[:explain_operations]
          puts "\n=== Cross-Validation Folds ==="
          puts "K-folds: #{k}"
          puts 'Purpose: Robust model evaluation using multiple train/test splits'
        end

        DataSplitter.new(self, @educational_config).k_fold_split(k, random_seed)
      end

      # Feature correlation analysis
      def correlation_matrix
        CorrelationAnalyzer.new(self, @educational_config).calculate_correlations
      end

      # Data visualization (ASCII-based for educational purposes)
      def visualize(column: nil, chart_type: :histogram)
        DataVisualizer.new(self, @educational_config).visualize(column, chart_type)
      end

      # Compare different distance metrics on the data
      def compare_distance_metrics(sample_size: 10)
        DistanceComparator.new(self, @educational_config).compare(sample_size)
      end

      # Educational data generation for experimenting
      def self.generate_sample_data(type: :classification, size: 100, features: 2, noise: 0.1)
        DataGenerator.generate(type, size, features, noise)
      end

      # Apply feature engineering techniques
      def engineer_features!(techniques: [:polynomial])
        if @educational_config[:explain_operations]
          puts "\n=== Feature Engineering ==="
          puts "Techniques: #{techniques.inspect}"
        end

        engineer = FeatureEngineer.new(self, @educational_config)
        engineered_data = engineer.apply_techniques(@data_items, techniques)

        @transformation_history << {
          operation: 'engineer_features',
          techniques: techniques,
          timestamp: Time.now,
          parameters: { techniques: techniques }
        }

        @data_items = engineered_data
        # Update labels for new features
        update_labels_after_engineering(techniques)
        analyze_data
        self
      end

      # Show transformation history
      def transformation_history_report
        puts "\n=== Data Transformation History ==="
        if @transformation_history.empty?
          puts 'No transformations applied yet.'
          return
        end

        @transformation_history.each_with_index do |transform, index|
          puts "#{index + 1}. #{transform[:operation]} (#{transform[:timestamp]})"
          puts "   Parameters: #{transform[:parameters]}" if transform[:parameters]
        end
      end

      # Undo last transformation (educational feature)
      def undo_last_transformation
        if @transformation_history.empty?
          puts 'No transformations to undo.' if @educational_config[:verbose]
          return self
        end

        last_transform = @transformation_history.pop
        puts "Undoing: #{last_transform[:operation]}" if @educational_config[:verbose]

        # In a full implementation, we'd need to store previous states
        # For educational purposes, we'll show the concept
        puts 'Note: Undo functionality requires storing data states - implement for production use'
        self
      end

      # Export processed data
      def export_csv(filename, include_metadata: true)
        DataExporter.new(self, @educational_config).export_csv(filename, include_metadata)
      end

      # Export educational report
      def export_analysis_report(filename)
        DataReporter.new(self, @educational_config).generate_full_report(filename)
      end

      private

      def update_labels_after_engineering(techniques)
        # Update data labels to reflect new engineered features
        # This is a simplified version - full implementation would track all changes
        return unless techniques.include?(:polynomial)

        # Add labels for polynomial features
        original_features = @data_labels[0...-1] # Exclude class label
        original_features.combination(2).each do |feat1, feat2|
          @data_labels.insert(-2, "#{feat1}_x_#{feat2}")
        end
      end
    end

    # Metadata analysis for datasets
    class DataMetadata
      attr_reader :attribute_types, :attribute_stats, :data_shape

      def initialize
        @attribute_types = {}
        @attribute_stats = {}
        @data_shape = [0, 0]
      end

      def analyze(data_items, data_labels)
        return if data_items.empty?

        @data_shape = [data_items.length, data_items.first&.length || 0]

        # Analyze each attribute
        data_labels.each_with_index do |label, index|
          @attribute_types[label] = detect_type(data_items, index)
          @attribute_stats[label] = calculate_basic_stats(data_items, index)
        end
      end

      private

      def detect_type(data_items, index)
        sample_values = data_items.first(100).filter_map { |item| item[index] }
        return :unknown if sample_values.empty?

        # Check if all values are numeric
        if sample_values.all?(Numeric)
          # Check if they're all integers
          if sample_values.all? { |val| val.is_a?(Integer) || val.to_i == val.to_f }
            :integer
          else
            :float
          end
        elsif sample_values.all? { |val| [true, false].include?(val) }
          :boolean
        else
          # Check if it looks like a category (limited unique values)
          unique_count = sample_values.uniq.length
          if unique_count <= [sample_values.length * 0.1, 10].max
            :categorical
          else
            :text
          end
        end
      end

      def calculate_basic_stats(data_items, index)
        values = data_items.filter_map { |item| item[index] }

        stats = {
          count: values.length,
          unique_count: values.uniq.length,
          null_count: data_items.length - values.length
        }

        if values.first.is_a?(Numeric) && !values.empty?
          stats.merge!({
                         min: values.min,
                         max: values.max,
                         mean: values.sum.to_f / values.length,
                         median: calculate_median(values)
                       })
        end

        stats
      end

      def calculate_median(values)
        sorted = values.sort
        mid = sorted.length / 2
        sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
      end
    end

    # Data quality analysis tool
    class DataQualityAnalyzer
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end

      def analyze
        report = {
          total_rows: @dataset.data_items.length,
          total_columns: @dataset.num_attributes,
          has_missing_values: false,
          missing_values_summary: {},
          data_types: {},
          potential_issues: []
        }

        return report if @dataset.data_items.empty?

        # Check for missing values
        missing_analysis = missing_values_analysis
        report[:has_missing_values] = missing_analysis[:has_missing]
        report[:missing_values_summary] = missing_analysis[:summary]

        # Check for data quality issues
        report[:potential_issues] = detect_quality_issues

        if @config[:verbose] && !report[:potential_issues].empty?
          puts "\n⚠️  Data Quality Issues Detected:"
          report[:potential_issues].each { |issue| puts "  • #{issue}" }
        end

        report
      end

      def missing_values_analysis
        missing_info = { has_missing: false, summary: {} }

        return missing_info if @dataset.data_items.empty?

        @dataset.data_labels.each_with_index do |label, index|
          missing_count = @dataset.data_items.count { |item| item[index].nil? || item[index] == '' }
          next unless missing_count > 0

          missing_info[:has_missing] = true
          missing_info[:summary][label] = {
            count: missing_count,
            percentage: (missing_count.to_f / @dataset.data_items.length * 100).round(2)
          }
        end

        if @config[:verbose] && missing_info[:has_missing]
          puts "\n=== Missing Values Report ==="
          missing_info[:summary].each do |label, info|
            puts "#{label}: #{info[:count]} missing (#{info[:percentage]}%)"
          end
        end

        missing_info
      end

      private

      def detect_quality_issues
        issues = []

        # Check for duplicate rows
        if @dataset.data_items.uniq.length < @dataset.data_items.length
          duplicates = @dataset.data_items.length - @dataset.data_items.uniq.length
          issues << "#{duplicates} duplicate rows detected"
        end

        # Check for constant columns
        @dataset.data_labels.each_with_index do |label, index|
          values = @dataset.data_items.filter_map { |item| item[index] }.uniq
          issues << "Column '#{label}' has constant value (#{values.first})" if values.length == 1
        end

        # Check for high cardinality in small datasets
        if @dataset.data_items.length < 100
          @dataset.data_labels.each_with_index do |label, index|
            unique_count = @dataset.data_items.filter_map { |item| item[index] }.uniq.length
            if unique_count > @dataset.data_items.length * 0.8
              issues << "Column '#{label}' has very high cardinality (#{unique_count} unique values)"
            end
          end
        end

        issues
      end
    end

    # Data profiling and summary generation
    class DataProfiler
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end

      def generate_report
        puts "\n#{'=' * 60}"
        puts 'DATASET PROFILE REPORT'
        puts '=' * 60

        # Basic info
        puts "\nBasic Information:"
        puts "  Shape: #{@dataset.shape.inspect} (rows, columns)"
        puts "  Total data points: #{@dataset.shape[0] * @dataset.shape[1]}"

        # Data types
        puts "\nData Types:"
        @dataset.metadata.attribute_types.each do |label, type|
          puts "  #{label}: #{type}"
        end

        # Missing values
        if @dataset.quality_report[:has_missing_values]
          puts "\nMissing Values:"
          @dataset.quality_report[:missing_values_summary].each do |label, info|
            puts "  #{label}: #{info[:count]} (#{info[:percentage]}%)"
          end
        else
          puts "\nMissing Values: None detected ✓"
        end

        # Statistical summary for numeric columns
        statistical_summary

        puts "\n#{'=' * 60}"
      end

      def statistical_summary
        puts "\nStatistical Summary (Numeric Columns):"
        puts 'Column             Count     Mean      Std      Min      Max'
        puts '-' * 70

        @dataset.data_labels.each_with_index do |label, index|
          next unless %i[float integer].include?(@dataset.metadata.attribute_types[label])

          stats = @dataset.metadata.attribute_stats[label]
          values = @dataset.data_items.filter_map { |item| item[index] }

          if values.length > 1
            variance = values.sum { |v| (v - stats[:mean])**2 } / (values.length - 1)
            std = Math.sqrt(variance)
          else
            std = 0.0
          end

          puts format('%-15s %8d %8.2f %8.2f %8.2f %8.2f',
                      label, stats[:count], stats[:mean], std, stats[:min], stats[:max])
        end
      end
    end
  end
end
