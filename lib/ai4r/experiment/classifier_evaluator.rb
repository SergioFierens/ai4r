# frozen_string_literal: true
require 'benchmark'
require_relative '../data/data_set'
require_relative 'split'


module Ai4r

  module Experiment
  
    # The ClassifierEvaluator is useful to compare different classifiers 
    # algorithms. The evaluator builds the Classifiers using the same data 
    # examples, and provides methods to evalute their performance in parallel.
    # It is a nice tool to compare and evaluate the performance of different 
    # algorithms, the same algorithm with different parameters, or your own new 
    # algorithm against the classic classifiers.
    class ClassifierEvaluator
      
      attr_reader :build_times, :eval_times, :classifiers
      
      # @return [Object]
      def initialize
        @classifiers = []
      end

      # Add a classifier instance to the test batch
      # @param classifier [Object]
      # @return [Object]
      def add_classifier(classifier)
        @classifiers << classifier
        return self
      end
      
      alias :<< :add_classifier
      
      # Build all classifiers, using data examples found in data_set.
      # The last attribute of each item is considered as the
      # item class.
      # Building times are measured by separate, and can be accessed
      # through build_times attribute reader.
      # @param data_set [Object]
      # @return [Object]
      def build(data_set)
        @build_times = []
        @classifiers.each do |classifier|
          @build_times << Benchmark.measure { classifier.build data_set }
        end
        return self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  
      #   => ['Y', 'Y', 'Y', 'N', 'Y', 'Y', 'N']
      # Evaluation times are measured by separate, and can be accessed
      # through eval_times attribute reader.
      # @param data [Object]
      # @return [Object]
      def eval(data)
        @eval_times = []
        results = []
        @classifiers.each do |classifier|
          @eval_times << Benchmark.measure { results << classifier.eval(data) }
        end
        return results
      end
      
      # Test classifiers using a data set. The last attribute of each item 
      # is considered as the expected class. Data items are evaluated
      # using all classifiers: evalution times, sucess rate, and quantity of
      # classification errors are returned in a data set.
      # The return data set has a row for every classifier tested, and the 
      # following attributes:
      #   ["Classifier", "Testing Time", "Errors", "Success rate"]
      # @param data_set [Object]
      # @return [Object]
      def test(data_set)
        result_data_items = []
        @classifiers.each do |classifier|
          result_data_items << test_classifier(classifier, data_set)
        end

        return Ai4r::Data::DataSet.new(data_items: result_data_items,
          data_labels: ["Classifier","Testing Time","Errors","Success rate"])

      end

      # Perform k-fold cross validation on all classifiers.
      # The dataset is split into +k+ folds using the Split utility. For each
      # fold, classifiers are trained on the remaining folds and then tested on
      # the held-out fold. The method returns a DataSet with the average time
      # (build and test) and accuracy for each classifier.
      # @param data_set [Ai4r::Data::DataSet] data to evaluate
      # @param k [Integer] number of folds
      # @return [Ai4r::Data::DataSet]
      def cross_validate(data_set, k:)
        folds = Split.split(data_set, k: k)
        times = Array.new(@classifiers.length, 0.0)
        accuracies = Array.new(@classifiers.length, 0.0)

        folds.each_with_index do |test_set, i|
          train_items = []
          folds.each_with_index do |fold, j|
            next if i == j
            train_items.concat(fold.data_items)
          end
          train_set = Ai4r::Data::DataSet.new(
            data_items: train_items,
            data_labels: data_set.data_labels
          )

          @classifiers.each_with_index do |classifier, idx|
            build_time = Benchmark.measure { classifier.build(train_set) }.real
            result = test_classifier(classifier, test_set)
            times[idx] += build_time + result[1]
            accuracies[idx] += result[3]
          end
        end

        result_items = @classifiers.each_index.map do |idx|
          [@classifiers[idx], times[idx] / k, accuracies[idx] / k]
        end
        Ai4r::Data::DataSet.new(
          data_items: result_items,
          data_labels: ["Classifier", "Avg. Time", "Avg. Success rate"]
        )
      end
      
      private
      # @param classifier [Object]
      # @param data_set [Object]
      # @return [Object]
      def test_classifier(classifier, data_set)
        data_set_size = data_set.data_items.length
        errors = 0
        testing_times = Benchmark.measure do 
          data_set.data_items.each do |data_item|
            data = data_item[0...-1]
            expected_result = data_item.last
            result = classifier.eval data
            errors += 1 if result != expected_result
          end
        end
        return [classifier, testing_times.real, errors,
          ((data_set_size-errors*1.0)/data_set_size)]
      end

    end
    
  end

end
