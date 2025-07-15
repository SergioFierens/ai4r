# frozen_string_literal: true

# Enhanced Educational Clustering Framework
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'clusterer'
require_relative 'k_means'
require_relative 'single_linkage'
require_relative 'complete_linkage'
require_relative 'average_linkage'
require_relative 'ward_linkage'
require_relative 'diana'
require_relative 'dbscan'
require_relative 'distance_metrics'
require_relative '../data/data_set'

module Ai4r
  module Clusterers
    
    # Comprehensive educational clustering framework for students and teachers
    class EnhancedClusteringFramework
      
      attr_reader :algorithms, :datasets, :current_algorithm, :current_dataset
      attr_reader :comparison_results, :learning_progress
      
      def initialize
        @algorithms = {}
        @datasets = {}
        @comparison_results = []
        @learning_progress = LearningProgress.new
        @visualization_enabled = false
        @step_mode = false
        
        initialize_algorithms
      end
      
      # Enable educational features
      def enable_step_mode
        @step_mode = true
        self
      end
      
      def enable_visualization
        @visualization_enabled = true
        self
      end
      
      # Add dataset for experimentation
      def add_dataset(name, data_set, description = "")
        @datasets[name] = {
          data_set: data_set,
          description: description,
          properties: analyze_dataset_properties(data_set)
        }
        self
      end
      
      # Run specific algorithm on dataset
      def run_algorithm(algorithm_name, dataset_name, params = {})
        raise ArgumentError, "Unknown algorithm: #{algorithm_name}" unless @algorithms.key?(algorithm_name)
        raise ArgumentError, "Unknown dataset: #{dataset_name}" unless @datasets.key?(dataset_name)
        
        algorithm_config = @algorithms[algorithm_name]
        dataset_info = @datasets[dataset_name]
        
        puts "Running #{algorithm_config[:name]} on #{dataset_name}..." if params[:verbose]
        
        # Create algorithm instance
        algorithm = create_algorithm_instance(algorithm_name, params)
        
        # Configure for educational mode
        if @step_mode && algorithm.respond_to?(:enable_educational_mode)
          algorithm.enable_educational_mode
        end
        
        # Run algorithm
        start_time = Time.now
        result = run_algorithm_with_params(algorithm, dataset_info[:data_set], params)
        end_time = Time.now
        
        # Record results
        execution_result = {
          algorithm: algorithm_name,
          dataset: dataset_name,
          parameters: params,
          execution_time: end_time - start_time,
          algorithm_instance: algorithm,
          clusters: algorithm.clusters,
          stats: collect_algorithm_stats(algorithm),
          quality_metrics: evaluate_clustering_quality(algorithm, dataset_info[:data_set])
        }
        
        @comparison_results << execution_result
        @current_algorithm = algorithm
        @current_dataset = dataset_info[:data_set]
        
        # Update learning progress
        @learning_progress.record_algorithm_experience(algorithm_name)
        
        # Visualize if enabled
        if @visualization_enabled
          visualize_results(execution_result)
        end
        
        execution_result
      end
      
      # Compare multiple algorithms on same dataset
      def compare_algorithms(algorithm_names, dataset_name, params_map = {})
        puts "=== Algorithm Comparison on #{dataset_name} ==="
        puts
        
        results = []
        algorithm_names.each do |algorithm_name|
          algorithm_params = params_map[algorithm_name] || {}
          algorithm_params[:verbose] = false  # Suppress individual verbose output
          
          result = run_algorithm(algorithm_name, dataset_name, algorithm_params)
          results << result
        end
        
        # Generate comparison report
        comparison = AlgorithmComparator.new(results).generate_report
        puts comparison[:summary]
        
        comparison
      end
      
      # Educational parameter exploration
      def explore_parameters(algorithm_name, dataset_name, parameter_ranges = {})
        puts "=== Parameter Exploration: #{algorithm_name} on #{dataset_name} ==="
        puts
        
        explorer = ParameterExplorer.new(
          @algorithms[algorithm_name],
          @datasets[dataset_name],
          parameter_ranges
        )
        
        explorer.explore_with_explanations
      end
      
      # Progressive learning curriculum
      def start_curriculum(level = :beginner)
        curriculum = ClusteringCurriculum.new(self)
        
        case level
        when :beginner
          curriculum.run_beginner_curriculum
        when :intermediate
          curriculum.run_intermediate_curriculum
        when :advanced
          curriculum.run_advanced_curriculum
        else
          raise ArgumentError, "Unknown curriculum level: #{level}"
        end
      end
      
      # Interactive experimentation mode
      def start_interactive_mode
        InteractiveClusteringExplorer.new(self).start
      end
      
      # Generate synthetic datasets for learning
      def generate_synthetic_datasets
        generator = SyntheticDatasetGenerator.new
        
        # Add various synthetic datasets
        add_dataset(:blobs_easy, generator.generate_blobs(3, 300, 0.5), 
                   "Well-separated Gaussian blobs - easiest clustering problem")
        
        add_dataset(:blobs_hard, generator.generate_blobs(5, 500, 1.5), 
                   "Overlapping Gaussian blobs - moderate difficulty")
        
        add_dataset(:moons, generator.generate_moons(400, 0.1), 
                   "Two interleaving half-circles - non-convex clusters")
        
        add_dataset(:circles, generator.generate_circles(300, 0.05), 
                   "Concentric circles - challenging for centroid-based methods")
        
        add_dataset(:anisotropic, generator.generate_anisotropic(400), 
                   "Stretched clusters - demonstrates distance metric importance")
        
        add_dataset(:density_varied, generator.generate_varied_density(600), 
                   "Clusters with different densities - DBSCAN showcase")
        
        add_dataset(:noise_heavy, generator.generate_with_noise(300, 0.3), 
                   "Dataset with 30% noise points - robustness test")
        
        puts "Generated 7 synthetic datasets for educational exploration"
        list_datasets
      end
      
      # List available algorithms
      def list_algorithms
        puts "=== Available Clustering Algorithms ==="
        puts
        
        @algorithms.each do |key, info|
          puts "#{key.to_s.upcase}:"
          puts "  Name: #{info[:name]}"
          puts "  Type: #{info[:type]}"
          puts "  Description: #{info[:description]}"
          puts "  Best for: #{info[:best_for].join(', ')}"
          puts "  Parameters: #{info[:parameters].keys.join(', ')}"
          puts
        end
      end
      
      # List available datasets
      def list_datasets
        puts "=== Available Datasets ==="
        puts
        
        @datasets.each do |key, info|
          puts "#{key.to_s.upcase}:"
          puts "  Points: #{info[:data_set].data_items.length}"
          puts "  Dimensions: #{info[:properties][:dimensions]}"
          puts "  Description: #{info[:description]}"
          puts "  Properties: #{info[:properties][:summary]}"
          puts
        end
      end
      
      # Get learning recommendations
      def get_learning_recommendations
        @learning_progress.get_recommendations(@algorithms.keys)
      end
      
      # Export results for further analysis
      def export_results(filename)
        ClusteringResultsExporter.new(@comparison_results).export(filename)
      end
      
      private
      
      def initialize_algorithms
        @algorithms = {
          k_means: {
            name: "K-Means",
            type: "Partitional",
            class: KMeans,
            description: "Partitions data into k clusters by minimizing within-cluster sum of squares",
            best_for: ["Spherical clusters", "Similar cluster sizes", "Numeric data"],
            parameters: {
              k: { type: :integer, min: 2, max: 20, default: 3 },
              max_iterations: { type: :integer, min: 10, max: 1000, default: 100 },
              initialization: { type: :symbol, options: [:random, :k_means_plus_plus], default: :random }
            }
          },
          
          hierarchical_single: {
            name: "Single Linkage",
            type: "Hierarchical",
            class: SingleLinkage,
            description: "Agglomerative clustering using minimum distance between clusters",
            best_for: ["Chain-like clusters", "Irregular shapes", "Small datasets"],
            parameters: {
              num_clusters: { type: :integer, min: 2, max: 10, default: 3 }
            }
          },
          
          hierarchical_complete: {
            name: "Complete Linkage",
            type: "Hierarchical", 
            class: CompleteLinkage,
            description: "Agglomerative clustering using maximum distance between clusters",
            best_for: ["Compact clusters", "Similar sizes", "Outlier sensitivity"],
            parameters: {
              num_clusters: { type: :integer, min: 2, max: 10, default: 3 }
            }
          },
          
          hierarchical_average: {
            name: "Average Linkage",
            type: "Hierarchical",
            class: AverageLinkage,
            description: "Agglomerative clustering using average distance between clusters",
            best_for: ["Balanced approach", "Medium-sized clusters", "General purpose"],
            parameters: {
              num_clusters: { type: :integer, min: 2, max: 10, default: 3 }
            }
          },
          
          hierarchical_ward: {
            name: "Ward's Method",
            type: "Hierarchical",
            class: WardLinkage,
            description: "Agglomerative clustering minimizing within-cluster variance",
            best_for: ["Spherical clusters", "Similar sizes", "Optimal for K-means data"],
            parameters: {
              num_clusters: { type: :integer, min: 2, max: 10, default: 3 }
            }
          },
          
          diana: {
            name: "DIANA",
            type: "Hierarchical Divisive",
            class: Diana,
            description: "Divisive clustering starting from one cluster",
            best_for: ["Top-down approach", "Large clusters first", "Hierarchical structure"],
            parameters: {
              num_clusters: { type: :integer, min: 2, max: 10, default: 3 }
            }
          },
          
          dbscan: {
            name: "DBSCAN",
            type: "Density-based",
            class: DBSCAN,
            description: "Density-based clustering that finds arbitrary shapes and handles noise",
            best_for: ["Arbitrary shapes", "Noise handling", "Unknown cluster count"],
            parameters: {
              eps: { type: :float, min: 0.1, max: 5.0, default: 0.5 },
              min_pts: { type: :integer, min: 3, max: 20, default: 5 }
            }
          }
        }
      end
      
      def create_algorithm_instance(algorithm_name, params)
        algorithm_config = @algorithms[algorithm_name]
        algorithm_class = algorithm_config[:class]
        
        instance = algorithm_class.new
        
        # Set parameters based on algorithm type
        params.each do |param_name, value|
          if instance.respond_to?("#{param_name}=")
            instance.send("#{param_name}=", value)
          elsif instance.instance_variable_defined?("@#{param_name}")
            instance.instance_variable_set("@#{param_name}", value)
          end
        end
        
        instance
      end
      
      def run_algorithm_with_params(algorithm, data_set, params)
        case algorithm.class.name.split('::').last
        when 'KMeans'
          k = params[:k] || 3
          algorithm.build(data_set, k)
        when 'DBSCAN'
          eps = params[:eps] || 0.5
          min_pts = params[:min_pts] || 5
          algorithm.build(data_set, eps, min_pts)
        else
          # Hierarchical algorithms
          num_clusters = params[:num_clusters] || 3
          algorithm.build(data_set, num_clusters)
        end
      end
      
      def analyze_dataset_properties(data_set)
        return { dimensions: 0, summary: "Empty dataset" } if data_set.data_items.empty?
        
        first_item = data_set.data_items.first
        dimensions = first_item.count { |attr| attr.is_a?(Numeric) }
        
        # Basic statistics
        numeric_data = data_set.data_items.map do |item|
          item.select { |attr| attr.is_a?(Numeric) }
        end
        
        properties = {
          dimensions: dimensions,
          size: data_set.data_items.length,
          summary: "#{data_set.data_items.length} points in #{dimensions}D space"
        }
        
        # Add more detailed analysis if reasonable size
        if data_set.data_items.length < 10000 && dimensions <= 10
          properties[:detailed] = calculate_detailed_properties(numeric_data)
        end
        
        properties
      end
      
      def calculate_detailed_properties(numeric_data)
        return {} if numeric_data.empty? || numeric_data.first.empty?
        
        dimensions = numeric_data.first.length
        properties = {}
        
        dimensions.times do |dim|
          values = numeric_data.map { |point| point[dim] }
          properties["dim_#{dim}"] = {
            min: values.min,
            max: values.max,
            mean: values.sum / values.length.to_f,
            std: calculate_std(values)
          }
        end
        
        properties
      end
      
      def calculate_std(values)
        mean = values.sum / values.length.to_f
        variance = values.sum { |v| (v - mean) ** 2 } / values.length.to_f
        Math.sqrt(variance)
      end
      
      def collect_algorithm_stats(algorithm)
        stats = {
          algorithm_type: algorithm.class.name.split('::').last
        }
        
        # Collect algorithm-specific stats
        if algorithm.respond_to?(:iterations)
          stats[:iterations] = algorithm.iterations
        end
        
        if algorithm.respond_to?(:clustering_stats)
          stats.merge!(algorithm.clustering_stats)
        end
        
        if algorithm.respond_to?(:clusters) && algorithm.clusters
          stats[:num_clusters] = algorithm.clusters.length
          stats[:cluster_sizes] = algorithm.clusters.map { |c| c.data_items.length }
        end
        
        stats
      end
      
      def evaluate_clustering_quality(algorithm, data_set)
        return {} unless algorithm.respond_to?(:clusters) && algorithm.clusters
        
        evaluator = ClusteringQualityEvaluator.new(data_set, algorithm.clusters)
        evaluator.evaluate_all_metrics
      end
      
      def visualize_results(result)
        if @datasets[result[:dataset]][:properties][:dimensions] == 2
          visualizer = ClusteringVisualizer.new(
            result[:algorithm_instance], 
            @datasets[result[:dataset]][:data_set]
          )
          visualizer.visualize_2d_results
        end
      end
    end
    
    # Learning progress tracker
    class LearningProgress
      def initialize
        @algorithm_experience = Hash.new(0)
        @concept_mastery = Hash.new(0)
        @start_time = Time.now
      end
      
      def record_algorithm_experience(algorithm_name)
        @algorithm_experience[algorithm_name] += 1
        
        # Record concept mastery based on algorithm
        case algorithm_name
        when :k_means
          @concept_mastery[:partitional_clustering] += 1
          @concept_mastery[:centroid_based] += 1
        when :dbscan
          @concept_mastery[:density_based] += 1
          @concept_mastery[:noise_handling] += 1
        when /hierarchical/
          @concept_mastery[:hierarchical_clustering] += 1
          @concept_mastery[:linkage_methods] += 1
        end
      end
      
      def get_recommendations(available_algorithms)
        recommendations = []
        
        # Suggest unexplored algorithms
        unexplored = available_algorithms.select { |alg| @algorithm_experience[alg] == 0 }
        if unexplored.any?
          recommendations << {
            type: :exploration,
            message: "Try these unexplored algorithms: #{unexplored.join(', ')}",
            algorithms: unexplored
          }
        end
        
        # Suggest concept areas needing work
        weak_concepts = @concept_mastery.select { |_, count| count < 3 }.keys
        if weak_concepts.any?
          recommendations << {
            type: :concept_strengthening,
            message: "Focus on these concepts: #{weak_concepts.join(', ')}",
            concepts: weak_concepts
          }
        end
        
        # Suggest advanced topics if basics are mastered
        if @concept_mastery.values.sum > 15
          recommendations << {
            type: :advanced,
            message: "Ready for advanced topics: parameter tuning, ensemble methods",
            next_steps: [:parameter_optimization, :ensemble_clustering]
          }
        end
        
        recommendations
      end
    end
    
    # Algorithm comparison utility
    class AlgorithmComparator
      def initialize(results)
        @results = results
      end
      
      def generate_report
        report = {
          summary: generate_summary_text,
          detailed_metrics: compare_metrics,
          recommendations: generate_recommendations
        }
        
        report
      end
      
      private
      
      def generate_summary_text
        summary = ["=== Algorithm Comparison Summary ===", ""]
        
        summary << "Algorithms compared: #{@results.map { |r| r[:algorithm] }.join(', ')}"
        summary << "Dataset: #{@results.first[:dataset]}"
        summary << ""
        
        # Performance comparison
        summary << "Performance Metrics:"
        summary << "-" * 30
        
        @results.each do |result|
          summary << "#{result[:algorithm].to_s.upcase}:"
          summary << "  Execution time: #{result[:execution_time].round(4)}s"
          summary << "  Clusters found: #{result[:stats][:num_clusters] || 'N/A'}"
          
          if result[:quality_metrics][:silhouette_score]
            summary << "  Silhouette score: #{result[:quality_metrics][:silhouette_score].round(4)}"
          end
          
          summary << ""
        end
        
        summary.join("\n")
      end
      
      def compare_metrics
        metrics = {}
        
        @results.each do |result|
          algorithm = result[:algorithm]
          metrics[algorithm] = result[:quality_metrics]
        end
        
        metrics
      end
      
      def generate_recommendations
        # Simple recommendation logic based on results
        best_algorithm = @results.max_by do |result|
          result[:quality_metrics][:silhouette_score] || 0
        end
        
        [
          "Best overall performance: #{best_algorithm[:algorithm]}",
          "Consider the trade-offs between quality and execution time",
          "Try different parameters to optimize results further"
        ]
      end
    end
    
    # Interactive parameter exploration
    class ParameterExplorer
      def initialize(algorithm_config, dataset_info, parameter_ranges)
        @algorithm_config = algorithm_config
        @dataset_info = dataset_info
        @parameter_ranges = parameter_ranges
      end
      
      def explore_with_explanations
        puts "Parameter exploration for #{@algorithm_config[:name]}"
        puts "Dataset: #{@dataset_info[:description]}"
        puts
        
        # Explore each parameter
        @algorithm_config[:parameters].each do |param_name, param_config|
          if @parameter_ranges.key?(param_name)
            explore_parameter(param_name, param_config, @parameter_ranges[param_name])
          else
            explain_parameter(param_name, param_config)
          end
        end
      end
      
      private
      
      def explore_parameter(param_name, param_config, range)
        puts "=== Exploring #{param_name} ==="
        puts
        
        values = case param_config[:type]
                 when :integer
                   range.step([(range.last - range.first) / 5, 1].max)
                 when :float
                   range.step((range.last - range.first) / 5.0)
                 else
                   range
                 end
        
        results = []
        
        values.each do |value|
          # Run algorithm with this parameter value
          params = { param_name => value }
          # ... implementation would run algorithm and collect results
          puts "#{param_name}=#{value}: [results would be shown here]"
        end
        
        puts
      end
      
      def explain_parameter(param_name, param_config)
        puts "Parameter: #{param_name}"
        puts "Type: #{param_config[:type]}"
        puts "Default: #{param_config[:default]}"
        
        if param_config[:options]
          puts "Options: #{param_config[:options].join(', ')}"
        else
          puts "Range: #{param_config[:min]} to #{param_config[:max]}"
        end
        
        puts
      end
    end
  end
end