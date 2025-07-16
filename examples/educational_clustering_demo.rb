#!/usr/bin/env ruby
# frozen_string_literal: true

# Educational Clustering Framework Demo
# This script demonstrates the enhanced clustering capabilities for learning

require_relative '../lib/ai4r'

puts '=== AI4R Educational Clustering Framework Demo ==='
puts 'Demonstrating educational improvements to clustering algorithms'
puts

# Demo 1: Basic K-Means with step-by-step execution
puts '1. Basic K-Means with Educational Features'
puts '=' * 50

# Generate sample data
data_set = Ai4r::Clusterers::EducationalExamples::DatasetGenerator.generate_blobs(50, 3, 2, 1.0)
puts "Generated dataset: #{data_set.data_items.length} points for 3 clusters"

# Create educational clustering
clustering = Ai4r::Clusterers::EducationalClustering.new(:k_means, {
                                                           max_iterations: 20,
                                                           tolerance: 0.01,
                                                           verbose: true,
                                                           initialization_strategy: :k_means_plus_plus
                                                         })

# Enable educational features
clustering.enable_visualization

# Run clustering
puts "\nRunning K-Means clustering..."
clustering.build(data_set, 3)

# Show results
puts "\nClustering Results:"
clustering.visualize

# Evaluate quality
quality = clustering.evaluate_quality
puts "\nQuality Metrics:"
puts "  Silhouette Score: #{quality[:silhouette_score].round(4)}"
puts "  Within-Cluster Sum of Squares: #{quality[:within_cluster_sum_of_squares].round(2)}"
puts "  Between-Cluster Sum of Squares: #{quality[:between_cluster_sum_of_squares].round(2)}"

puts "\n#{'=' * 60}\n"

# Demo 2: Distance Metrics Comparison
puts '2. Distance Metrics Educational Comparison'
puts '=' * 50

# Show available metrics
puts 'Available distance metrics:'
metrics = Ai4r::Clusterers::DistanceMetrics.get_all_metrics
metrics.each_value do |info|
  puts "  • #{info[:name]}: #{info[:description]}"
end

# Test with sample points
puts "\nTesting distance metrics with sample points:"
point1 = [1.0, 2.0]
point2 = [4.0, 5.0]
puts "Point 1: #{point1}"
puts "Point 2: #{point2}"
puts
puts 'Distance calculations:'
puts 'Metric               | Distance'
puts '---------------------|----------'

%i[euclidean manhattan cosine chebyshev].each do |metric_name|
  metric_info = metrics[metric_name]
  if metric_info
    distance = metric_info[:function].call(point1, point2)
    puts format('%-20s | %8.4f', metric_info[:name], distance)
  end
end

puts "\n#{'=' * 60}\n"

# Demo 3: Algorithm Comparison
puts '3. Clustering Algorithm Comparison'
puts '=' * 50

# Generate sample data
data_set = Ai4r::Clusterers::EducationalExamples::DatasetGenerator.generate_blobs(40, 3, 2, 1.2)

algorithms = [
  [:k_means, 'K-Means'],
  [:hierarchical_single, 'Hierarchical (Single)'],
  [:diana, 'DIANA']
]

results = {}

algorithms.each do |algorithm_type, algorithm_name|
  puts "\nTesting #{algorithm_name}..."

  clustering = Ai4r::Clusterers::EducationalClustering.new(algorithm_type, {
                                                             verbose: false
                                                           })

  clustering.build(data_set, 3)
  quality = clustering.evaluate_quality

  results[algorithm_type] = {
    name: algorithm_name,
    quality: quality
  }

  puts "  Silhouette Score: #{quality[:silhouette_score].round(4)}"
end

# Compare results
puts "\nAlgorithm Comparison Summary:"
puts 'Algorithm           | Silhouette | WCSS     | BCSS'
puts '--------------------|------------|----------|----------'
results.each_value do |result|
  quality = result[:quality]
  puts format('%-19s | %10.4f | %8.2f | %8.2f',
              result[:name],
              quality[:silhouette_score],
              quality[:within_cluster_sum_of_squares],
              quality[:between_cluster_sum_of_squares])
end

puts "\n#{'=' * 60}\n"

# Demo 4: Challenging Datasets
puts '4. Testing on Challenging Datasets'
puts '=' * 50

challenging_datasets = [
  ['Moons', Ai4r::Clusterers::EducationalExamples::DatasetGenerator.generate_moons(30, 0.1)],
  ['Circles', Ai4r::Clusterers::EducationalExamples::DatasetGenerator.generate_circles(30, 0.1)]
]

challenging_datasets.each do |dataset_name, data_set|
  puts "\n--- #{dataset_name} Dataset ---"

  # Test K-Means
  kmeans = Ai4r::Clusterers::EducationalClustering.new(:k_means, { verbose: false })
  kmeans.build(data_set, 2)
  kmeans_quality = kmeans.evaluate_quality

  # Test Hierarchical
  hierarchical = Ai4r::Clusterers::EducationalClustering.new(:hierarchical_single, { verbose: false })
  hierarchical.build(data_set, 2)
  hierarchical_quality = hierarchical.evaluate_quality

  puts "K-Means Silhouette Score: #{kmeans_quality[:silhouette_score].round(4)}"
  puts "Hierarchical Silhouette Score: #{hierarchical_quality[:silhouette_score].round(4)}"

  puts "\nK-Means Visualization:"
  kmeans.visualize
end

puts "\n#{'=' * 60}\n"

# Demo 5: Educational Examples
puts '5. Available Educational Examples'
puts '=' * 50

puts 'The framework includes several educational examples:'
puts '• run_basic_kmeans_example - Interactive K-means tutorial'
puts '• run_hierarchical_comparison - Compare linkage methods'
puts '• run_distance_metrics_comparison - Distance metric effects'
puts '• run_algorithm_comparison - Algorithm trade-offs'
puts '• run_challenging_datasets_example - Non-spherical data'
puts '• run_optimal_k_analysis - Finding optimal cluster count'
puts '• run_clustering_tutorial - Complete interactive tutorial'

puts "\nTo run any example:"
puts 'Ai4r::Clusterers::EducationalExamples.run_basic_kmeans_example'

puts "\n#{'=' * 60}\n"

puts '=== Demo Complete ==='
puts 'The educational clustering framework provides:'
puts '✓ Step-by-step algorithm execution'
puts '✓ Multiple distance metrics with explanations'
puts '✓ Quality evaluation tools'
puts '✓ Algorithm comparison capabilities'
puts '✓ Visualization features'
puts '✓ Challenging dataset testing'
puts '✓ Educational examples and tutorials'
puts '✓ Export capabilities for further analysis'
puts
puts 'This transforms clustering from a black box into an interactive learning experience!'
puts 'See docs/clustering-tutorial.md for complete documentation.'
