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
      
      describe ActivationFunctions::Sigmoid do
        let(:sigmoid) { described_class.new }
        
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
          
          it 'approaches 0 for large negative values' do
            expect(sigmoid.forward(-100)).to be < 0.001
          end
          
          it 'approaches 1 for large positive values' do
            expect(sigmoid.forward(100)).to be > 0.999
          end
        end
        
        describe '#backward' do
          it 'computes correct derivative' do
            # Derivative of sigmoid is output * (1 - output)
            output = 0.7
            derivative = sigmoid.backward(output)
            expect(derivative).to eq(0.7 * 0.3)
          end
          
          it 'has maximum derivative at output=0.5' do
            derivatives = (0.1..0.9).step(0.1).map { |o| sigmoid.backward(o) }
            max_derivative = sigmoid.backward(0.5)
            expect(derivatives.max).to eq(max_derivative)
          end
          
          it 'has small derivatives near 0 and 1' do
            expect(sigmoid.backward(0.01)).to be < 0.01
            expect(sigmoid.backward(0.99)).to be < 0.01
          end
        end
        
        it 'provides educational notes' do
          notes = sigmoid.educational_notes
          expect(notes).to include('Sigmoid')
          expect(notes).to include('Range: (0, 1)')
        end
      end
      
      describe ActivationFunctions::Tanh do
        let(:tanh) { described_class.new }
        
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
          
          it 'is antisymmetric around 0' do
            x = 2.5
            expect(tanh.forward(x)).to be_within(0.0001).of(-tanh.forward(-x))
          end
          
          it 'approaches -1 and 1 for extreme values' do
            expect(tanh.forward(-100)).to be_within(0.001).of(-1)
            expect(tanh.forward(100)).to be_within(0.001).of(1)
          end
        end
        
        describe '#backward' do
          it 'computes correct derivative' do
            # Derivative of tanh is 1 - output^2
            output = 0.5
            derivative = tanh.backward(output)
            expect(derivative).to eq(1 - 0.5**2)
          end
          
          it 'has maximum derivative at output=0' do
            derivatives = (-0.9..0.9).step(0.1).map { |o| tanh.backward(o) }
            max_derivative = tanh.backward(0)
            expect(derivatives.max).to be_within(0.001).of(max_derivative)
          end
        end
      end
      
      describe ActivationFunctions::ReLU do
        let(:relu) { described_class.new }
        
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
          
          it 'returns 0 for input 0' do
            expect(relu.forward(0)).to eq(0)
          end
        end
        
        describe '#backward' do
          it 'returns 0 for non-positive outputs' do
            expect(relu.backward(0)).to eq(0)
            expect(relu.backward(-1)).to eq(0)
          end
          
          it 'returns 1 for positive outputs' do
            expect(relu.backward(0.1)).to eq(1)
            expect(relu.backward(10)).to eq(1)
          end
        end
      end
      
      describe ActivationFunctions::LeakyReLU do
        let(:leaky_relu) { described_class.new }
        
        describe '#forward' do
          it 'returns scaled input for negative values' do
            alpha = leaky_relu.instance_variable_get(:@alpha) || 0.01
            expect(leaky_relu.forward(-10)).to eq(-10 * alpha)
            expect(leaky_relu.forward(-1)).to eq(-1 * alpha)
          end
          
          it 'returns input for positive values' do
            expect(leaky_relu.forward(1)).to eq(1)
            expect(leaky_relu.forward(10)).to eq(10)
          end
        end
        
        describe '#backward' do
          it 'returns alpha for negative outputs' do
            alpha = leaky_relu.instance_variable_get(:@alpha) || 0.01
            expect(leaky_relu.backward(-0.01)).to eq(alpha)
          end
          
          it 'returns 1 for positive outputs' do
            expect(leaky_relu.backward(1)).to eq(1)
          end
        end
        
        it 'accepts custom alpha parameter' do
          custom_relu = described_class.new(alpha: 0.1)
          expect(custom_relu.forward(-10)).to eq(-1.0)
        end
      end
      
      describe ActivationFunctions::ELU do
        let(:elu) { described_class.new }
        
        describe '#forward' do
          it 'returns input for positive values' do
            expect(elu.forward(1)).to eq(1)
            expect(elu.forward(10)).to eq(10)
          end
          
          it 'returns exponential for negative values' do
            alpha = elu.instance_variable_get(:@alpha) || 1.0
            x = -1
            expected = alpha * (Math.exp(x) - 1)
            expect(elu.forward(x)).to be_within(0.0001).of(expected)
          end
          
          it 'is smooth at x=0' do
            # Check continuity around 0
            left_limit = elu.forward(-0.001)
            right_limit = elu.forward(0.001)
            expect((left_limit - right_limit).abs).to be < 0.01
          end
        end
        
        describe '#backward' do
          it 'returns 1 for positive outputs' do
            expect(elu.backward(1)).to eq(1)
          end
          
          it 'returns output + alpha for negative outputs' do
            alpha = elu.instance_variable_get(:@alpha) || 1.0
            output = -0.5
            expect(elu.backward(output)).to eq(output + alpha)
          end
        end
      end
      
      describe ActivationFunctions::Swish do
        let(:swish) { described_class.new }
        
        describe '#forward' do
          it 'returns approximately 0 for large negative values' do
            expect(swish.forward(-100)).to be < 0.001
          end
          
          it 'returns approximately x for large positive values' do
            x = 10
            expect(swish.forward(x)).to be_within(0.1).of(x)
          end
          
          it 'is smooth and differentiable everywhere' do
            values = (-5..5).step(0.1).map { |x| swish.forward(x) }
            # Check smoothness by verifying no sudden jumps
            differences = values.each_cons(2).map { |a, b| (b - a).abs }
            expect(differences.max).to be < 0.5
          end
        end
        
        describe '#backward' do
          it 'computes correct derivative using chain rule' do
            x = 2.0
            output = swish.forward(x)
            sigmoid_x = 1.0 / (1.0 + Math.exp(-x))
            expected_derivative = output + sigmoid_x * (1 - output)
            
            # Swish backward might need x as second parameter
            derivative = swish.respond_to?(:backward) && swish.method(:backward).arity == 2 ? 
                        swish.backward(output, x) : swish.backward(output)
            
            expect(derivative).to be_within(0.0001).of(expected_derivative)
          end
        end
      end
      
      describe ActivationFunctions::Softmax do
        let(:softmax) { described_class.new }
        
        describe '#forward' do
          it 'returns probability distribution' do
            x = [1, 2, 3]
            output = softmax.forward(x)
            
            # Sum should be 1
            expect(output.sum).to be_within(0.0001).of(1.0)
            
            # All values should be positive
            expect(output.all? { |v| v > 0 }).to be true
          end
          
          it 'preserves ordering' do
            x = [1, 3, 2]
            output = softmax.forward(x)
            
            # Largest input should have largest output
            expect(output[1]).to be > output[0]
            expect(output[1]).to be > output[2]
            expect(output[2]).to be > output[0]
          end
          
          it 'handles numerical stability' do
            # Large values that could cause overflow
            x = [1000, 1001, 999]
            expect { softmax.forward(x) }.not_to raise_error
            
            output = softmax.forward(x)
            expect(output.sum).to be_within(0.0001).of(1.0)
          end
        end
        
        describe '#backward' do
          it 'computes Jacobian correctly' do
            x = [1, 2, 3]
            output = softmax.forward(x)
            jacobian = softmax.backward(output)
            
            # Jacobian should be square
            expect(jacobian.length).to eq(3)
            expect(jacobian[0].length).to eq(3)
            
            # Diagonal elements: output[i] * (1 - output[i])
            expect(jacobian[0][0]).to be_within(0.0001).of(output[0] * (1 - output[0]))
            
            # Off-diagonal elements: -output[i] * output[j]
            expect(jacobian[0][1]).to be_within(0.0001).of(-output[0] * output[1])
          end
        end
      end
      
      describe ActivationFunctions::Linear do
        let(:linear) { described_class.new }
        
        describe '#forward' do
          it 'returns input unchanged' do
            [-10, 0, 10].each do |x|
              expect(linear.forward(x)).to eq(x)
            end
          end
        end
        
        describe '#backward' do
          it 'returns 1 for any output' do
            [-10, 0, 10].each do |output|
              expect(linear.backward(output)).to eq(1)
            end
          end
        end
      end
      
      describe 'Factory method' do
        it 'creates correct activation function by name' do
          sigmoid = ActivationFunctions.create('sigmoid')
          expect(sigmoid).to be_a(ActivationFunctions::Sigmoid)
          
          relu = ActivationFunctions.create('relu')
          expect(relu).to be_a(ActivationFunctions::ReLU)
        end
        
        it 'accepts parameters for parameterized functions' do
          leaky = ActivationFunctions.create('leaky_relu', alpha: 0.2)
          expect(leaky.instance_variable_get(:@alpha)).to eq(0.2)
        end
        
        it 'raises error for unknown activation' do
          expect { 
            ActivationFunctions.create('unknown') 
          }.to raise_error(ArgumentError, /Unknown activation function/)
        end
      end
      
      describe 'Performance characteristics' do
        it 'handles array inputs efficiently' do
          relu = ActivationFunctions::ReLU.new
          inputs = Array.new(1000) { rand(-10..10) }
          
          # Should process array without errors
          outputs = inputs.map { |x| relu.forward(x) }
          expect(outputs.length).to eq(1000)
        end
        
        it 'maintains numerical precision' do
          sigmoid = ActivationFunctions::Sigmoid.new
          
          # Test with very small differences
          x1 = 0.5
          x2 = 0.5 + 1e-10
          
          output1 = sigmoid.forward(x1)
          output2 = sigmoid.forward(x2)
          
          # Should maintain precision for small differences
          expect(output2).to be > output1
        end
      end
    end
  end
end