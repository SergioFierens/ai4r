# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module Data
    # This module provides some basic statistics functions to operate on
    # data set attributes.
    module Statistics
      # Get the sample mean
      # @param data_set [Object]
      # @param attribute [Object]
      # @return [Object]
      def self.mean(data_set, attribute)
        index = data_set.get_index(attribute)
        sum = 0.0
        data_set.data_items.each { |item| sum += item[index] }
        sum / data_set.data_items.length
      end

      # Get the variance.
      # You can provide the mean if you have it already, to speed up things.
      # @param data_set [Object]
      # @param attribute [Object]
      # @param mean [Object]
      # @return [Object]
      def self.variance(data_set, attribute, mean = nil)
        index = data_set.get_index(attribute)
        mean ||= mean(data_set, attribute)
        sum = 0.0
        data_set.data_items.each { |item| sum += (item[index] - mean)**2 }
        sum / (data_set.data_items.length - 1)
      end

      # Get the standard deviation.
      # You can provide the variance if you have it already, to speed up things.
      # @param data_set [Object]
      # @param attribute [Object]
      # @param variance [Object]
      # @return [Object]
      def self.standard_deviation(data_set, attribute, variance = nil)
        variance ||= variance(data_set, attribute)
        Math.sqrt(variance)
      end

      # Get the sample mode.
      # @param data_set [Object]
      # @param attribute [Object]
      # @return [Object]
      def self.mode(data_set, attribute)
        index = data_set.get_index(attribute)
        data_set
          .data_items
          .map { |item| item[index] }
          .tally
          .max_by { _2 }
          &.first
      end

      # Get the maximum value of an attribute in the data set
      # @param data_set [Object]
      # @param attribute [Object]
      # @return [Object]
      def self.max(data_set, attribute)
        index = data_set.get_index(attribute)
        item = data_set.data_items.max_by { |item| item[index] }
        item ? item[index] : -Float::INFINITY
      end

      # Get the minimum value of an attribute in the data set
      # @param data_set [Object]
      # @param attribute [Object]
      # @return [Object]
      def self.min(data_set, attribute)
        index = data_set.get_index(attribute)
        item = data_set.data_items.min_by { |item| item[index] }
        item ? item[index] : Float::INFINITY
      end
    end
  end
end
