# frozen_string_literal: true

# Enhanced educational genetic algorithm framework
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'modern_genetic_search'
require_relative 'operators'
require_relative 'chromosome'
require_relative 'configuration'
require_relative '../utilities/monitoring/evolution_monitor'
require_relative '../educational/demos/genetic_algorithm_demos'
require_relative '../utilities/visualization/genetic_algorithm_visualization'
require_relative 'enhanced_operators'

module Ai4r
  module GeneticAlgorithm
    # Educational genetic algorithm with comprehensive learning features
    class EducationalGeneticSearch < ModernGeneticSearch
      attr_reader :learning_mode, :concept_tracker, :comparative_results

      def initialize(config = Configuration.new, learning_mode: :guided)
        super(config)
        @learning_mode = learning_mode
        @concept_tracker = ConceptTracker.new
        @comparative_results = {}
        @step_explanations = true
        @parameter_sensitivity = {}
      end

      # Enable different learning modes
      def set_learning_mode(mode)
        @learning_mode = mode
        case mode
        when :guided
          @config.verbose = true
          @step_explanations = true
        when :exploratory
          @step_explanations = false
        when :comparative
          @comparative_results = {}
        when :research
          @monitor.enable_detailed_tracking
        end
        self
      end

      # Interactive tutorial mode - step through GA concepts
      def run_tutorial(chromosome_class, *args)
        puts '=== Interactive Genetic Algorithm Tutorial ==='
        puts 'Learn genetic algorithms step by step!'
        puts

        explain_genetic_algorithms
        wait_for_user

        explain_chromosome_representation(chromosome_class)
        wait_for_user

        explain_fitness_function(chromosome_class, *args)
        wait_for_user

        explain_selection(@selection_operator)
        wait_for_user

        explain_crossover(@crossover_operator)
        wait_for_user

        explain_mutation(@mutation_operator)
        wait_for_user

        explain_replacement(@replacement_operator)
        wait_for_user

        puts "Now let's run the algorithm step by step!"
        result = run_step_by_step(chromosome_class, *args)

        explain_results(result)

        result
      end

      # Comparative analysis - run with different operators/parameters
      def run_comparative_analysis(chromosome_class, *args)
        puts '=== Comparative Analysis of Genetic Algorithm Components ==='
        puts 'Testing different operators and parameters...'
        puts

        base_config = @config.clone

        # Test different selection operators
        puts '1. Comparing Selection Operators:'
        selection_operators = [
          TournamentSelection.new(2),
          TournamentSelection.new(5),
          EnhancedSelectionOperators::RankSelection.new
        ]

        compare_operators('Selection', selection_operators, chromosome_class, *args) do |operator|
          ModernGeneticSearch.new(base_config).with_selection(operator)
        end

        # Test different crossover operators
        puts "\n2. Comparing Crossover Operators:"
        crossover_operators = [
          SinglePointCrossover.new,
          EnhancedCrossoverOperators::TwoPointCrossover.new,
          UniformCrossover.new
        ]

        compare_operators('Crossover', crossover_operators, chromosome_class, *args) do |operator|
          ModernGeneticSearch.new(base_config).with_crossover(operator)
        end

        # Test different mutation rates
        puts "\n3. Comparing Mutation Rates:"
        mutation_rates = [0.01, 0.05, 0.1, 0.2]

        mutation_rates.each do |rate|
          config = base_config.clone
          config.mutation_rate = rate

          ga = ModernGeneticSearch.new(config)
          puts "Testing mutation rate: #{rate}"
          result = ga.run(chromosome_class, *args)

          @comparative_results["mutation_#{rate}"] = {
            best_fitness: result.fitness,
            generations: ga.generation,
            final_diversity: calculate_diversity(ga.population)
          }
        end

        display_comparative_summary

        @comparative_results
      end

      # Parameter sensitivity analysis
      def analyze_parameter_sensitivity(chromosome_class, *args)
        puts '=== Parameter Sensitivity Analysis ==='
        puts 'Analyzing how different parameters affect performance...'
        puts

        base_config = @config.clone
        parameters = {
          population_size: [20, 50, 100, 200],
          mutation_rate: [0.01, 0.05, 0.1, 0.15],
          crossover_rate: [0.6, 0.7, 0.8, 0.9],
          selection_pressure: [2, 3, 5, 7]
        }

        parameters.each do |param_name, values|
          puts "Analyzing #{param_name}:"
          param_results = {}

          values.each do |value|
            config = base_config.clone

            case param_name
            when :population_size
              config.population_size = value
            when :mutation_rate
              config.mutation_rate = value
            when :crossover_rate
              config.crossover_rate = value
            when :selection_pressure
              # Update selection operator
              @selection_operator = TournamentSelection.new(value)
            end

            # Run multiple times for statistical significance
            results = []
            3.times do
              ga = ModernGeneticSearch.new(config)
              ga.selection_operator = @selection_operator if param_name == :selection_pressure

              result = ga.run(chromosome_class, *args)
              results << result.fitness
            end

            avg_fitness = results.sum / results.length
            param_results[value] = avg_fitness

            puts "  #{param_name} = #{value}: avg fitness = #{avg_fitness.round(4)}"
          end

          @parameter_sensitivity[param_name] = param_results
          puts
        end

        generate_sensitivity_report
        @parameter_sensitivity
      end

      # Concept-based learning with explanations
      def learn_concept(concept, chromosome_class, *args)
        case concept
        when :selection_pressure
          demonstrate_selection_pressure(chromosome_class, *args)
        when :population_diversity
          demonstrate_diversity_importance(chromosome_class, *args)
        when :exploration_vs_exploitation
          demonstrate_exploration_exploitation(chromosome_class, *args)
        when :premature_convergence
          demonstrate_premature_convergence(chromosome_class, *args)
        when :operator_interactions
          demonstrate_operator_interactions(chromosome_class, *args)
        else
          puts "Unknown concept: #{concept}"
          puts 'Available concepts: :selection_pressure, :population_diversity, '
          puts '                   :exploration_vs_exploitation, :premature_convergence, '
          puts '                   :operator_interactions'
        end
      end

      # Interactive parameter tuning
      def interactive_parameter_tuning(chromosome_class, *args)
        puts '=== Interactive Parameter Tuning ==='
        puts 'Experiment with different parameters and see the effects!'
        puts

        loop do
          display_current_config
          puts "\nChoose parameter to modify:"
          puts '1. Population size'
          puts '2. Mutation rate'
          puts '3. Crossover rate'
          puts '4. Selection pressure'
          puts '5. Run algorithm'
          puts '6. Exit'

          choice = gets.chomp.to_i

          case choice
          when 1
            adjust_population_size
          when 2
            adjust_mutation_rate
          when 3
            adjust_crossover_rate
          when 4
            adjust_selection_pressure
          when 5
            puts 'Running with current parameters...'
            result = run(chromosome_class, *args)
            puts "Best result: #{result.fitness}"
            plot_fitness
          when 6
            break
          else
            puts 'Invalid choice. Please try again.'
          end
        end
      end

      # Problem-specific educational examples
      def run_educational_example(problem_type, difficulty: :beginner)
        case problem_type
        when :optimization_basics
          optimization_basics_example(difficulty)
        when :constraint_handling
          constraint_handling_example(difficulty)
        when :multi_objective
          multi_objective_example(difficulty)
        when :dynamic_optimization
          dynamic_optimization_example(difficulty)
        when :real_world_application
          real_world_application_example(difficulty)
        else
          puts "Unknown problem type: #{problem_type}"
        end
      end

      # Algorithm comparison framework
      def compare_with_other_algorithms(chromosome_class, *args)
        puts '=== Genetic Algorithm vs Other Optimization Methods ==='
        puts 'Comparing GA with random search, hill climbing, and simulated annealing'
        puts

        # Run GA
        ga_result = run(chromosome_class, *args)

        # Run random search
        random_result = run_random_search(chromosome_class, @config.max_generations * @config.population_size, *args)

        # Run hill climbing
        hill_climbing_result = run_hill_climbing(chromosome_class, @config.max_generations, *args)

        # Display comparison
        puts 'Results Comparison:'
        puts "Genetic Algorithm: #{ga_result.fitness.round(4)}"
        puts "Random Search: #{random_result.fitness.round(4)}"
        puts "Hill Climbing: #{hill_climbing_result.fitness.round(4)}"

        analyze_algorithm_differences

        {
          genetic_algorithm: ga_result.fitness,
          random_search: random_result.fitness,
          hill_climbing: hill_climbing_result.fitness
        }
      end

      # Advanced visualization of evolution
      def visualize_evolution
        VisualizationTools.plot_evolution_timeline(@monitor, 'Genetic Algorithm Evolution')
        VisualizationTools.plot_convergence_analysis(@monitor)
        VisualizationTools.plot_diversity_evolution(@monitor)
      end

      # Visualize population analysis
      def visualize_population
        VisualizationTools.plot_population_analysis(@population, 'Current Population Analysis')
      end

      # Visualize comparative results
      def visualize_comparisons
        if @comparative_results.any?
          VisualizationTools.plot_operator_comparison(@comparative_results, 'Operator Performance Comparison')
        end

        if @parameter_sensitivity.any?
          VisualizationTools.plot_parameter_sensitivity(@parameter_sensitivity, 'Parameter Sensitivity Analysis')
        end
      end

      # Export learning session data
      def export_learning_session(filename)
        data = {
          timestamp: Time.now,
          learning_mode: @learning_mode,
          configuration: @config.to_h,
          comparative_results: @comparative_results,
          parameter_sensitivity: @parameter_sensitivity,
          concepts_learned: @concept_tracker.learned_concepts,
          evolution_data: @monitor.export_data
        }

        File.open(filename, 'w') do |file|
          require 'json'
          file.write(JSON.pretty_generate(data))
        end

        puts "Learning session exported to #{filename}"
      end

      private

      def explain_genetic_algorithms
        puts '=== What are Genetic Algorithms? ==='
        puts
        puts 'Genetic Algorithms (GAs) are optimization techniques inspired by biological evolution.'
        puts 'They work by evolving a population of candidate solutions over many generations.'
        puts
        puts 'Key concepts:'
        puts '• Population: A collection of candidate solutions'
        puts '• Chromosome: An individual solution representation'
        puts '• Fitness: How good a solution is'
        puts '• Selection: Choosing better solutions to reproduce'
        puts '• Crossover: Combining solutions to create offspring'
        puts '• Mutation: Small random changes to maintain diversity'
        puts
        puts 'The algorithm iteratively improves the population through these operations.'
      end

      def explain_chromosome_representation(chromosome_class)
        puts '=== Chromosome Representation ==='
        puts
        puts "For this problem, we're using: #{chromosome_class.name}"
        puts

        case chromosome_class.name
        when /Binary/
          puts 'Binary representation uses strings of 0s and 1s.'
          puts 'Each bit represents a decision or feature.'
          puts 'Example: [1, 0, 1, 1, 0] might represent which items to include.'
        when /Real/
          puts 'Real-valued representation uses floating-point numbers.'
          puts 'Each gene is a continuous value within specified bounds.'
          puts 'Example: [2.5, -1.3, 0.8] for function optimization.'
        when /Permutation/
          puts 'Permutation representation uses ordered sequences.'
          puts 'Each gene appears exactly once (no duplicates).'
          puts 'Example: [3, 1, 4, 2, 0] for routing or scheduling problems.'
        end

        puts
        puts 'The representation must capture all important aspects of your problem!'
      end

      def explain_fitness_function(chromosome_class, *args)
        puts '=== Fitness Function ==='
        puts
        puts "The fitness function evaluates how 'good' each solution is."
        puts "It's the driving force of evolution - better solutions get more chances to reproduce."
        puts
        puts 'Important properties:'
        puts '• Must return comparable numbers (higher = better)'
        puts '• Should capture the true objective of the problem'
        puts '• Can include penalties for constraint violations'
        puts '• Should be reasonably fast to compute'
        puts

        # Create example chromosome to show fitness calculation
        example = chromosome_class.random_chromosome(*args)
        puts "Example chromosome: #{example.genes[0..4].inspect}#{'...' if example.genes.length > 5}"
        puts "Fitness: #{example.fitness}"
      end

      def explain_selection(operator)
        puts "=== Selection Operator: #{operator.name} ==="
        puts
        puts operator.description
        puts
        puts 'Selection creates selection pressure - better individuals have higher'
        puts 'probability of being chosen for reproduction.'
        puts
        puts 'Key considerations:'
        puts '• Too much pressure → premature convergence'
        puts '• Too little pressure → slow evolution'
        puts '• Different operators have different characteristics'
      end

      def explain_crossover(operator)
        puts "=== Crossover Operator: #{operator.name} ==="
        puts
        puts operator.description
        puts
        puts 'Crossover combines genetic material from two parents to create offspring.'
        puts 'This allows the algorithm to explore new combinations of good features.'
        puts
        puts 'Important aspects:'
        puts '• Should preserve good building blocks'
        puts '• Must respect the chromosome representation'
        puts '• Different operators suit different problem types'
      end

      def explain_mutation(operator)
        puts "=== Mutation Operator: #{operator.name} ==="
        puts
        puts operator.description
        puts
        puts 'Mutation introduces small random changes to maintain genetic diversity.'
        puts 'It helps prevent premature convergence and explores new areas.'
        puts
        puts 'Key points:'
        puts '• Usually applied with low probability'
        puts '• Provides exploration capability'
        puts '• Can help escape local optima'
      end

      def explain_replacement(operator)
        puts "=== Replacement Strategy: #{operator.name} ==="
        puts
        puts operator.description
        puts
        puts 'Replacement determines which individuals survive to the next generation.'
        puts 'It balances between keeping good solutions and maintaining diversity.'
      end

      def explain_results(result)
        puts "\n=== Understanding the Results ==="
        puts
        puts "Best solution found: #{result}"
        puts "Final fitness: #{result.fitness}"
        puts
        puts 'Key observations:'
        puts '• Did the algorithm converge to a good solution?'
        puts '• How quickly did it improve?'
        puts '• Was there enough diversity throughout evolution?'
        puts
        puts 'The evolution plot shows fitness over generations.'
        puts 'Look for: steady improvement, convergence patterns, diversity loss.'
      end

      def wait_for_user
        puts "\nPress Enter to continue..."
        gets
      end

      def compare_operators(type, operators, chromosome_class, *args)
        operators.each do |operator|
          puts "Testing #{operator.name}:"

          # Run algorithm with this operator
          ga = yield(operator)
          result = ga.run(chromosome_class, *args)

          @comparative_results["#{type.downcase}_#{operator.name}"] = {
            best_fitness: result.fitness,
            generations: ga.generation,
            convergence_rate: calculate_convergence_rate(ga.monitor.generation_stats)
          }

          puts "  Best fitness: #{result.fitness.round(4)}"
          puts "  Converged in: #{ga.generation} generations"
        end
      end

      def display_comparative_summary
        puts "\n=== Comparative Analysis Summary ==="

        @comparative_results.each do |name, data|
          puts "#{name}: fitness=#{data[:best_fitness].round(4)}, " \
               "generations=#{data[:generations]}, " \
               "diversity=#{data[:final_diversity]&.round(4) || 'N/A'}"
        end

        # Find best performer
        best = @comparative_results.max_by { |_, data| data[:best_fitness] }
        puts "\nBest performer: #{best[0]} with fitness #{best[1][:best_fitness].round(4)}"
      end

      def demonstrate_selection_pressure(chromosome_class, *args)
        puts '=== Demonstrating Selection Pressure ==='
        puts
        puts 'Selection pressure determines how strongly better individuals are favored.'
        puts "Let's see the effect of different tournament sizes:"
        puts

        tournament_sizes = [2, 3, 5, 10]
        results = {}

        tournament_sizes.each do |size|
          puts "Tournament size #{size}:"

          config = @config.clone
          config.max_generations = 50
          config.verbose = false

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(TournamentSelection.new(size))

          result = ga.run(chromosome_class, *args)
          results[size] = {
            fitness: result.fitness,
            diversity: calculate_diversity(ga.population)
          }

          puts "  Final fitness: #{result.fitness.round(4)}"
          puts "  Final diversity: #{results[size][:diversity].round(4)}"
        end

        puts "\nObservations:"
        puts '• Higher tournament size → stronger selection pressure'
        puts '• Strong pressure → faster convergence but less diversity'
        puts '• Weak pressure → slower convergence but more exploration'
      end

      def demonstrate_diversity_importance(chromosome_class, *args)
        puts '=== Demonstrating Population Diversity ==='
        puts
        puts 'Diversity prevents premature convergence and enables exploration.'
        puts "Let's compare different population sizes:"
        puts

        pop_sizes = [10, 30, 50, 100]

        pop_sizes.each do |size|
          puts "Population size #{size}:"

          config = @config.clone
          config.population_size = size
          config.max_generations = 100
          config.verbose = false

          ga = ModernGeneticSearch.new(config)
          result = ga.run(chromosome_class, *args)

          diversity_history = ga.monitor.generation_stats.map { |stats| stats[:diversity] }
          final_diversity = diversity_history.last

          puts "  Final fitness: #{result.fitness.round(4)}"
          puts "  Final diversity: #{final_diversity.round(4)}"
          puts "  Diversity trend: #{diversity_trend(diversity_history)}"
        end

        puts "\nKey insights:"
        puts '• Larger populations maintain diversity longer'
        puts '• Diversity loss can indicate convergence'
        puts '• Balance between convergence speed and exploration'
      end

      def demonstrate_exploration_exploitation(chromosome_class, *args)
        puts '=== Exploration vs Exploitation Trade-off ==='
        puts
        puts 'GAs must balance exploring new areas with exploiting known good areas.'
        puts "Let's see how mutation rate affects this balance:"
        puts

        mutation_rates = [0.01, 0.05, 0.1, 0.2]

        mutation_rates.each do |rate|
          puts "Mutation rate #{rate}:"

          config = @config.clone
          config.mutation_rate = rate
          config.max_generations = 100
          config.verbose = false

          ga = ModernGeneticSearch.new(config)
          result = ga.run(chromosome_class, *args)

          puts "  Final fitness: #{result.fitness.round(4)}"
          puts "  Generations to best: #{find_best_generation(ga.monitor.generation_stats)}"
        end

        puts "\nObservations:"
        puts '• Low mutation → more exploitation, faster initial convergence'
        puts '• High mutation → more exploration, maintains diversity longer'
        puts '• Optimal rate depends on problem and other parameters'
      end

      def demonstrate_premature_convergence(chromosome_class, *args)
        puts '=== Demonstrating Premature Convergence ==='
        puts
        puts 'Premature convergence occurs when the population becomes too similar too quickly.'
        puts 'This can trap the algorithm in local optima.'
        puts

        # Create scenarios prone to premature convergence
        scenarios = [
          { name: 'High selection pressure', selection: TournamentSelection.new(10), mutation_rate: 0.01 },
          { name: 'Low mutation', selection: TournamentSelection.new(3), mutation_rate: 0.001 },
          { name: 'Small population', selection: TournamentSelection.new(3), mutation_rate: 0.05, pop_size: 10 }
        ]

        scenarios.each do |scenario|
          puts "Scenario: #{scenario[:name]}"

          config = @config.clone
          config.mutation_rate = scenario[:mutation_rate]
          config.population_size = scenario[:pop_size] || config.population_size
          config.max_generations = 50
          config.verbose = false

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(scenario[:selection])

          result = ga.run(chromosome_class, *args)

          # Check for premature convergence
          diversity_history = ga.monitor.generation_stats.map { |stats| stats[:diversity] }
          premature = diversity_history.last < 0.1 && ga.generation < config.max_generations

          puts "  Final fitness: #{result.fitness.round(4)}"
          puts "  Final diversity: #{diversity_history.last.round(4)}"
          puts "  Premature convergence: #{premature ? 'Yes' : 'No'}"
        end

        puts "\nPrevention strategies:"
        puts '• Maintain reasonable mutation rates'
        puts '• Use appropriate selection pressure'
        puts '• Ensure sufficient population size'
        puts '• Consider diversity-preserving techniques'
      end

      def demonstrate_operator_interactions(chromosome_class, *args)
        puts '=== Operator Interactions ==='
        puts
        puts "GA operators work together - changing one affects the others' effectiveness."
        puts "Let's explore some important interactions:"
        puts

        # Test operator combinations
        combinations = [
          { name: 'Aggressive', selection: TournamentSelection.new(5), crossover_rate: 0.9, mutation_rate: 0.01 },
          { name: 'Balanced', selection: TournamentSelection.new(3), crossover_rate: 0.7, mutation_rate: 0.05 },
          { name: 'Exploratory', selection: RouletteWheelSelection.new, crossover_rate: 0.6, mutation_rate: 0.1 }
        ]

        combinations.each do |combo|
          puts "Strategy: #{combo[:name]}"

          config = @config.clone
          config.crossover_rate = combo[:crossover_rate]
          config.mutation_rate = combo[:mutation_rate]
          config.max_generations = 100
          config.verbose = false

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(combo[:selection])

          result = ga.run(chromosome_class, *args)

          puts "  Final fitness: #{result.fitness.round(4)}"
          puts "  Convergence generation: #{find_convergence_generation(ga.monitor.generation_stats)}"
        end

        puts "\nKey interactions:"
        puts '• High selection pressure + low mutation → fast convergence, risk of local optima'
        puts '• Low selection pressure + high mutation → slow convergence, good exploration'
        puts '• High crossover + low mutation → exploitation focus'
        puts '• Balanced parameters often work best'
      end

      def calculate_diversity(population)
        return 0.0 if population.empty? || population.size < 2

        total_distance = 0.0
        count = 0

        population.each_with_index do |ind1, i|
          population.each_with_index do |ind2, j|
            next if i >= j

            distance = chromosome_distance(ind1, ind2)
            total_distance += distance
            count += 1
          end
        end

        count > 0 ? total_distance / count : 0.0
      end

      def chromosome_distance(chr1, chr2)
        # Simple hamming distance for binary, euclidean for real
        if chr1.genes.first.is_a?(Numeric)
          # Euclidean distance for real-valued
          sum = chr1.genes.zip(chr2.genes).sum { |a, b| (a - b)**2 }
          Math.sqrt(sum)
        else
          # Hamming distance for binary/discrete
          chr1.genes.zip(chr2.genes).count { |a, b| a != b }.to_f
        end
      end

      def calculate_convergence_rate(stats)
        return 0 if stats.empty?

        first_fitness = stats.first[:best_fitness]
        last_fitness = stats.last[:best_fitness]

        return 0 if first_fitness == last_fitness

        (last_fitness - first_fitness) / stats.length
      end

      def find_best_generation(stats)
        best_fitness = stats.map { |s| s[:best_fitness] }.max
        stats.find_index { |s| s[:best_fitness] == best_fitness } + 1
      end

      def find_convergence_generation(stats)
        return stats.length if stats.length < 10

        # Find when improvement becomes minimal
        (10...stats.length).each do |i|
          recent_improvement = stats[i][:best_fitness] - stats[i - 10][:best_fitness]
          return i if recent_improvement < 0.01
        end

        stats.length
      end

      def diversity_trend(diversity_history)
        return 'stable' if diversity_history.length < 2

        start_div = diversity_history.first(5).sum / [diversity_history.length, 5].min
        end_div = diversity_history.last(5).sum / [diversity_history.length, 5].min

        if end_div < start_div * 0.5
          'decreasing rapidly'
        elsif end_div < start_div * 0.8
          'decreasing'
        elsif end_div > start_div * 1.2
          'increasing'
        else
          'stable'
        end
      end

      def display_current_config
        puts "\nCurrent Configuration:"
        puts "Population size: #{@config.population_size}"
        puts "Mutation rate: #{@config.mutation_rate}"
        puts "Crossover rate: #{@config.crossover_rate}"
        puts "Selection pressure: #{@selection_operator.is_a?(TournamentSelection) ? @selection_operator.tournament_size : 'N/A'}"
      end

      def adjust_population_size
        print "Enter new population size (current: #{@config.population_size}): "
        input = gets.chomp.to_i
        @config.population_size = input if input > 0
      end

      def adjust_mutation_rate
        print "Enter new mutation rate (current: #{@config.mutation_rate}): "
        input = gets.chomp.to_f
        @config.mutation_rate = input if input.between?(0, 1)
      end

      def adjust_crossover_rate
        print "Enter new crossover rate (current: #{@config.crossover_rate}): "
        input = gets.chomp.to_f
        @config.crossover_rate = input if input.between?(0, 1)
      end

      def adjust_selection_pressure
        print "Enter new tournament size for selection (current: #{@selection_operator.respond_to?(:tournament_size) ? @selection_operator.tournament_size : 'N/A'}): "
        input = gets.chomp.to_i
        @selection_operator = TournamentSelection.new(input) if input > 0
      end

      def generate_sensitivity_report
        puts "\n=== Parameter Sensitivity Report ==="

        @parameter_sensitivity.each do |param, results|
          puts "\n#{param.to_s.capitalize}:"

          # Find best and worst values
          best = results.max_by { |_, fitness| fitness }
          worst = results.min_by { |_, fitness| fitness }

          puts "  Best value: #{best[0]} (fitness: #{best[1].round(4)})"
          puts "  Worst value: #{worst[0]} (fitness: #{worst[1].round(4)})"

          # Calculate sensitivity
          sensitivity = (best[1] - worst[1]) / best[1]
          puts "  Sensitivity: #{(sensitivity * 100).round(1)}%"

          if sensitivity > 0.1
            puts '  → High impact parameter - tune carefully'
          elsif sensitivity > 0.05
            puts '  → Moderate impact parameter'
          else
            puts '  → Low impact parameter - default values likely fine'
          end
        end
      end

      def run_random_search(chromosome_class, evaluations, *args)
        best = chromosome_class.random_chromosome(*args)

        (evaluations - 1).times do
          candidate = chromosome_class.random_chromosome(*args)
          best = candidate if candidate.fitness > best.fitness
        end

        best
      end

      def run_hill_climbing(chromosome_class, max_iterations, *args)
        current = chromosome_class.random_chromosome(*args)

        max_iterations.times do
          # Generate neighbor (simple mutation)
          neighbor = current.clone
          if neighbor.respond_to?(:mutate_single)
            neighbor.mutate_single
          else
            # Default mutation approach
            @mutation_operator.mutate(neighbor, 0.1)
          end

          # Accept if better
          current = neighbor if neighbor.fitness > current.fitness
        end

        current
      end

      def analyze_algorithm_differences
        puts "\nAlgorithm Characteristics:"
        puts '• Genetic Algorithm: Population-based, global search, handles multimodal problems'
        puts '• Random Search: Simple, unbiased, good baseline'
        puts '• Hill Climbing: Local search, fast, can get stuck in local optima'
        puts
        puts 'When to use each:'
        puts '• GA: Complex, multimodal, or poorly understood problems'
        puts '• Random: Quick baseline, very noisy functions'
        puts '• Hill Climbing: Smooth, unimodal functions'
      end

      # Educational example implementations
      def optimization_basics_example(difficulty)
        case difficulty
        when :beginner
          puts '=== Basic Optimization with OneMax ==='
          Examples.run_onemax_example
        when :intermediate
          puts '=== Function Optimization ==='
          Examples.run_sphere_example
        when :advanced
          puts '=== Multi-modal Optimization ==='
          Examples.run_custom_function_example
        end
      end

      def constraint_handling_example(_difficulty)
        puts '=== Constraint Handling Example ==='
        puts 'Using Knapsack problem to demonstrate constraint handling...'
        Examples.run_knapsack_example
      end

      def multi_objective_example(_difficulty)
        puts '=== Multi-Objective Optimization Concepts ==='
        puts 'While full NSGA-II is beyond this implementation,'
        puts 'we can demonstrate the concepts with weighted objectives...'

        # Simple weighted multi-objective example
        MultiObjectiveDemo.new.run_weighted_example
      end

      def dynamic_optimization_example(_difficulty)
        puts '=== Dynamic Optimization Concepts ==='
        puts 'Demonstrating how GAs can adapt to changing environments...'

        DynamicOptimizationDemo.new.run_example
      end

      def real_world_application_example(difficulty)
        puts '=== Real-World Application: Job Scheduling ==='

        JobSchedulingExample.new.run_example(difficulty)
      end
    end

    # Helper class for tracking learning concepts
    class ConceptTracker
      attr_reader :learned_concepts

      def initialize
        @learned_concepts = []
        @concept_timestamps = {}
      end

      def mark_learned(concept)
        @learned_concepts << concept unless @learned_concepts.include?(concept)
        @concept_timestamps[concept] = Time.now
      end

      def learning_progress
        total_concepts = %i[selection crossover mutation fitness population
                            diversity convergence selection_pressure parameter_tuning]
        (@learned_concepts.length.to_f / total_concepts.length * 100).round(1)
      end
    end
  end
end
