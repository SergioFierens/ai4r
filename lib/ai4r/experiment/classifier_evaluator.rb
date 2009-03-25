require 'benchmark'
require File.dirname(__FILE__) + '/../data/data_set' 


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
      
      def initialize
        @classifiers = []
      end

      # Add a classifier instance to the test batch
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
      def test(data_set)
        result_data_items = []
        @classifiers.each do |classifier|
          result_data_items << test_classifier(classifier, data_set)
        end
        return Ai4r::Data::DataSet.new(:data_items => result_data_items, 
          :data_labels => ["Classifier","Testing Time","Errors","Success rate"])
      end
      
      private
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
