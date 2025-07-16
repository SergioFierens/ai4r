#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Classifier Benchmarking Example: The Iris Dataset Showdown
#
# This example demonstrates how to use the AI4R ClassifierBench to compare
# different classification algorithms on the classic Iris dataset.
#
# The Iris dataset contains measurements of iris flowers from three species:
# - Setosa
# - Versicolor
# - Virginica
#
# Features: sepal length, sepal width, petal length, petal width
#

require_relative '../../lib/ai4r'

# Helper method to create the classic Iris dataset
def load_iris_dataset
  labels = %w[sepal_length sepal_width petal_length petal_width species]

  # Iris dataset (a subset for demonstration)
  items = [
    # Setosa examples
    [5.1, 3.5, 1.4, 0.2, 'setosa'],
    [4.9, 3.0, 1.4, 0.2, 'setosa'],
    [4.7, 3.2, 1.3, 0.2, 'setosa'],
    [4.6, 3.1, 1.5, 0.2, 'setosa'],
    [5.0, 3.6, 1.4, 0.2, 'setosa'],
    [5.4, 3.9, 1.7, 0.4, 'setosa'],
    [4.6, 3.4, 1.4, 0.3, 'setosa'],
    [5.0, 3.4, 1.5, 0.2, 'setosa'],
    [4.4, 2.9, 1.4, 0.2, 'setosa'],
    [4.9, 3.1, 1.5, 0.1, 'setosa'],
    [5.4, 3.7, 1.5, 0.2, 'setosa'],
    [4.8, 3.4, 1.6, 0.2, 'setosa'],
    [4.8, 3.0, 1.4, 0.1, 'setosa'],
    [4.3, 3.0, 1.1, 0.1, 'setosa'],
    [5.8, 4.0, 1.2, 0.2, 'setosa'],
    [5.7, 4.4, 1.5, 0.4, 'setosa'],
    [5.4, 3.9, 1.3, 0.4, 'setosa'],
    [5.1, 3.5, 1.4, 0.3, 'setosa'],
    [5.7, 3.8, 1.7, 0.3, 'setosa'],
    [5.1, 3.8, 1.5, 0.3, 'setosa'],

    # Versicolor examples
    [7.0, 3.2, 4.7, 1.4, 'versicolor'],
    [6.4, 3.2, 4.5, 1.5, 'versicolor'],
    [6.9, 3.1, 4.9, 1.5, 'versicolor'],
    [5.5, 2.3, 4.0, 1.3, 'versicolor'],
    [6.5, 2.8, 4.6, 1.5, 'versicolor'],
    [5.7, 2.8, 4.5, 1.3, 'versicolor'],
    [6.3, 3.3, 4.7, 1.6, 'versicolor'],
    [4.9, 2.4, 3.3, 1.0, 'versicolor'],
    [6.6, 2.9, 4.6, 1.3, 'versicolor'],
    [5.2, 2.7, 3.9, 1.4, 'versicolor'],
    [5.0, 2.0, 3.5, 1.0, 'versicolor'],
    [5.9, 3.0, 4.2, 1.5, 'versicolor'],
    [6.0, 2.2, 4.0, 1.0, 'versicolor'],
    [6.1, 2.9, 4.7, 1.4, 'versicolor'],
    [5.6, 2.9, 3.6, 1.3, 'versicolor'],
    [6.7, 3.1, 4.4, 1.4, 'versicolor'],
    [5.6, 3.0, 4.5, 1.5, 'versicolor'],
    [5.8, 2.7, 4.1, 1.0, 'versicolor'],
    [6.2, 2.2, 4.5, 1.5, 'versicolor'],
    [5.6, 2.5, 3.9, 1.1, 'versicolor'],

    # Virginica examples
    [6.3, 3.3, 6.0, 2.5, 'virginica'],
    [5.8, 2.7, 5.1, 1.9, 'virginica'],
    [7.1, 3.0, 5.9, 2.1, 'virginica'],
    [6.3, 2.9, 5.6, 1.8, 'virginica'],
    [6.5, 3.0, 5.8, 2.2, 'virginica'],
    [7.6, 3.0, 6.6, 2.1, 'virginica'],
    [4.9, 2.5, 4.5, 1.7, 'virginica'],
    [7.3, 2.9, 6.3, 1.8, 'virginica'],
    [6.7, 2.5, 5.8, 1.8, 'virginica'],
    [7.2, 3.6, 6.1, 2.5, 'virginica'],
    [6.5, 3.2, 5.1, 2.0, 'virginica'],
    [6.4, 2.7, 5.3, 1.9, 'virginica'],
    [6.8, 3.0, 5.5, 2.1, 'virginica'],
    [5.7, 2.5, 5.0, 2.0, 'virginica'],
    [5.8, 2.8, 5.1, 2.4, 'virginica'],
    [6.4, 3.2, 5.3, 2.3, 'virginica'],
    [6.5, 3.0, 5.5, 1.8, 'virginica'],
    [7.7, 3.8, 6.7, 2.2, 'virginica'],
    [7.7, 2.6, 6.9, 2.3, 'virginica'],
    [6.0, 2.2, 5.0, 1.5, 'virginica']
  ]

  Ai4r::Data::DataSet.new(data_labels: labels, data_items: items)
end

