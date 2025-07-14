# frozen_string_literal: true

require 'minitest/autorun'
require 'ai4r/genetic_algorithm/genetic_algorithm'

module Ai4r
  module GeneticAlgorithm
    # Simple chromosome with fixed fitness value used for edge case testing
    class FixedChromosome < ChromosomeBase
      def initialize(data = nil, fitness_value = 1)
        super(data)
        @fitness_value = fitness_value
      end

      def fitness
        @fitness_value
      end

      def self.seed
        new(:seed, 1)
      end

      def self.reproduce(a, b, _crossover = 0.4)
        new(:child, [a.fitness, b.fitness].max)
      end

      def self.mutate(_chromosome, _rate = 0.3)
        # no-op
      end
    end

    class GeneticSearchEdgeCasesTest < Minitest::Test
      def test_selection_with_identical_fitness_sets_normalized_to_one
        search = GeneticSearch.new(4, 1, FixedChromosome)
        search.generate_initial_population
        selected = search.selection
        assert_equal 2, selected.size
        search.population.each do |c|
          assert_in_delta 1.0, c.normalized_fitness, 0.0001
        end
      end

      def test_best_chromosome_returns_highest_fitness
        low = FixedChromosome.new(:a, 1)
        high = FixedChromosome.new(:b, 5)
        search = GeneticSearch.new(2, 1, FixedChromosome)
        search.population = [low, high]
        assert_equal high, search.best_chromosome
      end

      def test_generate_initial_population_uses_seed_method
        search = GeneticSearch.new(3, 1, FixedChromosome)
        search.generate_initial_population
        assert_equal 3, search.population.length
        assert(search.population.all? { |c| c.is_a?(FixedChromosome) })
      end

      def test_missing_chromosome_methods_raise_not_implemented
        klass = Class.new(ChromosomeBase)
        search = GeneticSearch.new(1, 1, klass)
        assert_raises(NotImplementedError) { search.generate_initial_population }
      end
    end
  end
end
