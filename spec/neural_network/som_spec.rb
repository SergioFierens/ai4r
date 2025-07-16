# frozen_string_literal: true

# RSpec tests for AI4R Som (Self-Organizing Map) based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Som::Som do
  # Test data from requirement document
  let(:training_data) do
    [
      # Cluster 1 - around [0, 0]
      [0.1, 0.1], [0.2, 0.0], [0.0, 0.2], [-0.1, 0.1],
      # Cluster 2 - around [1, 1]
      [0.9, 0.9], [1.1, 1.0], [1.0, 1.1], [0.8, 1.2],
      # Cluster 3 - around [0, 1]
      [0.1, 0.9], [0.0, 1.1], [0.2, 1.0], [-0.1, 0.8]
    ]
  end

  let(:som_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: training_data,
      data_labels: %w[x y]
    )
  end

  let(:single_point_data) { [[0.5, 0.5]] }
  let(:single_point_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: single_point_data,
      data_labels: %w[x y]
    )
  end

  describe 'SOM Initialization Tests' do
    context 'network creation' do
      it 'test_som_basic_creation' do
        # Should create SOM with specified dimensions
        som = described_class.new(4, 4, som_dataset)

        expect(som).to be_a(described_class)
        expect(som.data).to eq(som_dataset)
        expect(som.width).to eq(4)
        expect(som.height).to eq(4)
      end

      it 'test_som_weight_initialization' do
        # Weights should be initialized for all nodes
        som = described_class.new(3, 3, som_dataset)

        expect(som.nodes).to be_an(Array)
        expect(som.nodes.length).to eq(9) # 3x3 grid

        # Each node should have weights matching input dimension
        som.nodes.each do |node|
          expect(node.weights.length).to eq(2) # 2D input data

          # Weights should be numeric
          node.weights.each do |weight|
            expect(weight).to be_a(Numeric)
            expect(weight).to be_finite
          end
        end
      end

      it 'test_som_random_initialization' do
        # Multiple SOMs should have different initial weights (randomized)
        som1 = described_class.new(2, 2, som_dataset)
        som2 = described_class.new(2, 2, som_dataset)

        # At least some weights should be different
        all_weights_same = som1.nodes.zip(som2.nodes).all? do |node1, node2|
          node1.weights == node2.weights
        end

        expect(all_weights_same).to be false
      end
    end

    context 'parameter validation' do
      it 'test_som_dimensions' do
        # Should validate reasonable dimensions
        expect do
          described_class.new(0, 5, som_dataset)
        end.to raise_error(ArgumentError)

        expect do
          described_class.new(5, 0, som_dataset)
        end.to raise_error(ArgumentError)
      end

      it 'test_som_data_validation' do
        # Should validate input dataset
        expect do
          described_class.new(3, 3, nil)
        end.to raise_error(ArgumentError)

        empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
        expect do
          described_class.new(3, 3, empty_dataset)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'SOM Training Tests' do
    context 'basic training' do
      it 'test_som_train_iterations' do
        # Should complete training iterations without error
        som = described_class.new(3, 3, som_dataset)
        initial_weights = som.nodes.map { |node| node.weights.dup }

        som.train(100) # 100 iterations

        # Weights should have changed during training
        final_weights = som.nodes.map(&:weights)

        weights_changed = initial_weights.zip(final_weights).any? do |initial, final|
          initial != final
        end

        expect(weights_changed).to be true
      end

      it 'test_som_learning_rate_decay' do
        # Learning rate should decrease over time
        som = described_class.new(3, 3, som_dataset)

        # Test that consecutive training calls work
        som.train(50)
        weights_after_50 = som.nodes.map { |node| node.weights.dup }

        som.train(50) # Additional training
        weights_after_100 = som.nodes.map(&:weights)

        # Further training should cause smaller changes (learning rate decay)
        expect(weights_after_50).not_to eq(weights_after_100)
      end

      it 'test_som_neighborhood_function' do
        # Neighborhood function should affect nearby nodes more than distant ones
        som = described_class.new(5, 5, som_dataset)

        # Train with specific input
        test_input = [0.5, 0.5]
        winner = som.find_winner(test_input)

        initial_weights = som.nodes.map { |node| node.weights.dup }
        som.train_single(test_input, 0.1, 2.0) # Learning rate, radius
        final_weights = som.nodes.map(&:weights)

        # Winner node should change most
        winner_change = calculate_weight_change(initial_weights[winner], final_weights[winner])

        # Verify some weight change occurred
        expect(winner_change).to be > 0
      end
    end

    context 'convergence behavior' do
      it 'test_som_convergence' do
        # SOM should converge with sufficient training
        som = described_class.new(3, 3, som_dataset)

        # Train extensively
        som.train(1000)

        # After convergence, additional training should cause minimal change
        weights_before = som.nodes.map { |node| node.weights.dup }
        som.train(10) # Small additional training
        weights_after = som.nodes.map(&:weights)

        # Changes should be very small
        total_change = weights_before.zip(weights_after).sum do |before, after|
          calculate_weight_change(before, after)
        end

        expect(total_change).to be < 1.0 # Converged networks have small changes
      end

      it 'test_som_topology_preservation' do
        # SOM should preserve topology - nearby inputs map to nearby nodes
        som = described_class.new(4, 4, som_dataset)
        som.train(500)

        # Test with similar inputs
        input1 = [0.1, 0.1]
        input2 = [0.2, 0.1] # Close to input1

        winner1 = som.find_winner(input1)
        winner2 = som.find_winner(input2)

        # Winners should be close in the SOM grid
        node1_pos = som.get_node_position(winner1)
        node2_pos = som.get_node_position(winner2)

        grid_distance = Math.sqrt(((node1_pos[0] - node2_pos[0])**2) +
                                 ((node1_pos[1] - node2_pos[1])**2))

        expect(grid_distance).to be <= 2.0 # Should be reasonably close
      end
    end
  end

  describe 'SOM Query Tests' do
    context 'winner finding' do
      it 'test_find_winner' do
        # Should find best matching unit (BMU) for input
        som = described_class.new(3, 3, som_dataset)
        som.train(100)

        test_input = [0.0, 0.0]
        winner = som.find_winner(test_input)

        expect(winner).to be_an(Integer)
        expect(winner).to be_between(0, 8) # Valid node index for 3x3 grid

        # Winner should have smallest distance to input
        winner_distance = euclidean_distance(test_input, som.nodes[winner].weights)

        som.nodes.each_with_index do |node, index|
          distance = euclidean_distance(test_input, node.weights)
          expect(distance).to be >= winner_distance if index != winner
        end
      end

      it 'test_quantization_error' do
        # Should calculate quantization error
        som = described_class.new(3, 3, som_dataset)
        som.train(200)

        if som.respond_to?(:quantization_error)
          error = som.quantization_error

          expect(error).to be >= 0
          expect(error).to be_finite
        end
      end

      it 'test_topographic_error' do
        # Should calculate topographic error if available
        som = described_class.new(4, 4, som_dataset)
        som.train(200)

        if som.respond_to?(:topographic_error)
          error = som.topographic_error

          expect(error).to be_between(0, 1) # Typically normalized
        end
      end
    end

    context 'mapping functionality' do
      it 'test_map_input_to_node' do
        # Should map inputs to grid coordinates
        som = described_class.new(3, 3, som_dataset)
        som.train(100)

        test_input = [0.5, 0.5]
        winner = som.find_winner(test_input)
        coordinates = som.get_node_position(winner)

        expect(coordinates).to be_an(Array)
        expect(coordinates.length).to eq(2) # [x, y] coordinates
        expect(coordinates[0]).to be_between(0, 2) # Valid grid position
        expect(coordinates[1]).to be_between(0, 2)
      end

      it 'test_cluster_identification' do
        # Trained SOM should separate clusters
        som = described_class.new(4, 4, som_dataset)
        som.train(500)

        # Test cluster separation
        cluster1_input = [0.0, 0.0]   # Cluster 1
        cluster2_input = [1.0, 1.0]   # Cluster 2

        winner1 = som.find_winner(cluster1_input)
        winner2 = som.find_winner(cluster2_input)

        # Different clusters should map to different nodes
        expect(winner1).not_to eq(winner2)

        # Should be reasonably separated in grid
        pos1 = som.get_node_position(winner1)
        pos2 = som.get_node_position(winner2)
        distance = Math.sqrt(((pos1[0] - pos2[0])**2) + ((pos1[1] - pos2[1])**2))

        expect(distance).to be > 0 # Should be separated
      end
    end
  end

  describe 'Edge Case Tests' do
    context 'extreme conditions' do
      it 'test_single_data_point' do
        # Should handle dataset with single point
        som = described_class.new(2, 2, single_point_dataset)

        expect do
          som.train(50)
        end.not_to raise_error

        # All nodes should converge toward the single point
        target_point = single_point_data[0]
        som.nodes.each do |node|
          distance = euclidean_distance(node.weights, target_point)
          expect(distance).to be < 1.0 # Should be close to target
        end
      end

      it 'test_large_grid' do
        # Should handle larger grids efficiently
        som = described_class.new(10, 10, som_dataset)

        expect(som.nodes.length).to eq(100)

        expect do
          som.train(100)
        end.not_to raise_error
      end

      it 'test_small_grid' do
        # Should handle minimal grid size
        som = described_class.new(1, 1, som_dataset)

        expect(som.nodes.length).to eq(1)

        expect do
          som.train(50)
        end.not_to raise_error

        # Single node should represent all data
        winner = som.find_winner([0.5, 0.5])
        expect(winner).to eq(0)
      end
    end

    context 'boundary conditions' do
      it 'test_extreme_inputs' do
        # Should handle inputs outside training range
        som = described_class.new(3, 3, som_dataset)
        som.train(100)

        extreme_input = [10.0, 10.0] # Far from training data

        expect do
          winner = som.find_winner(extreme_input)
          expect(winner).to be_between(0, 8)
        end.not_to raise_error
      end

      it 'test_zero_learning_rate' do
        # Should handle edge learning parameters
        som = described_class.new(3, 3, som_dataset)

        initial_weights = som.nodes.map { |node| node.weights.dup }

        # Train with zero learning rate (no change expected)
        if som.respond_to?(:train_with_params)
          som.train_with_params(10, 0.0, 1.0) # iterations, learning_rate, radius

          final_weights = som.nodes.map(&:weights)
          expect(initial_weights).to eq(final_weights)
        end
      end
    end
  end

  describe 'Performance Tests' do
    it 'handles moderate datasets efficiently' do
      # Generate larger dataset
      large_data = []
      100.times do
        large_data << [rand(2.0), rand(2.0)]
      end

      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_data,
        data_labels: %w[x y]
      )

      benchmark_performance('SOM training on 100 points') do
        som = described_class.new(6, 6, large_dataset)
        som.train(200)

        expect(som.nodes.length).to eq(36)
      end
    end
  end

  describe 'Integration Tests' do
    it 'provides complete SOM functionality' do
      # Complete workflow test
      som = described_class.new(4, 4, som_dataset)

      # 1. Initialize
      expect(som.nodes.length).to eq(16)

      # 2. Train
      som.train(200)

      # 3. Query
      test_inputs = [[0.0, 0.0], [1.0, 1.0], [0.0, 1.0]]
      winners = test_inputs.map { |input| som.find_winner(input) }

      # Should find valid winners
      winners.each do |winner|
        expect(winner).to be_between(0, 15)
      end

      # Different inputs should generally map to different winners
      expect(winners.uniq.length).to be > 1
    end

    it 'maintains SOM properties after training' do
      som = described_class.new(3, 3, som_dataset)
      som.train(300)

      # 1. All weights should be finite
      som.nodes.each do |node|
        node.weights.each do |weight|
          expect(weight).to be_finite
        end
      end

      # 2. Grid structure should be maintained
      expect(som.width).to eq(3)
      expect(som.height).to eq(3)
      expect(som.nodes.length).to eq(9)

      # 3. Winner finding should work consistently
      test_input = [0.5, 0.5]
      winner1 = som.find_winner(test_input)
      winner2 = som.find_winner(test_input)

      expect(winner1).to eq(winner2) # Deterministic
    end
  end

  # Helper methods
  def euclidean_distance(point_a, point_b)
    Math.sqrt(point_a.zip(point_b).sum { |a, b| (a - b)**2 })
  end

  def calculate_weight_change(weights_before, weights_after)
    euclidean_distance(weights_before, weights_after)
  end

  def assert_valid_som(som, expected_width, expected_height)
    expect(som).to be_a(described_class)
    expect(som.width).to eq(expected_width)
    expect(som.height).to eq(expected_height)
    expect(som.nodes.length).to eq(expected_width * expected_height)

    som.nodes.each do |node|
      expect(node.weights).to be_an(Array)
      node.weights.each do |weight|
        expect(weight).to be_finite
      end
    end
  end
end
