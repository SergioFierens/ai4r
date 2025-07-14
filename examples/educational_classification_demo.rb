#!/usr/bin/env ruby
# frozen_string_literal: true

# Educational Classification Framework Demo
# This script demonstrates the enhanced classification capabilities for learning

require_relative '../lib/ai4r'

puts "=== AI4R Educational Classification Framework Demo ==="
puts "Demonstrating educational improvements to classification algorithms"
puts

# Demo 1: Basic ID3 Decision Tree with step-by-step execution
puts "1. Basic ID3 Decision Tree with Educational Features"
puts "=" * 50

# Generate sample data
data_set = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.generate_simple_binary_dataset
puts "Generated dataset: #{data_set.data_items.length} examples with #{data_set.data_labels.length - 1} features"

# Create educational classifier
classifier = Ai4r::Classifiers::EducationalClassification.new(:id3, {
  verbose: true,
  explain_predictions: true
})

# Enable educational features
classifier.enable_visualization

# Train classifier
puts "\nTraining ID3 decision tree..."
classifier.build(data_set)

# Show decision tree rules
puts "\nDecision Tree Rules:"
puts classifier.get_rules

# Test predictions
puts "\nTest Predictions:"
test_cases = [
  ['sunny', 'hot', 'high'],
  ['overcast', 'mild', 'normal'],
  ['rainy', 'cool', 'high']
]

test_cases.each do |test_case|
  prediction = classifier.eval(test_case)
  puts "#{test_case.inspect} => #{prediction}"
end

# Show model visualization
puts "\nModel Visualization:"
classifier.visualize

puts "\n" + "=" * 60 + "\n"

# Demo 2: Naive Bayes with probability explanations
puts "2. Naive Bayes with Probability Explanations"
puts "=" * 50

# Generate marketing data
marketing_data = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.generate_marketing_dataset
puts "Generated marketing dataset: #{marketing_data.data_items.length} examples"

# Create Naive Bayes classifier
nb_classifier = Ai4r::Classifiers::EducationalClassification.new(:naive_bayes, {
  verbose: false,
  explain_predictions: true
})

# Train classifier
puts "\nTraining Naive Bayes classifier..."
nb_classifier.build(marketing_data)

# Test predictions with confidence
puts "\nTest Predictions with Probabilities:"
test_cases = [
  ['young', 'student', 'single', 'fair'],
  ['senior', 'employee', 'married', 'excellent']
]

test_cases.each do |test_case|
  result = nb_classifier.predict_with_confidence(test_case)
  puts "#{test_case.inspect}:"
  puts "  Prediction: #{result[:prediction]}"
  puts "  Confidence: #{result[:confidence].round(4)}"
  puts "  Probabilities: #{result[:probabilities].map { |k, v| "#{k}: #{v.round(4)}" }.join(', ')}"
  puts
end

puts "\n" + "=" * 60 + "\n"

# Demo 3: Algorithm Comparison
puts "3. Classification Algorithm Comparison"
puts "=" * 50

# Generate multiclass data and split
multiclass_data = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.generate_multiclass_dataset
train_set, test_set = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.split_dataset(multiclass_data, 0.7, 0.3)

algorithms = [
  [:id3, "ID3 Decision Tree"],
  [:naive_bayes, "Naive Bayes"],
  [:one_r, "OneR"],
  [:zero_r, "ZeroR (Baseline)"]
]

results = {}

algorithms.each do |algorithm_type, algorithm_name|
  puts "\n--- Testing #{algorithm_name} ---"
  
  classifier = Ai4r::Classifiers::EducationalClassification.new(algorithm_type, {
    verbose: false
  })
  
  classifier.build(train_set)
  evaluation = classifier.evaluate_performance(test_set)
  
  results[algorithm_type] = {
    name: algorithm_name,
    evaluation: evaluation
  }
  
  puts "Accuracy: #{evaluation[:accuracy].round(4)}"
  puts "Test examples: #{evaluation[:test_size]}"
end

