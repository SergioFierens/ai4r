module Ai4r
  module GeneticAlgorithm
    # Base interface for chromosomes used by GeneticSearch.
    # Implementations must define class methods `seed`, `mutate`,
    # `reproduce` and the instance method `fitness`.
    class ChromosomeBase
      attr_accessor :data
      attr_accessor :normalized_fitness

      def initialize(data = nil)
        @data = data
      end

      def fitness
        raise NotImplementedError, 'Subclasses must implement #fitness'
      end

      def self.seed
        raise NotImplementedError, 'Implement .seed in subclass'
      end

      def self.reproduce(_a, _b, _crossover_rate = 0.4)
        raise NotImplementedError, 'Implement .reproduce in subclass'
      end

      def self.mutate(_chromosome, _mutation_rate = 0.3)
        raise NotImplementedError, 'Implement .mutate in subclass'
      end
    end
  end
end
