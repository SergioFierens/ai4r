# frozen_string_literal: true

#
# AI4R Classifier Benchmarking System
#
# A comprehensive framework for comparing classification algorithms with educational insights.
# Designed to help students understand the strengths, weaknesses, and characteristics of
# different AI classification approaches through hands-on experimentation.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# "In the grand arena of machine learning, every classifier has its moment to shine.
#  The trick is knowing which spotlight to use." - Anonymous Data Scientist
#

require_relative '../../data/data_set'
require_relative '../../classifiers/classifier'
require 'benchmark'
require 'set'

module Ai4r
  module Experiment
    #
    # ClassifierBench: The Ultimate Classifier Showdown Arena 🏟️
    #
    # This class provides a comprehensive benchmarking framework for comparing
    # different classification algorithms. It's designed with education in mind,
    # offering detailed insights into algorithm performance, characteristics,
    # and trade-offs.
    #
    # == Features:
    # * Side-by-side algorithm comparison
    # * Performance metrics (accuracy, precision, recall, F1)
    # * Training and prediction time measurement
    # * Cross-validation support
    # * Confusion matrix generation
    # * Algorithm complexity analysis
    # * Visual performance reports
    # * Educational insights and explanations
    #
    # == Example:
    #   # Create a benchmark
    #   bench = ClassifierBench.new(verbose: true)
    #
    #   # Add classifiers to compare
    #   bench.add_classifier(:decision_tree, Ai4r::Classifiers::ID3.new)
    #   bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)
    #   bench.add_classifier(:neural_net, Ai4r::Classifiers::MultilayerPerceptron.new([4, 8, 3]))
    #
    #   # Run the benchmark
    #   results = bench.run(iris_dataset)
    #
    #   # Display results
    #   bench.display_results(results)
    #
    #   # Get educational insights
    #   insights = bench.generate_insights(results)
    #   puts insights
    #
    class ClassifierBench
      attr_accessor :classifiers, :verbose, :cross_validation_folds
      attr_reader :results, :dataset_characteristics

      # Initialize a new classifier benchmark
      #
      # @param options [Hash] Configuration options
      # @option options [Boolean] :verbose (false) Enable detailed output
      # @option options [Integer] :cross_validation_folds (5) Number of CV folds
      # @option options [Boolean] :stratified (true) Use stratified sampling
      # @option options [Boolean] :educational_mode (true) Include educational insights
      def initialize(options = {})
        @classifiers = {}
        @verbose = options.fetch(:verbose, false)
        @cross_validation_folds = options.fetch(:cross_validation_folds, 5)
        @stratified = options.fetch(:stratified, true)
        @educational_mode = options.fetch(:educational_mode, true)
        @results = {}
        @dataset_characteristics = {}
      end

      # Add a classifier to the benchmark
      #
      # @param name [Symbol] Unique identifier for the classifier
      # @param classifier [Classifier] The classifier instance
      # @param options [Hash] Classifier-specific options
      def add_classifier(name, classifier, options = {})
        unless classifier.respond_to?(:build) && classifier.respond_to?(:eval)
          raise ArgumentError, 'Classifier must implement build and eval methods'
        end

        @classifiers[name] = {
          instance: classifier,
          options: options,
          friendly_name: options[:friendly_name] || name.to_s.split('_').map(&:capitalize).join(' ')
        }

        log "Added classifier: #{@classifiers[name][:friendly_name]}"
      end

      # Run the benchmark on a dataset
      #
      # @param dataset [DataSet] The dataset to use for benchmarking
      # @param options [Hash] Runtime options
      # @return [Hash] Comprehensive results for all classifiers
      def run(dataset, options = {})
        validate_dataset(dataset)
        analyze_dataset(dataset)

        log "\n🏁 Starting Classifier Benchmark Showdown! 🏁"
        log "Dataset: #{dataset.data_items.size} samples, #{dataset.data_labels.size - 1} features"
        log "Classes: #{@dataset_characteristics[:classes].to_a.join(', ')}"
        log '-' * 60

        @results = {}

        @classifiers.each do |name, classifier_info|
          log "\n📊 Benchmarking #{classifier_info[:friendly_name]}..."
          @results[name] = benchmark_classifier(
            name,
            classifier_info[:instance],
            dataset,
            options.merge(classifier_info[:options])
          )

          display_progress_insights(name, @results[name]) if @educational_mode
        end

        @results
      end

      # Display comprehensive results
      #
      # @param results [Hash] Results from run method (optional, uses @results if nil)
      def display_results(results = nil)
        results ||= @results

        puts "\n#{'=' * 80}"
        puts '🏆 CLASSIFIER BENCHMARK RESULTS 🏆'.center(80)
        puts '=' * 80

        display_accuracy_comparison(results)
        display_performance_comparison(results)
        display_timing_comparison(results)

        if @educational_mode
          display_winner_analysis(results)
          display_recommendations(results)
        end
      end

      # Generate educational insights about the results
      #
      # @param results [Hash] Results from run method
      # @return [String] Formatted insights text
      def generate_insights(results = nil)
        results ||= @results
        insights = []

        insights << "\n🎓 EDUCATIONAL INSIGHTS 🎓\n"
        insights << "#{'=' * 60}\n"

        # Dataset insights
        insights << "\n📊 Dataset Characteristics:"
        insights << "  • Balance: #{@dataset_characteristics[:balance]}"
        insights << "  • Complexity: #{@dataset_characteristics[:complexity]}"
        insights << "  • Feature types: #{@dataset_characteristics[:feature_types]}"

        # Algorithm insights
        insights << "\n🤖 Algorithm Observations:"
        results.each do |name, result|
          insights << "\n#{@classifiers[name][:friendly_name]}:"
          insights.concat(generate_classifier_insights(name, result))
        end

        # Comparative insights
        insights << "\n🔍 Comparative Analysis:"
        insights.concat(generate_comparative_insights(results))

        # Learning recommendations
        insights << "\n📚 Learning Recommendations:"
        insights.concat(generate_learning_recommendations(results))

        insights.join("\n")
      end

      # Export results to various formats
      #
      # @param format [Symbol] Output format (:csv, :json, :html)
      # @param filename [String] Output filename
      def export_results(format = :csv, filename = 'classifier_bench_results')
        case format
        when :csv
          export_to_csv(filename)
        when :json
          export_to_json(filename)
        when :html
          export_to_html(filename)
        else
          raise ArgumentError, "Unsupported format: #{format}"
        end
      end

      private

      # Validate dataset is suitable for benchmarking
      def validate_dataset(dataset)
        raise ArgumentError, 'Dataset cannot be nil' if dataset.nil?
        raise ArgumentError, 'Dataset must be a DataSet instance' unless dataset.is_a?(Ai4r::Data::DataSet)
        raise ArgumentError, 'Dataset cannot be empty' if dataset.data_items.empty?
        raise ArgumentError, 'Dataset must have at least 2 classes' if get_classes(dataset).size < 2
      end

      # Analyze dataset characteristics
      def analyze_dataset(dataset)
        classes = get_classes(dataset)
        class_distribution = calculate_class_distribution(dataset)

        @dataset_characteristics = {
          classes: classes,
          num_classes: classes.size,
          num_features: dataset.data_labels.size - 1,
          num_samples: dataset.data_items.size,
          class_distribution: class_distribution,
          balance: assess_balance(class_distribution),
          complexity: assess_complexity(dataset),
          feature_types: detect_feature_types(dataset)
        }
      end

      # Benchmark a single classifier
      def benchmark_classifier(name, classifier, dataset, _options = {})
        results = {
          metrics: {},
          confusion_matrix: {},
          timing: {},
          errors: [],
          cv_scores: []
        }

        # Check compatibility with numeric data
        if has_numeric_features?(dataset) && !supports_numeric_features?(classifier)
          log "Warning: #{name} may not work well with numeric features"
          results[:errors] << { type: :compatibility_warning,
                                message: 'Classifier may not handle numeric features well' }
        end

        # Perform cross-validation
        cv_results = cross_validate(classifier, dataset, @cross_validation_folds)

        # Aggregate results
        results[:metrics] = calculate_average_metrics(cv_results)
        results[:confusion_matrix] = cv_results.last[:confusion_matrix] # Use last fold as example
        results[:timing] = {
          avg_training_time: cv_results.sum { |r| r[:training_time] } / cv_results.size,
          avg_prediction_time: cv_results.sum { |r| r[:prediction_time] } / cv_results.size,
          total_time: cv_results.sum { |r| r[:training_time] + r[:prediction_time] }
        }
        results[:cv_scores] = cv_results.map { |r| r[:metrics][:accuracy] }
        results[:errors] = analyze_errors(cv_results)

        results
      rescue StandardError => e
        log "Error benchmarking #{name}: #{e.message}"
        results[:errors] << { type: :benchmark_error, message: e.message }
        results
      end

      # Perform k-fold cross-validation
      def cross_validate(classifier, dataset, k)
        folds = create_folds(dataset, k)
        cv_results = []

        folds.each_with_index do |test_fold, i|
          train_data = merge_folds(folds - [test_fold])
          test_data = test_fold

          # Clone classifier for this fold
          fold_classifier = clone_classifier(classifier)

          # Train
          training_start = Time.now
          fold_classifier.build(train_data)
          training_time = Time.now - training_start

          # Test
          predictions = []
          actuals = []
          prediction_start = Time.now

          test_data.data_items.each do |item|
            features = item[0...-1]
            actual = item.last
            predicted = fold_classifier.eval(features)

            predictions << predicted
            actuals << actual
          end

          prediction_time = Time.now - prediction_start

          # Calculate metrics
          cv_results << {
            fold: i + 1,
            metrics: calculate_metrics(actuals, predictions),
            confusion_matrix: build_confusion_matrix(actuals, predictions),
            training_time: training_time,
            prediction_time: prediction_time
          }
        end

        cv_results
      end

      # Create stratified folds for cross-validation
      def create_folds(dataset, k)
        if @stratified
          create_stratified_folds(dataset, k)
        else
          create_random_folds(dataset, k)
        end
      end

      # Create stratified folds maintaining class distribution
      def create_stratified_folds(dataset, k)
        # Group items by class
        class_groups = {}
        dataset.data_items.each_with_index do |item, idx|
          class_label = item.last
          class_groups[class_label] ||= []
          class_groups[class_label] << idx
        end

        # Shuffle within each class
        class_groups.each_value(&:shuffle!)

        # Distribute to folds
        folds = Array.new(k) { [] }
        class_groups.each_value do |indices|
          indices.each_with_index do |idx, i|
            folds[i % k] << dataset.data_items[idx]
          end
        end

        # Convert to DataSet objects
        folds.map do |fold_items|
          Ai4r::Data::DataSet.new(
            data_labels: dataset.data_labels.dup,
            data_items: fold_items
          )
        end
      end

      # Create random folds
      def create_random_folds(dataset, k)
        shuffled = dataset.data_items.shuffle
        fold_size = (shuffled.size / k.to_f).ceil

        shuffled.each_slice(fold_size).map do |fold_items|
          Ai4r::Data::DataSet.new(
            data_labels: dataset.data_labels.dup,
            data_items: fold_items
          )
        end
      end

      # Merge multiple folds into one dataset
      def merge_folds(folds)
        all_items = folds.flat_map(&:data_items)
        Ai4r::Data::DataSet.new(
          data_labels: folds.first.data_labels.dup,
          data_items: all_items
        )
      end

      # Clone a classifier (simple approach)
      def clone_classifier(classifier)
        # This is a simple approach - ideally classifiers would implement deep_clone
        classifier.class.new
      rescue StandardError
        # If simple instantiation fails, try with common parameters
        classifier_class_name = classifier.class.name.split('::').last

        if classifier_class_name == 'MultilayerPerceptron'
          # For neural networks, preserve architecture
          if classifier.instance_variable_get(:@structure)
            classifier.class.new(classifier.instance_variable_get(:@structure))
          else
            classifier.class.new([4, 8, 3]) # Default structure
          end
        elsif classifier_class_name == 'NaiveBayes'
          # NaiveBayes might have a parameter for m-estimates
          classifier.class.new(0)
        else
          classifier.class.new
        end
      end

      # Calculate classification metrics
      def calculate_metrics(actuals, predictions)
        classes = (actuals + predictions).uniq

        # Overall metrics
        correct = actuals.zip(predictions).count { |a, p| a == p }
        total = actuals.size
        accuracy = total > 0 ? correct.to_f / total : 0.0

        # Per-class metrics
        class_metrics = {}
        classes.each do |cls|
          tp = actuals.zip(predictions).count { |a, p| a == cls && p == cls }
          fp = actuals.zip(predictions).count { |a, p| a != cls && p == cls }
          fn = actuals.zip(predictions).count { |a, p| a == cls && p != cls }
          actuals.zip(predictions).count { |a, p| a != cls && p != cls }

          precision = (tp + fp) > 0 ? tp.to_f / (tp + fp) : 0.0
          recall = (tp + fn) > 0 ? tp.to_f / (tp + fn) : 0.0
          f1 = (precision + recall) > 0 ? 2 * precision * recall / (precision + recall) : 0.0

          class_metrics[cls] = {
            precision: precision,
            recall: recall,
            f1_score: f1,
            support: actuals.count(cls)
          }
        end

        # Macro averages
        macro_precision = class_metrics.values.sum { |m| m[:precision] } / classes.size
        macro_recall = class_metrics.values.sum { |m| m[:recall] } / classes.size
        macro_f1 = class_metrics.values.sum { |m| m[:f1_score] } / classes.size

        # Weighted averages
        total_support = class_metrics.values.sum { |m| m[:support] }
        weighted_precision = class_metrics.sum { |_c, m| m[:precision] * m[:support] } / total_support
        weighted_recall = class_metrics.sum { |_c, m| m[:recall] * m[:support] } / total_support
        weighted_f1 = class_metrics.sum { |_c, m| m[:f1_score] * m[:support] } / total_support

        {
          accuracy: accuracy,
          macro_precision: macro_precision,
          macro_recall: macro_recall,
          macro_f1: macro_f1,
          weighted_precision: weighted_precision,
          weighted_recall: weighted_recall,
          weighted_f1: weighted_f1,
          class_metrics: class_metrics
        }
      end

      # Build confusion matrix
      def build_confusion_matrix(actuals, predictions)
        classes = (actuals + predictions).uniq.sort
        matrix = {}

        classes.each do |actual_class|
          matrix[actual_class] = {}
          classes.each do |predicted_class|
            count = actuals.zip(predictions).count do |a, p|
              a == actual_class && p == predicted_class
            end
            matrix[actual_class][predicted_class] = count
          end
        end

        matrix
      end

      # Calculate average metrics across CV folds
      def calculate_average_metrics(cv_results)
        return {} if cv_results.empty?

        # Get all metric keys from first result
        metric_keys = cv_results.first[:metrics].keys - [:class_metrics]

        avg_metrics = {}
        metric_keys.each do |key|
          values = cv_results.map { |r| r[:metrics][key] }
          avg_metrics[key] = values.sum / values.size
          avg_metrics["#{key}_std"] = calculate_std_dev(values)
        end

        avg_metrics
      end

      # Calculate standard deviation
      def calculate_std_dev(values)
        return 0.0 if values.size <= 1

        mean = values.sum / values.size.to_f
        variance = values.sum { |v| (v - mean)**2 } / (values.size - 1)
        Math.sqrt(variance)
      end

      # Analyze errors across folds
      def analyze_errors(_cv_results)
        # This would analyze common misclassifications
        # For now, return empty array
        []
      end

      # Get unique classes from dataset
      def get_classes(dataset)
        dataset.data_items.map(&:last).uniq.to_set
      end

      # Calculate class distribution
      def calculate_class_distribution(dataset)
        distribution = Hash.new(0)
        dataset.data_items.each { |item| distribution[item.last] += 1 }
        total = dataset.data_items.size

        distribution.transform_values { |count| count.to_f / total }
      end

      # Assess dataset balance
      def assess_balance(distribution)
        return :empty if distribution.empty?

        max_ratio = distribution.values.max
        min_ratio = distribution.values.min

        if max_ratio / min_ratio > 3
          :imbalanced
        elsif max_ratio / min_ratio > 1.5
          :slightly_imbalanced
        else
          :balanced
        end
      end

      # Assess dataset complexity
      def assess_complexity(dataset)
        # Simple heuristic based on features and samples
        n_features = dataset.data_labels.size - 1
        n_samples = dataset.data_items.size
        n_classes = get_classes(dataset).size

        complexity_score = (n_features * n_classes) / Math.log(n_samples + 1)

        if complexity_score > 10
          :high
        elsif complexity_score > 5
          :medium
        else
          :low
        end
      end

      # Detect feature types
      def detect_feature_types(dataset)
        return :empty if dataset.data_items.empty?

        # Sample first few items
        sample_size = [10, dataset.data_items.size].min
        samples = dataset.data_items.first(sample_size)

        feature_types = []
        (0...(dataset.data_labels.size - 1)).each do |i|
          values = samples.map { |item| item[i] }

          if values.all?(Numeric)
            feature_types << :numeric
          elsif values.all? { |v| v.is_a?(String) || v.is_a?(Symbol) }
            unique_ratio = values.uniq.size.to_f / values.size
            feature_types << (unique_ratio < 0.5 ? :categorical : :text)
          else
            feature_types << :mixed
          end
        end

        # Return summary
        if feature_types.all?(:numeric)
          :all_numeric
        elsif feature_types.all?(:categorical)
          :all_categorical
        else
          :mixed
        end
      end

      # Display accuracy comparison
      def display_accuracy_comparison(results)
        puts "\n📊 Accuracy Comparison:"
        puts '-' * 60

        # Sort by accuracy
        sorted_results = results.sort_by { |_, r| -r[:metrics][:accuracy] }

        sorted_results.each_with_index do |(name, result), idx|
          accuracy = result[:metrics][:accuracy]
          std = result[:metrics][:accuracy_std] || 0.0
          bar_length = (accuracy * 40).to_i

          trophy = if idx == 0
                     '🥇'
                   else
                     (if idx == 1
                        '🥈'
                      else
                        (idx == 2 ? '🥉' : '  ')
                      end)
                   end

          puts format('%s %-20s %s %.1f%% (±%.1f%%)',
                      trophy,
                      @classifiers[name][:friendly_name],
                      ('█' * bar_length) + ('░' * (40 - bar_length)),
                      accuracy * 100,
                      std * 100)
        end
      end

      # Display performance metrics comparison
      def display_performance_comparison(results)
        puts "\n📈 Performance Metrics:"
        puts '-' * 80
        puts 'Classifier            Precision     Recall   F1-Score   Accuracy'
        puts '-' * 80

        results.each do |name, result|
          puts format('%-20s %10.3f %10.3f %10.3f %10.3f',
                      @classifiers[name][:friendly_name],
                      result[:metrics][:weighted_precision] || 0.0,
                      result[:metrics][:weighted_recall] || 0.0,
                      result[:metrics][:weighted_f1] || 0.0,
                      result[:metrics][:accuracy] || 0.0)
        end
      end

      # Display timing comparison
      def display_timing_comparison(results)
        puts "\n⏱️  Speed Comparison:"
        puts '-' * 60

        # Sort by total time
        sorted_results = results.sort_by { |_, r| r[:timing][:total_time] }

        sorted_results.each do |name, result|
          training_time = result[:timing][:avg_training_time]
          prediction_time = result[:timing][:avg_prediction_time]

          puts format('%-20s Training: %6.3fs  Prediction: %6.3fs',
                      @classifiers[name][:friendly_name],
                      training_time,
                      prediction_time)
        end
      end

      # Display winner analysis
      def display_winner_analysis(results)
        return if results.empty?

        puts "\n🏆 Winner Analysis:"
        puts '-' * 60

        # Find winners for different categories
        accuracy_winner = results.max_by { |_, r| r[:metrics][:accuracy] }
        speed_winner = results.min_by { |_, r| r[:timing][:total_time] }

        puts "🎯 Most Accurate: #{@classifiers[accuracy_winner[0]][:friendly_name]} " \
             "(#{(accuracy_winner[1][:metrics][:accuracy] * 100).round(1)}%)"

        puts "⚡ Fastest: #{@classifiers[speed_winner[0]][:friendly_name]} " \
             "(#{speed_winner[1][:timing][:total_time].round(3)}s total)"

        # Best overall (weighted score)
        overall_scores = results.map do |name, result|
          accuracy_score = result[:metrics][:accuracy]
          speed_score = 1.0 / (1.0 + result[:timing][:total_time])
          overall = (0.7 * accuracy_score) + (0.3 * speed_score)
          [name, overall]
        end

        overall_winner = overall_scores.max_by { |_, score| score }
        puts "🌟 Best Overall: #{@classifiers[overall_winner[0]][:friendly_name]}"
      end

      # Display recommendations based on results
      def display_recommendations(results)
        puts "\n💡 Recommendations:"
        puts '-' * 60

        # Analyze trade-offs
        if @dataset_characteristics[:balance] == :imbalanced
          puts '⚠️  Dataset is imbalanced - consider using weighted metrics'
        end

        if @dataset_characteristics[:complexity] == :high
          puts '🧮 High complexity dataset - neural networks or ensembles may perform better'
        end

        # Specific classifier recommendations
        results.each do |name, result|
          if result[:metrics][:accuracy] > 0.95
            puts "✅ #{@classifiers[name][:friendly_name]} shows excellent performance!"
          elsif result[:metrics][:accuracy] < 0.6
            puts "⚠️  #{@classifiers[name][:friendly_name]} may need parameter tuning"
          end
        end
      end

      # Generate insights for a specific classifier
      def generate_classifier_insights(_name, result)
        insights = []

        accuracy = result[:metrics][:accuracy] || 0.0
        cv_scores = result[:cv_scores] || []

        # Check if classifier failed
        if result[:errors] && !result[:errors].empty?
          insights << '  ❌ Classifier failed to train or predict'
          return insights
        end

        # Performance insights
        insights << if accuracy > 0.9
                      '  ✨ Excellent performance (>90% accuracy)'
                    elsif accuracy > 0.8
                      '  ✓ Good performance (>80% accuracy)'
                    elsif accuracy > 0.7
                      '  → Moderate performance (>70% accuracy)'
                    else
                      '  ⚠️  Poor performance (<70% accuracy)'
                    end

        # Stability insights
        if cv_scores.any?
          cv_std = calculate_std_dev(cv_scores)
          insights << if cv_std < 0.02
                        '  📊 Very stable across folds (low variance)'
                      elsif cv_std < 0.05
                        '  📊 Reasonably stable across folds'
                      else
                        '  📊 High variance across folds - may be overfitting'
                      end
        end

        # Speed insights
        total_time = result[:timing][:total_time] || 0.0
        insights << if total_time < 0.1
                      '  ⚡ Lightning fast (<0.1s)'
                    elsif total_time < 1.0
                      '  🏃 Fast execution (<1s)'
                    else
                      '  🐌 Slow execution (>1s)'
                    end

        insights
      end

      # Generate comparative insights
      def generate_comparative_insights(results)
        insights = []

        return insights if results.empty?

        # Filter out failed classifiers
        valid_results = results.select { |_, r| r[:metrics][:accuracy] && r[:metrics][:accuracy] > 0 }
        return insights if valid_results.empty?

        # Find best and worst performers
        sorted_by_accuracy = valid_results.sort_by { |_, r| -r[:metrics][:accuracy] }
        best = sorted_by_accuracy.first
        worst = sorted_by_accuracy.last

        accuracy_gap = best[1][:metrics][:accuracy] - worst[1][:metrics][:accuracy]

        if accuracy_gap < 0.05
          insights << '• All classifiers perform similarly (within 5%)'
          insights << '• Choice may depend on speed or interpretability'
        elsif accuracy_gap < 0.15
          insights << '• Moderate performance differences observed'
          insights << '• Consider the accuracy-speed trade-off'
        else
          insights << '• Significant performance gap (>15%)'
          insights << '• Some algorithms clearly better suited for this data'
        end

        # Speed vs accuracy trade-off
        valid_timing_results = valid_results.select { |_, r| r[:timing][:total_time] && r[:timing][:total_time] > 0 }
        if valid_timing_results.any?
          fastest = valid_timing_results.min_by { |_, r| r[:timing][:total_time] }
          if fastest[0] != best[0]
            insights << "• Trade-off: #{@classifiers[best[0]][:friendly_name]} is most accurate but " \
                        "#{@classifiers[fastest[0]][:friendly_name]} is fastest"
          end
        end

        insights
      end

      # Generate learning recommendations
      def generate_learning_recommendations(results)
        recommendations = []

        # Based on dataset characteristics
        case @dataset_characteristics[:feature_types]
        when :all_numeric
          recommendations << '• Dataset has all numeric features - try SVM or Neural Networks'
        when :all_categorical
          recommendations << '• Dataset has all categorical features - Decision Trees excel here'
        when :mixed
          recommendations << '• Mixed feature types - consider preprocessing or ensemble methods'
        end

        # Based on performance patterns
        tree_based = results.select { |name, _| name.to_s.include?('tree') || name == :id3 }
        if tree_based.any? && tree_based.values.all? { |r| r[:metrics][:accuracy] && r[:metrics][:accuracy] > 0.8 }
          recommendations << '• Tree-based methods work well - data may have clear decision boundaries'
        end

        # General learning tips
        recommendations << '• Try different train/test splits to verify stability'
        recommendations << '• Experiment with feature engineering to improve results'
        recommendations << '• Consider ensemble methods to combine classifier strengths'

        recommendations
      end

      # Display progress insights during benchmarking
      def display_progress_insights(_name, result)
        accuracy = result[:metrics][:accuracy] || 0.0
        time = result[:timing][:total_time] || 0.0

        insight = if accuracy > 0.9 && time < 0.1
                    '🚀 Wow! Fast AND accurate!'
                  elsif accuracy > 0.9
                    '🎯 Excellent accuracy!'
                  elsif time < 0.1
                    '⚡ Super speedy!'
                  else
                    '✓ Completed'
                  end

        log "  #{insight} - Accuracy: #{(accuracy * 100).round(1)}%, Time: #{time.round(3)}s"
      end

      # Export results to CSV
      def export_to_csv(filename)
        require 'csv'

        CSV.open("#{filename}.csv", 'w') do |csv|
          # Header
          csv << ['Classifier', 'Accuracy', 'Precision', 'Recall', 'F1-Score',
                  'Training Time', 'Prediction Time', 'Total Time']

          # Data rows
          @results.each do |name, result|
            csv << [
              @classifiers[name][:friendly_name],
              result[:metrics][:accuracy],
              result[:metrics][:weighted_precision],
              result[:metrics][:weighted_recall],
              result[:metrics][:weighted_f1],
              result[:timing][:avg_training_time],
              result[:timing][:avg_prediction_time],
              result[:timing][:total_time]
            ]
          end
        end

        log "Results exported to #{filename}.csv"
      end

      # Export results to JSON
      def export_to_json(filename)
        require 'json'

        export_data = {
          metadata: {
            timestamp: Time.now.iso8601,
            dataset_characteristics: @dataset_characteristics,
            cross_validation_folds: @cross_validation_folds
          },
          results: @results.map do |name, result|
            {
              classifier: @classifiers[name][:friendly_name],
              metrics: result[:metrics],
              timing: result[:timing],
              cv_scores: result[:cv_scores]
            }
          end
        }

        File.write("#{filename}.json", JSON.pretty_generate(export_data))
        log "Results exported to #{filename}.json"
      end

      # Export results to HTML
      def export_to_html(filename)
        html = generate_html_report
        File.write("#{filename}.html", html)
        log "Results exported to #{filename}.html"
      end

      # Generate HTML report
      def generate_html_report
        # This would generate a nice HTML report
        # For now, return a simple version
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <title>Classifier Benchmark Results</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 20px; }
              table { border-collapse: collapse; width: 100%; }
              th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
              th { background-color: #4CAF50; color: white; }
              tr:nth-child(even) { background-color: #f2f2f2; }
            </style>
          </head>
          <body>
            <h1>Classifier Benchmark Results</h1>
            <p>Generated at: #{Time.now}</p>
          #{'  '}
            <h2>Summary</h2>
            <table>
              <tr>
                <th>Classifier</th>
                <th>Accuracy</th>
                <th>F1-Score</th>
                <th>Total Time</th>
              </tr>
              #{@results.map do |name, result|
                "<tr>
                  <td>#{@classifiers[name][:friendly_name]}</td>
                  <td>#{(result[:metrics][:accuracy] * 100).round(1)}%</td>
                  <td>#{result[:metrics][:weighted_f1].round(3)}</td>
                  <td>#{result[:timing][:total_time].round(3)}s</td>
                </tr>"
              end.join("\n")}
            </table>
          #{'  '}
            <h2>Educational Insights</h2>
            <pre>#{generate_insights}</pre>
          </body>
          </html>
        HTML
      end

      # Check if dataset has numeric features
      def has_numeric_features?(dataset)
        return false if dataset.data_items.empty?

        # Check first few items for numeric features
        sample_size = [5, dataset.data_items.size].min
        samples = dataset.data_items.first(sample_size)

        (0...(dataset.data_labels.size - 1)).each do |i|
          values = samples.map { |item| item[i] }
          return true if values.any?(Numeric)
        end

        false
      end

      # Check if classifier supports numeric features
      def supports_numeric_features?(classifier)
        # List of classifiers that handle numeric features well (by class name)
        numeric_compatible_names = %w[
          MultilayerPerceptron
          IB1
          ZeroR
          SimpleLinearRegression
          LogisticRegression
          SupportVectorMachine
          Hyperpipes
        ]

        # Check if classifier class name is in the numeric compatible list
        classifier_class_name = classifier.class.name.split('::').last
        numeric_compatible_names.include?(classifier_class_name)
      end

      # Log message if verbose mode is enabled
      def log(message)
        puts message if @verbose
      end
    end
  end
end
