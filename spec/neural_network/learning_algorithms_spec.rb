# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/learning_algorithms'

RSpec.describe Ai4r::NeuralNetwork::LearningAlgorithms do
  describe 'GradientDescent' do
    let(:gd) { Ai4r::NeuralNetwork::LearningAlgorithms::GradientDescent.new }
    let(:custom_gd) { Ai4r::NeuralNetwork::LearningAlgorithms::GradientDescent.new(0.1) }

    it 'initializes with default learning rate' do
      expect(gd.learning_rate).to eq(0.01)
    end

    it 'initializes with custom learning rate' do
      expect(custom_gd.learning_rate).to eq(0.1)
    end

    describe '#update_weight' do
      it 'updates weight correctly' do
        current_weight = 1.0
        gradient = 0.5
        new_weight = gd.update_weight(current_weight, gradient)
        expect(new_weight).to eq(0.995) # 1.0 - (0.01 * 0.5)
      end

      it 'ignores step parameter' do
        expect(gd.update_weight(1.0, 0.5, 'ignored')).to eq(0.995)
      end
    end

    it 'provides description' do
      expect(gd.description).to include('Standard Gradient Descent')
    end

    it 'provides characteristics' do
      chars = gd.characteristics
      expect(chars[:memory_usage]).to eq('None')
      expect(chars[:convergence_speed]).to eq('Slow')
      expect(chars[:parameter_sensitivity]).to eq('High')
      expect(chars[:computational_cost]).to eq('Low')
    end
  end

  describe 'Momentum' do
    let(:momentum) { Ai4r::NeuralNetwork::LearningAlgorithms::Momentum.new }
    let(:custom_momentum) { Ai4r::NeuralNetwork::LearningAlgorithms::Momentum.new(0.1, 0.8) }

    it 'initializes with default parameters' do
      expect(momentum.learning_rate).to eq(0.01)
      expect(momentum.momentum_factor).to eq(0.9)
    end

    it 'initializes with custom parameters' do
      expect(custom_momentum.learning_rate).to eq(0.1)
      expect(custom_momentum.momentum_factor).to eq(0.8)
    end

    describe '#update_weight' do
      it 'updates weight with momentum' do
        weight_id = 'w1'
        
        # First update
        new_weight = momentum.update_weight(1.0, 0.5, weight_id)
        expect(new_weight).to eq(0.995) # First update is like regular GD
        
        # Second update - momentum kicks in
        new_weight2 = momentum.update_weight(new_weight, 0.5, weight_id)
        expect(new_weight2).to be < 0.990 # Accelerated by momentum
      end

      it 'maintains separate velocities for different weights' do
        momentum.update_weight(1.0, 0.5, 'w1')
        momentum.update_weight(2.0, 0.3, 'w2')
        
        # Velocities should be different
        v1 = momentum.instance_variable_get(:@velocity)['w1']
        v2 = momentum.instance_variable_get(:@velocity)['w2']
        expect(v1).not_to eq(v2)
      end
    end

    it 'provides description' do
      expect(momentum.description).to include('Momentum')
    end

    it 'provides characteristics' do
      chars = momentum.characteristics
      expect(chars[:memory_usage]).to eq('1x parameters')
      expect(chars[:convergence_speed]).to eq('Fast')
    end
  end

  describe 'AdaGrad' do
    let(:adagrad) { Ai4r::NeuralNetwork::LearningAlgorithms::AdaGrad.new }
    let(:custom_adagrad) { Ai4r::NeuralNetwork::LearningAlgorithms::AdaGrad.new(0.1, 1e-7) }

    it 'initializes with default parameters' do
      expect(adagrad.learning_rate).to eq(0.01)
      expect(adagrad.instance_variable_get(:@epsilon)).to eq(1e-8)
    end

    it 'initializes with custom parameters' do
      expect(custom_adagrad.learning_rate).to eq(0.1)
      expect(custom_adagrad.instance_variable_get(:@epsilon)).to eq(1e-7)
    end

    describe '#update_weight' do
      it 'adapts learning rate based on gradient history' do
        weight_id = 'w1'
        
        # Large gradient
        new_weight1 = adagrad.update_weight(1.0, 10.0, weight_id)
        
        # Same gradient again - should have smaller update
        new_weight2 = adagrad.update_weight(new_weight1, 10.0, weight_id)
        update1 = 1.0 - new_weight1
        update2 = new_weight1 - new_weight2
        
        expect(update2.abs).to be < update1.abs
      end

      it 'handles zero gradients safely' do
        weight_id = 'w1'
        new_weight = adagrad.update_weight(1.0, 0.0, weight_id)
        expect(new_weight).to eq(1.0)
      end
    end

    it 'provides characteristics' do
      chars = adagrad.characteristics
      expect(chars[:memory_usage]).to eq('1x parameters')
      expect(chars[:convergence_speed]).to eq('Medium')
    end
  end

  describe 'RMSProp' do
    let(:rmsprop) { Ai4r::NeuralNetwork::LearningAlgorithms::RMSProp.new }
    let(:custom_rmsprop) { Ai4r::NeuralNetwork::LearningAlgorithms::RMSProp.new(0.001, 0.99, 1e-7) }

    it 'initializes with default parameters' do
      expect(rmsprop.learning_rate).to eq(0.001)
      expect(rmsprop.instance_variable_get(:@rho)).to eq(0.9)
    end

    it 'initializes with custom parameters' do
      expect(custom_rmsprop.learning_rate).to eq(0.001)
      expect(custom_rmsprop.instance_variable_get(:@rho)).to eq(0.99)
    end

    describe '#update_weight' do
      it 'uses exponential moving average of squared gradients' do
        weight_id = 'w1'
        
        # Multiple updates
        weight = 1.0
        3.times do |i|
          gradient = 0.5 * (i + 1)
          weight = rmsprop.update_weight(weight, gradient, weight_id)
        end
        
        expect(weight).to be < 1.0
      end

      it 'handles different weights independently' do
        rmsprop.update_weight(1.0, 1.0, 'w1')
        rmsprop.update_weight(1.0, 0.1, 'w2')
        
        avg1 = rmsprop.instance_variable_get(:@avg_sq_grad)['w1']
        avg2 = rmsprop.instance_variable_get(:@avg_sq_grad)['w2']
        expect(avg1).to be > avg2
      end
    end

    it 'provides characteristics' do
      chars = rmsprop.characteristics
      expect(chars[:adaptive]).to eq('Yes')
      expect(chars[:recommended_for]).to include('recurrent')
    end
  end

  describe 'Adam' do
    let(:adam) { Ai4r::NeuralNetwork::LearningAlgorithms::Adam.new }
    let(:custom_adam) { Ai4r::NeuralNetwork::LearningAlgorithms::Adam.new(0.0001, 0.95, 0.99, 1e-7) }

    it 'initializes with default parameters' do
      expect(adam.learning_rate).to eq(0.001)
    end

    it 'initializes with custom parameters' do
      expect(custom_adam.learning_rate).to eq(0.0001)
      expect(custom_adam.instance_variable_get(:@beta1)).to eq(0.95)
      expect(custom_adam.instance_variable_get(:@beta2)).to eq(0.99)
    end

    describe '#update_weight' do
      it 'combines momentum and adaptive learning rates' do
        weight_id = 'w1'
        
        # First update
        new_weight = adam.update_weight(1.0, 0.1, weight_id)
        expect(new_weight).to be < 1.0
        
        # Track step count
        expect(adam.instance_variable_get(:@step)[weight_id]).to eq(1)
      end

      it 'applies bias correction' do
        weight_id = 'w1'
        
        # Early updates should have larger bias correction
        weight = 1.0
        first_update = adam.update_weight(weight, 0.1, weight_id)
        first_delta = weight - first_update
        
        # Later updates
        weight = first_update
        10.times { weight = adam.update_weight(weight, 0.1, weight_id) }
        
        last_update = adam.update_weight(weight, 0.1, weight_id)
        last_delta = weight - last_update
        
        # First update should be larger due to bias correction
        expect(first_delta.abs).to be > last_delta.abs
      end

      it 'handles zero gradients' do
        weight_id = 'w1'
        new_weight = adam.update_weight(1.0, 0.0, weight_id)
        expect(new_weight).to eq(1.0)
      end
    end

    it 'provides description' do
      expect(adam.description).to include('Adam')
      expect(adam.description).to include('momentum')
    end

    it 'provides characteristics' do
      chars = adam.characteristics
      expect(chars[:memory_usage]).to eq('2x parameters')
      expect(chars[:adaptive]).to eq('Yes')
      expect(chars[:bias_correction]).to eq('Yes')
    end
  end

  describe 'Nadam' do
    let(:nadam) { Ai4r::NeuralNetwork::LearningAlgorithms::Nadam.new }

    it 'initializes with correct parameters' do
      expect(nadam.learning_rate).to eq(0.001)
    end

    describe '#update_weight' do
      it 'applies Nesterov momentum to Adam' do
        weight_id = 'w1'
        
        # Multiple updates to see Nesterov effect
        weight = 1.0
        updates = []
        5.times do
          weight = nadam.update_weight(weight, 0.1, weight_id)
          updates << weight
        end
        
        # Should converge
        expect(updates.last).to be < updates.first
      end
    end

    it 'provides characteristics' do
      chars = nadam.characteristics
      expect(chars[:combines]).to include('Nesterov')
      expect(chars[:combines]).to include('Adam')
    end
  end

  describe 'Factory methods' do
    it 'creates correct learning algorithm by symbol' do
      expect(Ai4r::NeuralNetwork::LearningAlgorithms.create(:gradient_descent))
        .to be_a(Ai4r::NeuralNetwork::LearningAlgorithms::GradientDescent)
      expect(Ai4r::NeuralNetwork::LearningAlgorithms.create(:momentum))
        .to be_a(Ai4r::NeuralNetwork::LearningAlgorithms::Momentum)
      expect(Ai4r::NeuralNetwork::LearningAlgorithms.create(:adagrad))
        .to be_a(Ai4r::NeuralNetwork::LearningAlgorithms::AdaGrad)
      expect(Ai4r::NeuralNetwork::LearningAlgorithms.create(:rmsprop))
        .to be_a(Ai4r::NeuralNetwork::LearningAlgorithms::RMSProp)
      expect(Ai4r::NeuralNetwork::LearningAlgorithms.create(:adam))
        .to be_a(Ai4r::NeuralNetwork::LearningAlgorithms::Adam)
      expect(Ai4r::NeuralNetwork::LearningAlgorithms.create(:nadam))
        .to be_a(Ai4r::NeuralNetwork::LearningAlgorithms::Nadam)
    end

    it 'passes options to algorithms' do
      momentum = Ai4r::NeuralNetwork::LearningAlgorithms.create(:momentum, learning_rate: 0.05)
      expect(momentum.learning_rate).to eq(0.05)
    end

    it 'raises error for unknown algorithm' do
      expect { Ai4r::NeuralNetwork::LearningAlgorithms.create(:unknown) }
        .to raise_error(ArgumentError, /Unknown learning algorithm/)
    end
  end

  describe 'Available algorithms list' do
    it 'returns list of available algorithms' do
      available = Ai4r::NeuralNetwork::LearningAlgorithms.available
      expect(available).to include(:gradient_descent, :momentum, :adagrad, :rmsprop, :adam, :nadam)
    end
  end

  describe 'Educational comparison' do
    it 'provides comparison table' do
      comparison = Ai4r::NeuralNetwork::LearningAlgorithms.comparison_table
      expect(comparison).to be_a(Hash)
      expect(comparison.keys).to include(:gradient_descent, :momentum, :adam)
      
      # Check structure
      adam_info = comparison[:adam]
      expect(adam_info).to include(:memory_usage, :convergence_speed)
    end
  end
end