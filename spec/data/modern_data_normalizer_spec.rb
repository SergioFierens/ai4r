# frozen_string_literal: true

# RSpec tests for AI4R Modern Data Normalizer
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe 'Modern Data Normalizer' do
  before(:all) do
    require_relative '../../lib/ai4r/data/modern_data_normalizer'
    require_relative '../../lib/ai4r/data/data_set'
  end

  let(:sample_data) do
    [
      [10, 100, 1000],
      [20, 200, 2000],
      [30, 300, 3000],
      [40, 400, 4000],
      [50, 500, 5000]
    ]
  end

  let(:sample_labels) { %w[small medium large] }
  let(:dataset) { Ai4r::Data::DataSet.new(data_items: sample_data, data_labels: sample_labels) }
  let(:normalizer) { Ai4r::Data::ModernDataNormalizer.new(dataset, config: @educational_config) }

  describe Ai4r::Data::ModernDataNormalizer do
    describe '#initialize' do
      it 'creates normalizer with dataset and configuration' do
        expect(normalizer).to be_a(described_class)
        expect(normalizer.instance_variable_get(:@dataset)).to eq(dataset)
        expect(normalizer.instance_variable_get(:@config)).to eq(@educational_config)
      end

      it 'initializes empty normalization history' do
        history = normalizer.instance_variable_get(:@normalization_history)
        expect(history).to be_empty
      end
    end

    describe '.build (Builder Pattern)' do
      it 'creates a normalization builder' do
        builder = described_class.build(dataset)
        expect(builder).to be_a(described_class::NormalizationBuilder)
      end

      it 'supports fluent interface' do
        expect do
          described_class.build(dataset)
            .min_max(range: [0, 100])
            .columns('small', 'medium')
            .skip_validation
            .explain_steps
        end.not_to raise_error
      end
    end

    describe '#normalize' do
      context 'min_max normalization' do
        it 'normalizes data to [0,1] range by default' do
          result = normalizer.normalize(sample_data, method: :min_max)

          expect(result).to be_an(Array)
          expect(result.length).to eq(sample_data.length)

          # Check first column normalization
          first_column = result.map { |row| row[0] }
          expect(first_column.min).to be_approximately(0.0, 0.01)
          expect(first_column.max).to be_approximately(1.0, 0.01)
        end

        it 'normalizes to custom range' do
          result = normalizer.normalize(sample_data, method: :min_max, target_range: [10, 20])

          first_column = result.map { |row| row[0] }
          expect(first_column.min).to be_approximately(10.0, 0.01)
          expect(first_column.max).to be_approximately(20.0, 0.01)
        end

        it 'handles constant values' do
          constant_data = [[5, 5, 5], [5, 5, 5], [5, 5, 5]]
          result = normalizer.normalize(constant_data, method: :min_max)

          first_column = result.map { |row| row[0] }
          expect(first_column.uniq).to eq([0.5]) # Should be midpoint of range
        end

        it 'preserves non-numeric values' do
          mixed_data = [['A', 10], ['B', 20], ['C', 30]]
          result = normalizer.normalize(mixed_data, method: :min_max)

          # String values should be preserved
          expect(result.map { |row| row[0] }).to eq(%w[A B C])
        end
      end

      context 'z_score normalization' do
        it 'standardizes data to mean=0, std=1' do
          result = normalizer.normalize(sample_data, method: :z_score)

          first_column = result.map { |row| row[0] }
          mean = first_column.sum / first_column.length
          variance = first_column.sum { |x| (x - mean)**2 } / first_column.length
          std = Math.sqrt(variance)

          expect(mean).to be_approximately(0.0, 0.01)
          expect(std).to be_approximately(1.0, 0.01)
        end

        it 'uses custom target mean and std' do
          result = normalizer.normalize(sample_data, method: :z_score, target_mean: 50, target_std: 10)

          first_column = result.map { |row| row[0] }
          mean = first_column.sum / first_column.length
          variance = first_column.sum { |x| (x - mean)**2 } / first_column.length
          std = Math.sqrt(variance)

          expect(mean).to be_approximately(50.0, 0.01)
          expect(std).to be_approximately(10.0, 0.01)
        end

        it 'handles constant values' do
          constant_data = [[5, 5, 5], [5, 5, 5], [5, 5, 5]]
          result = normalizer.normalize(constant_data, method: :z_score)

          first_column = result.map { |row| row[0] }
          expect(first_column.uniq).to eq([0.0]) # Should be target mean
        end
      end

      context 'robust normalization' do
        it 'uses median and IQR for normalization' do
          result = normalizer.normalize(sample_data, method: :robust)

          expect(result).to be_an(Array)
          expect(result.length).to eq(sample_data.length)

          # Check that median becomes 0
          result.map { |row| row[0] }
          sorted_original = sample_data.map { |row| row[0] }.sort
          original_median = sorted_original[sorted_original.length / 2]

          # The median value should be close to 0 after robust normalization
          median_index = sample_data.map { |row| row[0] }.index(original_median)
          expect(result[median_index][0]).to be_approximately(0.0, 0.01)
        end

        it 'is less sensitive to outliers' do
          outlier_data = sample_data + [[1000, 10_000, 100_000]] # Extreme outlier

          robust_result = normalizer.normalize(outlier_data, method: :robust)
          z_score_result = normalizer.normalize(outlier_data, method: :z_score)

          # Robust normalization should be less affected by the outlier
          robust_std = calculate_std(robust_result.map { |row| row[0] })
          z_score_std = calculate_std(z_score_result.map { |row| row[0] })

          expect(robust_std).to be < z_score_std * 1.5 # Should be more stable
        end
      end

      context 'unit_vector normalization' do
        it 'normalizes rows to unit length' do
          result = normalizer.normalize(sample_data, method: :unit_vector)

          result.each do |row|
            numeric_values = row.select { |v| v.is_a?(Numeric) }
            norm = Math.sqrt(numeric_values.sum { |v| v**2 })
            expect(norm).to be_approximately(1.0, 0.01)
          end
        end

        it 'supports different norm types' do
          l1_result = normalizer.normalize(sample_data, method: :unit_vector, norm_type: :l1)
          l2_result = normalizer.normalize(sample_data, method: :unit_vector, norm_type: :l2)
          max_result = normalizer.normalize(sample_data, method: :unit_vector, norm_type: :max)

          expect(l1_result).not_to eq(l2_result)
          expect(l2_result).not_to eq(max_result)
        end

        it 'handles zero vectors' do
          zero_data = [[0, 0, 0], [1, 2, 3]]
          result = normalizer.normalize(zero_data, method: :unit_vector)

          expect(result[0]).to eq([0, 0, 0]) # Zero vector remains unchanged
        end
      end

      context 'quantile_uniform normalization' do
        it 'maps values to uniform distribution' do
          result = normalizer.normalize(sample_data, method: :quantile_uniform)

          first_column = result.map { |row| row[0] }
          expect(first_column.min).to be >= 0.0
          expect(first_column.max).to be <= 1.0
          expect(first_column.sort).to eq(first_column.sort.uniq) # Should be monotonic
        end

        it 'handles duplicate values' do
          duplicate_data = [[1, 10], [1, 10], [2, 20], [3, 30]]
          result = normalizer.normalize(duplicate_data, method: :quantile_uniform)

          # Duplicate values should get same normalized value
          expect(result[0][0]).to eq(result[1][0])
        end
      end

      context 'column selection' do
        it 'normalizes specific columns' do
          result = normalizer.normalize(sample_data, method: :min_max, columns: ['small'])

          # Only first column should be normalized
          first_column = result.map { |row| row[0] }
          second_column = result.map { |row| row[1] }

          expect(first_column.min).to be_approximately(0.0, 0.01)
          expect(second_column).to eq([100, 200, 300, 400, 500]) # Unchanged
        end

        it 'handles invalid column names' do
          expect do
            normalizer.normalize(sample_data, method: :min_max, columns: ['invalid'])
          end.to raise_error(Ai4r::Data::NormalizationError) do |error|
            expect(error.message).to include('Invalid columns: invalid')
            expect(error.message).to include('Available columns:')
          end
        end
      end

      context 'validation' do
        it 'validates input data' do
          expect do
            normalizer.normalize([], method: :min_max)
          end.to raise_error(Ai4r::Data::NormalizationError) do |error|
            expect(error.message).to include('Invalid data items')
          end
        end

        it 'validates normalization method' do
          expect do
            normalizer.normalize(sample_data, method: :invalid_method)
          end.to raise_error(Ai4r::Data::NormalizationError) do |error|
            expect(error.message).to include('Unknown normalization method: invalid_method')
            expect(error.message).to include('Try :min_max')
          end
        end
      end
    end

    describe '#normalize_lazily' do
      it 'processes data in chunks' do
        large_data = build(:large_dataset)[:data_items]

        lazy_enumerator = normalizer.normalize_lazily(large_data, method: :min_max, chunk_size: 100)

        expect(lazy_enumerator).to be_a(Enumerator)

        # Process first chunk
        first_chunk = lazy_enumerator.next
        expect(first_chunk).to be_an(Array)
        expect(first_chunk.length).to be <= 100
      end

      it 'maintains consistency across chunks' do
        test_data = Array.new(200) { |i| [i, i * 2] }

        lazy_enumerator = normalizer.normalize_lazily(test_data, method: :min_max, chunk_size: 50)

        all_results = []
        lazy_enumerator.each { |chunk| all_results.concat(chunk) }

        # Should have same length as input
        expect(all_results.length).to eq(test_data.length)

        # First and last values should be properly normalized
        first_column = all_results.map { |row| row[0] }
        expect(first_column.min).to be_approximately(0.0, 0.01)
        expect(first_column.max).to be_approximately(1.0, 0.01)
      end
    end

    describe '#normalize_concurrently' do
      it 'processes data using multiple threads' do
        large_data = build(:large_dataset)[:data_items]

        benchmark_performance('Concurrent normalization') do
          normalizer.normalize_concurrently(large_data, method: :min_max, max_threads: 2)
        end
      end

      it 'produces same results as sequential processing' do
        test_data = Array.new(100) { |i| [i, i * 2] }

        sequential_result = normalizer.normalize(test_data, method: :min_max)
        concurrent_result = normalizer.normalize_concurrently(test_data, method: :min_max, max_threads: 2)

        # Results should be identical (order might differ due to concurrent processing)
        sequential_values = sequential_result.map { |row| row[0] }.sort
        concurrent_values = concurrent_result.map { |row| row[0] }.sort

        expect(concurrent_values).to be_approximately_equal_to(sequential_values)
      end
    end

    describe '#validate_normalization_properties' do
      it 'validates normalization properties' do
        properties = normalizer.validate_normalization_properties(method: :min_max)

        expect(properties).to be_a(Hash)
        expect(properties).to have_key(:preservation)
        expect(properties).to have_key(:reversibility)
        expect(properties).to have_key(:consistency)
        expect(properties).to have_key(:robustness)

        properties.each_value do |result|
          expect(result).to be_in([true, false])
        end
      end

      it 'tests order preservation' do
        monotonic_data = Array.new(20) { |i| [i] }
        test_normalizer = described_class.new(
          Ai4r::Data::DataSet.new(data_items: monotonic_data, data_labels: ['value']),
          config: @educational_config
        )

        properties = test_normalizer.validate_normalization_properties(method: :min_max)

        # Min-max should preserve order
        expect(properties[:preservation]).to be true
      end

      it 'tests consistency' do
        properties = normalizer.validate_normalization_properties(method: :z_score)

        # Deterministic algorithms should be consistent
        expect(properties[:consistency]).to be true
      end
    end

    describe '#normalization_history' do
      it 'tracks normalization operations' do
        normalizer.normalize(sample_data, method: :min_max)
        normalizer.normalize(sample_data, method: :z_score)

        history = normalizer.normalization_history
        expect(history).to have(2).items
        expect(history[0]).to include('min_max')
        expect(history[1]).to include('z_score')
      end

      it 'supports undo functionality' do
        expect(normalizer.can_undo?).to be false

        normalizer.normalize(sample_data, method: :min_max)
        expect(normalizer.can_undo?).to be true

        normalizer.undo_last_normalization
        expect(normalizer.normalization_history).to be_empty
      end
    end

    describe 'NormalizationBuilder' do
      let(:builder) { described_class.build(dataset) }

      describe 'fluent interface' do
        it 'supports method chaining' do
          result = builder.min_max(range: [0, 100])
            .columns('small', 'medium')
            .explain_steps
            .execute

          expect(result).to be_an(Array)
        end

        it 'supports different normalization methods' do
          expect(builder.min_max(range: [0, 1])).to be_a(described_class::NormalizationBuilder)
          expect(builder.z_score(mean: 0, std: 1)).to be_a(described_class::NormalizationBuilder)
          expect(builder.robust(scale_factor: 1.0)).to be_a(described_class::NormalizationBuilder)
          expect(builder.unit_vector(norm: :l2)).to be_a(described_class::NormalizationBuilder)
        end

        it 'supports configuration options' do
          expect(builder.skip_validation).to be_a(described_class::NormalizationBuilder)
          expect(builder.explain_steps).to be_a(described_class::NormalizationBuilder)
          expect(builder.preserve_columns('id')).to be_a(described_class::NormalizationBuilder)
        end
      end

      describe '#execute' do
        it 'executes the normalization pipeline' do
          result = builder.min_max.columns('small').execute

          expect(result).to be_an(Array)
          expect(result.length).to eq(sample_data.length)
        end

        it 'handles complex pipelines' do
          expect do
            builder.robust
              .columns('small', 'medium')
              .with_options(scale_factor: 2.0)
              .skip_validation
              .execute
          end.not_to raise_error
        end
      end
    end

    describe 'educational features' do
      let(:educational_config) { Ai4r::Data::EducationalConfig.beginner }
      let(:educational_normalizer) { described_class.new(dataset, config: educational_config) }

      it 'provides educational explanations' do
        expect do
          educational_normalizer.normalize(sample_data, method: :min_max)
        end.to output(/⚖️  Normalization Method: Min Max/).to_stdout
      end

      it 'explains why normalization is needed' do
        expect do
          educational_normalizer.normalize(sample_data, method: :min_max)
        end.to output(/💡 Why Normalize Data/).to_stdout
      end

      it 'shows normalization results' do
        expect do
          educational_normalizer.normalize(sample_data, method: :min_max)
        end.to output(/✅ Normalization Complete/).to_stdout
      end

      it 'provides data analysis before normalization' do
        expect do
          educational_normalizer.normalize_interactively(sample_data)
        end.to output(/📊 Data Analysis Results/).to_stdout
      end
    end

    describe 'performance characteristics' do
      let(:large_dataset) do
        large_data = build(:large_dataset)
        Ai4r::Data::DataSet.new(
          data_items: large_data[:data_items],
          data_labels: large_data[:data_labels]
        )
      end

      let(:large_normalizer) { described_class.new(large_dataset, config: @educational_config) }

      it 'handles large datasets efficiently' do
        benchmark_performance('Large dataset normalization') do
          large_normalizer.normalize(large_dataset.data_items, method: :min_max)
        end
      end

      it 'performs lazy normalization efficiently' do
        benchmark_performance('Lazy normalization') do
          enumerator = large_normalizer.normalize_lazily(large_dataset.data_items, method: :min_max, chunk_size: 1000)
          enumerator.first # Process first chunk
        end
      end
    end

    describe 'property-based testing' do
      it 'maintains data structure integrity' do
        expect(normalizer).to satisfy_property('structure integrity', 20) do |norm|
          result = norm.normalize(sample_data, method: :min_max)

          result.length == sample_data.length &&
            result.all? { |row| row.length == sample_data.first.length }
        end
      end

      it 'preserves order for monotonic methods' do
        sorted_data = Array.new(20) { |i| [i, i * 2] }
        sorted_normalizer = described_class.new(
          Ai4r::Data::DataSet.new(data_items: sorted_data, data_labels: %w[a b]),
          config: @educational_config
        )

        expect(sorted_normalizer).to satisfy_property('order preservation', 10) do |norm|
          result = norm.normalize(sorted_data, method: :min_max)

          first_column = result.map { |row| row[0] }
          first_column == first_column.sort
        end
      end

      it 'handles edge cases robustly' do
        edge_cases = [
          [[1], [2], [3]], # Single column
          [[1, 2], [1, 2], [1, 2]],          # Duplicate rows
          [[1, 2], [3, 4], [5, 6]],          # Small dataset
          [[nil, 2], [3, nil], [5, 6]]       # Missing values
        ]

        edge_cases.each do |test_data|
          test_normalizer = described_class.new(
            Ai4r::Data::DataSet.new(data_items: test_data, data_labels: %w[a b]),
            config: @educational_config
          )

          expect do
            test_normalizer.normalize(test_data, method: :min_max)
          end.not_to raise_error
        end
      end
    end

    describe 'educational error handling' do
      it 'provides helpful error messages' do
        expect do
          normalizer.normalize(sample_data, method: :invalid_method)
        end.to raise_error(Ai4r::Data::NormalizationError) do |error|
          expect(error.message).to include('Unknown normalization method')
          expect(error.message).to include('💡 Suggestions:')
          expect(error.message).to include('Try :min_max')
        end
      end

      it 'provides context for validation errors' do
        expect do
          normalizer.normalize([], method: :min_max)
        end.to raise_error(Ai4r::Data::NormalizationError) do |error|
          expect(error.message).to include('Invalid data items')
          expect(error.message).to include('Check data format')
        end
      end
    end

    describe 'method configurations' do
      it 'provides method information' do
        expect(described_class::NORMALIZATION_METHODS).to have_key(:min_max)
        expect(described_class::NORMALIZATION_METHODS).to have_key(:z_score)
        expect(described_class::NORMALIZATION_METHODS).to have_key(:robust)

        min_max_config = described_class::NORMALIZATION_METHODS[:min_max]
        expect(min_max_config).to have_key(:description)
        expect(min_max_config).to have_key(:use_cases)
        expect(min_max_config).to have_key(:sensitivity_to_outliers)
      end

      it 'supports method selection by characteristics' do
        outlier_prone_data = build(:normalization_test_data, distribution: :skewed)

        # Robust method should be recommended for outlier-prone data
        analysis = normalizer.send(:analyze_data_characteristics, outlier_prone_data.zip)
        recommendations = normalizer.send(:recommend_normalization_methods, analysis)

        expect(recommendations.any? { |r| r[:method] == :robust }).to be true
      end
    end

    # Helper method for testing
    def calculate_std(values)
      mean = values.sum / values.length
      variance = values.sum { |v| (v - mean)**2 } / values.length
      Math.sqrt(variance)
    end

    # Custom matcher for approximate array equality
    def be_approximately_equal_to(expected, delta = 0.01)
      satisfy do |actual|
        expected.zip(actual).all? do |exp, act|
          (exp - act).abs < delta
        end
      end
    end
  end
end
