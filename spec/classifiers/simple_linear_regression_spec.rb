# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/data/data_set'
require 'ai4r/classifiers/simple_linear_regression'

RSpec.describe Ai4r::Classifiers::SimpleLinearRegression do
  let(:classifier) { described_class.new }
  
  describe '#initialize' do
    it 'initializes with default values' do
      expect(classifier.attribute).to be_nil
      expect(classifier.attribute_index).to eq(0)
      expect(classifier.slope).to eq(0)
      expect(classifier.intercept).to eq(0)
    end
  end

  describe '#build' do
    context 'with valid data' do
      let(:data_set) do
        Ai4r::Data::DataSet.new(
          data_labels: ['height', 'weight'],
          data_items: [
            [160, 60],
            [170, 70],
            [180, 80],
            [190, 90],
            [200, 100]
          ]
        )
      end

      it 'builds a linear regression model' do
        classifier.build(data_set)
        
        expect(classifier.attribute).to eq('height')
        expect(classifier.attribute_index).to eq(0)
        expect(classifier.slope).to be_within(0.001).of(1.0)
        expect(classifier.intercept).to be_within(0.001).of(-100.0)
      end

      it 'returns self' do
        expect(classifier.build(data_set)).to eq(classifier)
      end
    end

    context 'with multiple attributes' do
      let(:data_set) do
        Ai4r::Data::DataSet.new(
          data_labels: ['age', 'years_experience', 'salary'],
          data_items: [
            [25, 1, 30000],
            [28, 4, 40000],
            [32, 8, 55000],
            [38, 14, 80000],
            [45, 21, 120000]
          ]
        )
      end

      it 'selects the best attribute for regression' do
        classifier.build(data_set)
        
        # Should select years_experience as it has stronger correlation with salary
        expect(classifier.attribute).to eq('years_experience')
        expect(classifier.slope).to be > 0
      end
    end

    context 'with invalid data' do
      it 'raises error when data is not a DataSet' do
        expect { classifier.build([]) }.to raise_error('Error instance must be passed')
      end

      it 'raises error when data is empty' do
        empty_data = Ai4r::Data::DataSet.new(data_labels: ['x', 'y'], data_items: [])
        expect { classifier.build(empty_data) }.to raise_error('Data should not be empty')
      end

      it 'raises error when no useful attribute found' do
        # All x values are the same, so no correlation possible
        constant_data = Ai4r::Data::DataSet.new(
          data_labels: ['constant', 'y'],
          data_items: [[5, 10], [5, 20], [5, 30]]
        )
        expect { classifier.build(constant_data) }.to raise_error('no useful attribute found')
      end
    end
  end

  describe '#eval' do
    let(:training_data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y'],
        data_items: [
          [1, 3],
          [2, 5],
          [3, 7],
          [4, 9],
          [5, 11]
        ]
      )
    end

    before do
      classifier.build(training_data)
    end

    it 'predicts values correctly' do
      # y = 2x + 1
      expect(classifier.eval([6])).to be_within(0.001).of(13.0)
      expect(classifier.eval([10])).to be_within(0.001).of(21.0)
      expect(classifier.eval([0])).to be_within(0.001).of(1.0)
    end

    it 'uses the correct attribute index' do
      multi_attr_data = Ai4r::Data::DataSet.new(
        data_labels: ['a', 'b', 'c', 'target'],
        data_items: [
          [1, 10, 2, 5],
          [2, 20, 4, 10],
          [3, 30, 6, 15],
          [4, 40, 8, 20]
        ]
      )
      
      classifier.build(multi_attr_data)
      # Should use the attribute at the selected index
      test_instance = [5, 50, 10]
      result = classifier.eval(test_instance)
      expect(result).to be_a(Numeric)
    end
  end

  describe 'integration tests' do
    it 'handles real-world like data' do
      # House price prediction: size (sqft) -> price
      house_data = Ai4r::Data::DataSet.new(
        data_labels: ['bedrooms', 'size_sqft', 'age', 'price'],
        data_items: [
          [2, 1000, 10, 200000],
          [3, 1500, 5, 300000],
          [4, 2000, 2, 400000],
          [3, 1800, 8, 350000],
          [2, 1200, 15, 250000]
        ]
      )
      
      classifier.build(house_data)
      
      # Should select size_sqft as best predictor
      expect(classifier.attribute).to eq('size_sqft')
      
      # Predict price for 1600 sqft house
      predicted_price = classifier.eval([3, 1600, 7])
      expect(predicted_price).to be > 300000
      expect(predicted_price).to be < 350000
    end

    it 'handles negative correlations' do
      # Age vs Value (negative correlation)
      depreciation_data = Ai4r::Data::DataSet.new(
        data_labels: ['age_years', 'value'],
        data_items: [
          [0, 20000],
          [2, 16000],
          [4, 12000],
          [6, 8000],
          [8, 4000]
        ]
      )
      
      classifier.build(depreciation_data)
      
      expect(classifier.slope).to be < 0  # Negative slope
      
      # Older items should have lower predicted value
      expect(classifier.eval([10])).to be < classifier.eval([1])
    end

    it 'handles noisy data' do
      # Data with some noise
      noisy_data = Ai4r::Data::DataSet.new(
        data_labels: ['input', 'output'],
        data_items: [
          [1, 2.1],
          [2, 3.9],
          [3, 6.2],
          [4, 7.8],
          [5, 10.1]
        ]
      )
      
      classifier.build(noisy_data)
      
      # Should still find approximately y = 2x relationship
      expect(classifier.slope).to be_within(0.2).of(2.0)
    end
  end
end