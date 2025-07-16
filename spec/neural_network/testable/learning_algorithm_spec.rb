# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/learning_algorithm'

RSpec.describe Ai4r::NeuralNetwork::Testable::LearningAlgorithm do
  let(:weights) { [[0.5, 0.3], [0.2, 0.4]] }
  let(:gradients) { [[0.1, 0.2], [0.3, 0.1]] }

  describe 'Base class' do
    let(:base_algorithm) { described_class.new }

    it 'raises NotImplementedError for update_weights' do
      expect { base_algorithm.update_weights(weights, gradients) }
        .to raise_error(NotImplementedError, 'Subclasses must implement update_weights')
    end

    it 'tracks iteration count' do
      expect(base_algorithm.iteration_count).to eq(0)
      base_algorithm.step
      expect(base_algorithm.iteration_count).to eq(1)
      base_algorithm.step
      expect(base_algorithm.iteration_count).to eq(2)
    end

    it 'can reset state' do
      base_algorithm.step
      base_algorithm.step
      expect(base_algorithm.iteration_count).to eq(2)
      
      base_algorithm.reset
      expect(base_algorithm.iteration_count).to eq(0)
      expect(base_algorithm.current_state[:internal_state]).to be_empty
    end
  end

  describe 'GradientDescent' do
    let(:gd) { described_class::GradientDescent.new(learning_rate: 0.1) }

    it 'updates weights by subtracting scaled gradients' do
      updated = gd.update_weights(weights, gradients)
      
      expect(updated[0][0]).to be_within(0.0001).of(0.5 - 0.1 * 0.1)  # 0.49
      expect(updated[0][1]).to be_within(0.0001).of(0.3 - 0.1 * 0.2)  # 0.28
      expect(updated[1][0]).to be_within(0.0001).of(0.2 - 0.1 * 0.3)  # 0.17
      expect(updated[1][1]).to be_within(0.0001).of(0.4 - 0.1 * 0.1)  # 0.39
    end

    it 'uses configured learning rate' do
      gd_slow = described_class::GradientDescent.new(learning_rate: 0.01)
      gd_fast = described_class::GradientDescent.new(learning_rate: 1.0)
      
      updated_slow = gd_slow.update_weights(weights, gradients)
      updated_fast = gd_fast.update_weights(weights, gradients)
      
      # Slow learning rate should change weights less
      slow_change = (weights[0][0] - updated_slow[0][0]).abs
      fast_change = (weights[0][0] - updated_fast[0][0]).abs
      expect(slow_change).to be < fast_change
    end

    it 'does not maintain state between updates' do
      updated1 = gd.update_weights(weights, gradients)
      updated2 = gd.update_weights(weights, gradients)
      
      # Should produce same result each time
      expect(updated1).to eq(updated2)
    end
  end

  describe 'Momentum' do
    let(:momentum) { described_class::Momentum.new(learning_rate: 0.1, momentum_factor: 0.9) }

    it 'accumulates velocity over time' do
      # First update - no previous velocity
      updated1 = momentum.update_weights(weights, gradients, 0)
      
      # Second update - includes momentum from first
      updated2 = momentum.update_weights(updated1, gradients, 0)
      
      # With momentum, second update should be larger
      change1 = (weights[0][0] - updated1[0][0]).abs
      change2 = (updated1[0][0] - updated2[0][0]).abs
      
      expect(change2).to be > change1
    end

    it 'maintains separate velocity for each layer' do
      layer1_gradients = [[0.1, 0.1], [0.1, 0.1]]
      layer2_gradients = [[0.2, 0.2], [0.2, 0.2]]
      
      momentum.update_weights(weights, layer1_gradients, 0)
      momentum.update_weights(weights, layer2_gradients, 1)
      
      state = momentum.current_state
      expect(state[:internal_state]).to have_key('layer_0_velocity')
      expect(state[:internal_state]).to have_key('layer_1_velocity')
    end

    it 'momentum factor controls velocity decay' do
      high_momentum = described_class::Momentum.new(learning_rate: 0.1, momentum_factor: 0.99)
      low_momentum = described_class::Momentum.new(learning_rate: 0.1, momentum_factor: 0.1)
      
      # Apply same gradients multiple times
      weights_high = weights
      weights_low = weights
      
      5.times do
        weights_high = high_momentum.update_weights(weights_high, gradients, 0)
        weights_low = low_momentum.update_weights(weights_low, gradients, 0)
      end
      
      # High momentum should result in larger total change
      change_high = (weights[0][0] - weights_high[0][0]).abs
      change_low = (weights[0][0] - weights_low[0][0]).abs
      
      expect(change_high).to be > change_low
    end
  end

  describe 'AdaGrad' do
    let(:adagrad) { described_class::AdaGrad.new(learning_rate: 0.1, epsilon: 1e-8) }

    it 'adapts learning rate based on gradient history' do
      # Apply large gradient
      large_gradients = [[1.0, 0.1], [0.1, 1.0]]
      updated1 = adagrad.update_weights(weights, large_gradients, 0)
      
      # Apply small gradient - learning rate should be reduced for positions with large history
      small_gradients = [[0.1, 0.1], [0.1, 0.1]]
      updated2 = adagrad.update_weights(updated1, small_gradients, 0)
      
      # Check that positions with large gradient history have smaller updates
      change_00 = (updated1[0][0] - updated2[0][0]).abs  # Had large gradient
      change_01 = (updated1[0][1] - updated2[0][1]).abs  # Had small gradient
      
      expect(change_00).to be < change_01
    end

    it 'prevents division by zero with epsilon' do
      zero_gradients = [[0.0, 0.0], [0.0, 0.0]]
      
      expect { adagrad.update_weights(weights, zero_gradients, 0) }.not_to raise_error
    end

    it 'accumulates squared gradients monotonically' do
      state_before = adagrad.current_state
      
      adagrad.update_weights(weights, gradients, 0)
      state_after1 = adagrad.current_state
      
      adagrad.update_weights(weights, gradients, 0)
      state_after2 = adagrad.current_state
      
      # Accumulated gradients should only increase
      acc_grad1 = state_after1[:internal_state]['layer_0_acc_grad']
      acc_grad2 = state_after2[:internal_state]['layer_0_acc_grad']
      
      expect(acc_grad2[0][0]).to be > acc_grad1[0][0]
    end
  end

  describe 'Adam' do
    let(:adam) { described_class::Adam.new(learning_rate: 0.001, beta1: 0.9, beta2: 0.999, epsilon: 1e-8) }

    it 'combines momentum and adaptive learning rates' do
      # Adam should update weights
      updated = adam.update_weights(weights, gradients, 0)
      
      expect(updated).not_to eq(weights)
      
      # Check weight updates are reasonable
      weights.each_with_index do |row, i|
        row.each_with_index do |w, j|
          expect((w - updated[i][j]).abs).to be < 0.1  # Reasonable update size
        end
      end
    end

    it 'applies bias correction' do
      # First few iterations should have bias correction
      updated1 = adam.update_weights(weights, gradients, 0)
      expect(adam.iteration_count).to eq(1)
      
      # Reset and apply many iterations
      adam.reset
      weights_many = weights
      100.times do
        weights_many = adam.update_weights(weights_many, gradients, 0)
      end
      
      # Early iterations should have different behavior due to bias correction
      adam.reset
      early_update = adam.update_weights(weights, gradients, 0)
      
      expect(early_update).not_to eq(weights_many)
    end

    it 'maintains first and second moments separately' do
      adam.update_weights(weights, gradients, 0)
      state = adam.current_state
      
      expect(state[:internal_state]).to have_key('layer_0_m')
      expect(state[:internal_state]).to have_key('layer_0_v')
      
      m = state[:internal_state]['layer_0_m']
      v = state[:internal_state]['layer_0_v']
      
      # Moments should be different (first vs second moment)
      expect(m[0][0]).not_to eq(v[0][0])
    end

    it 'handles sparse gradients well' do
      # Sparse gradients with mostly zeros
      sparse_gradients = [[0.0, 0.5], [0.0, 0.0]]
      
      updated = adam.update_weights(weights, sparse_gradients, 0)
      
      # Should only update non-zero gradient positions significantly
      expect((weights[0][0] - updated[0][0]).abs).to be < 0.0001  # No gradient
      expect((weights[0][1] - updated[0][1]).abs).to be > 0.0001  # Has gradient
    end
  end

  describe 'Factory' do
    it 'creates algorithms by name' do
      gd = described_class::Factory.create(:gradient_descent, learning_rate: 0.5)
      expect(gd).to be_a(described_class::GradientDescent)
      expect(gd.learning_rate).to eq(0.5)
      
      momentum = described_class::Factory.create(:momentum, momentum_factor: 0.95)
      expect(momentum).to be_a(described_class::Momentum)
      expect(momentum.momentum_factor).to eq(0.95)
      
      adagrad = described_class::Factory.create(:adagrad)
      expect(adagrad).to be_a(described_class::AdaGrad)
      
      adam = described_class::Factory.create(:adam, beta1: 0.8)
      expect(adam).to be_a(described_class::Adam)
      expect(adam.beta1).to eq(0.8)
    end

    it 'raises error for unknown algorithm' do
      expect { described_class::Factory.create(:unknown_algorithm) }
        .to raise_error(ArgumentError, 'Unknown algorithm: unknown_algorithm')
    end

    it 'lists available algorithms' do
      available = described_class::Factory.available_algorithms
      expect(available).to include(:gradient_descent, :momentum, :adagrad, :adam)
    end
  end

  describe 'Algorithm comparison' do
    let(:algorithms) do
      {
        gd: described_class::GradientDescent.new(learning_rate: 0.1),
        momentum: described_class::Momentum.new(learning_rate: 0.1, momentum_factor: 0.9),
        adagrad: described_class::AdaGrad.new(learning_rate: 0.1),
        adam: described_class::Adam.new(learning_rate: 0.001)
      }
    end

    it 'all algorithms can handle same weight/gradient shapes' do
      algorithms.each do |name, algo|
        expect { algo.update_weights(weights, gradients) }.not_to raise_error
      end
    end

    it 'algorithms produce different convergence patterns' do
      # Simulate multiple updates with same gradients
      results = {}
      
      algorithms.each do |name, algo|
        current_weights = weights.map(&:dup)
        weight_history = [current_weights]
        
        10.times do
          current_weights = algo.update_weights(current_weights, gradients, 0)
          weight_history << current_weights.map(&:dup)
        end
        
        results[name] = weight_history
      end
      
      # Different algorithms should produce different trajectories
      final_weights = results.transform_values { |history| history.last }
      
      expect(final_weights[:gd]).not_to eq(final_weights[:momentum])
      expect(final_weights[:momentum]).not_to eq(final_weights[:adagrad])
      expect(final_weights[:adagrad]).not_to eq(final_weights[:adam])
    end
  end
end