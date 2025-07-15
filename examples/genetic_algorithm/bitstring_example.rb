# frozen_string_literal: true

# Example using a custom chromosome to maximise ones in a bit string
require_relative '../../lib/ai4r/genetic_algorithm/genetic_algorithm'

# Represents a chromosome consisting of a bit string.
class BitStringChromosome < Ai4r::GeneticAlgorithm::ChromosomeBase
  LENGTH = 16

  def fitness
    @data.count(1)
  end

  def self.seed
    new(Array.new(LENGTH) { rand(2) })
  end

  def self.reproduce(parent_a, parent_b, crossover_rate = 0.4)
    point = rand(LENGTH)
    data = parent_a.data[0...point] + parent_b.data[point..]
    data = parent_b.data[0...point] + parent_a.data[point..] if rand < crossover_rate
    new(data)
  end

  def self.mutate(chromosome, mutation_rate = 0.3)
    chromosome.data.map!.with_index do |bit, _|
      if rand < ((1 - chromosome.normalized_fitness.to_f) * mutation_rate)
        1 - bit
      else
        bit
      end
    end
    chromosome.instance_variable_set(:@fitness, nil)
  end
end

search = Ai4r::GeneticAlgorithm::GeneticSearch.new(
  30, 50, BitStringChromosome, 0.2, 0.7, BitStringChromosome::LENGTH
)
best = search.run
puts "Best fitness #{best.fitness}: #{best.data.join}"
