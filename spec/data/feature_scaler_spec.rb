# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/data/feature_scaler'

RSpec.describe Ai4r::Data::FeatureScaler do
  let(:data) do
    [
      [1.0, 100.0, 0.001],
      [2.0, 200.0, 0.002],
      [3.0, 300.0, 0.003],
      [4.0, 400.0, 0.004],
      [5.0, 500.0, 0.005]
    ]
  end
  
  describe 'MinMaxScaler' do
    let(:scaler) { described_class::MinMaxScaler.new }
    
    it 'scales features to [0, 1] range' do
      scaler.fit(data)
      scaled = scaler.transform(data)
      
      scaled.each do |row|
        row.each do |value|
          expect(value).to be_between(0, 1).inclusive
        end
      end
      
      # Check min and max values
      scaled.transpose.each do |column|
        expect(column.min).to be_within(0.001).of(0)
        expect(column.max).to be_within(0.001).of(1)
      end
    end
    
    it 'scales to custom range' do
      custom_scaler = described_class::MinMaxScaler.new(feature_range: [-1, 1])
      custom_scaler.fit(data)
      scaled = custom_scaler.transform(data)
      
      scaled.each do |row|
        row.each do |value|
          expect(value).to be_between(-1, 1).inclusive
        end
      end
    end
    
    it 'handles single value columns' do
      single_value_data = [[1, 5], [2, 5], [3, 5]]
      scaler.fit(single_value_data)
      scaled = scaler.transform(single_value_data)
      
      # Single value columns should be scaled to min of range
      expect(scaled.map { |row| row[1] }).to all(eq(0))
    end
    
    it 'can inverse transform' do
      scaler.fit(data)
      scaled = scaler.transform(data)
      original = scaler.inverse_transform(scaled)
      
      original.each_with_index do |row, i|
        row.each_with_index do |value, j|
          expect(value).to be_within(0.001).of(data[i][j])
        end
      end
    end
    
    it 'fits and transforms in one step' do
      scaled = scaler.fit_transform(data)
      expect(scaled).to eq(scaler.transform(data))
    end
  end
  
  describe 'StandardScaler' do
    let(:scaler) { described_class::StandardScaler.new }
    
    it 'standardizes features to zero mean and unit variance' do
      scaler.fit(data)
      scaled = scaler.transform(data)
      
      scaled.transpose.each do |column|
        mean = column.sum / column.size
        variance = column.map { |x| (x - mean)**2 }.sum / column.size
        
        expect(mean).to be_within(0.001).of(0)
        expect(variance).to be_within(0.001).of(1)
      end
    end
    
    it 'handles zero variance features' do
      zero_var_data = [[1, 5], [2, 5], [3, 5]]
      scaler.fit(zero_var_data)
      scaled = scaler.transform(zero_var_data)
      
      # Zero variance features should become 0
      expect(scaled.map { |row| row[1] }).to all(eq(0))
    end
    
    it 'can inverse transform' do
      scaler.fit(data)
      scaled = scaler.transform(data)
      original = scaler.inverse_transform(scaled)
      
      original.each_with_index do |row, i|
        row.each_with_index do |value, j|
          expect(value).to be_within(0.001).of(data[i][j])
        end
      end
    end
    
    it 'optionally scales without centering' do
      no_center_scaler = described_class::StandardScaler.new(with_mean: false)
      no_center_scaler.fit(data)
      scaled = no_center_scaler.transform(data)
      
      # Should scale but not center
      scaled.transpose.each do |column|
        mean = column.sum / column.size
        expect(mean).not_to be_within(0.1).of(0)
      end
    end
    
    it 'optionally scales without std' do
      no_std_scaler = described_class::StandardScaler.new(with_std: false)
      no_std_scaler.fit(data)
      scaled = no_std_scaler.transform(data)
      
      # Should center but not scale
      scaled.transpose.each do |column|
        mean = column.sum / column.size
        expect(mean).to be_within(0.001).of(0)
      end
    end
  end
  
  describe 'RobustScaler' do
    let(:scaler) { described_class::RobustScaler.new }
    let(:data_with_outliers) do
      data + [[1000, 10000, 1.0]]  # Outliers
    end
    
    it 'scales features using median and IQR' do
      scaler.fit(data_with_outliers)
      scaled = scaler.transform(data_with_outliers)
      
      # Most values should be in reasonable range despite outliers
      normal_scaled = scaled[0...-1]  # Exclude outlier
      normal_scaled.flatten.each do |value|
        expect(value.abs).to be < 3  # Most within 3 IQRs
      end
    end
    
    it 'is robust to outliers' do
      scaler.fit(data_with_outliers)
      scaled_with = scaler.transform(data)
      
      scaler.fit(data)  # Fit without outliers
      scaled_without = scaler.transform(data)
      
      # Scaling should be similar with and without outliers
      scaled_with.flatten.zip(scaled_without.flatten).each do |with, without|
        expect(with).to be_within(0.5).of(without)
      end
    end
    
    it 'uses custom quantile range' do
      custom_scaler = described_class::RobustScaler.new(quantile_range: [0.1, 0.9])
      custom_scaler.fit(data)
      scaled = custom_scaler.transform(data)
      
      expect(scaled).to all(be_an(Array))
    end
  end
  
  describe 'Normalizer' do
    let(:scaler) { described_class::Normalizer.new }
    
    it 'normalizes samples to unit norm' do
      normalized = scaler.transform(data)
      
      normalized.each do |row|
        norm = Math.sqrt(row.map { |x| x**2 }.sum)
        expect(norm).to be_within(0.001).of(1.0)
      end
    end
    
    it 'supports different norms' do
      l1_scaler = described_class::Normalizer.new(norm: 'l1')
      l1_normalized = l1_scaler.transform(data)
      
      l1_normalized.each do |row|
        l1_norm = row.map(&:abs).sum
        expect(l1_norm).to be_within(0.001).of(1.0)
      end
      
      max_scaler = described_class::Normalizer.new(norm: 'max')
      max_normalized = max_scaler.transform(data)
      
      max_normalized.each do |row|
        expect(row.map(&:abs).max).to be_within(0.001).of(1.0)
      end
    end
    
    it 'handles zero vectors' do
      data_with_zero = data + [[0, 0, 0]]
      normalized = scaler.transform(data_with_zero)
      
      # Zero vector should remain zero
      expect(normalized.last).to eq([0, 0, 0])
    end
  end
  
  describe 'MaxAbsScaler' do
    let(:scaler) { described_class::MaxAbsScaler.new }
    let(:data_with_negative) do
      [
        [-10, 20, -5],
        [5, -30, 10],
        [-15, 40, -20]
      ]
    end
    
    it 'scales by maximum absolute value' do
      scaler.fit(data_with_negative)
      scaled = scaler.transform(data_with_negative)
      
      scaled.each do |row|
        row.each do |value|
          expect(value.abs).to be <= 1.0
        end
      end
      
      # Check that max abs value is 1
      scaled.transpose.each do |column|
        expect(column.map(&:abs).max).to be_within(0.001).of(1.0)
      end
    end
    
    it 'preserves sparsity' do
      sparse_data = [
        [0, 10, 0],
        [5, 0, 0],
        [0, 0, 20]
      ]
      
      scaler.fit(sparse_data)
      scaled = scaler.transform(sparse_data)
      
      # Zero values should remain zero
      sparse_data.each_with_index do |row, i|
        row.each_with_index do |value, j|
          if value == 0
            expect(scaled[i][j]).to eq(0)
          end
        end
      end
    end
  end
  
  describe 'QuantileTransformer' do
    let(:scaler) { described_class::QuantileTransformer.new }
    
    it 'transforms features to uniform distribution' do
      # Generate non-uniform data
      non_uniform = 100.times.map { [rand**2, rand**3, Math.sqrt(rand)] }
      
      scaler.fit(non_uniform)
      transformed = scaler.transform(non_uniform)
      
      # Check that each feature is approximately uniform
      transformed.transpose.each do |column|
        sorted = column.sort
        # Check quantiles
        expect(sorted[24]).to be_within(0.1).of(0.25)  # 25th percentile
        expect(sorted[49]).to be_within(0.1).of(0.50)  # 50th percentile
        expect(sorted[74]).to be_within(0.1).of(0.75)  # 75th percentile
      end
    end
    
    it 'transforms to normal distribution' do
      normal_scaler = described_class::QuantileTransformer.new(output_distribution: 'normal')
      
      non_uniform = 100.times.map { [rand**2, rand**3] }
      normal_scaler.fit(non_uniform)
      transformed = normal_scaler.transform(non_uniform)
      
      # Should approximate standard normal
      transformed.transpose.each do |column|
        mean = column.sum / column.size
        std = Math.sqrt(column.map { |x| (x - mean)**2 }.sum / column.size)
        
        expect(mean).to be_within(0.2).of(0)
        expect(std).to be_within(0.2).of(1)
      end
    end
    
    it 'handles outliers' do
      data_with_outliers = data + [[1000, 10000, 10]]
      
      scaler.fit(data_with_outliers)
      transformed = scaler.transform(data_with_outliers)
      
      # Outliers should be clipped to range
      transformed.flatten.each do |value|
        expect(value).to be_between(0, 1).inclusive
      end
    end
  end
  
  describe 'PowerTransformer' do
    let(:scaler) { described_class::PowerTransformer.new }
    
    it 'applies Yeo-Johnson transformation' do
      # Skewed data
      skewed_data = 50.times.map { [rand**2 * 10, rand**3 * 100] }
      
      scaler.fit(skewed_data)
      transformed = scaler.transform(skewed_data)
      
      # Should be more symmetric
      transformed.transpose.each do |column|
        sorted = column.sort
        median_idx = column.size / 2
        lower_half = sorted[0...median_idx]
        upper_half = sorted[median_idx..-1]
        
        # Check that distribution is more symmetric
        lower_spread = sorted[median_idx] - sorted[0]
        upper_spread = sorted[-1] - sorted[median_idx]
        
        expect(lower_spread / upper_spread).to be_between(0.5, 2.0)
      end
    end
    
    it 'applies Box-Cox transformation for positive data' do
      box_cox_scaler = described_class::PowerTransformer.new(method: 'box-cox')
      positive_data = data  # All positive
      
      box_cox_scaler.fit(positive_data)
      transformed = box_cox_scaler.transform(positive_data)
      
      expect(transformed).to all(be_an(Array))
      expect(transformed.flatten).to all(be_finite)
    end
    
    it 'standardizes output' do
      scaler.fit(data)
      transformed = scaler.transform(data)
      
      # Should have zero mean and unit variance
      transformed.transpose.each do |column|
        mean = column.sum / column.size
        std = Math.sqrt(column.map { |x| (x - mean)**2 }.sum / column.size)
        
        expect(mean).to be_within(0.1).of(0)
        expect(std).to be_within(0.1).of(1)
      end
    end
  end
  
  describe 'Integration and edge cases' do
    it 'handles single sample transformation' do
      scaler = described_class::StandardScaler.new
      scaler.fit(data)
      
      single_sample = [2.5, 250, 0.0025]
      transformed = scaler.transform([single_sample])
      
      expect(transformed.size).to eq(1)
      expect(transformed.first.size).to eq(3)
    end
    
    it 'raises error when transforming before fit' do
      scaler = described_class::MinMaxScaler.new
      
      expect { scaler.transform(data) }.to raise_error(RuntimeError, /not fitted/)
    end
    
    it 'handles empty data gracefully' do
      scaler = described_class::StandardScaler.new
      
      expect { scaler.fit([]) }.to raise_error(ArgumentError, /empty/)
    end
    
    it 'preserves data shape' do
      scalers = [
        described_class::MinMaxScaler.new,
        described_class::StandardScaler.new,
        described_class::RobustScaler.new,
        described_class::Normalizer.new
      ]
      
      scalers.each do |scaler|
        scaler.fit(data) if scaler.respond_to?(:fit)
        transformed = scaler.transform(data)
        
        expect(transformed.size).to eq(data.size)
        expect(transformed.first.size).to eq(data.first.size)
      end
    end
  end
end