# Main benchmark demonstration
def run_iris_benchmark
  puts '🌺 Welcome to the Iris Classification Benchmark! 🌺'
  puts '=' * 60
  puts "We'll compare different AI algorithms on the famous Iris dataset."
  puts 'Watch as they compete to correctly identify flower species!'
  puts '=' * 60
  puts

  # Load the dataset
  puts 'Loading Iris dataset...'
  dataset = load_iris_dataset
  puts "✓ Loaded #{dataset.data_items.size} flower samples"
  puts

  # Create the benchmark
  puts 'Setting up the benchmark arena...'
  bench = Ai4r::Experiment::ClassifierBench.new(
    verbose: true,
    cross_validation_folds: 5,
    educational_mode: true
  )

  # Add classifiers with friendly names
  puts 'Adding contestants to the competition...'

  # 1. Decision Tree - The Logical Thinker
  bench.add_classifier(
    :decision_tree,
    Ai4r::Classifiers::ID3.new,
    friendly_name: 'Decision Tree (ID3)'
  )
  puts '  ✓ Decision Tree - Makes choices like a flowchart'

  # 2. Naive Bayes - The Probability Pro
  bench.add_classifier(
    :naive_bayes,
    Ai4r::Classifiers::NaiveBayes.new,
    friendly_name: 'Naive Bayes'
  )
  puts '  ✓ Naive Bayes - Calculates probabilities like a statistician'

  # 3. K-Nearest Neighbors - The Social Butterfly
  bench.add_classifier(
    :knn,
    Ai4r::Classifiers::IB1.new,
    friendly_name: '1-Nearest Neighbor'
  )
  puts '  ✓ 1-Nearest Neighbor - Classifies by finding similar flowers'

  # 4. Neural Network - The Brain
  bench.add_classifier(
    :neural_net,
    Ai4r::Classifiers::MultilayerPerceptron.new([4, 10, 3]),
    friendly_name: 'Neural Network'
  )
  puts '  ✓ Neural Network - Mimics brain neurons with 10 hidden nodes'

  # 5. One Rule - The Minimalist
  bench.add_classifier(
    :one_rule,
    Ai4r::Classifiers::OneR.new,
    friendly_name: 'One Rule (OneR)'
  )
  puts '  ✓ One Rule - Keeps it simple with just one decision rule'

  # 6. Hyperpipes - The Geometer
  bench.add_classifier(
    :hyperpipes,
    Ai4r::Classifiers::Hyperpipes.new,
    friendly_name: 'Hyperpipes'
  )
  puts '  ✓ Hyperpipes - Uses geometric boundaries to classify'

  puts
  puts 'All contestants are ready! Let the benchmark begin!'
  puts

  # Run the benchmark
  results = bench.run(dataset)

  # Display comprehensive results
  bench.display_results(results)

  # Show educational insights
  insights = bench.generate_insights(results)
  puts insights

  # Export results
  puts "\nExporting results..."
  bench.export_results(:html, 'iris_benchmark_results')
  bench.export_results(:csv, 'iris_benchmark_results')
  puts '✓ Results exported to iris_benchmark_results.html and .csv'

  # Fun facts about the results
  puts "\n🎉 Fun Facts from the Benchmark! 🎉"
  puts '=' * 60

  # Find the most confident classifier
  most_accurate = results.max_by { |_, r| r[:metrics][:accuracy] }
  puts "🏆 Most Accurate: #{bench.classifiers[most_accurate[0]][:friendly_name]}"
  puts "   Achieved #{(most_accurate[1][:metrics][:accuracy] * 100).round(1)}% accuracy!"

  # Find the fastest classifier
  fastest = results.min_by { |_, r| r[:timing][:total_time] }
  puts "⚡ Speed Demon: #{bench.classifiers[fastest[0]][:friendly_name]}"
  puts "   Completed in just #{(fastest[1][:timing][:total_time] * 1000).round(1)}ms!"

  # Find the most stable classifier
  most_stable = results.min_by { |_, r| r[:metrics][:accuracy_std] || Float::INFINITY }
  puts "🎯 Most Stable: #{bench.classifiers[most_stable[0]][:friendly_name]}"
  puts "   Standard deviation of only #{(most_stable[1][:metrics][:accuracy_std] * 100).round(2)}%!"

  puts "\n💡 What did we learn?"
  puts '- Different algorithms excel at different things'
  puts "- There's often a trade-off between accuracy and speed"
  puts '- Simple algorithms can sometimes beat complex ones!'
  puts '- The Iris dataset is well-suited for most classifiers'

  puts "\n🔬 Try this experiment with your own data!"
end

# Interactive mode for exploring specific classifiers
def explore_classifier(classifier_name, dataset)
  puts "\n🔍 Deep Dive: #{classifier_name}"
  puts '-' * 40

  case classifier_name
  when 'Decision Tree'
    classifier = Ai4r::Classifiers::ID3.new
    classifier.build(dataset)

    puts 'Decision Tree Rules:'
    puts classifier.get_rules
    puts "\nThe tree makes decisions based on feature thresholds!"

  when 'Naive Bayes'
    classifier = Ai4r::Classifiers::NaiveBayes.new
    classifier.build(dataset)

    # Test with a sample
    sample = [5.1, 3.5, 1.4, 0.2] # Typical setosa measurements
    puts "Testing with sample: #{sample}"
    prediction = classifier.eval(sample)
    puts "Prediction: #{prediction}"

    if classifier.respond_to?(:get_probability_map)
      probs = classifier.get_probability_map(sample)
      puts "Probabilities: #{probs}"
    end
  end
end

# Run the benchmark if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  begin
    run_iris_benchmark

    # Optional: Explore specific classifiers
    # dataset = load_iris_dataset
    # explore_classifier("Decision Tree", dataset)
  rescue StandardError => e
    puts "❌ Error: #{e.message}"
    puts e.backtrace.first(5)
  end
end
