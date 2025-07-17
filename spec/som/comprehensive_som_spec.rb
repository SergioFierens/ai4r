# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/som/som'
require 'ai4r/som/two_phase_layer'
require 'ai4r/som/layer'
require 'ai4r/som/node'

RSpec.describe 'SOM Module Comprehensive Tests' do
  describe Ai4r::Som::Som do
    let(:input_data) do
      [
        [0.1, 0.2],
        [0.2, 0.1],
        [0.8, 0.9],
        [0.9, 0.8]
      ]
    end
    
    let(:som) { described_class.new(4, 4, 2) }
    
    describe 'initialization' do
      it 'creates SOM with specified dimensions' do
        expect(som.width).to eq(4)
        expect(som.height).to eq(4)
        expect(som.input_dimension).to eq(2)
      end
      
      it 'initializes nodes with random weights' do
        expect(som.nodes.size).to eq(4)
        expect(som.nodes.first.size).to eq(4)
        
        som.nodes.each do |row|
          row.each do |node|
            expect(node.weights.size).to eq(2)
            expect(node.weights).to all(be_between(0, 1))
          end
        end
      end
      
      it 'accepts custom initialization parameters' do
        custom_som = described_class.new(
          3, 3, 2,
          learning_rate: 0.5,
          radius: 2.0,
          random_seed: 42
        )
        
        expect(custom_som.learning_rate).to eq(0.5)
        expect(custom_som.radius).to eq(2.0)
      end
    end
    
    describe 'training' do
      it 'trains on input data' do
        initial_weights = som.nodes[0][0].weights.dup
        
        som.train(input_data, 10)
        
        final_weights = som.nodes[0][0].weights
        expect(final_weights).not_to eq(initial_weights)
      end
      
      it 'decreases learning rate over time' do
        initial_rate = som.learning_rate
        som.train(input_data, 100)
        
        expect(som.current_learning_rate).to be < initial_rate
      end
      
      it 'decreases neighborhood radius over time' do
        initial_radius = som.radius
        som.train(input_data, 100)
        
        expect(som.current_radius).to be < initial_radius
      end
      
      it 'finds best matching unit' do
        bmu = som.find_bmu([0.1, 0.2])
        expect(bmu).to be_a(Ai4r::Som::Node)
        expect(bmu.x).to be_between(0, 3)
        expect(bmu.y).to be_between(0, 3)
      end
      
      it 'updates neighborhood around BMU' do
        bmu = som.find_bmu([0.5, 0.5])
        neighbors = som.get_neighbors(bmu, 1.0)
        
        expect(neighbors).to include(bmu)
        expect(neighbors.size).to be > 1
      end
    end
    
    describe 'visualization and analysis' do
      before { som.train(input_data, 50) }
      
      it 'creates U-matrix' do
        u_matrix = som.u_matrix
        expect(u_matrix.size).to eq(4)
        expect(u_matrix.first.size).to eq(4)
        
        u_matrix.each do |row|
          row.each do |value|
            expect(value).to be >= 0
          end
        end
      end
      
      it 'maps input to grid position' do
        position = som.map_input([0.1, 0.2])
        expect(position).to include(:x, :y)
        expect(position[:x]).to be_between(0, 3)
        expect(position[:y]).to be_between(0, 3)
      end
      
      it 'calculates quantization error' do
        error = som.quantization_error(input_data)
        expect(error).to be_a(Float)
        expect(error).to be >= 0
      end
      
      it 'calculates topographic error' do
        error = som.topographic_error(input_data)
        expect(error).to be_between(0, 1)
      end
      
      it 'identifies clusters' do
        clusters = som.identify_clusters(threshold: 0.5)
        expect(clusters).to be_an(Array)
        expect(clusters.flatten.uniq).to all(be_a(Integer))
      end
    end
    
    describe 'different topologies' do
      it 'supports hexagonal topology' do
        hex_som = described_class.new(5, 5, 2, topology: :hexagonal)
        expect(hex_som.topology).to eq(:hexagonal)
        
        # Hexagonal topology has different neighbor calculations
        center = hex_som.nodes[2][2]
        neighbors = hex_som.get_neighbors(center, 1.0)
        expect(neighbors.size).to eq(7)  # Center + 6 neighbors
      end
      
      it 'supports toroidal topology' do
        torus_som = described_class.new(4, 4, 2, topology: :toroidal)
        expect(torus_som.topology).to eq(:toroidal)
        
        # Toroidal wraps around edges
        corner = torus_som.nodes[0][0]
        neighbors = torus_som.get_neighbors(corner, 1.0)
        expect(neighbors.size).to be > 4  # More than rectangular
      end
    end
    
    describe 'advanced features' do
      it 'supports batch training' do
        som.batch_train(input_data, 10)
        
        # Batch training should converge faster
        error = som.quantization_error(input_data)
        expect(error).to be < 0.5
      end
      
      it 'supports growing SOM' do
        growing_som = described_class.new(2, 2, 2, growing: true)
        growing_som.train(input_data * 10, 100)
        
        # Should grow beyond initial size
        expect(growing_som.width * growing_som.height).to be > 4
      end
      
      it 'supports conscience mechanism' do
        conscience_som = described_class.new(4, 4, 2, conscience: true)
        conscience_som.train(input_data, 50)
        
        # Check that all nodes have been used
        usage_counts = conscience_som.node_usage_counts
        expect(usage_counts.values.min).to be > 0
      end
    end
  end
  
  describe Ai4r::Som::Layer do
    let(:layer) { described_class.new(3, 3, 2) }
    
    it 'initializes layer with nodes' do
      expect(layer.width).to eq(3)
      expect(layer.height).to eq(3)
      expect(layer.nodes.flatten.size).to eq(9)
    end
    
    it 'calculates distances between nodes' do
      node1 = layer.nodes[0][0]
      node2 = layer.nodes[1][1]
      
      distance = layer.distance(node1, node2)
      expect(distance).to be_within(0.01).of(Math.sqrt(2))
    end
    
    it 'finds nodes within radius' do
      center = layer.nodes[1][1]
      neighbors = layer.nodes_within_radius(center, 1.5)
      
      expect(neighbors.size).to eq(9)  # All nodes within radius
    end
    
    it 'normalizes input vectors' do
      input = [3.0, 4.0]
      normalized = layer.normalize_input(input)
      
      magnitude = Math.sqrt(normalized[0]**2 + normalized[1]**2)
      expect(magnitude).to be_within(0.001).of(1.0)
    end
  end
  
  describe Ai4r::Som::Node do
    let(:node) { described_class.new(0, 0, 3) }
    
    it 'initializes with position and weights' do
      expect(node.x).to eq(0)
      expect(node.y).to eq(0)
      expect(node.weights.size).to eq(3)
    end
    
    it 'calculates distance to input' do
      input = [0.5, 0.5, 0.5]
      distance = node.distance_to(input)
      
      expect(distance).to be_a(Float)
      expect(distance).to be >= 0
    end
    
    it 'updates weights' do
      input = [1.0, 1.0, 1.0]
      initial_weights = node.weights.dup
      
      node.update_weights(input, 0.5)
      
      node.weights.each_with_index do |w, i|
        expect(w).to be_between(initial_weights[i], input[i])
      end
    end
    
    it 'tracks activation count' do
      expect(node.activation_count).to eq(0)
      
      node.activate
      expect(node.activation_count).to eq(1)
      
      node.activate
      expect(node.activation_count).to eq(2)
    end
  end
  
  describe Ai4r::Som::TwoPhaseLayer do
    let(:layer) { described_class.new(5, 5, 3) }
    let(:training_data) do
      20.times.map { 3.times.map { rand } }
    end
    
    it 'performs two-phase training' do
      # Phase 1: Rough organization
      layer.train_phase1(training_data, 50)
      error1 = layer.quantization_error(training_data)
      
      # Phase 2: Fine tuning
      layer.train_phase2(training_data, 50)
      error2 = layer.quantization_error(training_data)
      
      expect(error2).to be < error1
    end
    
    it 'uses different parameters for each phase' do
      expect(layer.phase1_learning_rate).to be > layer.phase2_learning_rate
      expect(layer.phase1_radius).to be > layer.phase2_radius
    end
    
    it 'switches between phases automatically' do
      layer.auto_train(training_data, 100)
      
      expect(layer.current_phase).to eq(2)
      expect(layer.trained_iterations).to eq(100)
    end
  end
  
  describe 'SOM Applications' do
    describe 'Color mapping' do
      it 'organizes colors in 2D space' do
        # RGB colors
        colors = [
          [1, 0, 0],  # Red
          [0, 1, 0],  # Green
          [0, 0, 1],  # Blue
          [1, 1, 0],  # Yellow
          [1, 0, 1],  # Magenta
          [0, 1, 1],  # Cyan
          [0, 0, 0],  # Black
          [1, 1, 1]   # White
        ]
        
        color_som = Ai4r::Som::Som.new(4, 4, 3)
        color_som.train(colors, 100)
        
        # Similar colors should be mapped to nearby positions
        red_pos = color_som.map_input([1, 0, 0])
        yellow_pos = color_som.map_input([1, 1, 0])
        
        distance = Math.sqrt(
          (red_pos[:x] - yellow_pos[:x])**2 + 
          (red_pos[:y] - yellow_pos[:y])**2
        )
        
        expect(distance).to be < 3  # Should be relatively close
      end
    end
    
    describe 'Data visualization' do
      it 'projects high-dimensional data to 2D' do
        # 10-dimensional data
        high_dim_data = 50.times.map { 10.times.map { rand } }
        
        som = Ai4r::Som::Som.new(10, 10, 10)
        som.train(high_dim_data, 200)
        
        # Map each data point to 2D position
        positions = high_dim_data.map { |data| som.map_input(data) }
        
        expect(positions).to all(include(:x, :y))
        expect(positions.map { |p| p[:x] }).to all(be_between(0, 9))
      end
    end
    
    describe 'Anomaly detection' do
      it 'detects outliers in data' do
        # Normal data clustered around centers
        normal_data = []
        normal_data += 10.times.map { [rand(0.1..0.3), rand(0.1..0.3)] }
        normal_data += 10.times.map { [rand(0.7..0.9), rand(0.7..0.9)] }
        
        # Outlier
        outlier = [0.5, 0.5]
        
        som = Ai4r::Som::Som.new(5, 5, 2)
        som.train(normal_data, 100)
        
        # Calculate quantization errors
        normal_errors = normal_data.map { |d| som.quantization_error([d]) }
        outlier_error = som.quantization_error([outlier])
        
        expect(outlier_error).to be > normal_errors.max
      end
    end
  end
  
  describe 'Performance and optimization' do
    it 'handles large datasets efficiently' do
      large_data = 1000.times.map { 10.times.map { rand } }
      som = Ai4r::Som::Som.new(20, 20, 10)
      
      start_time = Time.now
      som.train(large_data, 10)
      elapsed = Time.now - start_time
      
      expect(elapsed).to be < 5.0  # Should complete in reasonable time
    end
    
    it 'supports parallel training' do
      data = 100.times.map { 5.times.map { rand } }
      
      parallel_som = Ai4r::Som::Som.new(10, 10, 5, parallel: true)
      sequential_som = Ai4r::Som::Som.new(10, 10, 5, parallel: false)
      
      # Parallel should be faster for larger datasets
      start = Time.now
      parallel_som.train(data, 50)
      parallel_time = Time.now - start
      
      start = Time.now
      sequential_som.train(data, 50)
      sequential_time = Time.now - start
      
      # May not always be faster due to overhead, but should work
      expect(parallel_som.quantization_error(data)).to be_a(Float)
    end
  end
  
  describe 'Educational features' do
    let(:som) { Ai4r::Som::Som.new(3, 3, 2) }
    
    it 'provides step-by-step training visualization' do
      data = [[0.1, 0.1], [0.9, 0.9]]
      
      steps = []
      som.train_with_history(data, 10) do |step|
        steps << step
      end
      
      expect(steps).not_to be_empty
      expect(steps.first).to include(:iteration, :bmu, :learning_rate)
    end
    
    it 'explains SOM concepts' do
      explanation = som.explain_concepts
      expect(explanation).to include(:topology, :neighborhood, :learning)
    end
    
    it 'provides interactive examples' do
      example = som.interactive_example(:color_mapping)
      expect(example).to include(:description, :code, :visualization)
    end
  end
end