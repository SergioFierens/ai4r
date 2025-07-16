# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/educational_neural_network'

RSpec.describe Ai4r::NeuralNetwork::EducationalNeuralNetwork do
  describe 'Initialization' do
    it 'creates backpropagation network by default' do
      nn = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new
      
      expect(nn.network).to be_a(Ai4r::NeuralNetwork::Backpropagation)
      expect(nn.monitor).to be_a(Ai4r::NeuralNetwork::NeuralNetworkMonitor)
      expect(nn.configuration).to be_a(Ai4r::NeuralNetwork::NeuralNetworkConfiguration)
      expect(nn.training_history).to eq([])
    end

    it 'creates network with custom structure' do
      nn = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [4, 5, 3])
      
      expect(nn.network.structure).to eq([4, 5, 3])
    end

    it 'creates hopfield network' do
      nn = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:hopfield, [10])
      
      expect(nn.network).to be_a(Ai4r::NeuralNetwork::Hopfield)
    end

    it 'accepts configuration options' do
      config = { learning_rate: 0.5, momentum: 0.8, verbose: true }
      nn = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 3, 1], config)
      
      expect(nn.configuration.learning_rate).to eq(0.5)
      expect(nn.configuration.momentum).to eq(0.8)
      expect(nn.configuration.verbose).to be true
    end
  end

  describe '#enable_step_mode' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new }

    it 'enables step-by-step execution' do
      result = nn.enable_step_mode
      
      expect(result).to eq(nn) # Returns self for chaining
      expect(nn.instance_variable_get(:@step_mode)).to be true
    end
  end

  describe '#enable_visualization' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new }

    it 'enables visualization output' do
      result = nn.enable_visualization
      
      expect(result).to eq(nn) # Returns self for chaining
      expect(nn.instance_variable_get(:@visualization_enabled)).to be true
    end
  end

  describe '#configure' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new }

    it 'updates configuration parameters' do
      nn.configure(learning_rate: 0.1, momentum: 0.95)
      
      expect(nn.configuration.learning_rate).to eq(0.1)
      expect(nn.configuration.momentum).to eq(0.95)
    end

    it 'returns self for method chaining' do
      result = nn.configure(learning_rate: 0.1)
      expect(result).to eq(nn)
    end

    it 'explains changes when verbose' do
      nn.configuration.verbose = true
      expect(nn.configuration).to receive(:explain_changes)
      
      nn.configure(learning_rate: 0.1)
    end
  end

  describe '#train_with_explanation' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 2, 1]) }
    let(:training_data) do
      [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
      ]
    end

    it 'trains network and records history' do
      initial_error = nn.network.eval([0, 1])[0]
      
      nn.train_with_explanation(training_data, epochs: 10, show_progress: false)
      
      expect(nn.training_history).not_to be_empty
      expect(nn.training_history.last[:epoch]).to eq(10)
      
      # Network should have learned something
      final_error = (nn.network.eval([0, 1])[0] - 1).abs
      expect(final_error).to be < initial_error.abs
    end

    it 'shows progress when enabled' do
      expect(nn).to receive(:show_training_progress).at_least(:once)
      
      nn.train_with_explanation(training_data, epochs: 1, show_progress: true)
    end

    it 'executes step by step when enabled' do
      nn.enable_step_mode
      allow(nn).to receive(:wait_for_user_input)
      
      nn.train_with_explanation(training_data, epochs: 1, show_progress: false)
      
      expect(nn).to have_received(:wait_for_user_input).at_least(:once)
    end
  end

  describe '#predict_with_explanation' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 3, 1]) }

    it 'makes prediction and explains process' do
      input = [0.5, 0.7]
      result = nn.predict_with_explanation(input)
      
      expect(result).to be_a(Hash)
      expect(result[:input]).to eq(input)
      expect(result[:output]).to be_an(Array)
      expect(result[:layer_outputs]).to be_an(Array)
      expect(result[:explanation]).to be_a(String)
    end

    it 'includes activation details' do
      result = nn.predict_with_explanation([0.5, 0.7])
      
      expect(result[:layer_outputs].size).to eq(2) # Hidden and output layer
      result[:layer_outputs].each do |layer_output|
        expect(layer_output).to be_an(Array)
      end
    end
  end

  describe '#analyze_network' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 4, 3, 1]) }

    it 'provides comprehensive network analysis' do
      analysis = nn.analyze_network
      
      expect(analysis).to be_a(Hash)
      expect(analysis[:structure]).to eq([2, 4, 3, 1])
      expect(analysis[:total_parameters]).to be > 0
      expect(analysis[:layer_details]).to be_an(Array)
      expect(analysis[:complexity]).to be_a(String)
    end

    it 'calculates correct parameter counts' do
      analysis = nn.analyze_network
      
      # 2->4: 2*4 + 4 = 12
      # 4->3: 4*3 + 3 = 15
      # 3->1: 3*1 + 1 = 4
      # Total: 31
      expect(analysis[:total_parameters]).to eq(31)
    end
  end

  describe '#visualize_network' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 3, 1]) }

    it 'generates ASCII visualization' do
      viz = nn.visualize_network
      
      expect(viz).to include('Neural Network Architecture')
      expect(viz).to include('Input Layer')
      expect(viz).to include('Hidden Layer')
      expect(viz).to include('Output Layer')
      expect(viz).to match(/\[2\].*\[3\].*\[1\]/)
    end
  end

  describe '#explain_concept' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new }

    it 'explains neural network concepts' do
      concepts = [:backpropagation, :gradient_descent, :activation_function, :overfitting]
      
      concepts.each do |concept|
        explanation = nn.explain_concept(concept)
        expect(explanation).to be_a(String)
        expect(explanation.length).to be > 50
      end
    end

    it 'returns unknown concept message for invalid concepts' do
      explanation = nn.explain_concept(:unknown_concept)
      expect(explanation).to include('not found')
    end
  end

  describe '#demonstrate_learning' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 2, 1]) }

    it 'demonstrates learning process on simple problem' do
      demo_result = nn.demonstrate_learning(:xor, epochs: 50, show_progress: false)
      
      expect(demo_result).to be_a(Hash)
      expect(demo_result[:problem]).to eq(:xor)
      expect(demo_result[:initial_error]).to be > 0
      expect(demo_result[:final_error]).to be < demo_result[:initial_error]
      expect(demo_result[:success]).to be true
    end

    it 'supports different demonstration problems' do
      problems = [:xor, :and, :or]
      
      problems.each do |problem|
        demo_result = nn.demonstrate_learning(problem, epochs: 10, show_progress: false)
        expect(demo_result[:problem]).to eq(problem)
      end
    end
  end

  describe '#experiment' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 2, 1]) }

    it 'runs learning rate experiment' do
      result = nn.experiment(:learning_rate, [0.01, 0.1, 0.5], epochs: 10)
      
      expect(result).to be_a(Hash)
      expect(result[:experiment_type]).to eq(:learning_rate)
      expect(result[:results]).to have_key(0.01)
      expect(result[:results]).to have_key(0.1)
      expect(result[:results]).to have_key(0.5)
      expect(result[:best_value]).to be_a(Float)
    end

    it 'runs network structure experiment' do
      result = nn.experiment(:hidden_neurons, [2, 4, 8], epochs: 10)
      
      expect(result[:experiment_type]).to eq(:hidden_neurons)
      expect(result[:results].keys).to eq([2, 4, 8])
    end
  end

  describe '#get_insights' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(:backpropagation, [2, 3, 1]) }

    it 'provides learning insights after training' do
      training_data = [
        { input: [0, 0], output: [0] },
        { input: [1, 1], output: [1] }
      ]
      
      nn.train_with_explanation(training_data, epochs: 20, show_progress: false)
      insights = nn.get_insights
      
      expect(insights).to be_a(Hash)
      expect(insights[:training_summary]).to be_a(String)
      expect(insights[:convergence_analysis]).to be_a(String)
      expect(insights[:recommendations]).to be_an(Array)
    end
  end

  describe 'NeuralNetworkConfiguration' do
    let(:config) { Ai4r::NeuralNetwork::NeuralNetworkConfiguration.new }

    it 'has default values' do
      expect(config.learning_rate).to eq(0.25)
      expect(config.momentum).to eq(0.1)
      expect(config.max_error).to eq(0.001)
      expect(config.verbose).to be false
    end

    it 'updates values' do
      config.update(learning_rate: 0.5, verbose: true)
      
      expect(config.learning_rate).to eq(0.5)
      expect(config.verbose).to be true
    end

    it 'validates learning rate' do
      expect { config.update(learning_rate: -0.1) }
        .to raise_error(ArgumentError, /Learning rate must be positive/)
      
      expect { config.update(learning_rate: 2.0) }
        .to raise_error(ArgumentError, /Learning rate must be less than 1/)
    end

    it 'validates momentum' do
      expect { config.update(momentum: -0.1) }
        .to raise_error(ArgumentError, /Momentum must be non-negative/)
      
      expect { config.update(momentum: 1.1) }
        .to raise_error(ArgumentError, /Momentum must be less than 1/)
    end
  end

  describe 'NeuralNetworkMonitor' do
    let(:monitor) { Ai4r::NeuralNetwork::NeuralNetworkMonitor.new }

    it 'records epoch data' do
      monitor.record_epoch(1, 0.5, 0.85)
      monitor.record_epoch(2, 0.3, 0.90)
      
      history = monitor.get_history
      expect(history[:epochs]).to eq([1, 2])
      expect(history[:errors]).to eq([0.5, 0.3])
      expect(history[:accuracies]).to eq([0.85, 0.90])
    end

    it 'tracks weight changes' do
      monitor.record_weight_change(0, 1.5)
      monitor.record_weight_change(1, 0.8)
      
      changes = monitor.get_weight_changes
      expect(changes[0]).to eq([1.5])
      expect(changes[1]).to eq([0.8])
    end

    it 'analyzes convergence' do
      10.times { |i| monitor.record_epoch(i, 1.0 / (i + 1), nil) }
      
      analysis = monitor.analyze_convergence
      expect(analysis[:converged]).to be true
      expect(analysis[:rate]).to be > 0
    end

    it 'generates summary' do
      5.times { |i| monitor.record_epoch(i, 0.5 - i * 0.1, 0.5 + i * 0.1) }
      
      summary = monitor.summary
      expect(summary).to include('Training Summary')
      expect(summary).to include('Final error: 0.1')
      expect(summary).to include('Final accuracy: 0.9')
    end
  end

  describe 'Educational utilities' do
    let(:nn) { Ai4r::NeuralNetwork::EducationalNeuralNetwork.new }

    it 'provides learning resources' do
      resources = nn.learning_resources
      
      expect(resources).to be_a(Hash)
      expect(resources[:tutorials]).to be_an(Array)
      expect(resources[:exercises]).to be_an(Array)
      expect(resources[:references]).to be_an(Array)
    end

    it 'generates quiz questions' do
      quiz = nn.generate_quiz(:beginner)
      
      expect(quiz).to be_an(Array)
      expect(quiz.first).to include(:question, :options, :answer, :explanation)
    end

    it 'checks understanding' do
      result = nn.check_understanding(:backpropagation, 'weight adjustment')
      
      expect(result).to be_a(Hash)
      expect(result[:correct]).to be(true).or be(false)
      expect(result[:feedback]).to be_a(String)
    end
  end
end