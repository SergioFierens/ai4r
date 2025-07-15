# frozen_string_literal: true

# Author::    Sergio Fierens (Implementation only)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'
require_relative '../classifiers/classifier'

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

      parameters_info default_class: 'Return this value when the provided ' \
                                     'dataset is empty.',
                      tie_break: 'Strategy used when more than one class has the ' \
                                 'same maximal frequency. Valid values are :first (default) ' \
                                 'and :random.',
                      random_seed: 'Seed for tie resolution when using :random strategy.'

      # @return [Object]
      def initialize
        @default_class = nil
        @tie_break = :first
        @random_seed = nil
        @rng = nil
      end

      # Build a new ZeroR classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as
      # the item class.
      # @param data_set [Object]
      # @return [Object]
      def build(data_set)
        @data_set = data_set

        if @data_set.data_items.empty?
          @class_value = @default_class
          return self
        end

        frequencies = Hash.new(0)
        max_freq = 0
        tied_classes = []

        @data_set.data_items.each do |example|
          class_value = example.last
          frequencies[class_value] += 1
          class_frequency = frequencies[class_value]
          if class_frequency > max_freq
            max_freq = class_frequency
            tied_classes = [class_value]
          elsif class_frequency == max_freq && !tied_classes.include?(class_value)
            tied_classes << class_value
          end
        end

        rng = @rng || (@random_seed.nil? ? Random.new : Random.new(@random_seed))

        @class_value = if tied_classes.length == 1
                         tied_classes.first
                       else
                         case @tie_break
                         when :random
                           tied_classes.sample(random: rng)
                         else
                           tied_classes.first
                         end
                       end

        self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      # @param data [Object]
      # @return [Object]
      def eval(_data)
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
      # @return [Object]
      def get_rules
        "#{@data_set.category_label} = '#{@class_value}'"
      end
    end
  end
end
