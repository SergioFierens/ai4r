# frozen_string_literal: true

# Educational examples for classification algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'educational_classification'
require_relative 'educational_algorithms'
require_relative '../data/data_set'

module Ai4r
  module Classifiers
    module EducationalExamples
      
      # Generate different types of datasets for educational purposes
      class DatasetGenerator
        
        def self.generate_simple_binary_dataset
          # Simple binary classification dataset
          data_items = [
            # Format: [feature1, feature2, feature3, class]
            ['sunny', 'hot', 'high', 'no'],
            ['sunny', 'hot', 'high', 'no'],
            ['overcast', 'hot', 'high', 'yes'],
            ['rainy', 'mild', 'high', 'yes'],
            ['rainy', 'cool', 'normal', 'yes'],
            ['rainy', 'cool', 'normal', 'no'],
            ['overcast', 'cool', 'normal', 'yes'],
            ['sunny', 'mild', 'high', 'no'],
            ['sunny', 'cool', 'normal', 'yes'],
            ['rainy', 'mild', 'normal', 'yes'],
            ['sunny', 'mild', 'normal', 'yes'],
            ['overcast', 'mild', 'high', 'yes'],
            ['overcast', 'hot', 'normal', 'yes'],
            ['rainy', 'mild', 'high', 'no']
          ]
          
          data_labels = ['weather', 'temperature', 'humidity', 'play_tennis']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_multiclass_dataset
          # Multi-class classification dataset (iris-like)
          data_items = [
            # Format: [sepal_length, sepal_width, petal_length, petal_width, species]
            ['short', 'wide', 'short', 'narrow', 'setosa'],
            ['short', 'wide', 'short', 'narrow', 'setosa'],
            ['short', 'medium', 'short', 'narrow', 'setosa'],
            ['medium', 'wide', 'short', 'narrow', 'setosa'],
            ['short', 'narrow', 'short', 'narrow', 'setosa'],
            ['medium', 'medium', 'medium', 'medium', 'versicolor'],
            ['long', 'narrow', 'medium', 'medium', 'versicolor'],
            ['medium', 'medium', 'medium', 'wide', 'versicolor'],
            ['medium', 'narrow', 'medium', 'narrow', 'versicolor'],
            ['medium', 'narrow', 'medium', 'medium', 'versicolor'],
            ['long', 'narrow', 'long', 'wide', 'virginica'],
            ['medium', 'narrow', 'long', 'wide', 'virginica'],
            ['long', 'narrow', 'long', 'medium', 'virginica'],
            ['long', 'medium', 'long', 'wide', 'virginica'],
            ['medium', 'wide', 'long', 'wide', 'virginica']
          ]
          
          data_labels = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_marketing_dataset
          # Marketing/customer classification dataset
          data_items = [
            ['young', 'student', 'single', 'fair', 'no'],
            ['young', 'student', 'single', 'excellent', 'no'],
            ['middle', 'student', 'single', 'fair', 'yes'],
            ['senior', 'employee', 'single', 'fair', 'yes'],
            ['senior', 'employee', 'single', 'excellent', 'no'],
            ['senior', 'employee', 'married', 'excellent', 'no'],
            ['middle', 'employee', 'married', 'excellent', 'yes'],
            ['young', 'student', 'single', 'fair', 'no'],
            ['young', 'employee', 'married', 'fair', 'yes'],
            ['senior', 'employee', 'married', 'fair', 'yes'],
            ['young', 'employee', 'married', 'excellent', 'yes'],
            ['middle', 'student', 'married', 'excellent', 'yes'],
            ['middle', 'employee', 'single', 'fair', 'yes'],
            ['senior', 'employee', 'single', 'excellent', 'no']
          ]
          
          data_labels = ['age', 'job', 'marital', 'credit_rating', 'buys_computer']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_medical_dataset
          # Medical diagnosis dataset
          data_items = [
            ['high', 'yes', 'normal', 'no', 'heart_disease'],
            ['normal', 'no', 'high', 'yes', 'healthy'],
            ['high', 'yes', 'high', 'no', 'heart_disease'],
            ['normal', 'no', 'normal', 'no', 'healthy'],
            ['high', 'no', 'high', 'yes', 'heart_disease'],
            ['normal', 'yes', 'normal', 'no', 'healthy'],
            ['high', 'yes', 'high', 'yes', 'heart_disease'],
            ['normal', 'no', 'normal', 'yes', 'healthy'],
            ['high', 'no', 'normal', 'no', 'heart_disease'],
            ['normal', 'yes', 'high', 'no', 'diabetes'],
            ['high', 'yes', 'normal', 'yes', 'heart_disease'],
            ['normal', 'no', 'high', 'no', 'diabetes'],
            ['high', 'no', 'high', 'no', 'heart_disease'],
            ['normal', 'yes', 'high', 'yes', 'diabetes']
          ]
          
          data_labels = ['blood_pressure', 'chest_pain', 'cholesterol', 'family_history', 'diagnosis']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_numeric_dataset
          # Dataset with both categorical and numeric features
          data_items = [
            ['male', 25, 'bachelor', 50000, 'approved'],
            ['female', 35, 'master', 75000, 'approved'],
            ['male', 28, 'bachelor', 45000, 'rejected'],
            ['female', 42, 'phd', 95000, 'approved'],
            ['male', 30, 'high_school', 35000, 'rejected'],
            ['female', 26, 'bachelor', 52000, 'approved'],
            ['male', 38, 'master', 68000, 'approved'],
            ['female', 33, 'bachelor', 48000, 'rejected'],
            ['male', 45, 'phd', 120000, 'approved'],
            ['female', 29, 'high_school', 32000, 'rejected'],
            ['male', 31, 'master', 71000, 'approved'],
            ['female', 27, 'bachelor', 46000, 'rejected'],
            ['male', 39, 'phd', 98000, 'approved'],
            ['female', 34, 'master', 62000, 'approved']
          ]
          
          data_labels = ['gender', 'age', 'education', 'income', 'loan_status']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_imbalanced_dataset
          # Dataset with class imbalance
          data_items = [
            ['low', 'small', 'new', 'normal'],
            ['low', 'small', 'new', 'normal'],
            ['low', 'small', 'old', 'normal'],
            ['low', 'medium', 'new', 'normal'],
            ['low', 'medium', 'old', 'normal'],
            ['medium', 'small', 'new', 'normal'],
            ['medium', 'small', 'old', 'normal'],
            ['medium', 'medium', 'new', 'normal'],
            ['medium', 'medium', 'old', 'normal'],
            ['medium', 'large', 'new', 'normal'],
            ['high', 'small', 'new', 'normal'],
            ['high', 'medium', 'new', 'normal'],
            ['high', 'large', 'old', 'fraud'],  # Only 2 fraud cases
            ['high', 'large', 'new', 'fraud']
          ]
          
          data_labels = ['risk_score', 'transaction_amount', 'account_age', 'transaction_type']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.split_dataset(dataset, train_ratio = 0.7, test_ratio = 0.3)
          total_size = dataset.data_items.length
          train_size = (total_size * train_ratio).to_i
          
          # Shuffle data items
          shuffled_items = dataset.data_items.shuffle
          
          train_items = shuffled_items[0...train_size]
          test_items = shuffled_items[train_size..-1]
          
          train_set = Ai4r::Data::DataSet.new(
            data_labels: dataset.data_labels,
            data_items: train_items
          )
          
          test_set = Ai4r::Data::DataSet.new(
            data_labels: dataset.data_labels,
            data_items: test_items
          )
          
          [train_set, test_set]
        end
      end
      
      # Educational runner methods
      class << self
        
        def run_basic_id3_example
          puts "=== Basic ID3 Decision Tree Example ==="
          puts "Demonstrating ID3 algorithm with step-by-step execution"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_simple_binary_dataset
          
          # Create educational classifier
          classifier = EducationalClassification.new(:id3, {
            verbose: true,
            explain_predictions: true
          })
          
          classifier.enable_step_mode.enable_visualization
          
          # Train classifier
          puts "Training ID3 decision tree..."
          classifier.build(data_set)
          
          # Show decision tree rules
          puts "\n=== Decision Tree Rules ==="
          puts classifier.get_rules
          
          # Test some predictions
          puts "\n=== Test Predictions ==="
          test_cases = [
            ['sunny', 'hot', 'high'],
            ['overcast', 'mild', 'normal'],
            ['rainy', 'cool', 'high']
          ]
          
          test_cases.each do |test_case|
            prediction = classifier.eval(test_case)
            puts "#{test_case.inspect} => #{prediction}"
          end
          
          # Visualize model
          classifier.visualize
          
          classifier
        end
        
        def run_naive_bayes_example
          puts "=== Naive Bayes Classifier Example ==="
          puts "Demonstrating Naive Bayes with probability calculations"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_marketing_dataset
          
          # Create educational classifier
          classifier = EducationalClassification.new(:naive_bayes, {
            verbose: true,
            explain_predictions: true
          })
          
          classifier.enable_step_mode.enable_visualization
          
          # Train classifier
          puts "Training Naive Bayes classifier..."
          classifier.build(data_set)
          
          # Test predictions with probabilities
          puts "\n=== Test Predictions with Probabilities ==="
          test_cases = [
            ['young', 'student', 'single', 'fair'],
            ['senior', 'employee', 'married', 'excellent'],
            ['middle', 'employee', 'single', 'fair']
          ]
          
          test_cases.each do |test_case|
            result = classifier.predict_with_confidence(test_case)
            puts "#{test_case.inspect}:"
            puts "  Prediction: #{result[:prediction]}"
            puts "  Confidence: #{result[:confidence].round(4)}"
            puts "  Probabilities: #{result[:probabilities].map { |k, v| "#{k}: #{v.round(4)}" }.join(', ')}"
            puts
          end
          
          # Visualize model
          classifier.visualize
          
          classifier
        end
        
        def run_algorithm_comparison
          puts "=== Classification Algorithm Comparison ==="
          puts "Comparing different classification algorithms"
          puts
          
          # Generate sample data and split
          data_set = DatasetGenerator.generate_multiclass_dataset
          train_set, test_set = DatasetGenerator.split_dataset(data_set, 0.7, 0.3)
          
          algorithms = [
            [:id3, "ID3 Decision Tree"],
            [:naive_bayes, "Naive Bayes"],
            [:one_r, "OneR"],
            [:zero_r, "ZeroR (Baseline)"]
          ]
          
          results = {}
          
          algorithms.each do |algorithm_type, algorithm_name|
            puts "\n--- Testing #{algorithm_name} ---"
            
            classifier = EducationalClassification.new(algorithm_type, {
              verbose: false
            })
            
            classifier.build(train_set)
            evaluation = classifier.evaluate_performance(test_set)
            
            results[algorithm_type] = {
              name: algorithm_name,
              classifier: classifier,
              evaluation: evaluation
            }
            
            puts "Accuracy: #{evaluation[:accuracy].round(4)}"
            
            # Show confusion matrix
            puts "\nConfusion Matrix:"
            classifier.visualize
          end
          
          # Compare results
          puts "\n=== Algorithm Performance Comparison ==="
          puts "Algorithm              | Accuracy | Avg F1-Score"
          puts "-----------------------|----------|-------------"
          results.each do |algorithm_type, result|
            evaluation = result[:evaluation]
            avg_f1 = evaluation[:class_metrics].values.sum { |m| m[:f1_score] } / evaluation[:class_metrics].length
            puts sprintf("%-22s | %8.4f | %11.4f", result[:name], evaluation[:accuracy], avg_f1)
          end
          
          results
        end
        
        def run_cross_validation_example
          puts "=== Cross-Validation Example ==="
          puts "Demonstrating k-fold cross-validation"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_marketing_dataset
          
          # Test different algorithms with cross-validation
          algorithms = [:id3, :naive_bayes, :one_r]
          
          algorithms.each do |algorithm_type|
            puts "\n--- #{algorithm_type.to_s.upcase} Cross-Validation ---"
            
            classifier = EducationalClassification.new(algorithm_type, { verbose: false })
            cv_results = classifier.cross_validate(data_set, 5)
            
            puts "5-Fold Cross-Validation Results:"
            puts "Average Accuracy: #{cv_results[:average_accuracy].round(4)} ± #{cv_results[:accuracy_std].round(4)}"
            puts
            puts "Fold Results:"
            cv_results[:results].each do |fold_result|
              puts "  Fold #{fold_result[:fold]}: #{fold_result[:accuracy].round(4)}"
            end
          end
        end
        
        def run_feature_importance_analysis
          puts "=== Feature Importance Analysis ==="
          puts "Analyzing which features are most important for classification"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_marketing_dataset
          
          # Train ID3 to see feature usage
          classifier = EducationalClassification.new(:id3, {
            verbose: true,
            explain_predictions: false
          })
          
          classifier.build(data_set)
          
          # Show decision tree rules to understand feature importance
          puts "\n=== Decision Tree Rules (Feature Usage) ==="
          puts classifier.get_rules
          
          # Test with different feature combinations
          puts "\n=== Feature Sensitivity Analysis ==="
          test_case = ['young', 'student', 'single', 'fair']
          
          puts "Base case: #{test_case.inspect} => #{classifier.eval(test_case)}"
          
          # Test changing each feature
          data_set.data_labels[0...-1].each_with_index do |label, index|
            modified_case = test_case.dup
            
            # Get other possible values for this feature
            possible_values = data_set.data_items.map { |item| item[index] }.uniq
            
            possible_values.each do |new_value|
              next if new_value == test_case[index]
              
              modified_case[index] = new_value
              new_prediction = classifier.eval(modified_case)
              
              if new_prediction != classifier.eval(test_case)
                puts "Changing #{label} from '#{test_case[index]}' to '#{new_value}': #{new_prediction}"
              end
              
              modified_case[index] = test_case[index]  # Reset
            end
          end
        end
        
        def run_model_interpretability_example
          puts "=== Model Interpretability Example ==="
          puts "Understanding how different models make decisions"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_simple_binary_dataset
          
          # Train different models
          models = {
            id3: "ID3 Decision Tree",
            naive_bayes: "Naive Bayes",
            one_r: "OneR"
          }
          
          classifiers = {}
          
          models.each do |algorithm_type, algorithm_name|
            puts "\n--- Training #{algorithm_name} ---"
            
            classifier = EducationalClassification.new(algorithm_type, {
              verbose: false,
              explain_predictions: true
            })
            
            classifier.build(data_set)
            classifiers[algorithm_type] = classifier
            
            # Show model structure
            puts "\nModel Structure:"
            classifier.visualize
          end
          
          # Test prediction explanations
          puts "\n=== Prediction Explanations ==="
          test_case = ['sunny', 'hot', 'high']
          
          models.each do |algorithm_type, algorithm_name|
            puts "\n--- #{algorithm_name} ---"
            prediction = classifiers[algorithm_type].eval(test_case)
          end
          
          classifiers
        end
        
        def run_performance_metrics_tutorial
          puts "=== Performance Metrics Tutorial ==="
          puts "Understanding different evaluation metrics"
          puts
          
          # Generate sample data with class imbalance
          data_set = DatasetGenerator.generate_imbalanced_dataset
          train_set, test_set = DatasetGenerator.split_dataset(data_set, 0.8, 0.2)
          
          # Train classifier
          classifier = EducationalClassification.new(:id3, { verbose: false })
          classifier.build(train_set)
          
          # Evaluate performance
          evaluation = classifier.evaluate_performance(test_set)
          
          puts "=== Performance Metrics Explanation ==="
          puts "Test set size: #{evaluation[:test_size]}"
          puts "Overall accuracy: #{evaluation[:accuracy].round(4)}"
          puts
          
          # Show confusion matrix
          puts "=== Confusion Matrix ==="
          classifier.visualize
          
          # Explain metrics for each class
          puts "\n=== Per-Class Metrics ==="
          evaluation[:class_metrics].each do |class_name, metrics|
            puts "\nClass: #{class_name}"
            puts "  Precision: #{metrics[:precision].round(4)} (What % of predicted #{class_name} were actually #{class_name})"
            puts "  Recall: #{metrics[:recall].round(4)} (What % of actual #{class_name} were predicted as #{class_name})"
            puts "  F1-Score: #{metrics[:f1_score].round(4)} (Harmonic mean of precision and recall)"
            puts "  Support: #{metrics[:support]} (Number of actual #{class_name} examples)"
          end
          
          # Show why these metrics matter
          puts "\n=== Why These Metrics Matter ==="
          puts "• Accuracy can be misleading with imbalanced classes"
          puts "• Precision: Important when false positives are costly"
          puts "• Recall: Important when false negatives are costly"
          puts "• F1-Score: Balances precision and recall"
          puts "• Support: Shows how much data we have for each class"
          
          evaluation
        end
        
        def run_interactive_classification_tutorial
          puts "=== Interactive Classification Tutorial ==="
          puts "A comprehensive tutorial covering all classification concepts"
          puts
          
          puts "1. Basic Decision Tree Classification"
          run_basic_id3_example
          
          puts "\n" + "="*60 + "\n"
          
          puts "2. Probabilistic Classification (Naive Bayes)"
          run_naive_bayes_example
          
          puts "\n" + "="*60 + "\n"
          
          puts "3. Algorithm Comparison"
          run_algorithm_comparison
          
          puts "\n" + "="*60 + "\n"
          
          puts "4. Cross-Validation"
          run_cross_validation_example
          
          puts "\n" + "="*60 + "\n"
          
          puts "5. Feature Importance Analysis"
          run_feature_importance_analysis
          
          puts "\n" + "="*60 + "\n"
          
          puts "6. Model Interpretability"
          run_model_interpretability_example
          
          puts "\n" + "="*60 + "\n"
          
          puts "7. Performance Metrics"
          run_performance_metrics_tutorial
          
          puts "\n=== Tutorial Complete ==="
          puts "You've learned about:"
          puts "• Different classification algorithms and their strengths"
          puts "• How to evaluate model performance with multiple metrics"
          puts "• Cross-validation for reliable model assessment"
          puts "• Feature importance and model interpretability"
          puts "• How to handle class imbalance"
          puts "• Step-by-step algorithm execution"
        end
        
        def create_custom_classification_example(dataset_type, algorithm_type, parameters = {})
          puts "=== Custom Classification Example ==="
          puts "Dataset: #{dataset_type}, Algorithm: #{algorithm_type}"
          puts
          
          # Generate data based on type
          data_set = case dataset_type
          when :simple_binary
            DatasetGenerator.generate_simple_binary_dataset
          when :multiclass
            DatasetGenerator.generate_multiclass_dataset
          when :marketing
            DatasetGenerator.generate_marketing_dataset
          when :medical
            DatasetGenerator.generate_medical_dataset
          when :numeric
            DatasetGenerator.generate_numeric_dataset
          when :imbalanced
            DatasetGenerator.generate_imbalanced_dataset
          else
            DatasetGenerator.generate_simple_binary_dataset
          end
          
          # Split data if requested
          if parameters[:split_data]
            train_set, test_set = DatasetGenerator.split_dataset(data_set, 0.7, 0.3)
            data_set = train_set
          end
          
          # Create classifier
          classifier = EducationalClassification.new(algorithm_type, parameters)
          
          if parameters[:step_mode]
            classifier.enable_step_mode
          end
          
          if parameters[:visualization]
            classifier.enable_visualization
          end
          
          # Train classifier
          classifier.build(data_set)
          
          # Show results
          classifier.visualize
          
          # Evaluate if test set available
          if parameters[:split_data] && defined?(test_set)
            evaluation = classifier.evaluate_performance(test_set)
            puts "\nTest Set Evaluation:"
            puts "Accuracy: #{evaluation[:accuracy].round(4)}"
            
            # Show confusion matrix
            classifier.visualize
          end
          
          classifier
        end
      end
    end
  end
end