# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/experiment/classifier_evaluator'
require 'ai4r/classifiers/classifier'

class MockClassifier < Ai4r::Classifiers::Classifier
  
  attr_accessor :built
  
  def initialize(class_value)
    @built = false
    @class_value = class_value
  end
  
  def build(data_set)
    @built = true
  end
  
  def eval(data)
    @class_value
  end
  
end

module Ai4r
  module Experiment
    class ClassifierEvaluatorTest < Test::Unit::TestCase
      
      def test_add_classifier
        evaluator = ClassifierEvaluator.new
        evaluator << MockClassifier.new(nil) << MockClassifier.new(nil)
        evaluator.add_classifier(MockClassifier.new(nil)).
          add_classifier(MockClassifier.new(nil)).
          add_classifier(MockClassifier.new(nil))
        assert_equal 5, evaluator.classifiers.length
      end

      def test_build
        evaluator = ClassifierEvaluator.new
        5.times { evaluator << MockClassifier.new(nil) }
        evaluator.classifiers.each {|c| assert !c.built}
        evaluator.build(Ai4r::Data::DataSet.new)
        evaluator.classifiers.each {|c| assert c.built}
      end
      
      def test_eval
        evaluator = ClassifierEvaluator.new
        5.times { |x| evaluator << MockClassifier.new(x) }
        assert_equal [0, 1, 2, 3, 4], evaluator.eval([])
      end
      
      def test_test
        evaluator = ClassifierEvaluator.new
        5.times { |x| evaluator << MockClassifier.new(x) }
        input = Ai4r::Data::DataSet.new :data_items => 
          [[0],[0],[0],[1],[2],[3]]
        output = evaluator.test input
        assert_equal 5, output.data_items.length # 5 classifiers, 5 result rows
        output.data_items.each { |result| assert result[1]>=0 && result[1]<1} # eval time
        assert_equal 3, output.data_items.first[2] # 3 errors for the 1st classifier
        assert_equal 0.5, output.data_items.first[3] # succes rate
        assert_equal 6, output.data_items.last[2] # 6 errors for the last classifier
        assert_equal 0, output.data_items.last[3] # succes rate
      end
      
    end
  end
end
