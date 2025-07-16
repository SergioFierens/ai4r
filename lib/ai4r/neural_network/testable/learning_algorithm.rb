# frozen_string_literal: true

module Ai4r
  module NeuralNetwork
    module Testable
      # Base class for learning algorithms
      # Provides clean interface and state management for testability
      class LearningAlgorithm
        attr_reader :iteration_count

        def initialize
          @iteration_count = 0
          @state = {}
        end

        # Update weights based on gradients
        # @param weights [Array<Array<Float>>] Current weights
        # @param gradients [Array<Array<Float>>] Gradients
        # @param layer_index [Integer] Layer index (for layer-specific behavior)
        # @return [Array<Array<Float>>] Updated weights
        def update_weights(weights, gradients, layer_index = 0)
          raise NotImplementedError, 'Subclasses must implement update_weights'
        end

        # Step the iteration counter
        def step
          @iteration_count += 1
        end

        # Reset algorithm state
        def reset
          @iteration_count = 0
          @state.clear
        end

        # Get current state (for testing/debugging)
        # @return [Hash] Current algorithm state
        def current_state
          {
            iteration: @iteration_count,
            internal_state: @state.dup
          }
        end

        # Standard Gradient Descent
        class GradientDescent < LearningAlgorithm
          attr_reader :learning_rate

          def initialize(learning_rate: 0.01)
            super()
            @learning_rate = learning_rate
          end

          def update_weights(weights, gradients, layer_index = 0)
            weights.map.with_index do |weight_row, i|
              weight_row.map.with_index do |weight, j|
                weight - @learning_rate * gradients[i][j]
              end
            end
          end
        end

        # Gradient Descent with Momentum
        class Momentum < LearningAlgorithm
          attr_reader :learning_rate, :momentum_factor

          def initialize(learning_rate: 0.01, momentum_factor: 0.9)
            super()
            @learning_rate = learning_rate
            @momentum_factor = momentum_factor
          end

          def update_weights(weights, gradients, layer_index = 0)
            # Initialize velocity for this layer if not exists
            layer_key = "layer_#{layer_index}_velocity"
            @state[layer_key] ||= create_zero_matrix(weights)
            
            velocity = @state[layer_key]
            
            # Update weights with momentum
            weights.map.with_index do |weight_row, i|
              weight_row.map.with_index do |weight, j|
                # Update velocity
                velocity[i][j] = @momentum_factor * velocity[i][j] + 
                                @learning_rate * gradients[i][j]
                
                # Update weight
                weight - velocity[i][j]
              end
            end
          end

          private

          def create_zero_matrix(template)
            template.map { |row| Array.new(row.size, 0.0) }
          end
        end

        # Adaptive Learning Rate (AdaGrad)
        class AdaGrad < LearningAlgorithm
          attr_reader :learning_rate, :epsilon

          def initialize(learning_rate: 0.01, epsilon: 1e-8)
            super()
            @learning_rate = learning_rate
            @epsilon = epsilon
          end

          def update_weights(weights, gradients, layer_index = 0)
            # Initialize accumulated squared gradients for this layer
            layer_key = "layer_#{layer_index}_acc_grad"
            @state[layer_key] ||= create_zero_matrix(weights)
            
            acc_grad = @state[layer_key]
            
            # Update weights with adaptive learning rate
            weights.map.with_index do |weight_row, i|
              weight_row.map.with_index do |weight, j|
                # Accumulate squared gradient
                acc_grad[i][j] += gradients[i][j] ** 2
                
                # Adaptive learning rate
                adapted_lr = @learning_rate / (Math.sqrt(acc_grad[i][j]) + @epsilon)
                
                # Update weight
                weight - adapted_lr * gradients[i][j]
              end
            end
          end

          private

          def create_zero_matrix(template)
            template.map { |row| Array.new(row.size, 0.0) }
          end
        end

        # Adam optimizer
        class Adam < LearningAlgorithm
          attr_reader :learning_rate, :beta1, :beta2, :epsilon

          def initialize(learning_rate: 0.001, beta1: 0.9, beta2: 0.999, epsilon: 1e-8)
            super()
            @learning_rate = learning_rate
            @beta1 = beta1
            @beta2 = beta2
            @epsilon = epsilon
          end

          def update_weights(weights, gradients, layer_index = 0)
            step # Increment iteration count for bias correction
            
            # Initialize moments for this layer
            m_key = "layer_#{layer_index}_m"
            v_key = "layer_#{layer_index}_v"
            @state[m_key] ||= create_zero_matrix(weights)
            @state[v_key] ||= create_zero_matrix(weights)
            
            m = @state[m_key]
            v = @state[v_key]
            
            # Update weights with Adam
            weights.map.with_index do |weight_row, i|
              weight_row.map.with_index do |weight, j|
                grad = gradients[i][j]
                
                # Update biased first moment
                m[i][j] = @beta1 * m[i][j] + (1 - @beta1) * grad
                
                # Update biased second moment
                v[i][j] = @beta2 * v[i][j] + (1 - @beta2) * (grad ** 2)
                
                # Bias correction
                m_corrected = m[i][j] / (1 - @beta1 ** @iteration_count)
                v_corrected = v[i][j] / (1 - @beta2 ** @iteration_count)
                
                # Update weight
                weight - @learning_rate * m_corrected / (Math.sqrt(v_corrected) + @epsilon)
              end
            end
          end

          private

          def create_zero_matrix(template)
            template.map { |row| Array.new(row.size, 0.0) }
          end
        end

        # Factory method for creating learning algorithms
        class Factory
          ALGORITHMS = {
            gradient_descent: GradientDescent,
            momentum: Momentum,
            adagrad: AdaGrad,
            adam: Adam
          }.freeze

          def self.create(algorithm, **options)
            klass = ALGORITHMS[algorithm]
            raise ArgumentError, "Unknown algorithm: #{algorithm}" unless klass
            
            klass.new(**options)
          end

          def self.available_algorithms
            ALGORITHMS.keys
          end
        end
      end
    end
  end
end