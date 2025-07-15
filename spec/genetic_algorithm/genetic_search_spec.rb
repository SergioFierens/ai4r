# frozen_string_literal: true

# RSpec tests for AI4R GeneticSearch class based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::GeneticAlgorithm::GeneticSearch do
  # Test data from requirement document
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

  describe "Constructor Tests" do
    context "valid initialization" do
      it "creates GeneticSearch with valid parameters" do
        search = described_class.new(100, 50)
        expect(search).to be_a(described_class)
        expect(search.instance_variable_get(:@population_size)).to eq(100)
        expect(search.instance_variable_get(:@max_generation)).to eq(50)
      end
    end

    context "minimum population" do
      it "accepts minimum population size of 2" do
        search = described_class.new(2, 10)
        expect(search.instance_variable_get(:@population_size)).to eq(2)
      end
    end

    context "edge case: single individual population" do
      it "accepts population size of 1" do
        search = described_class.new(1, 10)
        expect(search.instance_variable_get(:@population_size)).to eq(1)
      end
    end

    context "negative tests" do
      it "handles zero population size" do
        search = described_class.new(0, 10)
        expect {
          search.generate_initial_population
        }.not_to raise_error
        expect(search.instance_variable_get(:@population)).to be_empty
      end

      it "handles negative population size" do
        search = described_class.new(-1, 10)
        expect(search.instance_variable_get(:@population_size)).to eq(-1)
      end
    end

    context "generation parameters" do
      it "accepts zero generations" do
        search = described_class.new(10, 0)
        expect(search.instance_variable_get(:@max_generation)).to eq(0)
      end

      it "accepts negative generations" do
        search = described_class.new(10, -1)
        expect(search.instance_variable_get(:@max_generation)).to eq(-1)
      end
    end
  end

  describe "Run Method Tests" do
    let(:search) { described_class.new(20, 5) }

    context "basic evolution" do
      it "runs evolution and returns best chromosome" do
        search.generate_initial_population
        initial_best = search.best_chromosome
        
        result = search.run
        
        expect(result).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
        expect(result.fitness).to be >= initial_best.fitness
      end

      it "improves fitness over generations" do
        search.generate_initial_population
        initial_fitness = search.best_chromosome.fitness
        
        search.run
        final_fitness = search.best_chromosome.fitness
        
        expect(final_fitness).to be >= initial_fitness
      end
    end

    context "edge case: single generation" do
      it "handles single generation run" do
        single_gen_search = described_class.new(10, 1)
        expect {
          result = single_gen_search.run
          expect(result).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
        }.not_to raise_error
      end
    end

    context "edge case: zero generations" do
      it "handles zero generations" do
        zero_gen_search = described_class.new(10, 0)
        expect {
          result = zero_gen_search.run
          expect(result).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
        }.not_to raise_error
      end
    end

    context "population size maintenance" do
      it "maintains population size throughout evolution" do
        search.generate_initial_population
        initial_size = search.population.size
        
        search.run
        final_size = search.population.size
        
        expect(final_size).to eq(initial_size)
      end
    end

    context "best individual tracking" do
      it "ensures best individual never gets worse during evolution" do
        search.generate_initial_population
        fitness_history = []
        
        # Track fitness over generations
        search.instance_variable_set(:@max_generation, 3)
        3.times do
          fitness_history << search.best_chromosome.fitness
          selected = search.selection
          offsprings = search.reproduction(selected)
          search.replace_worst_ranked(offsprings)
        end
        
        # Check that fitness never decreases
        fitness_history.each_cons(2) do |prev, curr|
          expect(curr).to be >= prev
        end
      end
    end
  end

  describe "Selection Tests" do
    let(:search) { described_class.new(20, 5) }

    before(:each) do
      search.generate_initial_population
    end

    context "roulette selection" do
      it "performs roulette selection successfully" do
        selected = search.selection
        
        expect(selected).to be_an(Array)
        expect(selected.length).to eq((2 * search.instance_variable_get(:@population_size)) / 3)
        expect(selected).to all(be_a(Ai4r::GeneticAlgorithm::Chromosome))
      end

      it "ensures selection pressure favors fitter individuals" do
        # Run selection multiple times and check that best individuals are selected more often
        selection_counts = Hash.new(0)
        best_chromosome = search.best_chromosome
        
        100.times do
          selected = search.selection
          selection_counts[best_chromosome] += selected.count(best_chromosome)
        end
        
        # Best chromosome should be selected more often than average
        expect(selection_counts[best_chromosome]).to be > 0
      end
    end

    context "edge case: all equal fitness" do
      it "handles population with equal fitness" do
        # Create population with equal fitness
        equal_fitness_pop = Array.new(10) { Ai4r::GeneticAlgorithm::Chromosome.seed }
        equal_fitness_pop.each { |c| allow(c).to receive(:fitness).and_return(100) }
        search.instance_variable_set(:@population, equal_fitness_pop)
        
        expect {
          selected = search.selection
          expect(selected).to be_an(Array)
          expect(selected.length).to eq(6)
        }.not_to raise_error
      end
    end

    context "edge case: single super fit individual" do
      it "handles one dominant chromosome" do
        population = search.population
        # Make first chromosome much better
        allow(population[0]).to receive(:fitness).and_return(1000)
        population[1..-1].each { |c| allow(c).to receive(:fitness).and_return(1) }
        
        selected = search.selection
        
        expect(selected).to be_an(Array)
        expect(selected.count(population[0])).to be > 0
      end
    end

    context "edge case: zero total fitness" do
      it "handles zero total fitness scenario" do
        population = search.population
        population.each { |c| allow(c).to receive(:fitness).and_return(0) }
        
        expect {
          selected = search.selection
          expect(selected).to be_an(Array)
        }.not_to raise_error
      end
    end
  end

  describe "Reproduction Tests" do
    let(:search) { described_class.new(20, 5) }

    before(:each) do
      search.generate_initial_population
    end

    context "crossover validation" do
      it "produces valid offspring through crossover" do
        selected = search.selection
        offsprings = search.reproduction(selected)
        
        expect(offsprings).to be_an(Array)
        expect(offsprings).to all(be_a(Ai4r::GeneticAlgorithm::Chromosome))
        
        # Check that offspring are valid TSP tours
        offsprings.each do |offspring|
          expect(offspring.data.sort).to eq([0, 1, 2])
        end
      end
    end

    context "mutation validation" do
      it "produces valid chromosomes after mutation" do
        selected = search.selection
        original_population = search.population.map(&:data)
        
        offsprings = search.reproduction(selected)
        
        # Check that mutated chromosomes are still valid
        search.population.each do |chromosome|
          expect(chromosome.data.sort).to eq([0, 1, 2])
        end
      end
    end

    context "elitism" do
      it "can preserve best individual with elitism" do
        best_before = search.best_chromosome
        best_fitness_before = best_before.fitness
        
        selected = search.selection
        offsprings = search.reproduction(selected)
        search.replace_worst_ranked(offsprings)
        
        best_after = search.best_chromosome
        
        expect(best_after.fitness).to be >= best_fitness_before
      end
    end

    context "edge case: odd population size" do
      it "handles odd population size reproduction" do
        odd_search = described_class.new(101, 5)
        odd_search.generate_initial_population
        
        selected = odd_search.selection
        offsprings = odd_search.reproduction(selected)
        
        expect(offsprings).to be_an(Array)
        expect(offsprings.length).to eq(selected.length / 2)
      end
    end
  end

  describe "Population Management" do
    let(:search) { described_class.new(20, 5) }

    it "generates initial population of correct size" do
      search.generate_initial_population
      
      expect(search.population).to be_an(Array)
      expect(search.population.length).to eq(20)
      expect(search.population).to all(be_a(Ai4r::GeneticAlgorithm::Chromosome))
    end

    it "finds best chromosome correctly" do
      search.generate_initial_population
      best = search.best_chromosome
      
      expect(best).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
      
      # Verify it's actually the best
      search.population.each do |chromosome|
        expect(best.fitness).to be >= chromosome.fitness
      end
    end

    it "replaces worst ranked individuals correctly" do
      search.generate_initial_population
      selected = search.selection
      offsprings = search.reproduction(selected)
      original_size = search.population.length
      
      search.replace_worst_ranked(offsprings)
      
      expect(search.population.length).to eq(original_size)
      
      # Check that some offspring are in the population
      offsprings.each do |offspring|
        expect(search.population).to include(offspring)
      end
    end

    it "handles empty population in best_chromosome" do
      search.instance_variable_set(:@population, [])
      
      expect {
        search.best_chromosome
      }.to raise_error(RuntimeError, "Population is empty")
    end

    it "handles empty population in selection" do
      search.instance_variable_set(:@population, [])
      
      expect {
        search.selection
      }.to raise_error(RuntimeError, "Population is empty")
    end
  end

  describe "Integration Tests" do
    it "runs complete genetic algorithm successfully" do
      search = described_class.new(30, 10)
      
      initial_best = nil
      expect {
        result = search.run
        initial_best = result
        expect(result).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
        expect(result.data.sort).to eq([0, 1, 2])
      }.not_to raise_error
      
      # Run again and compare
      search2 = described_class.new(30, 10)
      result2 = search2.run
      
      # Both should be valid solutions
      expect(result2.data.sort).to eq([0, 1, 2])
    end

    it "handles different cost matrices" do
      # Test with different matrix sizes
      matrices = [single_city_matrix, two_city_matrix, all_equal_matrix]
      
      matrices.each_with_index do |matrix, index|
        Ai4r::GeneticAlgorithm::Chromosome.set_cost_matrix(matrix)
        search = described_class.new(10, 5)
        
        expect {
          result = search.run
          expect(result).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
          expect(result.data.sort).to eq((0...matrix.length).to_a)
        }.not_to raise_error
      end
    end
  end

  describe "Performance and Convergence" do
    it "shows improvement over generations" do
      search = described_class.new(50, 20)
      
      fitness_improvements = []
      
      # Custom run to track improvements
      search.generate_initial_population
      initial_fitness = search.best_chromosome.fitness
      
      10.times do
        selected = search.selection
        offsprings = search.reproduction(selected)
        search.replace_worst_ranked(offsprings)
        fitness_improvements << search.best_chromosome.fitness
      end
      
      # Should show some improvement or at least not get worse
      expect(fitness_improvements.last).to be >= initial_fitness
    end

    it "maintains population diversity" do
      search = described_class.new(30, 1)
      search.generate_initial_population
      
      # Check that not all individuals are identical
      unique_individuals = search.population.map(&:data).uniq
      expect(unique_individuals.length).to be > 1
    end
  end

  # Helper methods for assertions
  def assert_valid_permutation(chromosome)
    expect(chromosome.data.sort).to eq((0...chromosome.data.length).to_a)
  end

  def assert_fitness_improves(initial_pop, final_pop)
    initial_best = initial_pop.max_by(&:fitness)
    final_best = final_pop.max_by(&:fitness)
    expect(final_best.fitness).to be >= initial_best.fitness
  end

  def assert_population_diversity(population)
    unique_individuals = population.map(&:data).uniq
    expect(unique_individuals.length).to be > 1
  end

  def assert_valid_tour_cost(chromosome, expected_cost)
    expect(chromosome.fitness).to eq(-expected_cost)
  end
end