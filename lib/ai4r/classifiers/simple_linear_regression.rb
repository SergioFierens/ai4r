# frozen_string_literal: true

# Author::    Malav Bhavsar
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
    # = Introduction
    #
    # This is an implementation of a Simple Linear Regression Classifier.
    #
    # For further details regarding Bayes and Naive Bayes Classifier have a look at this link:
    # http://en.wikipedia.org/wiki/Naive_Bayesian_classification
    # http://en.wikipedia.org/wiki/Bayes%27_theorem
    #
    #
    # = How to use it
    #
    #   data = DataSet.new.parse_csv_with_labels "autoPrice.csv"
    #   c = SimpleLinearRegression.new.
    #     build data
    #   c.eval([1,158,105.8,192.7,71.4,55.7,2844,136,3.19,3.4,8.5,110,5500,19,25])
    #

    # SimpleLinearRegression performs linear regression on one attribute.
    class SimpleLinearRegression < Classifier
      attr_reader :attribute, :attribute_index, :slope, :intercept

      parameters_info selected_attribute: 'Index of attribute to use for regression.'

      # @return [Object]
      def initialize
        super()
        @attribute = nil
        @attribute_index = 0
        @slope = 0
        @intercept = 0
        @selected_attribute = nil
      end

      # You can evaluate new data, predicting its category.
      # e.g.
      #   c.eval([1,158,105.8,192.7,71.4,55.7,2844,136,3.19,3.4,8.5,110,5500,19,25])
      #     => 11876.96774193548
      # @param data [Object]
      # @return [Object]
      def eval(data)
        @intercept + (@slope * data[@attribute_index])
      end

      # Gets the best attribute and does Linear Regression using it to find out the
      # slope and intercept.
      # Parameter data has to be an instance of DataSet
      # @param data [Object]
      # @return [Object]
      def build(data)
        validate_data(data)

        y_mean = data.get_mean_or_mode[data.num_attributes - 1]
        result = if @selected_attribute
                    evaluate_attribute(data, @selected_attribute, y_mean)
                  else
                    evaluate_all_attributes(data, y_mean)
                  end
        assign_result(data, result, y_mean)
      end

      def validate_data(data)
        raise 'Error instance must be passed' unless data.is_a?(Ai4r::Data::DataSet)
        raise 'Data should not be empty' if data.data_items.empty?
      end

      def evaluate_attribute(data, attr_index, y_mean)
        x_mean = data.get_mean_or_mode[attr_index]
        slope, x_diff_sq, y_diff_sq = attribute_sums(data, attr_index, x_mean, y_mean)
        if x_diff_sq.zero?
          { chosen: attr_index, slope: 0, intercept: y_mean, msq: Float::MAX }
        else
          chosen_slope = slope / x_diff_sq
          intercept = y_mean - (chosen_slope * x_mean)
          { chosen: attr_index, slope: chosen_slope, intercept: intercept, msq: y_diff_sq - (chosen_slope * slope) }
        end
      end

      def evaluate_all_attributes(data, y_mean)
        result = { chosen: -1, msq: Float::MAX }
        data.data_labels.each do |attr_name|
          attr_index = data.get_index attr_name
          next if attr_index == data.num_attributes - 1

          candidate = evaluate_attribute(data, attr_index, y_mean)
          next unless candidate[:msq] < result[:msq]

          result = candidate
        end
        result
      end

      def assign_result(data, result, y_mean)
        raise 'no useful attribute found' if result[:chosen] == -1

        @attribute = data.data_labels[result[:chosen]]
        @attribute_index = result[:chosen]
        @slope = result[:slope]
        @intercept = result[:intercept]
        self
      end

      # Simple Linear Regression classifiers cannot generate human readable
      # rules. This method returns a descriptive string indicating that rule
      # extraction is not supported.
      def get_rules
        'SimpleLinearRegression does not support rule extraction.'
      end

      private

      # Calculate regression sums for the given attribute.
      def attribute_sums(data, attr_index, x_mean, y_mean)
        slope = 0
        sum_x_diff_squared = 0
        sum_y_diff_squared = 0
        data.data_items.each do |instance|
          x_diff = instance[attr_index] - x_mean
          y_diff = instance[data.num_attributes - 1] - y_mean
          slope += x_diff * y_diff
          sum_x_diff_squared += x_diff * x_diff
          sum_y_diff_squared += y_diff * y_diff
        end
        [slope, sum_x_diff_squared, sum_y_diff_squared]
      end
    end
  end
end
