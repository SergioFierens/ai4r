# frozen_string_literal: true

# Interactive Clustering Explorer for Educational Purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'enhanced_clustering_framework'
require_relative 'synthetic_dataset_generator'

module Ai4r
  module Clusterers
    
    # Interactive command-line interface for exploring clustering algorithms
    class InteractiveClusteringExplorer
      
      def initialize(framework)
        @framework = framework
        @current_dataset = nil
        @current_algorithm = nil
        @session_history = []
        @running = true
      end
      
      # Start the interactive exploration session
      def start
        display_welcome
        setup_initial_data
        
        while @running
          display_main_menu
          handle_user_choice
        end
        
        display_goodbye
      end
      
      private
      
      def display_welcome
        puts "="*70
        puts "INTERACTIVE CLUSTERING EXPLORER"
        puts "="*70
        puts
        puts "Welcome to the interactive clustering exploration tool!"
        puts "This tool helps you understand clustering algorithms through hands-on experimentation."
        puts
        puts "Features:"
        puts "• Compare multiple clustering algorithms"
        puts "• Experiment with different parameters"
        puts "• Generate and analyze synthetic datasets"
        puts "• Visualize clustering results"
        puts "• Learn through guided tutorials"
        puts
      end
      
      def setup_initial_data
        puts "Setting up educational datasets..."
        @framework.generate_synthetic_datasets
        puts "Ready to explore!"
        puts
      end
      
      def display_main_menu
        puts "="*50
        puts "MAIN MENU"
        puts "="*50
        puts
        puts "1. Select Dataset"
        puts "2. Select Algorithm"
        puts "3. Run Clustering"
        puts "4. Compare Algorithms"
        puts "5. Parameter Exploration"
        puts "6. Generate New Dataset"
        puts "7. Visualize Results"
        puts "8. Start Learning Tutorial"
        puts "9. View Session History"
        puts "10. Help"
        puts "0. Exit"
        puts
        print "Enter your choice (0-10): "
      end
      
      def handle_user_choice
        choice = gets.chomp.to_i
        
        case choice
        when 1
          select_dataset_menu
        when 2
          select_algorithm_menu
        when 3
          run_clustering_menu
        when 4
          compare_algorithms_menu
        when 5
          parameter_exploration_menu
        when 6
          generate_dataset_menu
        when 7
          visualize_results_menu
        when 8
          start_tutorial_menu
        when 9
          view_session_history
        when 10
          show_help
        when 0
          @running = false
        else
          puts "Invalid choice. Please enter a number between 0 and 10."
          pause
        end
      end
      
      def select_dataset_menu
        puts "\n" + "="*40
        puts "SELECT DATASET"
        puts "="*40
        
        datasets = @framework.datasets.keys
        
        if datasets.empty?
          puts "No datasets available. Generate some synthetic datasets first."
          pause
          return
        end
        
        puts "\nAvailable datasets:"
        datasets.each_with_index do |name, idx|
          info = @framework.datasets[name]
          puts "#{idx + 1}. #{name.to_s.upcase}"
          puts "    #{info[:description]}"
          puts "    Points: #{info[:data_set].data_items.length}, Dimensions: #{info[:properties][:dimensions]}"
        end
        
        puts "0. Back to main menu"
        print "\nSelect dataset (0-#{datasets.length}): "
        
        choice = gets.chomp.to_i
        
        if choice > 0 && choice <= datasets.length
          @current_dataset = datasets[choice - 1]
          puts "\nSelected dataset: #{@current_dataset.to_s.upcase}"
          analyze_dataset(@current_dataset)
        elsif choice != 0
          puts "Invalid choice."
        end
        
        pause
      end
      
      def select_algorithm_menu
        puts "\n" + "="*40
        puts "SELECT ALGORITHM"
        puts "="*40
        
        algorithms = @framework.algorithms.keys
        
        puts "\nAvailable algorithms:"
        algorithms.each_with_index do |name, idx|
          info = @framework.algorithms[name]
          puts "#{idx + 1}. #{info[:name]} (#{info[:type]})"
          puts "    #{info[:description]}"
          puts "    Best for: #{info[:best_for].join(', ')}"
        end
        
        puts "0. Back to main menu"
        print "\nSelect algorithm (0-#{algorithms.length}): "
        
        choice = gets.chomp.to_i
        
        if choice > 0 && choice <= algorithms.length
          @current_algorithm = algorithms[choice - 1]
          puts "\nSelected algorithm: #{@framework.algorithms[@current_algorithm][:name]}"
          explain_algorithm(@current_algorithm)
        elsif choice != 0
          puts "Invalid choice."
        end
        
        pause
      end
      
      def run_clustering_menu
        unless @current_dataset && @current_algorithm
          puts "\nPlease select both a dataset and an algorithm first."
          pause
          return
        end
        
        puts "\n" + "="*40
        puts "RUN CLUSTERING"
        puts "="*40
        puts "Dataset: #{@current_dataset.to_s.upcase}"
        puts "Algorithm: #{@framework.algorithms[@current_algorithm][:name]}"
        puts
        
        # Get parameters
        params = get_algorithm_parameters(@current_algorithm)
        return if params.nil?
        
        # Run clustering
        puts "\nRunning clustering..."
        
        begin
          result = @framework.run_algorithm(@current_algorithm, @current_dataset, params)
          
          # Record in session history
          @session_history << {
            timestamp: Time.now,
            dataset: @current_dataset,
            algorithm: @current_algorithm,
            parameters: params,
            result: result
          }
          
          display_clustering_result(result)
          
        rescue => e
          puts "Error running clustering: #{e.message}"
          puts "Please check your parameters and try again."
        end
        
        pause
      end
      
      def compare_algorithms_menu
        unless @current_dataset
          puts "\nPlease select a dataset first."
          pause
          return
        end
        
        puts "\n" + "="*40
        puts "COMPARE ALGORITHMS"
        puts "="*40
        puts "Dataset: #{@current_dataset.to_s.upcase}"
        puts
        
        algorithms = @framework.algorithms.keys
        puts "Available algorithms:"
        algorithms.each_with_index do |name, idx|
          puts "#{idx + 1}. #{@framework.algorithms[name][:name]}"
        end
        
        print "\nEnter algorithm numbers to compare (e.g., 1,2,3): "
        input = gets.chomp
        
        begin
          indices = input.split(',').map(&:strip).map(&:to_i)
          selected_algorithms = indices.map { |i| algorithms[i - 1] }.compact
          
          if selected_algorithms.length < 2
            puts "Please select at least 2 algorithms to compare."
            pause
            return
          end
          
          puts "\nComparing #{selected_algorithms.length} algorithms..."
          
          # Use default parameters for comparison
          comparison = @framework.compare_algorithms(selected_algorithms, @current_dataset)
          
          # Record in session history
          @session_history << {
            timestamp: Time.now,
            type: :comparison,
            dataset: @current_dataset,
            algorithms: selected_algorithms,
            result: comparison
          }
          
        rescue => e
          puts "Error in comparison: #{e.message}"
        end
        
        pause
      end
      
      def parameter_exploration_menu
        unless @current_dataset && @current_algorithm
          puts "\nPlease select both a dataset and an algorithm first."
          pause
          return
        end
        
        puts "\n" + "="*40
        puts "PARAMETER EXPLORATION"
        puts "="*40
        puts "Dataset: #{@current_dataset.to_s.upcase}"
        puts "Algorithm: #{@framework.algorithms[@current_algorithm][:name]}"
        puts
        
        algorithm_config = @framework.algorithms[@current_algorithm]
        parameters = algorithm_config[:parameters]
        
        if parameters.empty?
          puts "This algorithm has no configurable parameters."
          pause
          return
        end
        
        puts "Available parameters:"
        parameters.each_with_index do |(param_name, param_config), idx|
          puts "#{idx + 1}. #{param_name} (#{param_config[:type]})"
        end
        
        print "\nSelect parameter to explore (1-#{parameters.length}): "
        choice = gets.chomp.to_i
        
        param_name = parameters.keys[choice - 1]
        if param_name
          explore_single_parameter(param_name, parameters[param_name])
        else
          puts "Invalid choice."
        end
        
        pause
      end
      
      def generate_dataset_menu
        puts "\n" + "="*40
        puts "GENERATE SYNTHETIC DATASET"
        puts "="*40
        
        puts "\nDataset types:"
        puts "1. Gaussian Blobs (well-separated clusters)"
        puts "2. Moons (non-convex shapes)"
        puts "3. Circles (concentric clusters)"
        puts "4. Anisotropic (stretched clusters)"
        puts "5. Varied Density (different cluster densities)"
        puts "6. With Noise (clean clusters + random noise)"
        puts "7. Custom Blobs (specify parameters)"
        puts "0. Back to main menu"
        
        print "\nSelect dataset type (0-7): "
        choice = gets.chomp.to_i
        
        case choice
        when 1
          generate_gaussian_blobs
        when 2
          generate_moons_dataset
        when 3
          generate_circles_dataset
        when 4
          generate_anisotropic_dataset
        when 5
          generate_varied_density_dataset
        when 6
          generate_noisy_dataset
        when 7
          generate_custom_blobs
        when 0
          return
        else
          puts "Invalid choice."
        end
        
        pause
      end
      
      def visualize_results_menu
        if @session_history.empty?
          puts "\nNo clustering results to visualize. Run some clustering first."
          pause
          return
        end
        
        puts "\n" + "="*40
        puts "VISUALIZE RESULTS"
        puts "="*40
        
        # Show recent results
        recent_results = @session_history.select { |h| h[:type] != :comparison }.last(5)
        
        puts "Recent clustering results:"
        recent_results.each_with_index do |session, idx|
          puts "#{idx + 1}. #{session[:algorithm]} on #{session[:dataset]} (#{session[:timestamp].strftime('%H:%M:%S')})"
        end
        
        puts "0. Back to main menu"
        print "\nSelect result to visualize (0-#{recent_results.length}): "
        
        choice = gets.chomp.to_i
        
        if choice > 0 && choice <= recent_results.length
          session = recent_results[choice - 1]
          visualize_clustering_session(session)
        elsif choice != 0
          puts "Invalid choice."
        end
        
        pause
      end
      
      def start_tutorial_menu
        puts "\n" + "="*40
        puts "LEARNING TUTORIALS"
        puts "="*40
        
        puts "\nAvailable tutorials:"
        puts "1. Beginner: Clustering Fundamentals"
        puts "2. Intermediate: Multiple Algorithms"
        puts "3. Advanced: Parameter Optimization"
        puts "0. Back to main menu"
        
        print "\nSelect tutorial level (0-3): "
        choice = gets.chomp.to_i
        
        case choice
        when 1
          @framework.start_curriculum(:beginner)
        when 2
          @framework.start_curriculum(:intermediate)
        when 3
          @framework.start_curriculum(:advanced)
        when 0
          return
        else
          puts "Invalid choice."
          pause
        end
      end
      
      def view_session_history
        puts "\n" + "="*40
        puts "SESSION HISTORY"
        puts "="*40
        
        if @session_history.empty?
          puts "No clustering operations performed yet."
          pause
          return
        end
        
        puts "\nSession History:"
        puts "Time     | Type       | Dataset     | Algorithm     | Quality"
        puts "---------|------------|-------------|---------------|--------"
        
        @session_history.each do |session|
          time_str = session[:timestamp].strftime('%H:%M:%S')
          
          if session[:type] == :comparison
            puts sprintf("%-8s | %-10s | %-11s | %-13s | %s",
              time_str, "Compare", session[:dataset].to_s[0..10], 
              "Multiple", "Various")
          else
            quality = session[:result][:quality_metrics][:silhouette_score]
            quality_str = quality ? quality.round(3).to_s : "N/A"
            
            puts sprintf("%-8s | %-10s | %-11s | %-13s | %s",
              time_str, "Single", session[:dataset].to_s[0..10], 
              session[:algorithm].to_s[0..12], quality_str)
          end
        end
        
        puts
        print "Press Enter to continue..."
        gets
      end
      
      def show_help
        puts "\n" + "="*50
        puts "HELP - HOW TO USE THE CLUSTERING EXPLORER"
        puts "="*50
        
        puts <<~HELP
          Getting Started:
          1. First, select a dataset (Menu option 1)
          2. Then, select an algorithm (Menu option 2)
          3. Run clustering to see results (Menu option 3)
          
          Exploration Workflow:
          • Start with simple datasets like "blobs_easy"
          • Try K-means algorithm first (easiest to understand)
          • Compare different algorithms on the same data
          • Experiment with parameters to see their effects
          
          Understanding Results:
          • Silhouette Score: Higher is better (>0.5 is good)
          • Look at cluster sizes for balance
          • Visualize results when possible
          
          Educational Tips:
          • Try algorithms that should fail on certain data:
            - K-means on "moons" (non-convex shapes)
            - K-means on "circles" (non-linearly separable)
          • Use DBSCAN for noisy data
          • Compare hierarchical methods for different linkages
          
          Troubleshooting:
          • If clustering fails, try different parameters
          • Some algorithms need specific parameter ranges
          • Check dataset properties (size, dimensions)
          
          Advanced Features:
          • Parameter exploration shows how parameters affect results
          • Session history tracks your experiments
          • Tutorials provide structured learning paths
          
          Remember: Clustering is exploratory - there's often no single "right" answer!
        HELP
        
        pause
      end
      
      def display_goodbye
        puts "\n" + "="*50
        puts "Thank you for using the Interactive Clustering Explorer!"
        puts "="*50
        puts
        puts "Session Summary:"
        puts "• Clustering operations: #{@session_history.count { |h| h[:type] != :comparison }}"
        puts "• Algorithm comparisons: #{@session_history.count { |h| h[:type] == :comparison }}"
        puts "• Datasets explored: #{@session_history.map { |h| h[:dataset] }.uniq.length}"
        puts
        puts "Keep exploring and learning about clustering algorithms!"
      end
      
      # Helper methods
      
      def analyze_dataset(dataset_name)
        info = @framework.datasets[dataset_name]
        data_set = info[:data_set]
        
        puts "\nDataset Analysis:"
        puts "• Description: #{info[:description]}"
        puts "• Points: #{data_set.data_items.length}"
        puts "• Dimensions: #{info[:properties][:dimensions]}"
        puts "• Properties: #{info[:properties][:summary]}"
        
        # Show sample points
        puts "\nSample points:"
        sample_size = [5, data_set.data_items.length].min
        data_set.data_items.take(sample_size).each_with_index do |point, idx|
          formatted_point = point.map { |v| v.round(3) if v.is_a?(Numeric) }.join(', ')
          puts "  Point #{idx + 1}: [#{formatted_point}]"
        end
      end
      
      def explain_algorithm(algorithm_name)
        info = @framework.algorithms[algorithm_name]
        
        puts "\nAlgorithm Details:"
        puts "• Type: #{info[:type]}"
        puts "• Description: #{info[:description]}"
        puts "• Best for: #{info[:best_for].join(', ')}"
        puts "• Parameters: #{info[:parameters].keys.join(', ')}"
        
        # Algorithm-specific explanations
        case algorithm_name
        when :k_means
          puts "\nKey concepts: centroids, convergence, local optima"
          puts "Assumptions: spherical clusters, similar sizes"
        when :dbscan
          puts "\nKey concepts: density, core points, noise detection"
          puts "Advantages: arbitrary shapes, automatic cluster count"
        when :hierarchical_single, :hierarchical_complete, :hierarchical_average, :hierarchical_ward
          puts "\nKey concepts: dendrogram, linkage methods, hierarchy"
          puts "Advantages: no need to specify cluster count"
        end
      end
      
      def get_algorithm_parameters(algorithm_name)
        algorithm_config = @framework.algorithms[algorithm_name]
        parameters = algorithm_config[:parameters]
        params = {}
        
        if parameters.empty?
          puts "This algorithm uses default parameters."
          return {}
        end
        
        puts "\nParameter configuration:"
        
        parameters.each do |param_name, param_config|
          puts "\n#{param_name} (#{param_config[:type]}):"
          puts "Default: #{param_config[:default]}"
          
          if param_config[:options]
            puts "Options: #{param_config[:options].join(', ')}"
          else
            puts "Range: #{param_config[:min]} to #{param_config[:max]}"
          end
          
          print "Enter value (or press Enter for default): "
          input = gets.chomp
          
          if input.empty?
            params[param_name] = param_config[:default]
          else
            begin
              case param_config[:type]
              when :integer
                params[param_name] = input.to_i
              when :float
                params[param_name] = input.to_f
              when :symbol
                params[param_name] = input.to_sym
              else
                params[param_name] = input
              end
            rescue
              puts "Invalid value, using default."
              params[param_name] = param_config[:default]
            end
          end
        end
        
        params
      end
      
      def display_clustering_result(result)
        puts "\n" + "="*40
        puts "CLUSTERING RESULTS"
        puts "="*40
        
        stats = result[:stats]
        quality = result[:quality_metrics]
        
        puts "Execution time: #{result[:execution_time].round(4)} seconds"
        puts "Iterations: #{stats[:iterations]}" if stats[:iterations]
        puts "Clusters found: #{stats[:num_clusters]}"
        
        if stats[:cluster_sizes]
          puts "Cluster sizes: #{stats[:cluster_sizes].join(', ')}"
        end
        
        if quality[:silhouette_score]
          puts "Silhouette score: #{quality[:silhouette_score].round(4)}"
          interpret_silhouette_score(quality[:silhouette_score])
        end
        
        if quality[:davies_bouldin_index]
          puts "Davies-Bouldin index: #{quality[:davies_bouldin_index].round(4)} (lower is better)"
        end
        
        # Special stats for DBSCAN
        if stats[:num_noise_points]
          puts "Noise points: #{stats[:num_noise_points]} (#{(stats[:noise_ratio] * 100).round(1)}%)"
        end
      end
      
      def interpret_silhouette_score(score)
        interpretation = case score
                        when 0.7..1.0
                          "Excellent clustering"
                        when 0.5..0.7
                          "Good clustering"
                        when 0.2..0.5
                          "Weak clustering"
                        else
                          "Poor clustering"
                        end
        puts "  → #{interpretation}"
      end
      
      def explore_single_parameter(param_name, param_config)
        puts "\nExploring parameter: #{param_name}"
        puts "Type: #{param_config[:type]}"
        puts "Default: #{param_config[:default]}"
        
        # Generate parameter values to test
        test_values = generate_test_values(param_config)
        
        puts "\nTesting #{test_values.length} different values..."
        
        results = []
        test_values.each do |value|
          params = { param_name => value }
          
          begin
            result = @framework.run_algorithm(@current_algorithm, @current_dataset, params.merge(verbose: false))
            quality = result[:quality_metrics][:silhouette_score] || 0
            
            results << {
              value: value,
              quality: quality,
              clusters: result[:stats][:num_clusters],
              time: result[:execution_time]
            }
            
            print "."
          rescue
            print "x"  # Failed
          end
        end
        
        puts "\n"
        
        # Display results
        puts "\nParameter Exploration Results:"
        puts "Value       | Quality | Clusters | Time"
        puts "------------|---------|----------|--------"
        
        results.each do |result|
          puts sprintf("%-11s | %7.4f | %8d | %6.3fs",
            result[:value].to_s, result[:quality], result[:clusters], result[:time])
        end
        
        # Find best value
        best = results.max_by { |r| r[:quality] }
        if best
          puts "\nBest parameter value: #{best[:value]} (quality: #{best[:quality].round(4)})"
        end
      end
      
      def generate_test_values(param_config)
        case param_config[:type]
        when :integer
          if param_config[:options]
            param_config[:options]
          else
            min_val = param_config[:min] || 1
            max_val = param_config[:max] || 10
            step = [(max_val - min_val) / 8, 1].max
            (min_val..max_val).step(step).to_a
          end
        when :float
          min_val = param_config[:min] || 0.1
          max_val = param_config[:max] || 2.0
          step = (max_val - min_val) / 8.0
          (0..8).map { |i| min_val + i * step }
        when :symbol
          param_config[:options] || [param_config[:default]]
        else
          [param_config[:default]]
        end
      end
      
      def generate_gaussian_blobs
        print "Number of clusters (default 3): "
        n_clusters = gets.chomp
        n_clusters = n_clusters.empty? ? 3 : n_clusters.to_i
        
        print "Number of points (default 300): "
        n_points = gets.chomp
        n_points = n_points.empty? ? 300 : n_points.to_i
        
        print "Cluster standard deviation (default 0.8): "
        std = gets.chomp
        std = std.empty? ? 0.8 : std.to_f
        
        generator = SyntheticDatasetGenerator.new
        dataset = generator.generate_blobs(n_clusters, n_points, std)
        
        dataset_name = "custom_blobs_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, "Custom Gaussian blobs: #{n_clusters} clusters, #{n_points} points")
        
        puts "\nGenerated dataset: #{dataset_name}"
        puts "You can now select it from the dataset menu."
      end
      
      def generate_moons_dataset
        print "Number of points (default 400): "
        n_points = gets.chomp
        n_points = n_points.empty? ? 400 : n_points.to_i
        
        print "Noise level (default 0.1): "
        noise = gets.chomp
        noise = noise.empty? ? 0.1 : noise.to_f
        
        generator = SyntheticDatasetGenerator.new
        dataset = generator.generate_moons(n_points, noise)
        
        dataset_name = "custom_moons_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, "Custom moons: #{n_points} points, noise #{noise}")
        
        puts "\nGenerated dataset: #{dataset_name}"
      end
      
      def generate_circles_dataset
        print "Number of points (default 300): "
        n_points = gets.chomp
        n_points = n_points.empty? ? 300 : n_points.to_i
        
        generator = SyntheticDatasetGenerator.new
        dataset = generator.generate_circles(n_points, 0.05)
        
        dataset_name = "custom_circles_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, "Custom circles: #{n_points} points")
        
        puts "\nGenerated dataset: #{dataset_name}"
      end
      
      def generate_anisotropic_dataset
        print "Number of points (default 400): "
        n_points = gets.chomp
        n_points = n_points.empty? ? 400 : n_points.to_i
        
        generator = SyntheticDatasetGenerator.new
        dataset = generator.generate_anisotropic(n_points)
        
        dataset_name = "custom_anisotropic_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, "Custom anisotropic: #{n_points} points")
        
        puts "\nGenerated dataset: #{dataset_name}"
      end
      
      def generate_varied_density_dataset
        print "Number of points (default 600): "
        n_points = gets.chomp
        n_points = n_points.empty? ? 600 : n_points.to_i
        
        generator = SyntheticDatasetGenerator.new
        dataset = generator.generate_varied_density(n_points)
        
        dataset_name = "custom_density_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, "Custom varied density: #{n_points} points")
        
        puts "\nGenerated dataset: #{dataset_name}"
      end
      
      def generate_noisy_dataset
        print "Number of points (default 300): "
        n_points = gets.chomp
        n_points = n_points.empty? ? 300 : n_points.to_i
        
        print "Noise ratio (default 0.2): "
        noise_ratio = gets.chomp
        noise_ratio = noise_ratio.empty? ? 0.2 : noise_ratio.to_f
        
        generator = SyntheticDatasetGenerator.new
        dataset = generator.generate_with_noise(n_points, noise_ratio)
        
        dataset_name = "custom_noisy_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, "Custom noisy: #{n_points} points, #{(noise_ratio*100).round}% noise")
        
        puts "\nGenerated dataset: #{dataset_name}"
      end
      
      def generate_custom_blobs
        puts "\nCustom Gaussian Blobs Generator"
        puts "This allows you to create specific cluster configurations."
        
        print "Number of clusters: "
        n_clusters = gets.chomp.to_i
        
        print "Points per cluster: "
        points_per_cluster = gets.chomp.to_i
        
        print "Cluster separation (1.0 = touching, 2.0 = well separated): "
        separation = gets.chomp.to_f
        
        generator = SyntheticDatasetGenerator.new
        # Create well-separated blobs with specified separation
        dataset = generator.generate_blobs(n_clusters, n_clusters * points_per_cluster, 0.5 / separation)
        
        dataset_name = "custom_blobs_#{Time.now.to_i}".to_sym
        @framework.add_dataset(dataset_name, dataset, 
          "Custom: #{n_clusters} clusters, #{points_per_cluster} points each, separation #{separation}")
        
        puts "\nGenerated dataset: #{dataset_name}"
      end
      
      def visualize_clustering_session(session)
        puts "\nVisualizing clustering session:"
        puts "Dataset: #{session[:dataset]}"
        puts "Algorithm: #{session[:algorithm]}"
        puts "Time: #{session[:timestamp]}"
        
        # Show basic visualization
        result = session[:result]
        
        if result[:algorithm_instance].respond_to?(:visualize)
          result[:algorithm_instance].visualize
        else
          puts "\nBasic clustering information:"
          puts "Clusters: #{result[:stats][:num_clusters]}"
          puts "Quality: #{result[:quality_metrics][:silhouette_score]&.round(4) || 'N/A'}"
        end
      end
      
      def pause
        print "\nPress Enter to continue..."
        gets
      end
    end
  end
end