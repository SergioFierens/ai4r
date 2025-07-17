require_relative '../test_helper'
require 'ai4r/genetic_algorithm/chromosome_base'

class ChromosomeBaseTest < Minitest::Test
  include Ai4r::GeneticAlgorithm

  def test_base_methods_raise_errors
    chromosome = ChromosomeBase.new([1, 2])
    assert_raises(NotImplementedError) { chromosome.fitness }
    assert_raises(NotImplementedError) { ChromosomeBase.seed }
    assert_raises(NotImplementedError) { ChromosomeBase.reproduce(chromosome, chromosome) }
    assert_raises(NotImplementedError) { ChromosomeBase.mutate(chromosome) }
  end

  def test_attribute_accessors
    chromosome = ChromosomeBase.new([1, 2])
    chromosome.normalized_fitness = 0.5
    assert_equal [1, 2], chromosome.data
    assert_equal 0.5, chromosome.normalized_fitness
  end
end
