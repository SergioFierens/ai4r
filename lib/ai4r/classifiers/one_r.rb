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
require_relative '../data/data_set'
require_relative '../classifiers/classifier'

module Ai4r
  module Classifiers

    # = Introduction
    # 
    # The idea of the OneR algorithm is identify the single
    # attribute to use to classify data that makes 
    # fewest prediction errors.
    # It generates rules based on a single attribute.
    # Numeric attributes are automatically discretized into a fixed
    # number of bins (default is 10).
    class OneR < Classifier
      
      attr_reader :data_set, :rule

      parameters_info :selected_attribute => 'Index of the attribute to force.',
        :tie_break => 'Strategy when two attributes yield the same accuracy.',
        :bin_count => 'Number of bins used to discretize numeric attributes.'

      def initialize
        @selected_attribute = nil
        @tie_break = :first
        @bin_count = 10
      end

      # Build a new OneR classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as 
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        if (data_set.num_attributes == 1) 
          @zero_r = ZeroR.new.build(data_set)
          return self;
        else
          @zero_r = nil;
        end
        domains = @data_set.build_domains
        @rule = nil
        if @selected_attribute
          @rule = build_rule(@data_set.data_items, @selected_attribute, domains)
        else
          domains[1...-1].each_index do |attr_index|
            rule = build_rule(@data_set.data_items, attr_index, domains)
            if !@rule || rule[:correct] > @rule[:correct] ||
              (rule[:correct] == @rule[:correct] && @tie_break == :last)
              @rule = rule
            end
          end
        end
        return self
      end
      
      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'      
      def eval(data)
        return @zero_r.eval(data) if @zero_r
        attr_value = data[@rule[:attr_index]]
        if @rule[:bins]
          bin = @rule[:bins].find { |b| b.include?(attr_value) }
          attr_value = bin
        end
        return @rule[:rule][attr_value]
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
          if attr_value.is_a?(Range)
            sentences << "(#{attr_value}).include?(#{attr_label}) then #{class_label} = '#{class_value}'"
          else
            sentences << "#{attr_label} == '#{attr_value}' then #{class_label} = '#{class_value}'"
          end
        end
        return "if " + sentences.join("\nelsif ") + "\nend"
      end
      
      protected
      
      def build_rule(data_examples, attr_index, domains)
        domain = domains[attr_index]
        bins = nil
        value_freq = Hash.new
        if domain.is_a?(Array) && domain.length == 2 && domain.all? { |v| v.is_a? Numeric }
          bins = discretize_range(domain, @bin_count)
          bins.each { |b| value_freq[b] = Hash.new { |h, k| h[k] = 0 } }
          data_examples.each do |data|
            bin = bins.find { |b| b.include?(data[attr_index]) }
            value_freq[bin][data.last] = value_freq[bin][data.last] + 1
          end
        else
          domain.each do |attr_value|
            value_freq[attr_value] = Hash.new { |hash, key| hash[key] = 0 }
          end
          data_examples.each do |data|
            value_freq[data[attr_index]][data.last] = value_freq[data[attr_index]][data.last] + 1
          end
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
        return {:attr_index => attr_index, :rule => rule, :correct => correct_instances, :bins => bins}
      end

      def discretize_range(range, bins)
        min, max = range
        step = (max - min).to_f / bins
        ranges = []
        bins.times do |i|
          low = min + i * step
          high = (i == bins - 1) ? max : min + (i + 1) * step
          ranges << (i == bins - 1 ? (low..high) : (low...high))
        end
        ranges
      end

    end
  end
end
