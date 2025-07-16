# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/network_builder'

RSpec.describe Ai4r::NeuralNetwork::Testable::NetworkBuilder do
  let(:builder) { described_class.new }

  describe 'fluent interface' do
    it 'returns self from all configuration methods' do
      expect(builder.with_structure(2, 3, 1)).to eq(builder)
      expect(builder.with_weight_initialization(:random)).to eq(builder)
      expect(builder.with_activation_function(:sigmoid)).to eq(builder)
      expect(builder.with_learning_algorithm(:gradient_descent)).to eq(builder)
      expect(builder.with_learning_rate(0.5)).to eq(builder)
      expect(builder.with_momentum(0.9)).to eq(builder)
      expect(builder.without_bias).to eq(builder)
      expect(builder.with_bias).to eq(builder)
    end

    it 'allows method chaining' do
      network = builder
        .with_structure(2, 4, 1)
        .with_activation_function(:tanh)
        .with_learning_rate(0.1)
        .build
      
      expect(network).to be_a(Ai4r::NeuralNetwork::Testable::Backpropagation)
    end
  end

  describe '#with_structure' do
    it 'accepts array notation' do
      network = builder.with_structure([2, 3, 1]).build
      expect(network.structure).to eq([2, 3, 1])
    end

    it 'accepts varargs notation' do
      network = builder.with_structure(2, 3, 1).build
      expect(network.structure).to eq([2, 3, 1])
    end

    it 'flattens nested arrays' do
      network = builder.with_structure([2], [3], 1).build
      expect(network.structure).to eq([2, 3, 1])
    end
  end

  describe '#with_weight_initialization' do
    it 'accepts symbol shortcuts' do
      network = builder
        .with_structure(2, 1)
        .with_weight_initialization(:xavier)
        .build
      
      expect(network.weight_initializer).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::Xavier)
    end

    it 'accepts initializer instances' do
      custom_init = Ai4r::NeuralNetwork::Testable::WeightInitializer::Fixed.new(value: 0.5)
      network = builder
        .with_structure(2, 1)
        .with_weight_initialization(custom_init)
        .build
      
      expect(network.weight_initializer).to eq(custom_init)
    end

    it 'passes options to initializer' do
      network = builder
        .with_structure(2, 1)
        .with_weight_initialization(:random, seed: 42, min: -0.5, max: 0.5)
        .build
      
      init = network.weight_initializer
      expect(init).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::Random)
    end

    it 'raises error for unknown strategy' do
      expect {
        builder.with_weight_initialization(:unknown_strategy)
      }.to raise_error(ArgumentError, 'Unknown weight initialization: unknown_strategy')
    end
  end

  describe '#with_activation_function' do
    it 'accepts all supported functions' do
      functions = [:sigmoid, :tanh, :relu, :leaky_relu, :linear]
      
      functions.each do |func|
        network = builder
          .with_structure(2, 1)
          .with_activation_function(func)
          .build
        
        expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction)
      end
    end

    it 'passes options to activation functions' do
      network = builder
        .with_structure(2, 1)
        .with_activation_function(:leaky_relu, alpha: 0.2)
        .build
      
      expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::LeakyReLU)
    end
  end

  describe '#with_learning_algorithm' do
    it 'attaches learning algorithm to network' do
      network = builder
        .with_structure(2, 1)
        .with_learning_algorithm(:adam, learning_rate: 0.001)
        .build
      
      expect(network).to respond_to(:learning_algorithm)
      expect(network.learning_algorithm).to be_a(Ai4r::NeuralNetwork::Testable::LearningAlgorithm::Adam)
    end
  end

  describe '#build' do
    it 'requires structure to be set' do
      expect { builder.build }.to raise_error(ArgumentError, 'Structure must be specified')
    end

    it 'uses sensible defaults' do
      network = builder.with_structure(2, 1).build
      
      expect(network.weight_initializer).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::Random)
      expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::Sigmoid)
      expect(network.validator).to be_a(Ai4r::NeuralNetwork::Testable::NetworkValidator)
      expect(network.learning_rate).to eq(0.25)
      expect(network.momentum).to eq(0.1)
    end

    it 'respects all configurations' do
      validator = Ai4r::NeuralNetwork::Testable::NetworkValidator.new
      
      network = builder
        .with_structure(3, 5, 2)
        .with_weight_initialization(:he)
        .with_activation_function(:relu)
        .with_learning_algorithm(:momentum)
        .with_learning_rate(0.01)
        .with_momentum(0.95)
        .without_bias
        .with_validator(validator)
        .build
      
      expect(network.structure).to eq([3, 5, 2])
      expect(network.weight_initializer).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::He)
      expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::ReLU)
      expect(network.learning_algorithm).to be_a(Ai4r::NeuralNetwork::Testable::LearningAlgorithm::Momentum)
      expect(network.learning_rate).to eq(0.01)
      expect(network.momentum).to eq(0.95)
      expect(network.disable_bias).to eq(true)
      expect(network.validator).to eq(validator)
    end
  end

  describe 'Presets' do
    describe '.xor_network' do
      let(:network) { described_class::Presets.xor_network }

      it 'creates appropriate XOR network' do
        expect(network.structure).to eq([2, 2, 1])
        expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::Sigmoid)
        expect(network.learning_rate).to eq(0.5)
      end
    end

    describe '.iris_classifier' do
      let(:network) { described_class::Presets.iris_classifier }

      it 'creates appropriate Iris classifier' do
        expect(network.structure).to eq([4, 10, 3])
        expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::Tanh)
        expect(network.weight_initializer).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::Xavier)
      end
    end

    describe '.mnist_classifier' do
      let(:network) { described_class::Presets.mnist_classifier }

      it 'creates appropriate MNIST classifier' do
        expect(network.structure).to eq([784, 128, 64, 10])
        expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::ReLU)
        expect(network.weight_initializer).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::He)
      end
    end

    describe '.test_network' do
      let(:network) { described_class::Presets.test_network([2, 3, 1]) }

      it 'creates deterministic test network' do
        expect(network.structure).to eq([2, 3, 1])
        expect(network.activation_function).to be_a(Ai4r::NeuralNetwork::Testable::ActivationFunction::Linear)
        expect(network.weight_initializer).to be_a(Ai4r::NeuralNetwork::Testable::WeightInitializer::Fixed)
        expect(network.disable_bias).to eq(true)
      end
    end
  end

  describe 'testability improvements' do
    it 'makes it easy to create networks with known weights' do
      # For testing, we often want deterministic weights
      test_network = builder
        .with_structure(2, 2, 1)
        .with_weight_initialization(:fixed, value: 0.5)
        .with_activation_function(:linear)
        .without_bias
        .build
      
      test_network.init_network
      
      # All weights should be 0.5
      test_network.weights.each do |layer|
        layer.each do |neuron_weights|
          neuron_weights.each do |weight|
            expect(weight).to eq(0.5)
          end
        end
      end
    end

    it 'makes it easy to test different configurations' do
      configurations = [
        { activation: :sigmoid, initializer: :xavier },
        { activation: :relu, initializer: :he },
        { activation: :tanh, initializer: :random }
      ]
      
      networks = configurations.map do |config|
        builder
          .with_structure(10, 5, 2)
          .with_activation_function(config[:activation])
          .with_weight_initialization(config[:initializer])
          .build
      end
      
      expect(networks).to all(be_a(Ai4r::NeuralNetwork::Testable::Backpropagation))
      expect(networks.map(&:activation_function).map(&:class).uniq.size).to eq(3)
    end

    it 'supports dependency injection for all components' do
      # Custom components for testing
      mock_validator = double('validator')
      allow(mock_validator).to receive(:validate_structure)
      
      mock_initializer = double('initializer')
      allow(mock_initializer).to receive(:is_a?).with(Ai4r::NeuralNetwork::Testable::WeightInitializer).and_return(true)
      
      mock_activation = double('activation')
      allow(mock_activation).to receive(:is_a?).with(Ai4r::NeuralNetwork::Testable::ActivationFunction).and_return(true)
      
      network = builder
        .with_structure(2, 1)
        .with_weight_initialization(mock_initializer)
        .with_activation_function(mock_activation)
        .with_validator(mock_validator)
        .build
      
      expect(network.validator).to eq(mock_validator)
      expect(network.weight_initializer).to eq(mock_initializer)
      expect(network.activation_function).to eq(mock_activation)
    end
  end
end