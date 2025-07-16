# frozen_string_literal: true

# Author::    OpenAI ChatGPT
# License::   MPL 1.1
# Project::   ai4r
#
# Very small gradient boosting implementation for regression using
# simple linear regression as base learner.

require_relative 'simple_linear_regression'
require_relative '../data/data_set'
require_relative '../classifiers/classifier'

module Ai4r
  module Classifiers
    # Gradient boosting regressor using simple linear regression base learners.
    class GradientBoosting < Classifier
      parameters_info n_estimators: 'Number of boosting iterations. Default 10.',
                      learning_rate: 'Shrinkage parameter for each learner. Default 0.1.'

      attr_reader :initial_value, :learners

      def initialize
        super()
        @n_estimators = 10
        @learning_rate = 0.1
      end

      def build(data_set)
        data_set.check_not_empty
        @learners = []
        targets = data_set.data_items.map(&:last)
        @initial_value = targets.sum.to_f / targets.length
        predictions = Array.new(targets.length, @initial_value)
        @n_estimators.times do
          residuals = targets.zip(predictions).map { |y, f| y - f }
          items = data_set.data_items.each_with_index.map do |item, idx|
            item[0...-1] + [residuals[idx]]
          end
          ds = Ai4r::Data::DataSet.new(data_items: items, data_labels: data_set.data_labels)
          learner = SimpleLinearRegression.new.build(ds)
          @learners << learner
          pred = items.map { |it| learner.eval(it[0...-1]) }
          predictions = predictions.zip(pred).map { |f, p| f + (@learning_rate * p) }
        end
        self
      end
      # rubocop:enable Metrics/AbcSize

      def eval(data)
        value = @initial_value
        @learners.each do |learner|
          value += @learning_rate * learner.eval(data)
        end
        value
      end

      def get_rules
        'GradientBoosting does not support rule extraction.'
      end
      # rubocop:enable Naming/AccessorMethodName
    end
  end
end
