# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/csv_data_set'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  module Classifiers


    # = Introduction
    #
    # This is an implementation of a Naive Bayesian Classifier without any
    # specialisation (ie. for text classification)
    # Probabilities P(a_i | v_j) are estimated using m-estimates, hence the
    # m parameter as second parameter when isntantiating the class.
    # The estimation looks like this:
    #(n_c + mp) / (n + m)
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
    # * :data => Mandatory. Has to be an instance of CsvDataSet
    # * :m => Optional. Default value is set to 0. Is set to a value greater than 0 when
    # the size of the dataset is relatively small
    # * :automatic_build => Optional. Default value is true. If it is true, the probability calculations
    # are done automatically
    #
    #
    # = How to use it
    #
    # data = CsvDataSet.new
    # data.load_csv_with_labels "bayes_data.csv"
    #
    # b = Bayes.new data, 3
    # p b.eval(["Red", "SUV", "Domestic"])
    #
    # Optionally - if you don't want to use csv you can still use CsvDataSet (it only extends DataSet
    # by ovrriding load_csv_with_labels) and set the attribute 'klasses' manually by overriding
    # @data_items of DataSet by an array of DataEntryr instances

    class Bayes < Classifier

      def initialize(data, m=0, automatic_build=true)
        raise "Error instance must be passed" unless data.is_a?(DataSet)
        raise "Data should not be empty" if data.data_items.length == 0

        @data = data
        @domains = @data.build_domains
        @m = m

        @class_counts = []
        @class_prob = [] # stores the probability of the classes
        @pcc = [] # stores the number of instances divided into attribute/value/class
        @pcp = [] # stores the conditional probabilities of the values of an attribute
        @klass_index = {} # hashmap for quick lookup of all the used klasses and their indice
        @values = {} # hashmap for quick lookup of all the values

        build data if automatic_build
      end

      # overrides the method in Classifier
      # calculates the probabilities for the data entry Data.
      # data has to be an array of the same dimension as the training data minus the
      # class column. In addition to that, it also has to be in the same order attribute-wise.
      # Returns an array of size 2: [Class, probability]. Probability is smaller than 1 and of type Float
      def eval(data)
        prob = @class_prob.map {|cp| cp}

        prob = calculate_class_probabilities_for_entry(data, prob)
        prob = normalize_class_probability prob
        [index_to_klass(prob.index(prob.max)), prob.max]
      end

      # counts values of the attribute instances and calculates the probability of the classes
      # and the conditional probabilities
      def build(data)
        initialize_klass_index
        initialize_pc
        calculate_probabilities
      end

      private

      # calculates the klass probability of a data entry
      # as usual, the probability of the value is multiplied with every conditional
      # probability of every attribute in condition to a specific class
      # this is repeated for every class
      def calculate_class_probabilities_for_entry(data, prob)
        prob.each_with_index do |prob_entry, prob_index|
          data.each_with_index do |att, index|
            next if value_index(att, index).nil?
            prob[prob_index] *= @pcp[index][value_index(att, index)][prob_index]
          end
        end
      end

      # normalises the array of probabilities so the sum of the array equals 1
      def normalize_class_probability(prob)
        sum(prob) > 0 ?
                prob.map {|prob_entry| prob_entry / sum(prob) } :
                prob
      end

      # sums an array up; returns a number of type Float
      def sum(array)
        array.inject(0.0){|b, i| b+i}
      end

      # returns the name of the class when the index is found
      def index_to_klass(index)
        @klass_index.has_value?(index) ? @klass_index.index(index) : nil
      end

      # initializes @values and @klass_index; maps a certain value to a uniq index
      def initialize_klass_index
        @data.klasses.each_with_index do |dl, index|
          @klass_index[dl] = index
        end

        @data.data_labels.each_with_index do |dl, index|
          @values[index] = {}
          @domains[index].each_with_index do |d, d_index|
            @values[index][d] = d_index
          end
        end
      end

      # returns the index of a class
      def klass_index(klass)
        @klass_index[klass]
      end

      # returns the index of a value, depending on the attribute index
      def value_index(value, dl_index)
        @values[dl_index][value]
      end

      # builds an array of the form:
      # array[attributes][values][classes]
      def build_array(dl, index)
        domains = Array.new(@domains[index].length)
        domains.map do |p1|
          pl = Array.new @data.klasses.length, 0
        end
      end

      # initializes the two array for storing the count and conditional probabilities of
      # the attributes
      def initialize_pc
        @data.data_labels.each_with_index do |dl, index|
          @pcc << build_array(dl, index)
          @pcp << build_array(dl, index)
        end
      end

      # calculates the occurrences of a class and the instances of a certain value of a
      # certain attribute and the assigned class.
      # In addition to that, it also calculates the conditional probabilities and values
      def calculate_probabilities
        @data.klasses.each {|dl| @class_counts[klass_index(dl)] = 0}

        calculate_class_probabilities
        count_instances
        calculate_conditional_probabilities
      end

      def calculate_class_probabilities
        @data.data_items.each do |entry|
          @class_counts[klass_index(entry.klass)] += 1
        end

        @class_counts.each_with_index do |k, index|
          @class_prob[index] = k.to_f / @data.data_items.length
        end
      end

      # counts the instances of a certain value of a certain attribute and the assigned class
      def count_instances
        @data.data_items.each do |item|
          @data.data_labels.each_with_index do |dl, dl_index|
            @pcc[dl_index][value_index(item[dl_index], dl_index)][klass_index(item.klass)] += 1
          end
        end
      end

      # calculates the conditional probability and stores it in the @pcp-array
      def calculate_conditional_probabilities
        @pcc.each_with_index do |attributes, a_index|
          attributes.each_with_index do |values, v_index|
            values.each_with_index do |klass, k_index|
              @pcp[a_index][v_index][k_index] = (klass.to_f + @m * @class_prob[k_index]) / (@class_counts[k_index] + @m).to_f
            end
          end
        end
      end

    end
  end
end
