# Author::    Sergio Fierens (Implementation only)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'set'
require File.dirname(__FILE__) + '/../data/data_set'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  module Classifiers

    # = Introduction
    # 
    # IB1 algorithm implementation.
    # IB1 is the simplest instance-based learning (IBL) algorithm.
    #
    # D. Aha, D. Kibler (1991). Instance-based learning algorithms.
    # Machine Learning. 6:37-66.
    #
    # IBI is identical to the nearest neighbor algorithm except that
    # it normalizes its attributes' ranges, processes instances
    # incrementally, and has a simple policy for tolerating missing values
    class IB1 < Classifier
      
      attr_reader :data_set

      # Build a new IB1 classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as 
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @min_values = Array.new(data_set.data_labels.length)
        @max_values = Array.new(data_set.data_labels.length)
        data_set.data_items.each { |data_item| update_min_max(data_item[0...-1]) }
        return self
      end
      
      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'      
      def eval(data)
        update_min_max(data)
        min_distance = 1.0/0
        klass = nil
        @data_set.data_items.each do |train_item|
          d = distance(data, train_item)
          if d < min_distance
            min_distance = d
            klass = train_item.last
          end
        end
        return klass
      end
      
      protected

      # We keep in the state the min and max value of each attribute,
      # to provide normalized distances between to values of a numeric attribute
      def update_min_max(atts)
        atts.each_with_index do |att, i|
          if att && att.is_a?(Numeric)
            @min_values[i] = att if @min_values[i].nil? || @min_values[i] > att
            @max_values[i] = att if @max_values[i].nil? || @max_values[i] < att
          end
        end
      end

      # Normalized distance between 2 instances
      #
      #
      # Returns sum of
      #  * squared difference between normalized numeric att values
      #  * 1 for nominal atts which differs or one is missing
      #  * 1 if both atts are missing
      #  * normalized numeric att value if other att value is missing and > 0.5
      #  * 1.0-normalized numeric att value if other att value is missing and < 0.5
      def distance(a, b)
        d = 0
        a.each_with_index do |att_a, i|
          att_b = b[i]
          if att_a.nil?
            if att_b.is_a? Numeric
              diff = norm(att_b, i)
              diff = 1.0 - diff if diff < 0.5
            else
              diff = 1
            end
          elsif att_a.is_a? Numeric
            if att_b.is_a? Numeric
              diff = norm(att_a, i) - norm(att_b, i);
            else
              diff = norm(att_a, i)
              diff = 1.0 - diff if diff < 0.5
            end
          elsif att_a != att_b
            diff = 1
          else
            diff = 0
          end
          d += diff * diff
        end
        return d
      end

      # Returns normalized value att
      #
      # index is the index of the attribute in the instance.
      def norm(att, index)
        return 0 if @min_values[index].nil?
        return 1.0*(att - @min_values[index]) / (@max_values[index] -@min_values[index]);
      end
      
    end
  end
end
