# frozen_string_literal: true

require 'spec_helper'

# All modules are loaded through spec_helper -> ai4r.rb

RSpec.describe 'AI4R Core Algorithms' do
  # Test basic classifiers
  describe 'Basic Classifiers' do
    let(:simple_dataset) do
      Ai4r::Data::DataSet.new(
        data_items: [
          ['sunny', 'hot', 'high', 'weak', 'no'],
          ['sunny', 'hot', 'high', 'strong', 'no'],
          ['overcast', 'hot', 'high', 'weak', 'yes'],
          ['rain', 'mild', 'high', 'weak', 'yes']
        ],
        data_labels: ['outlook', 'temp', 'humidity', 'wind', 'play']
      )
    end

    it 'tests ID3 classifier' do
      classifier = Ai4r::Classifiers::ID3.new
      classifier.build(simple_dataset)
      result = classifier.eval(['sunny', 'hot', 'high', 'weak'])
      expect(['yes', 'no']).to include(result)
    end

    it 'tests OneR classifier' do
      classifier = Ai4r::Classifiers::OneR.new
      classifier.build(simple_dataset)
      result = classifier.eval(['sunny', 'hot', 'high', 'weak'])
      expect(['yes', 'no']).to include(result)
    end

    it 'tests ZeroR classifier' do
      classifier = Ai4r::Classifiers::ZeroR.new
      classifier.build(simple_dataset)
      result = classifier.eval(['anything', 'goes', 'here', 'really'])
      expect(['yes', 'no']).to include(result)
    end

    it 'tests NaiveBayes classifier' do
      classifier = Ai4r::Classifiers::NaiveBayes.new
      classifier.build(simple_dataset)
      result = classifier.eval(['sunny', 'hot', 'high', 'weak'])
      expect(['yes', 'no']).to include(result)
      
      # Test probability map
      probs = classifier.get_probability_map(['sunny', 'hot', 'high', 'weak'])
      expect(probs).to be_a(Hash)
    end
  end

  # Test numeric classifiers
  describe 'Numeric Classifiers' do
    let(:numeric_dataset) do
      Ai4r::Data::DataSet.new(
        data_items: [
          [1.0, 2.0, 'A'],
          [2.0, 3.0, 'A'],
          [3.0, 4.0, 'B'],
          [4.0, 5.0, 'B']
        ],
        data_labels: ['x', 'y', 'class']
      )
    end

    it 'tests IB1 classifier' do
      classifier = Ai4r::Classifiers::IB1.new
      classifier.build(numeric_dataset)
      result = classifier.eval([1.5, 2.5])
      expect(['A', 'B']).to include(result)
    end

    it 'tests Hyperpipes classifier' do
      classifier = Ai4r::Classifiers::Hyperpipes.new
      classifier.build(numeric_dataset)
      result = classifier.eval([1.5, 2.5])
      expect(['A', 'B']).to include(result)
    end

    it 'tests SimpleLinearRegression' do
      regression_data = Ai4r::Data::DataSet.new(
        data_items: [[1, 2], [2, 4], [3, 6], [4, 8]],
        data_labels: ['x', 'y']
      )
      
      classifier = Ai4r::Classifiers::SimpleLinearRegression.new
      classifier.build(regression_data)
      result = classifier.eval([5])
      expect(result).to be_within(1).of(10)
    end
  end

  # Test clusterers
  describe 'Clustering Algorithms' do
    let(:cluster_data) do
      Ai4r::Data::DataSet.new(
        data_items: [
          [1, 1], [1, 2], [2, 1],
          [8, 8], [8, 9], [9, 8]
        ],
        data_labels: ['x', 'y']
      )
    end

    it 'tests KMeans' do
      clusterer = Ai4r::Clusterers::KMeans.new
      clusterer.build(cluster_data, 2)
      expect(clusterer.clusters.size).to eq(2)
      
      # Test evaluation
      cluster_id = clusterer.eval([1.5, 1.5])
      expect(cluster_id).to be_between(0, 1)
    end

    it 'tests SingleLinkage' do
      clusterer = Ai4r::Clusterers::SingleLinkage.new
      clusterer.build(cluster_data, 2)
      expect(clusterer.clusters.size).to eq(2)
    end

    it 'tests CompleteLinkage' do
      clusterer = Ai4r::Clusterers::CompleteLinkage.new
      clusterer.build(cluster_data, 2)
      expect(clusterer.clusters.size).to eq(2)
    end

    it 'tests AverageLinkage' do
      clusterer = Ai4r::Clusterers::AverageLinkage.new
      clusterer.build(cluster_data, 2)
      expect(clusterer.clusters.size).to eq(2)
    end

    it 'tests DBSCAN' do
      clusterer = Ai4r::Clusterers::DBSCAN.new
      clusterer.build(cluster_data, { epsilon: 3, min_points: 2 })
      expect(clusterer.clusters.size).to be >= 1
    end

    it 'tests Diana' do
      clusterer = Ai4r::Clusterers::Diana.new
      clusterer.build(cluster_data, 2)
      expect(clusterer.clusters.size).to eq(2)
    end
  end

  # Test neural networks
  describe 'Neural Networks' do
    it 'tests Backpropagation' do
      nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])
      
      # Train XOR
      inputs = [[0, 0], [0, 1], [1, 0], [1, 1]]
      outputs = [[0], [1], [1], [0]]
      
      5.times do
        inputs.zip(outputs).each do |input, output|
          nn.train(input, output)
        end
      end
      
      # Test evaluation
      result = nn.eval([0, 0])
      expect(result).to be_an(Array)
      expect(result.first).to be_between(0, 1)
    end

    it 'tests Hopfield' do
      patterns = [[1, -1, 1], [-1, 1, -1]]
      nn = Ai4r::NeuralNetwork::Hopfield.new(patterns)
      
      result = nn.eval([1, -1, 1])
      expect(result).to eq([1, -1, 1])
    end
  end

  # Test genetic algorithms
  describe 'Genetic Algorithms' do
    it 'tests basic genetic search' do
      ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(10, 5)
      ga.run(5)
      
      best = ga.best_chromosome
      expect(best).not_to be_nil
    end

    it 'tests chromosome operations' do
      c1 = Ai4r::GeneticAlgorithm::Chromosome.new([1, 2, 3, 4, 5])
      c2 = Ai4r::GeneticAlgorithm::Chromosome.new([5, 4, 3, 2, 1])
      
      # Test fitness
      c1.fitness
      
      # Test crossover
      offspring = c1.crossover(c2)
      expect(offspring).to be_an(Array)
      expect(offspring.size).to eq(2)
      
      # Test mutation
      original = c1.genes.dup
      10.times { c1.mutate }
      # May or may not change, but should not error
    end
  end

  # Test search algorithms
  describe 'Search Algorithms' do
    it 'tests A* search' do
      grid = [
        [0, 0, 0],
        [0, 1, 0],
        [0, 0, 0]
      ]
      
      astar = Ai4r::Search::AStar.new(grid)
      path = astar.find_path([0, 0], [2, 2])
      
      expect(path).to be_an(Array)
      expect(path.first).to eq([0, 0])
      expect(path.last).to eq([2, 2])
    end
  end

  # Test data structures
  describe 'Data Structures' do
    it 'tests DataSet operations' do
      ds = Ai4r::Data::DataSet.new(
        data_items: [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
        data_labels: ['a', 'b', 'c']
      )
      
      # Test indexing
      expect(ds[0]).to be_a(Ai4r::Data::DataSet)
      expect(ds[0].data_items.first).to eq([1, 2, 3])
      
      # Test range indexing
      expect(ds[0..1]).to be_a(Ai4r::Data::DataSet)
      expect(ds[0..1].data_items.size).to eq(2)
      
      # Test adding items
      ds << [10, 11, 12]
      expect(ds.data_items.size).to eq(4)
      
      # Test statistics
      expect(ds.mean(0)).to eq(5.5)
      
      # Test build domains
      domains = ds.build_domains
      expect(domains[0]).to eq([1, 10])
    end

    it 'tests Statistics module' do
      ds = Ai4r::Data::DataSet.new(
        data_items: [[1], [2], [3], [4], [5]]
      )
      
      expect(Ai4r::Data::Statistics.mean(ds, 0)).to eq(3.0)
      expect(Ai4r::Data::Statistics.variance(ds, 0)).to eq(2.0)
      expect(Ai4r::Data::Statistics.standard_deviation(ds, 0)).to be_within(0.01).of(Math.sqrt(2))
      expect(Ai4r::Data::Statistics.min(ds, 0)).to eq(1)
      expect(Ai4r::Data::Statistics.max(ds, 0)).to eq(5)
    end

    it 'tests Proximity calculations' do
      expect(Ai4r::Data::Proximity.euclidean_distance([0, 0], [3, 4])).to eq(5.0)
      expect(Ai4r::Data::Proximity.manhattan_distance([0, 0], [3, 4])).to eq(7)
      expect(Ai4r::Data::Proximity.chebyshev_distance([0, 0], [3, 4])).to eq(4)
      expect(Ai4r::Data::Proximity.hamming_distance(['a', 'b'], ['a', 'c'])).to eq(1)
    end
  end

  # Test SOM
  describe 'Self-Organizing Maps' do
    it 'tests basic SOM' do
      som = Ai4r::Som::Som.new(3, 3, 2)
      data = [[0.1, 0.2], [0.8, 0.9], [0.5, 0.5]]
      
      som.train(data)
      
      bmu = som.find_bmu([0.1, 0.2])
      expect(bmu).to be_an(Array)
      expect(bmu.size).to eq(2)
    end
  end

  # Test Machine Learning extras
  describe 'Machine Learning Extras' do
    it 'tests HiddenMarkovModel' do
      hmm = Ai4r::MachineLearning::HiddenMarkovModel.new(
        [:sunny, :rainy],  # states
        [:walk, :shop, :clean]  # observations
      )
      
      # Set some probabilities
      hmm.set_transition_probability(:sunny, :sunny, 0.7)
      hmm.set_transition_probability(:sunny, :rainy, 0.3)
      hmm.set_emission_probability(:sunny, :walk, 0.6)
      
      # Train with sequences
      sequences = [
        { observations: [:walk, :shop], states: [:sunny, :sunny] }
      ]
      
      hmm.train(sequences)
      
      # Predict
      result = hmm.viterbi([:walk, :shop])
      expect(result).to be_an(Array)
    end
  end
end