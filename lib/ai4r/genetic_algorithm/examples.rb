# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative 'modern_genetic_search'

module Ai4r
  module GeneticAlgorithm
    module Examples
      # OneMax Problem - Classic binary optimization
      class OneMaxChromosome < BinaryChromosome
        def self.random_chromosome(length = 50)
          super
        end

        def calculate_fitness
          # Fitness is simply the number of 1s
          @genes.sum.to_f
        end

        def to_s
          "OneMax(#{@genes.join}) = #{fitness}"
        end
      end

      # Knapsack Problem - Binary optimization with constraints
      class KnapsackChromosome < BinaryChromosome
        def initialize(genes, weights, values, capacity)
          super(genes)
          @weights = weights
          @values = values
          @capacity = capacity
        end

        def self.random_chromosome(length, weights, values, capacity)
          genes = Array.new(length) { rand(2) }
          new(genes, weights, values, capacity)
        end

        def calculate_fitness
          total_weight = 0
          total_value = 0

          @genes.each_with_index do |gene, index|
            if gene == 1
              total_weight += @weights[index]
              total_value += @values[index]
            end
          end

          # Penalty for exceeding capacity
          if total_weight > @capacity
            penalty = (total_weight - @capacity) * 10
            total_value - penalty
          else
            total_value.to_f
          end
        end

        def to_s
          weight = @genes.zip(@weights).sum { |gene, w| gene * w }
          value = @genes.zip(@values).sum { |gene, v| gene * v }
          "Knapsack(weight: #{weight}/#{@capacity}, value: #{value})"
        end
      end

      # Sphere Function - Continuous optimization
      class SphereChromosome < RealChromosome
        def self.random_chromosome(dimensions = 10, min_val = -5.0, max_val = 5.0)
          super
        end

        def calculate_fitness
          # Sphere function: minimize sum of squares
          # Higher fitness = better, so we negate the sum
          -@genes.sum { |x| x * x }
        end

        def to_s
          "Sphere(#{@genes.map { |x| x.round(3) }.join(', ')}) = #{fitness.round(3)}"
        end
      end

      # Rastrigin Function - Multimodal optimization
      class RastriginChromosome < RealChromosome
        def self.random_chromosome(dimensions = 10, min_val = -5.12, max_val = 5.12)
          super
        end

        def calculate_fitness
          # Rastrigin function: minimize sum(x^2 - 10*cos(2*π*x) + 10)
          n = @genes.length
          sum = @genes.sum { |x| (x * x) - (10 * Math.cos(2 * Math::PI * x)) + 10 }
          -((10 * n) + sum) # Negate for maximization
        end

        def to_s
          "Rastrigin(#{@genes.map { |x| x.round(3) }.join(', ')}) = #{fitness.round(3)}"
        end
      end

      # N-Queens Problem - Constraint satisfaction
      class NQueensChromosome < PermutationChromosome
        def self.random_chromosome(n = 8)
          genes = (0...n).to_a.shuffle
          new(genes)
        end

        def calculate_fitness
          n = @genes.length
          conflicts = 0

          (0...n).each do |i|
            ((i + 1)...n).each do |j|
              # Check diagonal conflicts
              conflicts += 1 if (@genes[i] - @genes[j]).abs == (i - j).abs
            end
          end

          # Higher fitness = fewer conflicts
          ((n * (n - 1)) / 2) - conflicts
        end

        def to_s
          "NQueens(#{@genes.join(',')}) conflicts: #{((length * (length - 1)) / 2) - fitness}"
        end
      end

      # Function Optimization Example
      class FunctionOptimizationChromosome < RealChromosome
        def initialize(genes, function)
          super(genes)
          @function = function
        end

        def self.random_chromosome(dimensions, min_val, max_val, function)
          genes = Array.new(dimensions) { (rand * (max_val - min_val)) + min_val }
          new(genes, function)
        end

        def calculate_fitness
          @function.call(@genes)
        end

        def to_s
          "Function(#{@genes.map { |x| x.round(3) }.join(', ')}) = #{fitness.round(3)}"
        end
      end

      # Educational runner methods
      class << self
        def run_onemax_example
          puts '=== OneMax Problem Example ==='
          puts 'Objective: Maximize the number of 1s in a binary string'
          puts

          config = Configuration.new(:default,
                                     population_size: 30,
                                     max_generations: 50,
                                     mutation_rate: 0.02,
                                     verbose: true)

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(TournamentSelection.new(3))
            .with_crossover(SinglePointCrossover.new)
            .with_mutation(BitFlipMutation.new)

          best = ga.run(OneMaxChromosome, 20)

          puts "\nBest solution found:"
          puts best
          puts "Optimal solution would be: #{best.genes.map { 1 }.join}"

          ga.plot_fitness
        end

        def run_knapsack_example
          puts '=== Knapsack Problem Example ==='
          puts 'Objective: Maximize value while staying within weight capacity'
          puts

          # Example knapsack data
          weights = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
          values = [60, 100, 120, 160, 200, 240, 280, 320, 360, 400]
          capacity = 250

          config = Configuration.new(:default,
                                     population_size: 50,
                                     max_generations: 100,
                                     mutation_rate: 0.05,
                                     verbose: true)

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(TournamentSelection.new(3))
            .with_crossover(UniformCrossover.new)
            .with_mutation(BitFlipMutation.new)

          best = ga.run(KnapsackChromosome, weights.length, weights, values, capacity)

          puts "\nBest solution found:"
          puts best

          ga.plot_fitness
        end

        def run_sphere_example
          puts '=== Sphere Function Example ==='
          puts 'Objective: Minimize sum of squares (find origin)'
          puts

          config = Configuration.new(:default,
                                     population_size: 50,
                                     max_generations: 100,
                                     mutation_rate: 0.1,
                                     verbose: true)

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(TournamentSelection.new(2))
            .with_crossover(UniformCrossover.new)
            .with_mutation(BitFlipMutation.new) # This will be overridden for real chromosomes

          best = ga.run(SphereChromosome, 5)

          puts "\nBest solution found:"
          puts best
          puts 'Optimal solution: [0.0, 0.0, 0.0, 0.0, 0.0]'

          ga.plot_fitness
        end

        def run_nqueens_example
          puts '=== N-Queens Problem Example ==='
          puts 'Objective: Place N queens on NxN chessboard with no conflicts'
          puts

          n = 8
          config = Configuration.new(:default,
                                     population_size: 100,
                                     max_generations: 500,
                                     mutation_rate: 0.02,
                                     verbose: true)

          ga = ModernGeneticSearch.new(config)
          ga.with_selection(TournamentSelection.new(3))
            .with_crossover(SinglePointCrossover.new)
            .with_mutation(SwapMutation.new)

          best = ga.run(NQueensChromosome, n)

          puts "\nBest solution found:"
          puts best

          if best.fitness == (n * (n - 1)) / 2
            puts 'Perfect solution found! No conflicts.'
            print_chess_board(best.genes)
          else
            puts "Solution has #{((n * (n - 1)) / 2) - best.fitness} conflicts."
          end

          ga.plot_fitness
        end

        def run_custom_function_example
          puts '=== Custom Function Optimization Example ==='
          puts 'Objective: Find minimum of custom function'
          puts

          # Define a custom function to optimize
          custom_function = ->(x) do
            # Example: minimize x^2 + y^2 + sin(x) + cos(y)
            return 0 if x.length < 2

            -((x[0]**2) + (x[1]**2) + Math.sin(x[0]) + Math.cos(x[1]))
          end

          config = Configuration.new(:balanced,
                                     population_size: 30,
                                     max_generations: 100,
                                     verbose: true)

          ga = ModernGeneticSearch.new(config)

          best = ga.run(FunctionOptimizationChromosome, 2, -10, 10, custom_function)

          puts "\nBest solution found:"
          puts best

          ga.plot_fitness
        end

        def run_all_examples
          puts 'Running all genetic algorithm examples...'
          puts "\n#{'=' * 60}\n"

          run_onemax_example
          puts "\n#{'=' * 60}\n"

          run_knapsack_example
          puts "\n#{'=' * 60}\n"

          run_sphere_example
          puts "\n#{'=' * 60}\n"

          run_nqueens_example
          puts "\n#{'=' * 60}\n"

          run_custom_function_example

          puts "\nAll examples completed!"
        end

        private

        def print_chess_board(queens)
          n = queens.length
          puts "\nChessboard representation:"

          (0...n).each do |row|
            line = ''
            (0...n).each do |col|
              line += if queens[col] == row
                        'Q '
                      else
                        '. '
                      end
            end
            puts line
          end
        end
      end
    end
  end
end
