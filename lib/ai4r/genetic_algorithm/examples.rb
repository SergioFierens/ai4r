# frozen_string_literal: true

# Genetic Algorithm Examples
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'chromosome'
require_relative 'modern_genetic_search'
require_relative 'configuration'

module Ai4r
  module GeneticAlgorithm
    # Collection of example problems for learning genetic algorithms
    module Examples
      # Example: OneMax problem - maximize the number of 1s in a binary string
      class OneMaxChromosome < Chromosome
        attr_reader :length

        def initialize(genes, length = 50)
          super(genes)
          @length = length
        end

        def fitness
          @fitness ||= @genes.count(1)
        end

        def self.random_chromosome(length = 50)
          genes = Array.new(length) { rand(2) }
          new(genes, length)
        end
      end

      # Example: Sphere function optimization
      class SphereChromosome < Chromosome
        attr_reader :bounds

        def initialize(genes, bounds = [-5.12, 5.12])
          super(genes)
          @bounds = bounds
        end

        def fitness
          @fitness ||= -@genes.sum { |x| x**2 }
        end

        def self.random_chromosome(dimensions = 3, bounds = [-5.12, 5.12])
          genes = Array.new(dimensions) { rand * (bounds[1] - bounds[0]) + bounds[0] }
          new(genes, bounds)
        end
      end

      # Example: Knapsack problem
      class KnapsackChromosome < Chromosome
        attr_reader :items, :capacity

        def initialize(genes, items, capacity)
          super(genes)
          @items = items
          @capacity = capacity
        end

        def fitness
          return @fitness if @fitness

          total_value = 0
          total_weight = 0

          @genes.each_with_index do |gene, i|
            next unless gene == 1

            total_value += @items[i][:value]
            total_weight += @items[i][:weight]
          end

          # Penalty for exceeding capacity
          @fitness = total_weight > @capacity ? -total_weight : total_value
        end

        def self.random_chromosome(items, capacity)
          genes = Array.new(items.length) { rand(2) }
          new(genes, items, capacity)
        end
      end

      # Example: Custom function with multiple local optima
      class CustomFunctionChromosome < Chromosome
        def fitness
          return @fitness if @fitness

          x, y = @genes[0], @genes[1]
          # Rastrigin function - has many local minima
          @fitness = -(20 + x**2 + y**2 - 10 * (Math.cos(2 * Math::PI * x) + Math.cos(2 * Math::PI * y)))
        end

        def self.random_chromosome
          genes = Array.new(2) { rand * 10 - 5 }
          new(genes)
        end
      end

      # Run OneMax example
      def self.run_onemax_example
        puts '=== OneMax Problem ==='
        puts 'Goal: Maximize the number of 1s in a binary string'
        puts

        config = Configuration.new(
          population_size: 50,
          max_generations: 100,
          mutation_rate: 0.02,
          crossover_rate: 0.7,
          verbose: true
        )

        ga = ModernGeneticSearch.new(config)
        result = ga.run(OneMaxChromosome, 50)

        puts "\nBest solution: #{result.genes}"
        puts "Fitness (1s count): #{result.fitness}"
        puts "Percentage of 1s: #{(result.fitness / 50.0 * 100).round(1)}%"
      end

      # Run Sphere function example
      def self.run_sphere_example
        puts '=== Sphere Function Optimization ==='
        puts 'Goal: Find x values that minimize sum(x^2)'
        puts

        config = Configuration.new(
          population_size: 30,
          max_generations: 100,
          mutation_rate: 0.1,
          crossover_rate: 0.8,
          verbose: true
        )

        ga = ModernGeneticSearch.new(config)
        result = ga.run(SphereChromosome, 3)

        puts "\nBest solution: #{result.genes.map { |g| g.round(4) }}"
        puts "Fitness: #{result.fitness.round(6)}"
        puts "Distance from optimum: #{Math.sqrt(result.genes.sum { |x| x**2 }).round(6)}"
      end

      # Run Knapsack example
      def self.run_knapsack_example
        puts '=== Knapsack Problem ==='
        puts 'Goal: Select items to maximize value while staying within weight capacity'
        puts

        # Define items with weight and value
        items = [
          { weight: 10, value: 60 },
          { weight: 20, value: 100 },
          { weight: 30, value: 120 },
          { weight: 15, value: 50 },
          { weight: 25, value: 90 },
          { weight: 5, value: 30 }
        ]
        capacity = 50

        config = Configuration.new(
          population_size: 40,
          max_generations: 50,
          mutation_rate: 0.05,
          crossover_rate: 0.8,
          verbose: true
        )

        ga = ModernGeneticSearch.new(config)
        result = ga.run(KnapsackChromosome, items, capacity)

        puts "\nBest solution:"
        total_weight = 0
        total_value = 0
        result.genes.each_with_index do |gene, i|
          next unless gene == 1

          puts "  Item #{i}: weight=#{items[i][:weight]}, value=#{items[i][:value]}"
          total_weight += items[i][:weight]
          total_value += items[i][:value]
        end
        puts "Total weight: #{total_weight}/#{capacity}"
        puts "Total value: #{total_value}"
      end

      # Run custom function example
      def self.run_custom_function_example
        puts '=== Custom Function Optimization ==='
        puts 'Goal: Find global minimum of Rastrigin function'
        puts

        config = Configuration.new(
          population_size: 100,
          max_generations: 200,
          mutation_rate: 0.1,
          crossover_rate: 0.9,
          verbose: true
        )

        ga = ModernGeneticSearch.new(config)
        result = ga.run(CustomFunctionChromosome)

        puts "\nBest solution: x=#{result.genes[0].round(4)}, y=#{result.genes[1].round(4)}"
        puts "Fitness: #{result.fitness.round(6)}"
        puts "Global optimum is at (0, 0) with fitness 0"
      end
    end

    # Demo classes referenced in educational_genetic_search.rb
    class MultiObjectiveDemo
      def run_weighted_example
        puts 'Demonstrating weighted multi-objective optimization...'
        puts 'Objective 1: Maximize speed'
        puts 'Objective 2: Minimize cost'
        puts 'Using weighted sum: fitness = w1*speed - w2*cost'
        puts
        puts 'This is a simplified approach. For true multi-objective optimization,'
        puts 'consider algorithms like NSGA-II that maintain a Pareto front.'
      end
    end

    class DynamicOptimizationDemo
      def run_example
        puts 'In dynamic optimization, the fitness landscape changes over time.'
        puts 'GAs can adapt by:'
        puts '• Maintaining diversity to explore new optima'
        puts '• Using memory to recall previous good solutions'
        puts '• Detecting changes and reinitializing parts of the population'
        puts '• Using predictive models to anticipate changes'
      end
    end

    class JobSchedulingExample
      def run_example(difficulty)
        case difficulty
        when :beginner
          puts 'Simple job scheduling: assign jobs to minimize completion time'
        when :intermediate
          puts 'Job scheduling with dependencies and resource constraints'
        when :advanced
          puts 'Multi-objective scheduling: minimize time, cost, and resource usage'
        end
        puts 'Chromosome representation: permutation of job IDs'
        puts 'Fitness: negative total completion time (or weighted objectives)'
      end
    end
  end
end