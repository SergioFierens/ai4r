# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/enhanced_neural_network'

RSpec.describe Ai4r::NeuralNetwork::EnhancedNeuralNetwork do
  describe 'Initialization' do
    it 'creates network with default configuration' do
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1])
      
      expect(nn.structure).to eq([2, 3, 1])
      expect(nn.layers).to be_an(Array)
      expect(nn.layers.size).to eq(2) # n-1 layers
      expect(nn.optimizer).to be_a(Ai4r::NeuralNetwork::Optimizers::AdamOptimizer)
      expect(nn.monitor).to be_a(Ai4r::NeuralNetwork::EnhancedNetworkMonitor)
      expect(nn.training_mode).to be true
    end

    it 'creates network with custom configuration' do
      config = {
        optimizer: :sgd,
        optimizer_params: { learning_rate: 0.1 },
        activation_function: :tanh,
        verbose: false
      }
      
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 4, 2], config)
      
      expect(nn.optimizer).to be_a(Ai4r::NeuralNetwork::Optimizers::SGD)
      expect(nn.optimizer.learning_rate).to eq(0.1)
    end

    it 'sets up regularization' do
      config = {
        regularization_config: {
          dropout: { rate: 0.3 },
          l2: { lambda: 0.001 }
        }
      }
      
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1], config)
      reg_strategy = nn.instance_variable_get(:@regularization)
      
      expect(reg_strategy).to be_a(Ai4r::NeuralNetwork::RegularizationStrategy)
      expect(reg_strategy.techniques).to have_key(:dropout)
      expect(reg_strategy.techniques).to have_key(:l2)
    end

    it 'initializes weights according to strategy' do
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1])
      
      # Check weights are initialized
      nn.layers.each do |layer|
        expect(layer.weights).not_to be_nil
        expect(layer.weights).to all(be_an(Array))
        expect(layer.biases).not_to be_nil
      end
    end
  end

  describe '#forward' do
    let(:nn) { Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1]) }

    it 'performs forward pass' do
      inputs = [0.5, 0.7]
      outputs = nn.forward(inputs)
      
      expect(outputs).to be_an(Array)
      expect(outputs.size).to eq(1)
      expect(outputs[0]).to be_between(-1, 1) # Assuming sigmoid activation
    end

    it 'applies regularization during training' do
      config = {
        regularization_config: {
          dropout: { rate: 0.5 }
        }
      }
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 4, 1], config)
      
      # Multiple forward passes should give different results due to dropout
      results = []
      10.times { results << nn.forward([0.5, 0.5], true)[0] }
      
      expect(results.uniq.size).to be > 1
    end

    it 'does not apply dropout during inference' do
      config = {
        regularization_config: {
          dropout: { rate: 0.5 }
        }
      }
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 4, 1], config)
      
      # Multiple forward passes in inference mode should give same results
      results = []
      5.times { results << nn.forward([0.5, 0.5], false)[0] }
      
      expect(results.uniq.size).to eq(1)
    end

    it 'tracks activations when monitoring is enabled' do
      nn.monitor.enable_activation_tracking
      nn.forward([0.5, 0.7])
      
      stats = nn.monitor.get_activation_statistics
      expect(stats).not_to be_empty
    end
  end

  describe '#train' do
    let(:nn) { Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 2, 1]) }
    let(:training_data) do
      [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
      ]
    end

    it 'trains for specified epochs' do
      initial_weights = nn.layers[0].weights[0][0]
      
      nn.train(training_data, epochs: 5, batch_size: 2, verbose: false)
      
      # Weights should change
      expect(nn.layers[0].weights[0][0]).not_to eq(initial_weights)
    end

    it 'uses batch training' do
      monitor = nn.monitor
      allow(monitor).to receive(:record_batch_loss)
      
      nn.train(training_data, epochs: 1, batch_size: 2, verbose: false)
      
      # Should process 2 batches (4 samples / batch_size 2)
      expect(monitor).to have_received(:record_batch_loss).at_least(2).times
    end

    it 'applies gradient clipping when configured' do
      config = {
        gradient_clip_threshold: 1.0
      }
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 2, 1], config)
      
      # Train with large learning rate to trigger clipping
      nn.train(training_data, epochs: 1, batch_size: 1, verbose: false)
      
      # Gradients should be clipped - weights shouldn't explode
      nn.layers.each do |layer|
        layer.weights.flatten.each do |weight|
          expect(weight.abs).to be < 10
        end
      end
    end

    it 'validates training data' do
      invalid_data = [
        { input: [0, 0, 0], output: [0] } # Wrong input size
      ]
      
      expect { nn.train(invalid_data) }
        .to raise_error(ArgumentError, /Input size mismatch/)
    end
  end

  describe '#predict' do
    let(:nn) { Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1]) }

    it 'makes predictions in inference mode' do
      result = nn.predict([0.5, 0.7])
      
      expect(result).to be_an(Array)
      expect(result.size).to eq(1)
      expect(nn.training_mode).to be false
    end

    it 'makes batch predictions' do
      inputs = [[0.1, 0.2], [0.3, 0.4], [0.5, 0.6]]
      results = nn.predict_batch(inputs)
      
      expect(results).to be_an(Array)
      expect(results.size).to eq(3)
      expect(results).to all(be_an(Array))
    end
  end

  describe '#evaluate' do
    let(:nn) { Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 2, 1]) }
    let(:test_data) do
      [
        { input: [0, 0], output: [0] },
        { input: [1, 1], output: [1] }
      ]
    end

    it 'evaluates network performance' do
      metrics = nn.evaluate(test_data)
      
      expect(metrics).to include(:loss, :accuracy)
      expect(metrics[:loss]).to be_a(Float)
      expect(metrics[:accuracy]).to be_between(0, 1)
    end

    it 'supports custom metrics' do
      custom_metrics = {
        mse: ->(predicted, actual) { (predicted - actual).map { |d| d**2 }.sum / predicted.size }
      }
      
      metrics = nn.evaluate(test_data, metrics: custom_metrics)
      expect(metrics).to include(:mse)
    end
  end

  describe '#save and #load' do
    let(:nn) { Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1]) }
    let(:filename) { 'test_network.nn' }

    after { File.delete(filename) if File.exist?(filename) }

    it 'saves network to file' do
      nn.save(filename)
      expect(File.exist?(filename)).to be true
    end

    it 'loads network from file' do
      # Train network to change weights
      nn.train([{ input: [0.5, 0.5], output: [0.7] }], epochs: 1, verbose: false)
      original_output = nn.predict([0.5, 0.5])
      
      # Save and load
      nn.save(filename)
      loaded_nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.load(filename)
      
      # Should produce same output
      loaded_output = loaded_nn.predict([0.5, 0.5])
      expect(loaded_output[0]).to be_within(0.001).of(original_output[0])
    end
  end

  describe 'Layer class' do
    it 'creates layer with correct dimensions' do
      layer = Ai4r::NeuralNetwork::Layer.new(3, 2, :relu)
      
      expect(layer.input_size).to eq(3)
      expect(layer.output_size).to eq(2)
      expect(layer.weights.size).to eq(2)
      expect(layer.weights[0].size).to eq(3)
      expect(layer.biases.size).to eq(2)
    end

    it 'performs forward pass' do
      layer = Ai4r::NeuralNetwork::Layer.new(2, 3, :relu)
      inputs = [0.5, 0.7]
      
      outputs = layer.forward(inputs)
      
      expect(outputs).to be_an(Array)
      expect(outputs.size).to eq(3)
    end

    it 'performs backward pass' do
      layer = Ai4r::NeuralNetwork::Layer.new(2, 3, :relu)
      inputs = [0.5, 0.7]
      
      # Forward to cache inputs
      layer.forward(inputs)
      
      # Backward
      gradients = [0.1, 0.2, 0.3]
      input_gradients = layer.backward(gradients, 0.01)
      
      expect(input_gradients).to be_an(Array)
      expect(input_gradients.size).to eq(2)
    end
  end

  describe 'NetworkConfiguration' do
    it 'sets default configuration' do
      config = Ai4r::NeuralNetwork::NetworkConfiguration.new
      
      expect(config.activation_function).to eq(:sigmoid)
      expect(config.optimizer).to eq(:adam)
      expect(config.learning_rate).to eq(0.001)
      expect(config.verbose).to be false
    end

    it 'merges custom configuration' do
      custom = {
        activation_function: :tanh,
        learning_rate: 0.01,
        dropout_rate: 0.5
      }
      
      config = Ai4r::NeuralNetwork::NetworkConfiguration.new(custom)
      
      expect(config.activation_function).to eq(:tanh)
      expect(config.learning_rate).to eq(0.01)
      expect(config.dropout_rate).to eq(0.5)
    end
  end

  describe 'EnhancedNetworkMonitor' do
    let(:monitor) { Ai4r::NeuralNetwork::EnhancedNetworkMonitor.new }

    it 'tracks training metrics' do
      monitor.start_epoch(1)
      monitor.record_batch_loss(0.5)
      monitor.record_batch_loss(0.4)
      monitor.end_epoch(0.45)
      
      history = monitor.get_training_history
      expect(history[:loss]).to eq([0.45])
      expect(history[:batch_losses][0]).to eq([0.5, 0.4])
    end

    it 'tracks gradient statistics' do
      monitor.enable_gradient_tracking
      gradients = [[0.1, -0.2], [0.3, -0.4]]
      
      monitor.record_gradients(0, gradients)
      
      stats = monitor.get_gradient_statistics
      expect(stats[0]).to include(:mean, :std, :max, :min)
    end

    it 'detects gradient issues' do
      monitor.enable_gradient_tracking
      
      # Vanishing gradients
      monitor.record_gradients(0, [[0.0001, 0.0001]])
      warnings = monitor.check_gradient_health
      expect(warnings).to include(/vanishing/i)
      
      # Exploding gradients
      monitor.record_gradients(1, [[100.0, -100.0]])
      warnings = monitor.check_gradient_health
      expect(warnings).to include(/exploding/i)
    end
  end

  describe 'RegularizationStrategy' do
    let(:strategy) { Ai4r::NeuralNetwork::RegularizationStrategy.new }

    it 'adds regularization techniques' do
      strategy.add_technique(:dropout, rate: 0.5)
      strategy.add_technique(:l2, lambda: 0.01)
      
      expect(strategy.techniques).to have_key(:dropout)
      expect(strategy.techniques).to have_key(:l2)
    end

    it 'applies forward regularization' do
      strategy.add_technique(:dropout, rate: 0.5)
      inputs = [1.0, 2.0, 3.0]
      
      # Multiple applications should give different results
      results = []
      5.times { results << strategy.apply_forward(inputs, true) }
      
      expect(results.uniq.size).to be > 1
    end

    it 'calculates total penalty' do
      strategy.add_technique(:l1, lambda: 0.01)
      strategy.add_technique(:l2, lambda: 0.01)
      
      weights = [[1.0, -2.0], [3.0, -4.0]]
      penalty = strategy.total_penalty(weights)
      
      expect(penalty).to be > 0
    end
  end

  describe 'Educational features' do
    it 'provides network summary' do
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 4, 3, 1])
      summary = nn.summary
      
      expect(summary).to include('Enhanced Neural Network Summary')
      expect(summary).to include('Structure: 2 → 4 → 3 → 1')
      expect(summary).to include('Total parameters:')
    end

    it 'visualizes network architecture' do
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1])
      viz = nn.visualize_architecture
      
      expect(viz).to include('Input Layer (2)')
      expect(viz).to include('Hidden Layer')
      expect(viz).to include('Output Layer (1)')
    end

    it 'explains predictions' do
      nn = Ai4r::NeuralNetwork::EnhancedNeuralNetwork.new([2, 3, 1])
      explanation = nn.explain_prediction([0.5, 0.7])
      
      expect(explanation).to include(:prediction)
      expect(explanation).to include(:layer_activations)
      expect(explanation).to include(:feature_importance)
    end
  end
end