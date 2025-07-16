# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/educational_examples'

RSpec.describe Ai4r::NeuralNetwork::EducationalExamples do
  describe '.beginner_tutorial' do
    it 'explains neural network basics' do
      tutorial = described_class.beginner_tutorial
      
      expect(tutorial).to include(
        title: 'Neural Networks for Beginners',
        description: a_string_including('neural'),
        concepts: an_instance_of(Array)
      )
    end

    it 'includes perceptron example' do
      tutorial = described_class.beginner_tutorial
      example = tutorial[:examples].find { |e| e[:name] == 'Perceptron' }
      
      expect(example).not_to be_nil
      expect(example[:code]).to include('Perceptron')
      expect(example[:explanation]).to include('linear')
    end

    it 'provides XOR problem example' do
      tutorial = described_class.beginner_tutorial
      xor_example = tutorial[:examples].find { |e| e[:name] == 'XOR Problem' }
      
      expect(xor_example).not_to be_nil
      expect(xor_example[:why_important]).to include('non-linear')
    end
  end

  describe '.intermediate_tutorial' do
    it 'covers backpropagation' do
      tutorial = described_class.intermediate_tutorial
      
      expect(tutorial[:algorithms]).to include('Backpropagation')
      expect(tutorial[:mathematical_concepts]).to include('Gradient Descent')
    end

    it 'includes activation functions' do
      tutorial = described_class.intermediate_tutorial
      
      expect(tutorial[:activation_functions]).to include(
        'sigmoid', 'tanh', 'relu', 'softmax'
      )
    end

    it 'provides regularization techniques' do
      tutorial = described_class.intermediate_tutorial
      
      expect(tutorial[:regularization]).to include(
        'L1', 'L2', 'Dropout', 'Early Stopping'
      )
    end
  end

  describe '.advanced_tutorial' do
    it 'covers deep learning architectures' do
      tutorial = described_class.advanced_tutorial
      
      expect(tutorial[:architectures]).to include(
        'CNN', 'RNN', 'LSTM', 'Transformer'
      )
    end

    it 'includes optimization algorithms' do
      tutorial = described_class.advanced_tutorial
      
      expect(tutorial[:optimizers]).to include(
        'SGD', 'Adam', 'RMSprop', 'AdaGrad'
      )
    end

    it 'provides research directions' do
      tutorial = described_class.advanced_tutorial
      
      expect(tutorial[:research_topics]).to be_an(Array)
      expect(tutorial[:papers]).to be_an(Array)
    end
  end

  describe '.create_neural_network_example' do
    it 'creates XOR network' do
      nn = described_class.create_neural_network_example(:xor)
      
      expect(nn).to respond_to(:train)
      expect(nn).to respond_to(:eval)
    end

    it 'creates digit recognition network' do
      nn = described_class.create_neural_network_example(:digits)
      
      expect(nn).to respond_to(:train)
      expect(nn.instance_variable_get(:@structure)).to include(784) # 28x28 pixels
    end

    it 'creates regression network' do
      nn = described_class.create_neural_network_example(:regression)
      
      expect(nn).to respond_to(:train)
      expect(nn.instance_variable_get(:@structure).last).to eq(1) # Single output
    end
  end

  describe '.explain_backpropagation' do
    it 'provides step-by-step explanation' do
      explanation = described_class.explain_backpropagation
      
      expect(explanation[:steps]).to be_an(Array)
      expect(explanation[:steps].size).to be >= 4
    end

    it 'includes mathematical formulas' do
      explanation = described_class.explain_backpropagation
      
      expect(explanation[:formulas]).to include(
        :error_calculation,
        :weight_update,
        :gradient_calculation
      )
    end

    it 'provides visual representation' do
      explanation = described_class.explain_backpropagation
      
      expect(explanation[:visualization]).to include(:forward_pass, :backward_pass)
    end
  end

  describe '.activation_function_comparison' do
    it 'compares common activation functions' do
      comparison = described_class.activation_function_comparison
      
      expect(comparison[:functions]).to include('sigmoid', 'tanh', 'relu')
    end

    it 'provides properties for each function' do
      comparison = described_class.activation_function_comparison
      sigmoid = comparison[:functions]['sigmoid']
      
      expect(sigmoid).to include(
        :formula,
        :derivative,
        :range,
        :pros,
        :cons
      )
    end

    it 'includes visualization data' do
      comparison = described_class.activation_function_comparison
      
      expect(comparison[:plot_data]).to be_an(Array)
      expect(comparison[:plot_data].first).to include(:x, :y, :function_name)
    end
  end

  describe '.training_visualization' do
    let(:training_history) do
      {
        epochs: (1..10).to_a,
        loss: 10.times.map { |i| 1.0 / (i + 1) },
        accuracy: 10.times.map { |i| i * 0.1 }
      }
    end

    it 'generates training plots' do
      viz = described_class.training_visualization(training_history)
      
      expect(viz[:loss_plot]).to be_an(Array)
      expect(viz[:accuracy_plot]).to be_an(Array)
    end

    it 'provides interpretation' do
      viz = described_class.training_visualization(training_history)
      
      expect(viz[:interpretation]).to include(:convergence, :overfitting_risk)
    end
  end

  describe '.debug_neural_network' do
    let(:nn) { described_class.create_neural_network_example(:xor) }

    it 'provides debugging information' do
      debug_info = described_class.debug_neural_network(nn)
      
      expect(debug_info).to include(
        :architecture,
        :weight_statistics,
        :gradient_flow,
        :activation_patterns
      )
    end

    it 'suggests improvements' do
      debug_info = described_class.debug_neural_network(nn)
      
      expect(debug_info[:suggestions]).to be_an(Array)
    end
  end

  describe '.common_pitfalls' do
    it 'lists common neural network pitfalls' do
      pitfalls = described_class.common_pitfalls
      
      expect(pitfalls).to be_an(Array)
      expect(pitfalls.first).to include(
        :issue,
        :symptoms,
        :causes,
        :solutions
      )
    end
  end

  describe '.hyperparameter_guide' do
    it 'provides hyperparameter tuning guide' do
      guide = described_class.hyperparameter_guide
      
      expect(guide).to include(
        :learning_rate,
        :batch_size,
        :hidden_layers,
        :neurons_per_layer
      )
    end

    it 'includes tuning strategies' do
      guide = described_class.hyperparameter_guide
      
      expect(guide[:strategies]).to include(
        'Grid Search',
        'Random Search',
        'Bayesian Optimization'
      )
    end
  end

  describe '.create_dataset_for_nn' do
    it 'creates appropriate datasets for neural networks' do
      dataset = described_class.create_dataset_for_nn(:classification)
      
      expect(dataset).to be_a(Ai4r::Data::DataSet)
      expect(dataset.data_items).not_to be_empty
    end

    it 'normalizes data appropriately' do
      dataset = described_class.create_dataset_for_nn(:regression)
      
      # Check that values are normalized
      values = dataset.data_items.flatten.select { |v| v.is_a?(Numeric) }
      expect(values.max).to be <= 1.0
      expect(values.min).to be >= -1.0
    end
  end
end