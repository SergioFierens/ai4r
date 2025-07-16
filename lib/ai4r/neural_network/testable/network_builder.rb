# frozen_string_literal: true

require_relative 'backpropagation'
require_relative 'weight_initializer'
require_relative 'activation_function'
require_relative 'learning_algorithm'
require_relative 'network_validator'

module Ai4r
  module NeuralNetwork
    module Testable
      # Builder pattern for creating neural networks with fluent interface
      # Makes it easy to create networks for testing with different configurations
      class NetworkBuilder
        def initialize
          @structure = nil
          @weight_initializer = nil
          @activation_function = nil
          @learning_algorithm = nil
          @validator = nil
          @learning_rate = 0.25
          @momentum = 0.1
          @disable_bias = false
        end

        # Set network structure
        # @param structure [Array<Integer>] Network architecture
        # @return [self]
        def with_structure(*layers)
          @structure = layers.flatten
          self
        end

        # Set weight initialization strategy
        # @param strategy [Symbol, WeightInitializer] Strategy or instance
        # @param options [Hash] Options for strategy
        # @return [self]
        def with_weight_initialization(strategy, **options)
          @weight_initializer = case strategy
          when :random
            WeightInitializer::Random.new(**options)
          when :xavier
            WeightInitializer::Xavier.new(**options)
          when :he
            WeightInitializer::He.new(**options)
          when :fixed
            WeightInitializer::Fixed.new(**options)
          when WeightInitializer
            strategy
          else
            raise ArgumentError, "Unknown weight initialization: #{strategy}"
          end
          self
        end

        # Set activation function
        # @param function [Symbol, ActivationFunction] Function or instance
        # @param options [Hash] Options for function
        # @return [self]
        def with_activation_function(function, **options)
          @activation_function = case function
          when :sigmoid
            ActivationFunction::Sigmoid.new
          when :tanh
            ActivationFunction::Tanh.new
          when :relu
            ActivationFunction::ReLU.new
          when :leaky_relu
            ActivationFunction::LeakyReLU.new(**options)
          when :linear
            ActivationFunction::Linear.new
          when ActivationFunction
            function
          else
            raise ArgumentError, "Unknown activation function: #{function}"
          end
          self
        end

        # Set learning algorithm
        # @param algorithm [Symbol, LearningAlgorithm] Algorithm or instance
        # @param options [Hash] Options for algorithm
        # @return [self]
        def with_learning_algorithm(algorithm, **options)
          @learning_algorithm = case algorithm
          when :gradient_descent
            LearningAlgorithm::GradientDescent.new(**options)
          when :momentum
            LearningAlgorithm::Momentum.new(**options)
          when :adagrad
            LearningAlgorithm::AdaGrad.new(**options)
          when :adam
            LearningAlgorithm::Adam.new(**options)
          when LearningAlgorithm
            algorithm
          else
            raise ArgumentError, "Unknown learning algorithm: #{algorithm}"
          end
          self
        end

        # Set learning rate
        # @param rate [Float] Learning rate
        # @return [self]
        def with_learning_rate(rate)
          @learning_rate = rate
          self
        end

        # Set momentum
        # @param momentum [Float] Momentum factor
        # @return [self]
        def with_momentum(momentum)
          @momentum = momentum
          self
        end

        # Disable bias nodes
        # @return [self]
        def without_bias
          @disable_bias = true
          self
        end

        # Enable bias nodes (default)
        # @return [self]
        def with_bias
          @disable_bias = false
          self
        end

        # Set custom validator
        # @param validator [NetworkValidator] Validator instance
        # @return [self]
        def with_validator(validator)
          @validator = validator
          self
        end

        # Build the network
        # @return [Backpropagation] Configured network
        def build
          raise ArgumentError, 'Structure must be specified' unless @structure
          
          options = {
            weight_initializer: @weight_initializer || WeightInitializer::Random.new,
            activation_function: @activation_function || ActivationFunction::Sigmoid.new,
            validator: @validator || NetworkValidator.new,
            learning_rate: @learning_rate,
            momentum: @momentum,
            disable_bias: @disable_bias
          }
          
          network = Backpropagation.new(@structure, options)
          
          # Attach learning algorithm if specified
          if @learning_algorithm
            network.define_singleton_method(:learning_algorithm) { @learning_algorithm }
          end
          
          network
        end

        # Common preset configurations
        class Presets
          # XOR problem network
          def self.xor_network
            NetworkBuilder.new
              .with_structure(2, 2, 1)
              .with_activation_function(:sigmoid)
              .with_learning_algorithm(:momentum, learning_rate: 0.5, momentum_factor: 0.9)
              .with_learning_rate(0.5)
              .build
          end

          # Iris classification network
          def self.iris_classifier
            NetworkBuilder.new
              .with_structure(4, 10, 3)
              .with_activation_function(:tanh)
              .with_weight_initialization(:xavier)
              .with_learning_algorithm(:adam)
              .build
          end

          # MNIST digit classifier (simplified)
          def self.mnist_classifier
            NetworkBuilder.new
              .with_structure(784, 128, 64, 10)
              .with_activation_function(:relu)
              .with_weight_initialization(:he)
              .with_learning_algorithm(:adam, learning_rate: 0.001)
              .build
          end

          # Test network with fixed weights
          def self.test_network(structure)
            NetworkBuilder.new
              .with_structure(*structure)
              .with_weight_initialization(:fixed, value: 0.5)
              .with_activation_function(:linear)
              .with_learning_algorithm(:gradient_descent, learning_rate: 0.1)
              .without_bias
              .build
          end
        end
      end
    end
  end
end