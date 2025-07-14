# frozen_string_literal: true

# Data preprocessing tools for educational purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    
    # Data normalization techniques with educational explanations
    class DataNormalizer
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def normalize(data_items, method)
        case method
        when :min_max
          min_max_normalization(data_items)
        when :z_score, :standardize
          z_score_normalization(data_items)
        when :robust
          robust_normalization(data_items)
        when :unit_vector
          unit_vector_normalization(data_items)
        else
          raise ArgumentError, "Unknown normalization method: #{method}"
        end
      end
      
      def self.explain_method(method)
        explanations = {
          min_max: "Min-Max: Scales data to [0,1] range. Formula: (x - min) / (max - min). Good when you know the bounds.",
          z_score: "Z-Score: Centers data around 0 with std=1. Formula: (x - mean) / std. Good for normally distributed data.",
          standardize: "Same as Z-Score normalization - centers and scales data.",
          robust: "Robust: Uses median and IQR instead of mean/std. Less sensitive to outliers.",
          unit_vector: "Unit Vector: Scales each row to unit length. Good for text/sparse data."
        }
        explanations[method] || "Unknown method"
      end
      
      private
      
      def min_max_normalization(data_items)
        return data_items if data_items.empty?
        
        # Calculate min/max for each numeric column
        mins, maxs = calculate_min_max(data_items)
        
        normalized = data_items.map do |row|
          row.each_with_index.map do |value, idx|
            if value.is_a?(Numeric) && mins[idx] && maxs[idx]
              range = maxs[idx] - mins[idx]
              range == 0 ? 0.5 : (value - mins[idx]) / range
            else
              value
            end
          end
        end
        
        if @config[:verbose]
          puts "Applied Min-Max normalization to numeric columns"
          puts "Ranges: #{mins.zip(maxs).map { |min, max| min && max ? "[#{min.round(3)}, #{max.round(3)}]" : "N/A" }}"
        end
        
        normalized
      end
      
      def z_score_normalization(data_items)
        return data_items if data_items.empty?
        
        # Calculate mean and std for each numeric column
        means, stds = calculate_mean_std(data_items)
        
        normalized = data_items.map do |row|
          row.each_with_index.map do |value, idx|
            if value.is_a?(Numeric) && means[idx] && stds[idx] && stds[idx] > 0
              (value - means[idx]) / stds[idx]
            else
              value
            end
          end
        end
        
        if @config[:verbose]
          puts "Applied Z-Score normalization to numeric columns"
          puts "Means: #{means.map { |m| m ? m.round(3) : "N/A" }}"
          puts "Stds: #{stds.map { |s| s ? s.round(3) : "N/A" }}"
        end
        
        normalized
      end
      
      def robust_normalization(data_items)
        return data_items if data_items.empty?
        
        # Calculate median and IQR for each numeric column
        medians, iqrs = calculate_median_iqr(data_items)
        
        normalized = data_items.map do |row|
          row.each_with_index.map do |value, idx|
            if value.is_a?(Numeric) && medians[idx] && iqrs[idx] && iqrs[idx] > 0
              (value - medians[idx]) / iqrs[idx]
            else
              value
            end
          end
        end
        
        if @config[:verbose]
          puts "Applied Robust normalization to numeric columns"
          puts "Medians: #{medians.map { |m| m ? m.round(3) : "N/A" }}"
          puts "IQRs: #{iqrs.map { |i| i ? i.round(3) : "N/A" }}"
        end
        
        normalized
      end
      
      def unit_vector_normalization(data_items)
        normalized = data_items.map do |row|
          numeric_values = row.select { |val| val.is_a?(Numeric) }
          if numeric_values.empty?
            row
          else
            magnitude = Math.sqrt(numeric_values.sum { |val| val**2 })
            if magnitude == 0
              row
            else
              row.map { |val| val.is_a?(Numeric) ? val / magnitude : val }
            end
          end
        end
        
        puts "Applied Unit Vector normalization" if @config[:verbose]
        normalized
      end
      
      def calculate_min_max(data_items)
        num_cols = data_items.first&.length || 0
        mins = Array.new(num_cols)
        maxs = Array.new(num_cols)
        
        num_cols.times do |col|
          values = data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          if values.any?
            mins[col] = values.min
            maxs[col] = values.max
          end
        end
        
        [mins, maxs]
      end
      
      def calculate_mean_std(data_items)
        num_cols = data_items.first&.length || 0
        means = Array.new(num_cols)
        stds = Array.new(num_cols)
        
        num_cols.times do |col|
          values = data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          if values.length > 1
            mean = values.sum.to_f / values.length
            variance = values.sum { |val| (val - mean)**2 } / (values.length - 1)
            means[col] = mean
            stds[col] = Math.sqrt(variance)
          end
        end
        
        [means, stds]
      end
      
      def calculate_median_iqr(data_items)
        num_cols = data_items.first&.length || 0
        medians = Array.new(num_cols)
        iqrs = Array.new(num_cols)
        
        num_cols.times do |col|
          values = data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }.sort
          if values.length > 1
            # Calculate median
            mid = values.length / 2
            median = values.length.odd? ? values[mid] : (values[mid - 1] + values[mid]) / 2.0
            
            # Calculate IQR
            q1_idx = values.length / 4
            q3_idx = 3 * values.length / 4
            q1 = values[q1_idx]
            q3 = values[q3_idx]
            
            medians[col] = median
            iqrs[col] = q3 - q1
          end
        end
        
        [medians, iqrs]
      end
    end
    
    # Missing value handling strategies
    class MissingValueHandler
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def handle(data_items, strategy)
        case strategy
        when :remove_rows
          remove_rows_with_missing(data_items)
        when :remove_columns
          remove_columns_with_missing(data_items)
        when :mean
          fill_with_mean(data_items)
        when :median
          fill_with_median(data_items)
        when :mode
          fill_with_mode(data_items)
        when :forward_fill
          forward_fill(data_items)
        when :interpolate
          interpolate_missing(data_items)
        else
          raise ArgumentError, "Unknown missing value strategy: #{strategy}"
        end
      end
      
      def self.explain_strategy(strategy)
        explanations = {
          remove_rows: "Remove Rows: Deletes all rows with any missing values. Simple but loses data.",
          remove_columns: "Remove Columns: Deletes columns with missing values. Loses features entirely.",
          mean: "Mean Imputation: Replaces missing values with column mean. Good for normal distributions.",
          median: "Median Imputation: Replaces with median. Robust to outliers.",
          mode: "Mode Imputation: Replaces with most frequent value. Good for categorical data.",
          forward_fill: "Forward Fill: Uses previous value. Good for time series data.",
          interpolate: "Interpolation: Estimates values between known points. Good for continuous data."
        }
        explanations[strategy] || "Unknown strategy"
      end
      
      private
      
      def remove_rows_with_missing(data_items)
        original_count = data_items.length
        clean_data = data_items.reject do |row|
          row.any? { |val| val.nil? || val == "" }
        end
        
        if @config[:verbose]
          removed = original_count - clean_data.length
          puts "Removed #{removed} rows with missing values (#{((removed.to_f / original_count) * 100).round(1)}%)"
        end
        
        clean_data
      end
      
      def remove_columns_with_missing(data_items)
        return data_items if data_items.empty?
        
        num_cols = data_items.first.length
        cols_to_keep = []
        
        num_cols.times do |col|
          has_missing = data_items.any? { |row| row[col].nil? || row[col] == "" }
          cols_to_keep << col unless has_missing
        end
        
        if @config[:verbose]
          removed = num_cols - cols_to_keep.length
          puts "Removed #{removed} columns with missing values"
        end
        
        data_items.map { |row| cols_to_keep.map { |col| row[col] } }
      end
      
      def fill_with_mean(data_items)
        fill_with_statistic(data_items, :mean)
      end
      
      def fill_with_median(data_items)
        fill_with_statistic(data_items, :median)
      end
      
      def fill_with_mode(data_items)
        fill_with_statistic(data_items, :mode)
      end
      
      def fill_with_statistic(data_items, stat_type)
        return data_items if data_items.empty?
        
        num_cols = data_items.first.length
        fill_values = Array.new(num_cols)
        
        # Calculate fill values for each column
        num_cols.times do |col|
          values = data_items.map { |row| row[col] }.reject { |val| val.nil? || val == "" }
          next if values.empty?
          
          fill_values[col] = case stat_type
                           when :mean
                             values.select { |v| v.is_a?(Numeric) }.sum.to_f / values.length if values.any? { |v| v.is_a?(Numeric) }
                           when :median
                             numeric_values = values.select { |v| v.is_a?(Numeric) }.sort
                             if numeric_values.any?
                               mid = numeric_values.length / 2
                               numeric_values.length.odd? ? numeric_values[mid] : (numeric_values[mid - 1] + numeric_values[mid]) / 2.0
                             end
                           when :mode
                             values.group_by(&:itself).max_by { |_, v| v.length }&.first
                           end
        end
        
        # Fill missing values
        filled_count = 0
        filled_data = data_items.map do |row|
          row.each_with_index.map do |val, col|
            if (val.nil? || val == "") && fill_values[col]
              filled_count += 1
              fill_values[col]
            else
              val
            end
          end
        end
        
        if @config[:verbose]
          puts "Filled #{filled_count} missing values using #{stat_type}"
        end
        
        filled_data
      end
      
      def forward_fill(data_items)
        return data_items if data_items.empty?
        
        filled_data = []
        last_valid_row = nil
        
        data_items.each do |row|
          if last_valid_row
            filled_row = row.each_with_index.map do |val, col|
              (val.nil? || val == "") ? last_valid_row[col] : val
            end
            filled_data << filled_row
            last_valid_row = filled_row
          else
            filled_data << row
            last_valid_row = row unless row.any? { |val| val.nil? || val == "" }
          end
        end
        
        puts "Applied forward fill to missing values" if @config[:verbose]
        filled_data
      end
      
      def interpolate_missing(data_items)
        # Simple linear interpolation for numeric data
        return data_items if data_items.empty?
        
        num_cols = data_items.first.length
        filled_data = data_items.dup
        
        num_cols.times do |col|
          values = data_items.map.with_index { |row, idx| [idx, row[col]] }
          numeric_values = values.select { |_, val| val.is_a?(Numeric) && !val.nil? }
          
          next if numeric_values.length < 2
          
          # Interpolate missing values
          data_items.each_with_index do |row, idx|
            if row[col].nil? || row[col] == ""
              # Find surrounding valid values
              before = numeric_values.select { |i, _| i < idx }.last
              after = numeric_values.select { |i, _| i > idx }.first
              
              if before && after
                # Linear interpolation
                x1, y1 = before
                x2, y2 = after
                interpolated = y1 + (y2 - y1) * (idx - x1).to_f / (x2 - x1)
                filled_data[idx][col] = interpolated
              end
            end
          end
        end
        
        puts "Applied linear interpolation to missing numeric values" if @config[:verbose]
        filled_data
      end
    end
    
    # Outlier detection methods
    class OutlierDetector
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def detect(method, threshold)
        case method
        when :iqr
          iqr_method(threshold)
        when :z_score
          z_score_method(threshold)
        when :modified_z_score
          modified_z_score_method(threshold)
        when :isolation_forest
          isolation_forest_method(threshold)
        else
          raise ArgumentError, "Unknown outlier detection method: #{method}"
        end
      end
      
      def self.explain_method(method)
        explanations = {
          iqr: "IQR Method: Uses Interquartile Range. Outliers are beyond Q1 - 1.5*IQR or Q3 + 1.5*IQR",
          z_score: "Z-Score: Based on standard deviations from mean. Outliers typically |z| > 3",
          modified_z_score: "Modified Z-Score: Uses median instead of mean. More robust to outliers",
          isolation_forest: "Isolation Forest: Tree-based anomaly detection. Good for complex patterns"
        }
        explanations[method] || "Unknown method"
      end
      
      private
      
      def iqr_method(threshold)
        outliers = {}
        
        @dataset.data_labels.each_with_index do |label, col|
          values = @dataset.data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          next if values.length < 4
          
          sorted_values = values.sort
          q1_idx = sorted_values.length / 4
          q3_idx = 3 * sorted_values.length / 4
          q1 = sorted_values[q1_idx]
          q3 = sorted_values[q3_idx]
          iqr = q3 - q1
          
          lower_bound = q1 - threshold * iqr
          upper_bound = q3 + threshold * iqr
          
          column_outliers = @dataset.data_items.each_with_index.select do |row, idx|
            val = row[col]
            val.is_a?(Numeric) && (val < lower_bound || val > upper_bound)
          end.map(&:last)
          
          outliers[label] = {
            indices: column_outliers,
            bounds: [lower_bound, upper_bound],
            count: column_outliers.length
          } if column_outliers.any?
        end
        
        report_outliers(outliers, :iqr)
        outliers
      end
      
      def z_score_method(threshold)
        outliers = {}
        
        @dataset.data_labels.each_with_index do |label, col|
          values = @dataset.data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          next if values.length < 2
          
          mean = values.sum.to_f / values.length
          variance = values.sum { |val| (val - mean)**2 } / (values.length - 1)
          std = Math.sqrt(variance)
          
          next if std == 0
          
          column_outliers = @dataset.data_items.each_with_index.select do |row, idx|
            val = row[col]
            val.is_a?(Numeric) && ((val - mean).abs / std) > threshold
          end.map(&:last)
          
          outliers[label] = {
            indices: column_outliers,
            threshold: threshold,
            count: column_outliers.length
          } if column_outliers.any?
        end
        
        report_outliers(outliers, :z_score)
        outliers
      end
      
      def modified_z_score_method(threshold)
        outliers = {}
        
        @dataset.data_labels.each_with_index do |label, col|
          values = @dataset.data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          next if values.length < 2
          
          # Calculate median
          sorted_values = values.sort
          median = sorted_values.length.odd? ? 
                   sorted_values[sorted_values.length / 2] : 
                   (sorted_values[sorted_values.length / 2 - 1] + sorted_values[sorted_values.length / 2]) / 2.0
          
          # Calculate MAD (Median Absolute Deviation)
          mad = sorted_values.map { |val| (val - median).abs }.sort
          mad_median = mad.length.odd? ? 
                       mad[mad.length / 2] : 
                       (mad[mad.length / 2 - 1] + mad[mad.length / 2]) / 2.0
          
          next if mad_median == 0
          
          column_outliers = @dataset.data_items.each_with_index.select do |row, idx|
            val = row[col]
            val.is_a?(Numeric) && (0.6745 * (val - median).abs / mad_median) > threshold
          end.map(&:last)
          
          outliers[label] = {
            indices: column_outliers,
            threshold: threshold,
            count: column_outliers.length
          } if column_outliers.any?
        end
        
        report_outliers(outliers, :modified_z_score)
        outliers
      end
      
      def isolation_forest_method(threshold)
        # Simplified isolation forest concept for educational purposes
        outliers = {}
        
        puts "Note: Simplified isolation forest implementation for educational purposes" if @config[:verbose]
        
        # For each numeric column, use a simple depth-based approach
        @dataset.data_labels.each_with_index do |label, col|
          values = @dataset.data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          next if values.length < 10
          
          # Simple approach: values that are isolated in small ranges
          sorted_values = values.sort
          column_outliers = []
          
          values.each_with_index do |val, original_idx|
            # Find how many neighbors this value has within a small range
            range = (sorted_values.max - sorted_values.min) * 0.1
            neighbors = values.count { |v| (v - val).abs <= range }
            isolation_score = 1.0 / (neighbors + 1)
            
            if isolation_score > threshold
              column_outliers << @dataset.data_items.index { |row| row[col] == val }
            end
          end
          
          outliers[label] = {
            indices: column_outliers.compact,
            threshold: threshold,
            count: column_outliers.compact.length
          } if column_outliers.any?
        end
        
        report_outliers(outliers, :isolation_forest)
        outliers
      end
      
      def report_outliers(outliers, method)
        return if !@config[:verbose] || outliers.empty?
        
        puts "\n=== Outlier Detection Results (#{method}) ==="
        outliers.each do |column, info|
          puts "#{column}: #{info[:count]} outliers detected"
          if info[:count] <= 10  # Show indices for small numbers
            puts "  Row indices: #{info[:indices].inspect}"
          end
        end
      end
    end
    
    # Feature scaling methods
    class FeatureScaler
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def scale(data_items, method)
        case method
        when :standardize
          standardize_features(data_items)
        when :normalize
          normalize_features(data_items)
        when :robust_scale
          robust_scale_features(data_items)
        when :quantile_uniform
          quantile_uniform_transform(data_items)
        else
          raise ArgumentError, "Unknown scaling method: #{method}"
        end
      end
      
      def self.explain_method(method)
        explanations = {
          standardize: "Standardize: Z-score normalization (mean=0, std=1). Good for most ML algorithms.",
          normalize: "Normalize: Min-max scaling to [0,1]. Good when you know the feature bounds.",
          robust_scale: "Robust Scale: Uses median and IQR. Less affected by outliers.",
          quantile_uniform: "Quantile Transform: Maps to uniform distribution. Good for non-linear data."
        }
        explanations[method] || "Unknown method"
      end
      
      private
      
      def standardize_features(data_items)
        # Same as z-score normalization but focused on features (excluding class)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1  # Exclude class column
        means = Array.new(feature_count)
        stds = Array.new(feature_count)
        
        # Calculate means and stds for feature columns only
        feature_count.times do |col|
          values = data_items.map { |row| row[col] }.select { |val| val.is_a?(Numeric) }
          if values.length > 1
            mean = values.sum.to_f / values.length
            variance = values.sum { |val| (val - mean)**2 } / (values.length - 1)
            means[col] = mean
            stds[col] = Math.sqrt(variance)
          end
        end
        
        scaled_data = data_items.map do |row|
          row.each_with_index.map do |val, col|
            if col < feature_count && val.is_a?(Numeric) && means[col] && stds[col] && stds[col] > 0
              (val - means[col]) / stds[col]
            else
              val  # Keep class column unchanged
            end
          end
        end
        
        puts "Standardized #{feature_count} feature columns" if @config[:verbose]
        scaled_data
      end
      
      def normalize_features(data_items)
        # Min-max scaling for features only
        DataNormalizer.new(@dataset, @config).normalize(data_items, :min_max)
      end
      
      def robust_scale_features(data_items)
        # Robust scaling for features only
        DataNormalizer.new(@dataset, @config).normalize(data_items, :robust)
      end
      
      def quantile_uniform_transform(data_items)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1
        
        transformed_data = data_items.map do |row|
          row.each_with_index.map do |val, col|
            if col < feature_count && val.is_a?(Numeric)
              # Get all values for this column and sort them
              column_values = data_items.map { |r| r[col] }.select { |v| v.is_a?(Numeric) }.sort
              # Find percentile rank
              rank = column_values.index(val) || column_values.length - 1
              rank.to_f / (column_values.length - 1)
            else
              val
            end
          end
        end
        
        puts "Applied quantile uniform transformation to #{feature_count} features" if @config[:verbose]
        transformed_data
      end
    end
    
    # Data splitting for machine learning
    class DataSplitter
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def split(test_size, random_seed = nil)
        srand(random_seed) if random_seed
        
        data_items = @dataset.data_items.dup
        data_items.shuffle!
        
        split_index = (data_items.length * (1 - test_size)).to_i
        train_data = data_items[0...split_index]
        test_data = data_items[split_index..-1]
        
        if @config[:verbose]
          puts "Split: #{train_data.length} training, #{test_data.length} testing samples"
        end
        
        {
          train: EducationalDataSet.new(data_items: train_data, data_labels: @dataset.data_labels),
          test: EducationalDataSet.new(data_items: test_data, data_labels: @dataset.data_labels)
        }
      end
      
      def k_fold_split(k, random_seed = nil)
        srand(random_seed) if random_seed
        
        data_items = @dataset.data_items.dup
        data_items.shuffle!
        
        fold_size = data_items.length / k
        folds = []
        
        k.times do |i|
          start_idx = i * fold_size
          end_idx = (i == k - 1) ? data_items.length : (i + 1) * fold_size
          
          test_data = data_items[start_idx...end_idx]
          train_data = data_items[0...start_idx] + data_items[end_idx..-1]
          
          folds << {
            fold: i + 1,
            train: EducationalDataSet.new(data_items: train_data, data_labels: @dataset.data_labels),
            test: EducationalDataSet.new(data_items: test_data, data_labels: @dataset.data_labels)
          }
        end
        
        if @config[:verbose]
          puts "Created #{k} folds for cross-validation"
          folds.each { |fold| puts "  Fold #{fold[:fold]}: #{fold[:train].data_items.length} train, #{fold[:test].data_items.length} test" }
        end
        
        folds
      end
    end
  end
end