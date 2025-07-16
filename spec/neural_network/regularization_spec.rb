# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/regularization'

RSpec.describe Ai4r::NeuralNetwork::Regularization do
  describe 'Base RegularizationTechnique' do
    let(:base_reg) { Ai4r::NeuralNetwork::Regularization::RegularizationTechnique.new }

    it 'returns inputs unchanged in forward pass' do
      inputs = [1.0, 2.0, 3.0]
      expect(base_reg.apply_forward(inputs)).to eq(inputs)
      expect(base_reg.apply_forward(inputs, false)).to eq(inputs)
    end

    it 'returns gradients unchanged in backward pass' do
      gradients = [0.1, 0.2, 0.3]
      expect(base_reg.apply_backward(gradients)).to eq(gradients)
    end

    it 'returns zero penalty' do
      weights = [[1.0, 2.0], [3.0, 4.0]]
      expect(base_reg.penalty(weights)).to eq(0.0)
    end

    it 'provides educational notes' do
      expect(base_reg.educational_notes).to eq('Base regularization technique')
    end
  end

  describe 'Dropout' do
    let(:dropout) { Ai4r::NeuralNetwork::Regularization::Dropout.new }
    let(:custom_dropout) { Ai4r::NeuralNetwork::Regularization::Dropout.new(0.3) }

    it 'initializes with default rate' do
      expect(dropout.rate).to eq(0.5)
      expect(dropout.mask).to be_nil
    end

    it 'initializes with custom rate' do
      expect(custom_dropout.rate).to eq(0.3)
    end

    describe '#apply_forward' do
      context 'during training' do
        it 'applies dropout with scaling' do
          inputs = [1.0, 2.0, 3.0, 4.0, 5.0]
          
          # Set random seed for predictability
          srand(123)
          result = dropout.apply_forward(inputs, true)
          
          # Some values should be zero, others scaled
          expect(result.count(0.0)).to be > 0
          expect(result.count(0.0)).to be < inputs.size
          
          # Non-zero values should be scaled up
          non_zero = result.reject { |x| x == 0.0 }
          non_zero.each_with_index do |val, i|
            original_idx = result.index(val)
            expect(val).to be > inputs[original_idx]
          end
        end

        it 'creates and stores mask' do
          inputs = [1.0, 2.0, 3.0]
          dropout.apply_forward(inputs, true)
          
          expect(dropout.mask).not_to be_nil
          expect(dropout.mask.size).to eq(inputs.size)
          expect(dropout.mask).to all(satisfy { |m| m == 0.0 || m == 2.0 })
        end

        it 'applies different masks each time' do
          inputs = [1.0, 2.0, 3.0, 4.0, 5.0]
          
          result1 = dropout.apply_forward(inputs, true)
          result2 = dropout.apply_forward(inputs, true)
          
          expect(result1).not_to eq(result2)
        end
      end

      context 'during inference' do
        it 'returns inputs unchanged' do
          inputs = [1.0, 2.0, 3.0, 4.0, 5.0]
          result = dropout.apply_forward(inputs, false)
          
          expect(result).to eq(inputs)
          expect(dropout.mask).to be_nil
        end
      end
    end

    describe '#apply_backward' do
      it 'applies same mask to gradients' do
        inputs = [1.0, 2.0, 3.0, 4.0]
        gradients = [0.1, 0.2, 0.3, 0.4]
        
        # Forward pass to create mask
        forward_result = dropout.apply_forward(inputs, true)
        mask = dropout.mask.dup
        
        # Backward pass
        backward_result = dropout.apply_backward(gradients)
        
        # Check mask is applied correctly
        gradients.each_with_index do |grad, i|
          expect(backward_result[i]).to eq(grad * mask[i])
        end
      end

      it 'returns gradients unchanged without mask' do
        gradients = [0.1, 0.2, 0.3]
        dropout.instance_variable_set(:@mask, nil)
        
        expect(dropout.apply_backward(gradients)).to eq(gradients)
      end
    end

    it 'provides educational notes' do
      notes = dropout.educational_notes
      expect(notes).to include('Dropout')
      expect(notes).to include('overfitting')
      expect(notes).to include('co-adaptation')
    end
  end

  describe 'L1Regularization' do
    let(:l1) { Ai4r::NeuralNetwork::Regularization::L1Regularization.new }
    let(:custom_l1) { Ai4r::NeuralNetwork::Regularization::L1Regularization.new(0.005) }

    it 'initializes with default lambda' do
      expect(l1.instance_variable_get(:@lambda)).to eq(0.01)
    end

    it 'initializes with custom lambda' do
      expect(custom_l1.instance_variable_get(:@lambda)).to eq(0.005)
    end

    describe '#penalty' do
      it 'calculates L1 penalty for weights' do
        weights = [[1.0, -2.0], [3.0, -4.0]]
        penalty = l1.penalty(weights)
        
        # L1 penalty = lambda * sum(|weights|)
        expected = 0.01 * (1.0 + 2.0 + 3.0 + 4.0)
        expect(penalty).to eq(expected)
      end

      it 'handles nested weight structures' do
        weights = [[[1.0, -1.0]], [[2.0, -2.0]]]
        penalty = l1.penalty(weights)
        
        expected = 0.01 * (1.0 + 1.0 + 2.0 + 2.0)
        expect(penalty).to eq(expected)
      end
    end

    describe '#gradient_penalty' do
      it 'calculates L1 gradient penalty' do
        weights = [[1.0, -2.0], [0.0, 3.0]]
        gradient_penalty = l1.gradient_penalty(weights)
        
        # Gradient of L1 = lambda * sign(weights)
        expect(gradient_penalty[0][0]).to eq(0.01)  # sign(1.0) * lambda
        expect(gradient_penalty[0][1]).to eq(-0.01) # sign(-2.0) * lambda
        expect(gradient_penalty[1][0]).to eq(0.0)   # sign(0.0) * lambda
        expect(gradient_penalty[1][1]).to eq(0.01)  # sign(3.0) * lambda
      end
    end

    it 'provides educational notes' do
      notes = l1.educational_notes
      expect(notes).to include('L1 Regularization')
      expect(notes).to include('sparse')
      expect(notes).to include('feature selection')
    end
  end

  describe 'L2Regularization' do
    let(:l2) { Ai4r::NeuralNetwork::Regularization::L2Regularization.new }
    let(:custom_l2) { Ai4r::NeuralNetwork::Regularization::L2Regularization.new(0.005) }

    it 'initializes with default lambda' do
      expect(l2.instance_variable_get(:@lambda)).to eq(0.01)
    end

    it 'initializes with custom lambda' do
      expect(custom_l2.instance_variable_get(:@lambda)).to eq(0.005)
    end

    describe '#penalty' do
      it 'calculates L2 penalty for weights' do
        weights = [[1.0, 2.0], [3.0, 4.0]]
        penalty = l2.penalty(weights)
        
        # L2 penalty = 0.5 * lambda * sum(weights^2)
        expected = 0.5 * 0.01 * (1.0 + 4.0 + 9.0 + 16.0)
        expect(penalty).to eq(expected)
      end

      it 'handles nested weight structures' do
        weights = [[[1.0, 2.0]], [[3.0, 4.0]]]
        penalty = l2.penalty(weights)
        
        expected = 0.5 * 0.01 * (1.0 + 4.0 + 9.0 + 16.0)
        expect(penalty).to eq(expected)
      end
    end

    describe '#gradient_penalty' do
      it 'calculates L2 gradient penalty' do
        weights = [[1.0, 2.0], [3.0, 4.0]]
        gradient_penalty = l2.gradient_penalty(weights)
        
        # Gradient of L2 = lambda * weights
        expect(gradient_penalty[0][0]).to eq(0.01 * 1.0)
        expect(gradient_penalty[0][1]).to eq(0.01 * 2.0)
        expect(gradient_penalty[1][0]).to eq(0.01 * 3.0)
        expect(gradient_penalty[1][1]).to eq(0.01 * 4.0)
      end
    end

    it 'provides educational notes' do
      notes = l2.educational_notes
      expect(notes).to include('L2 Regularization')
      expect(notes).to include('weight decay')
      expect(notes).to include('Ridge')
    end
  end

  describe 'BatchNormalization' do
    let(:batch_norm) { Ai4r::NeuralNetwork::Regularization::BatchNormalization.new }
    let(:custom_batch_norm) { Ai4r::NeuralNetwork::Regularization::BatchNormalization.new(momentum: 0.99, epsilon: 1e-4) }

    it 'initializes with default parameters' do
      expect(batch_norm.instance_variable_get(:@momentum)).to eq(0.9)
      expect(batch_norm.instance_variable_get(:@epsilon)).to eq(1e-5)
    end

    it 'initializes with custom parameters' do
      expect(custom_batch_norm.instance_variable_get(:@momentum)).to eq(0.99)
      expect(custom_batch_norm.instance_variable_get(:@epsilon)).to eq(1e-4)
    end

    describe '#apply_forward' do
      context 'during training' do
        it 'normalizes batch and updates running statistics' do
          # Batch of samples
          batch = [
            [1.0, 2.0, 3.0],
            [4.0, 5.0, 6.0],
            [7.0, 8.0, 9.0]
          ]
          
          result = batch_norm.apply_forward(batch, true)
          
          # Check normalization
          result.each do |sample|
            mean = sample.sum / sample.size.to_f
            expect(mean.abs).to be < 0.1 # Should be close to 0
          end
          
          # Check running statistics updated
          expect(batch_norm.running_mean).not_to be_nil
          expect(batch_norm.running_var).not_to be_nil
        end

        it 'stores values for backward pass' do
          batch = [[1.0, 2.0], [3.0, 4.0]]
          batch_norm.apply_forward(batch, true)
          
          expect(batch_norm.instance_variable_get(:@cache)).not_to be_nil
        end
      end

      context 'during inference' do
        it 'uses running statistics' do
          # Set up running statistics
          batch_norm.running_mean = [5.0, 5.0, 5.0]
          batch_norm.running_var = [1.0, 1.0, 1.0]
          batch_norm.gamma = [1.0, 1.0, 1.0]
          batch_norm.beta = [0.0, 0.0, 0.0]
          
          inputs = [[4.0, 5.0, 6.0]]
          result = batch_norm.apply_forward(inputs, false)
          
          # Should use running stats, not batch stats
          expect(result[0][0]).to be_within(0.1).of(-1.0)
          expect(result[0][1]).to be_within(0.1).of(0.0)
          expect(result[0][2]).to be_within(0.1).of(1.0)
        end
      end
    end

    describe '#apply_backward' do
      it 'computes gradients correctly' do
        batch = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]
        gradients = [[0.1, 0.2], [0.3, 0.4], [0.5, 0.6]]
        
        # Forward pass to set up cache
        batch_norm.apply_forward(batch, true)
        
        # Backward pass
        grad_result = batch_norm.apply_backward(gradients)
        
        expect(grad_result).to be_an(Array)
        expect(grad_result.size).to eq(batch.size)
        expect(grad_result[0].size).to eq(batch[0].size)
      end
    end

    it 'provides educational notes' do
      notes = batch_norm.educational_notes
      expect(notes).to include('Batch Normalization')
      expect(notes).to include('internal covariate shift')
      expect(notes).to include('training stability')
    end
  end

  describe 'ElasticNet' do
    let(:elastic_net) { Ai4r::NeuralNetwork::Regularization::ElasticNet.new }
    let(:custom_elastic) { Ai4r::NeuralNetwork::Regularization::ElasticNet.new(l1_lambda: 0.005, l2_lambda: 0.01, ratio: 0.7) }

    it 'initializes with default parameters' do
      expect(elastic_net.instance_variable_get(:@l1_lambda)).to eq(0.01)
      expect(elastic_net.instance_variable_get(:@l2_lambda)).to eq(0.01)
      expect(elastic_net.instance_variable_get(:@ratio)).to eq(0.5)
    end

    it 'initializes with custom parameters' do
      expect(custom_elastic.instance_variable_get(:@l1_lambda)).to eq(0.005)
      expect(custom_elastic.instance_variable_get(:@l2_lambda)).to eq(0.01)
      expect(custom_elastic.instance_variable_get(:@ratio)).to eq(0.7)
    end

    describe '#penalty' do
      it 'combines L1 and L2 penalties' do
        weights = [[1.0, -2.0], [3.0, -4.0]]
        penalty = elastic_net.penalty(weights)
        
        # L1 part: 0.5 * 0.01 * (1 + 2 + 3 + 4) = 0.05
        # L2 part: 0.5 * 0.5 * 0.01 * (1 + 4 + 9 + 16) = 0.075
        # Total: 0.05 + 0.075 = 0.125
        expect(penalty).to be_within(0.001).of(0.125)
      end
    end

    describe '#gradient_penalty' do
      it 'combines L1 and L2 gradient penalties' do
        weights = [[1.0, -2.0]]
        gradient_penalty = elastic_net.gradient_penalty(weights)
        
        # L1 gradient: ratio * l1_lambda * sign(w)
        # L2 gradient: (1-ratio) * l2_lambda * w
        expect(gradient_penalty[0][0]).to be_within(0.001).of(0.01) # 0.5*0.01*1 + 0.5*0.01*1
        expect(gradient_penalty[0][1]).to be_within(0.001).of(-0.015) # 0.5*0.01*(-1) + 0.5*0.01*(-2)
      end
    end

    it 'provides educational notes' do
      notes = elastic_net.educational_notes
      expect(notes).to include('Elastic Net')
      expect(notes).to include('combines L1 and L2')
    end
  end

  describe 'Factory method' do
    it 'creates correct regularization technique by symbol' do
      expect(Ai4r::NeuralNetwork::Regularization.create(:dropout))
        .to be_a(Ai4r::NeuralNetwork::Regularization::Dropout)
      expect(Ai4r::NeuralNetwork::Regularization.create(:l1))
        .to be_a(Ai4r::NeuralNetwork::Regularization::L1Regularization)
      expect(Ai4r::NeuralNetwork::Regularization.create(:l2))
        .to be_a(Ai4r::NeuralNetwork::Regularization::L2Regularization)
      expect(Ai4r::NeuralNetwork::Regularization.create(:batch_norm))
        .to be_a(Ai4r::NeuralNetwork::Regularization::BatchNormalization)
      expect(Ai4r::NeuralNetwork::Regularization.create(:elastic_net))
        .to be_a(Ai4r::NeuralNetwork::Regularization::ElasticNet)
    end

    it 'passes options to regularization technique' do
      dropout = Ai4r::NeuralNetwork::Regularization.create(:dropout, rate: 0.3)
      expect(dropout.rate).to eq(0.3)
    end

    it 'raises error for unknown technique' do
      expect { Ai4r::NeuralNetwork::Regularization.create(:unknown) }
        .to raise_error(ArgumentError, /Unknown regularization technique/)
    end
  end

  describe 'Available techniques list' do
    it 'returns list of available techniques' do
      available = Ai4r::NeuralNetwork::Regularization.available
      expect(available).to include(:dropout, :l1, :l2, :batch_norm, :elastic_net)
    end
  end
end