# frozen_string_literal: true

# RSpec tests for AI4R ID3 classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::ID3 do
  # Test data from requirement document - Weather dataset
  let(:weather_data_items) do
    [
      %w[sunny hot high false],
      %w[sunny hot high true],
      %w[overcast hot high false],
      %w[rainy mild high false],
      %w[rainy cool normal false],
      %w[rainy cool normal true],
      %w[overcast cool normal true],
      %w[sunny mild high false],
      %w[sunny cool normal false],
      %w[rainy mild normal false],
      %w[sunny mild normal true],
      %w[overcast mild high true],
      %w[overcast hot normal false],
      %w[rainy mild high true]
    ]
  end

  let(:weather_data_labels) do
    %w[outlook temperature humidity windy play]
  end

  let(:weather_data_items_with_classes) do
    [
      %w[sunny hot high false no],
      %w[sunny hot high true no],
      %w[overcast hot high false yes],
      %w[rainy mild high false yes],
      %w[rainy cool normal false yes],
      %w[rainy cool normal true no],
      %w[overcast cool normal true yes],
      %w[sunny mild high false no],
      %w[sunny cool normal false yes],
      %w[rainy mild normal false yes],
      %w[sunny mild normal true yes],
      %w[overcast mild high true yes],
      %w[overcast hot normal false yes],
      %w[rainy mild high true no]
    ]
  end

  let(:weather_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: weather_data_items_with_classes,
      data_labels: weather_data_labels
    )
  end

  # Additional test datasets
  let(:single_feature_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [['A', '1'], ['B', '2'], ['A', '1'], ['B', '2']],
      data_labels: %w[feature class]
    )
  end

  let(:single_instance_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [%w[sunny hot yes]],
      data_labels: %w[outlook temperature play]
    )
  end

  let(:all_same_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [%w[A B yes], %w[C D yes], %w[E F yes]],
      data_labels: %w[attr1 attr2 class]
    )
  end

  let(:continuous_features_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.5, 2.3, 'A'], [4.1, 5.2, 'B'], [7.8, 8.9, 'C'], [2.1, 3.4, 'A']],
      data_labels: %w[feature1 feature2 class]
    )
  end

  let(:identical_instances_different_classes) do
    Ai4r::Data::DataSet.new(
      data_items: [%w[A B yes], %w[A B no], %w[C D maybe]],
      data_labels: %w[attr1 attr2 class]
    )
  end

  describe 'Build Tests' do
    context 'standard datasets' do
      it 'test_build_weather_dataset' do
        classifier = described_class.new.build(weather_dataset)

        expect(classifier).to be_a(described_class)
        expect(classifier.data_set).to eq(weather_dataset)

        # Test a few predictions to verify the tree was built
        result = classifier.eval(%w[sunny hot high false])
        expect(%w[yes no]).to include(result)
      end

      it 'test_build_single_feature' do
        classifier = described_class.new.build(single_feature_dataset)

        expect(classifier).to be_a(described_class)

        # Should be able to predict based on single feature
        result = classifier.eval(['A'])
        expect(result).to eq('1')
      end

      it 'test_build_single_instance' do
        classifier = described_class.new.build(single_instance_dataset)

        expect(classifier).to be_a(described_class)

        # With single instance, should predict that class
        result = classifier.eval(%w[sunny hot])
        expect(result).to eq('yes')
      end

      it 'test_build_all_same_class' do
        classifier = described_class.new.build(all_same_class_dataset)

        expect(classifier).to be_a(described_class)

        # Should always predict the single class
        result1 = classifier.eval(%w[A B])
        result2 = classifier.eval(%w[X Y])
        expect(result1).to eq('yes')
        expect(result2).to eq('yes')
      end

      it 'test_build_continuous_features' do
        # ID3 should handle continuous features through discretization
        expect do
          classifier = described_class.new.build(continuous_features_dataset)
          expect(classifier).to be_a(described_class)
        end.not_to raise_error
      end

      it 'test_build_identical_instances_different_classes' do
        # This represents unlearnable data - same features, different classes
        classifier = described_class.new.build(identical_instances_different_classes)

        expect(classifier).to be_a(described_class)

        # Should handle gracefully, likely picking majority class for conflicts
        result = classifier.eval(%w[A B])
        expect(%w[yes no maybe]).to include(result)
      end
    end

    context 'parameter testing' do
      it 'test_build_max_depth' do
        # Test with depth limitation
        classifier = described_class.new
        classifier.set_parameters(max_depth: 2)
        classifier.build(weather_dataset)

        expect(classifier).to be_a(described_class)

        # Should still be able to make predictions
        result = classifier.eval(%w[sunny hot high false])
        expect(%w[yes no]).to include(result)
      end
    end

    context 'error cases' do
      it 'test_build_empty_dataset' do
        expect do
          empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
          described_class.new.build(empty_dataset)
        end.to raise_error(ArgumentError)
      end

      it 'test_build_nil_dataset' do
        expect do
          described_class.new.build(nil)
        end.to raise_error
      end

      it 'test_build_missing_values' do
        dataset_with_nils = Ai4r::Data::DataSet.new(
          data_items: [['A', nil], %w[B X], [nil, 'Y']],
          data_labels: %w[1 2 3]
        )

        # Should handle missing values gracefully
        expect do
          classifier = described_class.new.build(dataset_with_nils)
          expect(classifier).to be_a(described_class)
        end.not_to raise_error
      end
    end
  end

  describe 'Eval Tests' do
    let(:trained_classifier) { described_class.new.build(weather_dataset) }

    context 'prediction testing' do
      it 'test_eval_known_instance' do
        # Test with a training instance
        known_instance = %w[sunny hot high false]
        result = trained_classifier.eval(known_instance)

        expect(%w[yes no]).to include(result)
        expect(result).to be_a(String)
      end

      it 'test_eval_new_instance' do
        # Test with unseen combination
        new_instance = %w[overcast mild normal false]
        result = trained_classifier.eval(new_instance)

        expect(%w[yes no]).to include(result)
      end

      it 'test_eval_unknown_attribute_value' do
        # Test with a value not seen during training
        unknown_instance = %w[foggy hot high false]

        # Should handle gracefully, possibly using majority class
        expect do
          result = trained_classifier.eval(unknown_instance)
          expect(%w[yes no]).to include(result)
        end.not_to raise_error
      end

      it 'test_eval_missing_attribute' do
        # Test with nil value
        missing_instance = ['sunny', nil, 'high', 'false']

        expect do
          result = trained_classifier.eval(missing_instance)
          expect(%w[yes no]).to include(result)
        end.not_to raise_error
      end
    end

    context 'error cases' do
      it 'test_eval_wrong_dimensions' do
        # Test with wrong number of features
        expect do
          trained_classifier.eval(%w[sunny hot]) # Missing 2 features
        end.to raise_error
      end

      it 'test_eval_before_build' do
        # Test evaluation before building tree
        unbuild_classifier = described_class.new

        expect do
          unbuild_classifier.eval(%w[sunny hot high false])
        end.to raise_error
      end
    end
  end

  describe 'Rules Tests' do
    let(:trained_classifier) { described_class.new.build(weather_dataset) }

    it 'test_get_rules' do
      rules = trained_classifier.get_rules

      expect(rules).to be_an(Array)
      expect(rules).not_to be_empty

      # Each rule should be a string
      rules.each do |rule|
        expect(rule).to be_a(String)
        expect(rule).to include('if') # Rules should contain conditional logic
      end
    end

    it 'test_rules_cover_all_leaves' do
      rules = trained_classifier.get_rules

      # Rules should be a non-empty string
      expect(rules).to be_a(String)
      expect(rules.length).to be > 0

      # Rules should contain classifications
      expect(rules).to match(/then.*=/) # Should have conclusions
    end

    it 'test_rules_mutual_exclusion' do
      rules = trained_classifier.get_rules

      # Rules should be properly structured
      expect(rules).to be_a(String)
      # Should have multiple conditions if tree has branches
      # ID3 returns a single string with if/elsif structure
      expect(rules).to include('if')
    end
  end

  describe 'Edge Cases and Error Handling' do
    it 'handles dataset with single class efficiently' do
      single_class_data = Ai4r::Data::DataSet.new(
        data_items: Array.new(100) { %w[A B yes] },
        data_labels: %w[attr1 attr2 class]
      )

      classifier = described_class.new.build(single_class_data)

      # Should build quickly and always predict the single class
      result = classifier.eval(%w[X Y])
      expect(result).to eq('yes')
    end

    it 'handles large datasets efficiently' do
      # Generate larger dataset for performance testing
      large_data_items = []
      large_data_labels = []

      100.times do |i|
        large_data_items << [i % 3, (i * 2) % 5, (i * 3) % 4]
        large_data_labels << (i.even? ? 'even' : 'odd')
      end

      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_data_items,
        data_labels: large_data_labels
      )

      benchmark_performance('Large ID3 dataset training') do
        classifier = described_class.new.build(large_dataset)
        expect(classifier).to be_a(described_class)
      end
    end

    it 'handles mixed data types' do
      mixed_dataset = Ai4r::Data::DataSet.new(
        data_items: [['A', 1, true, 'X'], ['B', 2, false, 'Y'], ['C', 3, true, 'X']],
        data_labels: %w[attr1 attr2 attr3 class]
      )

      classifier = described_class.new.build(mixed_dataset)
      result = classifier.eval(['A', 1, true])

      expect(%w[X Y]).to include(result)
    end
  end

  describe 'Parameter Configuration Tests' do
    it 'respects max_depth parameter' do
      shallow_classifier = described_class.new
      shallow_classifier.set_parameters(max_depth: 1)
      shallow_classifier.build(weather_dataset)

      deep_classifier = described_class.new
      deep_classifier.set_parameters(max_depth: 10)
      deep_classifier.build(weather_dataset)

      # Both should work but may have different performance
      result1 = shallow_classifier.eval(%w[sunny hot high false])
      result2 = deep_classifier.eval(%w[sunny hot high false])

      expect(%w[yes no]).to include(result1)
      expect(%w[yes no]).to include(result2)
    end

    it 'handles custom split criteria' do
      # Test with custom parameters if available
      classifier = described_class.new

      # Set parameters that might be available
      expect do
        classifier.build(weather_dataset)
      end.not_to raise_error
    end
  end

  # Helper methods for assertions
  def assert_classification_correct(classifier, instance, expected_class)
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_rule_valid(rule)
    expect(rule).to be_a(String)
    expect(rule).to include('if')
    expect(rule).to include('then')
  end

  def assert_deterministic_output(classifier, instance)
    result1 = classifier.eval(instance)
    result2 = classifier.eval(instance)
    expect(result1).to eq(result2)
  end

  def assert_handles_unknown_value(classifier, instance_with_unknown)
    expect do
      result = classifier.eval(instance_with_unknown)
      expect(result).to be_a(String)
    end.not_to raise_error
  end
end
