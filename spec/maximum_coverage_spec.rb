# frozen_string_literal: true

require 'spec_helper'
require 'ai4r'

# This spec aims to maximize code coverage by exercising as many code paths as possible

RSpec.describe 'AI4R Maximum Coverage' do
  # Exercise all data structures and utilities
  describe 'Data structures coverage' do
    it 'exercises DataSet thoroughly' do
      # Create datasets with various configurations
      ds1 = Ai4r::Data::DataSet.new(data_items: [[1, 2, 3], [4, 5, 6]])
      ds2 = Ai4r::Data::DataSet.new(data_items: [[1, 2, 3], [4, 5, 6]], data_labels: ['a', 'b', 'c'])
      
      # Exercise all methods
      expect(ds1.data_items).to be_an(Array)
      expect(ds2.data_labels).to eq(['a', 'b', 'c'])
      
      # Load from CSV
      csv_content = "a,b,c\n1,2,3\n4,5,6"
      allow(File).to receive(:read).and_return(csv_content)
      ds3 = Ai4r::Data::DataSet.new
      ds3.load_csv('dummy.csv')
      
      # Indexing
      expect(ds1[0]).to be_a(Ai4r::Data::DataSet)
      expect(ds1[0..1]).to be_a(Ai4r::Data::DataSet)
      
      # Adding items
      ds1 << [7, 8, 9]
      
      # Statistics
      expect { ds1.mean(0) }.not_to raise_error
      
      # Build domains
      domains = ds2.build_domains
      expect(domains).to be_an(Array)
      
      # Get column
      col = ds2.get_column(0)
      expect(col).to eq([1, 4])
      
      # Set data items
      ds2.set_data_items([[10, 11, 12]])
      expect(ds2.data_items.first).to eq([10, 11, 12])
    end

    it 'exercises Statistics module' do
      ds = Ai4r::Data::DataSet.new(data_items: (1..10).map { |i| [i, i*2, i*3] })
      
      # Test all statistical methods
      expect(Ai4r::Data::Statistics.mean(ds, 0)).to eq(5.5)
      expect(Ai4r::Data::Statistics.variance(ds, 0)).to be > 0
      expect(Ai4r::Data::Statistics.standard_deviation(ds, 0)).to be > 0
      expect(Ai4r::Data::Statistics.min(ds, 0)).to eq(1)
      expect(Ai4r::Data::Statistics.max(ds, 0)).to eq(10)
      expect(Ai4r::Data::Statistics.mode(ds, 0)).to eq(1) # All unique, returns first
    end

    it 'exercises Proximity module' do
      a = [1, 2, 3]
      b = [4, 5, 6]
      
      # Test all distance metrics
      expect(Ai4r::Data::Proximity.euclidean_distance(a, b)).to be > 0
      expect(Ai4r::Data::Proximity.squared_euclidean_distance(a, b)).to be > 0
      expect(Ai4r::Data::Proximity.manhattan_distance(a, b)).to eq(9)
      expect(Ai4r::Data::Proximity.chebyshev_distance(a, b)).to eq(3)
      expect(Ai4r::Data::Proximity.minkowski_distance(a, b, 3)).to be > 0
      expect(Ai4r::Data::Proximity.cosine_distance(a, b)).to be_between(0, 2)
      expect(Ai4r::Data::Proximity.hamming_distance(['a', 'b', 'c'], ['a', 'x', 'c'])).to eq(1)
      expect(Ai4r::Data::Proximity.binary_hamming_distance([1, 0, 1], [1, 1, 0])).to eq(2)
    end

    it 'exercises all helper modules' do
      # Parameterizable
      class TestParam
        include Ai4r::Data::Parameterizable
        parameters_info test_param: 'A test parameter'
      end
      
      obj = TestParam.new
      obj.set_parameters(test_param: 42)
      expect(obj.get_parameters[:test_param]).to eq(42)
      
      # Labels
      labels_data = Ai4r::Data::DataSet.new(data_items: [[1, 'A'], [2, 'B']], data_labels: ['num', 'class'])
      expect(labels_data.data_labels).to eq(['num', 'class'])
    end
  end

  # Exercise all classifiers
  describe 'Classifiers coverage' do
    let(:classification_data) do
      Ai4r::Data::DataSet.new(
        data_items: [
          ['sunny', 85, 85, 'weak', 'no'],
          ['sunny', 80, 90, 'strong', 'no'],
          ['overcast', 83, 78, 'weak', 'yes'],
          ['rain', 70, 96, 'weak', 'yes'],
          ['rain', 68, 80, 'weak', 'yes'],
          ['rain', 65, 70, 'strong', 'no'],
          ['overcast', 64, 65, 'strong', 'yes'],
          ['sunny', 72, 95, 'weak', 'no'],
          ['sunny', 69, 70, 'weak', 'yes'],
          ['rain', 75, 80, 'weak', 'yes']
        ],
        data_labels: ['outlook', 'temperature', 'humidity', 'wind', 'play_tennis']
      )
    end

    it 'exercises ID3 classifier' do
      id3 = Ai4r::Classifiers::ID3.new
      id3.build(classification_data)
      
      # Test evaluation
      expect(id3.eval(['sunny', 85, 85, 'weak'])).to eq('no')
      
      # Get rules
      rules = id3.get_rules
      expect(rules).to include('if')
      
      # Test with different parameters
      id3_custom = Ai4r::Classifiers::ID3.new
      id3_custom.set_parameters(min_samples: 2)
      id3_custom.build(classification_data)
    end

    it 'exercises Prism classifier' do
      prism = Ai4r::Classifiers::Prism.new
      prism.build(classification_data)
      
      result = prism.eval(['sunny', 85, 85, 'weak'])
      expect(['yes', 'no']).to include(result)
      
      rules = prism.get_rules
      expect(rules).to be_a(String)
    end

    it 'exercises OneR classifier' do
      oner = Ai4r::Classifiers::OneR.new
      oner.build(classification_data)
      
      result = oner.eval(['sunny', 85, 85, 'weak'])
      expect(['yes', 'no']).to include(result)
      
      rules = oner.get_rules
      expect(rules).to be_a(String)
    end

    it 'exercises ZeroR classifier' do
      zeror = Ai4r::Classifiers::ZeroR.new
      zeror.build(classification_data)
      
      # Always predicts majority class
      result = zeror.eval(['any', 'thing', 'goes', 'here'])
      expect(['yes', 'no']).to include(result)
    end

    it 'exercises NaiveBayes classifier' do
      nb = Ai4r::Classifiers::NaiveBayes.new
      nb.build(classification_data)
      
      result = nb.eval(['sunny', 85, 85, 'weak'])
      expect(['yes', 'no']).to include(result)
      
      # Get probability map
      probs = nb.get_probability_map(['sunny', 85, 85, 'weak'])
      expect(probs).to be_a(Hash)
      expect(probs.values.sum).to be_within(0.01).of(1.0)
    end

    it 'exercises IB1 classifier' do
      # Use numeric data for IB1
      numeric_data = Ai4r::Data::DataSet.new(
        data_items: [[1, 1, 'A'], [2, 2, 'A'], [8, 8, 'B'], [9, 9, 'B']],
        data_labels: ['x', 'y', 'class']
      )
      
      ib1 = Ai4r::Classifiers::IB1.new
      ib1.build(numeric_data)
      
      result = ib1.eval([1.5, 1.5])
      expect(result).to eq('A')
    end

    it 'exercises Hyperpipes classifier' do
      numeric_data = Ai4r::Data::DataSet.new(
        data_items: [[1, 2, 'A'], [2, 3, 'A'], [8, 9, 'B'], [9, 10, 'B']],
        data_labels: ['x', 'y', 'class']
      )
      
      hp = Ai4r::Classifiers::Hyperpipes.new
      hp.build(numeric_data)
      
      result = hp.eval([1.5, 2.5])
      expect(['A', 'B']).to include(result)
    end

    it 'exercises SimpleBayes' do
      if defined?(Ai4r::Classifiers::SimpleBayes)
        sb = Ai4r::Classifiers::SimpleBayes.new
        sb.build(classification_data)
        result = sb.eval(['sunny', 85, 85, 'weak'])
        expect(['yes', 'no']).to include(result)
      end
    end
  end

  # Exercise all clusterers
  describe 'Clusterers coverage' do
    let(:cluster_data) do
      Ai4r::Data::DataSet.new(
        data_items: [
          [1, 1], [1.5, 2], [2, 1.5],      # Cluster 1
          [8, 8], [8.5, 9], [9, 8.5],      # Cluster 2
          [1, 8], [1.5, 9], [2, 8.5]       # Cluster 3
        ],
        data_labels: ['x', 'y']
      )
    end

    it 'exercises K-Means clusterer' do
      kmeans = Ai4r::Clusterers::KMeans.new
      kmeans.set_parameters(max_iterations: 100, distance_function: :euclidean_distance)
      kmeans.build(cluster_data, 3)
      
      expect(kmeans.clusters.size).to eq(3)
      
      # Eval new point
      cluster_idx = kmeans.eval([1.2, 1.2])
      expect(cluster_idx).to be_between(0, 2)
      
      # Test different initialization methods
      kmeans2 = Ai4r::Clusterers::KMeans.new
      kmeans2.set_parameters(init_method: :random)
      kmeans2.build(cluster_data, 3)
    end

    it 'exercises BisectingKMeans' do
      bkmeans = Ai4r::Clusterers::BisectingKMeans.new
      bkmeans.build(cluster_data, 3)
      
      expect(bkmeans.clusters.size).to eq(3)
      cluster_idx = bkmeans.eval([1.2, 1.2])
      expect(cluster_idx).to be_between(0, 2)
    end

    it 'exercises hierarchical clusterers' do
      # Single linkage
      sl = Ai4r::Clusterers::SingleLinkage.new
      sl.build(cluster_data, 3)
      expect(sl.clusters.size).to eq(3)
      
      # Complete linkage
      cl = Ai4r::Clusterers::CompleteLinkage.new
      cl.build(cluster_data, 3)
      expect(cl.clusters.size).to eq(3)
      
      # Average linkage
      al = Ai4r::Clusterers::AverageLinkage.new
      al.build(cluster_data, 3)
      expect(al.clusters.size).to eq(3)
      
      # Centroid linkage
      cent = Ai4r::Clusterers::CentroidLinkage.new
      cent.build(cluster_data, 3)
      expect(cent.clusters.size).to eq(3)
      
      # Ward linkage
      ward = Ai4r::Clusterers::WardLinkage.new
      ward.build(cluster_data, 3)
      expect(ward.clusters.size).to eq(3)
      
      # Weighted average
      wal = Ai4r::Clusterers::WeightedAverageLinkage.new
      wal.build(cluster_data, 3)
      expect(wal.clusters.size).to eq(3)
      
      # Median linkage
      ml = Ai4r::Clusterers::MedianLinkage.new
      ml.build(cluster_data, 3)
      expect(ml.clusters.size).to eq(3)
    end

    it 'exercises DIANA clusterer' do
      diana = Ai4r::Clusterers::Diana.new
      diana.build(cluster_data, 3)
      expect(diana.clusters.size).to eq(3)
    end

    it 'exercises DBSCAN clusterer' do
      dbscan = Ai4r::Clusterers::DBSCAN.new
      dbscan.set_parameters(epsilon: 2.0, min_points: 2)
      dbscan.build(cluster_data)
      
      # DBSCAN finds its own number of clusters
      expect(dbscan.clusters.size).to be > 0
    end
  end

  # Exercise neural networks
  describe 'Neural Network coverage' do
    it 'exercises Backpropagation network' do
      # XOR problem
      nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 3, 1])
      nn.set_parameters(
        learning_rate: 0.5,
        momentum: 0.1,
        max_iterations: 100
      )
      
      # Train on XOR
      inputs = [[0, 0], [0, 1], [1, 0], [1, 1]]
      outputs = [[0], [1], [1], [0]]
      
      10.times do
        inputs.zip(outputs).each do |input, output|
          nn.train(input, output)
        end
      end
      
      # Test all XOR cases
      result = nn.eval([0, 0])
      expect(result.first).to be_between(0, 1)
      
      # Test network structure methods
      expect(nn.weights).to be_an(Array)
      expect(nn.activation_nodes).to be_an(Array)
    end

    it 'exercises Hopfield network' do
      patterns = [
        [1, -1, 1, -1, 1],
        [-1, 1, -1, 1, -1],
        [1, 1, -1, -1, 1]
      ]
      
      hopfield = Ai4r::NeuralNetwork::Hopfield.new(patterns)
      
      # Test pattern recall
      noisy_pattern = [1, -1, 1, -1, -1] # Last bit flipped
      result = hopfield.eval(noisy_pattern)
      expect(result).to be_an(Array)
      expect(result.size).to eq(5)
    end

    it 'exercises SOM' do
      som = Ai4r::Som::Som.new(5, 5, 2) # 5x5 map, 2D input
      
      # Train with some data
      data = 20.times.map { [rand, rand] }
      som.set_parameters(
        learning_rate: 0.5,
        radius: 2.0,
        epochs: 10
      )
      som.train(data)
      
      # Find BMU
      bmu = som.find_bmu([0.5, 0.5])
      expect(bmu).to be_an(Array)
      expect(bmu.size).to eq(2)
    end
  end

  # Exercise genetic algorithms
  describe 'Genetic Algorithm coverage' do
    it 'exercises basic GA' do
      # Simple maximization problem
      ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(
        10,  # population size
        5    # chromosome length
      ) do |chromosome|
        # Fitness = sum of genes
        chromosome.genes.sum
      end
      
      ga.set_parameters(
        max_generations: 10,
        mutation_rate: 0.1,
        crossover_rate: 0.8
      )
      
      initial_best = ga.best_chromosome.fitness
      result = ga.run
      final_best = result.fitness
      
      expect(final_best).to be >= initial_best
    end

    it 'exercises TSP chromosome' do
      cities = [[0, 0], [10, 0], [10, 10], [0, 10]]
      
      tsp = Ai4r::GeneticAlgorithm::TSPChromosome.new(cities)
      tsp.mutate  # Swap mutation
      
      # Test crossover
      tsp2 = Ai4r::GeneticAlgorithm::TSPChromosome.new(cities)
      offspring = tsp.crossover(tsp2)
      expect(offspring).to be_an(Array)
    end
  end

  # Exercise search algorithms
  describe 'Search algorithms coverage' do
    it 'exercises A* search' do
      # Simple grid
      grid = [
        [0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 1, 1, 0],
        [0, 0, 0, 0, 0]
      ]
      
      astar = Ai4r::Search::AStar.new(grid)
      
      # Find path
      path = astar.search([0, 0], [4, 4])
      expect(path).to be_an(Array)
      expect(path.first).to eq([0, 0])
      expect(path.last).to eq([4, 4])
      
      # Try with custom heuristic
      astar2 = Ai4r::Search::AStar.new(grid, :manhattan)
      path2 = astar2.search([0, 0], [4, 4])
      expect(path2).to be_an(Array)
    end

    it 'exercises Minimax search' do
      # Tic-tac-toe-like game
      game = Class.new do
        attr_accessor :board, :current_player
        
        def initialize(board = nil)
          @board = board || Array.new(9, nil)
          @current_player = 'X'
        end
        
        def get_possible_moves
          @board.each_index.select { |i| @board[i].nil? }
        end
        
        def make_move(move)
          new_game = self.class.new(@board.dup)
          new_game.board[move] = @current_player
          new_game.current_player = @current_player == 'X' ? 'O' : 'X'
          new_game
        end
        
        def evaluate
          # Simple evaluation
          lines = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],  # rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8],  # cols
            [0, 4, 8], [2, 4, 6]              # diagonals
          ]
          
          lines.each do |line|
            values = line.map { |i| @board[i] }
            return 100 if values.all? { |v| v == 'X' }
            return -100 if values.all? { |v| v == 'O' }
          end
          
          0  # Draw or ongoing
        end
      end.new
      
      minimax = Ai4r::Search::Minimax.new(game, depth: 5)
      move = minimax.best_move
      expect(move).to be_between(0, 8)
    end
  end

  # Exercise data preprocessing
  describe 'Data preprocessing coverage' do
    it 'exercises all data utilities' do
      # Create various datasets
      dataset = Ai4r::Data::DataSet.new(
        data_items: [
          [1, 100, 'A'],
          [2, 200, 'B'],
          [3, 300, 'A'],
          [4, 400, 'B'],
          [5, 500, 'A']
        ],
        data_labels: ['feature1', 'feature2', 'class']
      )
      
      # Test normalization
      if defined?(Ai4r::Data::Normalizer)
        normalizer = Ai4r::Data::Normalizer.new(dataset)
        normalized = normalizer.normalize(:min_max)
        expect(normalized).to be_a(Ai4r::Data::DataSet)
      end
      
      # Test feature extraction
      if defined?(Ai4r::Data::FeatureExtractor)
        extractor = Ai4r::Data::FeatureExtractor.new(dataset)
        features = extractor.extract_features
        expect(features).to be_an(Array)
      end
    end
  end

  # Exercise educational features
  describe 'Educational features coverage' do
    it 'exercises all educational methods' do
      # Tutorial tracks
      tracks = Ai4r::Data::EducationalExamples.tutorial_tracks
      expect(tracks).to have_key(:beginner)
      
      # Dataset creation
      iris = Ai4r::Data::DataSet.create_iris_dataset
      expect(iris).to be_a(Ai4r::Data::DataSet)
      
      weather = Ai4r::Data::DataSet.create_weather_dataset
      expect(weather).to be_a(Ai4r::Data::DataSet)
      
      xor = Ai4r::Data::DataSet.create_xor_dataset
      expect(xor).to be_a(Ai4r::Data::DataSet)
      
      # Clustering examples
      clustering_tutorial = Ai4r::Clusterers::EducationalExamples.beginner_tutorial
      expect(clustering_tutorial).to have_key(:title)
      
      # Neural network examples
      nn_tutorial = Ai4r::NeuralNetwork::EducationalExamples.beginner_tutorial
      expect(nn_tutorial).to have_key(:title)
    end
  end
end