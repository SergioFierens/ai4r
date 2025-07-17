# frozen_string_literal: true

module Ai4r
  module Core
    module Helpers
      # Helper methods for input validation used throughout AI4R
      module ValidationHelper
        # Validate that a value is numeric
        def self.validate_numeric(value, name = "Value")
          raise ArgumentError, "#{name} must be numeric, got #{value.class}" unless value.is_a?(Numeric)
          raise ArgumentError, "#{name} cannot be NaN" if value.respond_to?(:nan?) && value.nan?
          raise ArgumentError, "#{name} cannot be infinite" if value.respond_to?(:infinite?) && value.infinite?
          value
        end
        
        # Validate that a value is within range
        def self.validate_range(value, min, max, name = "Value")
          validate_numeric(value, name)
          unless value >= min && value <= max
            raise ArgumentError, "#{name} must be between #{min} and #{max}, got #{value}"
          end
          value
        end
        
        # Validate probability (0 to 1)
        def self.validate_probability(value, name = "Probability")
          validate_range(value, 0.0, 1.0, name)
        end
        
        # Validate positive integer
        def self.validate_positive_integer(value, name = "Value")
          unless value.is_a?(Integer) && value > 0
            raise ArgumentError, "#{name} must be a positive integer, got #{value}"
          end
          value
        end
        
        # Validate array of numbers
        def self.validate_numeric_array(array, name = "Array")
          raise ArgumentError, "#{name} must be an array" unless array.is_a?(Array)
          raise ArgumentError, "#{name} cannot be empty" if array.empty?
          
          array.each_with_index do |value, i|
            validate_numeric(value, "#{name}[#{i}]")
          end
          array
        end
        
        # Validate 2D array (matrix)
        def self.validate_matrix(matrix, name = "Matrix")
          raise ArgumentError, "#{name} must be an array" unless matrix.is_a?(Array)
          raise ArgumentError, "#{name} cannot be empty" if matrix.empty?
          
          first_row_size = nil
          matrix.each_with_index do |row, i|
            raise ArgumentError, "#{name}[#{i}] must be an array" unless row.is_a?(Array)
            
            if first_row_size.nil?
              first_row_size = row.size
            elsif row.size != first_row_size
              raise ArgumentError, "#{name} rows must have same size"
            end
            
            validate_numeric_array(row, "#{name}[#{i}]")
          end
          matrix
        end
        
        # Validate dataset
        def self.validate_dataset(dataset)
          raise ArgumentError, "Dataset cannot be nil" if dataset.nil?
          
          if dataset.respond_to?(:data_items)
            raise ArgumentError, "Dataset must have data_items" if dataset.data_items.nil?
            validate_matrix(dataset.data_items, "Dataset data_items")
          else
            raise ArgumentError, "Dataset must respond to data_items"
          end
          
          dataset
        end
        
        # Validate that array elements sum to 1 (for probability distributions)
        def self.validate_probability_distribution(array, tolerance = 1e-6)
          validate_numeric_array(array, "Probability distribution")
          
          array.each_with_index do |p, i|
            validate_probability(p, "Probability[#{i}]")
          end
          
          sum = array.sum
          unless (sum - 1.0).abs < tolerance
            raise ArgumentError, "Probabilities must sum to 1.0, got #{sum}"
          end
          
          array
        end
      end
    end
  end
end