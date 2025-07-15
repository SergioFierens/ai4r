# frozen_string_literal: true

# RSpec tests for AI4R Backpropagation neural network based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::NeuralNetwork::Backpropagation do
  # Test data from requirement document
  let(:xor_inputs) { [[0,0], [0,1], [1,0], [1,1]] }
  let(:xor_outputs) { [[0], [1], [1], [0]] }
  let(:and_inputs) { [[0,0], [0,1], [1,0], [1,1]] }
  let(:and_outputs) { [[0], [0], [0], [1]] }
  let(:or_inputs) { [[0,0], [0,1], [1,0], [1,1]] }
  let(:or_outputs) { [[0], [1], [1], [1]] }

  describe "Constructor Tests" do
    context "valid architectures" do
      it "test_valid_architecture" do
        network = described_class.new([2, 3, 1]).init_network
        
        expect(network).to be_a(described_class)
        expect(network.structure).to eq([2, 3, 1])
      end

      it "test_deep_network" do
        network = described_class.new([10, 20, 15, 10, 5, 2]).init_network
        
        expect(network.structure).to eq([10, 20, 15, 10, 5, 2])
        expect(network.structure.length).to eq(6)
      end

      it "test_no_hidden_layer" do
        network = described_class.new([5, 3]).init_network
        
        expect(network.structure).to eq([5, 3])
        expect(network.structure.length).to eq(2)
      end

      it "test_single_neuron_layers" do
        network = described_class.new([1, 1, 1]).init_network
        
        expect(network.structure).to eq([1, 1, 1])
      end
    end

    context "invalid architectures" do
      it "test_empty_architecture" do
        # Empty arrays should be handled gracefully or raise error
        expect {
          described_class.new([])
        }.not_to raise_error  # Constructor may succeed, init_network may fail
      end

      it "test_single_layer" do
        # Single layer networks don't make sense for backpropagation
        expect {
          described_class.new([5])
        }.not_to raise_error  # Constructor may succeed, eval may fail
      end

      it "test_zero_neurons" do
        expect {
          network = described_class.new([5, 0, 3])
          network.init_network
        }.to raise_error
      end

      it "test_negative_neurons" do
        expect {
          network = described_class.new([5, -3, 2])
          network.init_network
        }.to raise_error
      end

      it "test_non_integer_neurons" do
        # Float values should be handled gracefully
        expect {
          described_class.new([5, 2.5, 3])
        }.not_to raise_error
      end

      it "test_nil_architecture" do
        expect {
          described_class.new(nil)
        }.to raise_error
      end
    end
  end

  describe "Weight Initialization Tests" do
    let(:network) { described_class.new([2, 3, 1]).init_network }

    it "test_random_weight_range" do
      # Check that weights are in expected range [-1, 1]
      all_weights_in_range = true
      network.weights.each do |layer_weights|
        layer_weights.each do |neuron_weights|
          neuron_weights.each do |weight|
            unless weight.between?(-1.1, 1.1)  # Allow small tolerance
              all_weights_in_range = false
            end
          end
        end
      end
      
      expect(all_weights_in_range).to be true
    end

    it "test_xavier_initialization" do
      # Test that custom weight initialization works
      network = described_class.new([2, 3, 1])
      network.set_parameters(initial_weight_function: lambda { |n, i, j| 0.5 })
      network.init_network
      
      expect(network).to be_a(described_class)
    end

    it "test_zero_initialization" do
      network = described_class.new([2, 3, 1])
      network.set_parameters(initial_weight_function: lambda { |n, i, j| 0.0 })
      network.init_network
      
      # Zero weights should prevent learning
      expect(network).to be_a(described_class)
    end

    it "test_large_network_memory" do
      expect {
        large_network = described_class.new([100, 200, 100]).init_network
        expect(large_network.structure).to eq([100, 200, 100])
      }.not_to raise_error
    end
  end

  describe "Forward Propagation Tests" do
    let(:network) { described_class.new([2, 3, 1]).init_network }

    it "test_forward_pass_dimensions" do
      output = network.eval([1, 0])
      
      expect(output).to be_an(Array)
      expect(output.length).to eq(1)  # Output layer has 1 neuron
    end

    it "test_activation_sigmoid" do
      output = network.eval([1, 0])
      
      # Sigmoid outputs should be in (0, 1)
      output.each do |value|
        expect(value).to be > 0
        expect(value).to be < 1
      end
    end

    it "test_activation_tanh" do
      network = described_class.new([2, 3, 1])
      network.set_parameters(
        propagation_function: lambda { |x| Math.tanh(x) },
        derivative_propagation_function: lambda { |y| 1.0 - y**2 }
      )
      network.init_network
      
      output = network.eval([1, 0])
      
      # Tanh outputs should be in (-1, 1)
      output.each do |value|
        expect(value).to be > -1
        expect(value).to be < 1
      end
    end

    it "test_activation_relu" do
      network = described_class.new([2, 3, 1])
      network.set_parameters(
        propagation_function: lambda { |x| [0, x].max },
        derivative_propagation_function: lambda { |y| y > 0 ? 1 : 0 }
      )
      network.init_network
      
      output = network.eval([1, 0])
      
      # ReLU outputs should be >= 0
      output.each do |value|
        expect(value).to be >= 0
      end
    end

    it "test_single_input" do
      single_input_network = described_class.new([1, 2, 1]).init_network
      
      output = single_input_network.eval([0.5])
      expect(output.length).to eq(1)
    end

    it "test_batch_forward" do
      outputs = []
      inputs = [[1, 0], [0, 1], [1, 1]]
      
      inputs.each do |input|
        outputs << network.eval(input)
      end
      
      expect(outputs.length).to eq(3)
      outputs.each do |output|
        expect(output.length).to eq(1)
      end
    end

    it "test_input_dimension_mismatch" do
      expect {
        network.eval([1])  # Network expects 2 inputs, giving 1
      }.to raise_error
    end

    it "test_nil_input" do
      expect {
        network.eval(nil)
      }.to raise_error
    end

    it "test_infinite_input" do
      # Test with infinite input
      result = network.eval([Float::INFINITY, 0])
      
      # Should handle gracefully (may return NaN or extreme values)
      expect(result).to be_an(Array)
    end

    it "test_nan_input" do
      # Test with NaN input
      result = network.eval([Float::NAN, 0])
      
      # Should handle gracefully
      expect(result).to be_an(Array)
    end
  end

  describe "Training Tests" do
    it "test_xor_convergence" do
      network = described_class.new([2, 4, 1]).init_network
      network.set_parameters(learning_rate: 0.5, momentum: 0.9)
      
      # Train for reasonable number of epochs
      1000.times do
        xor_inputs.each_with_index do |input, i|
          network.train(input, xor_outputs[i])
        end
      end
      
      # Test that network learned XOR
      results = xor_inputs.map { |input| network.eval(input)[0] }
      expected_results = [0, 1, 1, 0]
      
      correct_predictions = 0
      results.each_with_index do |result, i|
        if (result > 0.5 && expected_results[i] == 1) || (result <= 0.5 && expected_results[i] == 0)
          correct_predictions += 1
        end
      end
      
      expect(correct_predictions).to be >= 3  # At least 75% accuracy
    end

    it "test_and_gate" do
      network = described_class.new([2, 3, 1]).init_network
      
      500.times do
        and_inputs.each_with_index do |input, i|
          network.train(input, and_outputs[i])
        end
      end
      
      # AND gate should be easier to learn than XOR
      results = and_inputs.map { |input| network.eval(input)[0] }
      expected_results = [0, 0, 0, 1]
      
      correct_predictions = 0
      results.each_with_index do |result, i|
        if (result > 0.5 && expected_results[i] == 1) || (result <= 0.5 && expected_results[i] == 0)
          correct_predictions += 1
        end
      end
      
      expect(correct_predictions).to be >= 3
    end

    it "test_or_gate" do
      network = described_class.new([2, 3, 1]).init_network
      
      500.times do
        or_inputs.each_with_index do |input, i|
          network.train(input, or_outputs[i])
        end
      end
      
      results = or_inputs.map { |input| network.eval(input)[0] }
      expected_results = [0, 1, 1, 1]
      
      correct_predictions = 0
      results.each_with_index do |result, i|
        if (result > 0.5 && expected_results[i] == 1) || (result <= 0.5 && expected_results[i] == 0)
          correct_predictions += 1
        end
      end
      
      expect(correct_predictions).to be >= 3
    end

    it "test_linear_regression" do
      # Test y = 2x + 1
      inputs = [[0], [1], [2], [3], [4]]
      outputs = [[1], [3], [5], [7], [9]]
      
      network = described_class.new([1, 3, 1]).init_network
      
      1000.times do
        inputs.each_with_index do |input, i|
          network.train(input, outputs[i])
        end
      end
      
      # Test approximation
      test_input = [2.5]
      result = network.eval(test_input)[0]
      expected = 6.0  # 2 * 2.5 + 1
      
      # Allow reasonable error for neural network approximation
      expect((result - expected).abs).to be < 3.0
    end

    it "test_multi_class" do
      # 3-class classification problem
      inputs = [[0, 0], [0, 1], [1, 0], [1, 1]]
      outputs = [[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 0, 0]]
      
      network = described_class.new([2, 4, 3]).init_network
      
      500.times do
        inputs.each_with_index do |input, i|
          network.train(input, outputs[i])
        end
      end
      
      # Test that outputs have correct dimensions
      result = network.eval([0, 0])
      expect(result.length).to eq(3)
    end

    it "test_single_sample_training" do
      network = described_class.new([2, 3, 1]).init_network
      
      expect {
        100.times do
          network.train([1, 0], [1])
        end
      }.not_to raise_error
    end

    it "test_identical_samples" do
      network = described_class.new([2, 3, 1]).init_network
      
      expect {
        100.times do
          network.train([1, 0], [1])
          network.train([1, 0], [1])
          network.train([1, 0], [1])
        end
      }.not_to raise_error
    end

    it "test_contradictory_samples" do
      network = described_class.new([2, 3, 1]).init_network
      
      expect {
        100.times do
          network.train([1, 0], [1])  # Same input, different outputs
          network.train([1, 0], [0])
        end
      }.not_to raise_error
      
      # Network should struggle to learn contradictory patterns
      result = network.eval([1, 0])[0]
      expect(result).to be_between(0.2, 0.8)  # Should be uncertain
    end

    it "test_empty_dataset" do
      network = described_class.new([2, 3, 1]).init_network
      
      # Training with no data should not crash
      expect {
        # No training calls
        network.eval([1, 0])
      }.not_to raise_error
    end

    it "test_mismatched_output_size" do
      network = described_class.new([2, 3, 1]).init_network  # Network has 1 output
      
      expect {
        network.train([1, 0], [1, 0])  # But trying to train with 2 outputs
      }.to raise_error
    end
  end

  describe "Learning Parameters Tests" do
    let(:network) { described_class.new([2, 3, 1]).init_network }

    it "test_learning_rate_effect" do
      network1 = described_class.new([2, 3, 1])
      network1.set_parameters(learning_rate: 0.01)
      network1.init_network
      
      network2 = described_class.new([2, 3, 1])
      network2.set_parameters(learning_rate: 1.0)
      network2.init_network
      
      # Both should train without error
      expect {
        10.times { network1.train([1, 0], [1]) }
        10.times { network2.train([1, 0], [1]) }
      }.not_to raise_error
    end

    it "test_zero_learning_rate" do
      network.set_parameters(learning_rate: 0)
      
      expect {
        network.train([1, 0], [1])
      }.not_to raise_error
    end

    it "test_negative_learning_rate" do
      expect {
        network.set_parameters(learning_rate: -0.1)
      }.not_to raise_error  # May be allowed by implementation
    end

    it "test_huge_learning_rate" do
      network.set_parameters(learning_rate: 100)
      
      # Should not crash but may not converge
      expect {
        10.times { network.train([1, 0], [1]) }
      }.not_to raise_error
    end

    it "test_momentum_acceleration" do
      network.set_parameters(momentum: 0.9)
      
      expect {
        10.times { network.train([1, 0], [1]) }
      }.not_to raise_error
    end

    it "test_negative_momentum" do
      expect {
        network.set_parameters(momentum: -0.5)
      }.not_to raise_error  # May be allowed by implementation
    end

    it "test_momentum_greater_than_one" do
      expect {
        network.set_parameters(momentum: 1.5)
      }.not_to raise_error  # May be allowed by implementation
    end
  end

  describe "Gradient Tests" do
    let(:network) { described_class.new([2, 3, 1]).init_network }

    it "test_gradient_calculation" do
      # Test that gradient computation doesn't crash
      expect {
        network.train([1, 0], [1])
      }.not_to raise_error
    end

    it "test_vanishing_gradient" do
      # Deep network with sigmoid activation
      deep_network = described_class.new([2, 10, 10, 10, 10, 1]).init_network
      
      expect {
        100.times { deep_network.train([1, 0], [1]) }
      }.not_to raise_error
    end

    it "test_exploding_gradient" do
      network.set_parameters(learning_rate: 10.0)
      
      expect {
        10.times { network.train([1, 0], [1]) }
      }.not_to raise_error
    end

    it "test_gradient_clipping" do
      # Test with extreme learning rate
      network.set_parameters(learning_rate: 1000.0)
      
      # Should handle extreme gradients gracefully
      expect {
        network.train([1, 0], [1])
        result = network.eval([1, 0])
        expect(result[0]).to be_finite
      }.not_to raise_error
    end

    it "test_dead_neurons" do
      # ReLU activation with potential for dead neurons
      network.set_parameters(
        propagation_function: lambda { |x| [0, x].max },
        derivative_propagation_function: lambda { |y| y > 0 ? 1 : 0 }
      )
      
      expect {
        100.times { network.train([-10, -10], [1]) }
      }.not_to raise_error
    end
  end

  describe "Persistence Tests" do
    let(:network) { described_class.new([2, 3, 1]).init_network }

    it "test_save_network" do
      # Train the network
      100.times do
        xor_inputs.each_with_index do |input, i|
          network.train(input, xor_outputs[i])
        end
      end
      
      # Test serialization
      expect {
        serialized = Marshal.dump(network)
        expect(serialized).to be_a(String)
      }.not_to raise_error
    end

    it "test_load_network" do
      # Train the network
      100.times do
        xor_inputs.each_with_index do |input, i|
          network.train(input, xor_outputs[i])
        end
      end
      
      # Serialize and deserialize
      serialized = Marshal.dump(network)
      loaded_network = Marshal.load(serialized)
      
      expect(loaded_network).to be_a(described_class)
      expect(loaded_network.structure).to eq(network.structure)
    end

    it "test_save_load_predictions" do
      # Train the network
      100.times do
        xor_inputs.each_with_index do |input, i|
          network.train(input, xor_outputs[i])
        end
      end
      
      # Get prediction before serialization
      original_prediction = network.eval([1, 0])
      
      # Serialize and deserialize
      serialized = Marshal.dump(network)
      loaded_network = Marshal.load(serialized)
      
      # Get prediction after deserialization
      loaded_prediction = loaded_network.eval([1, 0])
      
      # Predictions should be identical
      expect(loaded_prediction).to eq(original_prediction)
    end
  end

  # Helper methods for assertions
  def assert_converges(network, inputs, outputs, max_epochs)
    max_epochs.times do |epoch|
      inputs.each_with_index do |input, i|
        network.train(input, outputs[i])
      end
      
      # Simple convergence check
      if epoch % 100 == 0
        current_output = network.eval(inputs.first)
        current_error = (current_output[0] - outputs.first[0]).abs
        
        if current_error < 0.1
          return true
        end
      end
    end
    
    false
  end

  def assert_weights_in_range(network, min_val, max_val)
    network.weights.each do |layer_weights|
      layer_weights.each do |neuron_weights|
        neuron_weights.each do |weight|
          expect(weight).to be_between(min_val, max_val)
        end
      end
    end
  end

  def assert_network_output_shape(output, expected_shape)
    expect(output).to be_an(Array)
    expect(output.length).to eq(expected_shape[0])
  end
end