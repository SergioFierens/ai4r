# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/data_set'

module Ai4r
  module Data
  
    # This module provides some statistics functions to operate on
    # data set attributes.
    module Statistics
      
      # Get the sample mean
      def self.mean(data_set, attribute)
        index = data_set.get_index(attribute)
        mean = 0.0
        data_set.data_items.each { |item| mean += item[index] }
        return mean / data_set.data_items.length
      end
  
      # Get the standard deviation.
      # You can provide the mean if you have it already, to speed up things.
      def self.standard_deviation(data_set, attribute, m = nil)
        index = data_set.get_index(attribute)
        m ||= mean(data_set, attribute)
        accum = 0.0
        data_set.data_items.each { |item| accum += (item[index]-m)**2 }
        return accum / (data_set.data_items.length-1)
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
        max = -1.0/0
        data_set.data_items.each do |data_item| 
          attr_value = data_item[index]
          max = attr_value if attr_value > max
        end
        return max
      end
      
      # Get the minimum value of an attribute in the data set
      def self.min(data_set, attribute)
        index = data_set.get_index(attribute)
        min = 1.0/0
        data_set.data_items.each do |data_item| 
          attr_value = data_item[index]
          min = attr_value if attr_value < min
        end
        return min
      end
      
    end
  end
end