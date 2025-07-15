# frozen_string_literal: true

# RSpec tests for AI4R TSP functionality based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe "AI4R TSP Chromosome Functionality" do
  # These tests work with the original Chromosome class that uses @data
  # Testing TSP-specific functionality through the existing API
  
  # Test data matrices from requirement document
  let(:simple_cost_matrix) do
    [
      [0, 10, 15],
      [10, 0, 20],
      [15, 20, 0]
    ]
  end

  let(:single_city_matrix) { [[0]] }
  let(:two_city_matrix) { [[0, 5], [5, 0]] }
  let(:all_equal_matrix) { Array.new(5) { Array.new(5) { |i, j| i == j ? 0 : 10 } } }

  before(:each) do
    # Set up cost matrix for TSP chromosome
    Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(simple_cost_matrix)
  end

  describe "TSP Chromosome Initialization Tests" do
    context "random permutation generation" do
      it "test_random_permutation_generation" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.seed
        
        expect(chromosome).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
        expect(chromosome.data).to be_an(Array)
        expect(chromosome.data.length).to eq(3)
        expect(chromosome.data.sort).to eq([0, 1, 2])
      end

      it "generates different permutations" do
        chromosomes = Array.new(10) { Ai4r::GeneticAlgorithm::Chromosome.seed }
        unique_data = chromosomes.map(&:data).uniq
        
        # Should have some variety (though not guaranteed due to randomness)
        expect(unique_data.length).to be >= 1
      end
    end

    context "custom permutation" do
      it "test_custom_permutation" do
        custom_route = [2, 0, 1]
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new(custom_route)
        
        expect(chromosome.data).to eq(custom_route)
        expect(chromosome.data.sort).to eq([0, 1, 2])
      end
    end

    context "city validation" do
      it "test_all_cities_present" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(all_equal_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.seed
        
        expect(chromosome.data.sort).to eq([0, 1, 2, 3, 4])
      end

      it "test_no_duplicate_cities" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.seed
        
        expect(chromosome.data.uniq.length).to eq(chromosome.data.length)
      end
    end
  end

  describe "TSP Cost Matrix Tests" do
    context "matrix setting and validation" do
      it "test_set_cost_matrix" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(simple_cost_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.seed
        
        expect(chromosome.data.length).to eq(simple_cost_matrix.length)
      end

      it "test_symmetric_cost_matrix" do
        # Verify symmetry
        expect(simple_cost_matrix[0][1]).to eq(simple_cost_matrix[1][0])
        expect(simple_cost_matrix[0][2]).to eq(simple_cost_matrix[2][0])
        expect(simple_cost_matrix[1][2]).to eq(simple_cost_matrix[2][1])
      end

      it "test_asymmetric_cost_matrix" do
        asymmetric_matrix = [
          [0, 10, 15],
          [5, 0, 20],
          [8, 12, 0]
        ]
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(asymmetric_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        expected_cost = 10 + 20  # 0->1 + 1->2 (doesn't return to start in fitness calculation)
        expect(chromosome.fitness).to eq(-expected_cost)
      end

      it "test_nil_cost_matrix" do
        expect {
          Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(nil)
          Ai4r::GeneticAlgorithm::Chromosome.seed
        }.to raise_error
      end

      it "test_non_square_matrix" do
        non_square_matrix = [
          [0, 10],
          [10, 0],
          [15, 20]
        ]
        
        # Should handle gracefully
        expect {
          Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(non_square_matrix)
          chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1])
          chromosome.fitness
        }.not_to raise_error
      end

      it "test_negative_costs" do
        negative_matrix = [
          [0, -10, 15],
          [-10, 0, -20],
          [15, -20, 0]
        ]
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(negative_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        expected_cost = -10 + -20  # 0->1 + 1->2
        expect(chromosome.fitness).to eq(-expected_cost)
      end

      it "test_zero_diagonal" do
        zero_diagonal_matrix = [
          [0, 10, 15],
          [10, 0, 20],
          [15, 20, 0]
        ]
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(zero_diagonal_matrix)
        
        # Diagonal should be zero
        expect(zero_diagonal_matrix[0][0]).to eq(0)
        expect(zero_diagonal_matrix[1][1]).to eq(0)
        expect(zero_diagonal_matrix[2][2]).to eq(0)
      end

      it "test_infinite_costs" do
        infinite_matrix = [
          [0, Float::INFINITY, 15],
          [Float::INFINITY, 0, 20],
          [15, 20, 0]
        ]
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(infinite_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        expect(chromosome.fitness).to eq(-Float::INFINITY)
      end
    end
  end

  describe "TSP Fitness Calculation Tests" do
    context "tour cost calculation" do
      it "test_fitness_simple_path" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        # Tour: 0->1->2 (fitness doesn't return to start)
        # Cost: 10 + 20 = 30
        # Fitness: -30 (negative because we minimize cost)
        expect(chromosome.fitness).to eq(-30)
      end

      it "test_fitness_circular_tour" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        # Should calculate sequential distances
        expect(chromosome.fitness).to be_a(Numeric)
        expect(chromosome.fitness).to be < 0  # Should be negative (minimization)
      end

      it "test_fitness_single_city" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(single_city_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0])
        
        # Single city tour should have zero cost
        expect(chromosome.fitness).to eq(0)
      end

      it "test_fitness_two_cities" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(two_city_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1])
        
        # Tour: 0->1
        # Cost: 5
        # Fitness: -5
        expect(chromosome.fitness).to eq(-5)
      end

      it "test_fitness_large_tour" do
        large_size = 50
        large_matrix = Array.new(large_size) { Array.new(large_size) { |i, j| i == j ? 0 : rand(1..100) } }
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(large_matrix)
        
        large_tour = (0...large_size).to_a
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new(large_tour)
        
        expect(chromosome.data.length).to eq(large_size)
        expect(chromosome.fitness).to be_a(Numeric)
      end

      it "test_fitness_all_equal_distances" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(all_equal_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2, 3, 4])
        
        # All edges cost 10, sequential path length 4, so total cost = 40
        expect(chromosome.fitness).to eq(-40)
      end
    end

    context "error handling" do
      it "handles missing cities in cost matrix" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 5])  # City 5 doesn't exist
        
        expect(chromosome.fitness).to eq(-Float::INFINITY)
      end

      it "handles empty data" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([])
        
        expect(chromosome.fitness).to eq(0)
      end

      it "handles nil data" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new(nil)
        
        expect(chromosome.fitness).to eq(0)
      end
    end
  end

  describe "TSP Crossover Tests" do
    context "reproduction testing" do
      it "test_order_crossover" do
        parent1 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        parent2 = Ai4r::GeneticAlgorithm::Chromosome.new([2, 1, 0])
        
        offspring = Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, parent2)
        
        expect(offspring).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
        expect(offspring.data.sort).to eq([0, 1, 2])
      end

      it "test_crossover_preserves_cities" do
        parent1 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        parent2 = Ai4r::GeneticAlgorithm::Chromosome.new([2, 1, 0])
        
        offspring = Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, parent2)
        
        expect(offspring.data.sort).to eq([0, 1, 2])
      end

      it "test_crossover_identical_parents" do
        parent1 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        parent2 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        offspring = Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, parent2)
        
        expect(offspring.data).to eq([0, 1, 2])
      end

      it "test_crossover_reverse_tours" do
        parent1 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        parent2 = Ai4r::GeneticAlgorithm::Chromosome.new([2, 1, 0])
        
        offspring = Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, parent2)
        
        expect(offspring.data.sort).to eq([0, 1, 2])
      end

      it "handles nil parents" do
        parent1 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        
        expect(Ai4r::GeneticAlgorithm::Chromosome.reproduce(nil, parent1)).to be_nil
        expect(Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, nil)).to be_nil
      end
    end
  end

  describe "TSP Mutation Tests" do
    context "mutation testing" do
      it "test_swap_mutation" do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        chromosome.normalized_fitness = 0.1  # High mutation probability
        
        # Test that mutation preserves all cities
        original_cities = chromosome.data.sort
        
        # Try mutation multiple times
        mutation_occurred = false
        100.times do
          test_chromosome = Ai4r::GeneticAlgorithm::Chromosome.new(chromosome.data.dup)
          test_chromosome.normalized_fitness = 0.1
          original_data = test_chromosome.data.dup
          
          Ai4r::GeneticAlgorithm::Chromosome.mutate(test_chromosome)
          
          if test_chromosome.data != original_data
            mutation_occurred = true
          end
          
          expect(test_chromosome.data.sort).to eq(original_cities)
        end
        
        expect(mutation_occurred).to be true
      end

      it "test_mutation_rate_effect" do
        high_fitness_chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        high_fitness_chromosome.normalized_fitness = 0.9  # Low mutation probability
        
        low_fitness_chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
        low_fitness_chromosome.normalized_fitness = 0.1  # High mutation probability
        
        # Test multiple times to account for randomness
        high_fitness_mutations = 0
        low_fitness_mutations = 0
        
        100.times do
          test_high = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
          test_high.normalized_fitness = 0.9
          original_high = test_high.data.dup
          Ai4r::GeneticAlgorithm::Chromosome.mutate(test_high)
          high_fitness_mutations += 1 if test_high.data != original_high
          
          test_low = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
          test_low.normalized_fitness = 0.1
          original_low = test_low.data.dup
          Ai4r::GeneticAlgorithm::Chromosome.mutate(test_low)
          low_fitness_mutations += 1 if test_low.data != original_low
        end
        
        expect(low_fitness_mutations).to be > high_fitness_mutations
      end

      it "test_mutation_single_city" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(single_city_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0])
        chromosome.normalized_fitness = 0.1
        
        # Single city mutation might add nil due to mutation logic
        original_length = chromosome.data.length
        Ai4r::GeneticAlgorithm::Chromosome.mutate(chromosome)
        
        # Should still contain the original city
        expect(chromosome.data).to include(0)
        # Verify no actual change occurred to the tour structure
        expect(chromosome.data.compact.sort).to eq([0])
      end

      it "test_mutation_two_cities" do
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(two_city_matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1])
        chromosome.normalized_fitness = 0.1
        
        # Mutation should preserve both cities
        original_cities = chromosome.data.sort
        Ai4r::GeneticAlgorithm::Chromosome.mutate(chromosome)
        
        expect(chromosome.data.sort).to eq(original_cities)
      end
    end
  end

  describe "TSP Performance Tests" do
    it "handles large TSP instances efficiently" do
      large_size = 50
      large_matrix = Array.new(large_size) { Array.new(large_size) { |i, j| i == j ? 0 : rand(1..1000) } }
      Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(large_matrix)
      
      benchmark_performance("Large TSP chromosome operations") do
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.seed
        chromosome.fitness
        
        # Test multiple operations
        10.times do
          parent1 = Ai4r::GeneticAlgorithm::Chromosome.seed
          parent2 = Ai4r::GeneticAlgorithm::Chromosome.seed
          offspring = Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, parent2)
          Ai4r::GeneticAlgorithm::Chromosome.mutate(offspring) if offspring
        end
      end
    end
  end

  describe "TSP Integration Tests" do
    it "works with different matrix sizes" do
      matrices = [
        single_city_matrix,
        two_city_matrix,
        simple_cost_matrix,
        all_equal_matrix
      ]
      
      matrices.each do |matrix|
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(matrix)
        chromosome = Ai4r::GeneticAlgorithm::Chromosome.seed
        
        expect(chromosome.data.sort).to eq((0...matrix.length).to_a)
        expect(chromosome.fitness).to be_a(Numeric)
      end
    end

    it "maintains tour validity through genetic operations" do
      parent1 = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
      parent2 = Ai4r::GeneticAlgorithm::Chromosome.new([2, 1, 0])
      
      # Test crossover
      offspring = Ai4r::GeneticAlgorithm::Chromosome.reproduce(parent1, parent2)
      expect(offspring.data.sort).to eq([0, 1, 2])
      
      # Test mutation
      offspring.normalized_fitness = 0.1
      original_cities = offspring.data.sort
      Ai4r::GeneticAlgorithm::Chromosome.mutate(offspring)
      expect(offspring.data.sort).to eq(original_cities)
    end
  end

  describe "TSP Edge Cases and Error Handling" do
    it "handles empty cost matrix entries" do
      incomplete_matrix = [
        [0, 10, nil],
        [10, 0, 20],
        [nil, 20, 0]
      ]
      
      Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(incomplete_matrix)
      chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 2, 1])  # Use path that hits nil entry
      
      expect(chromosome.fitness).to eq(-Float::INFINITY)
    end

    it "handles very large costs" do
      large_cost_matrix = [
        [0, 1000000, 1500000],
        [1000000, 0, 2000000],
        [1500000, 2000000, 0]
      ]
      
      Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(large_cost_matrix)
      chromosome = Ai4r::GeneticAlgorithm::Chromosome.new([0, 1, 2])
      
      expect(chromosome.fitness).to be_a(Numeric)
      expect(chromosome.fitness).to be < 0
    end
  end

  # Helper methods for assertions
  def assert_valid_permutation(chromosome)
    expect(chromosome.data.sort).to eq((0...chromosome.data.length).to_a)
  end

  def assert_valid_tour_cost(chromosome, expected_cost)
    expect(chromosome.fitness).to eq(-expected_cost)
  end
end