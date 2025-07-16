# frozen_string_literal: true

# Educational examples for data handling and preprocessing
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'educational_data_set'
require_relative 'data_preprocessing'
require_relative 'data_visualization'

module Ai4r
  module Data
    # Collection of educational examples for data handling
    class EducationalDataExamples
      # Example 1: Basic data exploration and quality assessment
      def self.data_exploration_tutorial(verbose: true)
        puts '=== Data Exploration Tutorial ===' if verbose
        puts 'Learning to understand your data before analysis' if verbose

        # Create sample customer data with realistic issues
        customer_data = [
          # [age, income, purchases, satisfaction, region, is_customer]
          [25, 35_000, 12, 8.5, 'North', true],
          [nil, 42_000, 8, 7.2, 'South', true], # Missing age
          [35, nil, 15, 9.1, 'East', true], # Missing income
          [28, 38_000, 10, 8.8, 'North', true],
          [45, 65_000, 25, 6.5, 'West', false],
          [33, 48_000, 18, 8.9, 'East', true],
          [29, 41_000, 14, 7.8, 'South', true],
          [52, 75_000, 30, 5.2, 'West', false],      # Potential outlier
          [26, 36_000, 11, '', 'North', true],       # Missing satisfaction
          [31, 44_000, 16, 8.3, 'East', true],
          [38, 58_000, 22, 7.9, 'West', true],
          [27, 39_000, 13, 8.6, 'South', true],
          [200, 45_000, 17, 8.1, 'North', true],     # Age outlier
          [34, 51_000, 19, 9.0, 'East', true],
          [30, 43_000, 15, 8.4, 'South', true]
        ]

        labels = %w[age income purchases satisfaction region is_customer]

        # Create educational dataset
        dataset = EducationalDataSet.new(
          data_items: customer_data,
          data_labels: labels,
          verbose: verbose,
          explain_operations: true
        )

        # Enable educational mode
        dataset.enable_educational_mode

        puts "\n1. Basic Dataset Information:" if verbose
        dataset.info

        puts "\n2. Statistical Summary:" if verbose
        dataset.describe

        puts "\n3. Missing Values Analysis:" if verbose
        dataset.missing_values_report

        puts "\n4. Outlier Detection:" if verbose
        dataset.detect_outliers(method: :iqr, threshold: 1.5)

        puts "\n5. Data Visualization:" if verbose
        dataset.visualize('age', :histogram)
        dataset.visualize('income', :box_plot)
        dataset.visualize('region', :bar_chart)

        if verbose
          puts "\n=== Key Learning Points ==="
          puts '• Always start with basic data exploration'
          puts '• Look for missing values and outliers'
          puts '• Understand the distribution of your variables'
          puts '• Check data quality before analysis'
        end

        dataset
      end

      # Example 2: Data preprocessing pipeline
      def self.preprocessing_pipeline_tutorial(verbose: true)
        puts "\n=== Data Preprocessing Pipeline Tutorial ===" if verbose
        puts 'Learning to clean and prepare data for machine learning' if verbose

        # Create messy dataset that needs preprocessing
        messy_data = [
          [1.2, 100, 0.8, 'A', 1],
          [nil, 150, 1.2, 'B', 0],        # Missing value
          [2.1, 200, 1.5, 'A', 1],
          [1.8, 120, 0.9, 'C', 0],
          [50.0, 180, 2.1, 'B', 1],       # Outlier
          [1.5, nil, 1.1, 'A', 0],        # Missing value
          [1.9, 160, 1.3, 'C', 1],
          [1.4, 140, 0.7, 'B', 0],
          [2.3, 220, 1.8, 'A', 1],
          [1.7, 130, 1.0, '', 0],         # Missing category
          [2.0, 170, 1.4, 'C', 1],
          [1.6, 110, 0.6, 'B', 0]
        ]

        labels = %w[feature1 feature2 feature3 category target]

        dataset = EducationalDataSet.new(
          data_items: messy_data,
          data_labels: labels,
          verbose: verbose,
          explain_operations: true
        )

        puts "\nOriginal Dataset:" if verbose
        dataset.info

        # Step 1: Handle missing values
        puts "\nStep 1: Handle Missing Values" if verbose
        dataset.handle_missing_values!(strategy: :mean)

        # Step 2: Detect and handle outliers
        puts "\nStep 2: Outlier Detection" if verbose
        dataset.detect_outliers(method: :z_score, threshold: 2.5)

        # Step 3: Normalize features
        puts "\nStep 3: Normalize Features" if verbose
        dataset.normalize!(method: :min_max)

        # Step 4: Scale for machine learning
        puts "\nStep 4: Feature Scaling" if verbose
        dataset.scale_features!(method: :standardize)

        # Step 5: Split for training
        puts "\nStep 5: Train-Test Split" if verbose
        splits = dataset.train_test_split(test_size: 0.3, random_seed: 42)

        if verbose
          puts "\nFinal Dataset Information:"
          dataset.info

          puts "\n=== Preprocessing Pipeline Summary ==="
          dataset.transformation_history_report

          puts "\n=== Key Learning Points ==="
          puts '• Preprocessing is crucial for ML success'
          puts '• Handle missing values before other operations'
          puts '• Detect outliers early in the process'
          puts '• Normalize/scale features for consistent ranges'
          puts '• Always split data before final preprocessing'
        end

        { original: dataset, train: splits[:train], test: splits[:test] }
      end

      # Example 3: Feature engineering exploration
      def self.feature_engineering_tutorial(verbose: true)
        puts "\n=== Feature Engineering Tutorial ===" if verbose
        puts 'Learning to create and transform features for better ML performance' if verbose

        # Create dataset suitable for feature engineering
        engineering_data = [
          [2.0, 3.0, 1], # Simple 2D features
          [1.5, 2.5, 0],
          [3.0, 4.0, 1],
          [2.5, 3.5, 1],
          [1.0, 2.0, 0],
          [3.5, 4.5, 1],
          [2.2, 3.2, 1],
          [1.8, 2.8, 0],
          [2.8, 3.8, 1],
          [1.3, 2.3, 0],
          [3.2, 4.2, 1],
          [2.0, 3.0, 0]
        ]

        labels = %w[x1 x2 class]

        dataset = EducationalDataSet.new(
          data_items: engineering_data,
          data_labels: labels,
          verbose: verbose,
          explain_operations: true
        )

        puts "\nOriginal Features:" if verbose
        dataset.visualize('x1', :histogram)
        dataset.visualize('x2', :histogram)
        dataset.visualize(%w[x1 x2], :scatter)

        # Create a copy for each engineering technique
        datasets = {}

        # Technique 1: Polynomial features
        puts "\nTechnique 1: Polynomial Features" if verbose
        poly_dataset = EducationalDataSet.new(
          data_items: engineering_data.dup,
          data_labels: labels.dup,
          verbose: verbose,
          explain_operations: true
        )
        poly_dataset.engineer_features!(techniques: [:polynomial])
        datasets[:polynomial] = poly_dataset

        # Technique 2: Interaction features only
        puts "\nTechnique 2: Interaction Features" if verbose
        interaction_dataset = EducationalDataSet.new(
          data_items: engineering_data.dup,
          data_labels: labels.dup,
          verbose: verbose,
          explain_operations: true
        )
        interaction_dataset.engineer_features!(techniques: [:interaction])
        datasets[:interaction] = interaction_dataset

        # Technique 3: Log transformation
        puts "\nTechnique 3: Log Transformation" if verbose
        log_dataset = EducationalDataSet.new(
          data_items: engineering_data.dup,
          data_labels: labels.dup,
          verbose: verbose,
          explain_operations: true
        )
        log_dataset.engineer_features!(techniques: [:log_transform])
        datasets[:log_transform] = log_dataset

        # Technique 4: Binning
        puts "\nTechnique 4: Feature Binning" if verbose
        binning_dataset = EducationalDataSet.new(
          data_items: engineering_data.dup,
          data_labels: labels.dup,
          verbose: verbose,
          explain_operations: true
        )
        binning_dataset.engineer_features!(techniques: [:binning])
        datasets[:binning] = binning_dataset

        # Compare feature counts
        if verbose
          puts "\n=== Feature Count Comparison ==="
          puts "Original features: #{dataset.num_attributes - 1}"
          datasets.each do |technique, ds|
            puts "#{technique.to_s.capitalize} features: #{ds.num_attributes - 1}"
          end

          puts "\n=== Key Learning Points ==="
          puts '• Feature engineering can dramatically improve model performance'
          puts '• Polynomial features capture non-linear relationships'
          puts '• Interaction features find feature combinations'
          puts '• Transformations can normalize skewed distributions'
          puts '• Binning converts continuous to categorical features'
          puts "• More features isn't always better - consider overfitting"
        end

        datasets[:original] = dataset
        datasets
      end

      # Example 4: Cross-validation and data splitting
      def self.cross_validation_tutorial(verbose: true)
        puts "\n=== Cross-Validation Tutorial ===" if verbose
        puts 'Learning proper data splitting for reliable model evaluation' if verbose

        # Create classification dataset
        classification_data = generate_classification_data(size: 100, features: 3, classes: 2)

        dataset = EducationalDataSet.new(
          data_items: classification_data,
          data_labels: %w[feature1 feature2 feature3 class],
          verbose: verbose,
          explain_operations: true
        )

        puts "\nDataset Overview:" if verbose
        dataset.info

        # Simple train-test split
        puts "\n1. Simple Train-Test Split (70-30)" if verbose
        simple_split = dataset.train_test_split(test_size: 0.3, random_seed: 42)

        # K-fold cross-validation
        puts "\n2. K-Fold Cross-Validation (k=5)" if verbose
        cv_folds = dataset.cross_validation_folds(k: 5, random_seed: 42)

        # Stratified approach simulation (for educational purposes)
        puts "\n3. Stratified Splitting Concept" if verbose
        puts '   (Maintains class distribution in splits)'

        if verbose
          puts "\n=== Split Analysis ==="
          puts 'Simple split:'
          puts "  Training: #{simple_split[:train].data_items.length} samples"
          puts "  Testing: #{simple_split[:test].data_items.length} samples"

          puts "\nCross-validation folds:"
          cv_folds.each do |fold|
            puts "  Fold #{fold[:fold]}: #{fold[:train].data_items.length} train, #{fold[:test].data_items.length} test"
          end

          puts "\n=== Key Learning Points ==="
          puts '• Never test on training data - causes overfitting'
          puts '• Cross-validation gives more reliable estimates'
          puts '• Stratified splitting maintains class balance'
          puts '• Use consistent random seeds for reproducibility'
          puts '• Larger test sets give more reliable estimates'
        end

        {
          dataset: dataset,
          simple_split: simple_split,
          cv_folds: cv_folds
        }
      end

      # Example 5: Distance metrics comparison
      def self.distance_metrics_tutorial(verbose: true)
        puts "\n=== Distance Metrics Tutorial ===" if verbose
        puts 'Understanding how different distance measures affect similarity' if verbose

        # Create data points with different characteristics
        distance_data = [
          [1.0, 1.0],      # Point A
          [2.0, 2.0],      # Point B - close to A
          [10.0, 1.0],     # Point C - far in x dimension
          [1.0, 10.0],     # Point D - far in y dimension
          [5.0, 5.0],      # Point E - middle
          [1.1, 1.1],      # Point F - very close to A
          [0.0, 0.0],      # Point G - origin
          [3.0, 7.0]       # Point H - diagonal
        ]

        labels = %w[x y point_id]

        # Add point IDs for reference
        labeled_data = distance_data.each_with_index.map do |point, idx|
          point + [('A'.ord + idx).chr]
        end

        dataset = EducationalDataSet.new(
          data_items: labeled_data,
          data_labels: labels,
          verbose: verbose,
          explain_operations: true
        )

        puts "\nData Points Visualization:" if verbose
        dataset.visualize(%w[x y], :scatter)

        puts "\nDistance Metrics Comparison:" if verbose
        dataset.compare_distance_metrics(sample_size: 8)

        # Manual distance calculation for educational purposes
        if verbose
          puts "\n=== Manual Distance Calculations ==="
          point_a = [1.0, 1.0]
          point_b = [2.0, 2.0]
          point_c = [10.0, 1.0]

          puts "Between Point A #{point_a.inspect} and Point B #{point_b.inspect}:"
          puts "  Euclidean: #{Math.sqrt(((point_a[0] - point_b[0])**2) + ((point_a[1] - point_b[1])**2)).round(3)}"
          puts "  Manhattan: #{(point_a[0] - point_b[0]).abs + (point_a[1] - point_b[1]).abs}"
          puts "  Chebyshev: #{[(point_a[0] - point_b[0]).abs, (point_a[1] - point_b[1]).abs].max}"

          puts "\nBetween Point A #{point_a.inspect} and Point C #{point_c.inspect}:"
          puts "  Euclidean: #{Math.sqrt(((point_a[0] - point_c[0])**2) + ((point_a[1] - point_c[1])**2)).round(3)}"
          puts "  Manhattan: #{(point_a[0] - point_c[0]).abs + (point_a[1] - point_c[1]).abs}"
          puts "  Chebyshev: #{[(point_a[0] - point_c[0]).abs, (point_a[1] - point_c[1]).abs].max}"

          puts "\n=== Key Learning Points ==="
          puts '• Euclidean: Most common, treats all dimensions equally'
          puts '• Manhattan: Good when features have different units'
          puts '• Chebyshev: Focuses on the largest difference'
          puts '• Cosine: Good for high-dimensional, sparse data'
          puts '• Choice of distance metric affects clustering and classification'
        end

        dataset
      end

      # Example 6: Correlation analysis
      def self.correlation_analysis_tutorial(verbose: true)
        puts "\n=== Correlation Analysis Tutorial ===" if verbose
        puts 'Understanding relationships between variables' if verbose

        # Create data with different correlation patterns
        size = 50
        correlation_data = []

        size.times do |_i|
          x1 = rand * 10
          x2 = x1 + (rand * 2) - 1          # Positive correlation
          x3 = 10 - x1 + (rand * 2) - 1     # Negative correlation
          x4 = rand * 10 # No correlation
          x5 = ((x1**2) / 10) + rand - 0.5 # Non-linear relationship

          correlation_data << [x1, x2, x3, x4, x5, (x1 + x2 > 10 ? 1 : 0)]
        end

        labels = %w[x1_base x2_positive x3_negative x4_random x5_nonlinear target]

        dataset = EducationalDataSet.new(
          data_items: correlation_data,
          data_labels: labels,
          verbose: verbose,
          explain_operations: true
        )

        puts "\nDataset Statistical Summary:" if verbose
        dataset.describe

        puts "\nCorrelation Analysis:" if verbose
        dataset.correlation_matrix

        puts "\nCorrelation Heatmap:" if verbose
        dataset.visualize(nil, :correlation_heatmap)

        puts "\nScatter Plots of Key Relationships:" if verbose
        dataset.visualize(%w[x1_base x2_positive], :scatter)
        dataset.visualize(%w[x1_base x3_negative], :scatter)
        dataset.visualize(%w[x1_base x4_random], :scatter)

        if verbose
          puts "\n=== Correlation Interpretation ==="
          puts 'Strong positive (0.7 to 1.0): Variables increase together'
          puts 'Moderate positive (0.3 to 0.7): Some positive relationship'
          puts 'Weak/No correlation (-0.3 to 0.3): Little linear relationship'
          puts 'Moderate negative (-0.7 to -0.3): Inverse relationship'
          puts 'Strong negative (-1.0 to -0.7): Strong inverse relationship'

          puts "\n=== Key Learning Points ==="
          puts '• Correlation measures linear relationships only'
          puts '• Non-linear relationships may show low correlation'
          puts "• Correlation doesn't imply causation"
          puts '• Check for multicollinearity in ML features'
          puts '• Use scatter plots to visualize relationships'
        end

        dataset
      end

      # Example 7: Data quality assessment comprehensive example
      def self.data_quality_comprehensive(verbose: true)
        puts "\n=== Comprehensive Data Quality Assessment ===" if verbose
        puts 'Learning to identify and fix data quality issues' if verbose

        # Create dataset with multiple quality issues
        problematic_data = [
          [25, 50_000, 'Engineer', 'New York', 1],
          [25, 50_000, 'Engineer', 'New York', 1],    # Duplicate
          [30, 60_000, 'Doctor', 'Boston', 1],
          [nil, 55_000, 'Teacher', 'Chicago', 0],     # Missing age
          [35, nil, 'Lawyer', 'Seattle', 1], # Missing salary
          [28, 48_000, '', 'Miami', 0],               # Missing profession
          [150, 45_000, 'Artist', 'Portland', 0],     # Age outlier
          [32, -5000, 'Writer', 'Austin', 1], # Impossible salary
          [29, 52_000, 'Nurse', 'Denver', 1],
          [31, 58_000, 'Chef', 'Nashville', 0],
          [27, 51_000, 'Designer', '', 1], # Missing city
          [33, 62_000, 'Manager', 'Phoenix', 1],
          [26, 49_000, 'Analyst', 'Atlanta', 0],
          [34, 0, 'Student', 'Philadelphia', 0],     # Zero salary (student)
          [28, 53_000, 'Developer', 'San Diego', 1],
          [nil, nil, '', '', nil]                    # Completely empty row
        ]

        labels = %w[age salary profession city employed]

        dataset = EducationalDataSet.new(
          data_items: problematic_data,
          data_labels: labels,
          verbose: verbose,
          explain_operations: true
        )

        puts "\n1. Initial Data Assessment:" if verbose
        dataset.info

        puts "\n2. Missing Values Analysis:" if verbose
        dataset.missing_values_report

        puts "\n3. Outlier Detection (Multiple Methods):" if verbose
        dataset.detect_outliers(method: :iqr, threshold: 1.5)
        dataset.detect_outliers(method: :z_score, threshold: 2.0)

        puts "\n4. Data Distribution Analysis:" if verbose
        dataset.visualize('age', :histogram)
        dataset.visualize('salary', :box_plot)
        dataset.visualize('profession', :bar_chart)

        puts "\n5. Data Cleaning Steps:" if verbose

        # Remove completely empty rows first
        original_count = dataset.data_items.length
        dataset.data_items.reject! { |row| row.all? { |val| val.nil? || val == '' } }
        puts "Removed #{original_count - dataset.data_items.length} completely empty rows" if verbose

        # Handle missing values
        dataset.handle_missing_values!(strategy: :mode) # Use mode for mixed data

        # Address outliers (for educational - in practice, investigate first)
        puts 'Note: In practice, investigate outliers before removing them' if verbose

        puts "\n6. Post-Cleaning Assessment:" if verbose
        dataset.info
        dataset.analyze_data

        if verbose
          puts "\n=== Data Quality Checklist ==="
          puts '✓ Check for missing values and handle appropriately'
          puts '✓ Identify and investigate outliers'
          puts '✓ Look for duplicate records'
          puts '✓ Validate data ranges and constraints'
          puts '✓ Check data type consistency'
          puts '✓ Verify categorical value consistency'
          puts '✓ Assess data completeness and coverage'

          puts "\n=== Key Learning Points ==="
          puts '• Data quality directly impacts analysis results'
          puts '• Multiple quality issues often occur together'
          puts '• Document all cleaning decisions for reproducibility'
          puts '• Consider domain knowledge when handling outliers'
          puts '• Quality assessment should be iterative'
        end

        dataset
      end

      # Run all examples in sequence
      def self.run_complete_tutorial(step_mode: false)
        puts '=== AI4R Data Handling Complete Tutorial ==='
        puts 'This tutorial covers all aspects of data preprocessing and analysis.'
        puts "Each section builds on previous concepts.\n"

        examples = [
          -> { data_exploration_tutorial(verbose: true) },
          -> { preprocessing_pipeline_tutorial(verbose: true) },
          -> { feature_engineering_tutorial(verbose: true) },
          -> { cross_validation_tutorial(verbose: true) },
          -> { distance_metrics_tutorial(verbose: true) },
          -> { correlation_analysis_tutorial(verbose: true) },
          -> { data_quality_comprehensive(verbose: true) }
        ]

        example_titles = [
          'Data Exploration and Quality Assessment',
          'Data Preprocessing Pipeline',
          'Feature Engineering Techniques',
          'Cross-Validation and Data Splitting',
          'Distance Metrics Comparison',
          'Correlation Analysis',
          'Comprehensive Data Quality Assessment'
        ]

        results = {}

        examples.each_with_index do |example, index|
          puts "\n#{'=' * 70}"
          puts "SECTION #{index + 1}: #{example_titles[index]}"
          puts '=' * 70

          results[example_titles[index]] = example.call

          if step_mode && index < examples.length - 1
            puts "\nPress Enter to continue to the next section..."
            gets
          end
        end

        puts "\n#{'=' * 70}"
        puts 'TUTORIAL COMPLETED!'
        puts '=' * 70
        puts "You've learned about:"
        puts '• Data exploration and quality assessment'
        puts '• Handling missing values and outliers'
        puts '• Data normalization and scaling'
        puts '• Feature engineering techniques'
        puts '• Proper data splitting for ML'
        puts '• Distance metrics and their applications'
        puts '• Correlation analysis'
        puts '• Comprehensive data quality management'
        puts '=' * 70

        results
      end

      # Generate synthetic classification data
      def self.generate_classification_data(size: 100, features: 2, classes: 2)
        data = []

        size.times do
          # Generate features
          feature_values = Array.new(features) { rand * 10 }

          # Generate class based on simple rule for educational purposes
          class_value = feature_values.sum > (features * 5) ? 1 : 0

          data << (feature_values + [class_value])
        end

        data
      end
    end

    # Sample data generator for educational purposes
    class DataGenerator
      def self.generate(type, size, features, noise)
        case type
        when :classification
          generate_classification_data(size, features, noise)
        when :regression
          generate_regression_data(size, features, noise)
        when :clustering
          generate_clustering_data(size, features, noise)
        else
          raise ArgumentError, "Unknown data type: #{type}"
        end
      end

      def self.generate_classification_data(size, features, noise)
        data = []

        size.times do
          # Generate feature values
          feature_values = Array.new(features) { rand * 10 }

          # Simple classification rule with noise
          signal = feature_values.sum
          threshold = features * 5
          base_class = signal > threshold ? 1 : 0

          # Add noise
          final_class = rand < noise ? (1 - base_class) : base_class

          data << (feature_values + [final_class])
        end

        data
      end

      def self.generate_regression_data(size, features, noise)
        data = []

        size.times do
          feature_values = Array.new(features) { (rand * 10) - 5 } # Range [-5, 5]

          # Linear combination with noise
          target = feature_values.sum + (rand * noise * 10) - (noise * 5)

          data << (feature_values + [target])
        end

        data
      end

      def self.generate_clustering_data(size, features, noise)
        data = []
        clusters = 3

        size.times do
          # Choose a cluster center
          cluster = rand(clusters)
          center = [cluster * 5, cluster * 3] # Different centers for each cluster

          # Generate point around center with noise
          feature_values = Array.new(features) do |i|
            center[i % center.length] + ((rand - 0.5) * noise * 5)
          end

          data << feature_values
        end

        data
      end
    end

    # Data export utilities
    class DataExporter
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end

      def export_csv(filename, include_metadata)
        require 'csv'

        CSV.open(filename, 'w') do |csv|
          # Write headers
          csv << @dataset.data_labels

          # Write data
          @dataset.data_items.each do |row|
            csv << row
          end
        end

        if include_metadata && @dataset.metadata
          metadata_filename = filename.sub('.csv', '_metadata.txt')
          File.open(metadata_filename, 'w') do |file|
            file.puts 'Dataset Metadata'
            file.puts '=' * 50
            file.puts "Shape: #{@dataset.shape.inspect}"
            file.puts "Data types: #{@dataset.metadata.attribute_types.inspect}"
            if @dataset.transformation_history.any?
              file.puts "\nTransformation History:"
              @dataset.transformation_history.each do |transform|
                file.puts "  #{transform[:operation]} (#{transform[:timestamp]})"
              end
            end
          end
          puts "Exported metadata to #{metadata_filename}" if @config[:verbose]
        end

        puts "Exported dataset to #{filename}" if @config[:verbose]
      end
    end

    # Comprehensive reporting
    class DataReporter
      def initialize(dataset, config)
        @dataset = dataset
        @config = config
      end

      def generate_full_report(filename)
        File.open(filename, 'w') do |file|
          file.puts 'AI4R Educational Data Analysis Report'
          file.puts '=' * 60
          file.puts "Generated: #{Time.now}"
          file.puts

          # Basic information
          file.puts 'DATASET OVERVIEW'
          file.puts '-' * 30
          file.puts "Shape: #{@dataset.shape.inspect} (rows, columns)"
          file.puts "Columns: #{@dataset.data_labels.join(', ')}"
          file.puts

          # Data types
          if @dataset.metadata&.attribute_types
            file.puts 'DATA TYPES'
            file.puts '-' * 30
            @dataset.metadata.attribute_types.each do |label, type|
              file.puts "#{label}: #{type}"
            end
            file.puts
          end

          # Quality issues
          if @dataset.quality_report
            file.puts 'DATA QUALITY ASSESSMENT'
            file.puts '-' * 30
            file.puts "Missing values: #{@dataset.quality_report[:has_missing_values] ? 'Yes' : 'No'}"

            if @dataset.quality_report[:has_missing_values]
              @dataset.quality_report[:missing_values_summary].each do |col, info|
                file.puts "  #{col}: #{info[:count]} missing (#{info[:percentage]}%)"
              end
            end

            if @dataset.quality_report[:potential_issues].any?
              file.puts 'Potential issues:'
              @dataset.quality_report[:potential_issues].each do |issue|
                file.puts "  • #{issue}"
              end
            end
            file.puts
          end

          # Transformations
          if @dataset.transformation_history.any?
            file.puts 'TRANSFORMATION HISTORY'
            file.puts '-' * 30
            @dataset.transformation_history.each_with_index do |transform, index|
              file.puts "#{index + 1}. #{transform[:operation]} (#{transform[:timestamp]})"
              file.puts "   Parameters: #{transform[:parameters]}" if transform[:parameters]
            end
            file.puts
          end

          # Recommendations
          file.puts 'RECOMMENDATIONS'
          file.puts '-' * 30
          file.puts '• Verify data quality before analysis'
          file.puts '• Consider feature engineering based on domain knowledge'
          file.puts '• Use appropriate preprocessing for your ML algorithm'
          file.puts '• Validate results with cross-validation'
          file.puts '• Document all preprocessing steps for reproducibility'
        end

        puts "Generated comprehensive report: #{filename}" if @config[:verbose]
      end
    end
  end
end
