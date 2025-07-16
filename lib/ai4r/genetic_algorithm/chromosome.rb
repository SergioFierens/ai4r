# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module GeneticAlgorithm
    # Generic chromosome class for genetic algorithms
    # This class provides the foundation for all chromosome types
    class Chromosome
      attr_reader :genes
      attr_accessor :fitness

      def initialize(genes)
        @genes = genes.dup
        @fitness = nil
      end

      # Calculate fitness - to be implemented by subclasses
      def calculate_fitness
        raise NotImplementedError, 'Subclasses must implement calculate_fitness'
      end

      # Get fitness, calculating if necessary
      def fitness
        @fitness ||= calculate_fitness
      end

      # Force fitness recalculation
      def reset_fitness!
        @fitness = nil
      end

      # Create a deep copy of the chromosome
      def clone
        cloned = self.class.new(@genes.dup)
        cloned.fitness = @fitness
        cloned
      end

      # Compare chromosomes by fitness
      def <=>(other)
        fitness <=> other.fitness
      end

      # String representation for debugging
      def to_s
        "#{self.class.name}(genes: #{@genes.inspect}, fitness: #{fitness})"
      end

      # Create a random chromosome - to be implemented by subclasses
      def self.random_chromosome
        raise NotImplementedError, 'Subclasses must implement random_chromosome'
      end

      # Validate chromosome structure
      def valid?
        !@genes.nil? && !@genes.empty?
      end

      # Get chromosome length
      def length
        @genes.length
      end

      # Get gene at specific position
      def [](index)
        @genes[index]
      end

      # Set gene at specific position
      def []=(index, value)
        @genes[index] = value
        reset_fitness!
      end
    end

    # Binary chromosome for binary optimization problems
    class BinaryChromosome < Chromosome
      def initialize(genes)
        super
        validate_binary_genes
      end

      def self.random_chromosome(length)
        genes = Array.new(length) { rand(2) }
        new(genes)
      end

      # Example fitness function (OneMax problem)
      def calculate_fitness
        @genes.sum.to_f
      end

      # Flip a bit at given position
      def flip_bit(position)
        @genes[position] = @genes[position] == 0 ? 1 : 0
        reset_fitness!
      end

      # Count number of 1s
      def count_ones
        @genes.count(1)
      end

      # Count number of 0s
      def count_zeros
        @genes.count(0)
      end

      private

      def validate_binary_genes
        unless @genes.all? { |gene| [0, 1].include?(gene) }
          raise ArgumentError, 'Binary chromosome must contain only 0s and 1s'
        end
      end
    end

    # Permutation chromosome for problems like TSP
    class PermutationChromosome < Chromosome
      def initialize(genes)
        super
        validate_permutation
      end

      def self.random_chromosome(length)
        genes = (0...length).to_a.shuffle
        new(genes)
      end

      # Default fitness (to be overridden)
      def calculate_fitness
        # Placeholder - subclasses should implement problem-specific fitness
        rand
      end

      # Check if it's a valid permutation
      def valid_permutation?
        @genes.sort == (0...@genes.length).to_a
      end

      # Swap two elements
      def swap(i, j)
        @genes[i], @genes[j] = @genes[j], @genes[i]
        reset_fitness!
      end

      # Reverse a segment
      def reverse_segment(start, finish)
        @genes[start..finish] = @genes[start..finish].reverse
        reset_fitness!
      end

      private

      def validate_permutation
        raise ArgumentError, "Invalid permutation: #{@genes.inspect}" unless valid_permutation?
      end
    end

    # Real-valued chromosome for continuous optimization
    class RealChromosome < Chromosome
      attr_reader :min_value, :max_value

      def initialize(genes, min_value = -100, max_value = 100)
        @min_value = min_value
        @max_value = max_value
        super(genes)
        validate_bounds
      end

      def self.random_chromosome(length, min_value = -100, max_value = 100)
        genes = Array.new(length) { (rand * (max_value - min_value)) + min_value }
        new(genes, min_value, max_value)
      end

      # Default fitness (to be overridden)
      def calculate_fitness
        # Placeholder - subclasses should implement problem-specific fitness
        rand
      end

      # Add Gaussian noise to a gene
      def add_gaussian_noise(position, stddev = 1.0)
        noise = gaussian_random * stddev
        @genes[position] = clamp(@genes[position] + noise)
        reset_fitness!
      end

      # Uniform random mutation
      def uniform_mutation(position)
        @genes[position] = (rand * (@max_value - @min_value)) + @min_value
        reset_fitness!
      end

      private

      def validate_bounds
        @genes.each do |gene|
          unless gene.between?(@min_value, @max_value)
            raise ArgumentError, "Gene #{gene} out of bounds [#{@min_value}, #{@max_value}]"
          end
        end
      end

      def clamp(value)
        [[value, @min_value].max, @max_value].min
      end

      def gaussian_random
        # Box-Muller transform for Gaussian random numbers
        @spare ||= nil
        if @spare
          val = @spare
          @spare = nil
          return val
        end

        u1 = rand
        u2 = rand
        mag = Math.sqrt(-2.0 * Math.log(u1))
        @spare = mag * Math.cos(2.0 * Math::PI * u2)
        mag * Math.sin(2.0 * Math::PI * u2)
      end
    end

    # TSP-specific chromosome that extends PermutationChromosome
    class TSPChromosome < PermutationChromosome
      def initialize(genes, cost_matrix)
        super(genes)
        @cost_matrix = cost_matrix
      end

      def self.random_chromosome(length, cost_matrix)
        genes = (0...length).to_a.shuffle
        new(genes, cost_matrix)
      end

      def calculate_fitness
        return -Float::INFINITY if @cost_matrix.nil? || @genes.empty?

        total_cost = 0
        @genes.each_with_index do |city, index|
          next_city = @genes[(index + 1) % @genes.length]

          # Check if cost exists
          return -Float::INFINITY unless @cost_matrix[city] && @cost_matrix[city][next_city]

          total_cost += @cost_matrix[city][next_city]
        end

        # Return negative cost (higher fitness = lower cost)
        -total_cost
      end

      def total_distance
        -fitness
      end

      def to_s
        "TSP Route: #{@genes.inspect} (Distance: #{total_distance})"
      end
    end
  end
end
