# frozen_string_literal: true

# Modular activation functions for neural networks
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module NeuralNetwork
    module ActivationFunctions
      # Base class for activation functions
      class ActivationFunction
        def forward(x)
          raise NotImplementedError, 'Subclass must implement forward method'
        end

        def backward(output)
          raise NotImplementedError, 'Subclass must implement backward method'
        end

        def name
          self.class.name.split('::').last
        end

        def educational_notes
          'Base activation function'
        end
      end

      # Sigmoid activation function
      class Sigmoid < ActivationFunction
        def forward(x)
          1.0 / (1.0 + Math.exp(-x))
        end

        def backward(output)
          output * (1.0 - output)
        end

        def educational_notes
          <<~NOTES
            Sigmoid (Logistic) Function
            Range: (0, 1)
            Pros:
            • Smooth and differentiable everywhere
            • Output can be interpreted as probability
            • Historically popular

            Cons:
            • Vanishing gradient problem for large |x|
            • Outputs not zero-centered
            • Computationally expensive (exp)

            Use cases:
            • Binary classification output layer
            • Gates in LSTM/GRU

            Mathematical form: σ(x) = 1/(1+e^(-x))
            Derivative: σ'(x) = σ(x)(1-σ(x))
          NOTES
        end
      end

      # Hyperbolic tangent activation
      class Tanh < ActivationFunction
        def forward(x)
          Math.tanh(x)
        end

        def backward(output)
          1.0 - (output**2)
        end

        def educational_notes
          <<~NOTES
            Hyperbolic Tangent (tanh) Function
            Range: (-1, 1)
            Pros:
            • Zero-centered outputs
            • Stronger gradients than sigmoid
            • Smooth and differentiable

            Cons:
            • Still suffers from vanishing gradients
            • Computationally expensive

            Use cases:
            • Hidden layers in older networks
            • RNN hidden states

            Mathematical form: tanh(x) = (e^x - e^(-x))/(e^x + e^(-x))
            Derivative: tanh'(x) = 1 - tanh²(x)
          NOTES
        end
      end

      # Rectified Linear Unit
      class ReLU < ActivationFunction
        def forward(x)
          [0, x].max
        end

        def backward(output)
          output > 0 ? 1.0 : 0.0
        end

        def educational_notes
          <<~NOTES
            Rectified Linear Unit (ReLU)
            Range: [0, ∞)
            Pros:
            • No vanishing gradient for positive inputs
            • Computationally efficient
            • Promotes sparsity
            • Works well in practice

            Cons:
            • Dying ReLU problem (neurons can get stuck)
            • Not differentiable at x=0
            • Unbounded output
            • Not zero-centered

            Use cases:
            • Default choice for hidden layers
            • Deep networks

            Mathematical form: f(x) = max(0, x)
            Derivative: f'(x) = 1 if x > 0, else 0
          NOTES
        end
      end

      # Leaky ReLU
      class LeakyReLU < ActivationFunction
        attr_reader :alpha

        def initialize(alpha = 0.01)
          @alpha = alpha
        end

        def forward(x)
          x > 0 ? x : @alpha * x
        end

        def backward(output)
          output > 0 ? 1.0 : @alpha
        end

        def educational_notes
          <<~NOTES
            Leaky Rectified Linear Unit
            Range: (-∞, ∞)
            Pros:
            • Prevents dying ReLU problem
            • Still computationally efficient
            • Allows negative outputs

            Cons:
            • Extra hyperparameter (α)
            • Not zero-centered
            • Negative side not well motivated

            Use cases:
            • When experiencing dying ReLU
            • Deep networks

            Mathematical form: f(x) = max(αx, x)
            Derivative: f'(x) = 1 if x > 0, else α
            Current α: #{@alpha}
          NOTES
        end
      end

      # Exponential Linear Unit
      class ELU < ActivationFunction
        attr_reader :alpha

        def initialize(alpha = 1.0)
          @alpha = alpha
        end

        def forward(x)
          x >= 0 ? x : @alpha * (Math.exp(x) - 1)
        end

        def backward(output)
          output >= 0 ? 1.0 : output + @alpha
        end

        def educational_notes
          <<~NOTES
            Exponential Linear Unit (ELU)
            Range: (-α, ∞)
            Pros:
            • Smooth everywhere (including x=0)
            • Negative outputs (closer to zero mean)
            • Robust to noise

            Cons:
            • Computationally expensive (exp)
            • Extra hyperparameter

            Use cases:
            • When smoother activation needed
            • Networks requiring negative outputs

            Mathematical form: f(x) = x if x ≥ 0, else α(e^x - 1)
            Current α: #{@alpha}
          NOTES
        end
      end

      # Swish (SiLU) activation
      class Swish < ActivationFunction
        attr_reader :beta

        def initialize(beta = 1.0)
          @beta = beta
        end

        def forward(x)
          @x = x # Store for backward pass
          x * sigmoid(x * @beta)
        end

        def backward(output)
          sigmoid_beta_x = sigmoid(@x * @beta)
          output + (sigmoid_beta_x * @beta * (1 - output))
        end

        private

        def sigmoid(x)
          1.0 / (1.0 + Math.exp(-x))
        end

        def educational_notes
          <<~NOTES
            Swish (Sigmoid Linear Unit)
            Range: (-∞, ∞)
            Pros:
            • Smooth and non-monotonic
            • Self-gating property
            • Often outperforms ReLU
            • Bounded below, unbounded above

            Cons:
            • Computationally expensive
            • More complex gradient

            Use cases:
            • Deep networks
            • When ReLU underperforms

            Mathematical form: f(x) = x·σ(βx)
            Current β: #{@beta}
          NOTES
        end
      end

      # Softmax activation (for output layer)
      class Softmax < ActivationFunction
        def forward(x)
          # Handle numerical stability
          if x.is_a?(Array)
            max_x = x.max
            exp_x = x.map { |xi| Math.exp(xi - max_x) }
            sum_exp = exp_x.sum
            exp_x.map { |e| e / sum_exp }
          else
            # Single value softmax = sigmoid
            1.0 / (1.0 + Math.exp(-x))
          end
        end

        def backward(output)
          # For softmax, the derivative depends on all outputs
          # This is a simplified version for single class
          if output.is_a?(Array)
            # Full Jacobian would be needed for proper implementation
            output.map { |o| o * (1.0 - o) }
          else
            output * (1.0 - output)
          end
        end

        def educational_notes
          <<~NOTES
            Softmax Function
            Range: (0, 1) with sum = 1
            Pros:
            • Outputs sum to 1 (probability distribution)
            • Differentiable
            • Standard for multi-class classification

            Cons:
            • Computationally expensive
            • Can saturate with extreme values
            • Gradient vanishing for wrong predictions

            Use cases:
            • Multi-class classification output
            • Attention mechanisms

            Mathematical form: softmax(x_i) = e^(x_i) / Σ(e^(x_j))
          NOTES
        end
      end

      # Linear (identity) activation
      class Linear < ActivationFunction
        def forward(x)
          x
        end

        def backward(_output)
          1.0
        end

        def educational_notes
          <<~NOTES
            Linear (Identity) Function
            Range: (-∞, ∞)
            Pros:
            • No saturation
            • Simple gradient
            • Preserves input scale

            Cons:
            • No non-linearity
            • Multiple linear layers = single linear layer

            Use cases:
            • Regression output layer
            • Skip connections
            • Testing/debugging

            Mathematical form: f(x) = x
            Derivative: f'(x) = 1
          NOTES
        end
      end

      # GELU (Gaussian Error Linear Unit)
      class GELU < ActivationFunction
        def forward(x)
          # Approximation for computational efficiency
          0.5 * x * (1 + Math.tanh(Math.sqrt(2.0 / Math::PI) * (x + (0.044715 * (x**3)))))
        end

        def backward(_output)
          # This is an approximation
          x = @last_input || 0
          cdf = 0.5 * (1 + Math.tanh(Math.sqrt(2.0 / Math::PI) * (x + (0.044715 * (x**3)))))
          pdf_approx = Math.exp(-0.5 * (x**2)) / Math.sqrt(2 * Math::PI)
          cdf + (x * pdf_approx)
        end

        def educational_notes
          <<~NOTES
            Gaussian Error Linear Unit (GELU)
            Range: (-∞, ∞)
            Pros:
            • Smooth approximation of ReLU
            • Used in transformer models
            • Stochastic regularization interpretation

            Cons:
            • Computationally expensive
            • Complex derivative

            Use cases:
            • Transformer models (BERT, GPT)
            • NLP applications

            Mathematical form: f(x) = x·Φ(x) where Φ is Gaussian CDF
          NOTES
        end
      end

      # Helper class to manage activation functions
      class ActivationFunctionFactory
        FUNCTIONS = {
          sigmoid: Sigmoid,
          tanh: Tanh,
          relu: ReLU,
          leaky_relu: LeakyReLU,
          elu: ELU,
          swish: Swish,
          softmax: Softmax,
          linear: Linear,
          gelu: GELU
        }.freeze

        def self.create(name, params = {})
          function_class = FUNCTIONS[name.to_sym]
          raise ArgumentError, "Unknown activation function: #{name}" unless function_class

          if params.any?
            function_class.new(**params)
          else
            function_class.new
          end
        end

        def self.list_available
          FUNCTIONS.keys
        end

        def self.compare_functions(x_range = -5..5, step = 0.1)
          puts '=== Activation Function Comparison ==='

          x_range.step(step).to_a

          FUNCTIONS.each do |name, function_class|
            func = function_class.new
            puts "\n#{name.to_s.capitalize}:"

            # Sample some values
            sample_points = [-2, -1, 0, 1, 2]
            sample_points.each do |x|
              y = func.forward(x)
              puts "  f(#{x}) = #{y.round(4)}"
            end

            # Show derivative at 0
            y_at_0 = func.forward(0)
            dy_at_0 = func.backward(y_at_0)
            puts "  f'(0) = #{dy_at_0.round(4)}"
          end
        end
      end

      # Educational comparison tool
      class ActivationComparison
        def self.visualize_functions
          puts "\n=== Activation Functions Visualization ==="

          functions = %i[sigmoid tanh relu leaky_relu]
          x_range = -3..3

          # Create ASCII plot
          puts '  x  | ' + functions.map { |f| f.to_s.ljust(8) }.join(' | ')
          puts "-----+#{'-' * 10 * functions.length}"

          x_range.step(0.5) do |x|
            values = functions.map do |func_name|
              func = ActivationFunctionFactory.create(func_name)
              func.forward(x).round(2).to_s.ljust(8)
            end

            puts format('%4.1f | %s', x, values.join(' | '))
          end
        end

        def self.analyze_gradients
          puts "\n=== Gradient Analysis ==="

          functions = %i[sigmoid tanh relu leaky_relu]
          test_outputs = [0.01, 0.5, 0.99] # Different saturation levels

          functions.each do |func_name|
            func = ActivationFunctionFactory.create(func_name)
            puts "\n#{func_name}:"

            # For functions that map to [0,1] or [-1,1]
            if %i[sigmoid tanh].include?(func_name)
              test_outputs.each do |output|
                gradient = func.backward(output)
                puts "  Gradient at output=#{output}: #{gradient.round(4)}"
              end
            else
              # For unbounded functions, test at different input values
              [-1, 0, 1].each do |x|
                output = func.forward(x)
                gradient = func.backward(output)
                puts "  Gradient at x=#{x}: #{gradient.round(4)}"
              end
            end
          end
        end
      end
    end
  end
end
