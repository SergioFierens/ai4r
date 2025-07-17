# frozen_string_literal: true

# Author::    Sergio Fierens (Implementation only)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'set'
require "#{File.dirname(__FILE__)}/../data/data_set"
require "#{File.dirname(__FILE__)}/../classifiers/classifier"

module Ai4r
  module Classifiers
    # = Introduction
    #
    # The idea of the OneR algorithm is identify the single
    # attribute to use to classify data that makes
    # fewest prediction errors.
    # It generates rules based on a single attribute.
    class OneR < Classifier
      attr_reader :data_set, :rule
      
      # Default number of bins for numeric attributes
      DEFAULT_BINS = 10
      
      parameters_info bins_count: 'Number of bins for discretizing numeric attributes (default: 10)'
      
      # Returns the index of the selected attribute
      def selected_attribute
        @rule[:attr_index] if @rule
      end
      
      def initialize
        @bins_count = DEFAULT_BINS
        @bin_info = {}
      end

      # Build a new OneR classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        if data_set.num_attributes == 1
          @zero_r = ZeroR.new.build(data_set)
          return self
        else
          @zero_r = nil
        end
        domains = @data_set.build_domains
        @rule = nil
        # Iterate through all attributes except the last one (which is the class)
        (0...@data_set.num_attributes-1).each do |attr_index|
          rule = build_rule(@data_set.data_items, attr_index, domains)
          @rule = rule if !@rule || rule[:correct] > @rule[:correct]
        end
        return self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      def eval(data)
        return @zero_r.eval(data) if @zero_r

        attr_value = data[@rule[:attr_index]]
        
        # Handle nil/missing values - return most common class for this attribute
        if attr_value.nil?
          # Find the most common class across all values for this attribute
          class_counts = Hash.new(0)
          @rule[:rule].each_value { |class_val| class_counts[class_val] += 1 }
          return class_counts.max_by { |_, count| count }&.first
        end
        
        # If numeric value and we have bin info, discretize it
        if attr_value.is_a?(Numeric) && @bin_info[@rule[:attr_index]]
          bin_info = @bin_info[@rule[:attr_index]]
          
          # Handle out of range values
          if attr_value < bin_info[:min]
            attr_value = bin_info[:min]
          elsif attr_value > bin_info[:max]
            attr_value = bin_info[:max]
          end
          
          # Calculate bin index
          bin_index = ((attr_value - bin_info[:min]) / bin_info[:width]).floor
          # Ensure last bin includes max value
          bin_index = bin_info[:count] - 1 if bin_index >= bin_info[:count]
          
          # Create bin label
          bin_start = bin_info[:min] + (bin_index * bin_info[:width])
          bin_end = bin_start + bin_info[:width]
          attr_value = "[#{bin_start.round(2)}-#{bin_end.round(2)})"
        end
        
        # If value not in rule, return the most common class overall
        @rule[:rule][attr_value] || begin
          class_counts = Hash.new(0)
          @rule[:rule].each_value { |class_val| class_counts[class_val] += 1 }
          class_counts.max_by { |_, count| count }&.first
        end
      end

      # This method returns the generated rules in ruby code.
      # e.g.
      #
      #   classifier.get_rules
      #     # =>  if age_range == '<30' then marketing_target = 'Y'
      #           elsif age_range == '[30-50)' then marketing_target = 'N'
      #           elsif age_range == '[50-80]' then marketing_target = 'N'
      #           end
      #
      # It is a nice way to inspect induction results, and also to execute them:
      #     marketing_target = nil
      #     eval classifier.get_rules
      #     puts marketing_target
      #       # =>  'Y'
      def get_rules
        return @zero_r.get_rules if @zero_r

        sentences = []
        attr_label = @data_set.data_labels[@rule[:attr_index]]
        class_label = @data_set.category_label
        @rule[:rule].each_pair do |attr_value, class_value|
          sentences << "#{attr_label} == '#{attr_value}' then #{class_label} = '#{class_value}'"
        end
        return "if #{sentences.join("\nelsif ")}\nend"
      end

      protected
      
      # Check if an attribute contains numeric values
      def numeric_attribute?(data_examples, attr_index)
        data_examples.any? { |item| item[attr_index].is_a?(Numeric) }
      end
      
      # Discretize numeric values into bins
      def discretize_numeric_data(data_examples, attr_index)
        return data_examples unless numeric_attribute?(data_examples, attr_index)
        
        # Get numeric values
        numeric_values = data_examples.map { |item| item[attr_index] }.select { |v| v.is_a?(Numeric) }
        return data_examples if numeric_values.empty?
        
        min_val = numeric_values.min
        max_val = numeric_values.max
        
        # Handle case where all values are the same
        return data_examples if min_val == max_val
        
        # Calculate bin width
        bin_width = (max_val - min_val) / @bins_count.to_f
        
        # Store bin info for this attribute
        @bin_info[attr_index] = {
          min: min_val,
          max: max_val,
          width: bin_width,
          count: @bins_count
        }
        
        # Create discretized data
        discretized_data = data_examples.map do |item|
          new_item = item.dup
          if item[attr_index].is_a?(Numeric)
            # Calculate bin index
            bin_index = ((item[attr_index] - min_val) / bin_width).floor
            # Ensure last bin includes max value
            bin_index = @bins_count - 1 if bin_index >= @bins_count
            # Create bin label
            bin_start = min_val + (bin_index * bin_width)
            bin_end = bin_start + bin_width
            new_item[attr_index] = "[#{bin_start.round(2)}-#{bin_end.round(2)})"
          end
          new_item
        end
        
        discretized_data
      end

      def build_rule(data_examples, attr_index, domains)
        # Discretize numeric data if needed
        discretized_examples = discretize_numeric_data(data_examples, attr_index)
        
        # Build domain from discretized data
        domain = discretized_examples.map { |item| item[attr_index] }.uniq
        
        value_freq = Hash.new { |hash, key| hash[key] = Hash.new { |h, k| h[k] = 0 } }
        
        # Initialize with known domain values
        domain.each do |attr_value|
          value_freq[attr_value] # This ensures the hash is created for each domain value
        end
        
        discretized_examples.each do |data|
          attr_value = data[attr_index]
          class_value = data.last
          value_freq[attr_value][class_value] = value_freq[attr_value][class_value] + 1
        end
        rule = {}
        correct_instances = 0
        value_freq.each_pair do |attr, class_freq_hash|
          max_freq = 0
          class_freq_hash.each_pair do |class_value, freq|
            if max_freq < freq
              rule[attr] = class_value
              max_freq = freq
            end
          end
          correct_instances += max_freq
        end
        return { attr_index: attr_index, rule: rule, correct: correct_instances }
      end
    end
  end
end
