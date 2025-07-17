# frozen_string_literal: true

module Ai4r
  module Core
    module Helpers
      # Helper methods for Array operations used throughout AI4R
      module ArrayHelper
        # Calculate the mean of an array of numbers
        def self.mean(array)
          return 0.0 if array.empty?
          array.sum.to_f / array.size
        end
        
        # Calculate the variance of an array
        def self.variance(array)
          return 0.0 if array.size <= 1
          m = mean(array)
          array.map { |x| (x - m) ** 2 }.sum / (array.size - 1)
        end
        
        # Calculate standard deviation
        def self.standard_deviation(array)
          Math.sqrt(variance(array))
        end
        
        # Normalize array to [0, 1] range
        def self.normalize(array)
          min, max = array.minmax
          range = max - min
          return array.map { 0.5 } if range.zero?
          array.map { |x| (x - min) / range.to_f }
        end
        
        # Standardize array (zero mean, unit variance)
        def self.standardize(array)
          m = mean(array)
          sd = standard_deviation(array)
          return array.map { 0.0 } if sd.zero?
          array.map { |x| (x - m) / sd }
        end
        
        # Calculate dot product of two arrays
        def self.dot_product(a, b)
          raise ArgumentError, "Arrays must have same length" unless a.size == b.size
          a.zip(b).map { |x, y| x * y }.sum
        end
        
        # Calculate Euclidean distance between two arrays
        def self.euclidean_distance(a, b)
          raise ArgumentError, "Arrays must have same length" unless a.size == b.size
          Math.sqrt(a.zip(b).map { |x, y| (x - y) ** 2 }.sum)
        end
        
        # Element-wise operations
        def self.element_wise_add(a, b)
          raise ArgumentError, "Arrays must have same length" unless a.size == b.size
          a.zip(b).map { |x, y| x + y }
        end
        
        def self.element_wise_multiply(a, scalar_or_array)
          if scalar_or_array.is_a?(Array)
            raise ArgumentError, "Arrays must have same length" unless a.size == scalar_or_array.size
            a.zip(scalar_or_array).map { |x, y| x * y }
          else
            a.map { |x| x * scalar_or_array }
          end
        end
        
        # Sample with replacement
        def self.sample_with_replacement(array, n)
          Array.new(n) { array.sample }
        end
        
        # Shuffle array deterministically with seed
        def self.shuffle_with_seed(array, seed)
          rng = Random.new(seed)
          array.sort_by { rng.rand }
        end
      end
    end
  end
end