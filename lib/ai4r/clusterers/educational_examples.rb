# frozen_string_literal: true

# Educational examples for clustering algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'educational_clustering'
require_relative 'educational_algorithms'
require_relative '../data/data_set'

module Ai4r
  module Clusterers
    module EducationalExamples
      
      # Generate different types of synthetic datasets for educational purposes
      class DatasetGenerator
        
        def self.generate_blobs(n_samples = 150, n_clusters = 3, n_features = 2, cluster_std = 1.0)
          data_items = []
          cluster_centers = []
          
          # Generate random cluster centers
          n_clusters.times do
            center = Array.new(n_features) { rand(-10.0..10.0) }
            cluster_centers << center
          end
          
          # Generate points around each center
          points_per_cluster = n_samples / n_clusters
          
          cluster_centers.each_with_index do |center, cluster_index|
            points_per_cluster.times do
              point = center.map { |coord| coord + (rand(-1.0..1.0) * cluster_std) }
              data_items << point
            end
          end
          
          # Add some additional random points
          remaining_points = n_samples - (points_per_cluster * n_clusters)
          remaining_points.times do
            center = cluster_centers.sample
            point = center.map { |coord| coord + (rand(-1.0..1.0) * cluster_std) }
            data_items << point
          end
          
          data_labels = (0...n_features).map { |i| "feature_#{i}" }
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_circles(n_samples = 200, noise = 0.1, factor = 0.8)
          data_items = []
          outer_samples = n_samples / 2
          inner_samples = n_samples - outer_samples
          
          # Generate outer circle
          outer_samples.times do
            angle = rand * 2 * Math::PI
            radius = 1.0 + (rand(-1.0..1.0) * noise)
            x = radius * Math.cos(angle)
            y = radius * Math.sin(angle)
            data_items << [x, y]
          end
          
          # Generate inner circle
          inner_samples.times do
            angle = rand * 2 * Math::PI
            radius = factor + (rand(-1.0..1.0) * noise)
            x = radius * Math.cos(angle)
            y = radius * Math.sin(angle)
            data_items << [x, y]
          end
          
          data_labels = ['x', 'y']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_moons(n_samples = 200, noise = 0.1)
          data_items = []
          samples_per_moon = n_samples / 2
          
          # Generate first moon
          samples_per_moon.times do
            angle = rand * Math::PI
            x = Math.cos(angle) + (rand(-1.0..1.0) * noise)
            y = Math.sin(angle) + (rand(-1.0..1.0) * noise)
            data_items << [x, y]
          end
          
          # Generate second moon
          samples_per_moon.times do
            angle = rand * Math::PI
            x = 1 - Math.cos(angle) + (rand(-1.0..1.0) * noise)
            y = 1 - Math.sin(angle) - 0.5 + (rand(-1.0..1.0) * noise)
            data_items << [x, y]
          end
          
          data_labels = ['x', 'y']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.generate_anisotropic_blobs(n_samples = 200, n_clusters = 3)
          data_items = []
          
          # Generate clusters with different shapes
          n_clusters.times do |cluster_index|
            samples_per_cluster = n_samples / n_clusters
            
            # Random center
            center_x = rand(-5.0..5.0)
            center_y = rand(-5.0..5.0)
            
            # Random transformation matrix for anisotropic shape
            a = rand(0.5..2.0)
            b = rand(0.5..2.0)
            theta = rand(0..2*Math::PI)
            
            samples_per_cluster.times do
              # Generate point in unit circle
              r = Math.sqrt(rand)
              angle = rand * 2 * Math::PI
              x = r * Math.cos(angle)
              y = r * Math.sin(angle)
              
              # Apply transformation
              x_transformed = a * (x * Math.cos(theta) - y * Math.sin(theta))
              y_transformed = b * (x * Math.sin(theta) + y * Math.cos(theta))
              
              data_items << [center_x + x_transformed, center_y + y_transformed]
            end
          end
          
          data_labels = ['x', 'y']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
        
        def self.load_iris_subset
          # Simple iris-like dataset for demonstration
          data_items = [
            [5.1, 3.5, 1.4, 0.2], [4.9, 3.0, 1.4, 0.2], [4.7, 3.2, 1.3, 0.2],
            [4.6, 3.1, 1.5, 0.2], [5.0, 3.6, 1.4, 0.2], [5.4, 3.9, 1.7, 0.4],
            [7.0, 3.2, 4.7, 1.4], [6.4, 3.2, 4.5, 1.5], [6.9, 3.1, 4.9, 1.5],
            [5.5, 2.3, 4.0, 1.3], [6.5, 2.8, 4.6, 1.5], [5.7, 2.8, 4.5, 1.3],
            [6.3, 3.3, 6.0, 2.5], [5.8, 2.7, 5.1, 1.9], [7.1, 3.0, 5.9, 2.1],
            [6.3, 2.9, 5.6, 1.8], [6.5, 3.0, 5.8, 2.2], [7.6, 3.0, 6.6, 2.1]
          ]
          
          data_labels = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width']
          Ai4r::Data::DataSet.new(data_labels: data_labels, data_items: data_items)
        end
      end
      
      # Distance metrics for educational comparison
      class DistanceMetrics
        
        def self.euclidean_distance
          lambda do |a, b|
            numeric_a = a.select { |attr| attr.is_a?(Numeric) }
            numeric_b = b.select { |attr| attr.is_a?(Numeric) }
            
            sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y) ** 2 }
            Math.sqrt(sum)
          end
        end
        
        def self.manhattan_distance
          lambda do |a, b|
            numeric_a = a.select { |attr| attr.is_a?(Numeric) }
            numeric_b = b.select { |attr| attr.is_a?(Numeric) }
            
            numeric_a.zip(numeric_b).sum { |x, y| (x - y).abs }
          end
        end
        
        def self.cosine_distance
          lambda do |a, b|
            numeric_a = a.select { |attr| attr.is_a?(Numeric) }
            numeric_b = b.select { |attr| attr.is_a?(Numeric) }
            
            dot_product = numeric_a.zip(numeric_b).sum { |x, y| x * y }
            magnitude_a = Math.sqrt(numeric_a.sum { |x| x ** 2 })
            magnitude_b = Math.sqrt(numeric_b.sum { |x| x ** 2 })
            
            return 1.0 if magnitude_a == 0 || magnitude_b == 0
            
            1.0 - (dot_product / (magnitude_a * magnitude_b))
          end
        end
        
        def self.chebyshev_distance
          lambda do |a, b|
            numeric_a = a.select { |attr| attr.is_a?(Numeric) }
            numeric_b = b.select { |attr| attr.is_a?(Numeric) }
            
            numeric_a.zip(numeric_b).map { |x, y| (x - y).abs }.max
          end
        end
        
        def self.get_all_metrics
          {
            euclidean: euclidean_distance,
            manhattan: manhattan_distance,
            cosine: cosine_distance,
            chebyshev: chebyshev_distance
          }
        end
      end
      
      # Educational runner methods
      class << self
        
        def run_basic_kmeans_example
          puts "=== Basic K-Means Example ==="
          puts "Demonstrating K-Means clustering with step-by-step execution"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_blobs(100, 3, 2, 1.5)
          
          # Create educational clustering
          clustering = EducationalClustering.new(:k_means, {
            max_iterations: 50,
            tolerance: 0.001,
            verbose: true,
            initialization_strategy: :random
          })
          
          clustering.enable_step_mode.enable_visualization
          
          # Run clustering
          clustering.build(data_set, 3)
          
          # Show results
          puts "\n=== Results ==="
          clustering.visualize
          
          # Evaluate quality
          quality = clustering.evaluate_quality
          puts "\nQuality Metrics:"
          quality.each { |metric, value| puts "  #{metric}: #{value}" }
          
          # Export results
          clustering.export_data("kmeans_results.csv")
          
          clustering
        end
        
        def run_hierarchical_comparison
          puts "=== Hierarchical Clustering Comparison ==="
          puts "Comparing different linkage methods"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_blobs(50, 3, 2, 1.0)
          
          linkage_methods = [:single, :complete, :average, :ward]
          results = {}
          
          linkage_methods.each do |linkage|
            puts "\n--- #{linkage.to_s.capitalize} Linkage ---"
            
            clustering = EducationalClustering.new(:hierarchical_single, {
              verbose: true,
              linkage_type: linkage
            })
            
            clustering.build(data_set, 3)
            results[linkage] = clustering.evaluate_quality
            
            puts "Quality: Silhouette = #{results[linkage][:silhouette_score].round(4)}"
          end
          
          # Compare results
          puts "\n=== Linkage Method Comparison ==="
          puts "Method      | Silhouette | WCSS     | BCSS"
          puts "------------|------------|----------|----------"
          linkage_methods.each do |linkage|
            quality = results[linkage]
            puts sprintf("%-11s | %10.4f | %8.2f | %8.2f", 
              linkage.to_s.capitalize,
              quality[:silhouette_score],
              quality[:within_cluster_sum_of_squares],
              quality[:between_cluster_sum_of_squares]
            )
          end
          
          results
        end
        
        def run_distance_metrics_comparison
          puts "=== Distance Metrics Comparison ==="
          puts "Comparing different distance metrics with K-Means"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_blobs(80, 4, 2, 1.2)
          
          metrics = DistanceMetrics.get_all_metrics
          results = {}
          
          metrics.each do |metric_name, metric_function|
            puts "\n--- #{metric_name.to_s.capitalize} Distance ---"
            
            clustering = EducationalClustering.new(:k_means, {
              distance_function: metric_function,
              max_iterations: 30,
              verbose: true
            })
            
            clustering.build(data_set, 4)
            results[metric_name] = clustering.evaluate_quality
            
            puts "Quality: Silhouette = #{results[metric_name][:silhouette_score].round(4)}"
          end
          
          # Compare results
          puts "\n=== Distance Metric Comparison ==="
          puts "Metric      | Silhouette | WCSS     | BCSS"
          puts "------------|------------|----------|----------"
          metrics.keys.each do |metric_name|
            quality = results[metric_name]
            puts sprintf("%-11s | %10.4f | %8.2f | %8.2f", 
              metric_name.to_s.capitalize,
              quality[:silhouette_score],
              quality[:within_cluster_sum_of_squares],
              quality[:between_cluster_sum_of_squares]
            )
          end
          
          results
        end
        
        def run_algorithm_comparison
          puts "=== Algorithm Comparison ==="
          puts "Comparing K-Means, Hierarchical, and DIANA clustering"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_blobs(60, 3, 2, 1.0)
          
          algorithms = [
            [:k_means, "K-Means"],
            [:hierarchical_single, "Hierarchical (Single)"],
            [:diana, "DIANA"]
          ]
          
          results = {}
          
          algorithms.each do |algorithm_type, algorithm_name|
            puts "\n--- #{algorithm_name} ---"
            
            clustering = EducationalClustering.new(algorithm_type, {
              max_iterations: 50,
              verbose: true
            })
            
            clustering.build(data_set, 3)
            results[algorithm_type] = {
              clustering: clustering,
              quality: clustering.evaluate_quality
            }
            
            puts "Quality: Silhouette = #{results[algorithm_type][:quality][:silhouette_score].round(4)}"
          end
          
          # Compare results
          puts "\n=== Algorithm Comparison ==="
          puts "Algorithm           | Silhouette | WCSS     | BCSS"
          puts "--------------------|------------|----------|----------"
          algorithms.each do |algorithm_type, algorithm_name|
            quality = results[algorithm_type][:quality]
            puts sprintf("%-19s | %10.4f | %8.2f | %8.2f", 
              algorithm_name,
              quality[:silhouette_score],
              quality[:within_cluster_sum_of_squares],
              quality[:between_cluster_sum_of_squares]
            )
          end
          
          results
        end
        
        def run_challenging_datasets_example
          puts "=== Challenging Datasets Example ==="
          puts "Testing algorithms on non-spherical data"
          puts
          
          datasets = [
            ["Moons", DatasetGenerator.generate_moons(100, 0.1)],
            ["Circles", DatasetGenerator.generate_circles(100, 0.1)],
            ["Anisotropic", DatasetGenerator.generate_anisotropic_blobs(100, 3)]
          ]
          
          datasets.each do |dataset_name, data_set|
            puts "\n=== #{dataset_name} Dataset ==="
            
            # Try K-Means
            puts "\nK-Means Results:"
            kmeans = EducationalClustering.new(:k_means, { verbose: false })
            kmeans.build(data_set, 2)
            kmeans_quality = kmeans.evaluate_quality
            puts "  Silhouette Score: #{kmeans_quality[:silhouette_score].round(4)}"
            
            # Try Hierarchical
            puts "\nHierarchical Results:"
            hierarchical = EducationalClustering.new(:hierarchical_single, { verbose: false })
            hierarchical.build(data_set, 2)
            hierarchical_quality = hierarchical.evaluate_quality
            puts "  Silhouette Score: #{hierarchical_quality[:silhouette_score].round(4)}"
            
            # Visualize results
            puts "\nK-Means Visualization:"
            kmeans.visualize
            puts "\nHierarchical Visualization:"
            hierarchical.visualize
          end
        end
        
        def run_optimal_k_analysis
          puts "=== Optimal K Analysis ==="
          puts "Finding optimal number of clusters using elbow method"
          puts
          
          # Generate sample data
          data_set = DatasetGenerator.generate_blobs(120, 4, 2, 1.2)
          
          k_values = (1..10).to_a
          wcss_values = []
          silhouette_values = []
          
          k_values.each do |k|
            clustering = EducationalClustering.new(:k_means, { verbose: false })
            clustering.build(data_set, k)
            
            quality = clustering.evaluate_quality
            wcss_values << quality[:within_cluster_sum_of_squares]
            silhouette_values << (k > 1 ? quality[:silhouette_score] : 0)
            
            puts "K=#{k}: WCSS=#{quality[:within_cluster_sum_of_squares].round(2)}, Silhouette=#{quality[:silhouette_score].round(4)}"
          end
          
          # Plot elbow curve
          puts "\n=== Elbow Plot (WCSS) ==="
          puts "K | WCSS"
          puts "--|" + "-" * 50
          max_wcss = wcss_values.max
          k_values.each_with_index do |k, index|
            wcss = wcss_values[index]
            bar_length = (wcss / max_wcss * 50).to_i
            bar = "█" * bar_length
            puts sprintf("%2d| %s %.2f", k, bar, wcss)
          end
          
          # Plot silhouette scores
          puts "\n=== Silhouette Scores ==="
          puts "K | Silhouette"
          puts "--|" + "-" * 50
          k_values.each_with_index do |k, index|
            next if k == 1
            silhouette = silhouette_values[index]
            bar_length = [(silhouette * 50).to_i, 0].max
            bar = "█" * bar_length
            puts sprintf("%2d| %s %.4f", k, bar, silhouette)
          end
          
          # Find optimal K
          optimal_k_elbow = find_elbow_point(wcss_values)
          optimal_k_silhouette = silhouette_values.each_with_index.max[1] + 1
          
          puts "\nOptimal K suggestions:"
          puts "  Elbow method: K = #{optimal_k_elbow + 1}"
          puts "  Silhouette method: K = #{optimal_k_silhouette}"
          
          { k_values: k_values, wcss_values: wcss_values, silhouette_values: silhouette_values }
        end
        
        def run_clustering_tutorial
          puts "=== Interactive Clustering Tutorial ==="
          puts "A comprehensive tutorial covering all clustering concepts"
          puts
          
          puts "1. Basic K-Means clustering"
          run_basic_kmeans_example
          
          puts "\n" + "="*60 + "\n"
          
          puts "2. Hierarchical clustering comparison"
          run_hierarchical_comparison
          
          puts "\n" + "="*60 + "\n"
          
          puts "3. Distance metrics comparison"
          run_distance_metrics_comparison
          
          puts "\n" + "="*60 + "\n"
          
          puts "4. Algorithm comparison"
          run_algorithm_comparison
          
          puts "\n" + "="*60 + "\n"
          
          puts "5. Challenging datasets"
          run_challenging_datasets_example
          
          puts "\n" + "="*60 + "\n"
          
          puts "6. Optimal K analysis"
          run_optimal_k_analysis
          
          puts "\n=== Tutorial Complete ==="
          puts "You've learned about:"
          puts "- Different clustering algorithms and their strengths"
          puts "- Various distance metrics and their effects"
          puts "- How to evaluate clustering quality"
          puts "- How to find the optimal number of clusters"
          puts "- Challenges with non-spherical data"
        end
        
        def create_custom_example(dataset_type, algorithm_type, parameters = {})
          puts "=== Custom Clustering Example ==="
          puts "Dataset: #{dataset_type}, Algorithm: #{algorithm_type}"
          puts
          
          # Generate data based on type
          data_set = case dataset_type
          when :blobs
            DatasetGenerator.generate_blobs(parameters[:n_samples] || 100, 
                                          parameters[:n_clusters] || 3, 
                                          parameters[:n_features] || 2)
          when :moons
            DatasetGenerator.generate_moons(parameters[:n_samples] || 100)
          when :circles
            DatasetGenerator.generate_circles(parameters[:n_samples] || 100)
          when :iris
            DatasetGenerator.load_iris_subset
          else
            DatasetGenerator.generate_blobs(100, 3, 2)
          end
          
          # Create clustering
          clustering = EducationalClustering.new(algorithm_type, parameters)
          
          if parameters[:step_mode]
            clustering.enable_step_mode
          end
          
          if parameters[:visualization]
            clustering.enable_visualization
          end
          
          # Run clustering
          clustering.build(data_set, parameters[:k] || 3)
          
          # Show results
          clustering.visualize
          
          # Evaluate quality
          quality = clustering.evaluate_quality
          puts "\nQuality Metrics:"
          quality.each { |metric, value| puts "  #{metric}: #{value}" }
          
          clustering
        end
        
        private
        
        def find_elbow_point(values)
          # Simple elbow detection using rate of change
          return 1 if values.length < 3
          
          rates = []
          (1...values.length-1).each do |i|
            rate = (values[i-1] - values[i]) - (values[i] - values[i+1])
            rates << rate
          end
          
          rates.each_with_index.max[1] + 1
        end
      end
    end
  end
end