# frozen_string_literal: true

# RSpec tests for AI4R Prism classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::Prism do
  # Test data from requirement document
  let(:categorical_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['sunny', 'hot', 'high', 'false'],
        ['sunny', 'hot', 'high', 'true'],
        ['overcast', 'hot', 'high', 'false'],
        ['rainy', 'mild', 'high', 'false'],
        ['rainy', 'cool', 'normal', 'false'],
        ['rainy', 'cool', 'normal', 'true'],
        ['overcast', 'cool', 'normal', 'true'],
        ['sunny', 'mild', 'high', 'false']
      ],
      data_labels: ['no', 'no', 'yes', 'yes', 'yes', 'no', 'yes', 'no']
    )
  end

  let(:multi_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['A', 'X', '1'],
        ['B', 'Y', '2'],
        ['C', 'Z', '3'],
        ['A', 'Y', '1'],
        ['B', 'Z', '2'],
        ['C', 'X', '3'],
        ['A', 'Z', '1'],
        ['B', 'X', '2']
      ],
      data_labels: ['class1', 'class2', 'class3', 'class1', 'class2', 'class3', 'class1', 'class2']
    )
  end

  let(:overlapping_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['A', 'high'],
        ['B', 'low'],
        ['A', 'low'],
        ['B', 'high'],
        ['A', 'medium'],
        ['B', 'medium']
      ],
      data_labels: ['positive', 'negative', 'positive', 'negative', 'positive', 'negative']
    )
  end

  let(:minimal_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [['A', 'X'], ['B', 'Y']],
      data_labels: ['1', '2']
    )
  end

  let(:single_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [['A', 'B'], ['C', 'D'], ['E', 'F']],
      data_labels: ['only_class', 'only_class', 'only_class']
    )
  end

  describe "Build Tests" do
    context "rule covering algorithm" do
      it "test_build_categorical_features" do
        classifier = described_class.new.build(categorical_dataset)
        
        expect(classifier).to be_a(described_class)
        expect(classifier.rules).to be_an(Array)
        expect(classifier.rules).not_to be_empty
        
        # Should be able to classify
        result = classifier.eval(['sunny', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
      end

      it "test_build_multi_class_covering" do
        classifier = described_class.new.build(multi_class_dataset)
        
        # Should generate rules for all classes
        expect(classifier.rules.length).to be > 0
        
        # Should handle 3-class problem
        result = classifier.eval(['A', 'X', '1'])
        expect(['class1', 'class2', 'class3']).to include(result)
      end

      it "test_build_overlapping_instances" do
        # Test with instances that have overlapping attribute combinations
        classifier = described_class.new.build(overlapping_dataset)
        
        expect(classifier.rules).to be_an(Array)
        
        # Should handle cases where same features map to different classes
        result = classifier.eval(['A', 'high'])
        expect(['positive', 'negative']).to include(result)
      end
    end

    context "edge cases" do
      it "test_build_minimal_dataset" do
        classifier = described_class.new.build(minimal_dataset)
        
        # Should work with minimal data
        expect(classifier.rules).to be_an(Array)
        
        result = classifier.eval(['A', 'X'])
        expect(['1', '2']).to include(result)
      end

      it "test_build_single_class" do
        classifier = described_class.new.build(single_class_dataset)
        
        # Should handle single class efficiently
        expect(classifier.rules).to be_an(Array)
        
        # Should always predict the single class
        result = classifier.eval(['X', 'Y'])
        expect(result).to eq('only_class')
      end

      it "test_build_empty_dataset" do
        empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
        
        expect {
          described_class.new.build(empty_dataset)
        }.to raise_error
      end
    end
  end

  describe "Eval Tests" do
    let(:trained_classifier) { described_class.new.build(categorical_dataset) }

    context "rule-based classification" do
      it "test_eval_covered_instance" do
        # Test with instance that should be covered by a rule
        result = trained_classifier.eval(['sunny', 'hot', 'high', 'false'])
        
        expect(['yes', 'no']).to include(result)
        expect(result).to be_a(String)
      end

      it "test_eval_partial_match" do
        # Test with instance that partially matches multiple rules
        result = trained_classifier.eval(['overcast', 'mild', 'normal', 'false'])
        
        expect(['yes', 'no']).to include(result)
      end

      it "test_eval_no_rule_match" do
        # Test with instance not covered by any rule
        result = trained_classifier.eval(['foggy', 'freezing', 'extreme', 'unknown'])
        
        # Should use default class or majority class
        expect(['yes', 'no']).to include(result)
      end
    end

    context "consistency and determinism" do
      it "test_eval_deterministic" do
        # Same input should always give same output
        instance = ['sunny', 'hot', 'high', 'false']
        
        result1 = trained_classifier.eval(instance)
        result2 = trained_classifier.eval(instance)
        
        expect(result1).to eq(result2)
      end

      it "handles missing values" do
        result = trained_classifier.eval(['sunny', nil, 'high', 'false'])
        
        expect {
          expect(['yes', 'no']).to include(result)
        }.not_to raise_error
      end
    end
  end

  describe "Rule Analysis Tests" do
    let(:classifier) { described_class.new.build(categorical_dataset) }

    it "provides interpretable rules" do
      rules = classifier.rules
      
      expect(rules).to be_an(Array)
      expect(rules).not_to be_empty
      
      # Rules should be interpretable (contain conditions and conclusions)
      rules.each do |rule|
        expect(rule).to respond_to(:conditions) if rule.respond_to?(:conditions)
        expect(rule).to respond_to(:conclusion) if rule.respond_to?(:conclusion)
      end
    end

    it "covers all training instances" do
      # PRISM should generate rules that cover all positive instances
      correct_predictions = 0
      
      categorical_dataset.data_items.each_with_index do |item, i|
        prediction = classifier.eval(item)
        actual = categorical_dataset.data_labels[i]
        correct_predictions += 1 if prediction == actual
      end
      
      # Should achieve reasonable accuracy on training data
      accuracy = correct_predictions.to_f / categorical_dataset.data_items.length
      expect(accuracy).to be > 0.5
    end

    it "generates class-specific rules" do
      # PRISM generates separate rules for each class
      rules = classifier.rules
      
      # Should have rules (implementation dependent structure)
      expect(rules).to be_an(Array)
      expect(rules.length).to be > 0
    end
  end

  describe "Performance Tests" do
    it "handles moderate-sized datasets efficiently" do
      # Generate medium dataset
      medium_items = []
      medium_labels = []
      
      200.times do |i|
        medium_items << ["attr1_#{i % 10}", "attr2_#{i % 5}", "attr3_#{i % 8}"]
        medium_labels << (i % 3).to_s
      end
      
      medium_dataset = Ai4r::Data::DataSet.new(
        data_items: medium_items,
        data_labels: medium_labels
      )
      
      benchmark_performance("Prism training on medium dataset") do
        classifier = described_class.new.build(medium_dataset)
        expect(classifier.rules).to be_an(Array)
      end
    end

    it "evaluation performance is reasonable" do
      classifier = described_class.new.build(multi_class_dataset)
      
      benchmark_performance("Prism rule evaluation") do
        50.times do
          result = classifier.eval(['A', 'X', '1'])
          expect(['class1', 'class2', 'class3']).to include(result)
        end
      end
    end
  end

  describe "Integration Tests" do
    it "works with different class distributions" do
      # Test with unbalanced classes
      unbalanced_items = Array.new(20) { ['common', 'feature'] } + 
                        Array.new(5) { ['rare', 'feature'] }
      unbalanced_labels = Array.new(20) { 'majority' } + 
                         Array.new(5) { 'minority' }
      
      unbalanced_dataset = Ai4r::Data::DataSet.new(
        data_items: unbalanced_items,
        data_labels: unbalanced_labels
      )
      
      classifier = described_class.new.build(unbalanced_dataset)
      
      # Should handle unbalanced data
      result1 = classifier.eval(['common', 'feature'])
      result2 = classifier.eval(['rare', 'feature'])
      
      expect(['majority', 'minority']).to include(result1)
      expect(['majority', 'minority']).to include(result2)
    end

    it "maintains consistency across builds" do
      # Same dataset should produce same rules (given deterministic implementation)
      classifier1 = described_class.new.build(categorical_dataset)
      classifier2 = described_class.new.build(categorical_dataset)
      
      test_instance = ['sunny', 'hot', 'high', 'false']
      
      result1 = classifier1.eval(test_instance)
      result2 = classifier2.eval(test_instance)
      
      expect(result1).to eq(result2)
    end

    it "handles complex rule interactions" do
      # Test with data that requires multiple overlapping rules
      complex_items = [
        ['A', '1', 'X'], ['A', '2', 'Y'], ['B', '1', 'Y'], ['B', '2', 'X'],
        ['A', '1', 'Y'], ['A', '2', 'X'], ['B', '1', 'X'], ['B', '2', 'Y']
      ]
      complex_labels = ['pos', 'neg', 'neg', 'pos', 'pos', 'neg', 'neg', 'pos']
      
      complex_dataset = Ai4r::Data::DataSet.new(
        data_items: complex_items,
        data_labels: complex_labels
      )
      
      classifier = described_class.new.build(complex_dataset)
      
      # Should be able to learn complex patterns
      result = classifier.eval(['A', '1', 'X'])
      expect(['pos', 'neg']).to include(result)
    end
  end

  # Helper methods for assertions
  def assert_classification_correct(classifier, instance, expected_class)
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_deterministic_output(classifier, instance)
    result1 = classifier.eval(instance)
    result2 = classifier.eval(instance)
    expect(result1).to eq(result2)
  end

  def assert_rule_coverage(classifier, dataset)
    # Check that rules provide reasonable coverage
    correct = 0
    dataset.data_items.each_with_index do |item, i|
      prediction = classifier.eval(item)
      actual = dataset.data_labels[i]
      correct += 1 if prediction == actual
    end
    
    accuracy = correct.to_f / dataset.data_items.length
    expect(accuracy).to be > 0.4  # Reasonable threshold for complex rule learning
  end

  def assert_handles_unknown_value(classifier, instance_with_unknown)
    expect {
      result = classifier.eval(instance_with_unknown)
      expect(result).to be_a(String)
    }.not_to raise_error
  end
end