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
    
    class SimpleLinearRegression < Classifier

      attr_reader :attribute, :attribute_index, :slope, :intercept

      parameters_info :selected_attribute => 'Index of attribute to use for regression.'

      # @return [Object]
      def initialize
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
        @intercept + @slope * data[@attribute_index]
      end

      # Gets the best attribute and does Linear Regression using it to find out the
      # slope and intercept.
      # Parameter data has to be an instance of DataSet
      # @param data [Object]
      # @return [Object]
      def build(data)
        raise "Error instance must be passed" unless data.is_a?(DataSet)
        raise "Data should not be empty" if data.data_items.length == 0
        y_mean = data.get_mean_or_mode[data.num_attributes - 1]

        min_msq = Float::MAX
        chosen = -1
        chosen_slope = 0.0 / 0.0 # Float::NAN
        chosen_intercept = 0.0 / 0.0 # Float::NAN

        if @selected_attribute
          chosen = @selected_attribute
          attr_index = chosen
          x_mean = data.get_mean_or_mode[attr_index]
          sum_x_diff_squared = 0
          sum_y_diff_squared = 0
          slope = 0
          data.data_items.each do |instance|
            x_diff = instance[attr_index] - x_mean
            y_diff = instance[data.num_attributes - 1] - y_mean
            slope += x_diff * y_diff
            sum_x_diff_squared += x_diff * x_diff
            sum_y_diff_squared += y_diff * y_diff
          end

          if sum_x_diff_squared == 0
            chosen_slope = 0
            chosen_intercept = y_mean
          else
            numerator = slope
            chosen_slope = slope / sum_x_diff_squared
            chosen_intercept = y_mean - chosen_slope * x_mean
            min_msq = sum_y_diff_squared - chosen_slope * numerator
          end
        else
          data.data_labels.each do |attr_name|
            attr_index = data.get_index attr_name
            if attr_index != data.num_attributes - 1
              x_mean = data.get_mean_or_mode[attr_index]
              sum_x_diff_squared = 0
              sum_y_diff_squared = 0
              slope = 0
              data.data_items.each do |instance|
                x_diff = instance[attr_index] - x_mean
                y_diff = instance[data.num_attributes - 1] - y_mean
                slope += x_diff * y_diff
                sum_x_diff_squared += x_diff * x_diff
                sum_y_diff_squared += y_diff * y_diff
              end

              next if sum_x_diff_squared == 0

              numerator = slope
              slope /= sum_x_diff_squared
              intercept = y_mean - slope * x_mean
              msq = sum_y_diff_squared - slope * numerator

              if msq < min_msq
                min_msq = msq
                chosen = attr_index
                chosen_slope = slope
                chosen_intercept = intercept
              end
            end
          end
        end

        if chosen == -1
          raise "no useful attribute found"
          @attribute = nil
          @attribute_index = 0
          @slope = 0
          @intercept = y_mean
        else
          @attribute = data.data_labels[chosen]
          @attribute_index = chosen
          @slope = chosen_slope
          @intercept = chosen_intercept
        end
        return self
      end
    end
  end
end
