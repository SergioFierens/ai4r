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
    
    # Base class for all genetic algorithm operators
    # This provides a common interface for educational purposes
    class Operator
      attr_reader :name, :description
      
      def initialize(name, description = "")
        @name = name
        @description = description
      end
      
      def to_s
        "#{@name}: #{@description}"
      end
    end
    
    # Selection operators choose parents for reproduction
    class SelectionOperator < Operator
      # Selects count individuals from population
      # Returns array of selected chromosomes
      def select(population, count)
        raise NotImplementedError, "Subclasses must implement select method"
      end
    end
    
    # Crossover operators combine parents to create offspring
    class CrossoverOperator < Operator
      # Combines two parents to create offspring
      # Returns array of offspring chromosomes
      def crossover(parent1, parent2)
        raise NotImplementedError, "Subclasses must implement crossover method"
      end
    end
    
    # Mutation operators introduce random changes
    class MutationOperator < Operator
      # Mutates a chromosome with given probability
      # Returns the mutated chromosome
      def mutate(chromosome, probability)
        raise NotImplementedError, "Subclasses must implement mutate method"
      end
    end
    
    # Replacement operators determine which individuals survive
    class ReplacementOperator < Operator
      # Determines which individuals survive to next generation
      # Returns the new population
      def replace(population, offspring)
        raise NotImplementedError, "Subclasses must implement replace method"
      end
    end
    
    # Fitness Proportionate Selection (Roulette Wheel)
    class FitnessProportionateSelection < SelectionOperator
      def initialize
        super("Fitness Proportionate Selection", 
              "Selects individuals with probability proportional to their fitness")
      end
      
      def select(population, count)
        return [] if population.empty?
        
        # Calculate total fitness
        total_fitness = population.sum(&:fitness)
        return population.sample(count) if total_fitness <= 0
        
        selected = []
        count.times do
          target = rand * total_fitness
          accumulated = 0
          
          population.each do |individual|
            accumulated += individual.fitness
            if accumulated >= target
              selected << individual
              break
            end
          end
        end
        
        selected
      end
    end
    
    # Tournament Selection - good for educational purposes
    class TournamentSelection < SelectionOperator
      attr_reader :tournament_size
      
      def initialize(tournament_size = 3)
        @tournament_size = tournament_size
        super("Tournament Selection", 
              "Selects best individual from random tournament of size #{tournament_size}")
      end
      
      def select(population, count)
        return [] if population.empty?
        
        selected = []
        count.times do
          tournament = population.sample(@tournament_size)
          winner = tournament.max_by(&:fitness)
          selected << winner
        end
        
        selected
      end
    end
    
    # Uniform Crossover - good for binary representations
    class UniformCrossover < CrossoverOperator
      attr_reader :crossover_rate
      
      def initialize(crossover_rate = 0.5)
        @crossover_rate = crossover_rate
        super("Uniform Crossover", 
              "Each gene has #{crossover_rate} probability of coming from each parent")
      end
      
      def crossover(parent1, parent2)
        return [parent1.clone, parent2.clone] if parent1.genes.length != parent2.genes.length
        
        child1_genes = []
        child2_genes = []
        
        parent1.genes.each_with_index do |gene, index|
          if rand < @crossover_rate
            child1_genes << gene
            child2_genes << parent2.genes[index]
          else
            child1_genes << parent2.genes[index]
            child2_genes << gene
          end
        end
        
        [
          parent1.class.new(child1_genes),
          parent2.class.new(child2_genes)
        ]
      end
    end
    
    # Single Point Crossover - classic operator
    class SinglePointCrossover < CrossoverOperator
      def initialize
        super("Single Point Crossover", 
              "Swaps genetic material at a random cut point")
      end
      
      def crossover(parent1, parent2)
        return [parent1.clone, parent2.clone] if parent1.genes.length <= 1
        
        cut_point = rand(1...parent1.genes.length)
        
        child1_genes = parent1.genes[0...cut_point] + parent2.genes[cut_point..-1]
        child2_genes = parent2.genes[0...cut_point] + parent1.genes[cut_point..-1]
        
        [
          parent1.class.new(child1_genes),
          parent2.class.new(child2_genes)
        ]
      end
    end
    
    # Bit Flip Mutation - for binary strings
    class BitFlipMutation < MutationOperator
      def initialize
        super("Bit Flip Mutation", 
              "Flips each bit with given probability")
      end
      
      def mutate(chromosome, probability)
        new_genes = chromosome.genes.map do |gene|
          rand < probability ? (gene == 0 ? 1 : 0) : gene
        end
        
        chromosome.class.new(new_genes)
      end
    end
    
    # Swap Mutation - for permutation problems
    class SwapMutation < MutationOperator
      def initialize
        super("Swap Mutation", 
              "Swaps two random elements in the chromosome")
      end
      
      def mutate(chromosome, probability)
        return chromosome if rand >= probability || chromosome.genes.length <= 1
        
        new_genes = chromosome.genes.dup
        i = rand(new_genes.length)
        j = rand(new_genes.length)
        new_genes[i], new_genes[j] = new_genes[j], new_genes[i]
        
        chromosome.class.new(new_genes)
      end
    end
    
    # Elitist Replacement - keeps best individuals
    class ElitistReplacement < ReplacementOperator
      attr_reader :elitism_rate
      
      def initialize(elitism_rate = 0.1)
        @elitism_rate = elitism_rate
        super("Elitist Replacement", 
              "Keeps top #{(@elitism_rate * 100).round}% of population")
      end
      
      def replace(population, offspring)
        combined = population + offspring
        elite_count = (@elitism_rate * population.size).round
        
        combined.sort_by(&:fitness).reverse.take(population.size)
      end
    end
    
    # Generational Replacement - completely replace population
    class GenerationalReplacement < ReplacementOperator
      def initialize
        super("Generational Replacement", 
              "Completely replaces population with offspring")
      end
      
      def replace(population, offspring)
        offspring.take(population.size)
      end
    end
    
  end
end