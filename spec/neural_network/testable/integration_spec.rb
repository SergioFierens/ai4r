# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/network_builder'
require 'ai4r/neural_network/testable/trainer'

RSpec.describe 'Testable Neural Network Integration' do
  describe 'XOR problem' do
    let(:xor_data) do
      [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
      ]
    end

    it 'demonstrates improved testability with dependency injection' do
      # Create network with explicit dependencies
      network = Ai4r::NeuralNetwork::Testable::NetworkBuilder.new
        .with_structure(2, 3, 1)
        .with_weight_initialization(:xavier)
        .with_activation_function(:tanh)
        .with_learning_algorithm(:adam, learning_rate: 0.1)
        .with_learning_rate(0.1)
        .build

      # Create trainer with custom logger
      logged_epochs = []
      custom_logger = Class.new do
        define_method :log_epoch do |epoch, error|
          logged_epochs << { epoch: epoch, error: error }
        end
        def log_batch(batch, error); end
        def log_validation(metrics); end
      end.new

      trainer = Ai4r::NeuralNetwork::Testable::Trainer.new(
        network,
        logger: custom_logger
      )

      # Train with validation and early stopping
      result = trainer.train(
        xor_data * 10,  # More data for better training
        epochs: 50,
        validation_split: 0.2,
        early_stopping_patience: 5,
        on_epoch_end: ->(epoch, data) {
          # Custom callback for monitoring
          puts "Epoch #{epoch}: #{data[:error].round(4)}" if epoch % 10 == 0
        }
      )

      # Verify training occurred
      expect(result[:epochs_trained]).to be > 0
      expect(result[:final_error]).to be < 0.5
      expect(logged_epochs).not_to be_empty
      
      # Evaluate on test data
      evaluation = trainer.evaluate(xor_data)
      expect(evaluation[:mean_error]).to be < 0.5
    end

    it 'shows how to test with deterministic weights' do
      # Create network with fixed weights for testing
      test_network = Ai4r::NeuralNetwork::Testable::NetworkBuilder.new
        .with_structure(2, 2, 1)
        .with_weight_initialization(:fixed, value: 0.5)
        .with_activation_function(:linear)
        .without_bias
        .build

      test_network.init_network

      # Verify all weights are as expected
      test_network.weights.each do |layer|
        layer.each do |neuron_weights|
          expect(neuron_weights).to all(eq(0.5))
        end
      end

      # Test forward propagation with known weights
      output = test_network.eval([1, 1])
      # With linear activation and all weights 0.5:
      # Hidden layer: [1*0.5 + 1*0.5, 1*0.5 + 1*0.5] = [1, 1]
      # Output layer: [1*0.5 + 1*0.5] = [1]
      expect(output).to eq([1.0])
    end
  end

  describe 'Testing different configurations' do
    it 'makes it easy to test multiple network architectures' do
      configurations = [
        { 
          name: 'shallow_sigmoid',
          structure: [2, 4, 1],
          activation: :sigmoid,
          initializer: :random,
          algorithm: :gradient_descent
        },
        {
          name: 'deep_relu',
          structure: [2, 8, 4, 1],
          activation: :relu,
          initializer: :he,
          algorithm: :adam
        },
        {
          name: 'wide_tanh',
          structure: [2, 16, 1],
          activation: :tanh,
          initializer: :xavier,
          algorithm: :momentum
        }
      ]

      results = {}
      
      configurations.each do |config|
        network = Ai4r::NeuralNetwork::Testable::NetworkBuilder.new
          .with_structure(*config[:structure])
          .with_activation_function(config[:activation])
          .with_weight_initialization(config[:initializer])
          .with_learning_algorithm(config[:algorithm])
          .build

        trainer = Ai4r::NeuralNetwork::Testable::Trainer.new(network)
        
        # Quick training for comparison
        result = trainer.train(
          [
            { input: [0, 0], output: [0] },
            { input: [1, 1], output: [1] }
          ] * 10,
          epochs: 10
        )
        
        results[config[:name]] = {
          final_error: result[:final_error],
          structure: config[:structure]
        }
      end

      # All should train to some degree
      results.each do |name, result|
        expect(result[:final_error]).to be < 1.0
      end
    end
  end

  describe 'Mocking and testing components in isolation' do
    it 'allows mocking individual components' do
      # Mock activation function that always returns 0.5
      mock_activation = double('activation')
      allow(mock_activation).to receive(:forward).and_return(0.5)
      allow(mock_activation).to receive(:derivative).and_return(0.25)
      allow(mock_activation).to receive(:is_a?)
        .with(Ai4r::NeuralNetwork::Testable::ActivationFunction)
        .and_return(true)

      # Mock weight initializer that returns sequential values
      counter = 0
      mock_initializer = double('initializer')
      allow(mock_initializer).to receive(:initialize_weight) do |fan_in, fan_out|
        counter += 0.1
      end
      allow(mock_initializer).to receive(:is_a?)
        .with(Ai4r::NeuralNetwork::Testable::WeightInitializer)
        .and_return(true)

      # Build network with mocked components
      network = Ai4r::NeuralNetwork::Testable::NetworkBuilder.new
        .with_structure(2, 2, 1)
        .with_activation_function(mock_activation)
        .with_weight_initialization(mock_initializer)
        .build

      # Verify mocks are used
      expect(network.activation_function).to eq(mock_activation)
      expect(network.weight_initializer).to eq(mock_initializer)

      # Initialize and verify behavior
      network.init_network
      output = network.eval([1, 1])
      
      # With mocked activation always returning 0.5
      expect(output).to all(be_within(0.1).of(0.5))
    end

    it 'allows testing learning algorithms in isolation' do
      weights = [[0.5, 0.3], [0.2, 0.4]]
      gradients = [[0.1, 0.2], [0.3, 0.1]]

      # Test each algorithm independently
      algorithms = {
        gd: Ai4r::NeuralNetwork::Testable::LearningAlgorithm::GradientDescent.new(learning_rate: 0.1),
        momentum: Ai4r::NeuralNetwork::Testable::LearningAlgorithm::Momentum.new(learning_rate: 0.1),
        adam: Ai4r::NeuralNetwork::Testable::LearningAlgorithm::Adam.new(learning_rate: 0.01)
      }

      algorithms.each do |name, algo|
        updated = algo.update_weights(weights, gradients, 0)
        
        # Verify weights changed
        expect(updated).not_to eq(weights)
        
        # Verify shape preserved
        expect(updated.size).to eq(weights.size)
        expect(updated[0].size).to eq(weights[0].size)
      end
    end
  end

  describe 'Error handling and validation' do
    it 'provides clear error messages for common mistakes' do
      builder = Ai4r::NeuralNetwork::Testable::NetworkBuilder.new

      # Missing structure
      expect { builder.build }.to raise_error(ArgumentError, 'Structure must be specified')

      # Invalid activation function
      expect { 
        builder.with_activation_function(:invalid_function) 
      }.to raise_error(ArgumentError, /Unknown activation function/)

      # Invalid weight initialization
      expect {
        builder.with_weight_initialization(:invalid_init)
      }.to raise_error(ArgumentError, /Unknown weight initialization/)

      # Invalid training data
      network = builder.with_structure(2, 1).build
      trainer = Ai4r::NeuralNetwork::Testable::Trainer.new(network)
      
      expect {
        trainer.train([{ input: [1], output: [1] }])  # Wrong input size
      }.to raise_error(ArgumentError, /Input size mismatch/)
    end
  end

  describe 'Performance monitoring' do
    it 'tracks detailed metrics during training' do
      network = Ai4r::NeuralNetwork::Testable::NetworkBuilder::Presets.xor_network
      trainer = Ai4r::NeuralNetwork::Testable::Trainer.new(network)

      metrics = {
        epochs: [],
        errors: [],
        validation_errors: [],
        training_time: nil
      }

      start_time = Time.now
      result = trainer.train(
        [
          { input: [0, 0], output: [0] },
          { input: [0, 1], output: [1] },
          { input: [1, 0], output: [1] },
          { input: [1, 1], output: [0] }
        ] * 25,  # 100 examples
        epochs: 20,
        validation_split: 0.2,
        batch_size: 10,
        on_epoch_end: ->(epoch, data) {
          metrics[:epochs] << epoch
          metrics[:errors] << data[:error]
          metrics[:validation_errors] << data.dig(:validation, :mean_error)
        }
      )
      metrics[:training_time] = Time.now - start_time

      # Verify metrics collected
      expect(metrics[:epochs].size).to eq(result[:epochs_trained])
      expect(metrics[:errors]).to all(be_a(Float))
      expect(metrics[:validation_errors].compact).not_to be_empty
      expect(metrics[:training_time]).to be < 1.0  # Should be fast
    end
  end
end