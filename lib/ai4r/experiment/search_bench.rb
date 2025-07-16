# frozen_string_literal: true

#
# AI4R Search Algorithms Benchmarking System
# 
# A comprehensive framework for comparing search algorithms with educational insights.
# Designed to help students understand the strengths, weaknesses, and characteristics of
# different AI search approaches through hands-on experimentation.
#
# Author:: AI4R Development Team  
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# "In the vast landscape of problem-solving, every search algorithm has its own compass.
#  The art lies in knowing which direction leads to treasure." - Anonymous AI Explorer
#

require_relative '../search/a_star'
require_relative '../search/minimax'
require_relative '../genetic_algorithm/genetic_algorithm'
require 'benchmark'
require 'set'
require 'timeout'

module Ai4r
  module Experiment
    #
    # SearchBench: The Ultimate Search Algorithm Arena 🔍
    #
    # This class provides a comprehensive benchmarking framework for comparing
    # different search algorithms. It's designed with education in mind,
    # offering detailed insights into algorithm performance, characteristics,
    # and trade-offs across various problem types.
    #
    # == Features:
    # * Multi-algorithm comparison across different problem types
    # * Performance metrics (time, nodes explored, solution quality)
    # * Memory usage analysis
    # * Step-by-step execution tracking
    # * Educational insights and explanations
    # * Visual performance reports
    # * Export capabilities (CSV, JSON, HTML)
    #
    # == Example:
    #   # Create a benchmark
    #   bench = SearchBench.new(verbose: true)
    #   
    #   # Add search algorithms
    #   bench.add_algorithm(:astar_manhattan, Ai4r::Search::AStar.new(heuristic: :manhattan))
    #   bench.add_algorithm(:astar_euclidean, Ai4r::Search::AStar.new(heuristic: :euclidean))
    #   bench.add_algorithm(:minimax, Ai4r::Search::Minimax.new(max_depth: 4))
    #   
    #   # Add problems to solve
    #   bench.add_problem(:simple_maze, create_maze_problem())
    #   bench.add_problem(:tic_tac_toe, create_game_problem())
    #   
    #   # Run the benchmark
    #   results = bench.run()
    #   
    #   # Display results
    #   bench.display_results(results)
    #   
    #   # Get educational insights
    #   insights = bench.generate_insights(results)
    #   puts insights
    #
    class SearchBench
      attr_accessor :algorithms, :problems, :verbose, :timeout
      attr_reader :results, :problem_characteristics
      
      # Initialize a new search algorithm benchmark
      #
      # @param options [Hash] Configuration options
      # @option options [Boolean] :verbose (false) Enable detailed output
      # @option options [Integer] :timeout (30) Maximum seconds per algorithm/problem
      # @option options [Boolean] :educational_mode (true) Include educational insights
      # @option options [Boolean] :track_memory (true) Track memory usage
      def initialize(options = {})
        @algorithms = {}
        @problems = {}
        @verbose = options.fetch(:verbose, false)
        @timeout = options.fetch(:timeout, 30)
        @educational_mode = options.fetch(:educational_mode, true)
        @track_memory = options.fetch(:track_memory, true)
        @results = {}
        @problem_characteristics = {}
      end
      
      # Add a search algorithm to the benchmark
      #
      # @param name [Symbol] Unique identifier for the algorithm
      # @param algorithm [SearchAlgorithm] The algorithm instance
      # @param options [Hash] Algorithm-specific options
      def add_algorithm(name, algorithm, options = {})
        @algorithms[name] = {
          instance: algorithm,
          options: options,
          friendly_name: options[:friendly_name] || name.to_s.split('_').map(&:capitalize).join(' '),
          type: detect_algorithm_type(algorithm)
        }
        
        log "Added algorithm: #{@algorithms[name][:friendly_name]} (#{@algorithms[name][:type]})"
      end
      
      # Add a problem to benchmark against
      #
      # @param name [Symbol] Unique identifier for the problem
      # @param problem [Hash] Problem definition
      # @param options [Hash] Problem-specific options
      def add_problem(name, problem, options = {})
        validate_problem(problem)
        
        @problems[name] = {
          definition: problem,
          options: options,
          friendly_name: options[:friendly_name] || name.to_s.split('_').map(&:capitalize).join(' '),
          type: problem[:type]
        }
        
        log "Added problem: #{@problems[name][:friendly_name]} (#{@problems[name][:type]})"
      end
      
      # Run the benchmark on all algorithm/problem combinations
      #
      # @param options [Hash] Runtime options
      # @return [Hash] Comprehensive results for all combinations
      def run(options = {})
        validate_setup
        
        log "\n🏁 Starting Search Algorithm Benchmark Arena! 🏁"
        log "Algorithms: #{@algorithms.keys.join(', ')}"
        log "Problems: #{@problems.keys.join(', ')}"
        log "-" * 60
        
        @results = {}
        
        @algorithms.each do |algo_name, algo_info|
          @results[algo_name] = {}
          
          @problems.each do |prob_name, prob_info|
            log "\n🔍 Testing #{algo_info[:friendly_name]} on #{prob_info[:friendly_name]}..."
            
            @results[algo_name][prob_name] = benchmark_combination(
              algo_name, algo_info, prob_name, prob_info, options
            )
            
            if @educational_mode
              display_progress_insights(algo_name, prob_name, @results[algo_name][prob_name])
            end
          end
        end
        
        @results
      end
      
      # Display comprehensive results
      #
      # @param results [Hash] Results from run method (optional, uses @results if nil)
      def display_results(results = nil)
        results ||= @results
        
        puts "\n" + "=" * 80
        puts "🏆 SEARCH ALGORITHM BENCHMARK RESULTS 🏆".center(80)
        puts "=" * 80
        
        display_performance_comparison(results)
        display_efficiency_comparison(results)
        display_solution_quality_comparison(results)
        
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
        
        insights << "\n🎓 SEARCH ALGORITHM INSIGHTS 🎓\n"
        insights << "=" * 60 + "\n"
        
        # Algorithm characteristics
        insights << "\n🤖 Algorithm Characteristics:"
        @algorithms.each do |name, info|
          insights << "\n#{info[:friendly_name]} (#{info[:type]}):"
          insights.concat(generate_algorithm_insights(name, results[name]))
        end
        
        # Problem analysis
        insights << "\n📊 Problem Analysis:"
        @problems.each do |name, info|
          insights << "\n#{info[:friendly_name]} (#{info[:type]}):"
          insights.concat(generate_problem_insights(name, results))
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
      def export_results(format = :csv, filename = "search_bench_results")
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
      
      # Detect algorithm type based on class
      def detect_algorithm_type(algorithm)
        case algorithm.class.name
        when /AStar/
          :pathfinding
        when /Minimax/
          :game_tree
        when /Genetic/
          :optimization
        else
          :unknown
        end
      end
      
      # Validate problem definition
      def validate_problem(problem)
        raise ArgumentError, "Problem must be a hash" unless problem.is_a?(Hash)
        raise ArgumentError, "Problem must have a :type key" unless problem.key?(:type)
        
        case problem[:type]
        when :pathfinding
          validate_pathfinding_problem(problem)
        when :game
          validate_game_problem(problem)
        when :optimization
          validate_optimization_problem(problem)
        else
          raise ArgumentError, "Unknown problem type: #{problem[:type]}"
        end
      end
      
      # Validate pathfinding problem
      def validate_pathfinding_problem(problem)
        required_keys = [:grid, :start, :goal]
        required_keys.each do |key|
          raise ArgumentError, "Pathfinding problem must have #{key}" unless problem.key?(key)
        end
      end
      
      # Validate game problem
      def validate_game_problem(problem)
        required_keys = [:initial_state]
        required_keys.each do |key|
          raise ArgumentError, "Game problem must have #{key}" unless problem.key?(key)
        end
      end
      
      # Validate optimization problem
      def validate_optimization_problem(problem)
        required_keys = [:chromosome_class, :population_size, :generations]
        required_keys.each do |key|
          raise ArgumentError, "Optimization problem must have #{key}" unless problem.key?(key)
        end
      end
      
      # Validate benchmark setup
      def validate_setup
        raise RuntimeError, "No algorithms added" if @algorithms.empty?
        raise RuntimeError, "No problems added" if @problems.empty?
      end
      
      # Benchmark a specific algorithm/problem combination
      def benchmark_combination(algo_name, algo_info, prob_name, prob_info, options)
        result = {
          solution: nil,
          success: false,
          search_time: 0.0,
          nodes_explored: 0,
          solution_cost: nil,
          memory_usage: 0,
          error: nil,
          metadata: {}
        }
        
        algorithm = algo_info[:instance]
        problem = prob_info[:definition]
        
        begin
          # Check algorithm-problem compatibility
          unless compatible?(algo_info[:type], prob_info[:type])
            result[:error] = "Algorithm type #{algo_info[:type]} not compatible with problem type #{prob_info[:type]}"
            return result
          end
          
          # Run the algorithm with timeout
          start_time = Time.now
          start_memory = get_memory_usage if @track_memory
          
          solution = nil
          Timeout.timeout(@timeout) do
            solution = execute_algorithm(algorithm, problem)
          end
          
          end_time = Time.now
          end_memory = get_memory_usage if @track_memory
          
          # Extract results
          result[:solution] = solution
          result[:success] = !solution.nil?
          result[:search_time] = end_time - start_time
          result[:memory_usage] = @track_memory ? (end_memory - start_memory) : 0
          
          # Extract algorithm-specific metrics
          extract_algorithm_metrics(algorithm, result)
          
          # Calculate solution quality
          calculate_solution_quality(result, problem)
          
        rescue Timeout::Error
          result[:error] = "Algorithm timed out after #{@timeout} seconds"
        rescue => e
          result[:error] = "Algorithm failed: #{e.message}"
        end
        
        result
      end
      
      # Check if algorithm type is compatible with problem type
      def compatible?(algo_type, prob_type)
        compatibility_matrix = {
          pathfinding: [:pathfinding],
          game_tree: [:game],
          optimization: [:optimization]
        }
        
        compatibility_matrix[algo_type]&.include?(prob_type) || false
      end
      
      # Execute algorithm on problem
      def execute_algorithm(algorithm, problem)
        case problem[:type]
        when :pathfinding
          execute_pathfinding(algorithm, problem)
        when :game
          execute_game_search(algorithm, problem)
        when :optimization
          execute_optimization(algorithm, problem)
        else
          raise ArgumentError, "Unknown problem type: #{problem[:type]}"
        end
      end
      
      # Execute pathfinding algorithm
      def execute_pathfinding(algorithm, problem)
        # For A* algorithms, we need to create a new instance with the current grid
        # since the grid is set in the constructor
        if algorithm.class.name.include?('AStar')
          # Create new A* instance with the problem's grid
          new_astar = algorithm.class.new(problem[:grid], heuristic: algorithm.heuristic_function)
          solution = new_astar.find_path(problem[:start], problem[:goal])
          # Store the new instance for metrics extraction
          @current_algorithm_instance = new_astar
          solution
        else
          algorithm.find_path(problem[:start], problem[:goal])
        end
      end
      
      # Execute game tree search
      def execute_game_search(algorithm, problem)
        result = algorithm.find_best_move(problem[:initial_state])
        result.is_a?(Struct) ? result.best_move : result
      end
      
      # Execute optimization algorithm
      def execute_optimization(algorithm, problem)
        # This would need to be implemented based on the specific genetic algorithm interface
        # For now, return a placeholder
        algorithm.run if algorithm.respond_to?(:run)
      end
      
      # Extract algorithm-specific performance metrics
      def extract_algorithm_metrics(algorithm, result)
        # Use the current algorithm instance if available (for A*)
        actual_algorithm = @current_algorithm_instance || algorithm
        
        case actual_algorithm.class.name
        when /AStar/
          result[:nodes_explored] = actual_algorithm.nodes_explored || 0
          result[:nodes_generated] = actual_algorithm.nodes_generated || 0
          result[:path_cost] = actual_algorithm.path_cost || 0
          result[:metadata][:open_list_max_size] = actual_algorithm.open_list_max_size || 0
        when /Minimax/
          # Minimax results are typically returned as a struct
          # We'll need to extract from the last operation
          result[:nodes_explored] = actual_algorithm.instance_variable_get(:@nodes_explored) || 0
          result[:nodes_pruned] = actual_algorithm.instance_variable_get(:@nodes_pruned) || 0
          result[:metadata][:tree_depth] = actual_algorithm.instance_variable_get(:@max_depth_reached) || 0
        when /Genetic/
          result[:nodes_explored] = actual_algorithm.instance_variable_get(:@generations_run) || 0
          result[:metadata][:population_size] = actual_algorithm.instance_variable_get(:@population_size) || 0
        end
        
        # Reset the current algorithm instance
        @current_algorithm_instance = nil
      end
      
      # Calculate solution quality metrics
      def calculate_solution_quality(result, problem)
        return unless result[:success]
        
        case problem[:type]
        when :pathfinding
          # For pathfinding, solution quality = path length
          result[:solution_cost] = result[:solution]&.length || 0
        when :game
          # For games, solution quality would depend on the game evaluation
          result[:solution_cost] = 1 # Placeholder
        when :optimization
          # For optimization, solution quality = fitness value
          result[:solution_cost] = result[:solution]&.fitness || 0
        end
      end
      
      # Get current memory usage (simplified)
      def get_memory_usage
        # This is a simplified memory tracking approach
        # In a real implementation, you might use more sophisticated tools
        GC.stat[:heap_allocated_pages] * 1024 * 16 # Approximate memory usage
      end
      
      # Display performance comparison
      def display_performance_comparison(results)
        puts "\n⚡ Performance Comparison:"
        puts "-" * 70
        puts sprintf("%-20s %-15s %-15s %-15s", "Algorithm", "Avg Time (s)", "Avg Nodes", "Success Rate")
        puts "-" * 70
        
        results.each do |algo_name, algo_results|
          times = algo_results.values.map { |r| r[:search_time] }
          nodes = algo_results.values.map { |r| r[:nodes_explored] }
          successes = algo_results.values.count { |r| r[:success] }
          
          avg_time = times.sum / times.size
          avg_nodes = nodes.sum / nodes.size
          success_rate = (successes.to_f / algo_results.size * 100).round(1)
          
          puts sprintf("%-20s %-15.4f %-15d %-15s",
            @algorithms[algo_name][:friendly_name],
            avg_time,
            avg_nodes,
            "#{success_rate}%"
          )
        end
      end
      
      # Display efficiency comparison
      def display_efficiency_comparison(results)
        puts "\n📊 Efficiency Analysis:"
        puts "-" * 50
        
        results.each do |algo_name, algo_results|
          puts "\n#{@algorithms[algo_name][:friendly_name]}:"
          algo_results.each do |prob_name, result|
            if result[:success]
              efficiency = result[:nodes_explored] > 0 ? (result[:solution_cost].to_f / result[:nodes_explored]) : 0
              puts "  #{@problems[prob_name][:friendly_name]}: #{efficiency.round(4)} (cost/node)"
            else
              puts "  #{@problems[prob_name][:friendly_name]}: Failed - #{result[:error]}"
            end
          end
        end
      end
      
      # Display solution quality comparison
      def display_solution_quality_comparison(results)
        puts "\n🎯 Solution Quality:"
        puts "-" * 50
        
        @problems.each do |prob_name, prob_info|
          puts "\n#{prob_info[:friendly_name]}:"
          results.each do |algo_name, algo_results|
            result = algo_results[prob_name]
            if result[:success]
              quality = result[:solution_cost] || 0
              puts "  #{@algorithms[algo_name][:friendly_name]}: #{quality}"
            else
              puts "  #{@algorithms[algo_name][:friendly_name]}: No solution"
            end
          end
        end
      end
      
      # Display winner analysis
      def display_winner_analysis(results)
        puts "\n🏆 Winner Analysis:"
        puts "-" * 50
        
        # Find fastest algorithm
        fastest_times = {}
        results.each do |algo_name, algo_results|
          avg_time = algo_results.values.map { |r| r[:search_time] }.sum / algo_results.size
          fastest_times[algo_name] = avg_time
        end
        fastest = fastest_times.min_by { |_, time| time }
        
        puts "⚡ Fastest: #{@algorithms[fastest[0]][:friendly_name]} (#{fastest[1].round(4)}s avg)"
        
        # Find most efficient algorithm
        most_efficient = {}
        results.each do |algo_name, algo_results|
          successful_results = algo_results.values.select { |r| r[:success] }
          if successful_results.any?
            avg_nodes = successful_results.map { |r| r[:nodes_explored] }.sum / successful_results.size
            most_efficient[algo_name] = avg_nodes
          end
        end
        
        if most_efficient.any?
          efficient = most_efficient.min_by { |_, nodes| nodes }
          puts "🧠 Most Efficient: #{@algorithms[efficient[0]][:friendly_name]} (#{efficient[1].round(0)} avg nodes)"
        end
        
        # Find most reliable algorithm
        most_reliable = {}
        results.each do |algo_name, algo_results|
          success_rate = algo_results.values.count { |r| r[:success] }.to_f / algo_results.size
          most_reliable[algo_name] = success_rate
        end
        reliable = most_reliable.max_by { |_, rate| rate }
        
        puts "🎯 Most Reliable: #{@algorithms[reliable[0]][:friendly_name]} (#{(reliable[1] * 100).round(1)}% success)"
      end
      
      # Display recommendations
      def display_recommendations(results)
        puts "\n💡 Recommendations:"
        puts "-" * 50
        
        # Analyze algorithm performance patterns
        results.each do |algo_name, algo_results|
          successful_results = algo_results.values.select { |r| r[:success] }
          
          if successful_results.empty?
            puts "⚠️  #{@algorithms[algo_name][:friendly_name]} failed on all problems - check compatibility"
          elsif successful_results.size == algo_results.size
            puts "✅ #{@algorithms[algo_name][:friendly_name]} solved all problems successfully"
          else
            puts "⚠️  #{@algorithms[algo_name][:friendly_name]} had mixed results - problem-dependent performance"
          end
        end
      end
      
      # Generate algorithm-specific insights
      def generate_algorithm_insights(algo_name, algo_results)
        insights = []
        return insights unless algo_results
        
        successful_results = algo_results.values.select { |r| r[:success] }
        
        if successful_results.empty?
          insights << "  ❌ Algorithm failed on all tested problems"
          return insights
        end
        
        avg_time = successful_results.map { |r| r[:search_time] }.sum / successful_results.size
        avg_nodes = successful_results.map { |r| r[:nodes_explored] }.sum / successful_results.size
        
        # Performance insights
        if avg_time < 0.001
          insights << "  ⚡ Lightning fast execution (<1ms)"
        elsif avg_time < 0.01
          insights << "  🏃 Fast execution (<10ms)"
        elsif avg_time < 0.1
          insights << "  → Moderate execution time (<100ms)"
        else
          insights << "  🐌 Slow execution (>100ms)"
        end
        
        # Efficiency insights
        if avg_nodes < 50
          insights << "  🧠 Highly efficient (explores few nodes)"
        elsif avg_nodes < 200
          insights << "  📊 Moderately efficient"
        else
          insights << "  📈 Explores many nodes (less efficient)"
        end
        
        insights
      end
      
      # Generate problem-specific insights
      def generate_problem_insights(prob_name, results)
        insights = []
        
        # Analyze how different algorithms performed on this problem
        problem_results = results.map { |algo_name, algo_results| algo_results[prob_name] }
        successful_results = problem_results.select { |r| r[:success] }
        
        if successful_results.empty?
          insights << "  ❌ No algorithm could solve this problem"
        elsif successful_results.size == problem_results.size
          insights << "  ✅ All algorithms solved this problem"
        else
          insights << "  ⚠️  Only some algorithms could solve this problem"
        end
        
        if successful_results.any?
          times = successful_results.map { |r| r[:search_time] }
          time_variance = times.max - times.min
          
          if time_variance > 0.1
            insights << "  📊 High performance variance between algorithms"
          else
            insights << "  📊 Similar performance across algorithms"
          end
        end
        
        insights
      end
      
      # Generate comparative insights
      def generate_comparative_insights(results)
        insights = []
        
        # Overall performance comparison
        total_successes = results.map { |_, algo_results| algo_results.values.count { |r| r[:success] } }.sum
        total_attempts = results.size * @problems.size
        
        if total_successes == total_attempts
          insights << "• All algorithm/problem combinations were successful"
        elsif total_successes > total_attempts * 0.8
          insights << "• Most combinations were successful (>80%)"
        else
          insights << "• Many combinations failed - check algorithm/problem compatibility"
        end
        
        # Performance spread analysis
        all_times = results.values.flat_map { |algo_results| algo_results.values.map { |r| r[:search_time] } }
        if all_times.any? && all_times.max > all_times.min * 10
          insights << "• Significant performance differences between algorithms"
        end
        
        insights
      end
      
      # Generate learning recommendations
      def generate_learning_recommendations(results)
        recommendations = []
        
        # General learning recommendations
        recommendations << "• Try different problem types to understand algorithm strengths"
        recommendations << "• Compare heuristic functions for pathfinding algorithms"
        recommendations << "• Experiment with different search depths for game algorithms"
        recommendations << "• Analyze the trade-off between solution quality and search time"
        
        # Algorithm-specific recommendations
        if @algorithms.any? { |_, info| info[:type] == :pathfinding }
          recommendations << "• For pathfinding: Test different heuristics and grid densities"
        end
        
        if @algorithms.any? { |_, info| info[:type] == :game_tree }
          recommendations << "• For game search: Try different depth limits and pruning strategies"
        end
        
        if @algorithms.any? { |_, info| info[:type] == :optimization }
          recommendations << "• For optimization: Experiment with population sizes and mutation rates"
        end
        
        recommendations
      end
      
      # Display progress insights during benchmarking
      def display_progress_insights(algo_name, prob_name, result)
        if result[:success]
          time = result[:search_time]
          nodes = result[:nodes_explored]
          
          insight = if time < 0.01 && nodes < 50
            "🚀 Lightning fast and efficient!"
          elsif time < 0.01
            "⚡ Super speedy!"
          elsif nodes < 50
            "🧠 Very efficient!"
          else
            "✓ Completed"
          end
          
          log "  #{insight} - Time: #{time.round(4)}s, Nodes: #{nodes}"
        else
          log "  ❌ Failed: #{result[:error]}"
        end
      end
      
      # Export results to CSV
      def export_to_csv(filename)
        require 'csv'
        
        CSV.open("#{filename}.csv", "w") do |csv|
          # Header
          csv << ["Algorithm", "Problem", "Success", "Time(s)", "Nodes", "Solution Cost", "Error"]
          
          # Data rows
          @results.each do |algo_name, algo_results|
            algo_results.each do |prob_name, result|
              csv << [
                @algorithms[algo_name][:friendly_name],
                @problems[prob_name][:friendly_name],
                result[:success],
                result[:search_time],
                result[:nodes_explored],
                result[:solution_cost],
                result[:error]
              ]
            end
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
            algorithms: @algorithms.keys,
            problems: @problems.keys,
            timeout: @timeout
          },
          results: @results.map do |algo_name, algo_results|
            {
              algorithm: @algorithms[algo_name][:friendly_name],
              type: @algorithms[algo_name][:type],
              problems: algo_results.map do |prob_name, result|
                {
                  problem: @problems[prob_name][:friendly_name],
                  success: result[:success],
                  search_time: result[:search_time],
                  nodes_explored: result[:nodes_explored],
                  solution_cost: result[:solution_cost],
                  error: result[:error]
                }
              end
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
        <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>Search Algorithm Benchmark Results</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    .success { color: green; }
    .failure { color: red; }
  </style>
</head>
<body>
  <h1>Search Algorithm Benchmark Results</h1>
  <p>Generated at: #{Time.now}</p>
  
  <h2>Performance Summary</h2>
  <table>
    <tr>
      <th>Algorithm</th>
      <th>Problem</th>
      <th>Success</th>
      <th>Time (s)</th>
      <th>Nodes Explored</th>
      <th>Solution Cost</th>
    </tr>
    #{@results.map { |algo_name, algo_results|
      algo_results.map { |prob_name, result|
        "<tr>
          <td>#{@algorithms[algo_name][:friendly_name]}</td>
          <td>#{@problems[prob_name][:friendly_name]}</td>
          <td class='#{result[:success] ? 'success' : 'failure'}'>#{result[:success]}</td>
          <td>#{result[:search_time].round(4)}</td>
          <td>#{result[:nodes_explored]}</td>
          <td>#{result[:solution_cost]}</td>
        </tr>"
      }.join("\n")
    }.join("\n")}
  </table>
  
  <h2>Educational Insights</h2>
  <pre>#{generate_insights}</pre>
</body>
</html>
        HTML
      end
      
      # Log message if verbose mode is enabled
      def log(message)
        puts message if @verbose
      end
    end
  end
end