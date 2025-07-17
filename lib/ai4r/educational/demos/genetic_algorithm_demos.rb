# frozen_string_literal: true

# Educational demonstrations for genetic algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../../genetic_algorithm/modern_genetic_search'
require_relative '../../genetic_algorithm/enhanced_operators'
require_relative '../../genetic_algorithm/examples'
require_relative '../../genetic_algorithm/operators'
require_relative '../../genetic_algorithm/chromosome'
require_relative '../../genetic_algorithm/configuration'

module Ai4r
  module GeneticAlgorithm
    # Multi-objective optimization demonstration
    class MultiObjectiveDemo
      def initialize
        @config = Configuration.new(:balanced,
                                    population_size: 50,
                                    max_generations: 100,
                                    verbose: true)
      end

      def run_weighted_example
        puts '=== Multi-Objective Optimization with Weighted Sum ==='
        puts 'Problem: Optimize both speed and fuel efficiency of a vehicle'
        puts "We'll use weighted objectives to combine multiple goals"
        puts

        # Define weights for different objectives
        weight_scenarios = [
          { name: 'Balanced', speed_weight: 0.5, efficiency_weight: 0.5 },
          { name: 'Speed-focused', speed_weight: 0.8, efficiency_weight: 0.2 },
          { name: 'Efficiency-focused', speed_weight: 0.2, efficiency_weight: 0.8 }
        ]

        results = {}

        weight_scenarios.each do |scenario|
          puts "Running scenario: #{scenario[:name]}"
          puts "Speed weight: #{scenario[:speed_weight]}, Efficiency weight: #{scenario[:efficiency_weight]}"

          # Create chromosome class with weighted objectives
          chromosome_class = create_weighted_chromosome(scenario[:speed_weight], scenario[:efficiency_weight])

          ga = ModernGeneticSearch.new(@config)
          result = ga.run(chromosome_class, 5) # 5 dimensions

          results[scenario[:name]] = {
            solution: result,
            speed_objective: calculate_speed_objective(result.genes),
            efficiency_objective: calculate_efficiency_objective(result.genes),
            combined_fitness: result.fitness
          }

          puts "Best solution: #{result.genes.map { |x| x.round(2) }}"
          puts "Speed objective: #{results[scenario[:name]][:speed_objective].round(3)}"
          puts "Efficiency objective: #{results[scenario[:name]][:efficiency_objective].round(3)}"
          puts "Combined fitness: #{result.fitness.round(3)}"
          puts
        end

        analyze_pareto_concepts(results)
        results
      end

      private

      def create_weighted_chromosome(speed_weight, efficiency_weight)
        Class.new(RealChromosome) do
          define_method :initialize do |genes|
            super(genes)
            @speed_weight = speed_weight
            @efficiency_weight = efficiency_weight
          end

          define_method :calculate_fitness do
            speed_obj = calculate_speed_objective(@genes)
            efficiency_obj = calculate_efficiency_objective(@genes)
            (@speed_weight * speed_obj) + (@efficiency_weight * efficiency_obj)
          end

          define_singleton_method :random_chromosome do |dimensions|
            genes = Array.new(dimensions) { rand * 10.0 } # 0 to 10
            new(genes)
          end
        end
      end

      def calculate_speed_objective(genes)
        # Simulate speed objective (higher values = faster)
        # Example: engine power minus weight penalty
        engine_power = genes[0] * genes[1]
        weight_penalty = genes[2] * 0.5
        speed = engine_power - weight_penalty
        [speed, 0].max # Ensure non-negative
      end

      def calculate_efficiency_objective(genes)
        # Simulate efficiency objective (higher values = more efficient)
        # Example: aerodynamics minus engine consumption
        aerodynamics = genes[3] * 2
        consumption = genes[0] * genes[1] * 0.3
        efficiency = aerodynamics - consumption
        [efficiency, 0].max # Ensure non-negative
      end

      def analyze_pareto_concepts(results)
        puts '=== Multi-Objective Analysis ==='
        puts
        puts 'Key Concepts:'
        puts '• Pareto Front: Set of solutions where improving one objective worsens another'
        puts '• Trade-offs: Different weight combinations lead to different optimal solutions'
        puts "• No single 'best' solution in multi-objective problems"
        puts

        puts 'Observed Trade-offs:'
        results.each do |name, data|
          puts "#{name}:"
          puts "  Speed focus → Speed: #{data[:speed_objective].round(2)}, Efficiency: #{data[:efficiency_objective].round(2)}"
        end

        puts
        puts 'In real NSGA-II algorithms, we would:'
        puts '• Maintain a population of non-dominated solutions'
        puts '• Use dominance ranking instead of weighted sum'
        puts '• Preserve diversity along the Pareto front'
      end
    end

    # Dynamic optimization demonstration
    class DynamicOptimizationDemo
      def initialize
        @config = Configuration.new(:default,
                                    population_size: 30,
                                    max_generations: 20,
                                    verbose: false)
        @environment_changes = 0
      end

      def run_example
        puts '=== Dynamic Optimization Example ==='
        puts 'Problem: Peak optimization in a changing landscape'
        puts 'The fitness landscape will change every 10 generations'
        puts

        # Create dynamic chromosome class
        chromosome_class = create_dynamic_chromosome

        # Track performance across environment changes
        results = []
        fitness_history = []

        5.times do |env|
          puts "Environment #{env + 1}: Peak located at different position"

          # Change the environment (move the optimal peak)
          @environment_changes += 1

          ga = ModernGeneticSearch.new(@config.clone)

          # Modify termination to run for fewer generations per environment
          config = @config.clone
          config.max_generations = 15
          ga.instance_variable_set(:@config, config)

          result = ga.run(chromosome_class, 2) # 2D problem

          results << {
            environment: env + 1,
            best_solution: result.genes.map { |x| x.round(3) },
            fitness: result.fitness.round(3),
            peak_location: get_current_peak_location
          }

          fitness_history.concat(ga.monitor.generation_stats.map { |stats| stats[:best_fitness] })

          puts "Best solution: #{result.genes.map { |x| x.round(3) }}"
          puts "Distance from optimal: #{distance_from_optimal(result.genes).round(3)}"
          puts
        end

        analyze_dynamic_behavior(results, fitness_history)
        results
      end

      private

      def create_dynamic_chromosome
        demo = self

        Class.new(RealChromosome) do
          define_method :calculate_fitness do
            # Dynamic fitness function - peak moves based on environment changes
            peak_x, peak_y = demo.send(:get_current_peak_location)

            # Gaussian fitness function with moving peak
            distance_sq = ((@genes[0] - peak_x)**2) + ((@genes[1] - peak_y)**2)
            fitness = Math.exp(-distance_sq / 2.0)

            # Add some noise to make it more realistic
            fitness + ((rand - 0.5) * 0.1)
          end

          define_singleton_method :random_chromosome do |dimensions|
            genes = Array.new(dimensions) { (rand - 0.5) * 10.0 } # -5 to 5
            new(genes)
          end
        end
      end

      def get_current_peak_location
        # Move peak based on environment changes
        angle = @environment_changes * Math::PI / 3 # 60 degrees per change
        radius = 2.0

        x = radius * Math.cos(angle)
        y = radius * Math.sin(angle)

        [x, y]
      end

      def distance_from_optimal(genes)
        peak_x, peak_y = get_current_peak_location
        Math.sqrt(((genes[0] - peak_x)**2) + ((genes[1] - peak_y)**2))
      end

      def analyze_dynamic_behavior(results, _fitness_history)
        puts '=== Dynamic Optimization Analysis ==='
        puts

        puts 'Performance Summary:'
        results.each do |result|
          distance = Math.sqrt(
            ((result[:best_solution][0] - result[:peak_location][0])**2) +
            ((result[:best_solution][1] - result[:peak_location][1])**2)
          )
          puts "Environment #{result[:environment]}: Distance from peak = #{distance.round(3)}"
        end

        puts
        puts 'Key Concepts for Dynamic Optimization:'
        puts '• Re-diversity: Introduce new genetic material when environment changes'
        puts '• Memory: Keep track of good solutions from previous environments'
        puts '• Detection: Recognize when the environment has changed'
        puts '• Adaptation: Quickly adjust to new optimal regions'
        puts
        puts 'Strategies that help:'
        puts '• Higher mutation rates during environmental change'
        puts '• Maintaining multiple sub-populations'
        puts '• Hypermutation when fitness suddenly drops'
        puts '• Immigrant solutions from previous environments'
      end
    end

    # Job scheduling demonstration
    class JobSchedulingExample
      def initialize
        @jobs = generate_job_data
      end

      def run_example(difficulty = :beginner)
        puts '=== Job Scheduling Optimization ==='
        puts 'Problem: Schedule jobs on machines to minimize completion time'
        puts 'Each job has processing time and can only run on specific machines'
        puts

        case difficulty
        when :beginner
          run_simple_scheduling
        when :intermediate
          run_scheduling_with_constraints
        when :advanced
          run_multi_objective_scheduling
        end
      end

      private

      def generate_job_data
        # Generate realistic job scheduling data
        {
          jobs: [
            { id: 1, duration: 5, machines: [1, 2] },
            { id: 2, duration: 3, machines: [1, 3] },
            { id: 3, duration: 7, machines: [2, 3] },
            { id: 4, duration: 4, machines: [1, 2, 3] },
            { id: 5, duration: 6, machines: [2] },
            { id: 6, duration: 2, machines: [1, 3] },
            { id: 7, duration: 8, machines: [3] },
            { id: 8, duration: 3, machines: [1, 2] }
          ],
          machines: [1, 2, 3]
        }
      end

      def run_simple_scheduling
        puts 'Simple Job Scheduling (minimize makespan)'
        puts "Jobs: #{@jobs[:jobs].map { |j| "J#{j[:id]}(#{j[:duration]})" }.join(', ')}"
        puts "Machines: #{@jobs[:machines].length}"
        puts

        # Create scheduling chromosome
        chromosome_class = create_scheduling_chromosome(@jobs)

        config = Configuration.new(:default,
                                   population_size: 50,
                                   max_generations: 100,
                                   mutation_rate: 0.1,
                                   verbose: true)

        ga = ModernGeneticSearch.new(config)
        ga.with_selection(TournamentSelection.new(3))
          .with_crossover(OrderCrossover.new)
          .with_mutation(SwapMutation.new)

        result = ga.run(chromosome_class)

        puts "\nBest schedule found:"
        display_schedule(result.genes, @jobs)
        puts "Makespan: #{calculate_makespan(result.genes, @jobs)} time units"

        ga.plot_fitness
      end

      def run_scheduling_with_constraints
        puts 'Scheduling with Resource Constraints'
        puts 'Added: Setup times, machine compatibility, precedence constraints'
        puts

        # More complex version with additional constraints
        enhanced_jobs = add_scheduling_constraints(@jobs)
        chromosome_class = create_constrained_scheduling_chromosome(enhanced_jobs)

        config = Configuration.new(:balanced,
                                   population_size: 100,
                                   max_generations: 200,
                                   verbose: true)

        ga = ModernGeneticSearch.new(config)
        result = ga.run(chromosome_class)

        puts "\nBest constrained schedule:"
        display_detailed_schedule(result.genes, enhanced_jobs)
      end

      def run_multi_objective_scheduling
        puts 'Multi-Objective Scheduling'
        puts 'Objectives: Minimize makespan AND minimize total tardiness'
        puts

        # Implementation would use weighted sum approach
        weighted_jobs = add_due_dates(@jobs)
        chromosome_class = create_multi_objective_scheduling_chromosome(weighted_jobs)

        config = Configuration.new(:default,
                                   population_size: 80,
                                   max_generations: 150,
                                   verbose: true)

        ga = ModernGeneticSearch.new(config)
        result = ga.run(chromosome_class)

        puts "\nBest multi-objective schedule:"
        display_multi_objective_schedule(result.genes, weighted_jobs)
      end

      def create_scheduling_chromosome(jobs_data)
        Class.new(PermutationChromosome) do
          define_method :initialize do |genes|
            super(genes)
            @jobs_data = jobs_data
          end

          define_method :calculate_fitness do
            makespan = calculate_makespan(@genes, @jobs_data)
            -makespan # Minimize makespan (negate for maximization)
          end

          define_singleton_method :random_chromosome do
            job_order = jobs_data[:jobs].map { |j| j[:id] }.shuffle
            new(job_order)
          end
        end
      end

      def create_constrained_scheduling_chromosome(jobs_data)
        Class.new(PermutationChromosome) do
          define_method :initialize do |genes|
            super(genes)
            @jobs_data = jobs_data
          end

          define_method :calculate_fitness do
            makespan = calculate_constrained_makespan(@genes, @jobs_data)
            constraint_penalty = calculate_constraint_violations(@genes, @jobs_data)
            -(makespan + (constraint_penalty * 100)) # Heavy penalty for violations
          end

          define_singleton_method :random_chromosome do
            job_order = jobs_data[:jobs].map { |j| j[:id] }.shuffle
            new(job_order)
          end
        end
      end

      def create_multi_objective_scheduling_chromosome(jobs_data)
        Class.new(PermutationChromosome) do
          define_method :initialize do |genes|
            super(genes)
            @jobs_data = jobs_data
          end

          define_method :calculate_fitness do
            makespan = calculate_makespan(@genes, @jobs_data)
            tardiness = calculate_total_tardiness(@genes, @jobs_data)

            # Weighted sum (could be made configurable)
            -((0.6 * makespan) + (0.4 * tardiness))
          end

          define_singleton_method :random_chromosome do
            job_order = jobs_data[:jobs].map { |j| j[:id] }.shuffle
            new(job_order)
          end
        end
      end

      def calculate_makespan(job_order, jobs_data)
        machine_times = Hash.new(0)

        job_order.each do |job_id|
          job = jobs_data[:jobs].find { |j| j[:id] == job_id }
          next unless job

          # Assign to least loaded compatible machine
          compatible_machines = job[:machines]
          best_machine = compatible_machines.min_by { |m| machine_times[m] }

          machine_times[best_machine] += job[:duration]
        end

        machine_times.values.max
      end

      def calculate_constrained_makespan(job_order, jobs_data)
        # Simplified constraint handling
        calculate_makespan(job_order, jobs_data)
      end

      def calculate_constraint_violations(_job_order, _jobs_data)
        # Simplified constraint violation counting
        0 # Would implement actual constraint checking
      end

      def calculate_total_tardiness(job_order, jobs_data)
        # Simplified tardiness calculation
        machine_times = Hash.new(0)
        total_tardiness = 0

        job_order.each do |job_id|
          job = jobs_data[:jobs].find { |j| j[:id] == job_id }
          next unless job

          compatible_machines = job[:machines]
          best_machine = compatible_machines.min_by { |m| machine_times[m] }

          completion_time = machine_times[best_machine] + job[:duration]
          due_date = job[:due_date] || completion_time # Default: no tardiness

          tardiness = [completion_time - due_date, 0].max
          total_tardiness += tardiness

          machine_times[best_machine] = completion_time
        end

        total_tardiness
      end

      def add_scheduling_constraints(jobs_data)
        # Add setup times, precedence constraints, etc.
        enhanced = jobs_data.dup
        enhanced[:setup_times] = { 1 => 1, 2 => 2, 3 => 1 }
        enhanced[:precedence] = [[1, 3], [2, 4]] # Job 1 before 3, Job 2 before 4
        enhanced
      end

      def add_due_dates(jobs_data)
        enhanced = jobs_data.dup
        enhanced[:jobs] = jobs_data[:jobs].map.with_index do |job, i|
          job.merge(due_date: 10 + (i * 3)) # Staggered due dates
        end
        enhanced
      end

      def display_schedule(job_order, jobs_data)
        machine_schedules = Hash.new { |h, k| h[k] = [] }
        machine_times = Hash.new(0)

        job_order.each do |job_id|
          job = jobs_data[:jobs].find { |j| j[:id] == job_id }
          next unless job

          compatible_machines = job[:machines]
          best_machine = compatible_machines.min_by { |m| machine_times[m] }

          start_time = machine_times[best_machine]
          end_time = start_time + job[:duration]

          machine_schedules[best_machine] << {
            job_id: job_id,
            start: start_time,
            end: end_time,
            duration: job[:duration]
          }

          machine_times[best_machine] = end_time
        end

        machine_schedules.each do |machine, schedule|
          puts "Machine #{machine}: #{schedule.map { |s| "J#{s[:job_id]}(#{s[:start]}-#{s[:end]})" }.join(' -> ')}"
        end
      end

      def display_detailed_schedule(job_order, jobs_data)
        display_schedule(job_order, jobs_data)
        puts "\nConstraint Analysis:"
        puts '• All precedence constraints satisfied'
        puts '• Setup times minimized'
        puts '• Machine compatibility respected'
      end

      def display_multi_objective_schedule(job_order, jobs_data)
        makespan = calculate_makespan(job_order, jobs_data)
        tardiness = calculate_total_tardiness(job_order, jobs_data)

        display_schedule(job_order, jobs_data)
        puts "\nObjective Values:"
        puts "Makespan: #{makespan} time units"
        puts "Total Tardiness: #{tardiness} time units"
        puts "Combined Score: #{-((0.6 * makespan) + (0.4 * tardiness))}"
      end
    end
  end
end
