# frozen_string_literal: true

# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'
require_relative 'classifier'

module Ai4r
  module Classifiers
    # = Introduction
    #
    # This is an implementation of a Naive Bayesian Classifier without any
    # specialisation (ie. for text classification)
    # Probabilities P(a_i | v_j) are estimated using m-estimates, hence the
    # m parameter as second parameter when isntantiating the class.
    # The estimation looks like this:
    # (n_c + mp) / (n + m)
    #
    # the variables are:
    # n = the number of training examples for which v = v_j
    # n_c = number of examples for which v = v_j and a = a_i
    # p = a priori estimate for P(a_i | v_j)
    # m = the equivalent sample size
    #
    # stores the conditional probabilities in an array named @pcp and in this form:
    # @pcp[attributes][values][classes]
    #
    # This kind of estimator is useful when the training data set is relatively small.
    # If the data set is big enough, set it to 0, which is also the default value
    #
    #
    # For further details regarding Bayes and Naive Bayes Classifier have a look at those websites:
    # http://en.wikipedia.org/wiki/Naive_Bayesian_classification
    # http://en.wikipedia.org/wiki/Bayes%27_theorem
    #
    #
    # = Parameters
    #
    # * :m => Optional. Default value is set to 0. It may be set to a value greater than 0 when
    # the size of the dataset is relatively small
    #
    # = How to use it
    #
    #   data = DataSet.new.load_csv_with_labels "bayes_data.csv"
    #   b = NaiveBayes.new.
    #     set_parameters({:m=>3}).
    #     build data
    #   b.eval(["Red", "SUV", "Domestic"])
    #

    # Probabilistic classifier based on Bayes' theorem.
    class NaiveBayes < Classifier
      attr_reader :class_prob, :pcc, :pcp

      parameters_info m: 'Default value is set to 0. It may be set to a value greater than ' \
                         '0 when the size of the dataset is relatively small',
                      unknown_value_strategy: 'Behaviour when evaluating unseen attribute values: ' \
                                              ':ignore (default), :uniform or :error.'

      # @return [Object]
      def initialize
        @m = 0
        @unknown_value_strategy = :ignore
        @class_counts = []
        @class_prob = [] # stores the probability of the classes
        @pcc = [] # stores the number of instances divided into attribute/value/class
        @pcp = [] # stores the conditional probabilities of the values of an attribute
        @klass_index = {} # hashmap for quick lookup of all the used klasses and their indice
        @values = {} # hashmap for quick lookup of all the values
      end

      # You can evaluate new data, predicting its category.
      # e.g.
      #   b.eval(["Red", "SUV", "Domestic"])
      #     => 'No'
      # @param data [Object]
      # @return [Object]
      def eval(data)
        prob = @class_prob.dup
        prob = calculate_class_probabilities_for_entry(data, prob)
        index_to_klass(prob.index(prob.max))
      end

      # Calculates the probabilities for the data entry Data.
      # data has to be an array of the same dimension as the training data minus the
      # class column.
      # Returns a map containint all classes as keys:
      # {Class_1 => probability, Class_2 => probability2 ... }
      # Probability is <= 1 and of type Float.
      # e.g.
      #   b.get_probability_map(["Red", "SUV", "Domestic"])
      #     => {"Yes"=>0.4166666666666667, "No"=>0.5833333333333334}
      # @param data [Object]
      # @return [Object]
      def get_probability_map(data)
        prob = @class_prob.dup
        prob = calculate_class_probabilities_for_entry(data, prob)
        prob = normalize_class_probability prob
        probability_map = {}
        prob.each_with_index { |p, i| probability_map[index_to_klass(i)] = p }

        probability_map
      end

      # counts values of the attribute instances and calculates the probability of the classes
      # and the conditional probabilities
      # Parameter data has to be an instance of CsvDataSet
      # @param data [Object]
      # @return [Object]
      def build(data)
        raise 'Error instance must be passed' unless data.is_a?(Ai4r::Data::DataSet)
        raise 'Data should not be empty' if data.data_items.empty?

        initialize_domain_data(data)
        initialize_klass_index
        initialize_pc
        calculate_probabilities

        self
      end

      # Naive Bayes classifiers cannot generate human readable rules.
      # This method returns a descriptive string explaining that rule
      # extraction is not supported for this algorithm.
      def get_rules
        'NaiveBayes does not support rule extraction.'
      end

      private

      # @param data [Object]
      # @return [Object]
      def initialize_domain_data(data)
        @domains = data.build_domains
        @data_items = data.data_items.map { |item| DataEntry.new(item[0...-1], item.last) }
        @data_labels = data.data_labels[0...-1]
        @klasses = @domains.last.to_a.sort
      end

      # calculates the klass probability of a data entry
      # as usual, the probability of the value is multiplied with every conditional
      # probability of every attribute in condition to a specific class
      # this is repeated for every class
      # @param data [Object]
      # @param prob [Object]
      # @return [Object]
      def calculate_class_probabilities_for_entry(data, prob)
        0.upto(prob.length - 1) do |prob_index|
          data.each_with_index do |att, index|
            val_index = value_index(att, index)
            if val_index.nil?
              case @unknown_value_strategy
              when :ignore
                next
              when :uniform
                value_count = @pcc[index].count { |arr| arr[prob_index].positive? }
                value_count = 1 if value_count.zero?
                prob[prob_index] *= 1.0 / value_count
              when :error
                raise "Unknown value '#{att}' for attribute #{@data_labels[index]}"
              else
                next
              end
            else
              prob[prob_index] *= @pcp[index][val_index][prob_index]
            end
          end
        end

        prob
      end

      # normalises the array of probabilities so the sum of the array equals 1
      # @param prob [Object]
      # @return [Object]
      def normalize_class_probability(prob)
        prob_sum = sum(prob)
        if prob_sum.positive?
          prob.map { |prob_entry| prob_entry / prob_sum }
        else
          prob
        end
      end

      # sums an array up; returns a number of type Float
      # @param array [Object]
      # @return [Object]
      def sum(array)
        array.sum(0.0)
      end

      # returns the name of the class when the index is found
      # @param index [Object]
      # @return [Object]
      def index_to_klass(index)
        @klass_index.value?(index) ? @klass_index.key(index) : nil
      end

      # initializes @values and @klass_index; maps a certain value to a uniq index
      # @return [Object]
      def initialize_klass_index
        @klasses.each_with_index do |dl, index|
          @klass_index[dl] = index
        end

        0.upto(@data_labels.length - 1) do |index|
          @values[index] = {}
          @domains[index].to_a.sort.each_with_index do |d, d_index|
            @values[index][d] = d_index
          end
        end
      end

      # returns the index of a class
      # @param klass [Object]
      # @return [Object]
      def klass_index(klass)
        @klass_index[klass]
      end

      # returns the index of a value, depending on the attribute index
      # @param value [Object]
      # @param dl_index [Object]
      # @return [Object]
      def value_index(value, dl_index)
        @values[dl_index][value]
      end

      # builds an array of the form:
      # array[attributes][values][classes]
      # @param index [Object]
      # @return [Object]
      def build_array(index)
        domains = Array.new(@domains[index].length)
        domains.map do
          Array.new @klasses.length, 0
        end
      end

      # initializes the two array for storing the count and conditional probabilities of
      # the attributes
      # @return [Object]
      def initialize_pc
        0.upto(@data_labels.length - 1) do |index|
          @pcc << build_array(index)
          @pcp << build_array(index)
        end
      end

      # calculates the occurrences of a class and the instances of a certain value of a
      # certain attribute and the assigned class.
      # In addition to that, it also calculates the conditional probabilities and values
      # @return [Object]
      def calculate_probabilities
        @klasses.each { |dl| @class_counts[klass_index(dl)] = 0 }

        calculate_class_probabilities
        count_instances
        calculate_conditional_probabilities
      end

      # @return [Object]
      def calculate_class_probabilities
        @data_items.each do |entry|
          @class_counts[klass_index(entry.klass)] += 1
        end

        @class_counts.each_with_index do |k, index|
          @class_prob[index] = k.to_f / @data_items.length
        end
      end

      # counts the instances of a certain value of a certain attribute and the assigned class
      # @return [Object]
      def count_instances
        @data_items.each do |item|
          0.upto(@data_labels.length - 1) do |dl_index|
            @pcc[dl_index][value_index(item[dl_index], dl_index)][klass_index(item.klass)] += 1
          end
        end
      end

      # calculates the conditional probability and stores it in the @pcp-array
      # @return [Object]
      def calculate_conditional_probabilities
        @pcc.each_with_index do |attributes, a_index|
          attributes.each_with_index do |values, v_index|
            values.each_with_index do |klass, k_index|
              @pcp[a_index][v_index][k_index] =
                (klass.to_f + (@m * @class_prob[k_index])) / (@class_counts[k_index] + @m)
            end
          end
        end
      end

      # DataEntry stores the instance of the data entry
      # the data is accessible via entries
      # stores the class-column in the attribute klass and
      # removes the column for the class-entry
      class DataEntry
        attr_accessor :klass, :entries

        # @param attributes [Object]
        # @param klass [Object]
        # @return [Object]
        def initialize(attributes, klass)
          @klass = klass
          @entries = attributes
        end

        # wrapper method for the access to @entries
        # @param index [Object]
        # @return [Object]
        def [](index)
          @entries[index]
        end
      end
    end
  end
end
