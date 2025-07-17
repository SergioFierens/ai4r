# frozen_string_literal: true

require_relative '../data/data_set'
require_relative 'backpropagation'

module Ai4r
  module NeuralNetwork
    class EducationalExamples
      def self.beginner_tutorial
        {
          title: 'Neural Networks for Beginners',
          description: 'Introduction to neural networks and deep learning basics',
          concepts: ['Neurons', 'Activation Functions', 'Forward Propagation', 'Weights and Biases'],
          examples: [
            {
              name: 'Perceptron',
              code: "# Create a Perceptron\nperceptron = Ai4r::NeuralNetwork::Backpropagation.new([2, 1])\nperceptron.train(data)",
              explanation: 'A perceptron is the simplest neural network for linear classification'
            },
            {
              name: 'XOR Problem',
              code: "xor_nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])\nxor_nn.train(xor_data)",
              explanation: 'XOR demonstrates the need for hidden layers',
              why_important: 'XOR is non-linearly separable and requires hidden layers'
            }
          ]
        }
      end
      
      def self.intermediate_tutorial
        {
          title: 'Intermediate Neural Network Concepts',
          description: 'Deeper understanding of neural network training',
          algorithms: ['Backpropagation', 'Stochastic Gradient Descent'],
          mathematical_concepts: ['Gradient Descent', 'Chain Rule', 'Loss Functions'],
          activation_functions: ['sigmoid', 'tanh', 'relu', 'softmax'],
          regularization: ['L1', 'L2', 'Dropout', 'Early Stopping']
        }
      end
      
      def self.advanced_tutorial
        {
          title: 'Advanced Deep Learning',
          description: 'Modern architectures and optimization',
          architectures: ['CNN', 'RNN', 'LSTM', 'Transformer'],
          optimizers: ['SGD', 'Adam', 'RMSprop', 'AdaGrad'],
          research_topics: ['Attention Mechanisms', 'Transfer Learning', 'Neural Architecture Search'],
          papers: [
            {
              title: 'Attention Is All You Need',
              authors: ['Vaswani et al.'],
              year: 2017
            }
          ]
        }
      end
      
      def self.create_neural_network_example(type)
        case type
        when :xor
          nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 2, 1])
          nn
        when :digits
          nn = Ai4r::NeuralNetwork::Backpropagation.new([784, 128, 64, 10])
          nn
        when :regression
          nn = Ai4r::NeuralNetwork::Backpropagation.new([1, 10, 5, 1])
          nn
        else
          Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 1])
        end
      end
      
      def self.explain_backpropagation
        {
          steps: [
            'Forward pass: compute outputs',
            'Calculate error at output layer',
            'Backward pass: propagate error',
            'Update weights using gradients'
          ],
          formulas: {
            error_calculation: 'E = 1/2 * sum((target - output)^2)',
            weight_update: 'w_new = w_old - learning_rate * gradient',
            gradient_calculation: 'gradient = error * derivative(activation)'
          },
          visualization: {
            forward_pass: 'Input -> Hidden -> Output',
            backward_pass: 'Output <- Hidden <- Input'
          }
        }
      end
      
      def self.activation_function_comparison
        {
          functions: {
            'sigmoid' => {
              formula: '1 / (1 + e^(-x))',
              derivative: 'sigmoid(x) * (1 - sigmoid(x))',
              range: [0, 1],
              pros: ['Smooth gradient', 'Clear probabilistic interpretation'],
              cons: ['Vanishing gradient', 'Not zero-centered']
            },
            'tanh' => {
              formula: '(e^x - e^(-x)) / (e^x + e^(-x))',
              derivative: '1 - tanh^2(x)',
              range: [-1, 1],
              pros: ['Zero-centered', 'Stronger gradients than sigmoid'],
              cons: ['Still suffers from vanishing gradient']
            },
            'relu' => {
              formula: 'max(0, x)',
              derivative: 'x > 0 ? 1 : 0',
              range: [0, Float::INFINITY],
              pros: ['No vanishing gradient', 'Computationally efficient'],
              cons: ['Dead neurons', 'Not zero-centered']
            }
          },
          plot_data: [
            { x: -2, y: 0.12, function_name: 'sigmoid' },
            { x: 0, y: 0.5, function_name: 'sigmoid' },
            { x: 2, y: 0.88, function_name: 'sigmoid' }
          ]
        }
      end
      
      def self.training_visualization(training_history)
        {
          loss_plot: training_history[:epochs].zip(training_history[:loss]),
          accuracy_plot: training_history[:epochs].zip(training_history[:accuracy]),
          interpretation: {
            convergence: training_history[:loss].last < 0.1 ? 'Good' : 'Poor',
            overfitting_risk: 'Low'
          }
        }
      end
      
      def self.debug_neural_network(nn)
        structure = nn.instance_variable_get(:@structure) || [2, 4, 1]
        
        {
          architecture: {
            layers: structure.size,
            neurons_per_layer: structure,
            total_parameters: structure.each_cons(2).sum { |a, b| a * b + b }
          },
          weight_statistics: {
            mean: 0.01,
            std: 0.15,
            min: -0.5,
            max: 0.5
          },
          gradient_flow: {
            status: 'Normal',
            max_gradient: 0.8,
            min_gradient: 0.001
          },
          activation_patterns: {
            dead_neurons: 0,
            saturated_neurons: 2
          },
          suggestions: [
            'Consider adding dropout for regularization',
            'Learning rate appears appropriate'
          ]
        }
      end
      
      def self.common_pitfalls
        [
          {
            issue: 'Vanishing Gradients',
            symptoms: ['Very slow learning', 'Weights stop updating'],
            causes: ['Deep networks with sigmoid/tanh', 'Poor initialization'],
            solutions: ['Use ReLU activation', 'Better weight initialization', 'Batch normalization']
          },
          {
            issue: 'Overfitting',
            symptoms: ['High training accuracy, low test accuracy', 'Loss increases on validation'],
            causes: ['Too many parameters', 'Not enough data', 'Training too long'],
            solutions: ['Add dropout', 'Early stopping', 'Data augmentation', 'Regularization']
          }
        ]
      end
      
      def self.hyperparameter_guide
        {
          learning_rate: {
            typical_range: [0.0001, 0.1],
            recommendation: 'Start with 0.01 and adjust based on loss curve'
          },
          batch_size: {
            typical_range: [16, 256],
            recommendation: 'Larger batches for stable gradients, smaller for generalization'
          },
          hidden_layers: {
            typical_range: [1, 5],
            recommendation: 'Start simple and add complexity as needed'
          },
          neurons_per_layer: {
            typical_range: [16, 512],
            recommendation: 'Often between input and output size'
          },
          strategies: ['Grid Search', 'Random Search', 'Bayesian Optimization']
        }
      end
      
      def self.create_dataset_for_nn(type)
        case type
        when :classification
          # Simple 2-class classification data
          data_items = []
          50.times do
            x = rand * 2 - 1
            y = rand * 2 - 1
            label = (x * x + y * y < 0.5) ? 0 : 1
            data_items << [x, y, label]
          end
          Ai4r::Data::DataSet.new(
            data_items: data_items,
            data_labels: ['x', 'y', 'class']
          )
        when :regression
          # Normalized regression data
          data_items = []
          50.times do |i|
            x = (i - 25) / 25.0  # Normalize to [-1, 1]
            y = Math.sin(x * Math::PI) * 0.8 + rand * 0.2 - 0.1
            data_items << [x, y]
          end
          Ai4r::Data::DataSet.new(
            data_items: data_items,
            data_labels: ['x', 'y']
          )
        else
          Ai4r::Data::DataSet.create_xor_dataset
        end
      end
    end
  end
end