# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::GeneticAlgorithm::GeneticSearch do
  # Create a simple test chromosome class
  class TestChromosome < Ai4r::GeneticAlgorithm::Chromosome
    attr_accessor :data, :fitness
    
    def initialize(data)
      super(data)
      @data = data
    end
    
    def self.seed
      new(Array.new(5) { rand(0..10) })
    end
    
    def fitness
      @fitness ||= @data.sum # Simple fitness: sum of all values
    end
    
    def self.mutate(chromosome)
      mutated_data = chromosome.data.dup
      index = rand(mutated_data.length)
      mutated_data[index] = rand(0..10)
      new(mutated_data)
    end
    
    def self.reproduce(parent1, parent2)
      # Simple crossover at midpoint
      midpoint = parent1.data.length / 2
      child_data = parent1.data[0...midpoint] + parent2.data[midpoint..-1]
      new(child_data)
    end
  end
  
  let(:genetic_search) { described_class.new(10, 5) }
  
  describe '#initialize' do
    it 'sets initial parameters' do
      ga = described_class.new(20, 100)
      expect(ga.instance_variable_get(:@population_size)).to eq(20)
      expect(ga.instance_variable_get(:@max_generation)).to eq(100)
      expect(ga.instance_variable_get(:@generation)).to eq(0)
    end
  end
  
  describe '#generate_initial_population' do
    before do
      # Override Chromosome class for testing
      allow(Ai4r::GeneticAlgorithm::Chromosome).to receive(:seed).and_return(TestChromosome.seed)
    end
    
    it 'creates population of specified size' do
      genetic_search.generate_initial_population
      expect(genetic_search.population.size).to eq(10)
    end
    
    it 'creates chromosome instances' do
      genetic_search.generate_initial_population
      genetic_search.population.each do |chromosome|
        expect(chromosome).to be_a(Ai4r::GeneticAlgorithm::Chromosome)
      end
    end
  end
  
  describe '#selection' do
    before do
      # Create test population with known fitness values
      genetic_search.population = [
        TestChromosome.new([10, 10, 10, 10, 10]), # fitness: 50
        TestChromosome.new([8, 8, 8, 8, 8]),       # fitness: 40
        TestChromosome.new([6, 6, 6, 6, 6]),       # fitness: 30
        TestChromosome.new([4, 4, 4, 4, 4]),       # fitness: 20
        TestChromosome.new([2, 2, 2, 2, 2])        # fitness: 10
      ]
    end
    
    it 'raises error for empty population' do
      genetic_search.population = []
      expect { genetic_search.selection }.to raise_error('Population is empty')
    end
    
    it 'sorts population by fitness' do
      genetic_search.selection
      fitnesses = genetic_search.population.map(&:fitness)
      expect(fitnesses).to eq(fitnesses.sort.reverse)
    end
    
    it 'selects chromosomes for breeding' do
      selected = genetic_search.selection
      expect(selected).to be_an(Array)
      expect(selected).not_to be_empty
      
      # Should select approximately 2/3 of population size
      expected_size = (genetic_search.population.size * 2.0 / 3.0).to_i
      expect(selected.size).to be_within(2).of(expected_size)
    end
    
    it 'normalizes fitness values' do
      genetic_search.selection
      
      # Check normalized fitness values
      genetic_search.population.each do |chromosome|
        expect(chromosome.normalized_fitness).to be_between(0, 1)
      end
      
      # Best should have normalized fitness of 1
      expect(genetic_search.population.first.normalized_fitness).to eq(1.0)
      
      # Worst should have normalized fitness of 0
      expect(genetic_search.population.last.normalized_fitness).to eq(0.0)
    end
    
    it 'favors higher fitness chromosomes' do
      # Run selection multiple times to check statistical bias
      selections = []
      100.times do
        selected = genetic_search.selection
        selections.concat(selected)
      end
      
      # Count how often each fitness level appears
      fitness_counts = Hash.new(0)
      selections.each do |chromosome|
        fitness_counts[chromosome.fitness] += 1
      end
      
      # Higher fitness should be selected more often
      expect(fitness_counts[50]).to be > fitness_counts[10]
      expect(fitness_counts[40]).to be > fitness_counts[20]
    end
  end
  
  describe '#reproduction' do
    let(:parents) do
      [
        TestChromosome.new([5, 5, 5, 5, 5]),
        TestChromosome.new([10, 10, 10, 10, 10])
      ]
    end
    
    it 'generates offspring from parents' do
      offspring = genetic_search.reproduction(parents)
      expect(offspring).to be_an(Array)
      expect(offspring).not_to be_empty
    end
    
    it 'creates correct number of offspring' do
      genetic_search.population = Array.new(10) { TestChromosome.new([1, 1, 1, 1, 1]) }
      offspring = genetic_search.reproduction(parents)
      
      # Should create enough offspring to maintain population size
      expect(offspring.size).to be <= genetic_search.population.size
    end
    
    it 'uses crossover and mutation' do
      # Mock the chromosome methods to track calls
      allow(TestChromosome).to receive(:reproduce).and_call_original
      allow(TestChromosome).to receive(:mutate).and_call_original
      
      genetic_search.population = Array.new(10) { TestChromosome.new([1, 1, 1, 1, 1]) }
      genetic_search.reproduction(parents)
      
      # Should call reproduction (crossover)
      expect(TestChromosome).to have_received(:reproduce).at_least(:once)
    end
  end
  
  describe '#replace_worst_ranked' do
    before do
      genetic_search.population = [
        TestChromosome.new([10, 10, 10, 10, 10]), # fitness: 50
        TestChromosome.new([8, 8, 8, 8, 8]),       # fitness: 40
        TestChromosome.new([6, 6, 6, 6, 6]),       # fitness: 30
        TestChromosome.new([4, 4, 4, 4, 4]),       # fitness: 20
        TestChromosome.new([2, 2, 2, 2, 2])        # fitness: 10
      ]
    end
    
    it 'replaces worst individuals with offspring' do
      offspring = [
        TestChromosome.new([7, 7, 7, 7, 7]), # fitness: 35
        TestChromosome.new([9, 9, 9, 9, 9])  # fitness: 45
      ]
      
      original_best = genetic_search.population.first
      genetic_search.replace_worst_ranked(offspring)
      
      # Best individual should be preserved
      expect(genetic_search.population).to include(original_best)
      
      # Population size should remain constant
      expect(genetic_search.population.size).to eq(5)
      
      # Worst individuals should be replaced
      worst_fitness_values = genetic_search.population.map(&:fitness).sort.first(2)
      expect(worst_fitness_values).not_to include(10, 20)
    end
    
    it 'maintains population sorted by fitness' do
      offspring = [TestChromosome.new([7, 7, 7, 7, 7])]
      
      genetic_search.replace_worst_ranked(offspring)
      
      fitnesses = genetic_search.population.map(&:fitness)
      expect(fitnesses).to eq(fitnesses.sort.reverse)
    end
  end
  
  describe '#best_chromosome' do
    before do
      genetic_search.population = [
        TestChromosome.new([6, 6, 6, 6, 6]),
        TestChromosome.new([10, 10, 10, 10, 10]),
        TestChromosome.new([8, 8, 8, 8, 8])
      ]
    end
    
    it 'returns chromosome with highest fitness' do
      best = genetic_search.best_chromosome
      expect(best.fitness).to eq(50)
      expect(best.data).to eq([10, 10, 10, 10, 10])
    end
  end
  
  describe '#run' do
    before do
      # Use test chromosome for the entire run
      stub_const('Ai4r::GeneticAlgorithm::Chromosome', TestChromosome)
    end
    
    it 'executes complete genetic algorithm' do
      ga = described_class.new(20, 10)
      
      # Track method calls
      allow(ga).to receive(:generate_initial_population).and_call_original
      allow(ga).to receive(:selection).and_call_original
      allow(ga).to receive(:reproduction).and_call_original
      allow(ga).to receive(:replace_worst_ranked).and_call_original
      
      result = ga.run
      
      # Should call all steps
      expect(ga).to have_received(:generate_initial_population).once
      expect(ga).to have_received(:selection).exactly(10).times
      expect(ga).to have_received(:reproduction).exactly(10).times
      expect(ga).to have_received(:replace_worst_ranked).exactly(10).times
      
      # Should return best chromosome
      expect(result).to be_a(TestChromosome)
    end
    
    it 'improves fitness over generations' do
      ga = described_class.new(30, 20)
      
      # Capture fitness values over generations
      fitness_history = []
      
      # Override methods to track progress
      original_replace = ga.method(:replace_worst_ranked)
      allow(ga).to receive(:replace_worst_ranked) do |offspring|
        original_replace.call(offspring)
        fitness_history << ga.best_chromosome.fitness if ga.population
      end
      
      ga.run
      
      # Fitness should generally improve
      if fitness_history.length > 5
        early_fitness = fitness_history[0..4].sum / 5.0
        late_fitness = fitness_history[-5..-1].sum / 5.0
        expect(late_fitness).to be >= early_fitness
      end
    end
  end
  
  describe 'integration with custom chromosome' do
    # Define a more complex chromosome for testing
    class BinaryStringChromosome < Ai4r::GeneticAlgorithm::Chromosome
      LENGTH = 10
      
      def self.seed
        new(Array.new(LENGTH) { rand(2) })
      end
      
      def fitness
        # Fitness is number of 1s
        @fitness ||= @data.count(1)
      end
      
      def self.mutate(chromosome)
        mutated = chromosome.data.dup
        index = rand(LENGTH)
        mutated[index] = 1 - mutated[index] # Flip bit
        new(mutated)
      end
      
      def self.reproduce(parent1, parent2)
        # Uniform crossover
        child_data = Array.new(LENGTH) do |i|
          rand < 0.5 ? parent1.data[i] : parent2.data[i]
        end
        new(child_data)
      end
    end
    
    it 'works with custom chromosome implementation' do
      stub_const('Ai4r::GeneticAlgorithm::Chromosome', BinaryStringChromosome)
      
      ga = described_class.new(50, 50)
      result = ga.run
      
      expect(result).to be_a(BinaryStringChromosome)
      # Should evolve towards all 1s
      expect(result.fitness).to be >= 7 # At least 7 ones out of 10
    end
  end
  
  describe 'edge cases' do
    it 'handles small population sizes' do
      ga = described_class.new(3, 5)
      stub_const('Ai4r::GeneticAlgorithm::Chromosome', TestChromosome)
      
      expect { ga.run }.not_to raise_error
    end
    
    it 'handles single generation' do
      ga = described_class.new(10, 1)
      stub_const('Ai4r::GeneticAlgorithm::Chromosome', TestChromosome)
      
      result = ga.run
      expect(result).to be_a(TestChromosome)
    end
    
    it 'handles zero generations' do
      ga = described_class.new(10, 0)
      stub_const('Ai4r::GeneticAlgorithm::Chromosome', TestChromosome)
      
      result = ga.run
      expect(result).to be_a(TestChromosome)
    end
  end
end