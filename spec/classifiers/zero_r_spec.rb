# frozen_string_literal: true

# RSpec tests for AI4R ZeroR classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::ZeroR do
  # Test data from requirement document - AI4R format: last element is target class
  let(:majority_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['A', 'B', 'yes'], ['C', 'D', 'yes'], ['E', 'F', 'yes'],
        ['G', 'H', 'yes'], ['I', 'J', 'yes'], ['K', 'L', 'no'], 
        ['M', 'N', 'no'], ['O', 'P', 'maybe']
      ],
      data_labels: ['attr1', 'attr2', 'class']
    )
  end

  let(:tie_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [['A', 'B', 'class1'], ['C', 'D', 'class1'], ['E', 'F', 'class2'], ['G', 'H', 'class2']],
      data_labels: ['attr1', 'attr2', 'class']
    )
  end

  let(:single_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [['A', 'B', 'only_class'], ['C', 'D', 'only_class'], ['E', 'F', 'only_class']],
      data_labels: ['attr1', 'attr2', 'class']
    )
  end

  let(:many_classes_dataset) do
    items = Array.new(150) { |i| [i, i*2, "class_#{i % 100}"] }  # Target class is last element
    
    Ai4r::Data::DataSet.new(
      data_items: items,
      data_labels: ['num_attr', 'mult_attr', 'class']
    )
  end

  describe "Build Tests" do
    context "majority class identification" do
      it "test_build_majority_class" do
        classifier = described_class.new.build(majority_class_dataset)
        
        expect(classifier).to be_a(described_class)
        expect(classifier.class_value).to eq('yes')  # Appears 5 times
        
        # Should always predict majority class
        result = classifier.eval(['anything', 'irrelevant'])
        expect(result).to eq('yes')
      end

      it "test_build_single_class" do
        classifier = described_class.new.build(single_class_dataset)
        
        expect(classifier.class_value).to eq('only_class')
        
        # Should always predict the single class
        result = classifier.eval(['X', 'Y'])
        expect(result).to eq('only_class')
      end

      it "test_build_many_classes" do
        classifier = described_class.new.build(many_classes_dataset)
        
        # Should pick one of the classes (may be arbitrary due to distribution)
        expect(classifier.class_value).to be_a(String)
        expect(classifier.class_value).to start_with('class_')
        
        result = classifier.eval([999, 1998])
        expect(result).to start_with('class_')
      end
    end

    context "tie breaking" do
      it "test_build_tie_breaking" do
        classifier = described_class.new.build(tie_dataset)
        
        # When classes have equal frequency, should pick one deterministically
        selected_class = classifier.class_value
        expect(['class1', 'class2']).to include(selected_class)
        
        # Should be consistent
        classifier2 = described_class.new.build(tie_dataset)
        expect(classifier2.class_value).to eq(selected_class)
      end
    end

    context "error cases" do
      it "test_build_no_classes" do
        expect {
          empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
          described_class.new.build(empty_dataset)
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "Eval Tests" do
    let(:trained_classifier) { described_class.new.build(majority_class_dataset) }

    context "baseline behavior" do
      it "test_eval_always_same" do
        # Should always return the same class regardless of input
        result1 = trained_classifier.eval(['sunny', 'hot'])
        result2 = trained_classifier.eval(['rainy', 'cold'])
        result3 = trained_classifier.eval(['overcast', 'mild'])
        
        expect(result1).to eq('yes')
        expect(result2).to eq('yes')
        expect(result3).to eq('yes')
        
        # All results should be identical
        expect(result1).to eq(result2)
        expect(result2).to eq(result3)
      end

      it "test_eval_ignores_features" do
        # Input features should be completely irrelevant
        
        # Different number of features
        result1 = trained_classifier.eval(['A'])
        result2 = trained_classifier.eval(['A', 'B', 'C', 'D', 'E'])
        
        # Different data types
        result3 = trained_classifier.eval([1, 2.5, true, nil])
        result4 = trained_classifier.eval(['string', 100, []])
        
        # All should return majority class
        expect(result1).to eq('yes')
        expect(result2).to eq('yes')
        expect(result3).to eq('yes')
        expect(result4).to eq('yes')
      end
    end

    context "edge cases" do
      it "handles nil input" do
        result = trained_classifier.eval(nil)
        expect(result).to eq('yes')
      end

      it "handles empty array input" do
        result = trained_classifier.eval([])
        expect(result).to eq('yes')
      end

      it "handles very large input" do
        large_input = Array.new(1000) { rand(1000) }
        result = trained_classifier.eval(large_input)
        expect(result).to eq('yes')
      end
    end
  end

  describe "Baseline Evaluation Tests" do
    it "provides consistent baseline accuracy" do
      classifier = described_class.new.build(majority_class_dataset)
      
      # Calculate expected accuracy (should be frequency of majority class)
      total_instances = majority_class_dataset.data_items.length
      target_classes = majority_class_dataset.data_items.map(&:last)
      majority_count = target_classes.count('yes')
      expected_accuracy = majority_count.to_f / total_instances
      
      # Test on training data
      correct_predictions = 0
      majority_class_dataset.data_items.each do |item|
        prediction = classifier.eval(item[0..-2])  # All except last element
        actual_class = item.last  # Last element is target class
        correct_predictions += 1 if prediction == actual_class
      end
      
      actual_accuracy = correct_predictions.to_f / total_instances
      expect(actual_accuracy).to be_within(0.01).of(expected_accuracy)
    end

    it "serves as proper baseline for comparison" do
      # ZeroR should never achieve 100% accuracy unless all instances have same class
      mixed_classifier = described_class.new.build(majority_class_dataset)
      single_classifier = described_class.new.build(single_class_dataset)
      
      # Mixed dataset accuracy should be < 1.0
      accuracy_mixed = calculate_training_accuracy(mixed_classifier, majority_class_dataset)
      expect(accuracy_mixed).to be < 1.0
      
      # Single class dataset accuracy should be 1.0
      accuracy_single = calculate_training_accuracy(single_classifier, single_class_dataset)
      expect(accuracy_single).to eq(1.0)
    end
  end

  describe "Performance Tests" do
    it "builds and evaluates extremely fast" do
      # ZeroR should be the fastest possible classifier
      benchmark_performance("ZeroR training on large dataset") do
        classifier = described_class.new.build(many_classes_dataset)
        expect(classifier.class_value).to be_a(String)
      end
      
      trained_classifier = described_class.new.build(many_classes_dataset)
      
      benchmark_performance("ZeroR evaluation speed") do
        1000.times do
          result = trained_classifier.eval([rand(1000), rand(1000)])
          expect(result).to be_a(String)
        end
      end
    end

    it "handles massive datasets efficiently" do
      # Generate very large dataset
      massive_items = Array.new(10000) { |i| [i, i*2, i*3, i % 2 == 0 ? 'even' : 'odd'] }
      
      massive_dataset = Ai4r::Data::DataSet.new(
        data_items: massive_items,
        data_labels: ['attr1', 'attr2', 'attr3', 'class']
      )
      
      classifier = described_class.new.build(massive_dataset)
      
      # Should handle efficiently
      expect(classifier.class_value).to eq('even')  # Slightly more even numbers
    end
  end

  describe "Statistical Properties Tests" do
    it "correctly identifies majority in various distributions" do
      # Uniform distribution
      uniform_items = Array.new(35) { |i| [rand(10), i < 10 ? 'A' : (i < 20 ? 'B' : 'C')] }
      uniform_dataset = Ai4r::Data::DataSet.new(
        data_items: uniform_items,
        data_labels: ['random_attr', 'class']
      )
      
      classifier = described_class.new.build(uniform_dataset)
      expect(classifier.class_value).to eq('C')
      
      # Skewed distribution
      skewed_items = Array.new(100) { |i| [rand(10), i < 5 ? 'rare' : 'common'] }
      skewed_dataset = Ai4r::Data::DataSet.new(
        data_items: skewed_items,
        data_labels: ['random_attr', 'class']
      )
      
      classifier2 = described_class.new.build(skewed_dataset)
      expect(classifier2.class_value).to eq('common')
    end
  end

  describe "Integration Tests" do
    it "works as baseline for model comparison" do
      # ZeroR should provide lower bound for other classifiers
      zeror_classifier = described_class.new.build(majority_class_dataset)
      
      # Any reasonable classifier should beat ZeroR on learnable data
      zeror_accuracy = calculate_training_accuracy(zeror_classifier, majority_class_dataset)
      
      # ZeroR accuracy should be reasonable baseline (>= random chance)
      target_classes = majority_class_dataset.data_items.map(&:last)
      num_classes = target_classes.uniq.length
      random_accuracy = 1.0 / num_classes
      
      expect(zeror_accuracy).to be >= random_accuracy
    end

    it "maintains state correctly" do
      classifier = described_class.new.build(majority_class_dataset)
      
      # State should not change after multiple evaluations
      initial_class = classifier.class_value
      
      100.times do
        classifier.eval([rand(100), rand(100)])
      end
      
      expect(classifier.class_value).to eq(initial_class)
    end
  end

  # Helper methods
  def calculate_training_accuracy(classifier, dataset)
    correct = 0
    dataset.data_items.each do |item|
      prediction = classifier.eval(item[0..-2])  # All except last element
      actual = item.last  # Last element is target class
      correct += 1 if prediction == actual
    end
    correct.to_f / dataset.data_items.length
  end

  # Assertion helpers
  def assert_classification_correct(classifier, instance, expected_class)
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_deterministic_output(classifier, instance)
    result1 = classifier.eval(instance)
    result2 = classifier.eval(instance)
    expect(result1).to eq(result2)
  end
end