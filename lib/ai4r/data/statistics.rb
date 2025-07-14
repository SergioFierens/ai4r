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
        raise ArgumentError, "Data set cannot be nil" if data_set.nil?
        return 0.0 if data_set.data_items.empty?
        
        index = data_set.get_index(attribute)
        raise ArgumentError, "Invalid attribute index" if index.nil?
        
        sum = 0.0
        valid_items = 0
        data_set.data_items.each do |item|
          next if item.nil? || item.length <= index
          if item[index].is_a?(Numeric)
            sum += item[index]
            valid_items += 1
          end
        end
        return valid_items == 0 ? 0.0 : sum / valid_items
      end

      # Get the variance.
      # You can provide the mean if you have it already, to speed up things.
      def self.variance(data_set, attribute, mean = nil)
        raise ArgumentError, "Data set cannot be nil" if data_set.nil?
        return 0.0 if data_set.data_items.empty?
        return 0.0 if data_set.data_items.length <= 1
        
        index = data_set.get_index(attribute)
        raise ArgumentError, "Invalid attribute index" if index.nil?
        
        mean = mean.nil? ? mean(data_set, attribute) : mean
        sum = 0.0
        valid_items = 0
        data_set.data_items.each do |item|
          next if item.nil? || item.length <= index
          if item[index].is_a?(Numeric)
            sum += (item[index]-mean)**2
            valid_items += 1
          end
        end
        return valid_items <= 1 ? 0.0 : sum / (valid_items-1)
      end

      # Get the standard deviation.
      # You can provide the variance if you have it already, to speed up things.
      def self.standard_deviation(data_set, attribute, variance = nil)
        variance ||= variance(data_set, attribute)
        Math.sqrt(variance)
      end

      # Get the sample mode.
      def self.mode(data_set, attribute)
        raise ArgumentError, "Data set cannot be nil" if data_set.nil?
        return nil if data_set.data_items.empty?
        
        index = data_set.get_index(attribute)
        raise ArgumentError, "Invalid attribute index" if index.nil?
        
        count = Hash.new(0)
        max_count = 0
        mode = nil
        data_set.data_items.each do |data_item|
          next if data_item.nil? || data_item.length <= index
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
        raise ArgumentError, "Data set cannot be nil" if data_set.nil?
        return -Float::INFINITY if data_set.data_items.empty?
        
        index = data_set.get_index(attribute)
        raise ArgumentError, "Invalid attribute index" if index.nil?
        
        valid_items = data_set.data_items.select { |item| item && item.length > index && item[index].is_a?(Numeric) }
        return -Float::INFINITY if valid_items.empty?
        
        item = valid_items.max {|x,y| x[index] <=> y[index]}
        return item[index]
      end

      # Get the minimum value of an attribute in the data set
      def self.min(data_set, attribute)
        raise ArgumentError, "Data set cannot be nil" if data_set.nil?
        return Float::INFINITY if data_set.data_items.empty?
        
        index = data_set.get_index(attribute)
        raise ArgumentError, "Invalid attribute index" if index.nil?
        
        valid_items = data_set.data_items.select { |item| item && item.length > index && item[index].is_a?(Numeric) }
        return Float::INFINITY if valid_items.empty?
        
        item = valid_items.min {|x,y| x[index] <=> y[index]}
        return item[index]
      end

    end
  end
end
