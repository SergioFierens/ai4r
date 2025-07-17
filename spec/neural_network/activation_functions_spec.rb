# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::NeuralNetwork::ActivationFunctions do
  describe Ai4r::NeuralNetwork::ActivationFunctions::ActivationFunction do
    let(:base_function) { described_class.new }
    
    it 'raises NotImplementedError for forward' do
      expect { base_function.forward(1.0) }.to raise_error(NotImplementedError)
    end
    
    it 'raises NotImplementedError for backward' do
      expect { base_function.backward(1.0) }.to raise_error(NotImplementedError)
    end
    
    it 'returns class name' do
      expect(base_function.name).to eq('ActivationFunction')
    end
    
    it 'provides educational notes' do
      expect(base_function.educational_notes).to eq('Base activation function')
    end
  end
  
  describe 'Sigmoid' do
    let(:sigmoid) { Ai4r::NeuralNetwork::ActivationFunctions::Sigmoid.new }
    
    describe '#forward' do
      it 'returns values in range (0, 1)' do
        [-10, -1, 0, 1, 10].each do |x|
          output = sigmoid.forward(x)
          expect(output).to be > 0
          expect(output).to be < 1
        end
      end
      
      it 'returns 0.5 for input 0' do
        expect(sigmoid.forward(0)).to eq(0.5)
      end
      
      it 'is monotonically increasing' do
        outputs = (-5..5).map { |x| sigmoid.forward(x) }
        expect(outputs).to eq(outputs.sort)
      end
    end
    
    describe '#backward' do
      it 'returns correct derivative' do
        # For sigmoid, derivative is output * (1 - output)
        [0.1, 0.5, 0.9].each do |output|
          expected = output * (1 - output)
          expect(sigmoid.backward(output)).to be_within(0.001).of(expected)
        end
      end
    end
  end
  
  describe 'Tanh' do
    let(:tanh) { Ai4r::NeuralNetwork::ActivationFunctions::Tanh.new }
    
    describe '#forward' do
      it 'returns values in range (-1, 1)' do
        [-10, -1, 0, 1, 10].each do |x|
          output = tanh.forward(x)
          expect(output).to be > -1
          expect(output).to be < 1
        end
      end
      
      it 'returns 0 for input 0' do
        expect(tanh.forward(0)).to eq(0)
      end
    end
    
    describe '#backward' do
      it 'returns correct derivative' do
        # For tanh, derivative is 1 - output^2
        [-0.9, 0, 0.9].each do |output|
          expected = 1 - output**2
          expect(tanh.backward(output)).to be_within(0.001).of(expected)
        end
      end
    end
  end
  
  describe 'ReLU' do
    let(:relu) { Ai4r::NeuralNetwork::ActivationFunctions::ReLU.new }
    
    describe '#forward' do
      it 'returns 0 for negative inputs' do
        [-10, -1, -0.1].each do |x|
          expect(relu.forward(x)).to eq(0)
        end
      end
      
      it 'returns input for positive inputs' do
        [0.1, 1, 10].each do |x|
          expect(relu.forward(x)).to eq(x)
        end
      end
    end
    
    describe '#backward' do
      it 'returns 0 for zero output' do
        expect(relu.backward(0)).to eq(0)
      end
      
      it 'returns 1 for positive output' do
        [0.1, 1, 10].each do |output|
          expect(relu.backward(output)).to eq(1)
        end
      end
    end
  end
  
  describe 'LeakyReLU' do
    let(:leaky_relu) { Ai4r::NeuralNetwork::ActivationFunctions::LeakyReLU.new(0.01) }
    
    describe '#forward' do
      it 'returns small positive values for negative inputs' do
        expect(leaky_relu.forward(-10)).to eq(-0.1)
        expect(leaky_relu.forward(-1)).to eq(-0.01)
      end
      
      it 'returns input for positive inputs' do
        expect(leaky_relu.forward(10)).to eq(10)
      end
    end
  end
  
  describe 'Softmax' do
    let(:softmax) { Ai4r::NeuralNetwork::ActivationFunctions::Softmax.new }
    
    describe '#forward' do
      it 'returns probability distribution' do
        outputs = softmax.forward([1, 2, 3])
        expect(outputs.sum).to be_within(0.001).of(1.0)
        expect(outputs).to all(be > 0)
        expect(outputs).to all(be < 1)
      end
      
      it 'handles numerical stability' do
        # Large values shouldn't cause overflow
        outputs = softmax.forward([1000, 1001, 1002])
        expect(outputs).to all(be_finite)
        expect(outputs.sum).to be_within(0.001).of(1.0)
      end
    end
  end
  
  describe 'Linear' do
    let(:linear) { Ai4r::NeuralNetwork::ActivationFunctions::Linear.new }
    
    describe '#forward' do
      it 'returns input unchanged' do
        [-10, 0, 10].each do |x|
          expect(linear.forward(x)).to eq(x)
        end
      end
    end
    
    describe '#backward' do
      it 'returns 1 always' do
        [-10, 0, 10].each do |output|
          expect(linear.backward(output)).to eq(1)
        end
      end
    end
  end
  
  describe 'Factory method' do
    it 'creates correct activation function by name' do
      sigmoid = Ai4r::NeuralNetwork::ActivationFunctions.create(:sigmoid)
      expect(sigmoid).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::Sigmoid)
      
      relu = Ai4r::NeuralNetwork::ActivationFunctions.create(:relu)
      expect(relu).to be_a(Ai4r::NeuralNetwork::ActivationFunctions::ReLU)
    end
    
    it 'accepts parameters for parameterized functions' do
      leaky = Ai4r::NeuralNetwork::ActivationFunctions.create(:leaky_relu, 0.02)
      expect(leaky.alpha).to eq(0.02)
    end
    
    it 'raises error for unknown activation' do
      expect {
        Ai4r::NeuralNetwork::ActivationFunctions.create(:unknown)
      }.to raise_error(ArgumentError)
    end
  end
end