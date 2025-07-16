# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/trainer'
require 'ai4r/neural_network/testable/network_builder'

RSpec.describe Ai4r::NeuralNetwork::Testable::Trainer do
  let(:network) do
    Ai4r::NeuralNetwork::Testable::NetworkBuilder.new
      .with_structure(2, 2, 1)
      .with_activation_function(:sigmoid)
      .with_learning_rate(0.5)
      .build
  end
  
  let(:xor_data) do
    [
      { input: [0, 0], output: [0] },
      { input: [0, 1], output: [1] },
      { input: [1, 0], output: [1] },
      { input: [1, 1], output: [0] }
    ]
  end
  
  let(:trainer) { described_class.new(network) }

  describe '#initialize' do
    it 'accepts a network' do
      expect(trainer.network).to eq(network)
    end

    it 'uses default validator if not provided' do
      expect(trainer.validator).to be_a(Ai4r::NeuralNetwork::Testable::NetworkValidator)
    end

    it 'accepts custom validator' do
      custom_validator = double('validator')
      trainer = described_class.new(network, validator: custom_validator)
      expect(trainer.validator).to eq(custom_validator)
    end

    it 'accepts custom logger' do
      custom_logger = double('logger')
      trainer = described_class.new(network, logger: custom_logger)
      expect(trainer.logger).to eq(custom_logger)
    end
  end

  describe '#train' do
    it 'trains the network' do
      result = trainer.train(xor_data, epochs: 10)
      
      expect(result).to include(:history, :final_error, :epochs_trained)
      expect(result[:epochs_trained]).to eq(10)
      expect(result[:history]).to be_an(Array)
      expect(result[:history].length).to eq(10)
    end

    it 'validates training data' do
      invalid_data = [{ input: [0, 0, 0], output: [0] }]  # Wrong input size
      
      expect { trainer.train(invalid_data) }
        .to raise_error(ArgumentError, /Input size mismatch/)
    end

    it 'initializes network if needed' do
      expect(network).to receive(:network_initialized?).and_return(false)
      expect(network).to receive(:init_network)
      
      trainer.train(xor_data, epochs: 1)
    end

    it 'tracks error over epochs' do
      result = trainer.train(xor_data, epochs: 20)
      
      errors = result[:history].map { |h| h[:error] }
      # Error should generally decrease (though not strictly monotonic)
      expect(errors.first).to be > errors.last
    end

    it 'supports epoch callbacks' do
      callback_data = []
      
      trainer.train(xor_data, epochs: 3) do |epoch, data|
        callback_data << { epoch: epoch, error: data[:error] }
      end
      
      expect(callback_data.length).to eq(3)
      expect(callback_data.map { |d| d[:epoch] }).to eq([0, 1, 2])
    end

    it 'shuffles data by default' do
      # With fixed seed for deterministic test
      srand(42)
      
      order_tracker = []
      allow(network).to receive(:train) do |input, output|
        order_tracker << input
        0.1  # Return some error
      end
      
      trainer.train(xor_data, epochs: 2)
      
      # Check that order changed between epochs
      first_epoch = order_tracker[0...4]
      second_epoch = order_tracker[4...8]
      
      expect(first_epoch).not_to eq(second_epoch)
    end

    it 'can disable shuffling' do
      order_tracker = []
      allow(network).to receive(:train) do |input, output|
        order_tracker << input
        0.1
      end
      
      trainer.train(xor_data, epochs: 2, shuffle: false)
      
      first_epoch = order_tracker[0...4]
      second_epoch = order_tracker[4...8]
      
      expect(first_epoch).to eq(second_epoch)
    end
  end

  describe '#train_batch' do
    it 'is a convenience method for batch training' do
      result = trainer.train_batch(xor_data, 2, epochs: 5)
      
      expect(result[:epochs_trained]).to eq(5)
      expect(result[:history].first[:examples_trained]).to eq(4)
    end
  end

  describe 'validation split' do
    it 'splits data for validation' do
      result = trainer.train(xor_data, epochs: 5, validation_split: 0.25)
      
      # Should have validation metrics
      expect(result[:history].first).to have_key(:validation)
      expect(result[:history].first[:validation]).to include(:mean_error, :accuracy)
    end

    it 'trains on reduced dataset when validation split used' do
      examples_trained = []
      allow(network).to receive(:train) do |input, output|
        0.1
      end
      
      result = trainer.train(xor_data, epochs: 1, validation_split: 0.5)
      
      # Should only train on half the data
      expect(result[:history].first[:examples_trained]).to eq(2)
    end
  end

  describe '#evaluate' do
    before do
      # Setup network to return predictable outputs
      allow(network).to receive(:eval) do |input|
        # Simple logic for testing
        input.sum > 1 ? [0.1] : [0.9]
      end
    end

    it 'calculates mean error' do
      result = trainer.evaluate(xor_data)
      
      expect(result).to include(:mean_error, :accuracy, :total_examples)
      expect(result[:total_examples]).to eq(4)
    end

    it 'calculates accuracy for classification' do
      classification_data = [
        { input: [0, 0], output: [1, 0, 0] },  # Class 0
        { input: [1, 1], output: [0, 1, 0] },  # Class 1
      ]
      
      allow(network).to receive(:eval).and_return([0.8, 0.1, 0.1], [0.1, 0.8, 0.1])
      
      result = trainer.evaluate(classification_data)
      expect(result[:accuracy]).to eq(1.0)  # Both correct
    end
  end

  describe 'early stopping' do
    it 'stops when validation error stops improving' do
      # Mock network to simulate plateauing error
      call_count = 0
      allow(network).to receive(:train) do
        call_count += 1
        # Error plateaus after 5 epochs
        call_count > 5 ? 0.1 : 0.5 / call_count
      end
      
      result = trainer.train(
        xor_data,
        epochs: 100,
        validation_split: 0.25,
        early_stopping_patience: 3,
        early_stopping_min_delta: 0.01
      )
      
      # Should stop early
      expect(result[:epochs_trained]).to be < 100
      expect(result[:epochs_trained]).to be >= 3  # At least patience epochs
    end

    it 'does not stop if improvement continues' do
      # Mock network with continuous improvement
      allow(network).to receive(:train) do |input, output|
        0.1 / (trainer.training_history.length + 1)  # Decreasing error
      end
      
      result = trainer.train(
        xor_data,
        epochs: 10,
        early_stopping_patience: 3
      )
      
      expect(result[:epochs_trained]).to eq(10)  # Full training
    end
  end

  describe 'logging' do
    it 'uses null logger by default' do
      expect(trainer.logger).to be_a(described_class::NullLogger)
      
      # Should not raise errors
      expect { trainer.train(xor_data, epochs: 1) }.not_to raise_error
    end

    it 'logs to console logger' do
      console_logger = described_class::ConsoleLogger.new
      trainer = described_class.new(network, logger: console_logger)
      
      expect(console_logger).to receive(:log_epoch).at_least(:once)
      
      trainer.train(xor_data, epochs: 1)
    end
  end

  describe 'batch training' do
    it 'processes data in batches' do
      batch_sizes = []
      
      # Mock the network to track batch processing
      allow(network).to receive(:train) do |input, output|
        0.1
      end
      
      trainer.train(xor_data * 3, epochs: 1, batch_size: 4)  # 12 examples, batch size 4
      
      # Should process 3 batches of 4
      history = trainer.training_history
      expect(history.first[:examples_trained]).to eq(12)
    end

    it 'handles non-divisible batch sizes' do
      # 5 examples with batch size 2 should work
      data = xor_data + [{ input: [0.5, 0.5], output: [0.5] }]
      
      result = trainer.train(data, epochs: 1, batch_size: 2)
      
      expect(result[:history].first[:examples_trained]).to eq(5)
    end
  end

  describe 'integration with network builder' do
    it 'works seamlessly with different network configurations' do
      networks = [
        Ai4r::NeuralNetwork::Testable::NetworkBuilder::Presets.xor_network,
        Ai4r::NeuralNetwork::Testable::NetworkBuilder::Presets.test_network([2, 3, 1])
      ]
      
      networks.each do |net|
        trainer = described_class.new(net)
        result = trainer.train(xor_data, epochs: 1)
        
        expect(result[:epochs_trained]).to eq(1)
      end
    end
  end

  describe 'training history' do
    it 'maintains complete training history' do
      trainer.train(xor_data, epochs: 5, validation_split: 0.25)
      
      history = trainer.training_history
      expect(history).to be_an(Array)
      expect(history.length).to eq(5)
      
      history.each_with_index do |epoch_data, i|
        expect(epoch_data[:epoch]).to eq(i)
        expect(epoch_data).to have_key(:error)
        expect(epoch_data).to have_key(:validation)
      end
    end

    it 'returns copy of history to prevent external modification' do
      trainer.train(xor_data, epochs: 1)
      
      history1 = trainer.training_history
      history2 = trainer.training_history
      
      expect(history1).not_to be(history2)  # Different objects
      expect(history1).to eq(history2)      # But same content
    end
  end
end