# Compare results
puts "\n=== Algorithm Performance Comparison ==="
puts "Algorithm              | Accuracy | Test Size"
puts "-----------------------|----------|----------"
results.each do |algorithm_type, result|
  evaluation = result[:evaluation]
  puts sprintf("%-22s | %8.4f | %9d", 
    result[:name], 
    evaluation[:accuracy], 
    evaluation[:test_size]
  )
end

puts "\n" + "=" * 60 + "\n"

# Demo 4: Feature Analysis
puts "4. Feature Analysis and Engineering"
puts "=" * 50

# Generate dataset with mixed features
mixed_data = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.generate_numeric_dataset
puts "Generated mixed dataset: #{mixed_data.data_items.length} examples"

# Analyze features
puts "\nFeature Analysis:"
analyzer = Ai4r::Classifiers::FeatureAnalyzer.new(mixed_data)
analyzer.analyze_features

puts "\n" + "=" * 60 + "\n"

# Demo 5: Cross-Validation
puts "5. Cross-Validation Example"
puts "=" * 50

# Use simple dataset for cross-validation
cv_data = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.generate_simple_binary_dataset
puts "Dataset for cross-validation: #{cv_data.data_items.length} examples"

# Test ID3 with cross-validation
puts "\n--- ID3 Cross-Validation ---"
id3_classifier = Ai4r::Classifiers::EducationalClassification.new(:id3, { verbose: false })
cv_results = id3_classifier.cross_validate(cv_data, 5)

puts "5-Fold Cross-Validation Results:"
puts "Average Accuracy: #{cv_results[:average_accuracy].round(4)} ± #{cv_results[:accuracy_std].round(4)}"
puts
puts "Individual Fold Results:"
cv_results[:results].each do |fold_result|
  puts "  Fold #{fold_result[:fold]}: #{fold_result[:accuracy].round(4)}"
end

puts "\n" + "=" * 60 + "\n"

# Demo 6: Performance Metrics Tutorial
puts "6. Performance Metrics Tutorial"
puts "=" * 50

# Use imbalanced dataset to show different metrics
imbalanced_data = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.generate_imbalanced_dataset
train_set, test_set = Ai4r::Classifiers::EducationalExamples::DatasetGenerator.split_dataset(imbalanced_data, 0.8, 0.2)

puts "Imbalanced dataset: #{imbalanced_data.data_items.length} examples"

# Train classifier
metrics_classifier = Ai4r::Classifiers::EducationalClassification.new(:id3, { verbose: false })
metrics_classifier.build(train_set)

# Evaluate with comprehensive metrics
evaluation = metrics_classifier.evaluate_performance(test_set)

puts "\n=== Performance Metrics ==="
puts "Overall Accuracy: #{evaluation[:accuracy].round(4)}"
puts

# Show confusion matrix
puts "Confusion Matrix:"
metrics_classifier.visualize

puts "\n" + "=" * 60 + "\n"

puts "=== Demo Complete ==="
puts "The educational classification framework provides:"
puts "✓ Step-by-step algorithm execution"
puts "✓ Prediction explanations and reasoning"
puts "✓ Comprehensive performance evaluation"
puts "✓ Cross-validation for reliable assessment"
puts "✓ Feature analysis and engineering tools"
puts "✓ Algorithm comparison capabilities"
puts "✓ Educational visualizations"
puts "✓ Real-world datasets and examples"
puts
puts "This transforms classification from a black box into an interactive learning experience!"
puts "See docs/classification-tutorial.md for complete documentation."
puts
puts "Available educational examples:"
puts "• Ai4r::Classifiers::EducationalExamples.run_basic_id3_example"
puts "• Ai4r::Classifiers::EducationalExamples.run_naive_bayes_example"
puts "• Ai4r::Classifiers::EducationalExamples.run_algorithm_comparison"
puts "• Ai4r::Classifiers::EducationalExamples.run_cross_validation_example"
puts "• Ai4r::Classifiers::EducationalExamples.run_interactive_classification_tutorial"