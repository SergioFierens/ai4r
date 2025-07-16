# frozen_string_literal: true

# RSpec tests for AI4R PCA Algorithm
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::MachineLearning::PCA do
  # Test datasets
  let(:simple_data) do
    [
      [2.5, 2.4],
      [0.5, 0.7],
      [2.2, 2.9],
      [1.9, 2.2],
      [3.1, 3.0],
      [2.3, 2.7],
      [2.0, 1.6],
      [1.0, 1.1],
      [1.5, 1.6],
      [1.1, 0.9]
    ]
  end

  let(:iris_data) do
    [
      [5.1, 3.5, 1.4, 0.2],
      [4.9, 3.0, 1.4, 0.2],
      [4.7, 3.2, 1.3, 0.2],
      [4.6, 3.1, 1.5, 0.2],
      [5.0, 3.6, 1.4, 0.2],
      [7.0, 3.2, 4.7, 1.4],
      [6.4, 3.2, 4.5, 1.5],
      [6.9, 3.1, 4.9, 1.5],
      [5.5, 2.3, 4.0, 1.3],
      [6.5, 2.8, 4.6, 1.5],
      [6.3, 3.3, 6.0, 2.5],
      [5.8, 2.7, 5.1, 1.9],
      [7.1, 3.0, 5.9, 2.1],
      [6.3, 2.9, 5.6, 1.8],
      [6.5, 3.0, 5.8, 2.2]
    ]
  end

  let(:correlated_data) do
    # Create perfectly correlated data for testing
    [
      [1, 2, 3],
      [2, 4, 6],
      [3, 6, 9],
      [4, 8, 12],
      [5, 10, 15]
    ]
  end

  describe 'initialization' do
    context 'with valid parameters' do
      it 'creates PCA instance with default configuration' do
        pca = described_class.new

        expect(pca.instance_variable_get(:@n_components)).to eq(2)
        expect(pca.standardize).to be true
        expect(pca.verbose_mode).to be false
        expect(pca.store_covariance).to be true
      end

      it 'creates PCA instance with integer n_components' do
        pca = described_class.new(n_components: 3)

        expect(pca.instance_variable_get(:@n_components)).to eq(3)
      end

      it 'creates PCA instance with float n_components' do
        pca = described_class.new(n_components: 0.95)

        expect(pca.instance_variable_get(:@n_components)).to eq(0.95)
      end

      it 'creates PCA instance with custom options' do
        pca = described_class.new(
          n_components: 2,
          standardize: false,
          verbose: true,
          store_covariance: false,
          tolerance: 1e-8
        )

        expect(pca.instance_variable_get(:@n_components)).to eq(2)
        expect(pca.standardize).to be false
        expect(pca.verbose_mode).to be true
        expect(pca.store_covariance).to be false
        expect(pca.instance_variable_get(:@tolerance)).to eq(1e-8)
      end
    end

    context 'with invalid parameters' do
      it 'raises error for zero n_components' do
        expect do
          described_class.new(n_components: 0)
        end.to raise_error(ArgumentError, 'n_components must be positive')
      end

      it 'raises error for negative n_components' do
        expect do
          described_class.new(n_components: -1)
        end.to raise_error(ArgumentError, 'n_components must be positive')
      end

      it 'raises error for invalid float n_components' do
        expect do
          described_class.new(n_components: 1.5)
        end.to raise_error(ArgumentError, 'n_components as float must be between 0 and 1')

        expect do
          described_class.new(n_components: 0.0)
        end.to raise_error(ArgumentError, 'n_components as float must be between 0 and 1')
      end

      it 'raises error for invalid n_components type' do
        expect do
          described_class.new(n_components: 'invalid')
        end.to raise_error(ArgumentError, 'n_components must be Integer or Float')
      end
    end
  end

  describe 'fitting' do
    context 'with valid data' do
      let(:pca) { described_class.new(n_components: 2) }

      it 'fits successfully on simple data' do
        expect { pca.fit(simple_data) }.not_to raise_error

        expect(pca.instance_variable_get(:@fitted)).to be true
        expect(pca.n_samples).to eq(10)
        expect(pca.n_features).to eq(2)
        expect(pca.components.length).to eq(2)
        expect(pca.explained_variance.length).to eq(2)
      end

      it 'fits successfully on iris data' do
        pca_iris = described_class.new(n_components: 3)
        expect { pca_iris.fit(iris_data) }.not_to raise_error

        expect(pca_iris.n_samples).to eq(15)
        expect(pca_iris.n_features).to eq(4)
        expect(pca_iris.components.length).to eq(3)
        expect(pca_iris.explained_variance.length).to eq(3)
      end

      it 'limits n_components to n_features' do
        pca_limited = described_class.new(n_components: 10)
        pca_limited.fit(simple_data)

        expect(pca_limited.components.length).to eq(2) # Limited to n_features
      end

      it 'calculates explained variance ratios' do
        pca.fit(simple_data)

        expect(pca.explained_variance_ratio.length).to eq(2)
        expect(pca.explained_variance_ratio.all? { |ratio| ratio.between?(0, 1) }).to be true
        expect(pca.explained_variance_ratio.sum).to be_within(0.01).of(1.0)
      end

      it 'calculates cumulative variance' do
        pca.fit(simple_data)

        expect(pca.cumulative_variance.length).to eq(2)
        expect(pca.cumulative_variance.first).to eq(pca.explained_variance_ratio.first)
        expect(pca.cumulative_variance.last).to be_within(0.01).of(pca.explained_variance_ratio.sum)
      end

      it 'stores mean and std values for standardization' do
        pca.fit(simple_data)

        expect(pca.mean_values.length).to eq(2)
        expect(pca.std_values.length).to eq(2)
        expect(pca.mean_values.all?(Float)).to be true
        expect(pca.std_values.all? { |std| std > 0 }).to be true
      end

      it 'stores covariance matrix when requested' do
        pca.fit(simple_data)

        expect(pca.covariance_matrix.length).to eq(2)
        expect(pca.covariance_matrix.all? { |row| row.length == 2 }).to be true
      end

      it 'handles feature names' do
        feature_names = %w[feature1 feature2]
        pca.fit(simple_data, feature_names)

        expect(pca.feature_names).to eq(feature_names)
      end

      it 'generates default feature names' do
        pca.fit(simple_data)

        expect(pca.feature_names).to eq(%w[feature_0 feature_1])
      end
    end

    context 'with standardization options' do
      it 'standardizes data when standardize=true' do
        pca_std = described_class.new(n_components: 2, standardize: true)
        pca_std.fit(simple_data)

        # Check that standardized data has approximately zero mean and unit variance
        standardized = pca_std.standardized_data
        means = Array.new(2, 0.0)
        standardized.each do |sample|
          sample.each_with_index { |val, idx| means[idx] += val }
        end
        means.map! { |sum| sum / standardized.length }

        expect(means.all? { |mean| mean.abs < 0.01 }).to be true
      end

      it 'only centers data when standardize=false' do
        pca_center = described_class.new(n_components: 2, standardize: false)
        pca_center.fit(simple_data)

        # Check that std_values are all 1.0 (no scaling)
        expect(pca_center.std_values.all?(1.0)).to be true
      end
    end

    context 'with invalid data' do
      let(:pca) { described_class.new }

      it 'raises error for empty data' do
        expect do
          pca.fit([])
        end.to raise_error(ArgumentError, 'Data cannot be empty')
      end

      it 'raises error for non-2D data' do
        expect do
          pca.fit([1, 2, 3])
        end.to raise_error(ArgumentError, 'Data must be 2D array')
      end

      it 'raises error for inconsistent row lengths' do
        expect do
          pca.fit([[1, 2], [3, 4, 5]])
        end.to raise_error(ArgumentError, 'All samples must have the same number of features')
      end

      it 'raises error for insufficient features' do
        expect do
          pca.fit([[1], [2]])
        end.to raise_error(ArgumentError, 'Data must have at least 2 features')
      end

      it 'raises error for insufficient samples' do
        expect do
          pca.fit([[1, 2]])
        end.to raise_error(ArgumentError, 'Data must have at least 2 samples')
      end
    end
  end

  describe 'transformation' do
    let(:pca) { described_class.new(n_components: 2) }

    before do
      pca.fit(simple_data)
    end

    context 'transform method' do
      it 'transforms data successfully' do
        transformed = pca.transform(simple_data)

        expect(transformed.length).to eq(simple_data.length)
        expect(transformed.all? { |sample| sample.length == 2 }).to be true
        expect(transformed.all? { |sample| sample.all?(Float) }).to be true
      end

      it 'transforms new data with same dimensions' do
        new_data = [[1.5, 1.8], [2.0, 2.5]]
        transformed = pca.transform(new_data)

        expect(transformed.length).to eq(2)
        expect(transformed.all? { |sample| sample.length == 2 }).to be true
      end

      it 'produces consistent transformations' do
        transformed1 = pca.transform(simple_data)
        transformed2 = pca.transform(simple_data)

        expect(transformed1).to eq(transformed2)
      end
    end

    context 'fit_transform method' do
      it 'fits and transforms in one step' do
        pca_new = described_class.new(n_components: 2)
        transformed = pca_new.fit_transform(simple_data)

        expect(transformed.length).to eq(simple_data.length)
        expect(transformed.all? { |sample| sample.length == 2 }).to be true
        expect(pca_new.instance_variable_get(:@fitted)).to be true
      end
    end

    context 'input validation' do
      it 'raises error when not fitted' do
        unfitted_pca = described_class.new

        expect do
          unfitted_pca.transform(simple_data)
        end.to raise_error(RuntimeError, 'PCA model must be fitted before use')
      end

      it 'raises error for wrong number of features' do
        expect do
          pca.transform([[1, 2, 3]])
        end.to raise_error(ArgumentError, 'Data must have 2 features')
      end

      it 'raises error for invalid data format' do
        expect do
          pca.transform([1, 2, 3])
        end.to raise_error(ArgumentError, 'Data must be 2D array')
      end
    end
  end

  describe 'inverse transformation' do
    let(:pca) { described_class.new(n_components: 2) }

    before do
      pca.fit(simple_data)
    end

    context 'reconstruction' do
      it 'reconstructs data from transformed data' do
        transformed = pca.transform(simple_data)
        reconstructed = pca.inverse_transform(transformed)

        expect(reconstructed.length).to eq(simple_data.length)
        expect(reconstructed.all? { |sample| sample.length == 2 }).to be true
      end

      it 'reconstructs approximately original data' do
        transformed = pca.transform(simple_data)
        reconstructed = pca.inverse_transform(transformed)

        # Check that reconstruction is reasonably close to original
        # (Perfect reconstruction only if all components are retained)
        reconstruction_errors = simple_data.zip(reconstructed).map do |original, reconstructed_sample|
          original.zip(reconstructed_sample).map { |orig, recon| (orig - recon).abs }.max
        end

        # For 2D data with 2 components, reconstruction should be very close
        expect(reconstruction_errors.all? { |error| error < 0.1 }).to be true
      end
    end

    context 'with reduced dimensions' do
      let(:pca_reduced) { described_class.new(n_components: 1) }

      before do
        pca_reduced.fit(simple_data)
      end

      it 'reconstructs from reduced dimensions' do
        transformed = pca_reduced.transform(simple_data)
        reconstructed = pca_reduced.inverse_transform(transformed)

        expect(reconstructed.length).to eq(simple_data.length)
        expect(reconstructed.all? { |sample| sample.length == 2 }).to be true
      end

      it 'has reconstruction error with reduced dimensions' do
        transformed = pca_reduced.transform(simple_data)
        reconstructed = pca_reduced.inverse_transform(transformed)

        # With only 1 component, there should be some reconstruction error
        reconstruction_errors = simple_data.zip(reconstructed).map do |original, reconstructed_sample|
          original.zip(reconstructed_sample).sum { |orig, recon| (orig - recon).abs }
        end

        expect(reconstruction_errors.any? { |error| error > 0.01 }).to be true
      end
    end

    context 'input validation' do
      it 'raises error when not fitted' do
        unfitted_pca = described_class.new

        expect do
          unfitted_pca.inverse_transform([[1, 2]])
        end.to raise_error(RuntimeError, 'PCA model must be fitted before use')
      end

      it 'raises error for wrong number of components' do
        expect do
          pca.inverse_transform([[1, 2, 3]])
        end.to raise_error(ArgumentError, 'Data must have 2 components')
      end
    end
  end

  describe 'explained variance analysis' do
    let(:pca) { described_class.new(n_components: 3) }

    before do
      pca.fit(iris_data)
    end

    it 'analyzes explained variance' do
      analysis = pca.explained_variance_analysis

      expect(analysis).to have_key(:explained_variance)
      expect(analysis).to have_key(:explained_variance_ratio)
      expect(analysis).to have_key(:cumulative_variance)
      expect(analysis).to have_key(:information_retained)
      expect(analysis).to have_key(:information_lost)
      expect(analysis).to have_key(:dimensionality_reduction)
    end

    it 'calculates information metrics' do
      analysis = pca.explained_variance_analysis

      expect(analysis[:information_retained]).to be >= 0
      expect(analysis[:information_retained]).to be <= 1
      expect(analysis[:information_lost]).to be >= 0
      expect(analysis[:information_lost]).to be <= 1
      expect(analysis[:information_retained] + analysis[:information_lost]).to be_within(0.01).of(1.0)
    end

    it 'calculates dimensionality reduction ratio' do
      analysis = pca.explained_variance_analysis

      expected_reduction = (4 - 3).to_f / 4 # 4 original features, 3 components
      expect(analysis[:dimensionality_reduction]).to be_within(0.01).of(expected_reduction)
    end

    it 'finds components needed for threshold' do
      analysis = pca.explained_variance_analysis(0.90)

      expect(analysis[:components_for_threshold]).to be_a(Integer)
      expect(analysis[:components_for_threshold]).to be >= 1
      expect(analysis[:components_for_threshold]).to be <= 3
    end
  end

  describe 'reconstruction error' do
    let(:pca) { described_class.new(n_components: 2) }

    before do
      pca.fit(iris_data)
    end

    it 'calculates reconstruction error metrics' do
      error_analysis = pca.reconstruction_error(iris_data)

      expect(error_analysis).to have_key(:mean_squared_error)
      expect(error_analysis).to have_key(:root_mean_squared_error)
      expect(error_analysis).to have_key(:mean_absolute_error)
      expect(error_analysis).to have_key(:mse_per_sample)
      expect(error_analysis).to have_key(:max_error)
      expect(error_analysis).to have_key(:min_error)
    end

    it 'provides meaningful error values' do
      error_analysis = pca.reconstruction_error(iris_data)

      expect(error_analysis[:mean_squared_error]).to be >= 0
      expect(error_analysis[:root_mean_squared_error]).to be >= 0
      expect(error_analysis[:mean_absolute_error]).to be >= 0
      expect(error_analysis[:max_error]).to be >= error_analysis[:min_error]
    end

    it 'calculates per-sample errors' do
      error_analysis = pca.reconstruction_error(iris_data)

      expect(error_analysis[:mse_per_sample].length).to eq(iris_data.length)
      expect(error_analysis[:mse_per_sample].all? { |error| error >= 0 }).to be true
    end
  end

  describe 'component analysis' do
    let(:pca) { described_class.new(n_components: 2) }

    before do
      pca.fit(iris_data, %w[sepal_length sepal_width petal_length petal_width])
    end

    it 'analyzes component contributions' do
      analysis = pca.component_analysis

      expect(analysis).to have_key(:component_contributions)
      expect(analysis).to have_key(:feature_importance)
      expect(analysis).to have_key(:most_important_features)
    end

    it 'provides component-specific analysis' do
      analysis = pca.component_analysis
      contributions = analysis[:component_contributions]

      expect(contributions.length).to eq(2)
      contributions.each do |comp_analysis|
        expect(comp_analysis).to have_key(:component)
        expect(comp_analysis).to have_key(:explained_variance)
        expect(comp_analysis).to have_key(:top_features)
        expect(comp_analysis).to have_key(:all_contributions)
      end
    end

    it 'ranks features by importance' do
      analysis = pca.component_analysis
      importance = analysis[:feature_importance]

      expect(importance.length).to eq(4)
      expect(importance.all? { |feature, score| feature.is_a?(String) && score >= 0 }).to be true

      # Check that importance is sorted (descending)
      scores = importance.map { |_, score| score }
      expect(scores).to eq(scores.sort.reverse)
    end

    it 'identifies most important features' do
      analysis = pca.component_analysis
      most_important = analysis[:most_important_features]

      expect(most_important.length).to be <= 5
      expect(most_important.all? { |feature, score| feature.is_a?(String) && score >= 0 }).to be true
    end
  end

  describe 'educational visualization' do
    let(:pca) { described_class.new(n_components: 2) }

    before do
      pca.fit(iris_data)
    end

    it 'generates visualization string' do
      visualization = pca.visualize_analysis

      expect(visualization).to be_a(String)
      expect(visualization).to include('PCA Analysis Visualization')
      expect(visualization).to include('Data Summary')
      expect(visualization).to include('Explained Variance')
      expect(visualization).to include('Principal Components')
      expect(visualization).to include('Recommendations')
    end

    it 'includes dimensionality reduction information' do
      visualization = pca.visualize_analysis

      expect(visualization).to include('Original dimensions: 4')
      expect(visualization).to include('Reduced dimensions: 2')
      expect(visualization).to include('Dimensionality reduction:')
    end

    it 'shows variance information' do
      visualization = pca.visualize_analysis

      expect(visualization).to include('PC1:')
      expect(visualization).to include('PC2:')
      expect(visualization).to include('Cumulative:')
    end
  end

  describe 'matrix operations' do
    let(:pca) { described_class.new }

    context 'dot product' do
      it 'calculates dot product correctly' do
        vector1 = [1, 2, 3]
        vector2 = [4, 5, 6]
        result = pca.send(:dot_product, vector1, vector2)

        expect(result).to eq(32) # 1*4 + 2*5 + 3*6 = 32
      end

      it 'handles zero vectors' do
        vector1 = [0, 0, 0]
        vector2 = [1, 2, 3]
        result = pca.send(:dot_product, vector1, vector2)

        expect(result).to eq(0)
      end
    end

    context 'matrix-vector multiplication' do
      it 'multiplies matrix and vector correctly' do
        matrix = [[1, 2], [3, 4]]
        vector = [5, 6]
        result = pca.send(:matrix_vector_multiply, matrix, vector)

        expect(result).to eq([17, 39]) # [1*5+2*6, 3*5+4*6] = [17, 39]
      end
    end

    context 'vector closeness' do
      it 'detects close vectors' do
        vector1 = [1.0, 2.0, 3.0]
        vector2 = [1.001, 2.001, 3.001]
        result = pca.send(:vectors_close?, vector1, vector2, 0.01)

        expect(result).to be true
      end

      it 'detects distant vectors' do
        vector1 = [1.0, 2.0, 3.0]
        vector2 = [1.1, 2.1, 3.1]
        result = pca.send(:vectors_close?, vector1, vector2, 0.01)

        expect(result).to be false
      end
    end
  end

  describe 'performance characteristics' do
    context 'algorithm efficiency' do
      let(:pca) { described_class.new(n_components: 3) }

      it 'handles moderately large datasets' do
        # Create larger dataset
        large_data = Array.new(100) { Array.new(5) { rand * 10 } }

        benchmark_performance('PCA fitting') do
          pca.fit(large_data)
          expect(pca.components.length).to eq(3)
        end
      end

      it 'transforms data efficiently' do
        pca.fit(iris_data)

        # Create test data
        test_data = Array.new(100) { Array.new(4) { rand * 10 } }

        benchmark_performance('PCA transformation') do
          transformed = pca.transform(test_data)
          expect(transformed.length).to eq(100)
        end
      end
    end

    context 'memory efficiency' do
      it 'handles multiple fit cycles' do
        pca = described_class.new(n_components: 2)

        # Fit multiple times to test memory efficiency
        5.times do
          pca.fit(simple_data)
          expect(pca.components.length).to eq(2)
        end
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'boundary conditions' do
      it 'handles data with perfect correlation' do
        pca = described_class.new(n_components: 2)

        expect { pca.fit(correlated_data) }.not_to raise_error
        expect(pca.components.length).to eq(2)
      end

      it 'handles data with zero variance features' do
        zero_variance_data = [
          [1, 2, 1],
          [2, 2, 1],
          [3, 2, 1],
          [4, 2, 1]
        ]

        pca = described_class.new(n_components: 2)
        expect { pca.fit(zero_variance_data) }.not_to raise_error
      end

      it 'handles minimum dataset size' do
        minimal_data = [
          [1, 2],
          [3, 4]
        ]

        pca = described_class.new(n_components: 1)
        expect { pca.fit(minimal_data) }.not_to raise_error
      end
    end

    context 'numerical stability' do
      it 'handles very small values' do
        small_data = [
          [1e-10, 2e-10],
          [3e-10, 4e-10],
          [5e-10, 6e-10]
        ]

        pca = described_class.new(n_components: 1)
        expect { pca.fit(small_data) }.not_to raise_error
      end

      it 'handles very large values' do
        large_data = [
          [1e10, 2e10],
          [3e10, 4e10],
          [5e10, 6e10]
        ]

        pca = described_class.new(n_components: 1)
        expect { pca.fit(large_data) }.not_to raise_error
      end
    end
  end
end
