# Author::    Sergio Fierens (Implementation only)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/data_set.rb'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  module Classifiers
    
    # = Introduction
    # 
    # The idea behind the ZeroR classifier is to identify the 
    # the most common class value in the training set. 
    # It always returns that value when evaluating an instance. 
    # It is frequently used as a baseline for evaluating other machine learning 
    # algorithms.
    class ZeroR < Classifier

      attr_reader :data_set, :class_value
    
      # Build a new ZeroR classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as 
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        frequencies = {}
        max_freq = 0
        @class_value = nil
        @data_set.data_items.each do |example|
          class_value = example.last
          frequencies[class_value] = frequencies[class_value].nil? ? 1 : frequencies[class_value] + 1
          class_frequency = frequencies[class_value]
          if max_freq < class_frequency
            max_freq = class_frequency
            @class_value = class_value
          end
        end
        return self
      end
      
      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      def eval(data)
        @class_value
      end
      
      # This method returns the generated rules in ruby code.
      # e.g.
      #   
      #   classifier.get_rules
      #     # =>  marketing_target='Y'
      #
      # It is a nice way to inspect induction results, and also to execute them:  
      #     marketing_target = nil
      #     eval classifier.get_rules   
      #     puts marketing_target
      #       # =>  'Y'
      def get_rules
        return "#{@data_set.category_label} = '#{@class_value}'"
      end

    end
    
  end
end
