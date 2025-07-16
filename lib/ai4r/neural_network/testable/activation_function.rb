# frozen_string_literal: true

module Ai4r
  module NeuralNetwork
    module Testable
      # Base class for activation functions
      # Provides a clean interface for different activation strategies
      class ActivationFunction
        # Forward pass through activation function
        # @param x [Float] Input value
        # @return [Float] Activated value
        def forward(x)
          raise NotImplementedError, 'Subclasses must implement forward'
        end

        # Derivative of activation function
        # @param y [Float] Output of forward pass
        # @return [Float] Derivative value
        def derivative(y)
          raise NotImplementedError, 'Subclasses must implement derivative'
        end

        # Sigmoid activation function
        class Sigmoid < ActivationFunction
          def forward(x)
            1.0 / (1.0 + Math.exp(-x))
          end

          def derivative(y)
            y * (1.0 - y)
          end
        end

        # Hyperbolic tangent activation function
        class Tanh < ActivationFunction
          def forward(x)
            Math.tanh(x)
          end

          def derivative(y)
            1.0 - y**2
          end
        end

        # ReLU (Rectified Linear Unit) activation function
        class ReLU < ActivationFunction
          def forward(x)
            x > 0 ? x : 0.0
          end

          def derivative(y)
            y > 0 ? 1.0 : 0.0
          end
        end

        # Leaky ReLU activation function
        class LeakyReLU < ActivationFunction
          def initialize(alpha: 0.01)
            @alpha = alpha
          end

          def forward(x)
            x > 0 ? x : @alpha * x
          end

          def derivative(y)
            y > 0 ? 1.0 : @alpha
          end
        end

        # Linear activation function (identity)
        class Linear < ActivationFunction
          def forward(x)
            x
          end

          def derivative(y)
            1.0
          end
        end

        # Custom activation function
        class Custom < ActivationFunction
          def initialize(forward_fn:, derivative_fn:)
            @forward_fn = forward_fn
            @derivative_fn = derivative_fn
          end

          def forward(x)
            @forward_fn.call(x)
          end

          def derivative(y)
            @derivative_fn.call(y)
          end
        end
      end
    end
  end
end