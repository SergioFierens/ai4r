# frozen_string_literal: true

module Ai4r
  module NeuralNetwork
    module Testable
      # Base class for weight initialization strategies
      # This allows for easy testing by injecting different strategies
      class WeightInitializer
        # Initialize a weight matrix
        # @param from_size [Integer] Number of neurons in source layer
        # @param to_size [Integer] Number of neurons in destination layer
        # @param layer_index [Integer] Index of the layer (for layer-specific strategies)
        # @return [Array<Array<Float>>] Weight matrix
        def initialize_matrix(from_size, to_size, layer_index = 0)
          raise NotImplementedError, 'Subclasses must implement initialize_matrix'
        end

        # Random weight initializer (uniform distribution)
        class Random < WeightInitializer
          def initialize(range: (-1.0...1.0), random: ::Random.new)
            @range = range
            @random = random
          end

          def initialize_matrix(from_size, to_size, layer_index = 0)
            Array.new(from_size) do
              Array.new(to_size) do
                @random.rand(@range)
              end
            end
          end
        end

        # Xavier/Glorot initialization
        class Xavier < WeightInitializer
          def initialize(random: ::Random.new)
            @random = random
          end

          def initialize_matrix(from_size, to_size, layer_index = 0)
            # Xavier initialization: weights ~ U[-sqrt(6/(n_in+n_out)), sqrt(6/(n_in+n_out))]
            limit = Math.sqrt(6.0 / (from_size + to_size))
            
            Array.new(from_size) do
              Array.new(to_size) do
                @random.rand(-limit...limit)
              end
            end
          end
        end

        # He initialization (good for ReLU activation)
        class He < WeightInitializer
          def initialize(random: ::Random.new)
            @random = random
          end

          def initialize_matrix(from_size, to_size, layer_index = 0)
            # He initialization: weights ~ N(0, sqrt(2/n_in))
            std_dev = Math.sqrt(2.0 / from_size)
            
            Array.new(from_size) do
              Array.new(to_size) do
                # Box-Muller transform for normal distribution
                u1 = @random.rand
                u2 = @random.rand
                z0 = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math::PI * u2)
                z0 * std_dev
              end
            end
          end
        end

        # Fixed weights for testing
        class Fixed < WeightInitializer
          def initialize(value: 0.5)
            @value = value
          end

          def initialize_matrix(from_size, to_size, layer_index = 0)
            Array.new(from_size) do
              Array.new(to_size, @value)
            end
          end
        end

        # Custom function initializer
        class Custom < WeightInitializer
          def initialize(&block)
            @initializer_function = block
          end

          def initialize_matrix(from_size, to_size, layer_index = 0)
            Array.new(from_size) do |i|
              Array.new(to_size) do |j|
                @initializer_function.call(layer_index, i, j)
              end
            end
          end
        end
      end
    end
  end
end