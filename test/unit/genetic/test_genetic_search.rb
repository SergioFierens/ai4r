# frozen_string_literal: true

require_relative '../../test_helper'
require 'ai4r/genetic_algorithm/genetic_algorithm'
require_relative '../../helpers/genetic/bit_chromosome'

module Ai4r
  module GeneticAlgorithm
    class ErrorChromosome < ChromosomeBase
      def fitness
        raise 'boom'
      end

      def self.seed
        new([0])
      end

      def self.reproduce(a, _b, _rate = 0.4)
        new(a.data.dup)
      end

      def self.mutate(_c, _r = 0.3); end
    end
  end
end

class GeneticSearchUnitTest < Minitest::Test
  include Ai4r::GeneticAlgorithm

  def test_empty_search_space_raises
    assert_raises(ArgumentError) { GeneticSearch.new(0, 1, BitChromosome) }
  end

  def test_fitness_error_propagates
    search = GeneticSearch.new(2, 1, ErrorChromosome)
    assert_raises(RuntimeError) { search.run }
  end

  def test_best_fitness_improves_over_initial_average
    srand(123)
    search = GeneticSearch.new(20, 5, BitChromosome)
    search.generate_initial_population
    avg_before = search.population.map(&:fitness).sum / search.population.size.to_f
    best = search.run
    improvement = (best.fitness - avg_before) / avg_before
    assert_improves 0.0, improvement
    assert improvement >= 0.20
  end
end
