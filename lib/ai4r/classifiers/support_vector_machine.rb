# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# A minimal linear Support Vector Machine implementation using
# stochastic gradient descent. This implementation is intentionally
# simple and only supports binary classification with numeric
# attributes.

require_relative '../data/data_set'
require_relative 'classifier'

module Ai4r
  module Classifiers
    # A lightweight linear SVM classifier trained via gradient descent.
    # Only two classes are supported. Predictions return the same class
    # labels used in the training data.
    class SupportVectorMachine < Classifier
      attr_reader :weights, :bias, :classes

      parameters_info learning_rate: 'Learning rate for gradient descent.',
                      iterations: 'Training iterations.',
                      c: 'Regularization strength.'

      def initialize
        @learning_rate = 0.01
        @iterations = 1000
        @c = 1.0
        @weights = []
        @bias = 0.0
        @classes = []
      end

      # Train the SVM using the provided DataSet. Only numeric attributes and
      # exactly two classes are supported.
      def build(data_set)
        data_set.check_not_empty
        @classes = data_set.build_domains.last.to_a
        raise ArgumentError, 'SVM only supports two classes' unless @classes.size == 2

        num_features = data_set.data_labels.length - 1
        @weights = Array.new(num_features, 0.0)
        @bias = 0.0

        samples = data_set.data_items.map do |row|
          [row[0...-1].map(&:to_f), row.last]
        end

        @iterations.times do
          samples.each do |features, label|
            y = label == @classes[0] ? 1.0 : -1.0
            prediction = dot(@weights, features) + @bias
            if y * prediction < 1
              @weights.map!.with_index do |w, i|
                w + (@learning_rate * ((@c * y * features[i]) - (2 * w)))
              end
              @bias += @learning_rate * @c * y
            else
              @weights.map!.with_index { |w, _i| w - (@learning_rate * 2 * w) }
            end
          end
        end
        self
      end

      # Predict the class for the given numeric feature vector.
      def eval(data)
        score = dot(@weights, data.map(&:to_f)) + @bias
        score >= 0 ? @classes[0] : @classes[1]
      end

      # Support Vector Machine classifiers cannot generate human readable rules.
      # This method returns a string indicating rule extraction is unsupported.
      def get_rules
        'SupportVectorMachine does not support rule extraction.'
      end

      private

      def dot(a, b)
        sum = 0.0
        a.each_index { |i| sum += a[i] * b[i] }
        sum
      end
    end
  end
end
