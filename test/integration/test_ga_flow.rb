# frozen_string_literal: true

require_relative '../test_helper'
require 'ai4r/genetic_algorithm/genetic_algorithm'
require 'ai4r/clusterers/k_means'
require 'ai4r/classifiers/simple_linear_regression'
require 'ai4r/data/data_set'
require 'yaml'
require_relative '../../examples/som/som_data'

class GaFlowIntegrationTest < Minitest::Test
  include Ai4r::GeneticAlgorithm
  include Ai4r::Clusterers
  include Ai4r::Classifiers
  include Ai4r::Data

  SOM_SUBSET = SOM_DATA.first(30)
  SLR_FILE = File.expand_path('../../examples/classifiers/simple_linear_regression_example.csv',
                              __dir__)

  class SeedChromosome < ChromosomeBase
    RANGE = (0..10)
    DATA = DataSet.new(data_items: SOM_SUBSET)

    def fitness
      return @fitness if @fitness

      kmeans = KMeans.new.set_parameters(random_seed: @data).build(DATA, 3)
      @fitness = -kmeans.sse
    end

    def self.seed
      new(RANGE.to_a.sample)
    end

    def self.reproduce(a, b, _rate = 0.7)
      new([a.data, b.data].sample)
    end

    def self.mutate(chrom, rate = 0.3)
      return unless rand < rate

      chrom.data = RANGE.to_a.sample
      chrom.instance_variable_set(:@fitness, nil)
    end
  end

  class SlrFeatureChromosome < ChromosomeBase
    DATA = DataSet.new.parse_csv_with_labels(SLR_FILE)

    def fitness
      reg = SimpleLinearRegression.new.set_parameters(selected_attribute: @data).build(DATA)
      ys = DATA.data_items.map { |r| r[-1] }
      mean = ys.sum.to_f / ys.length
      ss_tot = ys.sum { |y| (y - mean)**2 }
      sse = DATA.data_items.sum { |row| (row[-1] - reg.eval(row))**2 }
      1 - (sse / ss_tot)
    end

    def self.seed
      new(rand(DATA.num_attributes - 1))
    end

    def self.reproduce(a, b, _rate = 0.7)
      new([a.data, b.data].sample)
    end

    def self.mutate(chrom, rate = 0.3)
      chrom.data = rand(DATA.num_attributes - 1) if rand < rate
    end
  end

  def test_ga_improves_kmeans_sse
    srand(123)
    data = SeedChromosome::DATA
    baseline = KMeans.new.set_parameters(random_seed: 1).build(data, 3).sse

    search = GeneticSearch.new(6, 5, SeedChromosome, 0.1, 0.7)
    best = search.run
    improved_sse = -best.fitness
    assert improved_sse < baseline
  end

  def test_ga_finds_high_r2_for_slr
    srand(123)
    search = GeneticSearch.new(6, 5, SlrFeatureChromosome, 0.1, 0.7)
    best = search.run
    assert best.fitness >= 0.9
  end

  def test_yaml_params_override_defaults
    yml = { 'mutation_rate' => 0.05, 'crossover_rate' => 0.9, 'population' => 4 }
    File.write('tmp_ga.yml', yml.to_yaml)
    params = YAML.safe_load_file('tmp_ga.yml')
    search = GeneticSearch.new(
      params['population'],
      1,
      SlrFeatureChromosome,
      params['mutation_rate'],
      params['crossover_rate']
    )
    assert_in_delta params['mutation_rate'], search.mutation_rate, 1e-6
    assert_in_delta params['crossover_rate'], search.crossover_rate, 1e-6
    assert_equal params['population'], search.instance_variable_get(:@population_size)
    File.delete('tmp_ga.yml')
  end
end
