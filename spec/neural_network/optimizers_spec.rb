# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/optimizers'

RSpec.describe Ai4r::NeuralNetwork::Optimizers do
  describe 'Base Optimizer' do
    let(:optimizer) { Ai4r::NeuralNetwork::Optimizers::Optimizer.new }
    let(:custom_optimizer) { Ai4r::NeuralNetwork::Optimizers::Optimizer.new(0.1) }

    it 'initializes with default learning rate' do
      expect(optimizer.learning_rate).to eq(0.01)
      expect(optimizer.iteration).to eq(0)
    end

    it 'initializes with custom learning rate' do
      expect(custom_optimizer.learning_rate).to eq(0.1)
    end

    it 'raises NotImplementedError for update method' do
      expect { optimizer.update([1.0], [0.1]) }
        .to raise_error(NotImplementedError, 'Subclass must implement update method')
    end

    describe '#step' do
      it 'increments iteration counter' do
        expect { optimizer.step }.to change { optimizer.iteration }.from(0).to(1)
        optimizer.step
        expect(optimizer.iteration).to eq(2)
      end
    end

    describe '#reset' do
      it 'resets iteration counter' do
        3.times { optimizer.step }
        expect(optimizer.iteration).to eq(3)
        optimizer.reset
        expect(optimizer.iteration).to eq(0)
      end
    end

    it 'provides educational notes' do
      expect(optimizer.educational_notes).to eq('Base optimizer class')
    end
  end

  describe 'SGD' do
    let(:sgd) { Ai4r::NeuralNetwork::Optimizers::SGD.new }
    let(:custom_sgd) { Ai4r::NeuralNetwork::Optimizers::SGD.new(0.1) }

    describe '#update' do
      it 'updates single parameter' do
        params = [1.0]
        gradients = [0.5]
        updated = sgd.update(params, gradients)
        expect(updated).to eq([0.995]) # 1.0 - (0.01 * 0.5)
      end

      it 'updates multiple parameters' do
        params = [1.0, 2.0, 3.0]
        gradients = [0.1, 0.2, 0.3]
        updated = sgd.update(params, gradients)
        expect(updated[0]).to eq(0.999) # 1.0 - (0.01 * 0.1)
        expect(updated[1]).to eq(1.998) # 2.0 - (0.01 * 0.2)
        expect(updated[2]).to eq(2.997) # 3.0 - (0.01 * 0.3)
      end

      it 'uses custom learning rate' do
        params = [1.0]
        gradients = [0.5]
        updated = custom_sgd.update(params, gradients)
        expect(updated).to eq([0.95]) # 1.0 - (0.1 * 0.5)
      end
    end

    it 'provides educational notes' do
      notes = sgd.educational_notes
      expect(notes).to include('Stochastic Gradient Descent')
      expect(notes).to include('fundamental optimization algorithm')
    end
  end

  describe 'SGDMomentum' do
    let(:sgd_momentum) { Ai4r::NeuralNetwork::Optimizers::SGDMomentum.new }
    let(:custom_momentum) { Ai4r::NeuralNetwork::Optimizers::SGDMomentum.new(0.1, 0.8) }

    it 'initializes with default parameters' do
      expect(sgd_momentum.learning_rate).to eq(0.01)
      expect(sgd_momentum.instance_variable_get(:@momentum)).to eq(0.9)
    end

    it 'initializes with custom parameters' do
      expect(custom_momentum.learning_rate).to eq(0.1)
      expect(custom_momentum.instance_variable_get(:@momentum)).to eq(0.8)
    end

    describe '#update' do
      it 'applies momentum to updates' do
        params = [1.0]
        gradients = [0.5]
        
        # First update
        updated1 = sgd_momentum.update(params, gradients)
        expect(updated1[0]).to eq(0.995)
        
        # Second update with same gradient - momentum accelerates
        updated2 = sgd_momentum.update(updated1, gradients)
        expect(updated2[0]).to be < 0.990
      end

      it 'handles multiple parameters with separate velocities' do
        params = [1.0, 2.0]
        gradients = [0.5, -0.3]
        
        updated = sgd_momentum.update(params, gradients)
        velocities = sgd_momentum.instance_variable_get(:@velocity)
        
        expect(velocities.size).to eq(2)
        expect(velocities[0]).not_to eq(velocities[1])
      end
    end

    it 'provides educational notes' do
      notes = sgd_momentum.educational_notes
      expect(notes).to include('Momentum')
      expect(notes).to include('accelerates')
    end
  end

  describe 'AdamOptimizer' do
    let(:adam) { Ai4r::NeuralNetwork::Optimizers::AdamOptimizer.new }
    let(:custom_adam) { Ai4r::NeuralNetwork::Optimizers::AdamOptimizer.new(0.0001, 0.95, 0.99, 1e-7) }

    it 'initializes with default parameters' do
      expect(adam.learning_rate).to eq(0.001)
      expect(adam.instance_variable_get(:@beta1)).to eq(0.9)
      expect(adam.instance_variable_get(:@beta2)).to eq(0.999)
      expect(adam.instance_variable_get(:@epsilon)).to eq(1e-8)
    end

    it 'initializes with custom parameters' do
      expect(custom_adam.learning_rate).to eq(0.0001)
      expect(custom_adam.instance_variable_get(:@beta1)).to eq(0.95)
      expect(custom_adam.instance_variable_get(:@beta2)).to eq(0.99)
      expect(custom_adam.instance_variable_get(:@epsilon)).to eq(1e-7)
    end

    describe '#update' do
      it 'applies Adam algorithm with bias correction' do
        params = [1.0]
        gradients = [0.1]
        
        # First update
        adam.step # Increment iteration for bias correction
        updated = adam.update(params, gradients)
        expect(updated[0]).to be < 1.0
        
        # Check internal states
        m = adam.instance_variable_get(:@m)
        v = adam.instance_variable_get(:@v)
        expect(m[0]).to be > 0
        expect(v[0]).to be > 0
      end

      it 'handles zero gradients' do
        params = [1.0]
        gradients = [0.0]
        
        adam.step
        updated = adam.update(params, gradients)
        expect(updated[0]).to eq(1.0)
      end

      it 'applies different updates for different parameters' do
        params = [1.0, 1.0]
        gradients = [0.1, 1.0]
        
        adam.step
        updated = adam.update(params, gradients)
        
        # Larger gradient should result in larger update
        update1 = 1.0 - updated[0]
        update2 = 1.0 - updated[1]
        expect(update2.abs).to be > update1.abs
      end
    end

    describe '#reset' do
      it 'resets all internal states' do
        # Use the optimizer
        adam.step
        adam.update([1.0], [0.1])
        
        # Reset
        adam.reset
        
        expect(adam.iteration).to eq(0)
        expect(adam.instance_variable_get(:@m)).to be_empty
        expect(adam.instance_variable_get(:@v)).to be_empty
      end
    end

    it 'provides educational notes' do
      notes = adam.educational_notes
      expect(notes).to include('Adam')
      expect(notes).to include('Adaptive Moment Estimation')
      expect(notes).to include('bias correction')
    end
  end

  describe 'RMSpropOptimizer' do
    let(:rmsprop) { Ai4r::NeuralNetwork::Optimizers::RMSpropOptimizer.new }
    let(:custom_rmsprop) { Ai4r::NeuralNetwork::Optimizers::RMSpropOptimizer.new(0.01, 0.95, 1e-7) }

    it 'initializes with default parameters' do
      expect(rmsprop.learning_rate).to eq(0.001)
      expect(rmsprop.instance_variable_get(:@rho)).to eq(0.9)
      expect(rmsprop.instance_variable_get(:@epsilon)).to eq(1e-8)
    end

    it 'initializes with custom parameters' do
      expect(custom_rmsprop.learning_rate).to eq(0.01)
      expect(custom_rmsprop.instance_variable_get(:@rho)).to eq(0.95)
      expect(custom_rmsprop.instance_variable_get(:@epsilon)).to eq(1e-7)
    end

    describe '#update' do
      it 'adapts learning rate based on gradient magnitude' do
        params = [1.0]
        
        # Large gradient
        large_update = rmsprop.update(params, [10.0])
        
        # Reset for comparison
        rmsprop.reset
        
        # Small gradient
        small_update = rmsprop.update(params, [0.1])
        
        # Updates should be proportionally different
        large_delta = 1.0 - large_update[0]
        small_delta = 1.0 - small_update[0]
        
        # RMSprop normalizes by gradient magnitude
        ratio = large_delta / small_delta
        expect(ratio).to be < 100 # Less than direct proportion
      end

      it 'accumulates squared gradients with decay' do
        params = [1.0]
        gradients = [0.5]
        
        # Multiple updates
        3.times { params = rmsprop.update(params, gradients) }
        
        cache = rmsprop.instance_variable_get(:@cache)
        expect(cache[0]).to be > 0
        expect(cache[0]).to be < 0.5 # Due to exponential averaging
      end
    end

    it 'provides educational notes' do
      notes = rmsprop.educational_notes
      expect(notes).to include('RMSprop')
      expect(notes).to include('Root Mean Square Propagation')
    end
  end

  describe 'AdaGradOptimizer' do
    let(:adagrad) { Ai4r::NeuralNetwork::Optimizers::AdaGradOptimizer.new }
    let(:custom_adagrad) { Ai4r::NeuralNetwork::Optimizers::AdaGradOptimizer.new(0.1, 1e-7) }

    it 'initializes with default parameters' do
      expect(adagrad.learning_rate).to eq(0.01)
      expect(adagrad.instance_variable_get(:@epsilon)).to eq(1e-8)
    end

    it 'initializes with custom parameters' do
      expect(custom_adagrad.learning_rate).to eq(0.1)
      expect(custom_adagrad.instance_variable_get(:@epsilon)).to eq(1e-7)
    end

    describe '#update' do
      it 'accumulates squared gradients without decay' do
        params = [1.0]
        gradients = [0.5]
        
        # First update
        updated1 = adagrad.update(params, gradients)
        cache1 = adagrad.instance_variable_get(:@cache)[0]
        
        # Second update
        updated2 = adagrad.update(updated1, gradients)
        cache2 = adagrad.instance_variable_get(:@cache)[0]
        
        # Cache should accumulate
        expect(cache2).to be > cache1
        expect(cache2).to eq(cache1 + 0.5 * 0.5)
        
        # Updates should get smaller
        update1 = 1.0 - updated1[0]
        update2 = updated1[0] - updated2[0]
        expect(update2.abs).to be < update1.abs
      end

      it 'handles sparse gradients' do
        params = [1.0, 1.0, 1.0]
        # Sparse gradient - only first parameter has non-zero gradient
        gradients = [1.0, 0.0, 0.0]
        
        updated = adagrad.update(params, gradients)
        
        # Only first parameter should change
        expect(updated[0]).not_to eq(1.0)
        expect(updated[1]).to eq(1.0)
        expect(updated[2]).to eq(1.0)
      end
    end

    it 'provides educational notes' do
      notes = adagrad.educational_notes
      expect(notes).to include('AdaGrad')
      expect(notes).to include('Adaptive Gradient')
      expect(notes).to include('sparse')
    end
  end

  describe 'Factory method' do
    it 'creates correct optimizer by symbol' do
      expect(Ai4r::NeuralNetwork::Optimizers.create(:sgd))
        .to be_a(Ai4r::NeuralNetwork::Optimizers::SGD)
      expect(Ai4r::NeuralNetwork::Optimizers.create(:sgd_momentum))
        .to be_a(Ai4r::NeuralNetwork::Optimizers::SGDMomentum)
      expect(Ai4r::NeuralNetwork::Optimizers.create(:adam))
        .to be_a(Ai4r::NeuralNetwork::Optimizers::AdamOptimizer)
      expect(Ai4r::NeuralNetwork::Optimizers.create(:rmsprop))
        .to be_a(Ai4r::NeuralNetwork::Optimizers::RMSpropOptimizer)
      expect(Ai4r::NeuralNetwork::Optimizers.create(:adagrad))
        .to be_a(Ai4r::NeuralNetwork::Optimizers::AdaGradOptimizer)
    end

    it 'passes options to optimizer' do
      adam = Ai4r::NeuralNetwork::Optimizers.create(:adam, learning_rate: 0.01)
      expect(adam.learning_rate).to eq(0.01)
    end

    it 'raises error for unknown optimizer' do
      expect { Ai4r::NeuralNetwork::Optimizers.create(:unknown) }
        .to raise_error(ArgumentError, /Unknown optimizer/)
    end
  end

  describe 'Available optimizers list' do
    it 'returns list of available optimizers' do
      available = Ai4r::NeuralNetwork::Optimizers.available
      expect(available).to include(:sgd, :sgd_momentum, :adam, :rmsprop, :adagrad)
    end
  end
end