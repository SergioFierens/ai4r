# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'
require_relative 'classifier'

module Ai4r
  module Classifiers
    # Implementation of binary Logistic Regression using gradient descent.
    #
    # Training data must have numeric attributes with the last attribute being
    # the class label (0 or 1). Parameters can be adjusted with
    # {Parameterizable#set_parameters}.
    #
    # Example:
    #   data = Ai4r::Data::DataSet.new(:data_items => [[0.2, 1], [0.4, 0]])
    #   classifier = LogisticRegression.new.build(data)
    #   classifier.eval([0.3])
    class LogisticRegression < Classifier
      attr_reader :weights

      parameters_info learning_rate: 'Learning rate for gradient descent.',
                      iterations: 'Number of iterations to train.'

      def initialize
        super()
        @learning_rate = 0.1
        @iterations = 1000
        @weights = nil
      end

      # Train the logistic regression classifier using the provided dataset.
      def build(data_set)
        raise 'Error instance must be passed' unless data_set.is_a?(Ai4r::Data::DataSet)

        data_set.check_not_empty

        x = data_set.data_items.map { |item| item[0...-1].map(&:to_f) }
        y = data_set.data_items.map { |item| item.last.to_f }
        m = x.length
        n = x.first.length
        @weights = Array.new(n + 1, 0.0) # last value is bias

        @iterations.times do
          predictions = x.map do |row|
            z = row.each_with_index.inject(@weights.last) { |s, (v, j)| s + (v * @weights[j]) }
            1.0 / (1.0 + Math.exp(-z))
          end
          errors = predictions.zip(y).map { |p, label| p - label }

          n.times do |j|
            grad = (0...m).inject(0.0) { |sum, i| sum + (errors[i] * x[i][j]) } / m
            @weights[j] -= @learning_rate * grad
          end
          bias_grad = errors.sum / m
          @weights[n] -= @learning_rate * bias_grad
        end
        self
      end

      # Predict the class (0 or 1) for the given data array.
      def eval(data)
        raise 'Model not trained' unless @weights

        expected_size = @weights.length - 1
        if data.length != expected_size
          raise ArgumentError,
                "Wrong number of inputs. Expected: #{expected_size}, " \
                "received: #{data.length}."
        end

        z = data.each_with_index.inject(@weights.last) do |s, (v, j)|
          s + (v.to_f * @weights[j])
        end
        prob = 1.0 / (1.0 + Math.exp(-z))
        prob >= 0.5 ? 1 : 0
      end

      # Logistic Regression classifiers cannot generate human readable rules.
      #
      # This method returns a string explaining that rule extraction is not
      # supported for this algorithm.
      def get_rules
        'LogisticRegression does not support rule extraction.'
      end
    end
  end
end
