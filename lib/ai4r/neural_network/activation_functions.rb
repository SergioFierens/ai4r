# frozen_string_literal: true

# Modular activation functions for educational neural networks
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module NeuralNetwork
    
    # Collection of activation functions with educational explanations
    module ActivationFunctions
      
      # Sigmoid activation function - classic choice for neural networks
      class Sigmoid
        def self.function
          lambda { |x| 1.0 / (1.0 + Math.exp(-x)) }
        end
        
        def self.derivative
          lambda { |y| y * (1.0 - y) }
        end
        
        def self.description
          "Sigmoid: Smooth S-shaped curve, outputs between 0 and 1. Good for binary classification."
        end
        
        def self.characteristics
          {
            range: [0.0, 1.0],
            differentiable: true,
            monotonic: true,
            zero_centered: false,
            vanishing_gradient_problem: true
          }
        end
      end
      
      # Hyperbolic Tangent - zero-centered alternative to sigmoid
      class Tanh
        def self.function
          lambda { |x| Math.tanh(x) }
        end
        
        def self.derivative
          lambda { |y| 1.0 - y**2 }
        end
        
        def self.description
          "Tanh: Zero-centered S-shaped curve, outputs between -1 and 1. Often better than sigmoid."
        end
        
        def self.characteristics
          {
            range: [-1.0, 1.0],
            differentiable: true,
            monotonic: true,
            zero_centered: true,
            vanishing_gradient_problem: true
          }
        end
      end
      
      # ReLU - Rectified Linear Unit, modern default choice
      class ReLU
        def self.function
          lambda { |x| [0.0, x].max }
        end
        
        def self.derivative
          lambda { |y| y > 0 ? 1.0 : 0.0 }
        end
        
        def self.description
          "ReLU: Simple and effective, outputs x if positive, 0 otherwise. Fast training, no vanishing gradients."
        end
        
        def self.characteristics
          {
            range: [0.0, Float::INFINITY],
            differentiable: false,  # at x=0
            monotonic: true,
            zero_centered: false,
            vanishing_gradient_problem: false
          }
        end
      end
      
      # Leaky ReLU - Addresses "dying ReLU" problem
      class LeakyReLU
        def self.function(alpha = 0.01)
          lambda { |x| x > 0 ? x : alpha * x }
        end
        
        def self.derivative(alpha = 0.01)
          lambda { |y| y > 0 ? 1.0 : alpha }
        end
        
        def self.description
          "Leaky ReLU: Like ReLU but allows small negative values. Prevents 'dead neurons'."
        end
        
        def self.characteristics
          {
            range: [-Float::INFINITY, Float::INFINITY],
            differentiable: false,  # at x=0
            monotonic: true,
            zero_centered: false,
            vanishing_gradient_problem: false
          }
        end
      end
      
      # ELU - Exponential Linear Unit
      class ELU
        def self.function(alpha = 1.0)
          lambda { |x| x > 0 ? x : alpha * (Math.exp(x) - 1) }
        end
        
        def self.derivative(alpha = 1.0)
          lambda { |x, y| x > 0 ? 1.0 : y + alpha }  # Note: needs both x and y
        end
        
        def self.description
          "ELU: Smooth function that can produce negative outputs. Zero-centered, no vanishing gradients."
        end
        
        def self.characteristics
          {
            range: [-1.0, Float::INFINITY],  # with alpha=1
            differentiable: true,
            monotonic: true,
            zero_centered: true,
            vanishing_gradient_problem: false
          }
        end
      end
      
      # Linear activation - no transformation
      class Linear
        def self.function
          lambda { |x| x }
        end
        
        def self.derivative
          lambda { |y| 1.0 }
        end
        
        def self.description
          "Linear: No transformation, output equals input. Used in regression output layers."
        end
        
        def self.characteristics
          {
            range: [-Float::INFINITY, Float::INFINITY],
            differentiable: true,
            monotonic: true,
            zero_centered: true,
            vanishing_gradient_problem: false
          }
        end
      end
      
      # Swish - Self-gated activation function
      class Swish
        def self.function
          lambda { |x| x / (1.0 + Math.exp(-x)) }
        end
        
        def self.derivative
          lambda { |x| 
            sigmoid_x = 1.0 / (1.0 + Math.exp(-x))
            sigmoid_x + x * sigmoid_x * (1.0 - sigmoid_x)
          }
        end
        
        def self.description
          "Swish: Self-gated function, x * sigmoid(x). Smooth and often outperforms ReLU."
        end
        
        def self.characteristics
          {
            range: [-0.28, Float::INFINITY],
            differentiable: true,
            monotonic: false,
            zero_centered: false,
            vanishing_gradient_problem: false
          }
        end
      end
      
      # Softmax - for multi-class classification output layers
      class Softmax
        def self.function(vector)
          # Subtract max for numerical stability
          shifted = vector.map { |x| x - vector.max }
          exp_values = shifted.map { |x| Math.exp(x) }
          sum_exp = exp_values.sum
          exp_values.map { |exp_val| exp_val / sum_exp }
        end
        
        def self.derivative(softmax_output, i, j)
          # Jacobian matrix element
          if i == j
            softmax_output[i] * (1.0 - softmax_output[i])
          else
            -softmax_output[i] * softmax_output[j]
          end
        end
        
        def self.description
          "Softmax: Converts vector to probability distribution. Sum of outputs equals 1."
        end
        
        def self.characteristics
          {
            range: [0.0, 1.0],
            differentiable: true,
            sum_equals_one: true,
            vector_function: true
          }
        end
      end
      
      # Factory for creating activation functions
      class ActivationFactory
        AVAILABLE_FUNCTIONS = {
          sigmoid: Sigmoid,
          tanh: Tanh,
          relu: ReLU,
          leaky_relu: LeakyReLU,
          elu: ELU,
          linear: Linear,
          swish: Swish,
          softmax: Softmax
        }.freeze
        
        def self.create(function_name, options = {})
          function_class = AVAILABLE_FUNCTIONS[function_name.to_sym]
          raise ArgumentError, "Unknown activation function: #{function_name}" unless function_class
          
          case function_name.to_sym
          when :leaky_relu
            alpha = options[:alpha] || 0.01
            {
              function: function_class.function(alpha),
              derivative: function_class.derivative(alpha),
              description: function_class.description,
              characteristics: function_class.characteristics
            }
          when :elu
            alpha = options[:alpha] || 1.0
            {
              function: function_class.function(alpha),
              derivative: function_class.derivative(alpha),
              description: function_class.description,
              characteristics: function_class.characteristics
            }
          when :softmax
            {
              function: function_class.method(:function),
              derivative: function_class.method(:derivative),
              description: function_class.description,
              characteristics: function_class.characteristics
            }
          else
            {
              function: function_class.function,
              derivative: function_class.derivative,
              description: function_class.description,
              characteristics: function_class.characteristics
            }
          end
        end
        
        def self.list_functions
          AVAILABLE_FUNCTIONS.keys
        end
        
        def self.compare_functions(input_range = (-5..5), step = 0.1)
          puts "=== Activation Function Comparison ==="
          puts "Input range: #{input_range}"
          puts
          
          inputs = input_range.step(step).to_a
          
          AVAILABLE_FUNCTIONS.each do |name, function_class|
            next if name == :softmax  # Skip vector function
            
            puts "#{name.to_s.upcase}:"
            puts "  #{function_class.description}"
            puts "  Characteristics: #{function_class.characteristics}"
            
            activation = create(name)
            sample_inputs = [-2, -1, 0, 1, 2]
            
            puts "  Sample values:"
            sample_inputs.each do |input|
              output = activation[:function].call(input)
              derivative = activation[:derivative].call(output)
              puts "    f(#{input}) = #{output.round(4)}, f'(#{output.round(4)}) = #{derivative.round(4)}"
            end
            puts
          end
        end
        
        def self.recommend_function(problem_type)
          recommendations = {
            binary_classification: "sigmoid (output layer) or relu (hidden layers)",
            multiclass_classification: "softmax (output layer) and relu (hidden layers)",
            regression: "linear (output layer) and relu or tanh (hidden layers)",
            autoencoder: "sigmoid or tanh for symmetry",
            deep_network: "relu or leaky_relu to avoid vanishing gradients",
            recurrent_network: "tanh or sigmoid for gating mechanisms"
          }
          
          recommendation = recommendations[problem_type.to_sym]
          if recommendation
            puts "For #{problem_type.to_s.humanize}, recommend: #{recommendation}"
          else
            puts "Available problem types: #{recommendations.keys.join(', ')}"
          end
          
          recommendation
        end
      end
      
      # Educational tools for understanding activation functions
      class ActivationAnalyzer
        def self.plot_function(function_name, range = (-5..5), step = 0.1)
          activation = ActivationFactory.create(function_name)
          inputs = range.step(step).to_a
          
          puts "=== #{function_name.to_s.upcase} Activation Function ==="
          puts activation[:description]
          puts
          
          # Simple ASCII plot
          outputs = inputs.map { |x| activation[:function].call(x) }
          min_output, max_output = outputs.minmax
          
          puts "Input  | Output   | Derivative | Visualization"
          puts "-------|----------|------------|---------------"
          
          sample_inputs = inputs.select.with_index { |_, i| i % (inputs.length / 20).ceil == 0 }
          sample_inputs.each do |input|
            output = activation[:function].call(input)
            derivative = activation[:derivative].call(output)
            
            # Simple visualization bar
            if max_output > min_output
              normalized = (output - min_output) / (max_output - min_output)
              bar_length = (normalized * 20).to_i
              bar = "█" * bar_length + "░" * (20 - bar_length)
            else
              bar = "█" * 10 + "░" * 10
            end
            
            puts sprintf("%6.2f | %8.4f | %10.4f | %s", input, output, derivative, bar)
          end
          
          puts
          puts "Function characteristics:"
          activation[:characteristics].each do |key, value|
            puts "  #{key}: #{value}"
          end
        end
        
        def self.analyze_gradients(function_name, input_values = [-3, -1, 0, 1, 3])
          activation = ActivationFactory.create(function_name)
          
          puts "=== Gradient Analysis for #{function_name.to_s.upcase} ==="
          puts
          
          puts "Input | Output | Derivative | Gradient Flow"
          puts "------|--------|------------|---------------"
          
          input_values.each do |input|
            output = activation[:function].call(input)
            derivative = activation[:derivative].call(output)
            
            # Classify gradient strength
            gradient_strength = case derivative.abs
                               when 0...0.01 then "Very Weak   ⚠️"
                               when 0.01...0.1 then "Weak       ⚠️"
                               when 0.1...0.5 then "Moderate   ✓"
                               when 0.5...1.0 then "Strong     ✓"
                               else "Very Strong ✓"
                               end
            
            puts sprintf("%5.1f | %6.3f | %10.4f | %s", input, output, derivative, gradient_strength)
          end
          
          puts
          puts "Gradient flow analysis:"
          if activation[:characteristics][:vanishing_gradient_problem]
            puts "⚠️  This function may suffer from vanishing gradients in deep networks"
          else
            puts "✓ This function maintains good gradient flow"
          end
        end
        
        def self.educational_summary
          puts "=== Activation Functions Educational Summary ==="
          puts
          puts "Activation functions determine the output of neurons and affect:"
          puts "• Learning speed and stability"
          puts "• Gradient flow in deep networks"
          puts "• Network expressiveness"
          puts "• Output interpretation"
          puts
          puts "Key considerations when choosing activation functions:"
          puts "1. Problem type (classification, regression, etc.)"
          puts "2. Network depth (vanishing gradients)"
          puts "3. Output requirements (range, interpretation)"
          puts "4. Training speed requirements"
          puts
          puts "Common patterns:"
          puts "• Hidden layers: ReLU (modern default) or Tanh (classical)"
          puts "• Binary classification output: Sigmoid"
          puts "• Multi-class classification output: Softmax"
          puts "• Regression output: Linear"
          puts "• Deep networks: ReLU variants to avoid vanishing gradients"
          puts
          puts "Experiment with different functions to understand their behavior!"
        end
      end
    end
  end
end