# frozen_string_literal: true

module Ai4r
  module Core
    module Helpers
      # Mathematical helper methods used throughout AI4R
      module MathHelper
        # Sigmoid function
        def self.sigmoid(x)
          1.0 / (1.0 + Math.exp(-x))
        end
        
        # Sigmoid derivative (given sigmoid output)
        def self.sigmoid_derivative(sigmoid_output)
          sigmoid_output * (1.0 - sigmoid_output)
        end
        
        # Hyperbolic tangent
        def self.tanh(x)
          Math.tanh(x)
        end
        
        # Tanh derivative (given tanh output)
        def self.tanh_derivative(tanh_output)
          1.0 - tanh_output ** 2
        end
        
        # ReLU (Rectified Linear Unit)
        def self.relu(x)
          x > 0 ? x : 0.0
        end
        
        # ReLU derivative
        def self.relu_derivative(x)
          x > 0 ? 1.0 : 0.0
        end
        
        # Softmax function for array
        def self.softmax(array)
          # Subtract max for numerical stability
          max = array.max
          exp_values = array.map { |x| Math.exp(x - max) }
          sum = exp_values.sum
          exp_values.map { |x| x / sum }
        end
        
        # Cross entropy loss
        def self.cross_entropy(predicted, actual, epsilon = 1e-15)
          # Clip values to prevent log(0)
          predicted = predicted.map { |p| [[p, 1 - epsilon].min, epsilon].max }
          
          -actual.zip(predicted).map { |a, p| a * Math.log(p) }.sum
        end
        
        # Mean squared error
        def self.mean_squared_error(predicted, actual)
          raise ArgumentError, "Arrays must have same length" unless predicted.size == actual.size
          
          predicted.zip(actual).map { |p, a| (p - a) ** 2 }.sum / predicted.size
        end
        
        # Root mean squared error
        def self.root_mean_squared_error(predicted, actual)
          Math.sqrt(mean_squared_error(predicted, actual))
        end
        
        # R-squared (coefficient of determination)
        def self.r_squared(predicted, actual)
          raise ArgumentError, "Arrays must have same length" unless predicted.size == actual.size
          
          mean_actual = actual.sum.to_f / actual.size
          ss_total = actual.map { |a| (a - mean_actual) ** 2 }.sum
          ss_residual = predicted.zip(actual).map { |p, a| (a - p) ** 2 }.sum
          
          return 0.0 if ss_total.zero?
          1.0 - (ss_residual / ss_total)
        end
        
        # Gaussian (normal) distribution probability density
        def self.gaussian_pdf(x, mean, std_dev)
          return Float::INFINITY if std_dev.zero?
          
          coefficient = 1.0 / (std_dev * Math.sqrt(2 * Math::PI))
          exponent = -0.5 * ((x - mean) / std_dev) ** 2
          coefficient * Math.exp(exponent)
        end
        
        # Euclidean distance between two points
        def self.euclidean_distance(point1, point2)
          raise ArgumentError, "Points must have same dimensions" unless point1.size == point2.size
          
          Math.sqrt(point1.zip(point2).map { |a, b| (a - b) ** 2 }.sum)
        end
        
        # Manhattan distance
        def self.manhattan_distance(point1, point2)
          raise ArgumentError, "Points must have same dimensions" unless point1.size == point2.size
          
          point1.zip(point2).map { |a, b| (a - b).abs }.sum
        end
        
        # Cosine similarity
        def self.cosine_similarity(vector1, vector2)
          raise ArgumentError, "Vectors must have same dimensions" unless vector1.size == vector2.size
          
          dot_product = vector1.zip(vector2).map { |a, b| a * b }.sum
          magnitude1 = Math.sqrt(vector1.map { |x| x ** 2 }.sum)
          magnitude2 = Math.sqrt(vector2.map { |x| x ** 2 }.sum)
          
          return 0.0 if magnitude1.zero? || magnitude2.zero?
          dot_product / (magnitude1 * magnitude2)
        end
        
        # Logistic function (generalized sigmoid)
        def self.logistic(x, k = 1.0, x0 = 0.0, l = 1.0)
          l / (1.0 + Math.exp(-k * (x - x0)))
        end
      end
    end
  end
end