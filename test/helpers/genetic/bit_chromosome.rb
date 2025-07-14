module Ai4r
  module GeneticAlgorithm
    class BitChromosome < ChromosomeBase
      LENGTH = 10

      def fitness
        @data.sum
      end

      def self.seed
        new(Array.new(LENGTH) { rand(2) })
      end

      def self.reproduce(a, b, crossover_rate = 0.4)
        return new(a.data.dup) if crossover_rate.zero?

        cut = LENGTH / 2
        if crossover_rate >= 1 || rand < crossover_rate
          new(a.data[0...cut] + b.data[cut..-1])
        else
          new(a.data.dup)
        end
      end

      def self.mutate(chromosome, mutation_rate = 0.3)
        chromosome.data = chromosome.data.map do |bit|
          rand < mutation_rate ? 1 - bit : bit
        end
        chromosome.instance_variable_set(:@fitness, nil)
      end
    end
  end
end
