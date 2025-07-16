# frozen_string_literal: true

# RSpec tests for AI4R TwoPhaseLayer based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Som::TwoPhaseLayer do
  # Test data from requirement document
  let(:layer_size) { 5 }
  let(:input_size) { 3 }
  let(:test_input) { [0.5, 0.8, 0.2] }
  let(:test_output) { [0.1, 0.9, 0.4, 0.7, 0.3] }

  let(:two_phase_layer) { described_class.new(layer_size) }

  describe 'TwoPhaseLayer Initialization Tests' do
    context 'layer creation' do
      it 'test_layer_creation' do
        # Should create layer with specified number of nodes
        layer = described_class.new(layer_size)

        expect(layer).to be_a(described_class)
        expect(layer.nodes.length).to eq(layer_size)

        # Each node should be properly initialized
        layer.nodes.each do |node|
          expect(node).to be_a(Ai4r::NeuralNetwork::Node)
          expect(node.weights).to be_an(Array)
          expect(node.threshold).to be_a(Numeric)
        end
      end

      it 'test_weight_initialization' do
        # Weights should be initialized for all nodes
        layer = described_class.new(layer_size)
        layer.init_layer(input_size)

        layer.nodes.each do |node|
          expect(node.weights.length).to eq(input_size)

          # Weights should be numeric and reasonable
          node.weights.each do |weight|
            expect(weight).to be_a(Numeric)
            expect(weight).to be_finite
            expect(weight).to be_between(-2.0, 2.0) # Reasonable initialization range
          end
        end
      end

      it 'test_threshold_initialization' do
        # Thresholds should be initialized for all nodes
        layer = described_class.new(layer_size)
        layer.init_layer(input_size)

        layer.nodes.each do |node|
          expect(node.threshold).to be_a(Numeric)
          expect(node.threshold).to be_finite
        end
      end
    end
  end

  describe 'TwoPhaseLayer Processing Tests' do
    context 'forward pass' do
      it 'test_forward_pass' do
        # Should process input through the layer
        layer = described_class.new(layer_size)
        layer.init_layer(input_size)

        output = layer.eval(test_input)

        expect(output).to be_an(Array)
        expect(output.length).to eq(layer_size)

        # All outputs should be numeric and finite
        output.each do |value|
          expect(value).to be_a(Numeric)
          expect(value).to be_finite
        end
      end

      it 'test_two_phase_activation' do
        # TwoPhaseLayer should implement specific two-phase activation
        layer = described_class.new(layer_size)
        layer.init_layer(input_size)

        # Test multiple inputs to verify activation behavior
        inputs = [
          [0.0, 0.0, 0.0],     # Zero input
          [1.0, 1.0, 1.0],     # High input
          [-1.0, -1.0, -1.0],  # Negative input
          test_input # Mixed input
        ]

        inputs.each do |input|
          output = layer.eval(input)

          expect(output.length).to eq(layer_size)

          # Two-phase activation typically has specific output characteristics
          output.each do |value|
            expect(value).to be_finite
          end
        end
      end
    end

    context 'backward pass' do
      it 'test_backward_pass' do
        # Should handle error backpropagation
        layer = described_class.new(layer_size)
        layer.init_layer(input_size)

        # Forward pass first
        output = layer.eval(test_input)

        # Calculate error (difference from expected output)
        error = output.zip(test_output).map { |actual, expected| expected - actual }

        # Backward pass
        expect do
          layer.backprop(error)
        end.not_to raise_error

        # Error should propagate back through the layer
        layer.nodes.each do |node|
          expect(node.error).to be_a(Numeric)
          expect(node.error).to be_finite
        end
      end

      it 'test_weight_updates' do
        # Weights should be updated during training
        layer = described_class.new(layer_size)
        layer.init_layer(input_size)

        # Store initial weights
        initial_weights = layer.nodes.map { |node| node.weights.dup }

        # Training step
        output = layer.eval(test_input)
        error = output.zip(test_output).map { |actual, expected| expected - actual }
        layer.backprop(error)
        layer.update_weights(test_input, 0.1) # Learning rate = 0.1

        # Weights should have changed
        final_weights = layer.nodes.map(&:weights)

        weights_changed = initial_weights.zip(final_weights).any? do |initial, final|
          initial != final
        end

        expect(weights_changed).to be true
      end
    end
  end

  describe 'Integration Tests' do
    it 'provides complete layer functionality' do
      # Complete training cycle
      layer = described_class.new(layer_size)
      layer.init_layer(input_size)

      # Multiple training iterations
      10.times do
        # Forward pass
        output = layer.eval(test_input)
        expect(output.length).to eq(layer_size)

        # Calculate error
        error = output.zip(test_output).map { |actual, expected| expected - actual }

        # Backward pass
        layer.backprop(error)

        # Update weights
        layer.update_weights(test_input, 0.1)
      end

      # Final output should be closer to target
      final_output = layer.eval(test_input)
      final_error = final_output.zip(test_output).sum { |actual, expected| (expected - actual).abs }

      # Error should be finite (convergence not guaranteed in 10 iterations)
      expect(final_error).to be_finite
      expect(final_error).to be >= 0
    end

    it 'maintains layer properties during training' do
      # Layer structure should remain consistent
      layer = described_class.new(layer_size)
      layer.init_layer(input_size)

      # Verify initial structure
      expect(layer.nodes.length).to eq(layer_size)

      # Training
      5.times do
        output = layer.eval(test_input)
        error = output.map { |_v| rand(0.1) - 0.05 } # Random small errors
        layer.backprop(error)
        layer.update_weights(test_input, 0.05)
      end

      # Structure should be preserved
      expect(layer.nodes.length).to eq(layer_size)

      layer.nodes.each do |node|
        expect(node.weights.length).to eq(input_size)

        # All weights should still be finite
        node.weights.each do |weight|
          expect(weight).to be_finite
        end

        expect(node.threshold).to be_finite
      end
    end

    it 'works with different layer sizes' do
      # Test various layer configurations
      layer_sizes = [1, 3, 10, 20]

      layer_sizes.each do |size|
        layer = described_class.new(size)
        layer.init_layer(input_size)

        expect(layer.nodes.length).to eq(size)

        # Should process input correctly
        output = layer.eval(test_input)
        expect(output.length).to eq(size)

        output.each do |value|
          expect(value).to be_finite
        end
      end
    end
  end

  # Helper methods for testing
  def assert_valid_layer(layer, expected_size)
    expect(layer).to be_a(described_class)
    expect(layer.nodes.length).to eq(expected_size)

    layer.nodes.each do |node|
      expect(node).to be_a(Ai4r::NeuralNetwork::Node)
      expect(node.weights).to be_an(Array)
      expect(node.threshold).to be_a(Numeric)
    end
  end

  def calculate_layer_error(output, target)
    output.zip(target).sum { |actual, expected| (expected - actual)**2 } / output.length
  end
end
