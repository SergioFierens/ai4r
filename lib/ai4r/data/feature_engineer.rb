# frozen_string_literal: true

# Feature engineering utilities with educational guidance
# Author::    Claude (AI Assistant)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    
    # Educational feature engineering with comprehensive techniques and explanations
    class FeatureEngineer
      
      def initialize(dataset, educational_config = {})
        @dataset = dataset
        @config = educational_config
        @verbose = educational_config.fetch(:verbose, false)
        @explain_operations = educational_config.fetch(:explain_operations, false)
      end
      
      # Apply feature engineering techniques
      def apply_techniques(data_items, techniques = [:polynomial])
        explain_feature_engineering if @explain_operations
        
        engineered_data = data_items.dup
        original_feature_count = data_items.first&.length || 0
        
        techniques.each do |technique|
          case technique
          when :polynomial
            engineered_data = add_polynomial_features(engineered_data)
          when :interaction
            engineered_data = add_interaction_features(engineered_data)
          when :binning
            engineered_data = add_binned_features(engineered_data)
          when :log_transform
            engineered_data = add_log_features(engineered_data)
          when :square_root
            engineered_data = add_sqrt_features(engineered_data)
          when :reciprocal
            engineered_data = add_reciprocal_features(engineered_data)
          when :exponential
            engineered_data = add_exponential_features(engineered_data)
          when :trigonometric
            engineered_data = add_trigonometric_features(engineered_data)
          else
            puts "⚠️  Unknown technique: #{technique}" if @verbose
          end
        end
        
        new_feature_count = engineered_data.first&.length || 0
        
        if @verbose
          puts "✨ Feature engineering complete!"
          puts "   Original features: #{original_feature_count}"
          puts "   New features: #{new_feature_count}"
          puts "   Added: #{new_feature_count - original_feature_count} features"
        end
        
        engineered_data
      end
      
      # Analyze feature importance and suggest engineering techniques
      def suggest_techniques(feature_analysis, target_column = nil)
        suggestions = []
        
        # Analyze each feature type
        feature_analysis.each do |feature, analysis|
          case analysis[:type]
          when :numeric
            suggestions.concat(suggest_numeric_techniques(feature, analysis))
          when :categorical
            suggestions.concat(suggest_categorical_techniques(feature, analysis))
          when :datetime
            suggestions.concat(suggest_datetime_techniques(feature, analysis))
          when :text
            suggestions.concat(suggest_text_techniques(feature, analysis))
          end
        end
        
        # Target-specific suggestions
        if target_column
          suggestions.concat(suggest_target_based_techniques(feature_analysis, target_column))
        end
        
        # Remove duplicates and prioritize
        suggestions.uniq! { |s| s[:name] }
        suggestions.sort_by! { |s| -s[:priority] }
        
        if @verbose
          display_technique_suggestions(suggestions)
        end
        
        suggestions
      end
      
      # Automatic feature selection based on importance
      def select_important_features(data_items, target_column, method = :correlation)
        explain_feature_selection(method) if @explain_operations
        
        case method
        when :correlation
          correlation_based_selection(data_items, target_column)
        when :variance
          variance_based_selection(data_items)
        when :mutual_information
          mutual_information_selection(data_items, target_column)
        when :univariate
          univariate_selection(data_items, target_column)
        else
          raise ArgumentError, "Unknown feature selection method: #{method}"
        end
      end
      
      private
      
      def explain_feature_engineering
        puts "\n⚗️  Feature Engineering Concepts:"
        puts "• Feature engineering creates new variables from existing data"
        puts "• Goal: Improve model performance and capture domain knowledge"
        puts "• Common techniques: polynomial, interactions, transformations"
        puts "• Balance: More features vs. overfitting risk"
        puts "• Always validate that new features add predictive value"
      end
      
      def explain_feature_selection(method)
        explanations = {
          correlation: "Selects features based on correlation with target variable. Good for linear relationships.",
          variance: "Removes features with low variance (little information). Good preprocessing step.",
          mutual_information: "Measures dependency between features and target. Captures non-linear relationships.",
          univariate: "Tests each feature individually against target. Fast but ignores feature interactions."
        }
        
        puts "\n🎯 Feature Selection Method: #{method.to_s.humanize}"
        puts "Approach: #{explanations[method]}"
      end
      
      def add_polynomial_features(data_items, degree = 2)
        return data_items if data_items.empty?
        
        if @verbose
          puts "🔢 Adding polynomial features (degree #{degree})"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          numeric_indices = find_numeric_feature_indices(item)
          
          # Add squared terms
          if degree >= 2
            numeric_indices.each do |idx|
              value = item[idx]
              if value.is_a?(Numeric)
                new_item << value ** 2
              end
            end
          end
          
          # Add cubic terms
          if degree >= 3
            numeric_indices.each do |idx|
              value = item[idx]
              if value.is_a?(Numeric)
                new_item << value ** 3
              end
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_interaction_features(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "🤝 Adding interaction features"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          numeric_indices = find_numeric_feature_indices(item)
          
          # Add pairwise interactions
          numeric_indices.combination(2).each do |idx1, idx2|
            val1 = item[idx1]
            val2 = item[idx2]
            
            if val1.is_a?(Numeric) && val2.is_a?(Numeric)
              new_item << val1 * val2
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_binned_features(data_items, bins = 5)
        return data_items if data_items.empty?
        
        if @verbose
          puts "🗂️  Adding binned features (#{bins} bins)"
        end
        
        # Calculate bin boundaries for each numeric feature
        bin_boundaries = calculate_bin_boundaries(data_items, bins)
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          
          bin_boundaries.each_with_index do |(feature_idx, boundaries), _|
            value = item[feature_idx]
            if value.is_a?(Numeric)
              bin_index = assign_to_bin(value, boundaries)
              new_item << bin_index
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_log_features(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "📈 Adding logarithmic features"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          
          item.each_with_index do |value, idx|
            if value.is_a?(Numeric) && value > 0
              new_item << Math.log(value)
            elsif value.is_a?(Numeric) && value <= 0
              # Handle non-positive values with log(x + 1)
              new_item << Math.log(value + 1) if value >= -1
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_sqrt_features(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "√ Adding square root features"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          
          item.each_with_index do |value, idx|
            if value.is_a?(Numeric) && value >= 0
              new_item << Math.sqrt(value)
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_reciprocal_features(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "🔄 Adding reciprocal features (1/x)"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          
          item.each_with_index do |value, idx|
            if value.is_a?(Numeric) && value != 0
              new_item << 1.0 / value
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_exponential_features(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "📊 Adding exponential features"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          
          item.each_with_index do |value, idx|
            if value.is_a?(Numeric) && value.abs < 10  # Prevent overflow
              new_item << Math.exp(value)
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def add_trigonometric_features(data_items)
        return data_items if data_items.empty?
        
        if @verbose
          puts "〰️ Adding trigonometric features (sin, cos)"
        end
        
        engineered_data = []
        
        data_items.each do |item|
          new_item = item.dup
          
          item.each_with_index do |value, idx|
            if value.is_a?(Numeric)
              new_item << Math.sin(value)
              new_item << Math.cos(value)
            end
          end
          
          engineered_data << new_item
        end
        
        engineered_data
      end
      
      def find_numeric_feature_indices(item)
        indices = []
        item.each_with_index do |value, idx|
          indices << idx if value.is_a?(Numeric)
        end
        indices
      end
      
      def calculate_bin_boundaries(data_items, bins)
        boundaries = {}
        num_features = data_items.first.length
        
        num_features.times do |feature_idx|
          values = data_items.map { |row| row[feature_idx] }.compact
          numeric_values = values.select { |v| v.is_a?(Numeric) }.sort
          
          next if numeric_values.empty?
          
          min_val = numeric_values.first
          max_val = numeric_values.last
          
          if min_val == max_val
            boundaries[feature_idx] = [min_val]
          else
            step = (max_val - min_val).to_f / bins
            bin_edges = (0..bins).map { |i| min_val + i * step }
            boundaries[feature_idx] = bin_edges
          end
        end
        
        boundaries
      end
      
      def assign_to_bin(value, boundaries)
        return 0 if boundaries.length <= 1
        
        # Find which bin the value belongs to
        (0...boundaries.length - 1).each do |i|
          if value >= boundaries[i] && value <= boundaries[i + 1]
            return i
          end
        end
        
        # Handle edge case where value is greater than max
        boundaries.length - 2
      end
      
      def suggest_numeric_techniques(feature, analysis)
        suggestions = []
        
        # Check distribution characteristics
        if analysis[:skewness] && analysis[:skewness].abs > 1.0
          suggestions << {
            name: "Log transformation for #{feature}",
            description: "High skewness detected. Log transform can normalize distribution.",
            benefit: "Reduces skewness, improves model performance",
            priority: 3
          }
        end
        
        # Check for potential polynomial relationships
        if analysis[:range] && analysis[:range] > 0
          suggestions << {
            name: "Polynomial features for #{feature}",
            description: "Create squared and cubic terms to capture non-linear patterns.",
            benefit: "Captures non-linear relationships",
            priority: 2
          }
        end
        
        # Suggest binning for continuous variables
        suggestions << {
          name: "Binning for #{feature}",
          description: "Convert continuous variable to categorical bins.",
          benefit: "Handles non-linear relationships, reduces noise",
          priority: 1
        }
        
        suggestions
      end
      
      def suggest_categorical_techniques(feature, analysis)
        suggestions = []
        
        # High cardinality categorical variables
        if analysis[:unique_count] && analysis[:unique_count] > 10
          suggestions << {
            name: "Encoding for #{feature}",
            description: "High cardinality categorical variable needs encoding.",
            benefit: "Reduces dimensionality, handles rare categories",
            priority: 3
          }
        end
        
        # Interaction with other categorical variables
        suggestions << {
          name: "Category interactions for #{feature}",
          description: "Create interaction features with other categorical variables.",
          benefit: "Captures category combinations",
          priority: 2
        }
        
        suggestions
      end
      
      def suggest_datetime_techniques(feature, analysis)
        suggestions = []
        
        suggestions << {
          name: "DateTime decomposition for #{feature}",
          description: "Extract year, month, day, hour, weekday, etc.",
          benefit: "Captures temporal patterns and seasonality",
          priority: 4
        }
        
        suggestions << {
          name: "Time-based features for #{feature}",
          description: "Create rolling averages, lags, time since events.",
          benefit: "Captures temporal dependencies",
          priority: 3
        }
        
        suggestions
      end
      
      def suggest_text_techniques(feature, analysis)
        suggestions = []
        
        suggestions << {
          name: "Text length features for #{feature}",
          description: "Extract character count, word count, sentence count.",
          benefit: "Simple numeric features from text",
          priority: 2
        }
        
        suggestions << {
          name: "Text encoding for #{feature}",
          description: "Apply TF-IDF, word embeddings, or bag-of-words.",
          benefit: "Converts text to numeric features",
          priority: 4
        }
        
        suggestions
      end
      
      def suggest_target_based_techniques(feature_analysis, target_column)
        suggestions = []
        
        # Suggest interaction features based on target correlation
        high_correlation_features = feature_analysis.select do |feature, analysis|
          analysis[:target_correlation] && analysis[:target_correlation].abs > 0.3
        end
        
        if high_correlation_features.length > 1
          suggestions << {
            name: "High-correlation feature interactions",
            description: "Create interactions between features highly correlated with target.",
            benefit: "Captures synergistic effects",
            priority: 4
          }
        end
        
        # Suggest ratio features
        numeric_features = feature_analysis.select { |f, a| a[:type] == :numeric }
        if numeric_features.length > 1
          suggestions << {
            name: "Ratio features",
            description: "Create ratios between numeric features.",
            benefit: "Captures relative relationships",
            priority: 2
          }
        end
        
        suggestions
      end
      
      def display_technique_suggestions(suggestions)
        puts "\n💡 Feature Engineering Suggestions"
        puts "=" * 50
        
        suggestions.each_with_index do |suggestion, idx|
          priority_stars = "⭐" * suggestion[:priority]
          puts "\n#{idx + 1}. #{suggestion[:name]} #{priority_stars}"
          puts "   Description: #{suggestion[:description]}"
          puts "   Benefit: #{suggestion[:benefit]}"
        end
      end
      
      def correlation_based_selection(data_items, target_column)
        return data_items if data_items.empty?
        
        target_idx = @dataset.get_index(target_column)
        correlations = []
        
        data_items.first.length.times do |feature_idx|
          next if feature_idx == target_idx
          
          correlation = calculate_correlation(data_items, feature_idx, target_idx)
          correlations << { index: feature_idx, correlation: correlation.abs }
        end
        
        # Sort by correlation strength
        correlations.sort_by! { |c| -c[:correlation] }
        
        if @verbose
          puts "\n🎯 Feature Selection by Correlation:"
          correlations.first(10).each do |c|
            puts "  Feature #{c[:index]}: r = #{c[:correlation].round(4)}"
          end
        end
        
        correlations
      end
      
      def variance_based_selection(data_items)
        return [] if data_items.empty?
        
        variances = []
        
        data_items.first.length.times do |feature_idx|
          values = data_items.map { |row| row[feature_idx] }.compact
          numeric_values = values.select { |v| v.is_a?(Numeric) }
          
          if numeric_values.length > 1
            mean = numeric_values.sum.to_f / numeric_values.length
            variance = numeric_values.sum { |v| (v - mean) ** 2 } / (numeric_values.length - 1)
            variances << { index: feature_idx, variance: variance }
          end
        end
        
        # Sort by variance (higher is better)
        variances.sort_by! { |v| -v[:variance] }
        
        if @verbose
          puts "\n📊 Feature Selection by Variance:"
          variances.first(10).each do |v|
            puts "  Feature #{v[:index]}: variance = #{v[:variance].round(4)}"
          end
        end
        
        variances
      end
      
      def mutual_information_selection(data_items, target_column)
        # Simplified mutual information calculation
        # In production, would use more sophisticated algorithms
        
        target_idx = @dataset.get_index(target_column)
        mi_scores = []
        
        data_items.first.length.times do |feature_idx|
          next if feature_idx == target_idx
          
          mi_score = calculate_mutual_information(data_items, feature_idx, target_idx)
          mi_scores << { index: feature_idx, mi_score: mi_score }
        end
        
        # Sort by mutual information (higher is better)
        mi_scores.sort_by! { |mi| -mi[:mi_score] }
        
        if @verbose
          puts "\n🔗 Feature Selection by Mutual Information:"
          mi_scores.first(10).each do |mi|
            puts "  Feature #{mi[:index]}: MI = #{mi[:mi_score].round(4)}"
          end
        end
        
        mi_scores
      end
      
      def univariate_selection(data_items, target_column)
        # Simple univariate selection using correlation
        correlation_based_selection(data_items, target_column)
      end
      
      def calculate_correlation(data_items, feature_idx, target_idx)
        feature_values = []
        target_values = []
        
        data_items.each do |row|
          f_val = row[feature_idx]
          t_val = row[target_idx]
          
          if f_val.is_a?(Numeric) && t_val.is_a?(Numeric)
            feature_values << f_val
            target_values << t_val
          end
        end
        
        return 0.0 if feature_values.length < 2
        
        # Calculate Pearson correlation
        n = feature_values.length
        sum_f = feature_values.sum
        sum_t = target_values.sum
        sum_f2 = feature_values.sum { |v| v ** 2 }
        sum_t2 = target_values.sum { |v| v ** 2 }
        sum_ft = feature_values.zip(target_values).sum { |f, t| f * t }
        
        numerator = n * sum_ft - sum_f * sum_t
        denominator = Math.sqrt((n * sum_f2 - sum_f ** 2) * (n * sum_t2 - sum_t ** 2))
        
        return 0.0 if denominator == 0
        
        numerator / denominator
      end
      
      def calculate_mutual_information(data_items, feature_idx, target_idx)
        # Simplified mutual information using discretized values
        # In production, would use more sophisticated entropy calculations
        
        feature_values = data_items.map { |row| row[feature_idx] }.compact
        target_values = data_items.map { |row| row[target_idx] }.compact
        
        return 0.0 if feature_values.empty? || target_values.empty?
        
        # Discretize numeric values into bins
        feature_bins = discretize_values(feature_values)
        target_bins = discretize_values(target_values)
        
        # Calculate joint frequency table
        joint_freq = {}
        feature_bins.zip(target_bins).each do |f, t|
          joint_freq[[f, t]] ||= 0
          joint_freq[[f, t]] += 1
        end
        
        # Calculate marginal frequencies
        feature_freq = feature_bins.group_by(&:itself).transform_values(&:length)
        target_freq = target_bins.group_by(&:itself).transform_values(&:length)
        
        # Calculate mutual information
        n = feature_bins.length.to_f
        mi = 0.0
        
        joint_freq.each do |(f, t), count|
          p_ft = count / n
          p_f = feature_freq[f] / n
          p_t = target_freq[t] / n
          
          if p_ft > 0 && p_f > 0 && p_t > 0
            mi += p_ft * Math.log2(p_ft / (p_f * p_t))
          end
        end
        
        mi
      end
      
      def discretize_values(values, bins = 5)
        return values unless values.first.is_a?(Numeric)
        
        numeric_values = values.select { |v| v.is_a?(Numeric) }
        return values if numeric_values.empty?
        
        min_val = numeric_values.min
        max_val = numeric_values.max
        
        return [0] * values.length if min_val == max_val
        
        step = (max_val - min_val).to_f / bins
        
        values.map do |value|
          if value.is_a?(Numeric)
            bin = ((value - min_val) / step).floor
            bin = bins - 1 if bin >= bins
            bin
          else
            value
          end
        end
      end
    end
  end
end