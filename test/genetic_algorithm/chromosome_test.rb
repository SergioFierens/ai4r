# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
 

require 'ai4r/genetic_algorithm/genetic_algorithm'
require 'ai4r/genetic_algorithm/tsp_chromosome'
require 'minitest/autorun'

module Ai4r
  
  module GeneticAlgorithm

    COST = [
              [  0,       10,       12,       21,       25,     25,       34,         26,     28,       11],
              [ 10,       0,        12,       21,       19,     21,       18,         12,     22,       11],
              [ 10,       12,       0,        24,       18,     16,       36,         29,     17,       22],
              [ 20,       12,       22,       0,        32,     34,       28,         24,     31,        9],
              [ 23,       20,       19,       31,        0,     25,       29,         25,     31,       28],
              [ 24,       20,       15,       33,       24,      0,       38,         34,     17,       25],
              [ 33,       19,       35,       29,       24,     34,        0,          9,     38,       28],
              [ 25,       13,       28,       25,       25,     34,        9,          0,     33,       19],
              [ 30,       23,       18,       29,       31,     18,       38,         34,      0,       23],
              [ 11,       11,       22,       9,        28,     26,       27,         19,     22,        0]
  ].freeze

    class ChromosomeTest < Minitest::Test

      def test_chromosome_seed
        TspChromosome.set_cost_matrix(COST)
        chromosome = TspChromosome.seed
        assert_equal [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], chromosome.data.sort
      end

      def test_fitness
        TspChromosome.set_cost_matrix(COST)
        chromosome = TspChromosome.new([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        assert_equal( -206, chromosome.fitness)
      end

      def test_reproduce
        TspChromosome.set_cost_matrix(COST)
        c1 = TspChromosome.new([2, 8, 5, 3, 6, 7, 1, 9, 0, 4])
        c2 = TspChromosome.new([3, 2, 0, 1, 5, 4, 6, 7, 9, 8])
        c3 = TspChromosome.reproduce(c1, c2)
        assert_equal([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], c3.data.sort)
      end

      def test_mutate_recalculates_fitness
        TspChromosome.set_cost_matrix(COST)
        chromosome = TspChromosome.new([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        original_fitness = chromosome.fitness
        chromosome.normalized_fitness = 0.0
        TspChromosome.mutate(chromosome, 1.0)
        mutated_data = chromosome.data.dup
        expected_fitness = TspChromosome.new(mutated_data).fitness
        assert_equal expected_fitness, chromosome.fitness
        refute_equal original_fitness, chromosome.fitness
      end

    end

  end

end
