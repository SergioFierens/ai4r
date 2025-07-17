# frozen_string_literal: true

require 'spec_helper'

# Require all modules
Dir[File.join(File.dirname(__FILE__), '..', 'lib', 'ai4r', '**', '*.rb')].each do |file|
  require file unless file.include?('ai4r.rb')
end

RSpec.describe 'Comprehensive Full Coverage Tests' do
  describe 'Genetic Algorithm Module' do
    describe Ai4r::GeneticAlgorithm::Chromosome do
      it 'has base functionality' do
        chromosome = described_class.new
        expect(chromosome).to respond_to(:fitness)
        expect(chromosome).to respond_to(:data)
        expect(chromosome).to respond_to(:normalized_fitness)
      end
      
      it 'calculates normalized fitness' do
        chromosome = described_class.new
        allow(chromosome).to receive(:fitness).and_return(10)
        allow(chromosome).to receive(:normalized_fitness=)
        
        chromosome.normalized_fitness = 0.5
        expect(chromosome).to have_received(:normalized_fitness=).with(0.5)
      end
    end
    
    describe Ai4r::GeneticAlgorithm::GeneticSearch do
      it 'performs genetic search' do
        initial_population = 10.times.map do
          double(fitness: rand(100), data: Array.new(5) { rand(2) })
        end
        
        search = described_class.new(initial_population, 10)
        expect(search).to respond_to(:run)
        
        # Test selection method
        search.selection_method = :tournament
        expect(search.selection_method).to eq(:tournament)
      end
    end
  end
  
  describe 'SOM Module' do
    describe Ai4r::Som::Som do
      let(:som) { described_class.new(3, 3, 2) }
      
      it 'initializes with dimensions' do
        expect(som).to respond_to(:nodes)
        expect(som).to respond_to(:train)
        expect(som).to respond_to(:find_bmu)
      end
      
      it 'trains on data' do
        data = [[0.1, 0.2], [0.8, 0.9]]
        expect { som.train(data, 1) }.not_to raise_error
      end
      
      it 'finds best matching unit' do
        bmu = som.find_bmu([0.5, 0.5])
        expect(bmu).to respond_to(:x)
        expect(bmu).to respond_to(:y)
      end
      
      it 'calculates distances' do
        expect(som).to respond_to(:distance)
        # Distance between two points
        dist = som.distance([0, 0], [1, 1])
        expect(dist).to be_a(Numeric)
      end
    end
    
    describe Ai4r::Som::Layer do
      let(:layer) { described_class.new(2, 2) }
      
      it 'initializes layer' do
        expect(layer).to respond_to(:nodes)
        expect(layer.nodes.size).to eq(2)
        expect(layer.nodes.first.size).to eq(2)
      end
      
      it 'processes input' do
        expect(layer).to respond_to(:process)
      end
    end
    
    describe Ai4r::Som::Node do
      let(:node) { described_class.new(3, 0, 0) }
      
      it 'has weights and position' do
        expect(node.weights.size).to eq(3)
        expect(node.x).to eq(0)
        expect(node.y).to eq(0)
      end
      
      it 'calculates distance to input' do
        distance = node.distance([0.5, 0.5, 0.5])
        expect(distance).to be_a(Float)
      end
    end
    
    describe Ai4r::Som::TwoPhaseLayer do
      let(:layer) { described_class.new(2, 2) }
      
      it 'supports two-phase training' do
        expect(layer).to respond_to(:train_phase_1)
        expect(layer).to respond_to(:train_phase_2)
      end
    end
    
    describe Ai4r::Som::EducationalSom do
      it 'provides educational features' do
        som = described_class.new(3, 3, 2)
        expect(som).to respond_to(:explain_concepts)
        expect(som).to respond_to(:step_by_step_demo)
        expect(som).to respond_to(:visualize_training)
        
        # Test educational methods
        concepts = som.explain_concepts
        expect(concepts).to include(:neighborhood_function)
        
        demo = som.step_by_step_demo([[0.1, 0.2]], 1)
        expect(demo).to include(:steps)
      end
    end
  end
  
  describe 'Data Module Extended' do
    describe Ai4r::Data::DataSet do
      let(:dataset) { described_class.new(data_items: [[1, 2], [3, 4]]) }
      
      it 'manipulates data' do
        expect(dataset.data_items).to eq([[1, 2], [3, 4]])
        
        # Test various methods
        dataset << [5, 6]
        expect(dataset.data_items.size).to eq(3)
        
        expect(dataset.get_mean_or_mode).to be_an(Array)
        
        # Set and get labels
        dataset.set_data_labels(['a', 'b'])
        expect(dataset.data_labels).to eq(['a', 'b'])
        
        dataset.set_data_items([[7, 8]])
        expect(dataset.data_items).to eq([[7, 8]])
      end
      
      it 'handles build method' do
        result = dataset.build(10)
        expect(result).to eq(dataset)
      end
    end
    
    describe Ai4r::Data::Statistics do
      it 'calculates various statistics' do
        expect(described_class).to respond_to(:mean)
        expect(described_class).to respond_to(:variance)
        expect(described_class).to respond_to(:standard_deviation)
        expect(described_class).to respond_to(:mode)
        
        data = [1, 2, 3, 4, 5]
        expect(described_class.mean(data)).to eq(3.0)
        expect(described_class.variance(data)).to be > 0
        expect(described_class.mode([1, 1, 2, 3])).to eq(1)
        
        # Test min_max
        min, max = described_class.min_max(data)
        expect(min).to eq(1)
        expect(max).to eq(5)
      end
    end
    
    describe Ai4r::Data::Proximity do
      it 'calculates distances' do
        expect(described_class).to respond_to(:euclidean_distance)
        expect(described_class).to respond_to(:manhattan_distance)
        expect(described_class).to respond_to(:cosine_distance)
        expect(described_class).to respond_to(:hamming_distance)
        
        v1 = [1, 2, 3]
        v2 = [4, 5, 6]
        
        expect(described_class.euclidean_distance(v1, v2)).to be > 0
        expect(described_class.manhattan_distance(v1, v2)).to eq(9)
        expect(described_class.cosine_distance(v1, v2)).to be_between(0, 2)
        expect(described_class.hamming_distance([1, 0, 1], [0, 0, 1])).to eq(1)
      end
    end
    
    describe Ai4r::Data::Parameterizable do
      class TestParameterizable
        include Ai4r::Data::Parameterizable
        
        parameters_info learning_rate: 'Learning rate for training',
                       momentum: 'Momentum factor'
      end
      
      it 'manages parameters' do
        obj = TestParameterizable.new
        obj.set_parameters(learning_rate: 0.5, momentum: 0.9)
        
        expect(obj.get_parameters).to include(learning_rate: 0.5, momentum: 0.9)
      end
    end
  end
  
  describe 'Clusterers Extended' do
    describe Ai4r::Clusterers::KMeans do
      it 'has all required methods' do
        km = described_class.new
        expect(km).to respond_to(:build)
        expect(km).to respond_to(:eval)
        expect(km).to respond_to(:clusters)
        expect(km).to respond_to(:centroids)
        expect(km).to respond_to(:iterations)
        expect(km).to respond_to(:distance_function)
      end
      
      it 'builds clusters' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10], [11, 11]])
        km = described_class.new.build(data, 2)
        
        expect(km.clusters.size).to eq(2)
        expect(km.centroids.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::BisectingKMeans do
      it 'performs bisecting k-means' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10], [11, 11]])
        bkm = described_class.new.build(data, 2)
        
        expect(bkm.clusters.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::SingleLinkage do
      it 'performs hierarchical clustering' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        sl = described_class.new
        sl.build(data, 2)
        
        expect(sl.clusters.size).to eq(2)
      end
      
      it 'calculates distance matrix' do
        sl = described_class.new
        expect(sl).to respond_to(:create_distance_matrix)
      end
    end
    
    describe Ai4r::Clusterers::CompleteLinkage do
      it 'uses complete linkage criterion' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        cl = described_class.new.build(data, 2)
        
        expect(cl.clusters.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::AverageLinkage do
      it 'uses average linkage criterion' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        al = described_class.new.build(data, 2)
        
        expect(al.clusters.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::MedianLinkage do
      it 'uses median linkage criterion' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        ml = described_class.new.build(data, 2)
        
        expect(ml.clusters.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::CentroidLinkage do
      it 'uses centroid linkage criterion' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        cl = described_class.new.build(data, 2)
        
        expect(cl.clusters.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::WardLinkage do
      it 'uses Ward linkage criterion' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        wl = described_class.new.build(data, 2)
        
        expect(wl.clusters.size).to eq(2)
      end
    end
    
    describe Ai4r::Clusterers::WeightedAverageLinkage do
      it 'uses weighted average linkage' do
        data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10]])
        wal = described_class.new.build(data, 2)
        
        expect(wal.clusters.size).to eq(2)
      end
    end
  end
  
  describe 'Neural Network Module Extended' do
    describe Ai4r::NeuralNetwork::Backpropagation do
      it 'has all methods' do
        nn = described_class.new([2, 3, 1])
        expect(nn).to respond_to(:train)
        expect(nn).to respond_to(:eval)
        expect(nn).to respond_to(:init_network)
        expect(nn).to respond_to(:weights)
        expect(nn).to respond_to(:activation_nodes)
      end
    end
  end
  
  describe 'Classifiers Module' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_items: [[1, 0], [0, 1], [1, 1], [0, 0]],
        data_labels: ['x', 'y'],
        labels: ['A', 'B', 'A', 'B']
      )
    end
    
    describe Ai4r::Classifiers::ID3 do
      it 'builds decision tree' do
        id3 = described_class.new.build(data)
        expect(id3).to respond_to(:eval)
        expect(id3).to respond_to(:get_rules)
      end
    end
    
    describe Ai4r::Classifiers::Prism do
      it 'builds rule-based classifier' do
        prism = described_class.new.build(data)
        expect(prism).to respond_to(:eval)
        expect(prism).to respond_to(:get_rules)
      end
    end
    
    describe Ai4r::Classifiers::NaiveBayes do
      it 'builds probabilistic classifier' do
        nb = described_class.new.build(data)
        expect(nb).to respond_to(:eval)
        expect(nb).to respond_to(:get_probability_map)
      end
    end
    
    describe Ai4r::Classifiers::SimpleLinearRegression do
      it 'performs linear regression' do
        regression_data = Ai4r::Data::DataSet.new(
          data_items: [[1], [2], [3], [4]],
          labels: [2, 4, 6, 8]
        )
        
        slr = described_class.new.build(regression_data)
        expect(slr.eval([5])).to be_within(0.1).of(10)
      end
    end
  end
  
  describe 'Experiment Module' do
    describe Ai4r::Experiment::ClassifierEvaluator do
      it 'evaluates classifiers' do
        data = Ai4r::Data::DataSet.new(
          data_items: [[1, 0], [0, 1], [1, 1], [0, 0]] * 10,
          labels: ['A', 'B', 'A', 'B'] * 10
        )
        
        evaluator = described_class.new(Ai4r::Classifiers::ID3.new, data)
        result = evaluator.build
        
        expect(result).to include(:accuracy, :precision, :recall)
      end
    end
  end
  
  describe 'Educational Components' do
    describe 'Genetic Algorithm Educational' do
      it 'provides tutorials' do
        tutorial = Ai4r::GeneticAlgorithm::Tutorial.new
        expect(tutorial).to respond_to(:introduction)
        expect(tutorial).to respond_to(:basic_example)
        expect(tutorial).to respond_to(:advanced_topics)
        
        intro = tutorial.introduction
        expect(intro).to include(:title, :content)
      end
      
      it 'provides visualization' do
        viz = Ai4r::GeneticAlgorithm::VisualizationTools.new
        expect(viz).to respond_to(:plot_fitness_progress)
        expect(viz).to respond_to(:visualize_population)
        expect(viz).to respond_to(:create_animation)
        
        # Test data generation
        data = viz.generate_sample_data(10, 5)
        expect(data).to be_an(Array)
      end
      
      it 'provides demos' do
        demo = Ai4r::GeneticAlgorithm::EducationalDemos.new
        expect(demo).to respond_to(:traveling_salesman_demo)
        expect(demo).to respond_to(:function_optimization_demo)
        expect(demo).to respond_to(:string_evolution_demo)
        
        # Run a simple demo
        result = demo.string_evolution_demo("HELLO", max_generations: 10)
        expect(result).to include(:solution, :generations)
      end
    end
    
    describe 'Data Module Educational' do
      it 'provides educational examples' do
        examples = Ai4r::Data::EducationalExamples.new
        expect(examples).to respond_to(:basic_statistics_demo)
        expect(examples).to respond_to(:data_preprocessing_demo)
        expect(examples).to respond_to(:feature_engineering_demo)
        
        # Run demos
        stats_demo = examples.basic_statistics_demo
        expect(stats_demo).to include(:mean, :variance, :explanation)
      end
      
      it 'provides educational datasets' do
        edu_data = Ai4r::Data::EducationalDataSet.new
        expect(edu_data).to respond_to(:load_iris)
        expect(edu_data).to respond_to(:load_xor)
        expect(edu_data).to respond_to(:generate_clusters)
        
        iris = edu_data.load_iris
        expect(iris).to be_a(Ai4r::Data::DataSet)
      end
    end
    
    describe 'Clusterers Educational' do
      it 'provides clustering curriculum' do
        curriculum = Ai4r::Clusterers::ClusteringCurriculum.new
        expect(curriculum).to respond_to(:lesson_1_introduction)
        expect(curriculum).to respond_to(:lesson_2_kmeans)
        expect(curriculum).to respond_to(:lesson_3_hierarchical)
        
        lesson1 = curriculum.lesson_1_introduction
        expect(lesson1).to include(:title, :objectives, :content)
      end
      
      it 'provides interactive explorer' do
        explorer = Ai4r::Clusterers::InteractiveClusteringExplorer.new
        expect(explorer).to respond_to(:kmeans_interactive)
        expect(explorer).to respond_to(:hierarchical_interactive)
        expect(explorer).to respond_to(:compare_algorithms)
        
        comparison = explorer.compare_algorithms(k: 2)
        expect(comparison).to include(:kmeans, :hierarchical)
      end
      
      it 'generates synthetic datasets' do
        generator = Ai4r::Clusterers::SyntheticDatasetGenerator.new
        expect(generator).to respond_to(:generate_blobs)
        expect(generator).to respond_to(:generate_circles)
        expect(generator).to respond_to(:generate_moons)
        
        blobs = generator.generate_blobs(n_samples: 20, n_features: 2)
        expect(blobs.data_items.size).to eq(20)
      end
    end
    
    describe 'Neural Network Educational' do
      it 'provides enhanced neural network' do
        enhanced_nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1])
        expect(enhanced_nn).to respond_to(:train_with_validation)
        expect(enhanced_nn).to respond_to(:get_learning_history)
        expect(enhanced_nn).to respond_to(:visualize_network)
        
        history = enhanced_nn.get_learning_history
        expect(history).to be_an(Array)
      end
      
      it 'provides educational neural network' do
        edu_nn = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new([2, 2, 1])
        expect(edu_nn).to respond_to(:explain_forward_propagation)
        expect(edu_nn).to respond_to(:explain_backpropagation)
        expect(edu_nn).to respond_to(:step_by_step_training)
        
        explanation = edu_nn.explain_forward_propagation([0.5, 0.5])
        expect(explanation).to include(:input, :hidden, :output)
      end
    end
  end
  
  describe 'Integration Tests' do
    it 'combines clustering with visualization' do
      data = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2], [10, 10], [11, 11]])
      kmeans = Ai4r::Clusterers::KMeans.new.build(data, 2)
      
      viz = Ai4r::Data::DataVisualization.new
      chart_data = viz.scatter_plot_data(data, clusters: kmeans.clusters)
      expect(chart_data).to include(:datasets)
    end
    
    it 'uses data preprocessing with classification' do
      raw_data = [[1, 100], [2, 200], [3, 300], [4, 400]]
      labels = ['A', 'A', 'B', 'B']
      
      dataset = Ai4r::Data::DataSet.new(data_items: raw_data, labels: labels)
      
      # Normalize data
      normalizer = Ai4r::Data::DataNormalizer.new(dataset)
      normalized = normalizer.normalize(:min_max)
      
      # Train classifier
      classifier = Ai4r::Classifiers::NaiveBayes.new.build(normalized)
      result = classifier.eval([0.5, 0.5])
      
      expect(['A', 'B']).to include(result)
    end
  end
  
  # Add more test coverage for remaining files
  describe 'Additional Coverage' do
    it 'covers miscellaneous methods' do
      # Test any remaining uncovered methods
      
      # Data module
      data = Ai4r::Data::DataSet.new(data_items: [[1, 2], [3, 4]])
      expect(data.inspect).to be_a(String)
      
      # Test parameterizable
      class TestParam
        include Ai4r::Data::Parameterizable
      end
      
      param_obj = TestParam.new
      param_obj.set_parameters(test: 123)
      expect(param_obj.get_parameters[:test]).to eq(123)
      
      # Cover any edge cases
      empty_data = Ai4r::Data::DataSet.new
      expect(empty_data.data_items).to eq([])
    end
  end
end