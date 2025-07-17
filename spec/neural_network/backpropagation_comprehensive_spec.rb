# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::NeuralNetwork::Backpropagation do
  describe '#initialize' do
    it 'creates network with specified structure' do
      nn = described_class.new([2, 3, 1])
      expect(nn.instance_variable_get(:@structure)).to eq([2, 3, 1])
    end

    it 'initializes weights randomly' do
      nn = described_class.new([2, 3, 1])
      weights = nn.instance_variable_get(:@weights)
      expect(weights).to be_an(Array)
      expect(weights.length).to eq(2) # 2 layers of weights
    end

    it 'uses default activation function' do
      nn = described_class.new([2, 3, 1])
      expect(nn.instance_variable_get(:@activation_function)).to be_a(Proc)
    end
  end

  describe '#train' do
    let(:nn) { described_class.new([2, 2, 1]) }

    it 'updates weights during training' do
      # Train with a single example to initialize the network
      nn.train([0.5, 0.5], [0.7])
      
      # Get initial weights after initialization
      initial_weights = nn.instance_variable_get(:@weights).map { |layer| layer.map(&:dup) }
      
      # Train again and weights should change
      nn.train([0.5, 0.5], [0.7])
      
      final_weights = nn.instance_variable_get(:@weights)
      
      # Weights should have changed
      expect(final_weights).not_to eq(initial_weights)
    end

    it 'accepts learning rate parameter' do
      nn.instance_variable_set(:@learning_rate, 0.5)
      expect { nn.train([0.5, 0.5], [0.7]) }.not_to raise_error
    end

    it 'handles multiple outputs' do
      nn_multi = described_class.new([2, 3, 2])
      expect { nn_multi.train([0.5, 0.5], [0.7, 0.3]) }.not_to raise_error
    end
  end

  describe '#eval' do
    let(:nn) { described_class.new([2, 3, 1]) }

    it 'returns output for given input' do
      output = nn.eval([0.5, 0.5])
      expect(output).to be_an(Array)
      expect(output.length).to eq(1)
      expect(output[0]).to be_between(0, 1)
    end

    it 'handles different input sizes correctly' do
      nn_large = described_class.new([5, 4, 3, 2])
      output = nn_large.eval([0.1, 0.2, 0.3, 0.4, 0.5])
      expect(output.length).to eq(2)
    end
  end

  describe '#feed_forward' do
    let(:nn) { described_class.new([2, 3, 1]) }

    it 'propagates input through network' do
      # Access the method if it's public
      if nn.respond_to?(:feed_forward)
        activations = nn.feed_forward([0.5, 0.5])
        expect(activations).to be_an(Array)
        expect(activations.length).to eq(3) # Input + hidden + output layers
      else
        # Test through eval if feed_forward is private
        output = nn.eval([0.5, 0.5])
        expect(output).to be_an(Array)
      end
    end
  end

  describe 'XOR problem' do
    it 'learns XOR function with sufficient training' do
      nn = described_class.new([2, 4, 1])
      nn.set_parameters(learning_rate: 0.5, momentum: 0.2)
      
      # Training data for XOR
      training_data = [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
      ]
      
      # Train for more epochs with higher learning rate
      500.times do
        training_data.each do |example|
          nn.train(example[:input], example[:output])
        end
      end
      
      # Test predictions with higher tolerance
      tolerance = 0.4
      expect(nn.eval([0, 0])[0]).to be_within(tolerance).of(0)
      expect(nn.eval([0, 1])[0]).to be_within(tolerance).of(1)
      expect(nn.eval([1, 0])[0]).to be_within(tolerance).of(1)
      expect(nn.eval([1, 1])[0]).to be_within(tolerance).of(0)
    end
  end

  describe 'regression problem' do
    it 'approximates simple function' do
      nn = described_class.new([1, 5, 1])
      
      # Train to approximate f(x) = x^2
      training_data = []
      (0..10).each do |i|
        x = i / 10.0
        y = x * x
        training_data << { input: [x], output: [y] }
      end
      
      # Train
      100.times do
        training_data.each do |example|
          nn.train(example[:input], example[:output])
        end
      end
      
      # Test approximation
      test_x = 0.5
      expected_y = test_x * test_x
      predicted_y = nn.eval([test_x])[0]
      
      expect(predicted_y).to be_within(0.1).of(expected_y)
    end
  end

  describe 'custom activation functions' do
    it 'accepts custom activation function' do
      # Custom linear activation
      linear_activation = ->(x) { x }
      linear_derivative = ->(x) { 1 }
      
      nn = described_class.new([2, 2, 1])
      
      # Set custom activation if the network supports it
      if nn.respond_to?(:activation_function=)
        nn.activation_function = linear_activation
        nn.derivative_function = linear_derivative
      end
      
      # Should still work
      expect { nn.eval([0.5, 0.5]) }.not_to raise_error
    end
  end

  describe 'error handling' do
    it 'handles mismatched input size' do
      nn = described_class.new([3, 2, 1])
      
      # This might raise an error or handle gracefully
      # depending on implementation
      expect { nn.eval([0.5, 0.5]) }.to raise_error(StandardError)
    end

    it 'handles mismatched output size during training' do
      nn = described_class.new([2, 2, 1])
      
      # Wrong output size
      expect { nn.train([0.5, 0.5], [0.7, 0.3]) }.to raise_error(StandardError)
    end
  end

  describe 'network persistence' do
    it 'can save and load weights' do
      nn = described_class.new([2, 3, 1])
      
      # Train a bit
      nn.train([0.5, 0.5], [0.7])
      
      # Get weights
      weights = nn.instance_variable_get(:@weights)
      
      # Create new network and set weights
      nn2 = described_class.new([2, 3, 1])
      nn2.instance_variable_set(:@weights, weights.map { |layer| layer.map(&:dup) })
      
      # Should produce same output
      output1 = nn.eval([0.5, 0.5])
      output2 = nn2.eval([0.5, 0.5])
      
      expect(output1).to eq(output2)
    end
  end

  describe 'multi-class classification' do
    it 'handles multiple output classes' do
      nn = described_class.new([2, 4, 3])
      
      # One-hot encoded outputs
      training_data = [
        { input: [0.1, 0.1], output: [1, 0, 0] },
        { input: [0.5, 0.5], output: [0, 1, 0] },
        { input: [0.9, 0.9], output: [0, 0, 1] }
      ]
      
      # Train
      50.times do
        training_data.each do |example|
          nn.train(example[:input], example[:output])
        end
      end
      
      # Test that outputs sum approximately to 1 (softmax-like)
      output = nn.eval([0.5, 0.5])
      expect(output.length).to eq(3)
      expect(output.sum).to be_within(0.5).of(1.0)
    end
  end
end