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
      def self.mean(data_set, attribute)
        index = data_set.get_index(attribute)
        sum = 0.0
        data_set.data_items.each { |item| sum += item[index] }
        return sum / data_set.data_items.length
      end

      # Get the variance.
      # You can provide the mean if you have it already, to speed up things.
      def self.variance(data_set, attribute, mean = nil)
        index = data_set.get_index(attribute)
        mean = mean(data_set, attribute)
        sum = 0.0
        data_set.data_items.each { |item| sum += (item[index]-mean)**2 }
        return sum / (data_set.data_items.length-1)
      end

      # Get the standard deviation.
      # You can provide the variance if you have it already, to speed up things.
      def self.standard_deviation(data_set, attribute, variance = nil)
        variance ||= variance(data_set, attribute)
        Math.sqrt(variance)
      end

      # Get the sample mode.
      def self.mode(data_set, attribute)
        index = data_set.get_index(attribute)
        count = Hash.new {0}
        max_count = 0
        mode = nil
        data_set.data_items.each do |data_item|
          attr_value = data_item[index]
          attr_count = (count[attr_value] += 1)
          if attr_count > max_count
            mode = attr_value
            max_count = attr_count
          end
        end
        return mode
      end

      # Get the maximum value of an attribute in the data set
      def self.max(data_set, attribute)
        index = data_set.get_index(attribute)
        item = data_set.data_items.max {|x,y| x[index] <=> y[index]}
        return (item) ? item[index] : (-1.0/0)
      end

      # Get the minimum value of an attribute in the data set
      def self.min(data_set, attribute)
        index = data_set.get_index(attribute)
        item = data_set.data_items.min {|x,y| x[index] <=> y[index]}
        return (item) ? item[index] : (1.0/0)
      end

    end
  end
end
