# frozen_string_literal: true

# Extensions to Ruby's Array class for AI4R
# These are optional and can be loaded separately
module Ai4r
  module Core
    module Extensions
      module ArrayExtensions
        def mean
          return 0.0 if empty?
          sum.to_f / size
        end
        
        def variance
          return 0.0 if size <= 1
          m = mean
          map { |x| (x - m) ** 2 }.sum / (size - 1)
        end
        
        def standard_deviation
          Math.sqrt(variance)
        end
        
        def normalize
          min, max = minmax
          range = max - min
          return map { 0.5 } if range.zero?
          map { |x| (x - min) / range.to_f }
        end
        
        def standardize
          m = mean
          sd = standard_deviation
          return map { 0.0 } if sd.zero?
          map { |x| (x - m) / sd }
        end
        
        def dot_product(other)
          raise ArgumentError, "Arrays must have same length" unless size == other.size
          zip(other).map { |a, b| a * b }.sum
        end
        
        def euclidean_distance_to(other)
          raise ArgumentError, "Arrays must have same length" unless size == other.size
          Math.sqrt(zip(other).map { |a, b| (a - b) ** 2 }.sum)
        end
        
        def cosine_similarity_to(other)
          raise ArgumentError, "Arrays must have same length" unless size == other.size
          
          dot_prod = dot_product(other)
          mag1 = Math.sqrt(map { |x| x ** 2 }.sum)
          mag2 = Math.sqrt(other.map { |x| x ** 2 }.sum)
          
          return 0.0 if mag1.zero? || mag2.zero?
          dot_prod / (mag1 * mag2)
        end
      end
    end
  end
end

# Optionally extend Array class
# Array.include(Ai4r::Core::Extensions::ArrayExtensions)