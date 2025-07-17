# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative 'operators'
require_relative 'chromosome'
require_relative 'configuration'
require_relative '../utilities/monitoring/evolution_monitor'

module Ai4r
  module GeneticAlgorithm
    # Modern, educational genetic algorithm implementation
    # This class provides a clean, modular interface for learning and experimentation
    class ModernGeneticSearch
      attr_reader :config, :population, :generation, :monitor
      attr_accessor :selection_operator, :crossover_operator, :mutation_operator, :replacement_operator

      def initialize(config = Configuration.new)
        @config = config
        @population = []
        @generation = 0
        @monitor = EvolutionMonitor.new

        # Default operators (can be changed)
        @selection_operator = TournamentSelection.new(@config.selection_pressure)
        @crossover_operator = SinglePointCrossover.new
        @mutation_operator = SwapMutation.new
        @replacement_operator = ElitistReplacement.new(@config.elitism_rate)

        @start_time = nil
        @best_individual = nil
      end

      # Run the genetic algorithm
      def run(chromosome_class, *args)
        validate_chromosome_class(chromosome_class)

        puts 'Starting Genetic Algorithm...' if @config.verbose
        puts @config if @config.verbose

        @monitor.start
        @start_time = Time.now

        # Initialize population
        initialize_population(chromosome_class, *args)

        # Evolution loop
        until termination_criteria_met?
          evolve_generation

          # Record statistics
          @monitor.record_generation(@generation, @population)

          # Print progress
          if @config.verbose
            current_stats = @monitor.generation_stats.last
            @monitor.print_generation_stats(current_stats)
          end

          # Check for early termination
          break if early_termination_check

          @generation += 1
        end

        @monitor.finish

        # Final results
        @best_individual = @population.max_by(&:fitness)

        puts "\nEvolution completed!" if @config.verbose
        puts @monitor.summary if @config.verbose

        @best_individual
      end

      # Run with step-by-step execution (for educational purposes)
      def run_step_by_step(chromosome_class, *args)
        validate_chromosome_class(chromosome_class)

        puts '=== Step-by-Step Genetic Algorithm Execution ==='
        puts 'Press Enter to continue through each step...'

        @monitor.start
        @start_time = Time.now

        # Step 1: Initialize population
        puts "\nStep 1: Initializing population..."
        initialize_population(chromosome_class, *args)
        puts "Created #{@population.size} random individuals"
        puts "Best fitness: #{@population.max_by(&:fitness).fitness}"
        gets

        # Evolution loop with user interaction
        until termination_criteria_met?
          puts "\n#{'=' * 50}"
          puts "Generation #{@generation + 1}"
          puts '=' * 50

          # Step 2: Selection
          puts "\nStep 2: Selection (#{@selection_operator.name})"
          puts @selection_operator.description
          parent_count = (@config.population_size * @config.crossover_rate).round
          parents = @selection_operator.select(@population, parent_count)
          puts "Selected #{parents.size} parents for reproduction"
          gets

          # Step 3: Crossover
          puts "\nStep 3: Crossover (#{@crossover_operator.name})"
          puts @crossover_operator.description
          offspring = []
          parents.each_slice(2) do |parent1, parent2|
            next unless parent2

            if rand < @config.crossover_rate
              children = @crossover_operator.crossover(parent1, parent2)
              offspring.concat(children)
            else
              offspring.push(parent1.clone, parent2.clone)
            end
          end
          puts "Created #{offspring.size} offspring through crossover"
          gets

          # Step 4: Mutation
          puts "\nStep 4: Mutation (#{@mutation_operator.name})"
          puts @mutation_operator.description
          mutated_count = 0
          offspring.each do |individual|
            original_fitness = individual.fitness
            mutated = @mutation_operator.mutate(individual, @config.mutation_rate)
            mutated_count += 1 if mutated.fitness != original_fitness
          end
          puts "Mutated #{mutated_count} individuals"
          gets

          # Step 5: Replacement
          puts "\nStep 5: Replacement (#{@replacement_operator.name})"
          puts @replacement_operator.description
          old_best = @population.max_by(&:fitness).fitness
          @population = @replacement_operator.replace(@population, offspring)
          new_best = @population.max_by(&:fitness).fitness
          puts "New population created. Best fitness: #{new_best} (was #{old_best})"

          # Record statistics
          @monitor.record_generation(@generation, @population)

          gets
          @generation += 1
        end

        @monitor.finish
        @best_individual = @population.max_by(&:fitness)

        puts "\n=== Evolution Complete ==="
        puts @monitor.summary

        @best_individual
      end

      # Get current best individual
      def best_individual
        @best_individual || @population.max_by(&:fitness)
      end

      # Get population statistics
      def population_statistics
        return {} if @population.empty?

        fitnesses = @population.map(&:fitness)
        {
          size: @population.size,
          best_fitness: fitnesses.max,
          worst_fitness: fitnesses.min,
          average_fitness: fitnesses.sum / fitnesses.size.to_f,
          fitness_std: @monitor.send(:standard_deviation, fitnesses)
        }
      end

      # Export evolution data
      def export_data(filename)
        @monitor.export_csv(filename)
      end

      # Plot fitness evolution in terminal
      def plot_fitness
        @monitor.plot_fitness_evolution
      end

      # Set operators using method chaining
      def with_selection(operator)
        @selection_operator = operator
        self
      end

      def with_crossover(operator)
        @crossover_operator = operator
        self
      end

      def with_mutation(operator)
        @mutation_operator = operator
        self
      end

      def with_replacement(operator)
        @replacement_operator = operator
        self
      end

      private

      def validate_chromosome_class(chromosome_class)
        raise ArgumentError, 'Chromosome class must inherit from Chromosome' unless chromosome_class < Chromosome

        unless chromosome_class.respond_to?(:random_chromosome)
          raise ArgumentError, 'Chromosome class must implement random_chromosome class method'
        end
      end

      def initialize_population(chromosome_class, *args)
        @population = Array.new(@config.population_size) do
          chromosome_class.random_chromosome(*args)
        end

        # Ensure all chromosomes have calculated fitness
        @population.each(&:fitness)
      end

      def evolve_generation
        # Selection
        parent_count = (@config.population_size * @config.crossover_rate).round
        parents = @selection_operator.select(@population, parent_count)

        # Crossover
        offspring = []
        parents.each_slice(2) do |parent1, parent2|
          next unless parent2

          if rand < @config.crossover_rate
            children = @crossover_operator.crossover(parent1, parent2)
            offspring.concat(children)
          else
            offspring.push(parent1.clone, parent2.clone)
          end
        end

        # Mutation
        offspring.map! do |individual|
          @mutation_operator.mutate(individual, @config.mutation_rate)
        end

        # Replacement
        @population = @replacement_operator.replace(@population, offspring)
      end

      def termination_criteria_met?
        # Max generations reached
        return true if @generation >= @config.max_generations

        # Time limit reached
        return true if @config.time_limit && @start_time && (Time.now - @start_time > @config.time_limit)

        # Fitness goal reached
        if @config.fitness_goal && !@population.empty? && (@population.max_by(&:fitness).fitness >= @config.fitness_goal)
          return true
        end

        false
      end

      def early_termination_check
        # Check convergence
        if @monitor.generation_stats.size >= @config.convergence_generations
          return @monitor.converged?(@config.convergence_generations, @config.convergence_threshold)
        end

        false
      end
    end
  end
end
