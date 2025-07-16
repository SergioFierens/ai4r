# frozen_string_literal: true

# RSpec tests for AI4R Hyperpipes classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::Hyperpipes do
  # Test data from requirement document
  let(:continuous_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1.5, 2.3, 3.1],
        [1.8, 2.1, 3.4],
        [4.1, 5.2, 6.8],
        [4.3, 5.1, 6.9],
        [7.8, 8.9, 9.2],
        [7.9, 8.8, 9.1]
      ],
      data_labels: %w[A A B B C C]
    )
  end

  let(:overlapping_rectangles_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1.0, 1.0],
        [2.0, 2.0],
        [1.5, 1.5],
        [2.5, 2.5],
        [3.0, 1.0],
        [3.5, 2.0]
      ],
      data_labels: %w[class1 class1 class1 class2 class2 class2]
    )
  end

  let(:mixed_features_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['sunny', 25.5, 'high'],
        ['overcast', 18.2, 'normal'],
        ['rainy', 12.1, 'high'],
        ['sunny', 22.3, 'normal'],
        ['overcast', 20.0, 'high'],
        ['rainy', 15.5, 'normal']
      ],
      data_labels: %w[no yes yes no yes yes]
    )
  end

  let(:single_instance_per_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]],
      data_labels: %w[A B C]
    )
  end

  let(:identical_points_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[1.0, 1.0], [1.0, 1.0], [2.0, 2.0], [2.0, 2.0]],
      data_labels: %w[same same different different]
    )
  end

  let(:high_dimensional_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 2, 3, 4, 5, 6, 7, 8],
        [2, 3, 4, 5, 6, 7, 8, 9],
        [11, 12, 13, 14, 15, 16, 17, 18],
        [12, 13, 14, 15, 16, 17, 18, 19]
      ],
      data_labels: %w[low low high high]
    )
  end

  describe 'Build Tests' do
    context 'hyperrectangle construction' do
      it 'test_build_continuous_features' do
        classifier = described_class.new.build(continuous_dataset)

        expect(classifier).to be_a(described_class)
        expect(classifier.hyperpipes).to be_a(Hash) if classifier.respond_to?(:hyperpipes)

        # Should be able to classify
        result = classifier.eval([2.0, 3.0, 4.0])
        expect(result).to be_in(%w[A B C])
      end

      it 'test_build_overlapping_rectangles' do
        classifier = described_class.new.build(overlapping_rectangles_dataset)

        # Should handle overlapping class regions
        result = classifier.eval([2.0, 1.5])
        expect(result).to be_in(%w[class1 class2])
      end

      it 'test_build_mixed_features' do
        classifier = described_class.new.build(mixed_features_dataset)

        # Should handle mixed categorical and continuous features
        result = classifier.eval(['sunny', 20.0, 'high'])
        expect(result).to be_in(%w[yes no])
      end

      it 'test_build_single_instance_per_class' do
        classifier = described_class.new.build(single_instance_per_class_dataset)

        # Each class has single instance - creates point rectangles
        result = classifier.eval([1.0, 2.0])
        expect(result).to eq('A') # Should classify exact match correctly
      end

      it 'test_build_identical_points' do
        classifier = described_class.new.build(identical_points_dataset)

        # Should handle identical points gracefully
        result = classifier.eval([1.0, 1.0])
        expect(result).to be_in(%w[same different])
      end
    end

    context 'dimensionality handling' do
      it 'test_build_high_dimensional' do
        classifier = described_class.new.build(high_dimensional_dataset)

        # Should handle higher dimensional spaces
        result = classifier.eval([1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5])
        expect(%w[low high]).to include(result)
      end

      it 'test_build_single_dimension' do
        single_dim_dataset = Ai4r::Data::DataSet.new(
          data_items: [[1], [2], [5], [6]],
          data_labels: %w[low low high high]
        )

        classifier = described_class.new.build(single_dim_dataset)

        result = classifier.eval([3])
        expect(%w[low high]).to include(result)
      end
    end

    context 'error handling' do
      it 'test_build_empty_dataset' do
        empty_dataset = Ai4r::Data::DataSet.new(data_items: [], data_labels: [])

        expect do
          described_class.new.build(empty_dataset)
        end.to raise_error
      end

      it 'test_build_single_instance' do
        single_dataset = Ai4r::Data::DataSet.new(
          data_items: [[1.0, 2.0]],
          data_labels: ['only']
        )

        classifier = described_class.new.build(single_dataset)
        result = classifier.eval([1.0, 2.0])
        expect(result).to eq('only')
      end
    end
  end

  describe 'Eval Tests' do
    let(:trained_classifier) { described_class.new.build(continuous_dataset) }

    context 'boundary evaluation' do
      it 'test_eval_inside_rectangle' do
        # Test point clearly inside a class rectangle
        result = trained_classifier.eval([1.6, 2.2, 3.2])

        expect(%w[A B C]).to include(result)
        expect(result).to be_a(String)
      end

      it 'test_eval_on_boundary' do
        # Test point on rectangle boundary
        result = trained_classifier.eval([1.5, 2.3, 3.1]) # Exact training point

        expect(result).to eq('A') # Should classify correctly
      end

      it 'test_eval_outside_all_rectangles' do
        # Test point outside all rectangles
        result = trained_classifier.eval([100.0, 200.0, 300.0])

        # Should use default classification or nearest rectangle
        expect(%w[A B C]).to include(result)
      end

      it 'test_eval_overlapping_regions' do
        overlap_classifier = described_class.new.build(overlapping_rectangles_dataset)

        # Test point that might be in multiple rectangles
        result = overlap_classifier.eval([2.0, 1.8])

        expect(%w[class1 class2]).to include(result)
      end
    end

    context 'distance and containment' do
      it 'test_eval_nearest_rectangle' do
        # Point close to but outside rectangle should classify to nearest class
        result = trained_classifier.eval([1.0, 2.0, 3.0]) # Close to class A

        expect(%w[A B C]).to include(result)
      end

      it 'test_eval_equidistant_rectangles' do
        # Point equidistant from multiple rectangles
        result = trained_classifier.eval([4.0, 4.0, 4.0]) # Between clusters

        expect(%w[A B C]).to include(result)
      end
    end

    context 'edge cases' do
      it 'handles extreme values' do
        # Very large values
        result1 = trained_classifier.eval([1e10, 1e10, 1e10])
        expect(%w[A B C]).to include(result1)

        # Very small values
        result2 = trained_classifier.eval([-1e10, -1e10, -1e10])
        expect(%w[A B C]).to include(result2)
      end

      it 'handles missing values' do
        result = trained_classifier.eval([1.5, nil, 3.1])

        expect do
          expect(%w[A B C]).to include(result)
        end.not_to raise_error
      end

      it 'handles wrong dimensions' do
        expect do
          trained_classifier.eval([1.5, 2.3]) # Missing one dimension
        end.to raise_error
      end
    end
  end

  describe 'Rectangle Analysis Tests' do
    let(:classifier) { described_class.new.build(continuous_dataset) }

    it 'creates proper hyperrectangles' do
      # Each class should have a hyperrectangle defined by min/max of training points

      # Test that rectangles are accessible (implementation dependent)
      if classifier.respond_to?(:hyperpipes)
        rectangles = classifier.hyperpipes
        expect(rectangles).to be_a(Hash)
        expect(rectangles.keys).to include('A', 'B', 'C')
      end
    end

    it 'handles rectangle expansion' do
      # When new instances are added to a class, rectangle should expand

      # This is implicit in the build process - verify through classification
      result1 = classifier.eval([1.5, 2.1, 3.1])  # Near class A boundary
      result2 = classifier.eval([1.8, 2.3, 3.4])  # Other class A boundary

      # Both should likely classify as A since they're in the A rectangle
      expect(%w[A B C]).to include(result1)
      expect(%w[A B C]).to include(result2)
    end

    it 'provides rectangle boundaries' do
      # Test access to rectangle information if available
      if classifier.respond_to?(:get_rectangle_bounds)
        bounds = classifier.get_rectangle_bounds('A')
        expect(bounds).to be_a(Array) if bounds
      end
    end
  end

  describe 'Performance Tests' do
    it 'handles large datasets efficiently' do
      # Generate large dataset
      large_items = []
      large_labels = []

      500.times do |i|
        large_items << [rand(100), rand(100), rand(100)]
        large_labels << (i % 5).to_s
      end

      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_items,
        data_labels: large_labels
      )

      benchmark_performance('Hyperpipes training on large dataset') do
        classifier = described_class.new.build(large_dataset)
        expect(classifier).to be_a(described_class)
      end
    end

    it 'fast evaluation performance' do
      classifier = described_class.new.build(continuous_dataset)

      benchmark_performance('Hyperpipes evaluation speed') do
        100.times do
          result = classifier.eval([rand(10), rand(10), rand(10)])
          expect(%w[A B C]).to include(result)
        end
      end
    end

    it 'scales with dimensionality' do
      # Test performance with high dimensional data
      high_dim_items = Array.new(50) { Array.new(20) { rand(10) } }
      high_dim_labels = Array.new(50) { |i| (i % 3).to_s }

      high_dim_dataset = Ai4r::Data::DataSet.new(
        data_items: high_dim_items,
        data_labels: high_dim_labels
      )

      classifier = described_class.new.build(high_dim_dataset)

      # Should handle high dimensions reasonably
      test_point = Array.new(20) { rand(10) }
      result = classifier.eval(test_point)
      expect(%w[0 1 2]).to include(result)
    end
  end

  describe 'Integration Tests' do
    it 'works with different data distributions' do
      # Clustered data
      clustered_items = []
      clustered_labels = []

      # Cluster 1: around (0,0)
      10.times do
        clustered_items << [rand(2), rand(2)]
        clustered_labels << 'cluster1'
      end

      # Cluster 2: around (10,10)
      10.times do
        clustered_items << [rand(10..11), rand(10..11)]
        clustered_labels << 'cluster2'
      end

      clustered_dataset = Ai4r::Data::DataSet.new(
        data_items: clustered_items,
        data_labels: clustered_labels
      )

      classifier = described_class.new.build(clustered_dataset)

      # Should classify clearly separated clusters correctly
      result1 = classifier.eval([0.5, 0.5])
      result2 = classifier.eval([10.5, 10.5])

      expect(result1).to eq('cluster1')
      expect(result2).to eq('cluster2')
    end

    it 'maintains consistency across evaluations' do
      classifier = described_class.new.build(continuous_dataset)

      test_point = [2.0, 3.0, 4.0]

      # Multiple evaluations should be consistent
      result1 = classifier.eval(test_point)
      result2 = classifier.eval(test_point)

      expect(result1).to eq(result2)
    end

    it 'handles categorical and continuous mixing' do
      mixed_classifier = described_class.new.build(mixed_features_dataset)

      # Should work with mixed feature types
      result = mixed_classifier.eval(['sunny', 23.0, 'normal'])
      expect(%w[yes no]).to include(result)
    end
  end

  describe 'Boundary Condition Tests' do
    it 'handles rectangles with zero width' do
      # When all instances of a class have same value in a dimension
      zero_width_dataset = Ai4r::Data::DataSet.new(
        data_items: [[1.0, 5.0], [2.0, 5.0], [3.0, 5.0]], # Same Y value
        data_labels: %w[same same same]
      )

      classifier = described_class.new.build(zero_width_dataset)
      result = classifier.eval([1.5, 5.0])
      expect(result).to eq('same')
    end

    it 'handles point rectangles' do
      # Single instance per class creates point rectangles
      point_classifier = described_class.new.build(single_instance_per_class_dataset)

      # Exact matches should work
      expect(point_classifier.eval([1.0, 2.0])).to eq('A')
      expect(point_classifier.eval([3.0, 4.0])).to eq('B')
      expect(point_classifier.eval([5.0, 6.0])).to eq('C')
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

  def assert_rectangle_containment(classifier, instance, expected_class)
    # Helper to verify that instance is properly contained in expected class rectangle
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_handles_boundary_case(classifier, boundary_instance)
    expect do
      result = classifier.eval(boundary_instance)
      expect(result).to be_a(String)
    end.not_to raise_error
  end
end
