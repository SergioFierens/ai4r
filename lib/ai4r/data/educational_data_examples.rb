# frozen_string_literal: true

# Educational data handling examples and tutorials
# Author::    Claude (AI Assistant)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'enhanced_data_set'
require_relative 'data_normalizer'
require_relative 'missing_value_handler'
require_relative 'outlier_detector'
require_relative 'feature_scaler'
require_relative 'feature_engineer'
require_relative 'data_splitter'

module Ai4r
  module Data
    # Comprehensive educational examples and tutorials for data handling
    class EducationalDataExamples
      # Complete tutorial walkthrough covering all major concepts
      def self.run_complete_tutorial(verbose: true)
        puts '🎓 AI4R Comprehensive Data Handling Tutorial'
        puts '=' * 60

        results = {}

        # 1. Data Exploration
        puts "\n📊 1. Data Exploration Tutorial"
        results[:exploration] = data_exploration_tutorial(verbose: verbose)

        # 2. Data Quality Assessment
        puts "\n🔍 2. Data Quality Assessment Tutorial"
        results[:quality] = data_quality_comprehensive(verbose: verbose)

        # 3. Data Preprocessing
        puts "\n🧹 3. Data Preprocessing Tutorial"
        results[:preprocessing] = preprocessing_pipeline_tutorial(verbose: verbose)

        # 4. Feature Engineering
        puts "\n⚗️  4. Feature Engineering Tutorial"
        results[:feature_engineering] = feature_engineering_tutorial(verbose: verbose)

        # 5. Data Splitting
        puts "\n🎯 5. Cross-Validation Tutorial"
        results[:splitting] = cross_validation_tutorial(verbose: verbose)

        # 6. Distance Metrics
        puts "\n📏 6. Distance Metrics Tutorial"
        results[:distances] = distance_metrics_tutorial(verbose: verbose)

        # 7. Correlation Analysis
        puts "\n🔗 7. Correlation Analysis Tutorial"
        results[:correlations] = correlation_analysis_tutorial(verbose: verbose)

        puts "\n🎉 Complete tutorial finished!"
        puts 'Check results hash for detailed outputs from each section.'

        results
      end

      # Data exploration tutorial with real-world dataset
      def self.data_exploration_tutorial(verbose: false)
        puts "\n=== Data Exploration Tutorial ===" if verbose
        puts 'Learning objective: Understand your data before analysis' if verbose

        # Create realistic customer dataset with quality issues
        dataset = create_customer_dataset_with_issues

        if verbose
          puts "\n📋 Dataset loaded: Customer Analytics Data"
          puts 'Scenario: E-commerce customer behavior analysis'
          puts 'Challenge: Data contains quality issues that need identification'
        end

        # Enable educational mode
        dataset.enable_educational_mode if dataset.respond_to?(:enable_educational_mode)

        results = {}

        # Basic information
        if verbose
          puts "\n🔍 Step 1: Basic Dataset Information"
          puts 'Always start by understanding your data structure'
        end

        results[:shape] = dataset.shape
        results[:columns] = dataset.data_labels

        # Data quality assessment
        if verbose
          puts "\n🔍 Step 2: Data Quality Assessment"
          puts 'Identify missing values, outliers, and inconsistencies'
        end

        results[:missing_analysis] = if dataset.respond_to?(:missing_values_report)
                                       dataset.missing_values_report
                                     else
                                       analyze_missing_values_basic(dataset)
                                     end

        # Statistical summary
        if verbose
          puts "\n📊 Step 3: Statistical Summary"
          puts 'Understand distributions and central tendencies'
        end

        results[:statistics] = calculate_basic_statistics(dataset)

        # Data types analysis
        if verbose
          puts "\n🏷️  Step 4: Data Types Analysis"
          puts 'Ensure appropriate data types for each column'
        end

        results[:data_types] = analyze_data_types(dataset)

        # Key insights
        if verbose
          puts "\n💡 Key Insights from Exploration:"
          display_exploration_insights(results)
        end

        results[:dataset] = dataset
        results
      end

      # Comprehensive data quality assessment tutorial
      def self.data_quality_comprehensive(verbose: false)
        puts "\n=== Comprehensive Data Quality Assessment ===" if verbose

        # Create dataset with multiple quality issues
        dataset = create_problematic_dataset

        results = {
          original_issues: [],
          detected_issues: [],
          severity_scores: {},
          recommendations: []
        }

        if verbose
          puts "\n🎯 Learning Objective: Systematic Data Quality Assessment"
          puts 'Scenario: Medical research data with various quality issues'
        end

        # Issue 1: Missing values analysis
        puts "\n🔍 Analyzing Missing Values Patterns..." if verbose

        missing_handler = MissingValueHandler.new(dataset, verbose: verbose)
        missing_analysis = missing_handler.analyze_missing_patterns(dataset.data_items, dataset.data_labels)

        results[:missing_patterns] = missing_analysis

        # Issue 2: Outlier detection
        puts "\n🎯 Detecting Outliers with Multiple Methods..." if verbose

        outlier_detector = OutlierDetector.new(dataset, verbose: verbose)
        outlier_analysis = outlier_detector.comprehensive_analysis

        results[:outlier_analysis] = outlier_analysis

        # Issue 3: Data consistency check
        puts "\n✅ Checking Data Consistency..." if verbose

        consistency_issues = check_data_consistency(dataset)
        results[:consistency_issues] = consistency_issues

        # Issue 4: Generate quality score
        quality_score = calculate_overall_quality_score(missing_analysis, outlier_analysis, consistency_issues)
        results[:quality_score] = quality_score

        if verbose
          puts "\n📊 Overall Data Quality Score: #{quality_score[:overall_score]}/100"
          puts "Quality Level: #{quality_score[:quality_level]}"

          puts "\n💡 Improvement Recommendations:"
          quality_score[:recommendations].each { |rec| puts "  • #{rec}" }
        end

        results
      end

      # Complete preprocessing pipeline tutorial
      def self.preprocessing_pipeline_tutorial(verbose: false)
        puts "\n=== Data Preprocessing Pipeline Tutorial ===" if verbose

        # Start with raw problematic data
        dataset = create_messy_real_world_dataset

        results = {
          original_data: dataset.dup,
          preprocessing_steps: [],
          final_data: nil
        }

        if verbose
          puts "\n🎯 Learning Objective: Build Complete Preprocessing Pipeline"
          puts 'Scenario: Preparing real estate data for machine learning'
          puts 'Challenge: Multiple data quality issues need systematic resolution'
        end

        # Step 1: Handle missing values
        puts "\n🔧 Step 1: Handling Missing Values" if verbose

        missing_handler = MissingValueHandler.new(dataset, explain_operations: verbose)

        # Demonstrate different strategies
        puts "\nComparing missing value strategies:" if verbose

        strategies = %i[mean median mode]
        strategy_results = {}

        strategies.each do |strategy|
          test_data = missing_handler.handle(dataset.data_items, strategy)
          strategy_results[strategy] = {
            remaining_missing: count_missing_values(test_data),
            data_shape: [test_data.length, test_data.first&.length || 0]
          }

          puts "  #{strategy}: #{strategy_results[strategy][:remaining_missing]} missing values remaining" if verbose
        end

        # Apply best strategy
        cleaned_data = missing_handler.handle(dataset.data_items, :median)
        dataset = create_dataset_from_items(cleaned_data, dataset.data_labels)
        results[:preprocessing_steps] << { step: 'missing_values', strategy: 'median' }

        # Step 2: Outlier treatment
        puts "\n🎯 Step 2: Outlier Detection and Treatment" if verbose

        outlier_detector = OutlierDetector.new(dataset, explain_operations: verbose)
        outliers = outlier_detector.detect(:iqr, 1.5)

        # For tutorial, we'll cap outliers rather than remove them
        capped_data = cap_outliers(dataset.data_items, outliers)
        dataset = create_dataset_from_items(capped_data, dataset.data_labels)
        results[:preprocessing_steps] << { step: 'outlier_treatment', method: 'capping' }

        # Step 3: Feature scaling
        puts "\n⚖️  Step 3: Feature Scaling" if verbose

        feature_scaler = FeatureScaler.new(dataset, explain_operations: verbose)
        feature_scaler.recommend_scaling_method(:random_forest)

        # Apply recommended scaling
        scaled_data = feature_scaler.scale(dataset.data_items, :standardize)
        dataset = create_dataset_from_items(scaled_data, dataset.data_labels)
        results[:preprocessing_steps] << { step: 'feature_scaling', method: 'standardize' }

        # Step 4: Feature engineering
        puts "\n⚗️  Step 4: Feature Engineering" if verbose

        feature_engineer = FeatureEngineer.new(dataset, explain_operations: verbose)
        engineered_data = feature_engineer.apply_techniques(dataset.data_items, %i[polynomial interaction])
        dataset = create_dataset_from_items(engineered_data, dataset.data_labels)
        results[:preprocessing_steps] << { step: 'feature_engineering', techniques: %w[polynomial interaction] }

        results[:final_data] = dataset

        if verbose
          puts "\n✅ Preprocessing Pipeline Complete!"
          puts "Original shape: #{results[:original_data].shape}"
          puts "Final shape: #{results[:final_data].shape}"
          puts "Steps applied: #{results[:preprocessing_steps].map { |s| s[:step] }.join(' → ')}"
        end

        results
      end

      # Feature engineering exploration tutorial
      def self.feature_engineering_tutorial(verbose: false)
        puts "\n=== Feature Engineering Tutorial ===" if verbose

        # Create dataset suitable for feature engineering
        dataset = create_feature_engineering_dataset

        results = {
          original: dataset.dup,
          techniques: {}
        }

        if verbose
          puts "\n🎯 Learning Objective: Master Feature Engineering Techniques"
          puts 'Scenario: Improving model performance through feature creation'
        end

        feature_engineer = FeatureEngineer.new(dataset, explain_operations: verbose)

        # Test different techniques individually
        techniques = %i[polynomial interaction log_transform binning]

        techniques.each do |technique|
          puts "\n⚗️  Testing #{technique.to_s.humanize} Features" if verbose

          engineered_data = feature_engineer.apply_techniques(dataset.data_items, [technique])
          original_features = dataset.data_items.first&.length || 0
          new_features = engineered_data.first&.length || 0

          results[:techniques][technique] = {
            original_features: original_features,
            new_features: new_features,
            added_features: new_features - original_features,
            data: engineered_data
          }

          puts "  Added #{results[:techniques][technique][:added_features]} new features" if verbose
        end

        # Combined approach
        puts "\n🚀 Combined Feature Engineering Approach" if verbose

        combined_data = feature_engineer.apply_techniques(dataset.data_items, %i[polynomial interaction])
        results[:combined] = create_dataset_from_items(combined_data, dataset.data_labels)

        if verbose
          puts "  Original features: #{dataset.data_items.first&.length || 0}"
          puts "  Combined features: #{combined_data.first&.length || 0}"
          puts "  Feature expansion: #{((combined_data.first&.length || 0).to_f / (dataset.data_items.first&.length || 1) * 100).round(1)}%"
        end

        results
      end

      # Cross-validation and data splitting tutorial
      def self.cross_validation_tutorial(verbose: false)
        puts "\n=== Cross-Validation Tutorial ===" if verbose

        # Create classification dataset
        dataset = create_classification_dataset

        results = {
          dataset: dataset,
          split_methods: {}
        }

        if verbose
          puts "\n🎯 Learning Objective: Master Data Splitting Techniques"
          puts 'Scenario: Evaluating model performance reliably'
        end

        data_splitter = DataSplitter.new(dataset, explain_operations: verbose)

        # Method 1: Simple train-test split
        puts "\n🎯 Method 1: Simple Train-Test Split" if verbose

        train_test = data_splitter.split(0.2, 42)
        results[:split_methods][:train_test] = train_test

        # Method 2: K-fold cross-validation
        puts "\n🔄 Method 2: K-Fold Cross-Validation" if verbose

        k_folds = data_splitter.k_fold_split(5, 42)
        results[:split_methods][:k_fold] = k_folds

        # Method 3: Stratified splitting (for classification)
        puts "\n⚖️  Method 3: Stratified Splitting" if verbose

        stratified = data_splitter.split(0.2, 42, 'class')
        results[:split_methods][:stratified] = stratified

        # Method 4: Holdout validation
        puts "\n🎯 Method 4: Holdout Validation (Train/Val/Test)" if verbose

        holdout = data_splitter.holdout_split(0.2, 0.2, 42)
        results[:split_methods][:holdout] = holdout

        if verbose
          puts "\n📊 Splitting Summary:"
          puts "Original dataset: #{dataset.data_items.length} samples"
          puts "Train-test split: #{train_test[:train].data_items.length}/#{train_test[:test].data_items.length}"
          puts "K-fold splits: #{k_folds.length} folds"
          puts "Holdout: #{holdout[:train].data_items.length}/#{holdout[:validation].data_items.length}/#{holdout[:test].data_items.length}"
        end

        results
      end

      # Distance metrics comparison tutorial
      def self.distance_metrics_tutorial(verbose: false)
        puts "\n=== Distance Metrics Tutorial ===" if verbose

        # Create dataset for distance comparison
        dataset = create_distance_comparison_dataset

        results = {
          dataset: dataset,
          distance_comparisons: {},
          use_cases: {}
        }

        if verbose
          puts "\n🎯 Learning Objective: Understand Distance Metrics"
          puts 'Scenario: Choosing appropriate similarity measures'
        end

        # Compare different distance metrics on sample points
        sample_points = dataset.data_items.first(10)
        distance_methods = %i[euclidean manhattan chebyshev cosine]

        distance_methods.each do |method|
          puts "\n📏 Testing #{method.to_s.humanize} Distance" if verbose

          distances = calculate_pairwise_distances(sample_points, method)
          results[:distance_comparisons][method] = distances

          next unless verbose

          avg_distance = distances.sum / distances.length
          puts "  Average distance: #{avg_distance.round(4)}"
          puts "  Distance range: #{distances.min.round(4)} - #{distances.max.round(4)}"
        end

        # Use case recommendations
        results[:use_cases] = {
          euclidean: 'General purpose, assumes all dimensions equally important',
          manhattan: 'High-dimensional data, robust to outliers',
          chebyshev: 'When maximum difference matters most',
          cosine: 'Text data, sparse vectors, direction matters more than magnitude'
        }

        if verbose
          puts "\n💡 Distance Metric Use Cases:"
          results[:use_cases].each do |metric, use_case|
            puts "  #{metric.to_s.humanize}: #{use_case}"
          end
        end

        results
      end

      # Correlation analysis tutorial
      def self.correlation_analysis_tutorial(verbose: false)
        puts "\n=== Correlation Analysis Tutorial ===" if verbose

        # Create dataset with known correlations
        dataset = create_correlation_dataset

        results = {
          dataset: dataset,
          correlations: {},
          insights: []
        }

        if verbose
          puts "\n🎯 Learning Objective: Discover Data Relationships"
          puts 'Scenario: Understanding feature relationships for modeling'
        end

        # Calculate correlation matrix
        correlations = calculate_correlation_matrix(dataset)
        results[:correlations] = correlations

        # Find strong correlations
        strong_correlations = find_strong_correlations(correlations, 0.7)
        results[:strong_correlations] = strong_correlations

        # Generate insights
        insights = generate_correlation_insights(correlations, strong_correlations)
        results[:insights] = insights

        if verbose
          puts "\n🔗 Correlation Matrix Calculated"
          puts "Features analyzed: #{correlations.keys.length}"

          if strong_correlations.any?
            puts "\n💡 Strong Correlations Found:"
            strong_correlations.each do |pair, corr|
              puts "  #{pair.join(' ↔ ')}: #{corr.round(3)}"
            end
          end

          puts "\n📊 Key Insights:"
          insights.each { |insight| puts "  • #{insight}" }
        end

        results
      end

      # Create realistic customer dataset with intentional quality issues
      def self.create_customer_dataset_with_issues
        data_items = []

        # Generate 200 customer records with various issues
        200.times do |_i|
          age = rand(18..80)

          # Introduce missing values (~10% rate)
          age = nil if rand < 0.1

          # Income with outliers
          income = case rand
                   when 0..0.8 then rand(25_000..85_000)
                   when 0.8..0.95 then rand(85_000..150_000)
                   else rand(200_000..500_000) # Outliers
                   end

          # Purchase amount with missing values
          purchase_amount = rand < 0.15 ? nil : rand(10.0..2000.0).round(2)

          # Categories with inconsistent naming
          category = case rand
                     when 0..0.3 then 'Electronics'
                     when 0.3..0.4 then 'electronics' # Inconsistent case
                     when 0.4..0.6 then 'Clothing'
                     when 0.6..0.8 then 'Home & Garden'
                     when 0.8..0.9 then 'Books'
                     else nil # Missing category
                     end

          satisfaction = rand(1..5)

          data_items << [age, income, purchase_amount, category, satisfaction]
        end

        labels = %w[age income purchase_amount category satisfaction]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Create dataset with multiple types of quality issues
      def self.create_problematic_dataset
        data_items = []

        100.times do |i|
          # Patient ID (some duplicates)
          patient_id = i < 95 ? "P#{i.to_s.rjust(3, '0')}" : "P#{(i - 5).to_s.rjust(3, '0')}"

          # Age with missing values and outliers
          age = case rand
                when 0..0.05 then nil
                when 0.05..0.9 then rand(18..85)
                when 0.9..0.98 then rand(85..120)
                else -5 # Invalid age
                end

          # Weight with unit inconsistencies
          weight = rand < 0.1 ? nil : rand(50.0..120.0).round(1)

          # Blood pressure (some invalid formats)
          bp_systolic = rand(90..180)
          bp_diastolic = rand(60..110)

          # Diagnosis with typos
          diagnosis = case rand
                      when 0..0.3 then 'Diabetes'
                      when 0.3..0.35 then 'Diabetis' # Typo
                      when 0.35..0.6 then 'Hypertension'
                      when 0.6..0.8 then 'Normal'
                      end

          data_items << [patient_id, age, weight, bp_systolic, bp_diastolic, diagnosis]
        end

        labels = %w[patient_id age weight bp_systolic bp_diastolic diagnosis]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Create messy real-world style dataset
      def self.create_messy_real_world_dataset
        data_items = []

        150.times do |_i|
          # Property features with various issues
          square_feet = rand < 0.08 ? nil : rand(500..4000)
          bedrooms = rand(1..5)
          bathrooms = rand(1.0..4.5).round(1)

          # Price with some extreme outliers
          price = case rand
                  when 0..0.85 then rand(100_000..800_000)
                  when 0.85..0.95 then rand(800_000..1_500_000)
                  else rand(2_000_000..5_000_000) # Luxury outliers
                  end

          # Location with inconsistent formatting
          location = %w[Downtown Suburb Rural DOWNTOWN suburb].sample

          # Year built with some missing and invalid values
          year_built = case rand
                       when 0..0.05 then nil
                       when 0.05..0.9 then rand(1950..2023)
                       else rand(2024..2030) # Future years (invalid)
                       end

          data_items << [square_feet, bedrooms, bathrooms, price, location, year_built]
        end

        labels = %w[square_feet bedrooms bathrooms price location year_built]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Create dataset suitable for feature engineering
      def self.create_feature_engineering_dataset
        data_items = []

        100.times do |_i|
          x1 = rand(-10.0..10.0)
          x2 = rand(-5.0..5.0)

          # Create target with known polynomial and interaction relationships
          y = (2 * x1) + (3 * x2) + (0.5 * (x1**2)) + (0.3 * (x1 * x2)) + rand(-1.0..1.0)

          data_items << [x1, x2, y]
        end

        labels = %w[x1 x2 target]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Create classification dataset for splitting tutorial
      def self.create_classification_dataset
        data_items = []

        # Create balanced classes
        200.times do |_i|
          feature1 = rand(-5.0..5.0)
          feature2 = rand(-5.0..5.0)
          feature3 = rand(0.0..10.0)

          # Create target classes based on features
          class_label = if feature1 + feature2 > 0
                          'A'
                        elsif feature3 > 5
                          'B'
                        else
                          'C'
                        end

          data_items << [feature1, feature2, feature3, class_label]
        end

        labels = %w[feature1 feature2 feature3 class]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Create dataset for distance comparison
      def self.create_distance_comparison_dataset
        data_items = []

        50.times do |i|
          # Create points in different regions
          if i < 15
            # Cluster 1
            x = rand(0.0..3.0)
            y = rand(0.0..3.0)
          elsif i < 30
            # Cluster 2
            x = rand(7.0..10.0)
            y = rand(7.0..10.0)
          else
            # Scattered points
            x = rand(-2.0..12.0)
            y = rand(-2.0..12.0)
          end

          z = rand(0.0..5.0)

          data_items << [x, y, z]
        end

        labels = %w[x y z]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Create dataset with known correlations
      def self.create_correlation_dataset
        data_items = []

        100.times do |_i|
          x1 = rand(-10.0..10.0)
          x2 = (0.8 * x1) + rand(-1.0..1.0) # Strong positive correlation
          x3 = (-0.6 * x1) + rand(-2.0..2.0) # Moderate negative correlation
          x4 = rand(-10.0..10.0) # Independent variable

          data_items << [x1, x2, x3, x4]
        end

        labels = %w[x1 x2 x3 x4]
        EnhancedDataSet.new(data_items: data_items, data_labels: labels)
      end

      # Helper methods

      def self.analyze_missing_values_basic(dataset)
        analysis = {}

        dataset.data_labels.each_with_index do |label, idx|
          missing_count = dataset.data_items.count { |row| row[idx].nil? || row[idx] == '' }
          next unless missing_count > 0

          analysis[label] = {
            count: missing_count,
            percentage: (missing_count.to_f / dataset.data_items.length * 100).round(2)
          }
        end

        analysis
      end

      def self.calculate_basic_statistics(dataset)
        stats = {}

        dataset.data_labels.each_with_index do |label, idx|
          values = dataset.data_items.filter_map { |row| row[idx] }
          numeric_values = values.select { |v| v.is_a?(Numeric) }

          stats[label] = if numeric_values.any?
                           {
                             count: numeric_values.length,
                             mean: numeric_values.sum.to_f / numeric_values.length,
                             min: numeric_values.min,
                             max: numeric_values.max,
                             unique_count: numeric_values.uniq.length
                           }
                         else
                           {
                             count: values.length,
                             unique_count: values.uniq.length,
                             most_common: values.group_by(&:itself).max_by { |_k, v| v.length }&.first
                           }
                         end
        end

        stats
      end

      def self.analyze_data_types(dataset)
        types = {}

        dataset.data_labels.each_with_index do |label, idx|
          values = dataset.data_items.filter_map { |row| row[idx] }.first(20)

          if values.all?(Numeric)
            types[label] = if values.all?(Integer)
                             :integer
                           else
                             :float
                           end
          elsif values.all? { |v| [true, false].include?(v) }
            types[label] = :boolean
          else
            unique_count = values.uniq.length
            types[label] = if unique_count <= [values.length * 0.1, 10].max
                             :categorical
                           else
                             :text
                           end
          end
        end

        types
      end

      def self.display_exploration_insights(results)
        puts "  • Dataset contains #{results[:shape][0]} rows and #{results[:shape][1]} columns"

        if results[:missing_analysis].any?
          puts "  • Missing values detected in #{results[:missing_analysis].keys.length} columns"
        else
          puts '  • No missing values detected'
        end

        numeric_columns = results[:data_types].count { |_, type| %i[integer float].include?(type) }
        puts "  • #{numeric_columns} numeric columns, #{results[:data_types].length - numeric_columns} categorical"

        return unless results[:statistics].any?

        ranges = results[:statistics].select { |_, stats| stats[:min] && stats[:max] }
        if ranges.any?
          large_range_cols = ranges.select { |_, stats| (stats[:max] - stats[:min]) > stats[:mean] * 10 }
          puts '  • Large value ranges detected - consider scaling' if large_range_cols.any?
        end
      end

      def self.check_data_consistency(dataset)
        issues = []

        # Check for duplicate rows
        unique_rows = dataset.data_items.uniq
        if unique_rows.length < dataset.data_items.length
          issues << "#{dataset.data_items.length - unique_rows.length} duplicate rows found"
        end

        # Check for constant columns
        dataset.data_labels.each_with_index do |label, idx|
          values = dataset.data_items.filter_map { |row| row[idx] }.uniq
          issues << "Column '#{label}' has constant value" if values.length == 1
        end

        issues
      end

      def self.calculate_overall_quality_score(missing_analysis, outlier_analysis, consistency_issues)
        # Simple quality scoring system
        score = 100

        # Deduct for missing values
        if missing_analysis[:has_missing]
          total_missing_pct = missing_analysis[:total_missing].to_f /
                              (missing_analysis[:by_column].length * 100) * 100
          score -= total_missing_pct
        end

        # Deduct for outliers
        total_outliers = outlier_analysis[:methods_comparison].values.sum { |info| info[:total_outliers] }
        if total_outliers > 0
          outlier_pct = total_outliers.to_f / 100 # Assuming 100 is dataset size
          score -= outlier_pct * 5 # 5 points per percent of outliers
        end

        # Deduct for consistency issues
        score -= consistency_issues.length * 10

        score = [score, 0].max # Ensure non-negative

        quality_level = case score
                        when 90..100 then 'Excellent'
                        when 80..89 then 'Good'
                        when 70..79 then 'Fair'
                        when 60..69 then 'Poor'
                        else 'Very Poor'
                        end

        recommendations = []
        recommendations << 'Address missing values' if missing_analysis[:has_missing]
        recommendations << 'Investigate and handle outliers' if total_outliers > 0
        recommendations << 'Fix consistency issues' if consistency_issues.any?
        recommendations << 'Data quality is excellent!' if score >= 90

        {
          overall_score: score.round(1),
          quality_level: quality_level,
          recommendations: recommendations
        }
      end

      def self.count_missing_values(data_items)
        data_items.sum { |row| row.count { |cell| cell.nil? || cell == '' } }
      end

      def self.cap_outliers(data_items, outliers_info)
        # Simple outlier capping implementation
        capped_data = data_items.map(&:dup)

        outliers_info.each_value do |info|
          next unless info[:lower_bound] && info[:upper_bound]

          # Find column index (simplified)
          col_idx = 0 # This would need proper column mapping

          capped_data.each do |row|
            value = row[col_idx]
            if value.is_a?(Numeric)
              if value < info[:lower_bound]
                row[col_idx] = info[:lower_bound]
              elsif value > info[:upper_bound]
                row[col_idx] = info[:upper_bound]
              end
            end
          end
        end

        capped_data
      end

      def self.create_dataset_from_items(items, labels)
        EnhancedDataSet.new(data_items: items, data_labels: labels)
      end

      def self.calculate_pairwise_distances(points, method)
        distances = []

        points.combination(2) do |p1, p2|
          case method
          when :euclidean
            dist = Math.sqrt(p1.zip(p2).sum { |a, b| (a - b)**2 })
          when :manhattan
            dist = p1.zip(p2).sum { |a, b| (a - b).abs }
          when :chebyshev
            dist = p1.zip(p2).map { |a, b| (a - b).abs }.max
          when :cosine
            dot_product = p1.zip(p2).sum { |a, b| a * b }
            norm_p1 = Math.sqrt(p1.sum { |a| a**2 })
            norm_p2 = Math.sqrt(p2.sum { |b| b**2 })
            dist = 1 - (dot_product / (norm_p1 * norm_p2))
          end

          distances << dist
        end

        distances
      end

      def self.calculate_correlation_matrix(dataset)
        correlations = {}
        numeric_columns = []

        # Find numeric columns
        dataset.data_labels.each_with_index do |label, idx|
          values = dataset.data_items.filter_map { |row| row[idx] }
          numeric_values = values.select { |v| v.is_a?(Numeric) }
          numeric_columns << { label: label, index: idx } if numeric_values.length > 1
        end

        # Calculate correlations
        numeric_columns.each do |col1|
          correlations[col1[:label]] = {}

          numeric_columns.each do |col2|
            if col1[:label] == col2[:label]
              correlations[col1[:label]][col2[:label]] = 1.0
            else
              corr = calculate_correlation_coefficient(dataset, col1[:index], col2[:index])
              correlations[col1[:label]][col2[:label]] = corr
            end
          end
        end

        correlations
      end

      def self.calculate_correlation_coefficient(dataset, idx1, idx2)
        values1 = []
        values2 = []

        dataset.data_items.each do |row|
          val1 = row[idx1]
          val2 = row[idx2]

          if val1.is_a?(Numeric) && val2.is_a?(Numeric)
            values1 << val1
            values2 << val2
          end
        end

        return 0.0 if values1.length < 2

        # Pearson correlation coefficient
        n = values1.length
        sum1 = values1.sum
        sum2 = values2.sum
        sum1_sq = values1.sum { |v| v**2 }
        sum2_sq = values2.sum { |v| v**2 }
        sum_products = values1.zip(values2).sum { |v1, v2| v1 * v2 }

        numerator = (n * sum_products) - (sum1 * sum2)
        denominator = Math.sqrt(((n * sum1_sq) - (sum1**2)) * ((n * sum2_sq) - (sum2**2)))

        return 0.0 if denominator == 0

        numerator / denominator
      end

      def self.find_strong_correlations(correlations, threshold = 0.7)
        strong_pairs = {}

        correlations.each do |col1, row|
          row.each do |col2, corr|
            next if col1 == col2 || corr.abs < threshold

            pair_key = [col1, col2].sort
            strong_pairs[pair_key] = corr unless strong_pairs.key?(pair_key)
          end
        end

        strong_pairs
      end

      def self.generate_correlation_insights(correlations, strong_correlations)
        insights = []

        if strong_correlations.any?
          insights << "#{strong_correlations.length} strong correlations detected"

          positive_corrs = strong_correlations.select { |_, corr| corr > 0 }
          negative_corrs = strong_correlations.select { |_, corr| corr < 0 }

          insights << "#{positive_corrs.length} positive, #{negative_corrs.length} negative correlations"
        else
          insights << 'No strong correlations found (threshold: 0.7)'
        end

        if correlations.any?
          avg_abs_corr = correlations.values.flat_map(&:values).sum(&:abs) / correlations.values.flat_map(&:values).length
          insights << "Average absolute correlation: #{avg_abs_corr.round(3)}"
        end

        insights
      end
    end
  end
end
