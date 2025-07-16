# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/activation_functions'

RSpec.describe Ai4r::NeuralNetwork::ActivationFunctions do
  describe 'Base ActivationFunction' do
    let(:base_function) { Ai4r::NeuralNetwork::ActivationFunctions::ActivationFunction.new }

    it 'raises NotImplementedError for forward method' do
      expect { base_function.forward(1.0) }.to raise_error(NotImplementedError, 'Subclass must implement forward method')
    end

    it 'raises NotImplementedError for backward method' do
      expect { base_function.backward(1.0) }.to raise_error(NotImplementedError, 'Subclass must implement backward method')
    end

    it 'returns correct name' do
      expect(base_function.name).to eq('ActivationFunction')
    end

    it 'returns educational notes' do
      expect(base_function.educational_notes).to eq('Base activation function')
    end
  end

  describe 'Sigmoid' do
    let(:sigmoid) { Ai4r::NeuralNetwork::ActivationFunctions::Sigmoid.new }

    describe '#forward' do
      it 'calculates sigmoid correctly' do
        expect(sigmoid.forward(0)).to be_within(0.001).of(0.5)
        expect(sigmoid.forward(1)).to be_within(0.001).of(0.731)
        expect(sigmoid.forward(-1)).to be_within(0.001).of(0.269)
        expect(sigmoid.forward(10)).to be > 0.999
        expect(sigmoid.forward(-10)).to be < 0.001
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly' do
        expect(sigmoid.backward(0.5)).to be_within(0.001).of(0.25)
        expect(sigmoid.backward(0.731)).to be_within(0.001).of(0.196)
        expect(sigmoid.backward(0.269)).to be_within(0.001).of(0.196)
      end
    end

    it 'has educational notes' do
      expect(sigmoid.educational_notes).to include('Sigmoid')
      expect(sigmoid.educational_notes).to include('Range: (0, 1)')
    end
  end

  describe 'Tanh' do
    let(:tanh) { Ai4r::NeuralNetwork::ActivationFunctions::Tanh.new }

    describe '#forward' do
      it 'calculates tanh correctly' do
        expect(tanh.forward(0)).to eq(0)
        expect(tanh.forward(1)).to be_within(0.001).of(0.762)
        expect(tanh.forward(-1)).to be_within(0.001).of(-0.762)
        expect(tanh.forward(10)).to be_within(0.001).of(1.0)
        expect(tanh.forward(-10)).to be_within(0.001).of(-1.0)
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly' do
        expect(tanh.backward(0)).to eq(1.0)
        expect(tanh.backward(0.762)).to be_within(0.001).of(0.420)
        expect(tanh.backward(-0.762)).to be_within(0.001).of(0.420)
      end
    end

    it 'has educational notes' do
      expect(tanh.educational_notes).to include('Hyperbolic Tangent')
      expect(tanh.educational_notes).to include('Range: (-1, 1)')
    end
  end

  describe 'ReLU' do
    let(:relu) { Ai4r::NeuralNetwork::ActivationFunctions::ReLU.new }

    describe '#forward' do
      it 'calculates ReLU correctly' do
        expect(relu.forward(5)).to eq(5)
        expect(relu.forward(0)).to eq(0)
        expect(relu.forward(-5)).to eq(0)
        expect(relu.forward(0.5)).to eq(0.5)
        expect(relu.forward(-0.5)).to eq(0)
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly' do
        expect(relu.backward(5)).to eq(1)
        expect(relu.backward(0)).to eq(0)
        expect(relu.backward(-5)).to eq(0)
      end
    end

    it 'has educational notes' do
      expect(relu.educational_notes).to include('Rectified Linear Unit')
      expect(relu.educational_notes).to include('Range: [0, ∞)')
    end
  end

  describe 'LeakyReLU' do
    let(:leaky_relu) { Ai4r::NeuralNetwork::ActivationFunctions::LeakyReLU.new }
    let(:custom_leaky) { Ai4r::NeuralNetwork::ActivationFunctions::LeakyReLU.new(alpha: 0.1) }

    describe '#forward' do
      it 'calculates LeakyReLU correctly with default alpha' do
        expect(leaky_relu.forward(5)).to eq(5)
        expect(leaky_relu.forward(0)).to eq(0)
        expect(leaky_relu.forward(-5)).to be_within(0.001).of(-0.05)
      end

      it 'calculates LeakyReLU correctly with custom alpha' do
        expect(custom_leaky.forward(5)).to eq(5)
        expect(custom_leaky.forward(-5)).to be_within(0.001).of(-0.5)
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly' do
        expect(leaky_relu.backward(5)).to eq(1)
        expect(leaky_relu.backward(0)).to eq(0.01)
        expect(leaky_relu.backward(-5)).to eq(0.01)
      end

      it 'calculates derivative with custom alpha' do
        expect(custom_leaky.backward(-5)).to eq(0.1)
      end
    end

    it 'has educational notes' do
      expect(leaky_relu.educational_notes).to include('Leaky ReLU')
      expect(leaky_relu.educational_notes).to include('dying ReLU')
    end
  end

  describe 'ELU' do
    let(:elu) { Ai4r::NeuralNetwork::ActivationFunctions::ELU.new }
    let(:custom_elu) { Ai4r::NeuralNetwork::ActivationFunctions::ELU.new(alpha: 2.0) }

    describe '#forward' do
      it 'calculates ELU correctly with default alpha' do
        expect(elu.forward(5)).to eq(5)
        expect(elu.forward(0)).to eq(0)
        expect(elu.forward(-1)).to be_within(0.001).of(-0.632)
      end

      it 'calculates ELU correctly with custom alpha' do
        expect(custom_elu.forward(5)).to eq(5)
        expect(custom_elu.forward(-1)).to be_within(0.001).of(-1.264)
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly for positive outputs' do
        expect(elu.backward(5)).to eq(1)
      end

      it 'calculates derivative correctly for negative inputs' do
        # For ELU, when x < 0, derivative = output + alpha
        output = elu.forward(-1)
        derivative = elu.backward(output)
        expect(derivative).to be_within(0.001).of(output + 1.0)
      end
    end

    it 'has educational notes' do
      expect(elu.educational_notes).to include('Exponential Linear Unit')
      expect(elu.educational_notes).to include('smooth')
    end
  end

  describe 'Swish' do
    let(:swish) { Ai4r::NeuralNetwork::ActivationFunctions::Swish.new }
    let(:custom_swish) { Ai4r::NeuralNetwork::ActivationFunctions::Swish.new(beta: 2.0) }

    describe '#forward' do
      it 'calculates Swish correctly' do
        expect(swish.forward(0)).to eq(0)
        expect(swish.forward(1)).to be_within(0.001).of(0.731)
        expect(swish.forward(-1)).to be_within(0.001).of(-0.269)
      end

      it 'stores input for backward pass' do
        swish.forward(2.0)
        expect(swish.instance_variable_get(:@last_input)).to eq(2.0)
      end

      it 'works with custom beta' do
        result = custom_swish.forward(1)
        sigmoid_2 = 1.0 / (1.0 + Math.exp(-2))
        expect(result).to be_within(0.001).of(sigmoid_2)
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly' do
        output = swish.forward(1)
        derivative = swish.backward(output)
        expect(derivative).to be > 0
      end
    end

    it 'has educational notes' do
      expect(swish.educational_notes).to include('Swish')
      expect(swish.educational_notes).to include('self-gating')
    end
  end

  describe 'Softmax' do
    let(:softmax) { Ai4r::NeuralNetwork::ActivationFunctions::Softmax.new }

    describe '#forward' do
      it 'calculates softmax correctly for vector input' do
        result = softmax.forward([1, 2, 3])
        expect(result).to be_an(Array)
        expect(result.sum).to be_within(0.001).of(1.0)
        expect(result[2]).to be > result[1]
        expect(result[1]).to be > result[0]
      end

      it 'handles single value input' do
        result = softmax.forward(1)
        expect(result).to eq(1.0)
      end

      it 'handles numerical stability' do
        result = softmax.forward([1000, 1001, 999])
        expect(result.sum).to be_within(0.001).of(1.0)
        expect(result.none?(&:nan?)).to be true
      end
    end

    describe '#backward' do
      it 'calculates jacobian correctly' do
        output = softmax.forward([1, 2, 3])
        jacobian = softmax.backward(output)
        expect(jacobian).to be_an(Array)
        expect(jacobian.size).to eq(3)
        expect(jacobian.all? { |row| row.size == 3 }).to be true
      end

      it 'handles single value backward' do
        expect(softmax.backward(0.5)).to eq(0.25)
      end
    end

    it 'has educational notes' do
      expect(softmax.educational_notes).to include('Softmax')
      expect(softmax.educational_notes).to include('probability distribution')
    end
  end

  describe 'GELU' do
    let(:gelu) { Ai4r::NeuralNetwork::ActivationFunctions::GELU.new }

    describe '#forward' do
      it 'calculates GELU correctly' do
        expect(gelu.forward(0)).to be_within(0.001).of(0)
        expect(gelu.forward(1)).to be_within(0.001).of(0.841)
        expect(gelu.forward(-1)).to be_within(0.001).of(-0.159)
      end

      it 'stores input for backward pass' do
        gelu.forward(2.0)
        expect(gelu.instance_variable_get(:@last_input)).to eq(2.0)
      end
    end

    describe '#backward' do
      it 'calculates derivative correctly' do
        gelu.forward(1)
        derivative = gelu.backward(0.841)
        expect(derivative).to be_within(0.1).of(1.08)
      end
    end

    it 'has educational notes' do
      expect(gelu.educational_notes).to include('Gaussian Error Linear Unit')
      expect(gelu.educational_notes).to include('Transformer')
    end
  end

  describe 'Factory method' do
    it 'creates correct activation function by symbol' do
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:sigmoid)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::Sigmoid)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:tanh)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::Tanh)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:relu)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::ReLU)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:leaky_relu)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::LeakyReLU)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:elu)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::ELU)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:swish)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::Swish)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:softmax)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::Softmax)
      expect(Ai4r::NeuralNetwork::ActivationFunctions.create(:gelu)).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::GELU)
    end

    it 'passes options to activation function' do
      leaky = Ai4r::NeuralNetwork::ActivationFunctions.create(:leaky_relu, alpha: 0.2)
      expect(leaky.instance_variable_get(:@alpha)).to eq(0.2)
    end

    it 'raises error for unknown activation' do
      expect { Ai4r::NeuralNetwork::ActivationFunctions.create(:unknown) }
        .to raise_error(ArgumentError, /Unknown activation function/)
    end
  end

  describe 'Available functions list' do
    it 'returns list of available functions' do
      available = Ai4r::NeuralNetwork::ActivationFunctions.available
      expect(available).to include(:sigmoid, :tanh, :relu, :leaky_relu, :elu, :swish, :softmax, :gelu)
    end
  end
end