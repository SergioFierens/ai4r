# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::Data::DataNormalizer do
  let(:dataset) { double('dataset') }
  let(:normalizer) { described_class.new(dataset) }
  
  describe '#initialize' do
    it 'sets default configuration' do
      expect(normalizer.instance_variable_get(:@dataset)).to eq(dataset)
      expect(normalizer.instance_variable_get(:@verbose)).to be false
      expect(normalizer.instance_variable_get(:@explain_operations)).to be false
    end
    
    it 'accepts custom configuration' do
      config = { verbose: true, explain_operations: true }
      custom_normalizer = described_class.new(dataset, config)
      
      expect(custom_normalizer.instance_variable_get(:@verbose)).to be true
      expect(custom_normalizer.instance_variable_get(:@explain_operations)).to be true
    end
  end
  
  describe '#normalize' do
    context 'with min-max normalization' do
      it 'scales data to [0, 1] range' do
        data = [[1, 10], [2, 20], [3, 30], [4, 40], [5, 50]]
        normalized = normalizer.normalize(data, :min_max)
        
        # Check each dimension is normalized to [0, 1]
        normalized.each do |row|
          row.each do |value|
            expect(value).to be_between(0, 1).inclusive
          end
        end
        
        # Check min becomes 0 and max becomes 1
        expect(normalized[0][0]).to eq(0.0)
        expect(normalized[-1][0]).to eq(1.0)
        expect(normalized[0][1]).to eq(0.0)
        expect(normalized[-1][1]).to eq(1.0)
      end
      
      it 'handles single value columns' do
        data = [[5, 10], [5, 20], [5, 30]]
        normalized = normalizer.normalize(data, :min_max)
        
        # Constant column should become all zeros
        normalized.each do |row|
          expect(row[0]).to eq(0.0)
        end
      end
      
      it 'preserves relative distances' do
        data = [[0], [25], [50], [100]]
        normalized = normalizer.normalize(data, :min_max)
        
        # 25 is 1/4 of the way from 0 to 100
        expect(normalized[1][0]).to be_within(0.001).of(0.25)
        # 50 is halfway
        expect(normalized[2][0]).to be_within(0.001).of(0.5)
      end
    end
    
    context 'with z-score normalization' do
      it 'standardizes data to mean=0, std=1' do
        data = [[1], [2], [3], [4], [5]]
        normalized = normalizer.normalize(data, :z_score)
        
        # Calculate mean and std of normalized data
        values = normalized.map { |row| row[0] }
        mean = values.sum / values.length
        variance = values.map { |v| (v - mean)**2 }.sum / values.length
        std = Math.sqrt(variance)
        
        expect(mean).to be_within(0.001).of(0.0)
        expect(std).to be_within(0.001).of(1.0)
      end
      
      it 'accepts :standardize as alias' do
        data = [[1], [2], [3]]
        z_score_result = normalizer.normalize(data, :z_score)
        standardize_result = normalizer.normalize(data, :standardize)
        
        expect(z_score_result).to eq(standardize_result)
      end
      
      it 'handles multi-dimensional data' do
        data = [[1, 10], [2, 20], [3, 30], [4, 40], [5, 50]]
        normalized = normalizer.normalize(data, :z_score)
        
        # Each dimension should be standardized independently
        [0, 1].each do |dim|
          values = normalized.map { |row| row[dim] }
          mean = values.sum / values.length
          expect(mean).to be_within(0.001).of(0.0)
        end
      end
    end
    
    context 'with robust normalization' do
      it 'uses median and IQR' do
        # Data with outliers
        data = [[1], [2], [3], [4], [100]] # 100 is an outlier
        normalized = normalizer.normalize(data, :robust)
        
        # The outlier should be handled gracefully
        expect(normalized[-1][0]).to be_finite
        
        # Non-outlier values should be reasonably scaled
        expect(normalized[0][0]).to be < 0  # Below median
        expect(normalized[3][0]).to be > 0  # Above median
      end
      
      it 'is less sensitive to outliers than z-score' do
        data_with_outlier = [[1], [2], [3], [4], [1000]]
        data_without_outlier = [[1], [2], [3], [4], [5]]
        
        # Robust normalization
        robust_with = normalizer.normalize(data_with_outlier, :robust)
        robust_without = normalizer.normalize(data_without_outlier, :robust)
        
        # Z-score normalization
        zscore_with = normalizer.normalize(data_with_outlier, :z_score)
        zscore_without = normalizer.normalize(data_without_outlier, :z_score)
        
        # Robust should show less difference for non-outlier points
        robust_diff = (robust_with[0][0] - robust_without[0][0]).abs
        zscore_diff = (zscore_with[0][0] - zscore_without[0][0]).abs
        
        expect(robust_diff).to be < zscore_diff
      end
    end
    
    context 'with unit vector normalization' do
      it 'normalizes to unit length' do
        data = [[3, 4], [6, 8], [5, 12]]
        normalized = normalizer.normalize(data, :unit_vector)
        
        # Each row should have unit length
        normalized.each do |row|
          length = Math.sqrt(row.map { |v| v**2 }.sum)
          expect(length).to be_within(0.001).of(1.0)
        end
      end
      
      it 'preserves direction' do
        data = [[1, 0], [0, 1], [1, 1]]
        normalized = normalizer.normalize(data, :unit_vector)
        
        # [1, 0] should stay [1, 0]
        expect(normalized[0]).to eq([1.0, 0.0])
        
        # [0, 1] should stay [0, 1]
        expect(normalized[1]).to eq([0.0, 1.0])
        
        # [1, 1] should become [1/√2, 1/√2]
        expected = 1.0 / Math.sqrt(2)
        expect(normalized[2][0]).to be_within(0.001).of(expected)
        expect(normalized[2][1]).to be_within(0.001).of(expected)
      end
      
      it 'handles zero vectors' do
        data = [[0, 0], [1, 1]]
        normalized = normalizer.normalize(data, :unit_vector)
        
        # Zero vector should remain zero
        expect(normalized[0]).to eq([0.0, 0.0])
      end
    end
    
    context 'with decimal scaling' do
      it 'scales by powers of 10' do
        data = [[10, 100], [20, 200], [30, 300]]
        normalized = normalizer.normalize(data, :decimal_scaling)
        
        # Should be scaled to [-1, 1] range
        normalized.flatten.each do |value|
          expect(value.abs).to be <= 1.0
        end
        
        # First column divided by 100 (10^2)
        expect(normalized[0][0]).to be_within(0.001).of(0.1)
        expect(normalized[1][0]).to be_within(0.001).of(0.2)
        
        # Second column divided by 1000 (10^3)
        expect(normalized[0][1]).to be_within(0.001).of(0.1)
        expect(normalized[1][1]).to be_within(0.001).of(0.2)
      end
      
      it 'handles negative values' do
        data = [[-50], [0], [50]]
        normalized = normalizer.normalize(data, :decimal_scaling)
        
        expect(normalized[0][0]).to be_within(0.001).of(-0.5)
        expect(normalized[1][0]).to eq(0.0)
        expect(normalized[2][0]).to be_within(0.001).of(0.5)
      end
    end
    
    it 'raises error for unknown method' do
      data = [[1], [2], [3]]
      expect { normalizer.normalize(data, :unknown) }.to raise_error(ArgumentError, /Unknown normalization method/)
    end
  end
  
  describe '.explain_method' do
    it 'provides explanations for all methods' do
      [:min_max, :z_score, :robust, :unit_vector, :decimal_scaling].each do |method|
        explanation = described_class.explain_method(method)
        expect(explanation).to be_a(String)
        expect(explanation).not_to be_empty
      end
    end
    
    it 'includes best use cases' do
      explanation = described_class.explain_method(:min_max)
      expect(explanation).to include('Best for:')
    end
  end
  
  describe 'educational features' do
    let(:educational_normalizer) do
      described_class.new(dataset, { verbose: true, explain_operations: true })
    end
    
    it 'explains operations when enabled' do
      data = [[1], [2], [3]]
      
      # Capture output
      output = capture_stdout do
        educational_normalizer.normalize(data, :min_max)
      end
      
      expect(output).to include('Min-Max Normalization')
    end
  end
  
  describe 'edge cases' do
    it 'handles empty data' do
      expect(normalizer.normalize([], :min_max)).to eq([])
    end
    
    it 'handles single row' do
      data = [[1, 2, 3]]
      normalized = normalizer.normalize(data, :min_max)
      
      # Single row becomes all zeros (no range)
      expect(normalized).to eq([[0.0, 0.0, 0.0]])
    end
    
    it 'handles very large values' do
      data = [[1e10], [2e10], [3e10]]
      
      # Should not raise errors
      expect { normalizer.normalize(data, :min_max) }.not_to raise_error
      expect { normalizer.normalize(data, :z_score) }.not_to raise_error
    end
    
    it 'handles very small values' do
      data = [[1e-10], [2e-10], [3e-10]]
      
      normalized = normalizer.normalize(data, :min_max)
      expect(normalized[0][0]).to eq(0.0)
      expect(normalized[-1][0]).to eq(1.0)
    end
  end
  
  describe 'data integrity' do
    it 'does not modify original data' do
      original_data = [[1, 2], [3, 4], [5, 6]]
      data_copy = original_data.map(&:dup)
      
      normalizer.normalize(original_data, :min_max)
      
      expect(original_data).to eq(data_copy)
    end
    
    it 'returns new array' do
      data = [[1], [2], [3]]
      normalized = normalizer.normalize(data, :min_max)
      
      expect(normalized).not_to equal(data)
      expect(normalized[0]).not_to equal(data[0])
    end
  end
  
  # Helper method
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end