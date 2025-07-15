# frozen_string_literal: true

# Data normalization and scaling utilities for educational purposes
# Author::    Claude (AI Assistant) 
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    
    # Educational data normalizer with detailed explanations
    class DataNormalizer
      
      def initialize(dataset, educational_config = {})
        @dataset = dataset
        @config = educational_config
        @verbose = educational_config.fetch(:verbose, false)
        @explain_operations = educational_config.fetch(:explain_operations, false)
      end
      
      # Normalize data using specified method
      def normalize(data_items, method = :min_max)
        explain_normalization_method(method) if @explain_operations
        
        case method
        when :min_max
          min_max_normalize(data_items)
        when :z_score, :standardize
          z_score_normalize(data_items)
        when :robust
          robust_normalize(data_items)
        when :unit_vector
          unit_vector_normalize(data_items)
        when :decimal_scaling
          decimal_scaling_normalize(data_items)
        else
          raise ArgumentError, "Unknown normalization method: #{method}"
        end
      end
      
      # Explain different normalization methods
      def self.explain_method(method)
        explanations = {
          min_max: "Min-Max normalization scales data to [0,1] range using (x-min)/(max-min). " +
                   "Best for: When you know the data bounds. Preserves original distribution shape.",
          
          z_score: "Z-score standardization transforms data to mean=0, std=1 using (x-μ)/σ. " +
                   "Best for: Normally distributed data. Makes features comparable.",
          
          robust: "Robust scaling uses median and IQR: (x-median)/IQR. " +
                  "Best for: Data with outliers. Less sensitive to extreme values.",
          
          unit_vector: "Unit vector scaling normalizes each row to unit length. " +
                       "Best for: When direction matters more than magnitude (e.g., text data).",
          
          decimal_scaling: "Decimal scaling divides by power of 10 to fit in [-1,1]. " +
                          "Best for: When you want to preserve relative magnitudes."
        }
        
        explanations[method] || "Unknown normalization method"
      end
      
      private
      
      def explain_normalization_method(method)
        puts "\n📐 Normalization Method: #{method.to_s.humanize}"
        puts "Purpose: #{self.class.explain_method(method)}"
        
        if @config[:show_warnings]
          show_method_warnings(method)
        end
      end
      
      def show_method_warnings(method)
        warnings = {
          min_max: "⚠️  Warning: Sensitive to outliers. New data outside training range may cause issues.",
          z_score: "⚠️  Warning: Assumes normal distribution. May not work well with skewed data.",
          robust: "✅ Good choice for data with outliers.",
          unit_vector: "⚠️  Warning: Changes the meaning of individual features.",
          decimal_scaling: "⚠️  Warning: May not fully utilize the range [0,1]."
        }
        
        puts warnings[method] if warnings[method]
      end
      
      def min_max_normalize(data_items)
        return data_items if data_items.empty?
        
        normalized_data = []
        num_features = data_items.first.length
        
        # Calculate min and max for each feature
        feature_ranges = calculate_feature_ranges(data_items, num_features)
        
        if @verbose
          puts "📊 Feature ranges calculated:"
          feature_ranges.each_with_index do |range, idx|
            next unless range[:numeric]
            puts "  Feature #{idx}: [#{range[:min]}, #{range[:max]}] → [0, 1]"
          end
        end
        
        # Apply normalization
        data_items.each do |item|
          normalized_item = item.map.with_index do |value, idx|
            range = feature_ranges[idx]
            
            if range[:numeric] && value.is_a?(Numeric)
              # Avoid division by zero
              if range[:max] == range[:min]
                0.5  # Set to middle value if no variation
              else
                (value - range[:min]).to_f / (range[:max] - range[:min])
              end
            else
              value  # Keep non-numeric values unchanged
            end
          end
          
          normalized_data << normalized_item
        end
        
        normalized_data
      end
      
      def z_score_normalize(data_items)
        return data_items if data_items.empty?
        
        normalized_data = []
        num_features = data_items.first.length
        
        # Calculate mean and standard deviation for each feature
        feature_stats = calculate_feature_statistics(data_items, num_features)
        
        if @verbose
          puts "📊 Feature statistics calculated:"
          feature_stats.each_with_index do |stats, idx|
            next unless stats[:numeric]
            puts "  Feature #{idx}: μ=#{stats[:mean].round(3)}, σ=#{stats[:std].round(3)}"
          end
        end
        
        # Apply standardization
        data_items.each do |item|
          normalized_item = item.map.with_index do |value, idx|
            stats = feature_stats[idx]
            
            if stats[:numeric] && value.is_a?(Numeric)
              # Avoid division by zero
              if stats[:std] == 0
                0  # Set to 0 if no variation
              else
                (value - stats[:mean]) / stats[:std]
              end
            else
              value  # Keep non-numeric values unchanged
            end
          end
          
          normalized_data << normalized_item
        end
        
        normalized_data
      end
      
      def robust_normalize(data_items)
        return data_items if data_items.empty?
        
        normalized_data = []
        num_features = data_items.first.length
        
        # Calculate median and IQR for each feature
        feature_robust_stats = calculate_robust_statistics(data_items, num_features)
        
        if @verbose
          puts "📊 Robust statistics calculated:"
          feature_robust_stats.each_with_index do |stats, idx|
            next unless stats[:numeric]
            puts "  Feature #{idx}: median=#{stats[:median].round(3)}, IQR=#{stats[:iqr].round(3)}"
          end
        end
        
        # Apply robust scaling
        data_items.each do |item|
          normalized_item = item.map.with_index do |value, idx|
            stats = feature_robust_stats[idx]
            
            if stats[:numeric] && value.is_a?(Numeric)
              # Avoid division by zero
              if stats[:iqr] == 0
                0  # Set to 0 if no variation
              else
                (value - stats[:median]) / stats[:iqr]
              end
            else
              value  # Keep non-numeric values unchanged
            end
          end
          
          normalized_data << normalized_item
        end
        
        normalized_data
      end
      
      def unit_vector_normalize(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "📊 Applying unit vector normalization (L2 norm)..."
        end
        
        normalized_data = []
        
        data_items.each do |item|
          # Calculate L2 norm for numeric values only
          numeric_values = item.select { |v| v.is_a?(Numeric) }
          
          if numeric_values.empty?
            normalized_data << item
            next
          end
          
          l2_norm = Math.sqrt(numeric_values.sum { |v| v ** 2 })
          
          if l2_norm == 0
            normalized_data << item
            next
          end
          
          # Normalize only numeric values
          normalized_item = item.map do |value|
            if value.is_a?(Numeric)
              value / l2_norm
            else
              value
            end
          end
          
          normalized_data << normalized_item
        end
        
        normalized_data
      end
      
      def decimal_scaling_normalize(data_items)
        return data_items if data_items.empty?
        
        normalized_data = []
        num_features = data_items.first.length
        
        # Find the maximum absolute value for each feature
        max_abs_values = calculate_max_absolute_values(data_items, num_features)
        
        if @verbose
          puts "📊 Maximum absolute values calculated:"
          max_abs_values.each_with_index do |max_abs, idx|
            next unless max_abs[:numeric]
            scaling_factor = 10 ** Math.log10(max_abs[:value]).ceil
            puts "  Feature #{idx}: max_abs=#{max_abs[:value]}, scale=#{scaling_factor}"
          end
        end
        
        # Apply decimal scaling
        data_items.each do |item|
          normalized_item = item.map.with_index do |value, idx|
            max_abs_info = max_abs_values[idx]
            
            if max_abs_info[:numeric] && value.is_a?(Numeric)
              scaling_factor = 10 ** Math.log10(max_abs_info[:value]).ceil
              value.to_f / scaling_factor
            else
              value
            end
          end
          
          normalized_data << normalized_item
        end
        
        normalized_data
      end
      
      def calculate_feature_ranges(data_items, num_features)
        ranges = []
        
        num_features.times do |feature_idx|
          values = data_items.map { |item| item[feature_idx] }.compact
          numeric_values = values.select { |v| v.is_a?(Numeric) }
          
          if numeric_values.empty?
            ranges << { numeric: false }
          else
            ranges << {
              numeric: true,
              min: numeric_values.min,
              max: numeric_values.max,
              range: numeric_values.max - numeric_values.min
            }
          end
        end
        
        ranges
      end
      
      def calculate_feature_statistics(data_items, num_features)
        stats = []
        
        num_features.times do |feature_idx|
          values = data_items.map { |item| item[feature_idx] }.compact
          numeric_values = values.select { |v| v.is_a?(Numeric) }
          
          if numeric_values.empty?
            stats << { numeric: false }
          else
            mean = numeric_values.sum.to_f / numeric_values.length
            variance = numeric_values.sum { |v| (v - mean) ** 2 } / numeric_values.length
            std = Math.sqrt(variance)
            
            stats << {
              numeric: true,
              mean: mean,
              std: std,
              count: numeric_values.length
            }
          end
        end
        
        stats
      end
      
      def calculate_robust_statistics(data_items, num_features)
        stats = []
        
        num_features.times do |feature_idx|
          values = data_items.map { |item| item[feature_idx] }.compact
          numeric_values = values.select { |v| v.is_a?(Numeric) }.sort
          
          if numeric_values.empty?
            stats << { numeric: false }
          else
            n = numeric_values.length
            median = if n.odd?
              numeric_values[n / 2]
            else
              (numeric_values[n / 2 - 1] + numeric_values[n / 2]) / 2.0
            end
            
            q1_idx = (n * 0.25).floor
            q3_idx = (n * 0.75).floor
            q1 = numeric_values[q1_idx]
            q3 = numeric_values[q3_idx]
            iqr = q3 - q1
            
            stats << {
              numeric: true,
              median: median,
              q1: q1,
              q3: q3,
              iqr: iqr
            }
          end
        end
        
        stats
      end
      
      def calculate_max_absolute_values(data_items, num_features)
        max_abs = []
        
        num_features.times do |feature_idx|
          values = data_items.map { |item| item[feature_idx] }.compact
          numeric_values = values.select { |v| v.is_a?(Numeric) }
          
          if numeric_values.empty?
            max_abs << { numeric: false }
          else
            max_absolute = numeric_values.map(&:abs).max
            max_abs << {
              numeric: true,
              value: max_absolute
            }
          end
        end
        
        max_abs
      end
    end
  end
end