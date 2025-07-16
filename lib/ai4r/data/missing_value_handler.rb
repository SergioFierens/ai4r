# frozen_string_literal: true

# Missing value handling with educational explanations
# Author::    Claude (AI Assistant)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    # Educational missing value handler with detailed strategy explanations
    class MissingValueHandler
      def initialize(dataset, educational_config = {})
        @dataset = dataset
        @config = educational_config
        @verbose = educational_config.fetch(:verbose, false)
        @explain_operations = educational_config.fetch(:explain_operations, false)
      end

      # Handle missing values using specified strategy
      def handle(data_items, strategy = :mean)
        explain_missing_value_strategy(strategy) if @explain_operations

        case strategy
        when :remove_rows, :drop_rows
          remove_rows_with_missing(data_items)
        when :remove_columns, :drop_columns
          remove_columns_with_missing(data_items)
        when :mean
          fill_with_mean(data_items)
        when :median
          fill_with_median(data_items)
        when :mode
          fill_with_mode(data_items)
        when :forward_fill, :ffill
          forward_fill(data_items)
        when :backward_fill, :bfill
          backward_fill(data_items)
        when :interpolate, :linear
          linear_interpolation(data_items)
        when :constant
          fill_with_constant(data_items)
        when :knn
          knn_imputation(data_items)
        else
          raise ArgumentError, "Unknown missing value strategy: #{strategy}"
        end
      end

      # Explain different missing value strategies
      def self.explain_strategy(strategy)
        explanations = {
          remove_rows: 'Remove rows with any missing values. ' \
                       'Pros: Simple, no assumptions. Cons: Loses data, may bias results.',

          remove_columns: 'Remove columns with missing values. ' \
                          'Pros: Retains all rows. Cons: Loses features, reduces model input.',

          mean: 'Fill missing values with column mean (numeric only). ' \
                "Pros: Preserves distribution center. Cons: Reduces variance, doesn't work for non-numeric.",

          median: 'Fill missing values with column median (numeric only). ' \
                  'Pros: Robust to outliers. Cons: Still reduces variance, mode may be better for skewed data.',

          mode: 'Fill missing values with most frequent value. ' \
                'Pros: Works for all data types. Cons: May over-represent common values.',

          forward_fill: 'Use previous non-null value (good for time series). ' \
                        'Pros: Maintains temporal continuity. Cons: Assumes persistence of values.',

          backward_fill: 'Use next non-null value (time series). ' \
                         'Pros: Uses future information. Cons: Not realistic for real-time scenarios.',

          interpolate: 'Linear interpolation between known values. ' \
                       'Pros: Smooth transitions. Cons: Assumes linear relationships.',

          constant: 'Fill with a specific constant value. ' \
                    'Pros: Explicit handling. Cons: May introduce bias.',

          knn: 'Use k-nearest neighbors to estimate missing values. ' \
               'Pros: Uses similarity patterns. Cons: Computationally expensive.'
        }

        explanations[strategy] || 'Unknown missing value strategy'
      end

      # Analyze missing value patterns
      def analyze_missing_patterns(data_items, data_labels)
        analysis = {
          total_missing: 0,
          by_column: {},
          by_row: {},
          patterns: [],
          recommendations: []
        }

        return analysis if data_items.empty?

        # Analyze by column
        data_labels.each_with_index do |label, col_idx|
          missing_count = data_items.count { |row| missing_value?(row[col_idx]) }
          missing_percentage = (missing_count.to_f / data_items.length * 100).round(2)

          analysis[:by_column][label] = {
            count: missing_count,
            percentage: missing_percentage
          }

          analysis[:total_missing] += missing_count
        end

        # Analyze by row
        data_items.each_with_index do |row, row_idx|
          missing_count = row.count { |cell| missing_value?(cell) }
          next unless missing_count > 0

          analysis[:by_row][row_idx] = {
            count: missing_count,
            percentage: (missing_count.to_f / row.length * 100).round(2)
          }
        end

        # Detect patterns
        analysis[:patterns] = detect_missing_patterns(data_items, data_labels)

        # Generate recommendations
        analysis[:recommendations] = generate_missing_value_recommendations(analysis, data_items)

        display_missing_analysis(analysis) if @verbose

        analysis
      end

      private

      def explain_missing_value_strategy(strategy)
        puts "\n🔧 Missing Value Strategy: #{strategy.to_s.humanize}"
        puts "Approach: #{self.class.explain_strategy(strategy)}"

        show_strategy_warnings(strategy) if @config[:show_warnings]
      end

      def show_strategy_warnings(strategy)
        warnings = {
          remove_rows: '⚠️  May significantly reduce dataset size if many rows have missing values.',
          remove_columns: '⚠️  May remove important features. Consider the impact on model performance.',
          mean: '⚠️  Reduces variance and may mask patterns. Consider for numeric data only.',
          median: '✅ Generally safe for numeric data, especially with outliers.',
          mode: '✅ Good general approach for categorical data.',
          forward_fill: '⚠️  Only appropriate for time-ordered data.',
          backward_fill: '⚠️  Uses future information - not suitable for real-time predictions.',
          interpolate: '⚠️  Assumes linear relationships between values.',
          constant: '⚠️  Choose constant value carefully to avoid introducing bias.',
          knn: '⚠️  Computationally expensive and may overfit to local patterns.'
        }

        puts warnings[strategy] if warnings[strategy]
      end

      def missing_value?(value)
        value.nil? || value == '' || (value.respond_to?(:nan?) && value.nan?)
      end

      def remove_rows_with_missing(data_items)
        cleaned_data = data_items.select do |row|
          row.none? { |cell| missing_value?(cell) }
        end

        removed_count = data_items.length - cleaned_data.length

        if @verbose && removed_count > 0
          puts "🗑️  Removed #{removed_count} rows with missing values"
          puts "   Retention rate: #{(cleaned_data.length.to_f / data_items.length * 100).round(1)}%"
        end

        cleaned_data
      end

      def remove_columns_with_missing(data_items)
        return data_items if data_items.empty?

        columns_to_keep = []
        num_columns = data_items.first.length

        num_columns.times do |col_idx|
          has_missing = data_items.any? { |row| missing_value?(row[col_idx]) }
          columns_to_keep << col_idx unless has_missing
        end

        cleaned_data = data_items.map do |row|
          columns_to_keep.map { |col_idx| row[col_idx] }
        end

        removed_count = num_columns - columns_to_keep.length

        if @verbose && removed_count > 0
          puts "🗑️  Removed #{removed_count} columns with missing values"
          puts "   Feature retention: #{columns_to_keep.length}/#{num_columns}"
        end

        cleaned_data
      end

      def fill_with_mean(data_items)
        return data_items if data_items.empty?

        column_means = calculate_column_means(data_items)
        filled_data = fill_missing_with_values(data_items, column_means, 'mean')

        if @verbose
          puts '📊 Filled missing values with column means:'
          column_means.each_with_index do |mean, idx|
            next unless mean

            puts "   Column #{idx}: #{mean.round(3)}"
          end
        end

        filled_data
      end

      def fill_with_median(data_items)
        return data_items if data_items.empty?

        column_medians = calculate_column_medians(data_items)
        filled_data = fill_missing_with_values(data_items, column_medians, 'median')

        if @verbose
          puts '📊 Filled missing values with column medians:'
          column_medians.each_with_index do |median, idx|
            next unless median

            puts "   Column #{idx}: #{median.round(3)}"
          end
        end

        filled_data
      end

      def fill_with_mode(data_items)
        return data_items if data_items.empty?

        column_modes = calculate_column_modes(data_items)
        filled_data = fill_missing_with_values(data_items, column_modes, 'mode')

        if @verbose
          puts '📊 Filled missing values with column modes:'
          column_modes.each_with_index do |mode, idx|
            next unless mode

            puts "   Column #{idx}: #{mode}"
          end
        end

        filled_data
      end

      def forward_fill(data_items)
        return data_items if data_items.empty?

        filled_data = []
        data_items.first.length

        data_items.each_with_index do |row, row_idx|
          filled_row = row.map.with_index do |cell, col_idx|
            if missing_value?(cell) && row_idx > 0
              # Use previous row's value
              filled_data[row_idx - 1][col_idx]
            else
              cell
            end
          end

          filled_data << filled_row
        end

        if @verbose
          filled_count = count_filled_values(data_items, filled_data)
          puts "⏭️  Forward filled #{filled_count} missing values"
        end

        filled_data
      end

      def backward_fill(data_items)
        return data_items if data_items.empty?

        filled_data = data_items.dup
        num_rows = data_items.length
        data_items.first.length

        # Process backwards
        (num_rows - 2).downto(0) do |row_idx|
          filled_data[row_idx] = filled_data[row_idx].map.with_index do |cell, col_idx|
            if missing_value?(cell)
              filled_data[row_idx + 1][col_idx]
            else
              cell
            end
          end
        end

        if @verbose
          filled_count = count_filled_values(data_items, filled_data)
          puts "⏮️  Backward filled #{filled_count} missing values"
        end

        filled_data
      end

      def linear_interpolation(data_items)
        return data_items if data_items.empty?

        filled_data = data_items.dup
        num_columns = data_items.first.length

        num_columns.times do |col_idx|
          values = data_items.map { |row| row[col_idx] }

          # Only interpolate numeric columns
          next unless values.any? { |v| !missing_value?(v) && v.is_a?(Numeric) }

          interpolated_values = interpolate_column(values)

          interpolated_values.each_with_index do |value, row_idx|
            filled_data[row_idx][col_idx] = value
          end
        end

        if @verbose
          filled_count = count_filled_values(data_items, filled_data)
          puts "📈 Interpolated #{filled_count} missing values"
        end

        filled_data
      end

      def fill_with_constant(data_items, constant_value = 0)
        return data_items if data_items.empty?

        filled_data = data_items.map do |row|
          row.map { |cell| missing_value?(cell) ? constant_value : cell }
        end

        if @verbose
          filled_count = count_filled_values(data_items, filled_data)
          puts "🔢 Filled #{filled_count} missing values with constant: #{constant_value}"
        end

        filled_data
      end

      def knn_imputation(data_items, k = 5)
        # Simplified KNN imputation - in production, would use more sophisticated algorithms
        return fill_with_mean(data_items) if data_items.length < k

        puts "🔍 Applying simplified KNN imputation (k=#{k})..." if @verbose

        filled_data = data_items.dup

        data_items.each_with_index do |row, row_idx|
          next unless row.any? { |cell| missing_value?(cell) }

          # Find k nearest neighbors based on non-missing values
          neighbors = find_nearest_neighbors(row, data_items, k, row_idx)

          # Fill missing values with neighbor averages
          row.each_with_index do |cell, col_idx|
            next unless missing_value?(cell)

            neighbor_values = neighbors.filter_map { |neighbor| neighbor[col_idx] }

            if neighbor_values.any? && neighbor_values.all?(Numeric)
              filled_data[row_idx][col_idx] = neighbor_values.sum.to_f / neighbor_values.length
            elsif neighbor_values.any?
              # Use mode for non-numeric
              filled_data[row_idx][col_idx] = neighbor_values.group_by(&:itself).max_by { |_k, v| v.length }&.first
            end
          end
        end

        filled_data
      end

      def calculate_column_means(data_items)
        return [] if data_items.empty?

        num_columns = data_items.first.length
        means = []

        num_columns.times do |col_idx|
          values = data_items.filter_map { |row| row[col_idx] }
          numeric_values = values.select { |v| v.is_a?(Numeric) }

          means << if numeric_values.any?
                     (numeric_values.sum.to_f / numeric_values.length)
                   end
        end

        means
      end

      def calculate_column_medians(data_items)
        return [] if data_items.empty?

        num_columns = data_items.first.length
        medians = []

        num_columns.times do |col_idx|
          values = data_items.filter_map { |row| row[col_idx] }
          numeric_values = values.select { |v| v.is_a?(Numeric) }.sort

          if numeric_values.any?
            n = numeric_values.length
            median = if n.odd?
                       numeric_values[n / 2]
                     else
                       (numeric_values[(n / 2) - 1] + numeric_values[n / 2]) / 2.0
                     end
            medians << median
          else
            medians << nil
          end
        end

        medians
      end

      def calculate_column_modes(data_items)
        return [] if data_items.empty?

        num_columns = data_items.first.length
        modes = []

        num_columns.times do |col_idx|
          values = data_items.filter_map { |row| row[col_idx] }

          if values.any?
            mode = values.group_by(&:itself).max_by { |_k, v| v.length }&.first
            modes << mode
          else
            modes << nil
          end
        end

        modes
      end

      def fill_missing_with_values(data_items, fill_values, _method_name)
        data_items.map do |row|
          row.map.with_index do |cell, col_idx|
            if missing_value?(cell) && fill_values[col_idx]
              fill_values[col_idx]
            else
              cell
            end
          end
        end
      end

      def interpolate_column(values)
        interpolated = values.dup

        # Find missing value positions
        missing_indices = []
        values.each_with_index do |value, idx|
          missing_indices << idx if missing_value?(value)
        end

        missing_indices.each do |idx|
          # Find previous and next non-missing values
          prev_idx = (0...idx).reverse_each.find { |i| !missing_value?(values[i]) && values[i].is_a?(Numeric) }
          next_idx = ((idx + 1)...values.length).find { |i| !missing_value?(values[i]) && values[i].is_a?(Numeric) }

          if prev_idx && next_idx
            # Linear interpolation
            prev_val = values[prev_idx]
            next_val = values[next_idx]
            ratio = (idx - prev_idx).to_f / (next_idx - prev_idx)
            interpolated[idx] = prev_val + (ratio * (next_val - prev_val))
          elsif prev_idx
            # Use previous value
            interpolated[idx] = values[prev_idx]
          elsif next_idx
            # Use next value
            interpolated[idx] = values[next_idx]
          end
        end

        interpolated
      end

      def find_nearest_neighbors(target_row, all_rows, k, exclude_idx)
        distances = []

        all_rows.each_with_index do |row, idx|
          next if idx == exclude_idx

          distance = calculate_distance(target_row, row)
          distances << { row: row, distance: distance, index: idx } unless distance.nil?
        end

        # Sort by distance and take k nearest
        distances.sort_by { |d| d[:distance] }.first(k).map { |d| d[:row] }
      end

      def calculate_distance(row1, row2)
        # Simple Euclidean distance for non-missing numeric values
        numeric_pairs = []

        row1.zip(row2).each do |val1, val2|
          if !missing_value?(val1) && !missing_value?(val2) && val1.is_a?(Numeric) && val2.is_a?(Numeric)
            numeric_pairs << [val1, val2]
          end
        end

        return nil if numeric_pairs.empty?

        sum_squared_diff = numeric_pairs.sum { |v1, v2| (v1 - v2)**2 }
        Math.sqrt(sum_squared_diff)
      end

      def count_filled_values(original_data, filled_data)
        count = 0
        original_data.each_with_index do |row, row_idx|
          row.each_with_index do |cell, col_idx|
            count += 1 if missing_value?(cell) && !missing_value?(filled_data[row_idx][col_idx])
          end
        end
        count
      end

      def detect_missing_patterns(data_items, data_labels)
        patterns = []

        # Pattern 1: Completely missing columns
        data_labels.each_with_index do |label, col_idx|
          missing_count = data_items.count { |row| missing_value?(row[col_idx]) }
          if missing_count == data_items.length
            patterns << "Column '#{label}' is completely missing"
          elsif missing_count > data_items.length * 0.5
            patterns << "Column '#{label}' has high missing rate: #{(missing_count.to_f / data_items.length * 100).round(1)}%"
          end
        end

        # Pattern 2: Rows with high missing rates
        high_missing_rows = 0
        data_items.each_with_index do |row, _row_idx|
          missing_count = row.count { |cell| missing_value?(cell) }
          high_missing_rows += 1 if missing_count > row.length * 0.5
        end

        patterns << "#{high_missing_rows} rows have >50% missing values" if high_missing_rows > 0

        patterns
      end

      def generate_missing_value_recommendations(analysis, data_items)
        recommendations = []
        total_cells = data_items.length * (data_items.first&.length || 0)
        missing_percentage = (analysis[:total_missing].to_f / total_cells * 100).round(2)

        recommendations << if missing_percentage < 5
                             'Low missing data (<5%). Simple strategies like mean/mode imputation should work well.'
                           elsif missing_percentage < 20
                             'Moderate missing data (5-20%). Consider median/mode imputation or more sophisticated methods.'
                           else
                             'High missing data (>20%). Investigate data collection process. Consider domain-specific imputation.'
                           end

        # Column-specific recommendations
        analysis[:by_column].each do |column, info|
          if info[:percentage] > 50
            recommendations << "Column '#{column}' has >50% missing values. Consider removing or investigating further."
          elsif info[:percentage] > 20
            recommendations << "Column '#{column}' has significant missing values (#{info[:percentage]}%). Use robust imputation methods."
          end
        end

        recommendations
      end

      def display_missing_analysis(analysis)
        puts "\n📊 Missing Value Analysis"
        puts '=' * 50

        total_cells = analysis[:by_column].values.sum { |info| info[:count] } +
                      (analysis[:by_column].length * (analysis[:by_row].length || 0))

        puts "Total missing values: #{analysis[:total_missing]}"
        puts "Missing percentage: #{(analysis[:total_missing].to_f / total_cells * 100).round(2)}%" if total_cells > 0

        puts "\nBy Column:"
        analysis[:by_column].each do |column, info|
          puts "  #{column}: #{info[:count]} (#{info[:percentage]}%)"
        end

        puts "\nRows with missing values: #{analysis[:by_row].length}" if analysis[:by_row].any?

        if analysis[:patterns].any?
          puts "\nPatterns detected:"
          analysis[:patterns].each { |pattern| puts "  • #{pattern}" }
        end

        if analysis[:recommendations].any?
          puts "\nRecommendations:"
          analysis[:recommendations].each { |rec| puts "  💡 #{rec}" }
        end
      end
    end
  end
end
