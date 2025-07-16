# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/activation_function'

RSpec.describe Ai4r::NeuralNetwork::Testable::ActivationFunction do
  describe 'Base class' do
    let(:base_function) { described_class.new }

    it 'raises NotImplementedError for forward' do
      expect { base_function.forward(0.5) }
        .to raise_error(NotImplementedError, 'Subclasses must implement forward')
    end

    it 'raises NotImplementedError for derivative' do
      expect { base_function.derivative(0.5) }
        .to raise_error(NotImplementedError, 'Subclasses must implement derivative')
    end
  end

  describe 'Sigmoid' do
    let(:sigmoid) { described_class::Sigmoid.new }

    describe '#forward' do
      it 'returns 0.5 for input 0' do
        expect(sigmoid.forward(0)).to be_within(0.0001).of(0.5)
      end

      it 'approaches 1 for large positive values' do
        expect(sigmoid.forward(10)).to be_within(0.0001).of(0.9999)
      end

      it 'approaches 0 for large negative values' do
        expect(sigmoid.forward(-10)).to be_within(0.0001).of(0.0000)
      end
    end

    describe '#derivative' do
      it 'returns 0.25 for y=0.5' do
        expect(sigmoid.derivative(0.5)).to be_within(0.0001).of(0.25)
      end

      it 'approaches 0 for y near 0 or 1' do
        expect(sigmoid.derivative(0.01)).to be_within(0.0001).of(0.0099)
        expect(sigmoid.derivative(0.99)).to be_within(0.0001).of(0.0099)
      end
    end

    it 'derivative matches numerical gradient' do
      x = 0.5
      h = 1e-7
      y = sigmoid.forward(x)
      
      numerical_derivative = (sigmoid.forward(x + h) - sigmoid.forward(x - h)) / (2 * h)
      analytical_derivative = sigmoid.derivative(y)
      
      expect(analytical_derivative).to be_within(1e-5).of(numerical_derivative)
    end
  end

  describe 'Tanh' do
    let(:tanh) { described_class::Tanh.new }

    describe '#forward' do
      it 'returns 0 for input 0' do
        expect(tanh.forward(0)).to eq(0)
      end

      it 'approaches 1 for large positive values' do
        expect(tanh.forward(5)).to be_within(0.0001).of(0.9999)
      end

      it 'approaches -1 for large negative values' do
        expect(tanh.forward(-5)).to be_within(0.0001).of(-0.9999)
      end
    end

    describe '#derivative' do
      it 'returns 1 for y=0' do
        expect(tanh.derivative(0)).to eq(1.0)
      end

      it 'approaches 0 for y near ±1' do
        expect(tanh.derivative(0.99)).to be_within(0.0001).of(0.0199)
        expect(tanh.derivative(-0.99)).to be_within(0.0001).of(0.0199)
      end
    end
  end

  describe 'ReLU' do
    let(:relu) { described_class::ReLU.new }

    describe '#forward' do
      it 'returns 0 for negative input' do
        expect(relu.forward(-1)).to eq(0.0)
        expect(relu.forward(-0.001)).to eq(0.0)
      end

      it 'returns input for positive input' do
        expect(relu.forward(1)).to eq(1.0)
        expect(relu.forward(0.5)).to eq(0.5)
      end

      it 'returns 0 for 0 input' do
        expect(relu.forward(0)).to eq(0.0)
      end
    end

    describe '#derivative' do
      it 'returns 0 for negative values' do
        expect(relu.derivative(-0.5)).to eq(0.0)
      end

      it 'returns 1 for positive values' do
        expect(relu.derivative(0.5)).to eq(1.0)
      end

      it 'returns 0 for 0' do
        expect(relu.derivative(0)).to eq(0.0)
      end
    end
  end

  describe 'LeakyReLU' do
    let(:leaky_relu) { described_class::LeakyReLU.new(alpha: 0.01) }
    let(:custom_alpha) { described_class::LeakyReLU.new(alpha: 0.2) }

    describe '#forward' do
      it 'returns alpha * input for negative input' do
        expect(leaky_relu.forward(-1)).to eq(-0.01)
        expect(custom_alpha.forward(-1)).to eq(-0.2)
      end

      it 'returns input for positive input' do
        expect(leaky_relu.forward(1)).to eq(1.0)
      end
    end

    describe '#derivative' do
      it 'returns alpha for negative values' do
        expect(leaky_relu.derivative(-0.5)).to eq(0.01)
        expect(custom_alpha.derivative(-0.5)).to eq(0.2)
      end

      it 'returns 1 for positive values' do
        expect(leaky_relu.derivative(0.5)).to eq(1.0)
      end
    end
  end

  describe 'Linear' do
    let(:linear) { described_class::Linear.new }

    describe '#forward' do
      it 'returns input unchanged' do
        expect(linear.forward(5)).to eq(5)
        expect(linear.forward(-3)).to eq(-3)
        expect(linear.forward(0)).to eq(0)
      end
    end

    describe '#derivative' do
      it 'always returns 1' do
        expect(linear.derivative(5)).to eq(1.0)
        expect(linear.derivative(-3)).to eq(1.0)
        expect(linear.derivative(0)).to eq(1.0)
      end
    end
  end

  describe 'Custom' do
    let(:custom) do
      described_class::Custom.new(
        forward_fn: ->(x) { x ** 2 },
        derivative_fn: ->(y) { 2 * Math.sqrt(y) }
      )
    end

    describe '#forward' do
      it 'uses custom forward function' do
        expect(custom.forward(3)).to eq(9)
        expect(custom.forward(-2)).to eq(4)
      end
    end

    describe '#derivative' do
      it 'uses custom derivative function' do
        expect(custom.derivative(9)).to be_within(0.0001).of(6.0)
        expect(custom.derivative(4)).to be_within(0.0001).of(4.0)
      end
    end

    it 'can implement any differentiable function' do
      # Example: Swish activation (x * sigmoid(x))
      swish = described_class::Custom.new(
        forward_fn: ->(x) { x / (1 + Math.exp(-x)) },
        derivative_fn: ->(y) { 
          # This is simplified - in practice you'd need x as well
          y > 0 ? 1.0 : 0.0 
        }
      )
      
      expect(swish.forward(0)).to eq(0)
      expect(swish.forward(2)).to be > 1.0
    end
  end

  describe 'Performance characteristics' do
    let(:functions) do
      {
        sigmoid: described_class::Sigmoid.new,
        tanh: described_class::Tanh.new,
        relu: described_class::ReLU.new,
        leaky_relu: described_class::LeakyReLU.new
      }
    end

    it 'all functions handle edge cases' do
      edge_values = [0, 1e-10, -1e-10, 1e10, -1e10]
      
      functions.each do |name, func|
        edge_values.each do |value|
          expect { func.forward(value) }.not_to raise_error
          # For derivative, we need the output of forward
          y = func.forward(value)
          expect { func.derivative(y) }.not_to raise_error
        end
      end
    end
  end
end