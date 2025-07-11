# frozen_string_literal: true
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
require_relative 'chromosome_base'
require_relative 'tsp_chromosome'

module Ai4r

  # The GeneticAlgorithm module implements the GeneticSearch class. The
  # GeneticSearch is a generic class, and can be used to solve any kind of
  # problem. The Chromosome implementation is problem specific and must conform
  # to +ChromosomeBase+.
  module GeneticAlgorithm

    #   This class is used to automatically:
    #   
    #     1. Choose initial population
    #     2. Evaluate the fitness of each individual in the population
    #     3. Repeat
    #           1. Select best-ranking individuals to reproduce
    #           2. Breed new generation through crossover and mutation (genetic operations) and give birth to offspring
    #           3. Evaluate the individual fitnesses of the offspring
    #           4. Replace worst ranked part of population with offspring
    #     4. Until termination
    #
    #   If you want to customize the algorithm, you must modify any of the following classes:
    #     - Chromosome
    #     - Population
    class GeneticSearch

      attr_accessor :population
      attr_reader :chromosome_class


      def initialize(initial_population_size, generations, chromosome_class = TspChromosome)
        @population_size = initial_population_size
        @max_generation = generations
        @generation = 0
        @chromosome_class = chromosome_class
      end

      #     1. Choose initial population
      #     2. Evaluate the fitness of each individual in the population
      #     3. Repeat
      #           1. Select best-ranking individuals to reproduce
      #           2. Breed new generation through crossover and mutation (genetic operations) and give birth to offspring
      #           3. Evaluate the individual fitnesses of the offspring
      #           4. Replace worst ranked part of population with offspring
      #     4. Until termination    
      #     5. Return the best chromosome
      def run
        generate_initial_population                    #Generate initial population 
        @max_generation.times do
          selected_to_breed = selection                #Evaluates current population 
          offsprings = reproduction selected_to_breed  #Generate the population for this new generation
          replace_worst_ranked offsprings
        end
        return best_chromosome
      end


      def generate_initial_population
       @population = []
       @population_size.times do
         population << @chromosome_class.seed
       end
      end

      # Select best-ranking individuals to reproduce
      # 
      # Selection is the stage of a genetic algorithm in which individual 
      # genomes are chosen from a population for later breeding. 
      # There are several generic selection algorithms, such as 
      # tournament selection and roulette wheel selection. We implemented the
      # latest.
      # 
      # Steps:
      # 
      # 1. The fitness function is evaluated for each individual, providing fitness values
      # 2. The population is sorted by descending fitness values.
      # 3. The fitness values ar then normalized. (Highest fitness gets 1, lowest fitness gets 0). The normalized value is stored in the "normalized_fitness" attribute of the chromosomes.
      # 4. A random number R is chosen. R is between 0 and the accumulated normalized value (all the normalized fitness values added togheter).
      # 5. The selected individual is the first one whose accumulated normalized value (its is normalized value plus the normalized values of the chromosomes prior it) greater than R.
      # 6. We repeat steps 4 and 5, 2/3 times the population size.    
      def selection
        @population.sort! { |a, b| b.fitness <=> a.fitness}
        best_fitness = @population[0].fitness
        worst_fitness = @population.last.fitness
        acum_fitness = 0
        if best_fitness-worst_fitness > 0
        @population.each do |chromosome| 
          chromosome.normalized_fitness = (chromosome.fitness - worst_fitness)/(best_fitness-worst_fitness)
          acum_fitness += chromosome.normalized_fitness
        end
        else
          @population.each { |chromosome| chromosome.normalized_fitness = 1}  
        end
        selected_to_breed = []
        ((2*@population_size)/3).times do 
          selected_to_breed << select_random_individual(acum_fitness)
        end
        selected_to_breed
      end

      # We combine each pair of selected chromosome using the method 
      # Chromosome.reproduce
      #
      # The reproduction will also call the Chromosome.mutate method with 
      # each member of the population. You should implement Chromosome.mutate
      # to only change (mutate) randomly. E.g. You could effectivly change the
      # chromosome only if 
      #     rand < ((1 - chromosome.normalized_fitness) * 0.4)
      def reproduction(selected_to_breed)
        offsprings = []
        0.upto(selected_to_breed.length/2 - 1) do |i|
          offsprings << @chromosome_class.reproduce(selected_to_breed[2 * i], selected_to_breed[2 * i + 1])
        end
        @population.each do |individual|
          @chromosome_class.mutate(individual)
        end
        offsprings
      end

      # Replace worst ranked part of population with offspring
      def replace_worst_ranked(offsprings)
        size = offsprings.length
        @population = @population[0..(-size-1)] + offsprings
      end

      # Select the best chromosome in the population
      def best_chromosome
        the_best = @population[0]
        @population.each do |chromosome|
          the_best = chromosome if chromosome.fitness > the_best.fitness
        end
        return the_best
      end

      private 
      def select_random_individual(acum_fitness)
        select_random_target = acum_fitness * rand
        local_acum = 0
        @population.each do |chromosome|
          local_acum += chromosome.normalized_fitness
          return chromosome if local_acum >= select_random_target
        end
      end

    end

  end

end
