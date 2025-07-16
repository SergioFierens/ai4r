# frozen_string_literal: true

module Ai4r
  module NeuralNetwork
    module Testable
      # Validates network structure and inputs/outputs
      # Extracted to separate class for better testability and single responsibility
      class NetworkValidator
        # Validate network structure
        # @param structure [Array<Integer>] Network architecture
        # @raise [ArgumentError] If structure is invalid
        def validate_structure(structure)
          raise ArgumentError, 'Network structure cannot be nil' if structure.nil?
          raise ArgumentError, 'Network structure cannot be empty' if structure.empty?
          raise ArgumentError, 'Network must have at least 2 layers' if structure.length < 2
          
          structure.each_with_index do |layer_size, index|
            unless layer_size.is_a?(Integer) && layer_size > 0
              raise ArgumentError, "Layer #{index} size must be a positive integer, got #{layer_size}"
            end
          end
        end

        # Validate input dimensions
        # @param inputs [Array<Float>] Input values
        # @param expected_size [Integer] Expected input size
        # @raise [ArgumentError] If input is invalid
        def validate_input(inputs, expected_size)
          raise ArgumentError, 'Input cannot be nil' if inputs.nil?
          raise ArgumentError, 'Input must be an array' unless inputs.is_a?(Array)
          
          if inputs.length != expected_size
            raise ArgumentError, "Input size mismatch. Expected #{expected_size}, got #{inputs.length}"
          end
          
          validate_numeric_array(inputs, 'Input')
        end

        # Validate output dimensions
        # @param outputs [Array<Float>] Output values
        # @param expected_size [Integer] Expected output size
        # @raise [ArgumentError] If output is invalid
        def validate_output(outputs, expected_size)
          raise ArgumentError, 'Output cannot be nil' if outputs.nil?
          raise ArgumentError, 'Output must be an array' unless outputs.is_a?(Array)
          
          if outputs.length != expected_size
            raise ArgumentError, "Output size mismatch. Expected #{expected_size}, got #{outputs.length}"
          end
          
          validate_numeric_array(outputs, 'Output')
        end

        # Validate training data
        # @param training_data [Array<Hash>] Training examples
        # @param input_size [Integer] Expected input size
        # @param output_size [Integer] Expected output size
        # @raise [ArgumentError] If training data is invalid
        def validate_training_data(training_data, input_size, output_size)
          raise ArgumentError, 'Training data cannot be nil' if training_data.nil?
          raise ArgumentError, 'Training data cannot be empty' if training_data.empty?
          raise ArgumentError, 'Training data must be an array' unless training_data.is_a?(Array)
          
          training_data.each_with_index do |example, index|
            unless example.is_a?(Hash) && example[:input] && example[:output]
              raise ArgumentError, "Training example #{index} must have :input and :output keys"
            end
            
            begin
              validate_input(example[:input], input_size)
              validate_output(example[:output], output_size)
            rescue ArgumentError => e
              raise ArgumentError, "Training example #{index}: #{e.message}"
            end
          end
        end

        private

        # Validate that array contains only numeric values
        # @param array [Array] Array to validate
        # @param name [String] Name for error messages
        # @raise [ArgumentError] If array contains non-numeric values
        def validate_numeric_array(array, name)
          array.each_with_index do |value, index|
            unless value.is_a?(Numeric)
              raise ArgumentError, "#{name}[#{index}] must be numeric, got #{value.class}"
            end
            
            if value.nan? || value.infinite?
              raise ArgumentError, "#{name}[#{index}] must be finite, got #{value}"
            end
          end
        end
      end
    end
  end
end