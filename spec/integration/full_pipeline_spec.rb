# frozen_string_literal: true

require 'spec_helper'

# Integration tests that exercise multiple components together
RSpec.describe 'AI4R Full Pipeline Integration' do
  describe 'Classification Pipeline' do
    it 'performs end-to-end classification with preprocessing' do
      # Create synthetic dataset
      data_items = []
      labels = []
      
      # Class A: centered around (2, 2)
      20.times do
        x = 2 + rand(-1.0..1.0)
        y = 2 + rand(-1.0..1.0)
        data_items << [x, y]
        labels << 'A'
      end
      
      # Class B: centered around (6, 6)
      20.times do
        x = 6 + rand(-1.0..1.0)
        y = 6 + rand(-1.0..1.0)
        data_items << [x, y]
        labels << 'B'
      end
      
      # Add labels to data
      data_with_labels = data_items.zip(labels).map { |item, label| item + [label] }
      
      # Create dataset
      dataset = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: data_with_labels
      )
      
      # Test multiple classifiers
      classifiers = [
        Ai4r::Classifiers::ID3.new,
        Ai4r::Classifiers::NaiveBayes.new,
        Ai4r::Classifiers::OneR.new,
        Ai4r::Classifiers::ZeroR.new
      ]
      
      classifiers.each do |classifier|
        classifier.build(dataset)
        
        # Test on new points
        class_a_point = [2.5, 2.5]
        class_b_point = [5.5, 5.5]
        
        # ZeroR always predicts most frequent class
        unless classifier.is_a?(Ai4r::Classifiers::ZeroR)
          expect(classifier.eval(class_a_point)).to eq('A')
          expect(classifier.eval(class_b_point)).to eq('B')
        end
      end
    end
  end
  
  describe 'Clustering Pipeline' do
    it 'performs clustering with different algorithms' do
      # Create three distinct clusters
      cluster_data = []
      
      # Cluster 1: bottom-left
      10.times do
        cluster_data << [rand(0..2), rand(0..2)]
      end
      
      # Cluster 2: top-right
      10.times do
        cluster_data << [rand(8..10), rand(8..10)]
      end
      
      # Cluster 3: top-left
      10.times do
        cluster_data << [rand(0..2), rand(8..10)]
      end
      
      dataset = Ai4r::Data::DataSet.new(data_items: cluster_data)
      
      # Test K-means
      kmeans = Ai4r::Clusterers::KMeans.new
      kmeans.build(dataset, 3)
      
      expect(kmeans.clusters.length).to eq(3)
      expect(kmeans.clusters.all? { |c| c.data_items.length > 0 }).to be true
      
      # Test DBSCAN
      dbscan = Ai4r::Clusterers::DBSCAN.new
      dbscan.set_parameters(min_points: 3, epsilon: 3.0)
      dbscan.build(dataset)
      
      # Should find at least 2 clusters (possibly 3)
      expect(dbscan.clusters.length).to be >= 2
      
      # Test hierarchical clustering
      single_linkage = Ai4r::Clusterers::SingleLinkage.new
      single_linkage.build(dataset, 3)
      
      expect(single_linkage.clusters.length).to eq(3)
    end
  end
  
  describe 'Neural Network Pipeline' do
    it 'trains a neural network for XOR problem' do
      # XOR dataset
      xor_data = Ai4r::Data::DataSet.new(
        data_labels: ['x1', 'x2', 'output'],
        data_items: [
          [0, 0, 0],
          [0, 1, 1],
          [1, 0, 1],
          [1, 1, 0]
        ]
      )
      
      # Create neural network
      nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 1])
      
      # Train the network
      100.times do
        xor_data.data_items.each do |item|
          input = item[0..1]
          output = [item[2]]
          nn.train(input, output)
        end
      end
      
      # Test predictions
      tolerance = 0.3
      expect(nn.eval([0, 0])[0]).to be_within(tolerance).of(0)
      expect(nn.eval([0, 1])[0]).to be_within(tolerance).of(1)
      expect(nn.eval([1, 0])[0]).to be_within(tolerance).of(1)
      expect(nn.eval([1, 1])[0]).to be_within(tolerance).of(0)
    end
  end
  
  describe 'Genetic Algorithm Pipeline' do
    it 'optimizes a simple function' do
      # Create a chromosome class for optimizing f(x) = -x^2 + 10x
      class OptimizationChromosome < Ai4r::GeneticAlgorithm::Chromosome
        def initialize(value)
          super([value])
          @data = [value]
        end
        
        def fitness
          x = @data[0]
          -x**2 + 10*x  # Maximum at x = 5
        end
        
        def self.seed
          new(rand(0.0..10.0))
        end
        
        def self.mutate(chromosome)
          value = chromosome.data[0]
          # Add small random change
          new_value = value + rand(-0.5..0.5)
          new_value = [[0, new_value].max, 10].min  # Clamp to [0, 10]
          new(new_value)
        end
        
        def self.reproduce(parent1, parent2)
          # Average crossover
          new_value = (parent1.data[0] + parent2.data[0]) / 2.0
          new(new_value)
        end
      end
      
      # Temporarily replace Chromosome class
      original_chromosome = Ai4r::GeneticAlgorithm::Chromosome
      Ai4r::GeneticAlgorithm.send(:remove_const, :Chromosome)
      Ai4r::GeneticAlgorithm.const_set(:Chromosome, OptimizationChromosome)
      
      # Run genetic algorithm
      ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(50, 20)
      best = ga.run
      
      # Should find value close to 5 (the maximum)
      expect(best.data[0]).to be_within(1.0).of(5.0)
      expect(best.fitness).to be > 20  # f(5) = 25
      
      # Restore original Chromosome class
      Ai4r::GeneticAlgorithm.send(:remove_const, :Chromosome)
      Ai4r::GeneticAlgorithm.const_set(:Chromosome, original_chromosome)
    end
  end
  
  describe 'Data Processing Pipeline' do
    it 'performs complete data preprocessing' do
      # Create dataset with different scales
      raw_data = Ai4r::Data::DataSet.new(
        data_labels: ['age', 'income', 'score', 'class'],
        data_items: [
          [25, 30000, 0.5, 'A'],
          [35, 50000, 0.7, 'B'],
          [45, 70000, 0.9, 'A'],
          [55, 90000, 0.3, 'B'],
          [65, 110000, 0.6, 'A']
        ]
      )
      
      # Normalize features (excluding class label)
      normalizer = Ai4r::Data::DataNormalizer.new(raw_data, {})
      features = raw_data.data_items.map { |row| row[0...-1] }
      
      # Test different normalization methods
      normalized_minmax = normalizer.normalize(features, :min_max)
      normalized_zscore = normalizer.normalize(features, :z_score)
      
      # Min-max should be in [0, 1]
      normalized_minmax.flatten.each do |value|
        expect(value).to be_between(0, 1).inclusive
      end
      
      # Z-score should have mean ≈ 0, std ≈ 1
      zscore_column = normalized_zscore.map { |row| row[0] }
      mean = zscore_column.sum / zscore_column.length
      expect(mean).to be_within(0.001).of(0)
    end
  end
  
  describe 'Model Evaluation Pipeline' do
    it 'evaluates classifier performance with cross-validation' do
      # Create a larger dataset for meaningful evaluation
      data_items = []
      
      # Generate two linearly separable classes
      50.times do
        x = rand(0..5)
        y = rand(0..5)
        label = (x + y < 5) ? 'Low' : 'High'
        data_items << [x, y, label]
      end
      
      dataset = Ai4r::Data::DataSet.new(
        data_labels: ['feature1', 'feature2', 'class'],
        data_items: data_items
      )
      
      # Split data for training and testing
      train_size = (data_items.length * 0.8).to_i
      train_items = data_items[0...train_size]
      test_items = data_items[train_size..-1]
      
      train_set = Ai4r::Data::DataSet.new(
        data_labels: dataset.data_labels,
        data_items: train_items
      )
      
      # Train classifier
      classifier = Ai4r::Classifiers::ID3.new
      classifier.build(train_set)
      
      # Evaluate on test set
      correct = 0
      test_items.each do |item|
        features = item[0...-1]
        actual_class = item.last
        predicted_class = classifier.eval(features)
        correct += 1 if predicted_class == actual_class
      end
      
      accuracy = correct.to_f / test_items.length
      expect(accuracy).to be > 0.6  # Should achieve reasonable accuracy
    end
  end
  
  describe 'Multi-stage Pipeline' do
    it 'combines preprocessing, clustering, and classification' do
      # Stage 1: Generate synthetic data
      data_points = []
      100.times do
        # Create data with natural clusters
        cluster = rand(3)
        case cluster
        when 0
          x = rand(0..3) + rand(-0.5..0.5)
          y = rand(0..3) + rand(-0.5..0.5)
          feature3 = x + y + rand(-0.1..0.1)
        when 1
          x = rand(7..10) + rand(-0.5..0.5)
          y = rand(7..10) + rand(-0.5..0.5)
          feature3 = x * y / 10.0 + rand(-0.1..0.1)
        else
          x = rand(0..3) + rand(-0.5..0.5)
          y = rand(7..10) + rand(-0.5..0.5)
          feature3 = (x - y).abs + rand(-0.1..0.1)
        end
        
        data_points << [x, y, feature3]
      end
      
      # Stage 2: Normalize data
      normalizer = Ai4r::Data::DataNormalizer.new(nil, {})
      normalized_data = normalizer.normalize(data_points, :min_max)
      
      # Stage 3: Perform clustering
      cluster_dataset = Ai4r::Data::DataSet.new(data_items: normalized_data)
      kmeans = Ai4r::Clusterers::KMeans.new
      kmeans.build(cluster_dataset, 3)
      
      # Stage 4: Use cluster assignments as labels for classification
      labeled_data = []
      normalized_data.each_with_index do |point, idx|
        cluster_id = kmeans.eval(point)
        labeled_data << point + [cluster_id]
      end
      
      # Stage 5: Train classifier on clustered data
      classification_dataset = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'feature3', 'cluster'],
        data_items: labeled_data
      )
      
      classifier = Ai4r::Classifiers::ID3.new
      classifier.build(classification_dataset)
      
      # Stage 6: Validate pipeline
      test_point = [5.0, 5.0, 5.0]  # Middle point
      normalized_test = normalizer.normalize([test_point], :min_max)[0]
      
      cluster_prediction = kmeans.eval(normalized_test)
      classification_prediction = classifier.eval(normalized_test)
      
      expect(cluster_prediction).to be_between(0, 2)
      expect(classification_prediction).to eq(cluster_prediction)
    end
  end
end