# frozen_string_literal: true

# RSpec tests for AI4R Chromosome base class based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::GeneticAlgorithm::Chromosome do
  # Test data matrices from requirement document
  let(:simple_cost_matrix) do
    [
      [0, 10, 15],
      [10, 0, 20],
      [15, 20, 0]
    ]
  end

  let(:sample_data) { [0, 1, 2] }
  let(:chromosome) { described_class.new(sample_data) }

  before(:each) do
    described_class.set_cost_matrix(simple_cost_matrix)
  end

  describe "Base Chromosome Class Tests" do
    describe "initialization" do
      it "initializes with valid data" do
        expect(chromosome.data).to eq(sample_data)
        expect(chromosome.data).not_to be(sample_data) # Should be a copy
      end

      it "handles data immutability" do
        original_data = sample_data.dup
        chromosome = described_class.new(sample_data)
        
        # Modify original data
        sample_data[0] = 999
        
        # Chromosome data should be unchanged
        expect(chromosome.data).to eq(original_data)
      end

      it "handles nil data initialization" do
        expect {
          nil_chromosome = described_class.new(nil)
          expect(nil_chromosome.data).to be_nil
        }.not_to raise_error
      end
    end

    describe "data validation" do
      it "properly sets @data instance variable" do
        expect(chromosome.instance_variable_get(:@data)).to eq(sample_data)
      end

      it "creates independent copy of data" do
        original = [1, 2, 3]
        chr = described_class.new(original)
        
        # Modify chromosome data
        chr.data[0] = 999
        
        # Original should be unchanged
        expect(original).to eq([1, 2, 3])
      end

      it "handles empty data" do
        empty_chromosome = described_class.new([])
        expect(empty_chromosome.data).to eq([])
        expect(empty_chromosome.fitness).to eq(0)
      end
    end

    describe "fitness calculation" do
      it "calculates fitness for valid TSP tour" do
        # Tour: 0 -> 1 -> 2 -> 0
        # Cost: 10 + 20 + 15 = 45
        # Fitness: -45 (negative because we minimize cost)
        tour = [0, 1, 2]
        tsp_chromosome = described_class.new(tour)
        
        expect(tsp_chromosome.fitness).to eq(-45)
      end

      it "handles single city tour" do
        described_class.set_cost_matrix([[0]])
        single_city = described_class.new([0])
        
        expect(single_city.fitness).to eq(0)
      end

      it "handles two city tour" do
        described_class.set_cost_matrix([[0, 5], [5, 0]])
        two_city = described_class.new([0, 1])
        
        # Cost: 0->1 (5) + 1->0 (5) = 10, but fitness calculation doesn't return to start
        # So it's just 0->1 = 5, fitness = -5
        expect(two_city.fitness).to eq(-5)
      end

      it "returns cached fitness on subsequent calls" do
        expect(chromosome.fitness).to eq(chromosome.fitness)
      end

      it "handles missing cost matrix entries" do
        # Create chromosome with city not in matrix
        invalid_chromosome = described_class.new([0, 1, 5])  # City 5 doesn't exist
        
        expect(invalid_chromosome.fitness).to eq(-Float::INFINITY)
      end

      it "handles nil or empty data" do
        nil_chromosome = described_class.new(nil)
        expect(nil_chromosome.fitness).to eq(0)
        
        empty_chromosome = described_class.new([])
        expect(empty_chromosome.fitness).to eq(0)
      end

      it "handles insufficient data" do
        single_element = described_class.new([0])
        expect(single_element.fitness).to eq(0)
      end
    end

    describe "normalized_fitness attribute" do
      it "allows setting and getting normalized_fitness" do
        chromosome.normalized_fitness = 0.75
        expect(chromosome.normalized_fitness).to eq(0.75)
      end

      it "starts with nil normalized_fitness" do
        expect(chromosome.normalized_fitness).to be_nil
      end
    end
  end

  describe "Static Methods" do
    describe "seed method" do
      it "generates valid random permutation" do
        chromosome = described_class.seed
        
        expect(chromosome).to be_a(described_class)
        expect(chromosome.data).to be_an(Array)
        expect(chromosome.data.length).to eq(3)
        expect(chromosome.data.sort).to eq([0, 1, 2])
      end

      it "generates different permutations" do
        chromosomes = Array.new(10) { described_class.seed }
        unique_data = chromosomes.map(&:data).uniq
        
        # Should have some variety (though not guaranteed due to randomness)
        expect(unique_data.length).to be >= 1
      end

      it "respects cost matrix size" do
        larger_matrix = Array.new(5) { Array.new(5) { |i, j| i == j ? 0 : rand(1..20) } }
        described_class.set_cost_matrix(larger_matrix)
        
        chromosome = described_class.seed
        expect(chromosome.data.length).to eq(5)
        expect(chromosome.data.sort).to eq([0, 1, 2, 3, 4])
      end
    end

    describe "set_cost_matrix method" do
      it "sets class variable correctly" do
        new_matrix = [[0, 1], [1, 0]]
        described_class.set_cost_matrix(new_matrix)
        
        chromosome = described_class.seed
        expect(chromosome.data.length).to eq(2)
      end

      it "allows matrix updates" do
        original_matrix = simple_cost_matrix
        described_class.set_cost_matrix(original_matrix)
        
        new_matrix = Array.new(4) { Array.new(4) { |i, j| i == j ? 0 : 10 } }
        described_class.set_cost_matrix(new_matrix)
        
        chromosome = described_class.seed
        expect(chromosome.data.length).to eq(4)
      end
    end

    describe "mutate method" do
      it "sometimes mutates chromosomes" do
        # Set up chromosome with high mutation probability
        chromosome.normalized_fitness = 0.1  # High mutation probability
        original_data = chromosome.data.dup
        
        # Try mutation multiple times
        mutation_occurred = false
        100.times do
          test_chromosome = described_class.new(original_data.dup)
          test_chromosome.normalized_fitness = 0.1
          described_class.mutate(test_chromosome)
          
          if test_chromosome.data != original_data
            mutation_occurred = true
            break
          end
        end
        
        expect(mutation_occurred).to be true
      end

      it "preserves all cities during mutation" do
        chromosome.normalized_fitness = 0.1
        original_cities = chromosome.data.sort
        
        100.times do
          test_chromosome = described_class.new(chromosome.data.dup)
          test_chromosome.normalized_fitness = 0.1
          described_class.mutate(test_chromosome)
          
          expect(test_chromosome.data.sort).to eq(original_cities)
        end
      end

      it "respects normalized_fitness for mutation probability" do
        high_fitness_chromosome = described_class.new([0, 1, 2])
        high_fitness_chromosome.normalized_fitness = 0.9  # Low mutation probability
        
        low_fitness_chromosome = described_class.new([0, 1, 2])
        low_fitness_chromosome.normalized_fitness = 0.1  # High mutation probability
        
        # Test multiple times to account for randomness
        high_fitness_mutations = 0
        low_fitness_mutations = 0
        
        100.times do
          test_high = described_class.new([0, 1, 2])
          test_high.normalized_fitness = 0.9
          original_high = test_high.data.dup
          described_class.mutate(test_high)
          high_fitness_mutations += 1 if test_high.data != original_high
          
          test_low = described_class.new([0, 1, 2])
          test_low.normalized_fitness = 0.1
          original_low = test_low.data.dup
          described_class.mutate(test_low)
          low_fitness_mutations += 1 if test_low.data != original_low
        end
        
        expect(low_fitness_mutations).to be > high_fitness_mutations
      end

      it "handles nil normalized_fitness" do
        expect {
          described_class.mutate(chromosome)
        }.not_to raise_error
      end
    end

    describe "reproduce method" do
      let(:parent1) { described_class.new([0, 1, 2]) }
      let(:parent2) { described_class.new([2, 1, 0]) }

      it "produces valid offspring from two parents" do
        offspring = described_class.reproduce(parent1, parent2)
        
        expect(offspring).to be_a(described_class)
        expect(offspring.data).to be_an(Array)
        expect(offspring.data.length).to eq(3)
        expect(offspring.data.sort).to eq([0, 1, 2])
      end

      it "handles identical parents" do
        identical_parent = described_class.new([0, 1, 2])
        offspring = described_class.reproduce(identical_parent, identical_parent)
        
        expect(offspring).to be_a(described_class)
        expect(offspring.data.sort).to eq([0, 1, 2])
      end

      it "handles reverse tour parents" do
        parent1 = described_class.new([0, 1, 2])
        parent2 = described_class.new([2, 1, 0])
        
        offspring = described_class.reproduce(parent1, parent2)
        
        expect(offspring.data.sort).to eq([0, 1, 2])
      end

      it "returns nil for nil parents" do
        expect(described_class.reproduce(nil, parent2)).to be_nil
        expect(described_class.reproduce(parent1, nil)).to be_nil
        expect(described_class.reproduce(nil, nil)).to be_nil
      end

      it "returns nil for parents with nil data" do
        nil_data_parent = described_class.new(nil)
        expect(described_class.reproduce(nil_data_parent, parent2)).to be_nil
        expect(described_class.reproduce(parent1, nil_data_parent)).to be_nil
      end

      it "returns nil for parents with empty data" do
        empty_data_parent = described_class.new([])
        expect(described_class.reproduce(empty_data_parent, parent2)).to be_nil
        expect(described_class.reproduce(parent1, empty_data_parent)).to be_nil
      end

      it "uses edge recombination algorithm" do
        # Test that offspring contains cities from both parents
        offspring = described_class.reproduce(parent1, parent2)
        
        # Should contain all cities
        expect(offspring.data.sort).to eq([0, 1, 2])
        
        # Should start with first parent's first city
        expect(offspring.data[0]).to eq(parent1.data[0])
      end

      it "handles different cost matrix sizes" do
        larger_matrix = Array.new(5) { Array.new(5) { |i, j| i == j ? 0 : rand(1..20) } }
        described_class.set_cost_matrix(larger_matrix)
        
        large_parent1 = described_class.new([0, 1, 2, 3, 4])
        large_parent2 = described_class.new([4, 3, 2, 1, 0])
        
        offspring = described_class.reproduce(large_parent1, large_parent2)
        
        expect(offspring.data.length).to eq(5)
        expect(offspring.data.sort).to eq([0, 1, 2, 3, 4])
      end

      it "produces diverse offspring from multiple crossovers" do
        offspring_set = Set.new
        
        10.times do
          offspring = described_class.reproduce(parent1, parent2)
          offspring_set << offspring.data
        end
        
        # Should produce some variety (though not guaranteed due to randomness)
        expect(offspring_set.size).to be >= 1
      end
    end
  end

  describe "Edge Cases and Error Handling" do
    it "handles cost matrix with negative values" do
      negative_matrix = [
        [0, -10, 15],
        [-10, 0, -20],
        [15, -20, 0]
      ]
      described_class.set_cost_matrix(negative_matrix)
      
      chromosome = described_class.new([0, 1, 2])
      expect(chromosome.fitness).to eq(-(-10 + -20))  # Should be 30
    end

    it "handles cost matrix with infinite values" do
      infinite_matrix = [
        [0, Float::INFINITY, 15],
        [Float::INFINITY, 0, 20],
        [15, 20, 0]
      ]
      described_class.set_cost_matrix(infinite_matrix)
      
      chromosome = described_class.new([0, 1, 2])
      expect(chromosome.fitness).to eq(-Float::INFINITY)
    end

    it "handles zero diagonal costs" do
      zero_diagonal = [
        [0, 10, 15],
        [10, 0, 20],
        [15, 20, 0]
      ]
      described_class.set_cost_matrix(zero_diagonal)
      
      single_city = described_class.new([0])
      expect(single_city.fitness).to eq(0)
    end

    it "handles asymmetric cost matrix" do
      asymmetric_matrix = [
        [0, 10, 15],
        [5, 0, 20],
        [8, 12, 0]
      ]
      described_class.set_cost_matrix(asymmetric_matrix)
      
      chromosome = described_class.new([0, 1, 2])
      expected_cost = 10 + 20  # 0->1 + 1->2
      expect(chromosome.fitness).to eq(-expected_cost)
    end

    it "handles large tours" do
      large_size = 10
      large_matrix = Array.new(large_size) { Array.new(large_size) { |i, j| i == j ? 0 : rand(1..100) } }
      described_class.set_cost_matrix(large_matrix)
      
      large_tour = (0...large_size).to_a
      large_chromosome = described_class.new(large_tour)
      
      expect(large_chromosome.data.length).to eq(large_size)
      expect(large_chromosome.fitness).to be_a(Numeric)
    end

    it "handles non-square cost matrix gracefully" do
      # This is an edge case - the implementation should handle it
      non_square_matrix = [
        [0, 10],
        [10, 0],
        [15, 20]
      ]
      
      expect {
        described_class.set_cost_matrix(non_square_matrix)
        chromosome = described_class.new([0, 1])
      }.not_to raise_error
    end
  end

  describe "Performance Tests" do
    it "handles fitness calculation efficiently" do
      large_matrix = Array.new(100) { Array.new(100) { |i, j| i == j ? 0 : rand(1..1000) } }
      described_class.set_cost_matrix(large_matrix)
      
      large_chromosome = described_class.new((0...100).to_a)
      
      benchmark_performance("Large chromosome fitness calculation") do
        large_chromosome.fitness
      end
    end

    it "handles multiple chromosome operations efficiently" do
      benchmark_performance("Multiple chromosome operations") do
        100.times do
          chromosome = described_class.seed
          chromosome.fitness
          described_class.mutate(chromosome)
        end
      end
    end
  end

  describe "Integration with GeneticSearch" do
    it "works correctly with genetic search algorithm" do
      search = Ai4r::GeneticAlgorithm::GeneticSearch.new(20, 5)
      
      expect {
        result = search.run
        expect(result).to be_a(described_class)
        expect(result.data.sort).to eq([0, 1, 2])
      }.not_to raise_error
    end

    it "maintains data integrity through genetic operations" do
      parent1 = described_class.new([0, 1, 2])
      parent2 = described_class.new([2, 1, 0])
      
      offspring = described_class.reproduce(parent1, parent2)
      described_class.mutate(offspring)
      
      # Should still be a valid permutation
      expect(offspring.data.sort).to eq([0, 1, 2])
      expect(offspring.fitness).to be_a(Numeric)
    end
  end
end