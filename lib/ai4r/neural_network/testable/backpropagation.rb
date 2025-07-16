# frozen_string_literal: true

require_relative '../../data/parameterizable'
require_relative 'weight_initializer'
require_relative 'activation_function'
require_relative 'network_validator'

module Ai4r
  module NeuralNetwork
    module Testable
      # Refactored Backpropagation implementation with improved testability
      # 
      # Key improvements:
      # - Dependency injection for all components
      # - Separation of concerns (validation, initialization, propagation)
      # - No hard-coded values
      # - Mockable dependencies
      # - Pure functions where possible
      # - Clear interfaces
      class Backpropagation
        include Ai4r::Data::Parameterizable

        attr_reader :structure, :weights, :activation_nodes, :last_changes
        attr_reader :weight_initializer, :activation_function, :validator
        attr_reader :learning_rate, :momentum, :disable_bias

        # Initialize with dependency injection
        # @param structure [Array<Integer>] Network architecture (e.g., [4, 3, 2])
        # @param options [Hash] Configuration options
        # @option options [WeightInitializer] :weight_initializer Weight initialization strategy
        # @option options [ActivationFunction] :activation_function Activation function
        # @option options [NetworkValidator] :validator Input/output validator
        # @option options [Float] :learning_rate Learning rate (default: 0.25)
        # @option options [Float] :momentum Momentum factor (default: 0.1)
        # @option options [Boolean] :disable_bias Disable bias nodes (default: false)
        def initialize(structure, options = {})
          @structure = structure
          
          # Dependency injection with sensible defaults
          @weight_initializer = options[:weight_initializer] || WeightInitializer::Random.new
          @activation_function = options[:activation_function] || ActivationFunction::Sigmoid.new
          @validator = options[:validator] || NetworkValidator.new
          
          # Configurable parameters
          @learning_rate = options[:learning_rate] || 0.25
          @momentum = options[:momentum] || 0.1
          @disable_bias = options[:disable_bias] || false
          
          # Validate structure
          @validator.validate_structure(@structure)
          
          # State will be initialized lazily or explicitly
          @weights = nil
          @activation_nodes = nil
          @last_changes = nil
        end

        # Evaluate input through the network
        # @param input_values [Array<Float>] Input values
        # @return [Array<Float>] Output values
        def eval(input_values)
          @validator.validate_input(input_values, @structure.first)
          init_network unless network_initialized?
          
          outputs = feedforward(input_values)
          outputs.clone # Return a copy to prevent external modification
        end

        # Evaluate and return the index of the most active output node
        # @param input_values [Array<Float>] Input values
        # @return [Integer] Index of most active output
        def eval_result(input_values)
          outputs = eval(input_values)
          outputs.index(outputs.max)
        end

        # Train the network with given input and expected output
        # @param inputs [Array<Float>] Input values
        # @param expected_outputs [Array<Float>] Expected output values
        # @return [Float] Network error
        def train(inputs, expected_outputs)
          @validator.validate_input(inputs, @structure.first)
          @validator.validate_output(expected_outputs, @structure.last)
          
          init_network unless network_initialized?
          
          # Forward pass
          actual_outputs = feedforward(inputs)
          
          # Backward pass
          backpropagate(expected_outputs)
          
          # Return error for monitoring
          calculate_error(actual_outputs, expected_outputs)
        end

        # Initialize or reset the network
        # @return [self]
        def init_network
          @activation_nodes = init_activation_nodes
          @weights = init_weights
          @last_changes = init_last_changes
          self
        end

        # Check if network is initialized
        # @return [Boolean]
        def network_initialized?
          !@weights.nil? && !@activation_nodes.nil?
        end

        # Get current network state for testing/debugging
        # @return [Hash] Network state
        def network_state
          {
            structure: @structure,
            weights: @weights&.map(&:dup),
            activation_nodes: @activation_nodes&.map(&:dup),
            learning_rate: @learning_rate,
            momentum: @momentum,
            disable_bias: @disable_bias
          }
        end

        private

        # Forward propagation through the network
        # @param input_values [Array<Float>] Input values
        # @return [Array<Float>] Output values
        def feedforward(input_values)
          # Set input layer
          input_values.each_with_index do |value, i|
            @activation_nodes[0][i] = value
          end
          
          # Propagate through layers
          (0...@weights.length).each do |layer_index|
            propagate_layer(layer_index)
          end
          
          @activation_nodes.last
        end

        # Propagate values through a single layer
        # @param layer_index [Integer] Index of the layer
        def propagate_layer(layer_index)
          current_layer = @activation_nodes[layer_index]
          next_layer = @activation_nodes[layer_index + 1]
          layer_weights = @weights[layer_index]
          
          next_layer.each_index do |j|
            sum = calculate_weighted_sum(current_layer, layer_weights, j)
            next_layer[j] = @activation_function.forward(sum)
          end
        end

        # Calculate weighted sum for a neuron
        # @param inputs [Array<Float>] Input values
        # @param weights [Array<Array<Float>>] Weight matrix
        # @param output_index [Integer] Index of output neuron
        # @return [Float] Weighted sum
        def calculate_weighted_sum(inputs, weights, output_index)
          inputs.each_with_index.sum do |input, i|
            input * weights[i][output_index]
          end
        end

        # Backpropagation algorithm
        # @param expected_outputs [Array<Float>] Expected output values
        def backpropagate(expected_outputs)
          # Calculate output layer deltas
          output_deltas = calculate_output_deltas(expected_outputs)
          
          # Calculate hidden layer deltas
          all_deltas = calculate_all_deltas(output_deltas)
          
          # Update weights
          update_all_weights(all_deltas)
        end

        # Calculate deltas for output layer
        # @param expected_outputs [Array<Float>] Expected outputs
        # @return [Array<Float>] Output deltas
        def calculate_output_deltas(expected_outputs)
          actual_outputs = @activation_nodes.last
          
          actual_outputs.each_with_index.map do |actual, i|
            error = expected_outputs[i] - actual
            error * @activation_function.derivative(actual)
          end
        end

        # Calculate deltas for all layers
        # @param output_deltas [Array<Float>] Output layer deltas
        # @return [Array<Array<Float>>] All layer deltas
        def calculate_all_deltas(output_deltas)
          deltas = Array.new(@weights.length)
          deltas[-1] = output_deltas
          
          # Backpropagate deltas
          (@weights.length - 2).downto(0) do |layer|
            deltas[layer] = calculate_hidden_deltas(layer, deltas[layer + 1])
          end
          
          deltas
        end

        # Calculate deltas for hidden layer
        # @param layer_index [Integer] Layer index
        # @param next_deltas [Array<Float>] Deltas from next layer
        # @return [Array<Float>] Hidden layer deltas
        def calculate_hidden_deltas(layer_index, next_deltas)
          layer_size = @structure[layer_index + 1]
          layer_weights = @weights[layer_index + 1]
          
          (0...layer_size).map do |i|
            error_sum = next_deltas.each_with_index.sum do |delta, j|
              delta * layer_weights[i][j]
            end
            
            activation = @activation_nodes[layer_index + 1][i]
            error_sum * @activation_function.derivative(activation)
          end
        end

        # Update all weights using deltas
        # @param deltas [Array<Array<Float>>] All layer deltas
        def update_all_weights(deltas)
          @weights.each_with_index do |layer_weights, layer|
            update_layer_weights(layer, layer_weights, deltas[layer])
          end
        end

        # Update weights for a single layer
        # @param layer_index [Integer] Layer index
        # @param layer_weights [Array<Array<Float>>] Layer weight matrix
        # @param layer_deltas [Array<Float>] Layer deltas
        def update_layer_weights(layer_index, layer_weights, layer_deltas)
          layer_weights.each_with_index do |neuron_weights, i|
            neuron_weights.each_with_index do |weight, j|
              # Calculate weight change
              delta = layer_deltas[j]
              input = @activation_nodes[layer_index][i]
              weight_change = @learning_rate * delta * input
              
              # Add momentum if enabled
              if @momentum > 0
                weight_change += @momentum * @last_changes[layer_index][i][j]
                @last_changes[layer_index][i][j] = weight_change
              end
              
              # Update weight
              layer_weights[i][j] = weight + weight_change
            end
          end
        end

        # Calculate network error
        # @param actual_outputs [Array<Float>] Actual outputs
        # @param expected_outputs [Array<Float>] Expected outputs
        # @return [Float] Mean squared error
        def calculate_error(actual_outputs, expected_outputs)
          sum_squared_error = actual_outputs.zip(expected_outputs).sum do |actual, expected|
            (expected - actual) ** 2
          end
          
          0.5 * sum_squared_error
        end

        # Initialize activation nodes
        # @return [Array<Array<Float>>] Activation nodes
        def init_activation_nodes
          @structure.map.with_index do |layer_size, layer_index|
            # Add bias node except for output layer
            size = layer_size
            size += 1 if add_bias_node?(layer_index)
            
            Array.new(size, 0.0)
          end
        end

        # Initialize weights
        # @return [Array<Array<Array<Float>>>] Weight matrices
        def init_weights
          (0...@structure.length - 1).map do |layer|
            from_size = @structure[layer]
            from_size += 1 if add_bias_node?(layer)
            to_size = @structure[layer + 1]
            
            @weight_initializer.initialize_matrix(from_size, to_size, layer)
          end
        end

        # Initialize last changes for momentum
        # @return [Array<Array<Array<Float>>>] Last change matrices
        def init_last_changes
          @weights.map do |layer_weights|
            layer_weights.map do |neuron_weights|
              Array.new(neuron_weights.size, 0.0)
            end
          end
        end

        # Check if bias node should be added to layer
        # @param layer_index [Integer] Layer index
        # @return [Boolean]
        def add_bias_node?(layer_index)
          !@disable_bias && layer_index < @structure.length - 1
        end
      end
    end
  end
end