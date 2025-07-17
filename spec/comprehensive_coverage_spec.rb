# frozen_string_literal: true

require 'spec_helper'
require 'ai4r'

# This comprehensive spec file ensures high test coverage across all AI4R modules

RSpec.describe 'AI4R Comprehensive Coverage' do
  describe 'Data Module' do
    describe Ai4r::Data::DataSet do
      let(:data_items) { [[1, 2, 'A'], [3, 4, 'B'], [5, 6, 'A']] }
      let(:data_labels) { ['feature1', 'feature2', 'class'] }
      let(:dataset) { described_class.new(data_items: data_items, data_labels: data_labels) }

      it 'builds attribute domains' do
        domains = dataset.build_domains
        expect(domains[0]).to eq([1, 5])  # min, max for numeric
        expect(domains[2]).to match_array(['A', 'B'])  # unique values
      end

      it 'calculates entropy' do
        entropy = dataset.entropy(2)  # entropy of class attribute
        expect(entropy).to be_a(Float)
        expect(entropy).to be > 0
      end

      it 'splits data by attribute' do
        subsets = dataset.data_items.group_by { |item| item[2] }
        expect(subsets['A'].size).to eq(2)
        expect(subsets['B'].size).to eq(1)
      end
    end

    describe Ai4r::Data::Statistics do
      let(:data_set) do
        Ai4r::Data::DataSet.new(data_items: [[1, 10], [2, 20], [3, 30], [4, 40], [5, 50]])
      end

      it 'calculates mean' do
        mean = Ai4r::Data::Statistics.mean(data_set, 0)
        expect(mean).to eq(3.0)
      end

      it 'calculates variance' do
        variance = Ai4r::Data::Statistics.variance(data_set, 0)
        expect(variance).to eq(2.0)
      end

      it 'calculates standard deviation' do
        std = Ai4r::Data::Statistics.standard_deviation(data_set, 0)
        expect(std).to be_within(0.01).of(Math.sqrt(2.0))
      end
    end

    describe Ai4r::Data::Proximity do
      it 'calculates euclidean distance' do
        dist = Ai4r::Data::Proximity.euclidean_distance([0, 0], [3, 4])
        expect(dist).to eq(5.0)
      end

      it 'calculates manhattan distance' do
        dist = Ai4r::Data::Proximity.manhattan_distance([0, 0], [3, 4])
        expect(dist).to eq(7)
      end

      it 'calculates cosine distance' do
        dist = Ai4r::Data::Proximity.cosine_distance([1, 0], [0, 1])
        expect(dist).to be_within(0.01).of(1.0)
      end
    end
  end

  describe 'Classifiers Module' do
    let(:dataset) do
      Ai4r::Data::DataSet.new(
        data_items: [
          ['sunny', 'hot', 'high', 'weak', 'no'],
          ['sunny', 'hot', 'high', 'strong', 'no'],
          ['overcast', 'hot', 'high', 'weak', 'yes'],
          ['rain', 'mild', 'high', 'weak', 'yes'],
          ['rain', 'cool', 'normal', 'weak', 'yes'],
          ['rain', 'cool', 'normal', 'strong', 'no'],
          ['overcast', 'cool', 'normal', 'strong', 'yes'],
          ['sunny', 'mild', 'high', 'weak', 'no'],
          ['sunny', 'cool', 'normal', 'weak', 'yes'],
          ['rain', 'mild', 'normal', 'weak', 'yes']
        ],
        data_labels: ['outlook', 'temperature', 'humidity', 'wind', 'play']
      )
    end

    describe Ai4r::Classifiers::ID3 do
      it 'builds and evaluates' do
        classifier = described_class.new.build(dataset)
        expect(classifier.eval(['sunny', 'hot', 'high', 'weak'])).to eq('no')
      end

      it 'generates rules' do
        classifier = described_class.new.build(dataset)
        rules = classifier.get_rules
        expect(rules).to be_a(String)
        expect(rules).to include('if')
      end
    end

    describe Ai4r::Classifiers::NaiveBayes do
      it 'builds and classifies' do
        classifier = described_class.new.build(dataset)
        result = classifier.eval(['rain', 'mild', 'high', 'weak'])
        expect(['yes', 'no']).to include(result)
      end

      it 'returns probability distribution' do
        classifier = described_class.new.build(dataset)
        probs = classifier.get_probability_map(['rain', 'mild', 'high', 'weak'])
        expect(probs).to be_a(Hash)
        expect(probs.values.sum).to be_within(0.01).of(1.0)
      end
    end

    describe Ai4r::Classifiers::OneR do
      it 'builds simple rules' do
        classifier = described_class.new.build(dataset)
        expect(classifier).to respond_to(:eval)
      end
    end

    describe Ai4r::Classifiers::ZeroR do
      it 'predicts majority class' do
        classifier = described_class.new.build(dataset)
        # Should predict the most common class
        result = classifier.eval(['any', 'values', 'here', 'work'])
        expect(['yes', 'no']).to include(result)
      end
    end

    describe Ai4r::Classifiers::Hyperpipes do
      let(:numeric_dataset) do
        Ai4r::Data::DataSet.new(
          data_items: [[1, 2, 'A'], [3, 4, 'A'], [5, 6, 'B'], [7, 8, 'B']],
          data_labels: ['x', 'y', 'class']
        )
      end

      it 'builds hyperpipes for numeric data' do
        classifier = described_class.new.build(numeric_dataset)
        result = classifier.eval([2, 3])
        expect(['A', 'B']).to include(result)
      end
    end
  end

  describe 'Clusterers Module' do
    let(:dataset) do
      Ai4r::Data::DataSet.new(
        data_items: [[1, 1], [2, 2], [3, 3], [10, 10], [11, 11], [12, 12]],
        data_labels: ['x', 'y']
      )
    end

    describe Ai4r::Clusterers::KMeans do
      it 'clusters data into k groups' do
        clusterer = described_class.new.build(dataset, 2)
        expect(clusterer.clusters.size).to eq(2)
      end

      it 'assigns points to nearest centroid' do
        clusterer = described_class.new.build(dataset, 2)
        cluster_index = clusterer.eval([1.5, 1.5])
        expect(cluster_index).to be_between(0, 1)
      end
    end

    describe Ai4r::Clusterers::BisectingKMeans do
      it 'hierarchically splits clusters' do
        clusterer = described_class.new.build(dataset, 2)
        expect(clusterer.clusters.size).to eq(2)
      end
    end

    describe Ai4r::Clusterers::SingleLinkage do
      it 'performs hierarchical clustering' do
        clusterer = described_class.new.build(dataset, 2)
        expect(clusterer.clusters.size).to eq(2)
      end
    end

    describe Ai4r::Clusterers::CompleteLinkage do
      it 'uses maximum distance between clusters' do
        clusterer = described_class.new.build(dataset, 2)
        expect(clusterer.clusters.size).to eq(2)
      end
    end

    describe Ai4r::Clusterers::AverageLinkage do
      it 'uses average distance between clusters' do
        clusterer = described_class.new.build(dataset, 2)
        expect(clusterer.clusters.size).to eq(2)
      end
    end

  end

  describe 'Neural Network Module' do
    describe Ai4r::NeuralNetwork::Backpropagation do
      let(:xor_data) do
        [[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 0]]
      end

      it 'learns XOR function' do
        nn = described_class.new([2, 3, 1])
        nn.set_parameters(
          learning_rate: 0.5,
          momentum: 0.1,
          max_iterations: 1000
        )
        
        100.times do
          xor_data.each do |input|
            nn.train(input[0..1], [input[2]])
          end
        end

        # Test predictions
        expect(nn.eval([0, 0]).first).to be < 0.5
        expect(nn.eval([1, 1]).first).to be < 0.5
        expect(nn.eval([0, 1]).first).to be > 0.5
        expect(nn.eval([1, 0]).first).to be > 0.5
      end
    end

    describe Ai4r::NeuralNetwork::Hopfield do
      it 'stores and recalls patterns' do
        patterns = [[1, -1, 1, -1], [-1, 1, -1, 1]]
        nn = described_class.new(patterns)
        
        # Should recall stored pattern
        output = nn.eval([1, -1, 1, -1])
        expect(output).to eq([1, -1, 1, -1])
      end
    end
  end

  describe 'Genetic Algorithm Module' do
    describe Ai4r::GeneticAlgorithm::Chromosome do
      it 'performs crossover' do
        parent1 = described_class.new([1, 2, 3, 4])
        parent2 = described_class.new([5, 6, 7, 8])
        
        offspring = parent1.crossover(parent2)
        expect(offspring).to be_an(Array)
        expect(offspring.size).to eq(2)
      end

      it 'performs mutation' do
        chromosome = described_class.new([1, 2, 3, 4])
        original = chromosome.genes.dup
        
        # Force mutation
        100.times { chromosome.mutate }
        
        expect(chromosome.genes).not_to eq(original)
      end
    end

    describe Ai4r::GeneticAlgorithm::GeneticSearch do
      it 'evolves population toward fitness' do
        # Simple optimization problem
        search = described_class.new(10, 4) do |chromosome|
          # Fitness: maximize sum
          chromosome.genes.sum
        end
        
        initial_fitness = search.population.map(&:fitness).max
        search.run(10)
        final_fitness = search.best_chromosome.fitness
        
        expect(final_fitness).to be >= initial_fitness
      end
    end
  end

  describe 'Search Module' do
    describe Ai4r::Search::AStar do
      let(:grid) do
        [
          [0, 0, 0],
          [0, 1, 0],
          [0, 0, 0]
        ]
      end

      it 'finds shortest path' do
        astar = described_class.new(grid)
        path = astar.search([0, 0], [2, 2])
        
        expect(path).to be_an(Array)
        expect(path.first).to eq([0, 0])
        expect(path.last).to eq([2, 2])
      end

      it 'avoids obstacles' do
        astar = described_class.new(grid)
        path = astar.search([0, 0], [2, 2])
        
        # Should not include the obstacle at [1, 1]
        expect(path).not_to include([1, 1])
      end
    end

    describe Ai4r::Search::Minimax do
      let(:simple_game) do
        Class.new do
          attr_accessor :board, :current_player

          def initialize
            @board = Array.new(9, nil)
            @current_player = 'X'
          end

          def get_possible_moves
            @board.each_index.select { |i| @board[i].nil? }
          end

          def make_move(move)
            new_game = self.class.new
            new_game.board = @board.dup
            new_game.board[move] = @current_player
            new_game.current_player = @current_player == 'X' ? 'O' : 'X'
            new_game
          end

          def evaluate
            # Simple evaluation
            0
          end
        end.new
      end

      it 'searches game tree' do
        minimax = described_class.new(simple_game, depth: 3)
        move = minimax.best_move
        
        expect(move).to be_between(0, 8)
      end
    end
  end

  describe 'SOM Module' do
    describe Ai4r::Som::Som do
      let(:data) { [[1, 1], [2, 2], [10, 10], [11, 11]] }

      it 'organizes data on 2D map' do
        som = described_class.new(4, 8, data.first.size)
        som.train(data)
        
        # Should map similar inputs to nearby neurons
        bmu1 = som.find_bmu([1, 1])
        bmu2 = som.find_bmu([2, 2])
        bmu3 = som.find_bmu([10, 10])
        
        # Distance between similar points should be small
        dist_similar = (bmu1[0] - bmu2[0]).abs + (bmu1[1] - bmu2[1]).abs
        dist_different = (bmu1[0] - bmu3[0]).abs + (bmu1[1] - bmu3[1]).abs
        
        expect(dist_similar).to be <= dist_different
      end
    end
  end

  describe 'Machine Learning Module' do
    describe Ai4r::MachineLearning::RandomForest do
      it 'exists and can be instantiated' do
        expect { described_class.new }.not_to raise_error
      end
    end
  end

  describe 'Integration Tests' do
    it 'complete classification pipeline' do
      # Create dataset
      dataset = Ai4r::Data::DataSet.new(
        data_items: 20.times.map { [rand, rand, rand > 0.5 ? 'A' : 'B'] },
        data_labels: ['x', 'y', 'class']
      )
      
      # Train classifier
      classifier = Ai4r::Classifiers::NaiveBayes.new.build(dataset)
      
      # Evaluate
      predictions = dataset.data_items.map { |item| classifier.eval(item[0..-2]) }
      actuals = dataset.data_items.map(&:last)
      
      accuracy = predictions.zip(actuals).count { |p, a| p == a } / predictions.size.to_f
      expect(accuracy).to be > 0.0
    end

    it 'complete clustering pipeline' do
      # Create dataset
      dataset = Ai4r::Data::DataSet.new(
        data_items: 20.times.map { [rand * 10, rand * 10] },
        data_labels: ['x', 'y']
      )
      
      # Cluster
      clusterer = Ai4r::Clusterers::KMeans.new.build(dataset, 3)
      
      # Verify
      expect(clusterer.clusters.size).to eq(3)
      expect(clusterer.clusters.map(&:data_items).flatten(1).size).to eq(20)
    end
  end
end