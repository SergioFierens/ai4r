require_relative 'chromosome_base'

module Ai4r
  module GeneticAlgorithm
    # Chromosome implementation for the Travelling Salesman Problem.
    class TspChromosome < ChromosomeBase
      # @return [Object]
      def fitness
        return @fitness if @fitness
        last_token = @data[0]
        cost = 0
        @data[1..-1].each do |token|
          cost += @@costs[last_token][token]
          last_token = token
        end
        @fitness = -1 * cost
        @fitness
      end

      # @param chromosome [Object]
      # @param mutation_rate [Object]
      # @return [Object]
      def self.mutate(chromosome, mutation_rate = 0.3)
        if chromosome.normalized_fitness && rand < ((1 - chromosome.normalized_fitness) * mutation_rate)
          data = chromosome.data
          index = (0...data.length - 1).to_a.sample
          data[index], data[index + 1] = data[index + 1], data[index]
          chromosome.data = data
          chromosome.instance_variable_set(:@fitness, nil)
        end
      end

      # @param a [Object]
      # @param b [Object]
      # @param crossover_rate [Object]
      # @return [Object]
      def self.reproduce(a, b, crossover_rate = 0.4)
        data_size = @@costs[0].length
        available = []
        0.upto(data_size - 1) { |n| available << n }
        token = a.data[0]
        spawn = [token]
        available.delete(token)
        while available.length > 0
          if token != b.data.last && available.include?(b.data[b.data.index(token) + 1])
            next_token = b.data[b.data.index(token) + 1]
          elsif token != a.data.last && available.include?(a.data[a.data.index(token) + 1])
            next_token = a.data[a.data.index(token) + 1]
          else
            next_token = available.sample
          end
          token = next_token
          available.delete(token)
          spawn << next_token
          a, b = b, a if rand < crossover_rate
        end
        new(spawn)
      end

      # @return [Object]
      def self.seed
        data_size = @@costs[0].length
        available = []
        0.upto(data_size - 1) { |n| available << n }
        seed = []
        while available.length > 0
          seed << available.delete(available.sample)
        end
        new(seed)
      end

      # @param costs [Object]
      # @return [Object]
      def self.set_cost_matrix(costs)
        @@costs = costs
      end
    end
  end
end
