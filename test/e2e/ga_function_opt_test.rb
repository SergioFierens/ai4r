# frozen_string_literal: true

require_relative '../test_helper'
require 'ai4r/genetic_algorithm/genetic_algorithm'

class GaFunctionOptTest < Minitest::Test
  include Ai4r::GeneticAlgorithm

  class IntChromosome < ChromosomeBase
    RANGE = (0..31)

    def fitness
      @data**2
    end

    def self.seed
      new(RANGE.to_a.sample)
    end

    def self.reproduce(a, b, rate = 0.7)
      new(rand < rate ? b.data : a.data)
    end

    def self.mutate(chrom, rate = 0.1)
      chrom.data = RANGE.to_a.sample if rand < rate
    end
  end

  def test_finds_max_value
    srand(1234)
    search = GeneticSearch.new(10, 20, IntChromosome, 0.2, 0.7)
    best = search.run
    assert_equal 31, best.data
  end
end
