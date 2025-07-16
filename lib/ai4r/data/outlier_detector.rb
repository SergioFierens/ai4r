# frozen_string_literal: true

# Outlier detection with comprehensive educational explanations
# Author::    Claude (AI Assistant)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    # Educational outlier detector with multiple methods and detailed explanations
    class OutlierDetector
      def initialize(dataset, educational_config = {})
        @dataset = dataset
        @config = educational_config
        @verbose = educational_config.fetch(:verbose, false)
        @explain_operations = educational_config.fetch(:explain_operations, false)
      end

      # Detect outliers using specified method
      def detect(method = :iqr, threshold = 1.5)
        explain_outlier_method(method, threshold) if @explain_operations

        case method
        when :iqr
          iqr_method(threshold)
        when :z_score
          z_score_method(threshold)
        when :modified_z_score
          modified_z_score_method(threshold)
        when :isolation_forest
          isolation_forest_method(threshold)
        when :percentile
          percentile_method(threshold)
        when :tukey
          tukey_method(threshold)
        else
          raise ArgumentError, "Unknown outlier detection method: #{method}"
        end
      end

      # Explain different outlier detection methods
      def self.explain_method(method)
        explanations = {
          iqr: 'IQR (Interquartile Range) method identifies values beyond Q1-1.5*IQR or Q3+1.5*IQR. ' \
               'Robust to distribution shape, good for skewed data. Threshold typically 1.5-3.0.',

          z_score: 'Z-score method finds values more than N standard deviations from mean. ' \
                   'Assumes normal distribution. Threshold typically 2.0-3.0. Sensitive to extreme values.',

          modified_z_score: 'Uses median instead of mean: 0.6745*(x-median)/MAD. ' \
                            'More robust than z-score, less sensitive to extreme outliers. Threshold ~3.5.',

          isolation_forest: 'Tree-based method that isolates outliers in fewer splits. ' \
                            'Good for high-dimensional data and complex patterns. Threshold is contamination rate (0.0-0.5).',

          percentile: 'Simple method using percentile cutoffs (e.g., <5th or >95th percentile). ' \
                      'Easy to understand and implement. Threshold is percentile value (0.01-0.1).',

          tukey: 'Tukey\'s method using Q1-1.5*IQR and Q3+1.5*IQR boundaries. ' \
                 'Similar to IQR but with specific multiplier. Classic statistical approach.'
        }

        explanations[method] || 'Unknown outlier detection method'
      end

      # Comprehensive outlier analysis
      def comprehensive_analysis
        methods = %i[iqr z_score modified_z_score]
        thresholds = { iqr: 1.5, z_score: 3.0, modified_z_score: 3.5 }

        analysis = {
          methods_comparison: {},
          consensus_outliers: [],
          recommendations: []
        }

        if @verbose
          puts "\n🔍 Comprehensive Outlier Analysis"
          puts '=' * 50
        end

        # Run multiple methods
        methods.each do |method|
          threshold = thresholds[method]
          outliers = detect(method, threshold)

          analysis[:methods_comparison][method] = {
            outliers: outliers,
            total_outliers: outliers.values.sum { |info| info[:count] }
          }

          if @verbose
            total = analysis[:methods_comparison][method][:total_outliers]
            puts "#{method.to_s.upcase}: #{total} outliers detected"
          end
        end

        # Find consensus outliers (detected by multiple methods)
        analysis[:consensus_outliers] = find_consensus_outliers(analysis[:methods_comparison])

        # Generate recommendations
        analysis[:recommendations] = generate_outlier_recommendations(analysis)

        display_comprehensive_analysis(analysis) if @verbose

        analysis
      end

      private

      def explain_outlier_method(method, threshold)
        puts "\n🎯 Outlier Detection Method: #{method.to_s.humanize}"
        puts "Approach: #{self.class.explain_method(method)}"
        puts "Threshold: #{threshold}"

        show_method_warnings(method) if @config[:show_warnings]
      end

      def show_method_warnings(method)
        warnings = {
          iqr: '✅ Robust method, good general choice for most data types.',
          z_score: '⚠️  Assumes normal distribution. May not work well with skewed data.',
          modified_z_score: '✅ More robust than z-score, good for non-normal distributions.',
          isolation_forest: '⚠️  Complex method, may be overkill for simple datasets.',
          percentile: '⚠️  Arbitrary cutoffs, may not reflect true outliers.',
          tukey: '✅ Classic statistical method, well-established boundaries.'
        }

        puts warnings[method] if warnings[method]
      end

      def iqr_method(threshold = 1.5)
        outliers = {}

        @dataset.data_labels.each_with_index do |label, col_idx|
          column_outliers = detect_iqr_outliers(@dataset.data_items, col_idx, threshold)

          next unless column_outliers[:count] > 0

          outliers[label] = column_outliers

          if @verbose
            puts "Column '#{label}': #{column_outliers[:count]} outliers (#{column_outliers[:percentage]}%)"
            puts "  Boundaries: [#{column_outliers[:lower_bound].round(3)}, #{column_outliers[:upper_bound].round(3)}]"
          end
        end

        outliers
      end

      def z_score_method(threshold = 3.0)
        outliers = {}

        @dataset.data_labels.each_with_index do |label, col_idx|
          column_outliers = detect_z_score_outliers(@dataset.data_items, col_idx, threshold)

          next unless column_outliers[:count] > 0

          outliers[label] = column_outliers

          if @verbose
            puts "Column '#{label}': #{column_outliers[:count]} outliers (#{column_outliers[:percentage]}%)"
            puts "  Z-score boundaries: [#{-threshold}, #{threshold}]"
          end
        end

        outliers
      end

      def modified_z_score_method(threshold = 3.5)
        outliers = {}

        @dataset.data_labels.each_with_index do |label, col_idx|
          column_outliers = detect_modified_z_score_outliers(@dataset.data_items, col_idx, threshold)

          next unless column_outliers[:count] > 0

          outliers[label] = column_outliers

          if @verbose
            puts "Column '#{label}': #{column_outliers[:count]} outliers (#{column_outliers[:percentage]}%)"
            puts "  Modified Z-score threshold: #{threshold}"
          end
        end

        outliers
      end

      def isolation_forest_method(contamination = 0.1)
        # Simplified isolation forest - in production would use more sophisticated implementation
        outliers = {}

        puts "🌲 Applying simplified isolation forest (contamination=#{contamination})" if @verbose

        @dataset.data_labels.each_with_index do |label, col_idx|
          values = @dataset.data_items.filter_map { |row| row[col_idx] }
          numeric_values = values.select { |v| v.is_a?(Numeric) }

          next if numeric_values.length < 10 # Need minimum data points

          # Simplified approach: use percentile-based detection
          outlier_count = (numeric_values.length * contamination).round
          next if outlier_count == 0

          sorted_values = numeric_values.sort
          lower_cutoff = sorted_values[outlier_count / 2]
          upper_cutoff = sorted_values[(-outlier_count / 2) - 1]

          outlier_indices = []
          outlier_values = []

          @dataset.data_items.each_with_index do |row, row_idx|
            value = row[col_idx]
            if value.is_a?(Numeric) && (value <= lower_cutoff || value >= upper_cutoff)
              outlier_indices << row_idx
              outlier_values << value
            end
          end

          next unless outlier_indices.any?

          outliers[label] = {
            count: outlier_indices.length,
            percentage: (outlier_indices.length.to_f / @dataset.data_items.length * 100).round(2),
            indices: outlier_indices,
            values: outlier_values,
            lower_bound: lower_cutoff,
            upper_bound: upper_cutoff
          }
        end

        outliers
      end

      def percentile_method(percentile = 0.05)
        outliers = {}

        @dataset.data_labels.each_with_index do |label, col_idx|
          column_outliers = detect_percentile_outliers(@dataset.data_items, col_idx, percentile)

          next unless column_outliers[:count] > 0

          outliers[label] = column_outliers

          if @verbose
            puts "Column '#{label}': #{column_outliers[:count]} outliers (#{column_outliers[:percentage]}%)"
            puts "  Percentile boundaries: #{percentile * 100}% - #{(1 - percentile) * 100}%"
          end
        end

        outliers
      end

      def tukey_method(threshold = 1.5)
        # Tukey method is essentially the same as IQR with 1.5 multiplier
        iqr_method(threshold)
      end

      def detect_iqr_outliers(data_items, col_idx, threshold)
        values = data_items.filter_map { |row| row[col_idx] }
        numeric_values = values.select { |v| v.is_a?(Numeric) }.sort

        return { count: 0, percentage: 0.0 } if numeric_values.length < 4

        # Calculate quartiles
        n = numeric_values.length
        q1_idx = (n * 0.25).floor
        q3_idx = (n * 0.75).floor
        q1 = numeric_values[q1_idx]
        q3 = numeric_values[q3_idx]
        iqr = q3 - q1

        # Calculate bounds
        lower_bound = q1 - (threshold * iqr)
        upper_bound = q3 + (threshold * iqr)

        # Find outliers
        outlier_indices = []
        outlier_values = []

        data_items.each_with_index do |row, row_idx|
          value = row[col_idx]
          if value.is_a?(Numeric) && (value < lower_bound || value > upper_bound)
            outlier_indices << row_idx
            outlier_values << value
          end
        end

        {
          count: outlier_indices.length,
          percentage: (outlier_indices.length.to_f / data_items.length * 100).round(2),
          indices: outlier_indices,
          values: outlier_values,
          lower_bound: lower_bound,
          upper_bound: upper_bound,
          q1: q1,
          q3: q3,
          iqr: iqr
        }
      end

      def detect_z_score_outliers(data_items, col_idx, threshold)
        values = data_items.filter_map { |row| row[col_idx] }
        numeric_values = values.select { |v| v.is_a?(Numeric) }

        return { count: 0, percentage: 0.0 } if numeric_values.length < 3

        # Calculate mean and standard deviation
        mean = numeric_values.sum.to_f / numeric_values.length
        variance = numeric_values.sum { |v| (v - mean)**2 } / numeric_values.length
        std = Math.sqrt(variance)

        return { count: 0, percentage: 0.0 } if std == 0

        # Find outliers
        outlier_indices = []
        outlier_values = []
        z_scores = []

        data_items.each_with_index do |row, row_idx|
          value = row[col_idx]
          next unless value.is_a?(Numeric)

          z_score = (value - mean) / std
          next unless z_score.abs > threshold

          outlier_indices << row_idx
          outlier_values << value
          z_scores << z_score
        end

        {
          count: outlier_indices.length,
          percentage: (outlier_indices.length.to_f / data_items.length * 100).round(2),
          indices: outlier_indices,
          values: outlier_values,
          z_scores: z_scores,
          mean: mean,
          std: std,
          threshold: threshold
        }
      end

      def detect_modified_z_score_outliers(data_items, col_idx, threshold)
        values = data_items.filter_map { |row| row[col_idx] }
        numeric_values = values.select { |v| v.is_a?(Numeric) }.sort

        return { count: 0, percentage: 0.0 } if numeric_values.length < 3

        # Calculate median
        n = numeric_values.length
        median = if n.odd?
                   numeric_values[n / 2]
                 else
                   (numeric_values[(n / 2) - 1] + numeric_values[n / 2]) / 2.0
                 end

        # Calculate MAD (Median Absolute Deviation)
        deviations = numeric_values.map { |v| (v - median).abs }
        mad = deviations.sort[deviations.length / 2]

        return { count: 0, percentage: 0.0 } if mad == 0

        # Find outliers using modified z-score
        outlier_indices = []
        outlier_values = []
        modified_z_scores = []

        data_items.each_with_index do |row, row_idx|
          value = row[col_idx]
          next unless value.is_a?(Numeric)

          modified_z_score = 0.6745 * (value - median) / mad
          next unless modified_z_score.abs > threshold

          outlier_indices << row_idx
          outlier_values << value
          modified_z_scores << modified_z_score
        end

        {
          count: outlier_indices.length,
          percentage: (outlier_indices.length.to_f / data_items.length * 100).round(2),
          indices: outlier_indices,
          values: outlier_values,
          modified_z_scores: modified_z_scores,
          median: median,
          mad: mad,
          threshold: threshold
        }
      end

      def detect_percentile_outliers(data_items, col_idx, percentile)
        values = data_items.filter_map { |row| row[col_idx] }
        numeric_values = values.select { |v| v.is_a?(Numeric) }.sort

        return { count: 0, percentage: 0.0 } if numeric_values.length < 10

        # Calculate percentile bounds
        lower_idx = (numeric_values.length * percentile).floor
        upper_idx = (numeric_values.length * (1 - percentile)).ceil - 1

        lower_bound = numeric_values[lower_idx]
        upper_bound = numeric_values[upper_idx]

        # Find outliers
        outlier_indices = []
        outlier_values = []

        data_items.each_with_index do |row, row_idx|
          value = row[col_idx]
          if value.is_a?(Numeric) && (value <= lower_bound || value >= upper_bound)
            outlier_indices << row_idx
            outlier_values << value
          end
        end

        {
          count: outlier_indices.length,
          percentage: (outlier_indices.length.to_f / data_items.length * 100).round(2),
          indices: outlier_indices,
          values: outlier_values,
          lower_bound: lower_bound,
          upper_bound: upper_bound,
          percentile: percentile
        }
      end

      def find_consensus_outliers(methods_comparison)
        # Find outliers detected by multiple methods
        all_outlier_indices = {}

        methods_comparison.each do |method, results|
          results[:outliers].each do |column, outlier_info|
            all_outlier_indices[column] ||= {}

            outlier_info[:indices].each do |idx|
              all_outlier_indices[column][idx] ||= []
              all_outlier_indices[column][idx] << method
            end
          end
        end

        # Find indices detected by multiple methods
        consensus = {}
        all_outlier_indices.each do |column, indices|
          consensus_indices = indices.select { |_idx, methods| methods.length > 1 }

          next unless consensus_indices.any?

          consensus[column] = {
            indices: consensus_indices.keys,
            method_counts: consensus_indices.transform_values(&:length)
          }
        end

        consensus
      end

      def generate_outlier_recommendations(analysis)
        recommendations = []

        total_outliers = analysis[:methods_comparison].values.sum { |info| info[:total_outliers] }

        recommendations << if total_outliers == 0
                             'No outliers detected. Data appears to be well-behaved.'
                           elsif total_outliers < @dataset.data_items.length * 0.05
                             'Low outlier rate (<5%). Investigate individual cases for data quality issues.'
                           elsif total_outliers < @dataset.data_items.length * 0.1
                             'Moderate outlier rate (5-10%). Consider robust preprocessing methods.'
                           else
                             'High outlier rate (>10%). Investigate data collection process and consider domain expertise.'
                           end

        # Method-specific recommendations
        method_results = analysis[:methods_comparison]
        if method_results.length > 1
          outlier_counts = method_results.transform_values { |info| info[:total_outliers] }
          max_method = outlier_counts.max_by { |_method, count| count }&.first
          min_method = outlier_counts.min_by { |_method, count| count }&.first

          if outlier_counts[max_method] > outlier_counts[min_method] * 3
            recommendations << "Large variation between methods. #{max_method} detected #{outlier_counts[max_method]} vs #{min_method} detected #{outlier_counts[min_method]}. Consider data distribution."
          end
        end

        # Consensus recommendations
        if analysis[:consensus_outliers].any?
          consensus_count = analysis[:consensus_outliers].values.sum { |info| info[:indices].length }
          recommendations << "#{consensus_count} outliers detected by multiple methods. These are strong candidates for investigation."
        end

        recommendations
      end

      def display_comprehensive_analysis(analysis)
        puts "\n📊 Method Comparison:"
        analysis[:methods_comparison].each do |method, info|
          puts "  #{method.to_s.upcase}: #{info[:total_outliers]} outliers"
        end

        if analysis[:consensus_outliers].any?
          puts "\n🎯 Consensus Outliers (detected by multiple methods):"
          analysis[:consensus_outliers].each do |column, info|
            puts "  #{column}: #{info[:indices].length} outliers"
          end
        end

        if analysis[:recommendations].any?
          puts "\n💡 Recommendations:"
          analysis[:recommendations].each { |rec| puts "  • #{rec}" }
        end
      end
    end
  end
end
