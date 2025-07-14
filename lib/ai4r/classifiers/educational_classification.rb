# frozen_string_literal: true

# Educational classification framework designed for students and teachers
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'classifier'
require_relative '../data/data_set'

module Ai4r
  module Classifiers
    
    # Educational classification framework designed for students and teachers
    # to understand, experiment with, and visualize classification algorithms
    class EducationalClassification < Classifier
      
      attr_reader :algorithm, :monitor, :configuration, :training_history, :model_info
      
      def initialize(algorithm_type = :id3, config = {})
        @algorithm_type = algorithm_type
        @configuration = ClassificationConfiguration.new(config)
        @monitor = ClassificationMonitor.new
        @training_history = []
        @model_info = {}
        @step_mode = false
        @visualization_enabled = false
        
        # Initialize the specific algorithm
        @algorithm = create_algorithm(algorithm_type)
      end
      
      # Enable step-by-step execution for educational purposes
      def enable_step_mode
        @step_mode = true
        self
      end
      
      # Enable visualization output
      def enable_visualization
        @visualization_enabled = true
        self
      end
      
      # Configure algorithm parameters with educational explanations
      def configure(params)
        @configuration.update(params)
        @configuration.explain_changes if @configuration.verbose
        self
      end
      
      # Main training method with educational features
      def build(data_set)
        @data_set = data_set
        @monitor.start_training(data_set)
        
        puts "Starting #{@algorithm_type} classification training..." if @configuration.verbose
        puts "Dataset: #{data_set.data_items.length} examples, #{data_set.data_labels.length} features" if @configuration.verbose
        
        if @step_mode
          build_step_by_step
        else
          build_normal
        end
        
        @monitor.finish_training(@algorithm)
        collect_model_info
        self
      end
      
      # Prediction with detailed explanation
      def eval(data_item)
        return nil unless @algorithm
        
        if @configuration.explain_predictions
          explain_prediction(data_item)
        else
          @algorithm.eval(data_item)
        end
      end
      
      # Get prediction with confidence scores
      def predict_with_confidence(data_item)
        case @algorithm_type
        when :naive_bayes
          probabilities = @algorithm.get_probability_map(data_item)
          prediction = probabilities.max_by { |k, v| v }[0]
          confidence = probabilities.values.max
          
          { prediction: prediction, confidence: confidence, probabilities: probabilities }
        else
          prediction = @algorithm.eval(data_item)
          { prediction: prediction, confidence: 1.0, probabilities: { prediction => 1.0 } }
        end
      end
      
      # Evaluate model performance with comprehensive metrics
      def evaluate_performance(test_set)
        return nil unless @algorithm
        
        ClassificationEvaluator.new(@algorithm, test_set, @configuration).evaluate
      end
      
      # Cross-validation for model assessment
      def cross_validate(data_set, folds = 5)
        ClassificationCrossValidator.new(@algorithm_type, @configuration).validate(data_set, folds)
      end
      
      # Compare this classifier with another
      def compare_with(other_classifier, test_set)
        ClassificationComparator.new(self, other_classifier, test_set).compare
      end
      
      # Export model and results for external analysis
      def export_model(filename)
        ClassificationExporter.new(@algorithm, @model_info, @training_history).export(filename)
      end
      
      # Visualize model structure and performance
      def visualize
        ClassificationVisualizer.new(@algorithm, @model_info, @training_history).visualize
      end
      
      # Get human-readable rules (if supported)
      def get_rules
        @algorithm.get_rules if @algorithm.respond_to?(:get_rules)
      end
      
      private
      
      def create_algorithm(algorithm_type)
        case algorithm_type
        when :id3
          EducationalID3.new(@configuration, @monitor)
        when :naive_bayes
          EducationalNaiveBayes.new(@configuration, @monitor)
        when :multilayer_perceptron
          EducationalMultilayerPerceptron.new(@configuration, @monitor)
        when :one_r
          EducationalOneR.new(@configuration, @monitor)
        when :zero_r
          EducationalZeroR.new(@configuration, @monitor)
        else
          raise ArgumentError, "Unknown algorithm type: #{algorithm_type}"
        end
      end
      
      def build_step_by_step
        puts "\n=== Step-by-step classification training ===" if @configuration.verbose
        @algorithm.build_with_steps(@data_set) do |step_info|
          @training_history << step_info
          
          if @configuration.verbose
            puts "\nStep #{step_info[:step]}: #{step_info[:description]}"
            puts step_info[:details] if step_info[:details]
          end
          
          visualize_step(step_info) if @visualization_enabled
          
          if @step_mode
            puts "Press Enter to continue..."
            gets
          end
        end
      end
      
      def build_normal
        @algorithm.build(@data_set)
      end
      
      def explain_prediction(data_item)
        case @algorithm_type
        when :id3
          explain_decision_tree_prediction(data_item)
        when :naive_bayes
          explain_naive_bayes_prediction(data_item)
        else
          @algorithm.eval(data_item)
        end
      end
      
      def explain_decision_tree_prediction(data_item)
        prediction = @algorithm.eval(data_item)
        
        if @configuration.verbose
          puts "\nDecision Tree Prediction Explanation:"
          puts "Input: #{data_item.inspect}"
          puts "Following decision path..."
          # This would trace through the decision tree
          puts "Final prediction: #{prediction}"
        end
        
        prediction
      end
      
      def explain_naive_bayes_prediction(data_item)
        probabilities = @algorithm.get_probability_map(data_item)
        prediction = probabilities.max_by { |k, v| v }[0]
        
        if @configuration.verbose
          puts "\nNaive Bayes Prediction Explanation:"
          puts "Input: #{data_item.inspect}"
          puts "Class probabilities:"
          probabilities.each { |class_name, prob| puts "  #{class_name}: #{prob.round(4)}" }
          puts "Prediction: #{prediction} (highest probability)"
        end
        
        prediction
      end
      
      def collect_model_info
        @model_info = {
          algorithm_type: @algorithm_type,
          training_examples: @data_set.data_items.length,
          features: @data_set.data_labels.length - 1,
          classes: @data_set.build_domains.last.length,
          class_names: @data_set.build_domains.last.to_a,
          training_time: @monitor.training_time,
          model_complexity: calculate_model_complexity
        }
      end
      
      def calculate_model_complexity
        case @algorithm_type
        when :id3
          # Number of nodes in decision tree
          count_tree_nodes(@algorithm.instance_variable_get(:@tree))
        when :naive_bayes
          # Number of conditional probabilities stored
          @data_set.data_labels.length * @data_set.build_domains.map(&:length).sum
        else
          "Unknown"
        end
      end
      
      def count_tree_nodes(node)
        return 1 if node.nil? || node.class.name.include?("CategoryNode")
        
        if node.class.name.include?("EvaluationNode")
          1 + node.nodes.sum { |child| count_tree_nodes(child) }
        else
          1
        end
      end
      
      def visualize_step(step_info)
        ClassificationVisualizer.new(@algorithm, @model_info, @training_history).visualize_step(step_info)
      end
    end
    
    # Configuration class for classification parameters
    class ClassificationConfiguration
      attr_accessor :verbose, :explain_predictions, :cross_validation_folds
      attr_accessor :training_split, :validation_split, :test_split
      attr_accessor :feature_selection, :preprocessing_steps
      
      def initialize(params = {})
        # Default parameters
        @verbose = params[:verbose] || false
        @explain_predictions = params[:explain_predictions] || false
        @cross_validation_folds = params[:cross_validation_folds] || 5
        @training_split = params[:training_split] || 0.7
        @validation_split = params[:validation_split] || 0.15
        @test_split = params[:test_split] || 0.15
        @feature_selection = params[:feature_selection] || false
        @preprocessing_steps = params[:preprocessing_steps] || []
        
        @explanations = {}
      end
      
      def update(params)
        params.each do |key, value|
          if respond_to?("#{key}=")
            old_value = send(key)
            send("#{key}=", value)
            @explanations[key] = explain_parameter_change(key, old_value, value)
          end
        end
      end
      
      def explain_changes
        @explanations.each do |param, explanation|
          puts "#{param}: #{explanation}"
        end
        @explanations.clear
      end
      
      def explain_all_parameters
        puts "\n=== Classification Parameters Explanation ==="
        puts "verbose: Show detailed training information (current: #{@verbose})"
        puts "explain_predictions: Show reasoning for each prediction (current: #{@explain_predictions})"
        puts "cross_validation_folds: Number of folds for cross-validation (current: #{@cross_validation_folds})"
        puts "training_split: Fraction of data for training (current: #{@training_split})"
        puts "validation_split: Fraction of data for validation (current: #{@validation_split})"
        puts "test_split: Fraction of data for testing (current: #{@test_split})"
        puts "feature_selection: Enable automatic feature selection (current: #{@feature_selection})"
        puts "preprocessing_steps: Data preprocessing steps (current: #{@preprocessing_steps})"
      end
      
      private
      
      def explain_parameter_change(param, old_value, new_value)
        case param
        when :verbose
          "Verbose mode #{new_value ? 'enabled' : 'disabled'} - affects training output detail"
        when :explain_predictions
          "Prediction explanations #{new_value ? 'enabled' : 'disabled'} - shows reasoning for classifications"
        when :cross_validation_folds
          "Cross-validation folds changed from #{old_value} to #{new_value} - affects model validation"
        when :training_split
          "Training split changed from #{old_value} to #{new_value} - affects data partitioning"
        else
          "Changed #{param} from #{old_value} to #{new_value}"
        end
      end
    end
    
    # Monitoring class for tracking classification training
    class ClassificationMonitor
      attr_reader :start_time, :training_time, :training_progress, :model_metrics
      
      def initialize
        @training_progress = []
        @model_metrics = {}
      end
      
      def start_training(data_set)
        @start_time = Time.now
        @data_set = data_set
        @training_progress.clear
        @model_metrics.clear
      end
      
      def record_training_step(step_info)
        step_info[:timestamp] = Time.now
        @training_progress << step_info
        step_info
      end
      
      def finish_training(algorithm)
        @end_time = Time.now
        @training_time = @end_time - @start_time
        @algorithm = algorithm
        
        # Collect final metrics
        @model_metrics = {
          training_examples: @data_set.data_items.length,
          features: @data_set.data_labels.length - 1,
          classes: @data_set.build_domains.last.length,
          training_time: @training_time
        }
      end
      
      def summary
        return "Training not completed" unless @training_time
        
        {
          training_time: @training_time,
          training_examples: @model_metrics[:training_examples],
          features: @model_metrics[:features],
          classes: @model_metrics[:classes],
          training_steps: @training_progress.length
        }
      end
      
      def plot_training_progress
        return "No training progress to plot" if @training_progress.empty?
        
        puts "\n=== Training Progress ==="
        puts "Step | Description"
        puts "-----|------------"
        
        @training_progress.each_with_index do |step, index|
          puts sprintf("%4d | %s", index + 1, step[:description])
        end
        
        puts "\nTotal training time: #{@training_time.round(3)} seconds"
      end
    end
    
    # Classification performance evaluation
    class ClassificationEvaluator
      def initialize(algorithm, test_set, configuration)
        @algorithm = algorithm
        @test_set = test_set
        @configuration = configuration
      end
      
      def evaluate
        return nil unless @algorithm && @test_set
        
        predictions = []
        actual_labels = []
        
        @test_set.data_items.each do |item|
          features = item[0...-1]
          actual_class = item.last
          predicted_class = @algorithm.eval(features)
          
          predictions << predicted_class
          actual_labels << actual_class
        end
        
        # Calculate metrics
        accuracy = calculate_accuracy(predictions, actual_labels)
        confusion_matrix = calculate_confusion_matrix(predictions, actual_labels)
        class_metrics = calculate_class_metrics(predictions, actual_labels)
        
        {
          accuracy: accuracy,
          confusion_matrix: confusion_matrix,
          class_metrics: class_metrics,
          predictions: predictions,
          actual_labels: actual_labels,
          test_size: @test_set.data_items.length
        }
      end
      
      private
      
      def calculate_accuracy(predictions, actual_labels)
        correct = predictions.zip(actual_labels).count { |pred, actual| pred == actual }
        correct.to_f / predictions.length
      end
      
      def calculate_confusion_matrix(predictions, actual_labels)
        classes = (predictions + actual_labels).uniq.sort
        matrix = {}
        
        classes.each do |actual_class|
          matrix[actual_class] = {}
          classes.each do |predicted_class|
            matrix[actual_class][predicted_class] = 0
          end
        end
        
        predictions.zip(actual_labels).each do |pred, actual|
          matrix[actual][pred] += 1
        end
        
        matrix
      end
      
      def calculate_class_metrics(predictions, actual_labels)
        classes = (predictions + actual_labels).uniq.sort
        metrics = {}
        
        classes.each do |class_name|
          tp = predictions.zip(actual_labels).count { |pred, actual| pred == class_name && actual == class_name }
          fp = predictions.zip(actual_labels).count { |pred, actual| pred == class_name && actual != class_name }
          fn = predictions.zip(actual_labels).count { |pred, actual| pred != class_name && actual == class_name }
          tn = predictions.zip(actual_labels).count { |pred, actual| pred != class_name && actual != class_name }
          
          precision = tp + fp > 0 ? tp.to_f / (tp + fp) : 0.0
          recall = tp + fn > 0 ? tp.to_f / (tp + fn) : 0.0
          f1_score = precision + recall > 0 ? 2 * (precision * recall) / (precision + recall) : 0.0
          
          metrics[class_name] = {
            precision: precision,
            recall: recall,
            f1_score: f1_score,
            support: tp + fn
          }
        end
        
        metrics
      end
    end
    
    # Cross-validation for model assessment
    class ClassificationCrossValidator
      def initialize(algorithm_type, configuration)
        @algorithm_type = algorithm_type
        @configuration = configuration
      end
      
      def validate(data_set, folds = 5)
        fold_size = data_set.data_items.length / folds
        results = []
        
        folds.times do |fold|
          # Create train and validation sets
          start_idx = fold * fold_size
          end_idx = start_idx + fold_size
          
          validation_items = data_set.data_items[start_idx...end_idx]
          training_items = data_set.data_items[0...start_idx] + data_set.data_items[end_idx..-1]
          
          training_set = Ai4r::Data::DataSet.new(
            data_labels: data_set.data_labels,
            data_items: training_items
          )
          
          validation_set = Ai4r::Data::DataSet.new(
            data_labels: data_set.data_labels,
            data_items: validation_items
          )
          
          # Train and evaluate
          classifier = EducationalClassification.new(@algorithm_type, @configuration.instance_variables.each_with_object({}) do |var, hash|
            hash[var.to_s.delete('@').to_sym] = @configuration.instance_variable_get(var)
          end)
          
          classifier.build(training_set)
          evaluation = classifier.evaluate_performance(validation_set)
          
          results << {
            fold: fold + 1,
            accuracy: evaluation[:accuracy],
            class_metrics: evaluation[:class_metrics]
          }
        end
        
        # Calculate average metrics
        avg_accuracy = results.sum { |r| r[:accuracy] } / results.length
        
        {
          folds: folds,
          results: results,
          average_accuracy: avg_accuracy,
          accuracy_std: calculate_standard_deviation(results.map { |r| r[:accuracy] })
        }
      end
      
      private
      
      def calculate_standard_deviation(values)
        mean = values.sum / values.length.to_f
        variance = values.sum { |v| (v - mean) ** 2 } / values.length.to_f
        Math.sqrt(variance)
      end
    end
    
    # Visualization helper for classification results
    class ClassificationVisualizer
      def initialize(algorithm, model_info, training_history)
        @algorithm = algorithm
        @model_info = model_info
        @training_history = training_history
      end
      
      def visualize
        puts "\n=== Classification Model Visualization ==="
        puts "Algorithm: #{@model_info[:algorithm_type]}"
        puts "Training examples: #{@model_info[:training_examples]}"
        puts "Features: #{@model_info[:features]}"
        puts "Classes: #{@model_info[:classes]}"
        puts "Training time: #{@model_info[:training_time]&.round(3)} seconds"
        
        visualize_model_structure
        visualize_training_progress if @training_history.any?
      end
      
      def visualize_step(step_info)
        puts "\n--- Step #{step_info[:step]} Visualization ---"
        puts step_info[:description]
        
        case step_info[:type]
        when :tree_building
          visualize_tree_step(step_info)
        when :probability_calculation
          visualize_probability_step(step_info)
        end
      end
      
      def visualize_confusion_matrix(confusion_matrix)
        return unless confusion_matrix
        
        puts "\n=== Confusion Matrix ==="
        classes = confusion_matrix.keys.sort
        
        # Header
        print "Actual\\Predicted"
        classes.each { |class_name| print sprintf("%8s", class_name) }
        puts
        
        # Matrix
        classes.each do |actual_class|
          print sprintf("%15s", actual_class)
          classes.each do |predicted_class|
            count = confusion_matrix[actual_class][predicted_class]
            print sprintf("%8d", count)
          end
          puts
        end
      end
      
      def visualize_class_metrics(class_metrics)
        return unless class_metrics
        
        puts "\n=== Per-Class Metrics ==="
        puts "Class       | Precision | Recall   | F1-Score | Support"
        puts "------------|-----------|----------|----------|--------"
        
        class_metrics.each do |class_name, metrics|
          puts sprintf("%-11s | %9.4f | %8.4f | %8.4f | %7d",
            class_name,
            metrics[:precision],
            metrics[:recall],
            metrics[:f1_score],
            metrics[:support]
          )
        end
      end
      
      private
      
      def visualize_model_structure
        case @model_info[:algorithm_type]
        when :id3
          visualize_decision_tree_structure
        when :naive_bayes
          visualize_naive_bayes_structure
        when :multilayer_perceptron
          visualize_neural_network_structure
        end
      end
      
      def visualize_decision_tree_structure
        puts "\n=== Decision Tree Structure ==="
        if @algorithm.respond_to?(:get_rules)
          puts "Rules:"
          puts @algorithm.get_rules
        else
          puts "Model complexity: #{@model_info[:model_complexity]} nodes"
        end
      end
      
      def visualize_naive_bayes_structure
        puts "\n=== Naive Bayes Structure ==="
        puts "Stores conditional probabilities for each feature-class combination"
        puts "Model complexity: #{@model_info[:model_complexity]} stored probabilities"
      end
      
      def visualize_neural_network_structure
        puts "\n=== Neural Network Structure ==="
        puts "Multilayer perceptron with hidden layers"
        puts "Input nodes: #{@model_info[:features]}"
        puts "Output nodes: #{@model_info[:classes]}"
      end
      
      def visualize_training_progress
        puts "\n=== Training Progress ==="
        puts "Step | Description"
        puts "-----|------------"
        
        @training_history.each_with_index do |step, index|
          puts sprintf("%4d | %s", index + 1, step[:description])
        end
      end
      
      def visualize_tree_step(step_info)
        puts "  Building decision tree node for attribute: #{step_info[:attribute]}"
        puts "  Information gain: #{step_info[:information_gain]&.round(4)}"
      end
      
      def visualize_probability_step(step_info)
        puts "  Calculating probabilities for class: #{step_info[:class_name]}"
        puts "  Prior probability: #{step_info[:prior_probability]&.round(4)}"
      end
    end
    
    # Export classification results to various formats
    class ClassificationExporter
      def initialize(algorithm, model_info, training_history)
        @algorithm = algorithm
        @model_info = model_info
        @training_history = training_history
      end
      
      def export(filename)
        case File.extname(filename).downcase
        when '.csv'
          export_csv(filename)
        when '.json'
          export_json(filename)
        else
          export_text(filename)
        end
      end
      
      private
      
      def export_csv(filename)
        require 'csv'
        
        CSV.open(filename, 'w') do |csv|
          csv << ['Metric', 'Value']
          @model_info.each { |key, value| csv << [key, value] }
        end
        
        puts "Exported model information to #{filename}"
      end
      
      def export_json(filename)
        require 'json'
        
        result = {
          model_info: @model_info,
          training_history: @training_history,
          rules: @algorithm.respond_to?(:get_rules) ? @algorithm.get_rules : nil
        }
        
        File.write(filename, JSON.pretty_generate(result))
        puts "Exported model to #{filename}"
      end
      
      def export_text(filename)
        File.open(filename, 'w') do |file|
          file.puts "Classification Model Export"
          file.puts "=" * 50
          file.puts "Algorithm: #{@model_info[:algorithm_type]}"
          file.puts "Training examples: #{@model_info[:training_examples]}"
          file.puts "Features: #{@model_info[:features]}"
          file.puts "Classes: #{@model_info[:classes]}"
          file.puts "Training time: #{@model_info[:training_time]} seconds"
          file.puts
          
          if @algorithm.respond_to?(:get_rules)
            file.puts "Model Rules:"
            file.puts @algorithm.get_rules
          end
          
          file.puts "\nTraining History:"
          @training_history.each_with_index do |step, index|
            file.puts "#{index + 1}. #{step[:description]}"
          end
        end
        
        puts "Exported model to #{filename}"
      end
    end
    
    # Comparison tool for different classification algorithms
    class ClassificationComparator
      def initialize(classifier1, classifier2, test_set)
        @classifier1 = classifier1
        @classifier2 = classifier2
        @test_set = test_set
      end
      
      def compare
        puts "\n=== Classification Algorithm Comparison ==="
        
        eval1 = @classifier1.evaluate_performance(@test_set)
        eval2 = @classifier2.evaluate_performance(@test_set)
        
        puts "Algorithm 1: #{@classifier1.algorithm_type}"
        puts "Algorithm 2: #{@classifier2.algorithm_type}"
        puts
        
        puts "Performance Comparison:"
        puts "-" * 40
        puts sprintf("%-15s | %10s | %10s", "Metric", "Algorithm 1", "Algorithm 2")
        puts "-" * 40
        puts sprintf("%-15s | %10.4f | %10.4f", "Accuracy", eval1[:accuracy], eval2[:accuracy])
        
        # Compare average F1-scores
        avg_f1_1 = eval1[:class_metrics].values.sum { |m| m[:f1_score] } / eval1[:class_metrics].length
        avg_f1_2 = eval2[:class_metrics].values.sum { |m| m[:f1_score] } / eval2[:class_metrics].length
        puts sprintf("%-15s | %10.4f | %10.4f", "Avg F1-Score", avg_f1_1, avg_f1_2)
        
        {
          algorithm1: @classifier1.algorithm_type,
          algorithm2: @classifier2.algorithm_type,
          evaluation1: eval1,
          evaluation2: eval2
        }
      end
    end
  end
end