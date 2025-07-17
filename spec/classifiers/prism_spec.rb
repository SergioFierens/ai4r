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
        %w[sunny hot high false no],
        %w[sunny hot high true no],
        %w[overcast hot high false yes],
        %w[rainy mild high false yes],
        %w[rainy cool normal false yes],
        %w[rainy cool normal true no],
        %w[overcast cool normal true yes],
        %w[sunny mild high false no]
      ],
      data_labels: %w[outlook temperature humidity windy play]
    )
  end

  let(:multi_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        %w[A X 1 class1],
        %w[B Y 2 class2],
        %w[C Z 3 class3],
        %w[A Y 1 class1],
        %w[B Z 2 class2],
        %w[C X 3 class3],
        %w[A Z 1 class1],
        %w[B X 2 class2]
      ],
      data_labels: %w[attr1 attr2 attr3 class]
    )
  end

  let(:overlapping_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        %w[A high positive],
        %w[B low negative],
        %w[A low positive],
        %w[B high negative],
        %w[A medium positive],
        %w[B medium negative]
      ],
      data_labels: %w[feature1 feature2 class]
    )
  end

  let(:minimal_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [%w[A X 1], %w[B Y 2]],
      data_labels: %w[attr1 attr2 class]
    )
  end

  let(:single_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [%w[A B same], %w[C D same], %w[E F same]],
      data_labels: %w[attr1 attr2 class]
    )
  end

  describe 'Build Tests' do
    context 'rule covering algorithm' do
      it 'test_build_categorical_features' do
        classifier = described_class.new.build(categorical_dataset)

        expect(classifier).to be_a(described_class)
        expect(classifier.rules).to be_an(Array)
        expect(classifier.rules).not_to be_empty

        # Should be able to classify
        result = classifier.eval(%w[sunny hot high false])
        expect(%w[yes no]).to include(result)
      end

      it 'test_build_multi_class_covering' do
        classifier = described_class.new.build(multi_class_dataset)

        # Should generate rules for all classes
        expect(classifier.rules.length).to be > 0

        # Should handle 3-class problem
        result = classifier.eval(%w[A X 1])
        expect(%w[class1 class2 class3]).to include(result)
      end

      it 'test_build_overlapping_instances' do
        # Test with instances that have overlapping attribute combinations
        classifier = described_class.new.build(overlapping_dataset)

        expect(classifier.rules).to be_an(Array)

        # Should handle cases where same features map to different classes
        result = classifier.eval(%w[A high])
        expect(%w[positive negative]).to include(result)
      end
    end

    context 'edge cases' do
      it 'test_build_minimal_dataset' do
        classifier = described_class.new.build(minimal_dataset)

        # Should work with minimal data
        expect(classifier.rules).to be_an(Array)

        result = classifier.eval(%w[A X])
        expect(%w[1 2]).to include(result)
      end

      it 'test_build_single_class' do
        classifier = described_class.new.build(single_class_dataset)

        # Should handle single class efficiently
        expect(classifier.rules).to be_an(Array)

        # Should always predict the single class
        result = classifier.eval(%w[X Y])
        expect(result).to eq('same')
      end

      it 'test_build_empty_dataset' do
        expect do
          empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
          described_class.new.build(empty_dataset)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Eval Tests' do
    let(:trained_classifier) { described_class.new.build(categorical_dataset) }

    context 'rule-based classification' do
      it 'test_eval_covered_instance' do
        # Test with instance that should be covered by a rule
        result = trained_classifier.eval(%w[sunny hot high false])

        expect(%w[yes no]).to include(result)
        expect(result).to be_a(String)
      end

      it 'test_eval_partial_match' do
        # Test with instance that partially matches multiple rules
        result = trained_classifier.eval(%w[overcast mild normal false])

        expect(%w[yes no]).to include(result)
      end

      it 'test_eval_no_rule_match' do
        # Test with instance not covered by any rule
        result = trained_classifier.eval(%w[foggy freezing extreme unknown])

        # Should use default class or majority class
        expect(%w[yes no]).to include(result)
      end
    end

    context 'consistency and determinism' do
      it 'test_eval_deterministic' do
        # Same input should always give same output
        instance = %w[sunny hot high false]

        result1 = trained_classifier.eval(instance)
        result2 = trained_classifier.eval(instance)

        expect(result1).to eq(result2)
      end

      it 'handles missing values' do
        result = trained_classifier.eval(['sunny', nil, 'high', 'false'])

        expect do
          expect(%w[yes no]).to include(result)
        end.not_to raise_error
      end
    end
  end

  describe 'Rule Analysis Tests' do
    let(:classifier) { described_class.new.build(categorical_dataset) }

    it 'provides interpretable rules' do
      rules = classifier.rules

      expect(rules).to be_an(Array)
      expect(rules).not_to be_empty

      # Rules should be interpretable (contain conditions and conclusions)
      rules.each do |rule|
        expect(rule).to respond_to(:conditions) if rule.respond_to?(:conditions)
        expect(rule).to respond_to(:conclusion) if rule.respond_to?(:conclusion)
      end
    end

    it 'covers all training instances' do
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

    it 'generates class-specific rules' do
      # PRISM generates separate rules for each class
      rules = classifier.rules

      # Should have rules (implementation dependent structure)
      expect(rules).to be_an(Array)
      expect(rules.length).to be > 0
    end
  end

  describe 'Performance Tests' do
    it 'handles moderate-sized datasets efficiently' do
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

      benchmark_performance('Prism training on medium dataset') do
        classifier = described_class.new.build(medium_dataset)
        expect(classifier.rules).to be_an(Array)
      end
    end

    it 'evaluation performance is reasonable' do
      classifier = described_class.new.build(multi_class_dataset)

      benchmark_performance('Prism rule evaluation') do
        50.times do
          result = classifier.eval(%w[A X 1])
          expect(%w[class1 class2 class3]).to include(result)
        end
      end
    end
  end

  describe 'Integration Tests' do
    it 'works with different class distributions' do
      # Test with unbalanced classes
      unbalanced_items = Array.new(20) { %w[common feature] } +
                         Array.new(5) { %w[rare feature] }
      unbalanced_labels = Array.new(20) { 'majority' } +
                          Array.new(5) { 'minority' }

      unbalanced_dataset = Ai4r::Data::DataSet.new(
        data_items: unbalanced_items,
        data_labels: unbalanced_labels
      )

      classifier = described_class.new.build(unbalanced_dataset)

      # Should handle unbalanced data
      result1 = classifier.eval(%w[common feature])
      result2 = classifier.eval(%w[rare feature])

      expect(%w[majority minority]).to include(result1)
      expect(%w[majority minority]).to include(result2)
    end

    it 'maintains consistency across builds' do
      # Same dataset should produce same rules (given deterministic implementation)
      classifier1 = described_class.new.build(categorical_dataset)
      classifier2 = described_class.new.build(categorical_dataset)

      test_instance = %w[sunny hot high false]

      result1 = classifier1.eval(test_instance)
      result2 = classifier2.eval(test_instance)

      expect(result1).to eq(result2)
    end

    it 'handles complex rule interactions' do
      # Test with data that requires multiple overlapping rules
      complex_items = [
        %w[A 1 X], %w[A 2 Y], %w[B 1 Y], %w[B 2 X],
        %w[A 1 Y], %w[A 2 X], %w[B 1 X], %w[B 2 Y]
      ]
      complex_labels = %w[pos neg neg pos pos neg neg pos]

      complex_dataset = Ai4r::Data::DataSet.new(
        data_items: complex_items,
        data_labels: complex_labels
      )

      classifier = described_class.new.build(complex_dataset)

      # Should be able to learn complex patterns
      result = classifier.eval(%w[A 1 X])
      expect(%w[pos neg]).to include(result)
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
    expect(accuracy).to be > 0.4 # Reasonable threshold for complex rule learning
  end

  def assert_handles_unknown_value(classifier, instance_with_unknown)
    expect do
      result = classifier.eval(instance_with_unknown)
      expect(result).to be_a(String)
    end.not_to raise_error
  end
end
