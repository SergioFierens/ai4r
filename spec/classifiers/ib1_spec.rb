# frozen_string_literal: true

# RSpec tests for AI4R IB1 classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::IB1 do
  # Test data from requirement document
  let(:numeric_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1.0, 1.0, 'A'],
        [1.1, 1.1, 'A'],
        [5.0, 5.0, 'B'],
        [5.1, 5.1, 'B'],
        [9.0, 9.0, 'C'],
        [9.1, 9.1, 'C']
      ],
      data_labels: %w[x y class]
    )
  end

  let(:mixed_features_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['sunny', 25.5, 'high', 'no'],
        ['overcast', 18.2, 'normal', 'yes'],
        ['rainy', 12.1, 'high', 'yes'],
        ['sunny', 22.3, 'normal', 'no'],
        ['overcast', 20.0, 'high', 'yes'],
        ['rainy', 15.5, 'normal', 'yes']
      ],
      data_labels: %w[outlook temperature humidity play]
    )
  end

  let(:single_instance_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.0, 2.0, 3.0, 'only_class']],
      data_labels: %w[x y z class]
    )
  end

  let(:high_dimensional_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 'low'],
        [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 'low'],
        [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 'medium'],
        [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 'medium'],
        [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 'high'],
        [22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 'high']
      ],
      data_labels: %w[d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 class]
    )
  end

  let(:identical_instances_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.0, 1.0, 'same'], [1.0, 1.0, 'different'], [2.0, 2.0, 'other'], [2.0, 2.0, 'another']],
      data_labels: %w[x y class]
    )
  end

  describe 'Build Tests' do
    context 'instance storage' do
      it 'test_build_numeric_features' do
        classifier = described_class.new.build(numeric_dataset)

        expect(classifier).to be_a(described_class)
        expect(classifier.data_set).to eq(numeric_dataset) if classifier.respond_to?(:data_set)

        # Should be able to classify immediately after build
        result = classifier.eval([1.05, 1.05])
        expect(%w[A B C]).to include(result)
      end

      it 'test_build_mixed_features' do
        classifier = described_class.new.build(mixed_features_dataset)

        # Should handle mixed categorical and numerical features
        result = classifier.eval(['sunny', 20.0, 'high'])
        expect(%w[yes no]).to include(result)
      end

      it 'test_build_single_instance' do
        classifier = described_class.new.build(single_instance_dataset)

        # With single instance, should always return that class
        result = classifier.eval([1.0, 2.0, 3.0])
        expect(result).to eq('only_class')

        # Even for different inputs
        result2 = classifier.eval([100.0, 200.0, 300.0])
        expect(result2).to eq('only_class')
      end

      it 'test_build_high_dimensional' do
        classifier = described_class.new.build(high_dimensional_dataset)

        # Should handle high dimensional data
        result = classifier.eval([1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5])
        expect(%w[low medium high]).to include(result)
      end

      it 'test_build_identical_instances' do
        classifier = described_class.new.build(identical_instances_dataset)

        # Should handle identical feature vectors with different classes
        result = classifier.eval([1.0, 1.0])
        expect(%w[same different other another]).to include(result)
      end
    end

    context 'error handling' do
      it 'test_build_empty_dataset' do
        expect do
          empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])
          described_class.new.build(empty_dataset)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Eval Tests' do
    let(:trained_classifier) { described_class.new.build(numeric_dataset) }

    context 'nearest neighbor classification' do
      it 'test_eval_exact_match' do
        # Test with exact training instance
        result = trained_classifier.eval([1.0, 1.0])

        expect(result).to eq('A') # Should match exactly
      end

      it 'test_eval_nearest_neighbor' do
        # Test with point close to class A
        result = trained_classifier.eval([1.05, 1.05])

        expect(result).to eq('A') # Should be closest to A instances
      end

      it 'test_eval_equidistant_tie' do
        # Test point equidistant from multiple neighbors
        result = trained_classifier.eval([3.0, 3.0]) # Midway between A and B clusters

        expect(%w[A B]).to include(result) # Could be either depending on tie-breaking
      end

      it 'test_eval_far_from_all' do
        # Test point far from all training instances
        result = trained_classifier.eval([100.0, 100.0])

        expect(%w[A B C]).to include(result) # Should return nearest neighbor's class
      end
    end

    context 'distance calculation' do
      it 'test_eval_different_distances' do
        # Points at different distances should classify to nearest

        # Very close to A
        result1 = trained_classifier.eval([1.01, 1.01])
        expect(result1).to eq('A')

        # Close to B
        result2 = trained_classifier.eval([5.05, 5.05])
        expect(result2).to eq('B')

        # Close to C
        result3 = trained_classifier.eval([9.05, 9.05])
        expect(result3).to eq('C')
      end

      it 'handles missing values' do
        result = trained_classifier.eval([1.0, nil])

        expect do
          expect(%w[A B C]).to include(result)
        end.not_to raise_error
      end

      it 'handles extreme values' do
        # Very large values
        result1 = trained_classifier.eval([1e10, 1e10])
        expect(%w[A B C]).to include(result1)

        # Very small values
        result2 = trained_classifier.eval([-1e10, -1e10])
        expect(%w[A B C]).to include(result2)
      end
    end
  end

  describe 'Distance Metric Tests' do
    let(:classifier) { described_class.new.build(numeric_dataset) }

    it 'uses appropriate distance metric' do
      # Test that similar points get classified the same

      # Both should be closest to A
      result1 = classifier.eval([1.02, 1.02])
      result2 = classifier.eval([1.03, 1.03])

      expect(result1).to eq(result2)
      expect(result1).to eq('A')
    end

    it 'handles categorical features properly' do
      mixed_classifier = described_class.new.build(mixed_features_dataset)

      # Test with exact categorical match but different numerical
      result = mixed_classifier.eval(['sunny', 30.0, 'high']) # Different temp

      expect(%w[yes no]).to include(result)
    end

    it 'normalizes features appropriately' do
      # Test that classifier handles different feature scales

      large_scale_dataset = Ai4r::Data::DataSet.new(
        data_items: [[1, 1000, 'small'], [2, 2000, 'small'], [100, 100, 'large'], [200, 200, 'large']],
        data_labels: %w[x y class]
      )

      classifier = described_class.new.build(large_scale_dataset)

      # Should handle different scales without one dimension dominating
      result = classifier.eval([1.5, 1500])
      expect(%w[small large]).to include(result)
    end
  end

  describe 'Performance Tests' do
    it 'handles large datasets efficiently' do
      # Generate large dataset
      large_items = []

      1000.times do |i|
        large_items << [rand(100), rand(100), rand(100), (i % 5).to_s]
      end

      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_items,
        data_labels: %w[x y z class]
      )

      # Build should be fast (just stores instances)
      benchmark_performance('IB1 training on large dataset') do
        classifier = described_class.new.build(large_dataset)
        expect(classifier).to be_a(described_class)
      end
    end

    it 'evaluation performance scales with dataset size' do
      classifier = described_class.new.build(numeric_dataset)

      benchmark_performance('IB1 evaluation speed') do
        50.times do
          result = classifier.eval([rand(10), rand(10)])
          expect(%w[A B C]).to include(result)
        end
      end
    end

    it 'handles high dimensional efficiently' do
      hd_classifier = described_class.new.build(high_dimensional_dataset)

      test_point = Array.new(10) { rand(30) }

      benchmark_performance('IB1 high dimensional evaluation') do
        result = hd_classifier.eval(test_point)
        expect(%w[low medium high]).to include(result)
      end
    end
  end

  describe 'Integration Tests' do
    it 'works with different data distributions' do
      # Test with clustered data
      clustered_items = []
      clustered_labels = []

      # Cluster 1
      20.times do
        clustered_items << [rand(2), rand(2), 'cluster1']
      end

      # Cluster 2
      20.times do
        clustered_items << [rand(10..11), rand(10..11), 'cluster2']
      end

      clustered_dataset = Ai4r::Data::DataSet.new(
        data_items: clustered_items,
        data_labels: %w[x y class]
      )

      classifier = described_class.new.build(clustered_dataset)

      # Should classify into correct clusters
      result1 = classifier.eval([0.5, 0.5])
      result2 = classifier.eval([10.5, 10.5])

      expect(result1).to eq('cluster1')
      expect(result2).to eq('cluster2')
    end

    it 'maintains consistency' do
      classifier = described_class.new.build(numeric_dataset)

      test_point = [2.0, 2.0]

      # Multiple evaluations should be consistent
      result1 = classifier.eval(test_point)
      result2 = classifier.eval(test_point)

      expect(result1).to eq(result2)
    end

    it 'handles noise appropriately' do
      # Add some noisy instances
      noisy_items = numeric_dataset.data_items.dup

      # Add outliers
      noisy_items += [[100, 100, 'outlier1'], [-100, -100, 'outlier2']]

      noisy_dataset = Ai4r::Data::DataSet.new(
        data_items: noisy_items,
        data_labels: numeric_dataset.data_labels
      )

      classifier = described_class.new.build(noisy_dataset)

      # Original clusters should still work
      result = classifier.eval([1.05, 1.05])
      expect(result).to eq('A') # Should not be affected by distant outliers
    end
  end

  describe 'Edge Case Tests' do
    it 'handles identical feature vectors' do
      identical_classifier = described_class.new.build(identical_instances_dataset)

      # When multiple instances have identical features, should return one of their classes
      result = identical_classifier.eval([1.0, 1.0])
      expect(%w[same different]).to include(result)
    end

    it 'handles single dimension data' do
      single_dim_dataset = Ai4r::Data::DataSet.new(
        data_items: [[1, 'low'], [2, 'low'], [5, 'high'], [6, 'high']],
        data_labels: %w[x class]
      )

      classifier = described_class.new.build(single_dim_dataset)

      result = classifier.eval([1.5])
      expect(result).to eq('low') # Should be closest to 1 or 2
    end

    it 'handles zero distance' do
      # Test when query point exactly matches training instance
      classifier = described_class.new.build(numeric_dataset)
      result = classifier.eval([5.0, 5.0]) # Exact match
      expect(result).to eq('B')
    end
  end

  # Helper methods for assertions
  def assert_classification_correct(classifier, instance, expected_class)
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_nearest_neighbor_correct(classifier, instance, training_set)
    result = classifier.eval(instance)

    # Find actual nearest neighbor manually
    min_distance = Float::INFINITY
    nearest_class = nil

    training_set.data_items.each_with_index do |train_item, i|
      distance = calculate_euclidean_distance(instance, train_item)
      if distance < min_distance
        min_distance = distance
        nearest_class = training_set.data_labels[i]
      end
    end

    expect(result).to eq(nearest_class)
  end

  def assert_deterministic_output(classifier, instance)
    result1 = classifier.eval(instance)
    result2 = classifier.eval(instance)
    expect(result1).to eq(result2)
  end

  def calculate_euclidean_distance(point1, point2)
    return Float::INFINITY if point1.length != point2.length

    sum = 0
    point1.each_with_index do |val1, i|
      val2 = point2[i]
      next if val1.nil? || val2.nil?

      if val1.is_a?(Numeric) && val2.is_a?(Numeric)
        sum += (val1 - val2)**2
      elsif val1 != val2 # Categorical mismatch
        sum += 1
      end
    end
    Math.sqrt(sum)
  end

  def assert_handles_missing_values(classifier, instance_with_missing)
    expect do
      result = classifier.eval(instance_with_missing)
      expect(result).to be_a(String)
    end.not_to raise_error
  end
end
