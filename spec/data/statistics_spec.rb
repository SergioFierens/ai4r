# frozen_string_literal: true

# RSpec tests for AI4R Statistics module based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Data::Statistics do
  # Test data from requirement document
  let(:simple_array) { [1, 2, 3, 4, 5] }
  let(:decimal_array) { [1.1, 2.2, 3.3, 4.4, 5.5] }
  let(:unsorted_array) { [5, 1, 3, 2, 4] }
  let(:with_duplicates) { [1, 2, 2, 3, 3, 3, 4] }
  let(:single_element) { [42] }
  let(:two_elements) { [10, 20] }
  let(:large_array) { Array.new(1000) { rand(100) } }
  
  describe "Basic Statistical Operations" do
    context "central tendency" do
      it "test_mean_calculation" do
        # Should calculate arithmetic mean correctly
        expect(described_class.mean(simple_array)).to eq(3.0)
        expect(described_class.mean(decimal_array)).to be_within(0.001).of(3.3)
        expect(described_class.mean(single_element)).to eq(42.0)
      end
      
      it "test_median_calculation" do
        # Should find middle value for odd-length arrays
        expect(described_class.median(simple_array)).to eq(3)
        
        # Should find average of middle two for even-length arrays
        expect(described_class.median(two_elements)).to eq(15.0)
        
        # Should handle unsorted arrays
        expect(described_class.median(unsorted_array)).to eq(3)
        
        # Single element
        expect(described_class.median(single_element)).to eq(42)
      end
      
      it "test_mode_calculation" do
        # Should find most frequent value
        expect(described_class.mode(with_duplicates)).to eq(3)
        
        # Should handle arrays with no clear mode
        mode_result = described_class.mode(simple_array)
        expect(simple_array).to include(mode_result)  # Any value is valid
        
        # Single element should be the mode
        expect(described_class.mode(single_element)).to eq(42)
      end
    end
    
    context "variability measures" do
      it "test_variance_calculation" do
        # Should calculate population variance
        variance = described_class.variance(simple_array)
        expect(variance).to be > 0
        expect(variance).to be_within(0.001).of(2.0)  # Known variance for [1,2,3,4,5]
        
        # Single element should have zero variance
        expect(described_class.variance(single_element)).to eq(0.0)
      end
      
      it "test_standard_deviation" do
        # Should be square root of variance
        std_dev = described_class.standard_deviation(simple_array)
        variance = described_class.variance(simple_array)
        
        expect(std_dev).to be_within(0.001).of(Math.sqrt(variance))
        expect(std_dev).to be > 0
        
        # Single element should have zero std dev
        expect(described_class.standard_deviation(single_element)).to eq(0.0)
      end
    end
    
    context "range operations" do
      it "test_max_min" do
        # Should find correct extremes
        expect(described_class.max(simple_array)).to eq(5)
        expect(described_class.min(simple_array)).to eq(1)
        
        expect(described_class.max(unsorted_array)).to eq(5)
        expect(described_class.min(unsorted_array)).to eq(1)
        
        # Single element
        expect(described_class.max(single_element)).to eq(42)
        expect(described_class.min(single_element)).to eq(42)
      end
      
      it "test_range_calculation" do
        # Should calculate range as max - min
        range = described_class.max(simple_array) - described_class.min(simple_array)
        expect(range).to eq(4)
        
        range_unsorted = described_class.max(unsorted_array) - described_class.min(unsorted_array)
        expect(range_unsorted).to eq(4)
        
        # Single element should have zero range
        single_range = described_class.max(single_element) - described_class.min(single_element)
        expect(single_range).to eq(0)
      end
    end
  end
  
  describe "Advanced Statistical Tests" do
    context "distribution analysis" do
      it "test_percentiles" do
        # Test quartiles if available
        if described_class.respond_to?(:percentile)
          q1 = described_class.percentile(simple_array, 25)
          median = described_class.percentile(simple_array, 50)
          q3 = described_class.percentile(simple_array, 75)
          
          expect(q1).to be <= median
          expect(median).to be <= q3
          expect(median).to eq(described_class.median(simple_array))
        end
      end
      
      it "test_frequency_distribution" do
        # Should handle frequency analysis
        frequencies = {}
        with_duplicates.each do |value|
          frequencies[value] = (frequencies[value] || 0) + 1
        end
        
        # Most frequent should be mode
        most_frequent = frequencies.max_by { |k, v| v }[0]
        expect(most_frequent).to eq(described_class.mode(with_duplicates))
      end
    end
    
    context "normalization operations" do
      it "test_z_score_normalization" do
        # Z-score normalization: (x - mean) / std_dev
        mean = described_class.mean(simple_array)
        std_dev = described_class.standard_deviation(simple_array)
        
        normalized = simple_array.map { |x| (x - mean) / std_dev }
        
        # Normalized data should have mean ≈ 0 and std dev ≈ 1
        norm_mean = described_class.mean(normalized)
        norm_std = described_class.standard_deviation(normalized)
        
        expect(norm_mean).to be_within(0.001).of(0.0)
        expect(norm_std).to be_within(0.001).of(1.0)
      end
      
      it "test_min_max_scaling" do
        # Min-max scaling: (x - min) / (max - min)
        min_val = described_class.min(simple_array)
        max_val = described_class.max(simple_array)
        
        scaled = simple_array.map { |x| (x - min_val).to_f / (max_val - min_val) }
        
        # Scaled data should be in [0, 1] range
        scaled_min = described_class.min(scaled)
        scaled_max = described_class.max(scaled)
        
        expect(scaled_min).to be_within(0.001).of(0.0)
        expect(scaled_max).to be_within(0.001).of(1.0)
      end
    end
  end
  
  describe "Edge Case Tests" do
    context "boundary conditions" do
      it "test_empty_array" do
        empty = []
        
        # Should handle empty arrays gracefully
        expect {
          described_class.mean(empty)
        }.to raise_error(StandardError)
      end
      
      it "test_single_value_array" do
        # All statistics should work with single values
        expect(described_class.mean(single_element)).to eq(42.0)
        expect(described_class.median(single_element)).to eq(42)
        expect(described_class.mode(single_element)).to eq(42)
        expect(described_class.variance(single_element)).to eq(0.0)
        expect(described_class.standard_deviation(single_element)).to eq(0.0)
      end
      
      it "test_identical_values" do
        identical = [5, 5, 5, 5, 5]
        
        expect(described_class.mean(identical)).to eq(5.0)
        expect(described_class.median(identical)).to eq(5)
        expect(described_class.mode(identical)).to eq(5)
        expect(described_class.variance(identical)).to eq(0.0)
        expect(described_class.standard_deviation(identical)).to eq(0.0)
        expect(described_class.max(identical)).to eq(5)
        expect(described_class.min(identical)).to eq(5)
      end
    end
    
    context "data type handling" do
      it "test_mixed_numeric_types" do
        mixed = [1, 2.5, 3, 4.7, 5]
        
        # Should handle integers and floats together
        mean = described_class.mean(mixed)
        expect(mean).to be_a(Numeric)
        expect(mean).to be_within(0.001).of(3.24)
      end
      
      it "test_large_numbers" do
        large_numbers = [1_000_000, 2_000_000, 3_000_000]
        
        # Should handle large numbers without overflow
        mean = described_class.mean(large_numbers)
        expect(mean).to eq(2_000_000.0)
      end
    end
  end
  
  describe "Performance Tests" do
    it "handles large datasets efficiently" do
      # Generate large dataset
      large_data = Array.new(10_000) { rand(1000) }
      
      benchmark_performance("Statistics on 10K elements") do
        mean = described_class.mean(large_data)
        median = described_class.median(large_data)
        variance = described_class.variance(large_data)
        
        expect(mean).to be_a(Numeric)
        expect(median).to be_a(Numeric)
        expect(variance).to be >= 0
      end
    end
  end
  
  describe "Integration Tests" do
    it "provides comprehensive statistical analysis" do
      # Should work together for complete analysis
      data = [10, 15, 20, 25, 30, 35, 40, 45, 50]
      
      mean = described_class.mean(data)
      median = described_class.median(data)
      mode = described_class.mode(data)
      variance = described_class.variance(data)
      std_dev = described_class.standard_deviation(data)
      min_val = described_class.min(data)
      max_val = described_class.max(data)
      
      # Sanity checks
      expect(mean).to be_between(min_val, max_val)
      expect(median).to be_between(min_val, max_val)
      expect(data).to include(mode)
      expect(variance).to be >= 0
      expect(std_dev).to eq(Math.sqrt(variance))
      expect(min_val).to be <= max_val
    end
    
    it "maintains numerical stability" do
      # Test with challenging numerical cases
      small_numbers = [0.0001, 0.0002, 0.0003, 0.0004, 0.0005]
      
      mean = described_class.mean(small_numbers)
      variance = described_class.variance(small_numbers)
      
      expect(mean).to be > 0
      expect(variance).to be >= 0
      expect(variance).to be_finite
    end
  end
  
  # Helper methods for testing
  def assert_valid_statistic(value, array)
    expect(value).to be_a(Numeric)
    expect(value).to be_finite
    
    unless array.empty?
      expect(value).to be >= described_class.min(array)
      expect(value).to be <= described_class.max(array)
    end
  end
end