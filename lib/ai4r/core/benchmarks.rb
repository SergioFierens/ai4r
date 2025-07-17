# frozen_string_literal: true

require_relative 'benchmarks/benchmark_runner'
require_relative 'benchmarks/classifier_bench'
require_relative 'benchmarks/search_bench'

module Ai4r
  module Core
    # Central module for all benchmarks
    module Benchmarks
      # Run all benchmarks
      def self.run_all
        puts "AI4R Comprehensive Benchmarks"
        puts "=" * 70
        
        run_classifier_benchmarks
        run_clustering_benchmarks
        run_neural_network_benchmarks
        run_search_benchmarks
      end
      
      # Run classifier benchmarks
      def self.run_classifier_benchmarks
        require 'ai4r/classifiers/classifier_evaluator'
        ClassifierBench.new.run
      end
      
      # Run clustering benchmarks  
      def self.run_clustering_benchmarks
        runner = BenchmarkRunner.new("Clustering Algorithms")
        
        # Generate test data
        small_data = generate_cluster_data(100)
        medium_data = generate_cluster_data(1000)
        large_data = generate_cluster_data(5000)
        
        algorithms = {
          "K-Means" => -> (data) { Ai4r::Clusterers::KMeans.new.build(data, 3) },
          "Single Linkage" => -> (data) { Ai4r::Clusterers::SingleLinkage.new.build(data, 3) },
          "Complete Linkage" => -> (data) { Ai4r::Clusterers::CompleteLinkage.new.build(data, 3) }
        }
        
        # Compare on medium dataset
        runner.compare(algorithms.transform_values { |algo| -> { algo.call(medium_data) } })
        
        # Scalability test for K-Means
        runner.scalability_test([100, 500, 1000, 2500, 5000]) do |size|
          data = generate_cluster_data(size)
          Ai4r::Clusterers::KMeans.new.build(data, 3)
        end
        
        runner.summary
      end
      
      # Run neural network benchmarks
      def self.run_neural_network_benchmarks
        runner = BenchmarkRunner.new("Neural Networks")
        
        # XOR problem
        xor_data = [
          [[0, 0], [0]],
          [[0, 1], [1]],
          [[1, 0], [1]],
          [[1, 1], [0]]
        ]
        
        architectures = {
          "Small (2-3-1)" => [2, 3, 1],
          "Medium (2-5-3-1)" => [2, 5, 3, 1],
          "Large (2-10-5-1)" => [2, 10, 5, 1]
        }
        
        runner.compare(architectures.transform_values do |structure|
          -> {
            nn = Ai4r::NeuralNetwork::Backpropagation.new(structure)
            100.times do
              xor_data.each { |input, output| nn.train(input, output) }
            end
          }
        end)
        
        runner.summary
      end
      
      # Run search algorithm benchmarks
      def self.run_search_benchmarks
        SearchBench.new.run
      end
      
      private
      
      def self.generate_cluster_data(size)
        points_per_cluster = size / 3
        data_items = []
        
        # Generate 3 clusters
        [[0, 0], [10, 10], [20, 0]].each do |center|
          points_per_cluster.times do
            point = center.map { |c| c + rand(-2.0..2.0) }
            data_items << point
          end
        end
        
        Ai4r::Data::DataSet.new(data_items: data_items)
      end
    end
  end
end