# frozen_string_literal: true

# Data visualization and analysis tools for educational purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    
    # ASCII-based data visualization for educational purposes
    class DataVisualizer
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def visualize(column, chart_type)
        case chart_type
        when :histogram
          histogram(column)
        when :box_plot
          box_plot(column)
        when :scatter
          scatter_plot(column)
        when :bar_chart
          bar_chart(column)
        when :correlation_heatmap
          correlation_heatmap
        else
          raise ArgumentError, "Unknown chart type: #{chart_type}"
        end
      end
      
      private
      
      def histogram(column)
        values = get_numeric_values(column)
        return puts "No numeric data found for #{column}" if values.empty?
        
        bins = 20
        min_val, max_val = values.minmax
        return puts "Cannot create histogram: all values are the same" if min_val == max_val
        
        bin_width = (max_val - min_val).to_f / bins
        counts = Array.new(bins, 0)
        
        values.each do |val|
          bin_index = [(val - min_val) / bin_width, bins - 1].min.to_i
          counts[bin_index] += 1
        end
        
        max_count = counts.max
        
        puts "\n=== Histogram: #{column} ==="
        puts "Range: [#{min_val.round(2)}, #{max_val.round(2)}]"
        puts "Total values: #{values.length}"
        puts
        
        counts.each_with_index do |count, i|
          bin_start = min_val + i * bin_width
          bin_end = bin_start + bin_width
          bar_length = max_count > 0 ? (count * 40 / max_count).to_i : 0
          bar = "█" * bar_length
          
          puts sprintf("%6.2f-%6.2f |%s %d", bin_start, bin_end, bar.ljust(40), count)
        end
      end
      
      def box_plot(column)
        values = get_numeric_values(column).sort
        return puts "No numeric data found for #{column}" if values.empty?
        
        n = values.length
        q1 = values[n / 4]
        median = values[n / 2]
        q3 = values[3 * n / 4]
        min_val = values.first
        max_val = values.last
        
        iqr = q3 - q1
        lower_fence = q1 - 1.5 * iqr
        upper_fence = q3 + 1.5 * iqr
        
        outliers = values.select { |v| v < lower_fence || v > upper_fence }
        
        puts "\n=== Box Plot: #{column} ==="
        puts "Min: #{min_val.round(2)}"
        puts "Q1:  #{q1.round(2)}"
        puts "Med: #{median.round(2)}"
        puts "Q3:  #{q3.round(2)}"
        puts "Max: #{max_val.round(2)}"
        puts "IQR: #{iqr.round(2)}"
        puts "Outliers: #{outliers.length}"
        
        # ASCII box plot
        range = max_val - min_val
        if range > 0
          puts "\nVisualization:"
          scale = 50.0 / range
          
          min_pos = 0
          q1_pos = ((q1 - min_val) * scale).to_i
          med_pos = ((median - min_val) * scale).to_i
          q3_pos = ((q3 - min_val) * scale).to_i
          max_pos = 50
          
          line = " " * 51
          line[min_pos] = "|"
          line[q1_pos] = "["
          line[med_pos] = "|"
          line[q3_pos] = "]"
          line[max_pos] = "|"
          
          # Fill the box
          (q1_pos + 1...q3_pos).each { |i| line[i] = "─" if line[i] == " " }
          
          puts line
          puts sprintf("%-8.2f %40s %8.2f", min_val, "", max_val)
        end
      end
      
      def scatter_plot(columns)
        if columns.is_a?(String) || columns.is_a?(Symbol)
          # Auto-select second column for scatter plot
          numeric_columns = get_numeric_column_names
          return puts "Need at least 2 numeric columns for scatter plot" if numeric_columns.length < 2
          
          col1 = columns
          col2 = numeric_columns.find { |c| c != col1 } || numeric_columns[1]
          columns = [col1, col2]
        end
        
        return puts "Need exactly 2 columns for scatter plot" unless columns.length == 2
        
        col1, col2 = columns
        values1 = get_numeric_values(col1)
        values2 = get_numeric_values(col2)
        
        return puts "Insufficient data for scatter plot" if values1.length != values2.length || values1.empty?
        
        puts "\n=== Scatter Plot: #{col1} vs #{col2} ==="
        
        min1, max1 = values1.minmax
        min2, max2 = values2.minmax
        
        return puts "Cannot create plot: no variation in data" if min1 == max1 || min2 == max2
        
        width, height = 50, 20
        grid = Array.new(height) { Array.new(width, " ") }
        
        values1.zip(values2).each do |v1, v2|
          x = ((v1 - min1) * (width - 1) / (max1 - min1)).to_i
          y = height - 1 - ((v2 - min2) * (height - 1) / (max2 - min2)).to_i
          grid[y][x] = "*"
        end
        
        grid.each_with_index do |row, i|
          y_value = max2 - i * (max2 - min2) / (height - 1)
          puts sprintf("%8.2f |%s", y_value, row.join(""))
        end
        
        puts "         " + "-" * width
        puts sprintf("         %-8.2f %30s %8.2f", min1, col1, max1)
        
        # Calculate correlation
        correlation = calculate_correlation(values1, values2)
        puts "\nCorrelation: #{correlation.round(3)}"
      end
      
      def bar_chart(column)
        values = get_column_values(column)
        value_counts = values.group_by(&:itself).transform_values(&:length)
        
        puts "\n=== Bar Chart: #{column} ==="
        puts "Total values: #{values.length}"
        puts "Unique values: #{value_counts.length}"
        puts
        
        max_count = value_counts.values.max
        max_label_length = value_counts.keys.map(&:to_s).map(&:length).max
        
        value_counts.sort_by { |_, count| -count }.each do |value, count|
          bar_length = max_count > 0 ? (count * 30 / max_count).to_i : 0
          bar = "█" * bar_length
          percentage = (count * 100.0 / values.length).round(1)
          
          puts sprintf("%-#{max_label_length}s |%s %d (%.1f%%)", 
                      value.to_s, bar.ljust(30), count, percentage)
        end
      end
      
      def correlation_heatmap
        numeric_columns = get_numeric_column_names
        return puts "Need at least 2 numeric columns for correlation heatmap" if numeric_columns.length < 2
        
        puts "\n=== Correlation Heatmap ==="
        puts
        
        correlations = {}
        numeric_columns.each do |col1|
          correlations[col1] = {}
          numeric_columns.each do |col2|
            values1 = get_numeric_values(col1)
            values2 = get_numeric_values(col2)
            correlations[col1][col2] = calculate_correlation(values1, values2)
          end
        end
        
        # Print column headers
        print sprintf("%12s", "")
        numeric_columns.each { |col| print sprintf("%8s", col[0..6]) }
        puts
        
        # Print correlation matrix
        numeric_columns.each do |row_col|
          print sprintf("%12s", row_col[0..10])
          numeric_columns.each do |col_col|
            corr = correlations[row_col][col_col]
            color_char = correlation_to_char(corr)
            print sprintf("%8s", "#{corr.round(2)}#{color_char}")
          end
          puts
        end
        
        puts "\nLegend: Strong (+) = ▓, Moderate (±) = ▒, Weak (.) = ░, None (0) = ·"
      end
      
      def correlation_to_char(correlation)
        abs_corr = correlation.abs
        case abs_corr
        when 0.8..1.0 then "▓"
        when 0.5..0.8 then "▒"
        when 0.2..0.5 then "░"
        else "·"
        end
      end
      
      def calculate_correlation(values1, values2)
        return 0.0 if values1.length != values2.length || values1.empty?
        
        n = values1.length
        mean1 = values1.sum.to_f / n
        mean2 = values2.sum.to_f / n
        
        numerator = values1.zip(values2).sum { |v1, v2| (v1 - mean1) * (v2 - mean2) }
        
        sum_sq1 = values1.sum { |v| (v - mean1) ** 2 }
        sum_sq2 = values2.sum { |v| (v - mean2) ** 2 }
        
        denominator = Math.sqrt(sum_sq1 * sum_sq2)
        
        denominator == 0 ? 0.0 : numerator / denominator
      end
      
      def get_numeric_values(column)
        column_index = @dataset.get_index(column)
        @dataset.data_items.map { |row| row[column_index] }.select { |val| val.is_a?(Numeric) }
      end
      
      def get_column_values(column)
        column_index = @dataset.get_index(column)
        @dataset.data_items.map { |row| row[column_index] }.compact
      end
      
      def get_numeric_column_names
        @dataset.data_labels.select.with_index do |label, index|
          values = @dataset.data_items.map { |row| row[index] }
          values.any? { |val| val.is_a?(Numeric) }
        end
      end
    end
    
    # Correlation analysis tools
    class CorrelationAnalyzer
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def calculate_correlations
        numeric_columns = get_numeric_columns
        return {} if numeric_columns.length < 2
        
        correlations = {}
        
        numeric_columns.combination(2).each do |col1, col2|
          values1 = @dataset.data_items.map { |row| row[col1[:index]] }.select { |v| v.is_a?(Numeric) }
          values2 = @dataset.data_items.map { |row| row[col2[:index]] }.select { |v| v.is_a?(Numeric) }
          
          if values1.length == values2.length && values1.length > 1
            correlation = calculate_correlation(values1, values2)
            correlations["#{col1[:name]}_#{col2[:name]}"] = {
              columns: [col1[:name], col2[:name]],
              correlation: correlation,
              strength: interpret_correlation(correlation),
              significance: correlation.abs > 0.3 ? "significant" : "weak"
            }
          end
        end
        
        if @config[:verbose]
          puts "\n=== Correlation Analysis ==="
          correlations.each do |pair, data|
            puts "#{data[:columns].join(' vs ')}: #{data[:correlation].round(3)} (#{data[:strength]})"
          end
        end
        
        correlations
      end
      
      private
      
      def get_numeric_columns
        columns = []
        @dataset.data_labels.each_with_index do |label, index|
          values = @dataset.data_items.map { |row| row[index] }
          if values.any? { |val| val.is_a?(Numeric) }
            columns << { name: label, index: index }
          end
        end
        columns
      end
      
      def calculate_correlation(values1, values2)
        return 0.0 if values1.length != values2.length || values1.empty?
        
        n = values1.length
        mean1 = values1.sum.to_f / n
        mean2 = values2.sum.to_f / n
        
        numerator = values1.zip(values2).sum { |v1, v2| (v1 - mean1) * (v2 - mean2) }
        
        sum_sq1 = values1.sum { |v| (v - mean1) ** 2 }
        sum_sq2 = values2.sum { |v| (v - mean2) ** 2 }
        
        denominator = Math.sqrt(sum_sq1 * sum_sq2)
        
        denominator == 0 ? 0.0 : numerator / denominator
      end
      
      def interpret_correlation(correlation)
        abs_corr = correlation.abs
        case abs_corr
        when 0.0...0.1 then "negligible"
        when 0.1...0.3 then "weak"
        when 0.3...0.5 then "moderate"
        when 0.5...0.7 then "strong"
        when 0.7...0.9 then "very strong"
        when 0.9..1.0 then "near perfect"
        else "perfect"
        end
      end
    end
    
    # Distance metrics comparison for educational purposes
    class DistanceComparator
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def compare(sample_size)
        numeric_data = get_numeric_data
        return puts "No numeric data available for distance comparison" if numeric_data.length < 2
        
        sample_data = numeric_data.sample(sample_size)
        
        puts "\n=== Distance Metrics Comparison ==="
        puts "Comparing #{sample_data.length} data points"
        puts
        
        distance_methods = [
          [:euclidean_distance, "Euclidean"],
          [:manhattan_distance, "Manhattan"],
          [:sup_distance, "Chebyshev"],
          [:cosine_distance, "Cosine"]
        ]
        
        # Calculate pairwise distances for first few samples
        sample_pairs = sample_data.combination(2).first(10)
        
        puts sprintf("%-15s %-12s %-12s %-12s %-12s", 
                    "Pair", "Euclidean", "Manhattan", "Chebyshev", "Cosine")
        puts "-" * 70
        
        sample_pairs.each_with_index do |(point1, point2), pair_idx|
          distances = {}
          
          distance_methods.each do |method, name|
            begin
              if method == :cosine_distance
                distances[name] = Proximity.send(method, point1, point2)
              else
                distances[name] = Proximity.send(method, point1, point2)
              end
            rescue => e
              distances[name] = "Error"
            end
          end
          
          puts sprintf("%-15s %-12s %-12s %-12s %-12s",
                      "#{pair_idx + 1}",
                      format_distance(distances["Euclidean"]),
                      format_distance(distances["Manhattan"]),
                      format_distance(distances["Chebyshev"]),
                      format_distance(distances["Cosine"]))
        end
        
        # Explain the differences
        if @config[:verbose]
          puts "\n=== Distance Metrics Explanation ==="
          puts "Euclidean: Straight-line distance. Sensitive to all dimensions equally."
          puts "Manhattan: City-block distance. Sum of absolute differences."
          puts "Chebyshev: Maximum difference across any dimension."
          puts "Cosine: Measures angle between vectors. Good for high-dimensional data."
        end
      end
      
      private
      
      def get_numeric_data
        return [] if @dataset.data_items.empty?
        
        # Get only numeric columns (excluding class if it's the last column)
        feature_columns = (0...(@dataset.num_attributes - 1))
        
        @dataset.data_items.map do |row|
          features = feature_columns.map { |col| row[col] }.select { |val| val.is_a?(Numeric) }
          features.length > 0 ? features : nil
        end.compact
      end
      
      def format_distance(distance)
        case distance
        when Numeric
          distance.round(3).to_s
        else
          distance.to_s
        end
      end
    end
    
    # Feature engineering and transformation
    class FeatureEngineer
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end
      
      def apply_techniques(data_items, techniques)
        result_data = data_items.dup
        
        techniques.each do |technique|
          case technique
          when :polynomial
            result_data = add_polynomial_features(result_data)
          when :interaction
            result_data = add_interaction_features(result_data)
          when :binning
            result_data = add_binned_features(result_data)
          when :log_transform
            result_data = apply_log_transform(result_data)
          when :square_root
            result_data = apply_sqrt_transform(result_data)
          else
            puts "Unknown feature engineering technique: #{technique}" if @config[:verbose]
          end
        end
        
        result_data
      end
      
      private
      
      def add_polynomial_features(data_items)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1  # Exclude class column
        
        engineered_data = data_items.map do |row|
          features = row[0...feature_count]
          class_value = row.last
          
          # Add squared features
          squared_features = features.select { |f| f.is_a?(Numeric) }.map { |f| f**2 }
          
          # Add interaction features (products of pairs)
          interaction_features = []
          features.select { |f| f.is_a?(Numeric) }.combination(2) do |f1, f2|
            interaction_features << f1 * f2
          end
          
          features + squared_features + interaction_features + [class_value]
        end
        
        puts "Added polynomial features (squared + interactions)" if @config[:verbose]
        engineered_data
      end
      
      def add_interaction_features(data_items)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1
        
        engineered_data = data_items.map do |row|
          features = row[0...feature_count]
          class_value = row.last
          
          interaction_features = []
          numeric_features = features.each_with_index.select { |f, _| f.is_a?(Numeric) }
          
          numeric_features.combination(2) do |(f1, i1), (f2, i2)|
            interaction_features << f1 * f2
          end
          
          features + interaction_features + [class_value]
        end
        
        puts "Added interaction features" if @config[:verbose]
        engineered_data
      end
      
      def add_binned_features(data_items)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1
        
        # Calculate bins for each numeric feature
        bins_info = []
        feature_count.times do |col|
          values = data_items.map { |row| row[col] }.select { |v| v.is_a?(Numeric) }
          if values.any?
            min_val, max_val = values.minmax
            if min_val != max_val
              bin_width = (max_val - min_val) / 5  # 5 bins
              bins_info[col] = { min: min_val, max: max_val, width: bin_width }
            end
          end
        end
        
        engineered_data = data_items.map do |row|
          features = row[0...feature_count]
          class_value = row.last
          
          binned_features = features.each_with_index.map do |feature, col|
            if feature.is_a?(Numeric) && bins_info[col]
              bin_info = bins_info[col]
              bin_index = [(feature - bin_info[:min]) / bin_info[:width], 4].min.to_i
              bin_index
            else
              nil
            end
          end.compact
          
          features + binned_features + [class_value]
        end
        
        puts "Added binned features (5 bins per numeric feature)" if @config[:verbose]
        engineered_data
      end
      
      def apply_log_transform(data_items)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1
        
        transformed_data = data_items.map do |row|
          features = row[0...feature_count]
          class_value = row.last
          
          log_features = features.map do |feature|
            if feature.is_a?(Numeric) && feature > 0
              Math.log(feature)
            elsif feature.is_a?(Numeric) && feature <= 0
              Math.log(feature + 1)  # Add 1 to handle zero/negative values
            else
              feature
            end
          end
          
          log_features + [class_value]
        end
        
        puts "Applied log transformation to numeric features" if @config[:verbose]
        transformed_data
      end
      
      def apply_sqrt_transform(data_items)
        return data_items if data_items.empty?
        
        feature_count = data_items.first.length - 1
        
        transformed_data = data_items.map do |row|
          features = row[0...feature_count]
          class_value = row.last
          
          sqrt_features = features.map do |feature|
            if feature.is_a?(Numeric) && feature >= 0
              Math.sqrt(feature)
            elsif feature.is_a?(Numeric) && feature < 0
              -Math.sqrt(-feature)  # Handle negative values
            else
              feature
            end
          end
          
          sqrt_features + [class_value]
        end
        
        puts "Applied square root transformation to numeric features" if @config[:verbose]
        transformed_data
      end
    end
  end
end