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

    class NaiveBayes < Classifier
      parameters_info m: 'Default value is set to 0. It may be set to a value greater than ' \
                         '0 when the size of the dataset is relatively small'

      def initialize
        super
        @m = 0
        @class_counts = []
        @class_prob = [] # stores the probability of the classes
        @pcc = [] # stores the number of instances divided into attribute/value/class
        @pcp = [] # stores the conditional probabilities of the values of an attribute
        @klass_index = {} # hashmap for quick lookup of all the used klasses and their indice
        @values = {} # hashmap for quick lookup of all the values
        @numeric_attributes = [] # stores whether each attribute is numeric
        @means = {} # stores means for numeric attributes per class
        @stdevs = {} # stores standard deviations for numeric attributes per class
      end

      def set_parameters(params)
        super
        if params[:m] && params[:m] < 0
          raise ArgumentError, "m must be non-negative"
        end
      end

      # You can evaluate new data, predicting its category.
      # e.g.
      #   b.eval(["Red", "SUV", "Domestic"])
      #     => 'No'
      def eval(data)
        # Use log probabilities to avoid underflow
        log_prob = @class_prob.map { |p| Math.log(p) }
        log_prob = calculate_log_probabilities_for_entry(data, log_prob)
        index_to_klass(log_prob.index(log_prob.max))
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
      def get_probability_map(data)
        # Use log probabilities to avoid underflow
        log_prob = @class_prob.map { |p| Math.log(p) }
        log_prob = calculate_log_probabilities_for_entry(data, log_prob)
        
        # Convert back from log space and normalize
        # Use log-sum-exp trick to avoid overflow
        max_log_prob = log_prob.max
        prob = log_prob.map { |lp| Math.exp(lp - max_log_prob) }
        prob = normalize_class_probability(prob)
        
        probability_map = {}
        prob.each_with_index { |p, i| probability_map[index_to_klass(i)] = p }

        probability_map
      end

      # counts values of the attribute instances and calculates the probability of the classes
      # and the conditional probabilities
      # Parameter data has to be an instance of CsvDataSet
      def build(data)
        raise 'Error instance must be passed' unless data.is_a?(Ai4r::Data::DataSet)
        raise 'Data should not be empty' if data.data_items.empty?

        initialize_domain_data(data)
        initialize_klass_index
        identify_numeric_attributes
        initialize_pc
        calculate_probabilities

        self
      end

      private

      def initialize_domain_data(data)
        @domains = data.build_domains
        @data_items = data.data_items.map { |item| DataEntry.new(item[0...-1], item.last) }
        @data_labels = data.data_labels[0...-1]
        @klasses = @domains.last.to_a
      end

      # calculates the klass probability of a data entry
      # as usual, the probability of the value is multiplied with every conditional
      # probability of every attribute in condition to a specific class
      # this is repeated for every class
      def calculate_class_probabilities_for_entry(data, prob)
        0.upto(prob.length - 1) do |prob_index|
          data.each_with_index do |att, index|
            if @numeric_attributes[index]
              # Handle numeric attributes with Gaussian distribution
              prob[prob_index] *= gaussian_probability(att, index, prob_index)
            else
              # Handle categorical attributes
              if value_index(att, index).nil?
                # Unseen categorical value - use small probability
                if @m == 0
                  # When m=0, use a very small probability that still preserves class prior ratios
                  prob[prob_index] *= 0.001
                else
                  # Use Laplace smoothing with m-estimate
                  denominator = @class_counts[prob_index] + @m
                  smoothed_prob = (@m * @class_prob[prob_index]) / denominator
                  prob[prob_index] *= smoothed_prob
                end
              else
                prob[prob_index] *= @pcp[index][value_index(att, index)][prob_index]
              end
            end
          end
        end

        prob
      end

      # Calculate log probabilities to avoid underflow
      def calculate_log_probabilities_for_entry(data, log_prob)
        0.upto(log_prob.length - 1) do |prob_index|
          data.each_with_index do |att, index|
            if @numeric_attributes[index]
              # Handle numeric attributes with Gaussian distribution
              gauss_prob = gaussian_probability(att, index, prob_index)
              # Avoid log(0) by using a very small probability
              gauss_prob = 1e-300 if gauss_prob == 0
              log_prob[prob_index] += Math.log(gauss_prob)
            else
              # Handle categorical attributes
              if value_index(att, index).nil?
                # Unseen categorical value - use small probability
                if @m == 0
                  # When m=0, use a very small probability
                  log_prob[prob_index] += Math.log(0.001)
                else
                  # Use Laplace smoothing with m-estimate
                  denominator = @class_counts[prob_index] + @m
                  smoothed_prob = (@m * @class_prob[prob_index]) / denominator
                  log_prob[prob_index] += Math.log(smoothed_prob)
                end
              else
                cond_prob = @pcp[index][value_index(att, index)][prob_index]
                # Avoid log(0)
                cond_prob = 1e-300 if cond_prob == 0
                log_prob[prob_index] += Math.log(cond_prob)
              end
            end
          end
        end

        log_prob
      end

      # Calculate Gaussian probability for numeric attributes
      def gaussian_probability(value, attr_index, class_index)
        mean = @means[attr_index][class_index]
        stdev = @stdevs[attr_index][class_index]
        
        # Handle zero variance (all values are the same)
        return 1.0 if stdev == 0
        
        # Calculate Gaussian probability density
        exponent = -((value.to_f - mean) ** 2) / (2 * stdev ** 2)
        (1 / (Math.sqrt(2 * Math::PI) * stdev)) * Math.exp(exponent)
      end

      # normalises the array of probabilities so the sum of the array equals 1
      def normalize_class_probability(prob)
        prob_sum = sum(prob)
        if prob_sum > 0
          prob.map { |prob_entry| prob_entry / prob_sum }
        else
          prob
        end
      end

      # sums an array up; returns a number of type Float
      def sum(array)
        array.sum(0.0)
      end

      # returns the name of the class when the index is found
      def index_to_klass(index)
        @klass_index.value?(index) ? @klass_index.key(index) : nil
      end

      # initializes @values and @klass_index; maps a certain value to a uniq index
      def initialize_klass_index
        @klasses.each_with_index do |dl, index|
          @klass_index[dl] = index
        end

        0.upto(@data_labels.length - 1) do |index|
          @values[index] = {}
          # Only build value index for categorical attributes
          unless @numeric_attributes[index]
            @domains[index].each_with_index do |d, d_index|
              @values[index][d] = d_index
            end
          end
        end
      end

      # Identify which attributes are numeric
      def identify_numeric_attributes
        0.upto(@data_labels.length - 1) do |index|
          @numeric_attributes[index] = !@domains[index].is_a?(Set)
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
      def build_array(index)
        # For numeric attributes, we don't need the value dimension
        if @numeric_attributes[index]
          return Array.new(@klasses.length, 0)
        end
        
        domains = Array.new(@domains[index].length)
        domains.map do
          Array.new @klasses.length, 0
        end
      end

      # initializes the two array for storing the count and conditional probabilities of
      # the attributes
      def initialize_pc
        0.upto(@data_labels.length - 1) do |index|
          if @numeric_attributes[index]
            # For numeric attributes, initialize mean and stdev storage
            @means[index] = Array.new(@klasses.length, 0.0)
            @stdevs[index] = Array.new(@klasses.length, 0.0)
            # Add nil placeholders to maintain array indices
            @pcc << nil
            @pcp << nil
          else
            # For categorical attributes, use the original structure
            @pcc << build_array(index)
            @pcp << build_array(index)
          end
        end
      end

      # calculates the occurrences of a class and the instances of a certain value of a
      # certain attribute and the assigned class.
      # In addition to that, it also calculates the conditional probabilities and values
      def calculate_probabilities
        @klasses.each { |dl| @class_counts[klass_index(dl)] = 0 }

        calculate_class_probabilities
        count_instances
        calculate_conditional_probabilities
        calculate_numeric_parameters
      end

      def calculate_class_probabilities
        @data_items.each do |entry|
          @class_counts[klass_index(entry.klass)] += 1
        end

        @class_counts.each_with_index do |k, index|
          @class_prob[index] = k.to_f / @data_items.length
        end
      end

      # counts the instances of a certain value of a certain attribute and the assigned class
      def count_instances
        @data_items.each do |item|
          0.upto(@data_labels.length - 1) do |dl_index|
            unless @numeric_attributes[dl_index]
              # Only count for categorical attributes
              @pcc[dl_index][value_index(item[dl_index], dl_index)][klass_index(item.klass)] += 1
            end
          end
        end
      end

      # calculates the conditional probability and stores it in the @pcp-array
      def calculate_conditional_probabilities
        @pcc.each_with_index do |attributes, a_index|
          next if attributes.nil? || @numeric_attributes[a_index] # Skip numeric attributes
          
          attributes.each_with_index do |values, v_index|
            values.each_with_index do |klass, k_index|
              denominator = @class_counts[k_index] + @m
              @pcp[a_index][v_index][k_index] =
                denominator == 0 ? 0.0 : (klass.to_f + (@m * @class_prob[k_index])) / denominator
            end
          end
        end
      end

      # Calculate means and standard deviations for numeric attributes
      def calculate_numeric_parameters
        # Group data by class
        class_data = Hash.new { |h, k| h[k] = [] }
        @data_items.each do |item|
          class_data[klass_index(item.klass)] << item
        end

        # Calculate mean and stdev for each numeric attribute per class
        0.upto(@data_labels.length - 1) do |attr_index|
          next unless @numeric_attributes[attr_index]

          @klasses.each_with_index do |_, class_index|
            values = class_data[class_index].map { |item| item[attr_index].to_f }
            
            if values.empty?
              @means[attr_index][class_index] = 0.0
              @stdevs[attr_index][class_index] = 1.0
            else
              # Calculate mean
              mean = values.sum / values.length
              @means[attr_index][class_index] = mean
              
              # Calculate standard deviation
              if values.length == 1
                @stdevs[attr_index][class_index] = 1.0
              else
                variance = values.map { |v| (v - mean) ** 2 }.sum / (values.length - 1)
                @stdevs[attr_index][class_index] = Math.sqrt(variance)
                # Prevent zero standard deviation
                @stdevs[attr_index][class_index] = 0.01 if @stdevs[attr_index][class_index] == 0
              end
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

        def initialize(attributes, klass)
          @klass = klass
          @entries = attributes
        end

        # wrapper method for the access to @entries
        def [](index)
          @entries[index]
        end
      end
    end
  end
end