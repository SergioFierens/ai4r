# frozen_string_literal: true

# Central file to require all helper modules
require_relative 'helpers/array_helper'
require_relative 'helpers/math_helper'
require_relative 'helpers/validation_helper'

module Ai4r
  module Core
    # Central namespace for all helper modules
    module Helpers
      # Make helpers available at module level for convenience
      extend ArrayHelper
      extend MathHelper
      extend ValidationHelper
      
      # Also make them available as module functions
      module_function
      
      # Array helpers
      def mean(array)
        ArrayHelper.mean(array)
      end
      
      def variance(array)
        ArrayHelper.variance(array)
      end
      
      def standard_deviation(array)
        ArrayHelper.standard_deviation(array)
      end
      
      def normalize(array)
        ArrayHelper.normalize(array)
      end
      
      def standardize(array)
        ArrayHelper.standardize(array)
      end
      
      # Math helpers
      def sigmoid(x)
        MathHelper.sigmoid(x)
      end
      
      def tanh(x)
        MathHelper.tanh(x)
      end
      
      def relu(x)
        MathHelper.relu(x)
      end
      
      def softmax(array)
        MathHelper.softmax(array)
      end
      
      def euclidean_distance(p1, p2)
        MathHelper.euclidean_distance(p1, p2)
      end
      
      # Validation helpers
      def validate_numeric(value, name = "Value")
        ValidationHelper.validate_numeric(value, name)
      end
      
      def validate_probability(value, name = "Probability")
        ValidationHelper.validate_probability(value, name)
      end
      
      def validate_dataset(dataset)
        ValidationHelper.validate_dataset(dataset)
      end
    end
  end
end