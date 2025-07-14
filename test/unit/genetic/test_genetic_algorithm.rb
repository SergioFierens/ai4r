# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/genetic_algorithm/genetic_algorithm'
require_relative '../../helpers/genetic/bit_chromosome'

class GeneticAlgorithmUnitTest < Minitest::Test
  include Ai4r::GeneticAlgorithm

  def test_initialize_requires_population_positive
    assert_raises(ArgumentError) { GeneticSearch.new(0, 1, BitChromosome) }
  end

  def test_generation_keeps_population_size
    srand(1234)
    search = GeneticSearch.new(4, 1, BitChromosome)
    search.run
    assert_equal 4, search.population.size
  end

  def test_selection_returns_existing_chromosomes
    search = GeneticSearch.new(6, 1, BitChromosome)
    search.generate_initial_population
    selected = search.selection
    assert selected.all? { |c| search.population.include?(c) }
  end

  def test_crossover_zero_no_change
    p1 = BitChromosome.new([1, 1, 0, 0])
    p2 = BitChromosome.new([0, 0, 1, 1])
    child = BitChromosome.reproduce(p1, p2, 0)
    assert_equal p1.data, child.data
  end

  def test_crossover_one_changes_child
    p1 = BitChromosome.new([1, 1, 1, 1])
    p2 = BitChromosome.new([0, 0, 0, 0])
    child = BitChromosome.reproduce(p1, p2, 1)
    assert child.data != p1.data || child.data != p2.data
  end

  def test_mutation_zero_keeps_genome
    chrom = BitChromosome.new([1, 0, 1, 0])
    BitChromosome.mutate(chrom, 0)
    assert_equal [1, 0, 1, 0], chrom.data
  end

  def test_mutation_flips_expected_percentage
    data = Array.new(100, 0)
    chrom = BitChromosome.new(data.dup)
    BitChromosome.mutate(chrom, 0.3)
    changed = data.zip(chrom.data).count { |a, b| a != b }
    pct = changed.to_f / data.size
    assert_pct_between 0.3, pct
  end

  def test_sort_by_fitness_is_stable
    c1 = BitChromosome.new([0])
    c2 = BitChromosome.new([0])
    c3 = BitChromosome.new([0])
    pop = [c1, c2, c3]
    sorted = pop.sort_by(&:fitness)
    assert_equal pop, sorted
  end

  def test_best_chromosome_highest_fitness
    search = GeneticSearch.new(3, 1, BitChromosome)
    c1 = BitChromosome.new([0, 0])
    c2 = BitChromosome.new([1, 0])
    c3 = BitChromosome.new([1, 1])
    search.population = [c1, c2, c3]
    assert_equal c3, search.best_chromosome
  end

  def test_run_stops_at_max_generations
    search = GeneticSearch.new(4, 2, BitChromosome)
    search.run
    assert_equal 2, search.instance_variable_get(:@generation)
  end
end
