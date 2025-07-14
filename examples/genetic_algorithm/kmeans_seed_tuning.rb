#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../lib/ai4r/genetic_algorithm/genetic_algorithm'
require_relative '../../lib/ai4r/clusterers/k_means'
require_relative '../som/som_data'

include Ai4r::GeneticAlgorithm
include Ai4r::Clusterers
include Ai4r::Data

class SeedChromosome < ChromosomeBase
  RANGE = (0..10)
  DATA = DataSet.new(data_items: SOM_DATA.first(30))

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

search = GeneticSearch.new(6, 5, SeedChromosome, 0.1, 0.7)
best = search.run
puts(-best.fitness)
