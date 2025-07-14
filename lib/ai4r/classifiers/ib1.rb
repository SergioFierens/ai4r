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
      attr_reader :data_set, :min_values, :max_values

      parameters_info k: 'Number of nearest neighbors to consider. Default is 1.',
                      distance_function: 'Optional custom distance metric taking two instances.',
                      tie_break: 'Strategy used when neighbors vote tie. Valid values are :first (default) and :random.',
                      random_seed: 'Seed for random tie-breaking when :tie_break is :random.'

      # @return [Object]
      def initialize
        @k = 1
        @distance_function = nil
        @tie_break = :first
        @random_seed = nil
        @rng = nil
      end

      # Build a new IB1 classifier. You must provide a DataSet instance
      # as parameter. The last attribute of each item is considered as
      # the item class.
      # @param data_set [Object]
      # @return [Object]
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @min_values = Array.new(data_set.data_labels.length)
        @max_values = Array.new(data_set.data_labels.length)
        data_set.data_items.each { |data_item| update_min_max(data_item[0...-1]) }
        self
      end

      # Append a new instance to the internal dataset. The last element is
      # considered the class label. Minimum and maximum values for numeric
      # attributes are updated so that future distance calculations remain
      # normalized.
      # @param data_item [Object]
      # @return [Object]
      def add_instance(data_item)
        @data_set << data_item
        update_min_max(data_item[0...-1])
        self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      #
      # Evaluation does not update internal statistics, keeping the
      # classifier state unchanged. Use +update_with_instance+ to
      # incorporate new samples.
      def eval(data)
        neighbors = @data_set.data_items.map do |train_item|
          [distance(data, train_item), train_item.last]
        end
        neighbors.sort_by! { |d, _| d }
        k_limit = [@k, @data_set.data_items.length].min
        k_neighbors = neighbors.first(k_limit)

        # Include any other neighbors tied with the last selected distance
        last_distance = k_neighbors.last[0]
        neighbors[k_limit..].to_a.each do |dist, klass|
          break if dist > last_distance

          k_neighbors << [dist, klass]
        end

        counts = Hash.new(0)
        k_neighbors.each { |_, klass| counts[klass] += 1 }
        max_votes = counts.values.max
        tied = counts.select { |_, v| v == max_votes }.keys

        return tied.first if tied.length == 1

        rng = @rng || (@random_seed.nil? ? Random.new : Random.new(@random_seed))

        case @tie_break
        when :random
          tied.sample(random: rng)
        else
          k_neighbors.each { |_, klass| return klass if tied.include?(klass) }
        end
      end

      # Returns an array with the +k+ nearest instances from the training set
      # for the given +data+ item. The returned elements are the training data
      # rows themselves, ordered from the closest to the furthest.
      # @param data [Object]
      # @param k [Object]
      # @return [Object]
      def neighbors_for(data, k)
        update_min_max(data)
        @data_set.data_items
                 .map { |train_item| [train_item, distance(data, train_item)] }
                 .sort_by(&:last)
                 .first(k)
                 .map(&:first)
      end

      # Update min/max values with the provided instance attributes. If
      # +learn+ is true, also append the instance to the training set so the
      # classifier learns incrementally.
      def update_with_instance(data_item, learn: false)
        update_min_max(data_item[0...-1])
        @data_set << data_item if learn
        self
      end

      protected

      # We keep in the state the min and max value of each attribute,
      # to provide normalized distances between to values of a numeric attribute
      # @param atts [Object]
      # @return [Object]
      def update_min_max(atts)
        atts.each_with_index do |att, i|
          if att.is_a?(Numeric)
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
      # @param a [Object]
      # @param b [Object]
      # @return [Object]
      def distance(a, b)
        return @distance_function.call(a, b) if @distance_function

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
              diff = norm(att_a, i) - norm(att_b, i)
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
        d
      end

      # Returns normalized value att
      #
      # index is the index of the attribute in the instance.
      # @param att [Object]
      # @param index [Object]
      # @return [Object]
      def norm(att, index)
        return 0 if @min_values[index].nil?

        1.0 * (att - @min_values[index]) / (@max_values[index] - @min_values[index])
      end
    end
  end
end
