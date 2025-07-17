#!/usr/bin/env ruby
# Simple test for classifier bench functionality

# Load just the needed files for testing
require_relative 'lib/ai4r/data/data_set'
require_relative 'lib/ai4r/classifiers/classifier'
require_relative 'lib/ai4r/classifiers/id3'
require_relative 'lib/ai4r/classifiers/naive_bayes'
require_relative 'lib/ai4r/classifiers/zero_r'
require_relative 'lib/ai4r/experiment/classifier_bench'

# Create simple test data with categorical features
def create_categorical_test_data
  Ai4r::Data::DataSet.new(
    data_labels: ['size', 'color', 'class'],
    data_items: [
      ['small', 'red', 'A'],
      ['small', 'red', 'A'],
      ['small', 'blue', 'A'],
      ['small', 'blue', 'A'],
      ['small', 'red', 'A'],
      ['medium', 'green', 'B'],
      ['medium', 'green', 'B'],
      ['medium', 'blue', 'B'],
      ['medium', 'blue', 'B'],
      ['medium', 'green', 'B'],
      ['large', 'yellow', 'C'],
      ['large', 'yellow', 'C'],
      ['large', 'red', 'C'],
      ['large', 'red', 'C'],
      ['large', 'yellow', 'C']
    ]
  )
end

# Create test data with numeric features
def create_numeric_test_data
  Ai4r::Data::DataSet.new(
    data_labels: ['feature1', 'feature2', 'class'],
    data_items: [
      [1.0, 2.0, 'A'],
      [1.1, 2.1, 'A'],
      [1.2, 2.2, 'A'],
      [1.3, 2.3, 'A'],
      [1.4, 2.4, 'A'],
      [3.0, 4.0, 'B'],
      [3.1, 4.1, 'B'],
      [3.2, 4.2, 'B'],
      [3.3, 4.3, 'B'],
      [3.4, 4.4, 'B'],
      [5.0, 6.0, 'C'],
      [5.1, 6.1, 'C'],
      [5.2, 6.2, 'C'],
      [5.3, 6.3, 'C'],
      [5.4, 6.4, 'C']
    ]
  )
end

# Test basic functionality
puts "🧪 Testing Classifier Bench..."
puts "=" * 40

# Test 1: Categorical Data
puts "\n📊 Test 1: Categorical Data"
puts "=" * 30
puts "Creating categorical test dataset..."
dataset = create_categorical_test_data
puts "✓ Dataset created with #{dataset.data_items.size} samples"

bench = Ai4r::Experiment::ClassifierBench.new(verbose: false)
bench.add_classifier(:id3, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)
bench.add_classifier(:zero_r, Ai4r::Classifiers::ZeroR.new)

begin
  results = bench.run(dataset)
  puts "✓ Categorical benchmark completed successfully!"
  
  results.each do |name, result|
    accuracy = result[:metrics][:accuracy] || 0.0
    time = result[:timing][:total_time] || 0.0
    puts "  #{name}: #{(accuracy * 100).round(1)}% accuracy, #{(time * 1000).round(2)}ms"
  end
rescue => e
  puts "❌ Error: #{e.message}"
end

# Test 2: Numeric Data
puts "\n📊 Test 2: Numeric Data (with compatibility warnings)"
puts "=" * 50
puts "Creating numeric test dataset..."
dataset = create_numeric_test_data
puts "✓ Dataset created with #{dataset.data_items.size} samples"

bench = Ai4r::Experiment::ClassifierBench.new(verbose: true)
bench.add_classifier(:id3, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)
bench.add_classifier(:zero_r, Ai4r::Classifiers::ZeroR.new)

begin
  results = bench.run(dataset)
  puts "✓ Numeric benchmark completed!"
  
  results.each do |name, result|
    accuracy = result[:metrics][:accuracy] || 0.0
    time = result[:timing][:total_time] || 0.0
    errors = result[:errors] || []
    puts "  #{name}: #{(accuracy * 100).round(1)}% accuracy, #{(time * 1000).round(2)}ms"
    puts "    Errors: #{errors.map { |e| e[:message] }.join(', ')}" if errors.any?
  end
rescue => e
  puts "❌ Error: #{e.message}"
end

# Test export
puts "\n📁 Testing export..."
bench.export_results(:csv, "test_results")
puts "✓ Export test completed"

# Clean up
File.delete("test_results.csv") if File.exist?("test_results.csv")

puts "\n🎉 All tests completed!"