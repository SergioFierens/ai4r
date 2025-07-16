# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::Data::DataSet do
  describe 'statistical methods' do
    let(:numeric_data) do
      described_class.new(
        data_labels: ['age', 'salary', 'score'],
        data_items: [
          [25, 30000, 0.8],
          [30, 40000, 0.9],
          [35, 50000, 0.7],
          [40, 60000, 0.85],
          [45, 70000, 0.95]
        ]
      )
    end

    describe '#get_mean_or_mode' do
      it 'calculates mean for numeric columns' do
        means = numeric_data.get_mean_or_mode
        
        expect(means[0]).to eq(35.0)  # Mean age
        expect(means[1]).to eq(50000.0)  # Mean salary
        expect(means[2]).to be_within(0.01).of(0.84)  # Mean score
      end

      it 'calculates mode for categorical columns' do
        categorical_data = described_class.new(
          data_labels: ['color', 'size'],
          data_items: [
            ['red', 'small'],
            ['blue', 'medium'],
            ['red', 'large'],
            ['red', 'medium'],
            ['blue', 'small']
          ]
        )
        
        modes = categorical_data.get_mean_or_mode
        expect(modes[0]).to eq('red')  # Most common color
        expect(modes[1]).to be_a(String)  # Some size
      end
    end

    describe '#get_min' do
      it 'returns minimum values for each column' do
        mins = numeric_data.get_min
        
        expect(mins[0]).to eq(25)
        expect(mins[1]).to eq(30000)
        expect(mins[2]).to eq(0.7)
      end
    end

    describe '#get_max' do
      it 'returns maximum values for each column' do
        maxs = numeric_data.get_max
        
        expect(maxs[0]).to eq(45)
        expect(maxs[1]).to eq(70000)
        expect(maxs[2]).to eq(0.95)
      end
    end

    describe '#get_variance' do
      it 'calculates variance for numeric columns' do
        variances = numeric_data.get_variance
        
        expect(variances[0]).to be > 0  # Age variance
        expect(variances[1]).to be > 0  # Salary variance
        expect(variances[2]).to be > 0  # Score variance
      end
    end

    describe '#get_standard_deviation' do
      it 'calculates standard deviation for numeric columns' do
        stds = numeric_data.get_standard_deviation
        
        # Standard deviation is square root of variance
        variances = numeric_data.get_variance
        
        expect(stds[0]).to be_within(0.001).of(Math.sqrt(variances[0]))
        expect(stds[1]).to be_within(0.001).of(Math.sqrt(variances[1]))
        expect(stds[2]).to be_within(0.001).of(Math.sqrt(variances[2]))
      end
    end
  end

  describe 'data manipulation' do
    let(:data_set) do
      described_class.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 2, 'A'],
          [3, 4, 'B'],
          [5, 6, 'A'],
          [7, 8, 'B']
        ]
      )
    end

    describe '#get_index' do
      it 'returns index of label' do
        expect(data_set.get_index('x')).to eq(0)
        expect(data_set.get_index('y')).to eq(1)
        expect(data_set.get_index('class')).to eq(2)
      end

      it 'returns nil for non-existent label' do
        expect(data_set.get_index('nonexistent')).to be_nil
      end
    end

    describe '#num_attributes' do
      it 'returns number of attributes' do
        expect(data_set.num_attributes).to eq(3)
      end
    end

    describe '#num_instances' do
      it 'returns number of data items' do
        expect(data_set.num_instances).to eq(4)
      end
    end

    describe '#set_data_labels' do
      it 'updates data labels' do
        new_labels = ['feature1', 'feature2', 'target']
        data_set.set_data_labels(new_labels)
        
        expect(data_set.data_labels).to eq(new_labels)
      end
    end

    describe '#set_data_items' do
      it 'updates data items' do
        new_items = [[10, 20, 'C'], [30, 40, 'D']]
        data_set.set_data_items(new_items)
        
        expect(data_set.data_items).to eq(new_items)
        expect(data_set.num_instances).to eq(2)
      end
    end
  end

  describe 'data loading' do
    describe '#parse_csv' do
      it 'loads data from CSV string' do
        csv_content = "1,2,3\n4,5,6\n7,8,9"
        data_set = described_class.new.parse_csv(csv_content)
        
        expect(data_set.data_items.length).to eq(3)
        expect(data_set.data_items[0]).to eq([1.0, 2.0, 3.0])
      end

      it 'handles quoted values' do
        csv_content = '"a","b","c"\n"d","e","f"'
        data_set = described_class.new.parse_csv(csv_content)
        
        expect(data_set.data_items[0]).to eq(['a', 'b', 'c'])
      end
    end

    describe '#parse_csv_with_labels' do
      it 'loads data with first row as labels' do
        csv_content = "age,salary,grade\n25,30000,A\n30,40000,B"
        data_set = described_class.new.parse_csv_with_labels(csv_content)
        
        expect(data_set.data_labels).to eq(['age', 'salary', 'grade'])
        expect(data_set.data_items.length).to eq(2)
      end
    end
  end

  describe 'data access patterns' do
    let(:data_set) do
      described_class.new(
        data_labels: ['x', 'y', 'z'],
        data_items: [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9]
        ]
      )
    end

    it 'provides array-like access to data items' do
      expect(data_set.data_items[0]).to eq([1, 2, 3])
      expect(data_set.data_items[1][1]).to eq(5)
    end

    it 'allows iteration over data items' do
      count = 0
      data_set.data_items.each do |item|
        expect(item).to be_an(Array)
        expect(item.length).to eq(3)
        count += 1
      end
      expect(count).to eq(3)
    end
  end

  describe 'data validation' do
    it 'raises error for empty data' do
      expect {
        described_class.new(data_labels: ['x', 'y'], data_items: [])
      }.to raise_error(ArgumentError, /must not be empty/)
    end

    it 'raises error for mismatched dimensions' do
      expect {
        described_class.new(
          data_labels: ['x', 'y'],
          data_items: [[1, 2], [3, 4, 5]]  # Different lengths
        )
      }.to raise_error(ArgumentError)
    end

    it 'raises error for mismatched labels and data width' do
      expect {
        described_class.new(
          data_labels: ['x', 'y'],
          data_items: [[1, 2, 3], [4, 5, 6]]  # 3 values but 2 labels
        )
      }.to raise_error(ArgumentError)
    end
  end

  describe 'domain handling' do
    let(:mixed_data) do
      described_class.new(
        data_labels: ['numeric', 'categorical'],
        data_items: [
          [1.5, 'A'],
          [2.5, 'B'],
          [3.5, 'A'],
          [4.5, 'C']
        ]
      )
    end

    describe '#build_domains' do
      it 'builds domains for categorical attributes' do
        domains = mixed_data.build_domains
        
        expect(domains).to be_an(Array)
        expect(domains[0]).to be_nil  # Numeric attribute
        expect(domains[1]).to contain_exactly('A', 'B', 'C')
      end
    end

    describe '#get_domain' do
      before { mixed_data.build_domains }

      it 'returns domain for categorical attribute' do
        domain = mixed_data.get_domain(1)
        expect(domain).to contain_exactly('A', 'B', 'C')
      end

      it 'returns nil for numeric attribute' do
        domain = mixed_data.get_domain(0)
        expect(domain).to be_nil
      end
    end
  end

  describe 'data transformation' do
    let(:original_data) do
      described_class.new(
        data_labels: ['x', 'y'],
        data_items: [[1, 2], [3, 4], [5, 6]]
      )
    end

    it 'supports mapping operations' do
      # Transform data by doubling all values
      transformed_items = original_data.data_items.map do |row|
        row.map { |val| val * 2 }
      end
      
      new_data = described_class.new(
        data_labels: original_data.data_labels,
        data_items: transformed_items
      )
      
      expect(new_data.data_items[0]).to eq([2, 4])
      expect(new_data.data_items[1]).to eq([6, 8])
    end

    it 'supports filtering operations' do
      # Filter rows where x > 2
      filtered_items = original_data.data_items.select { |row| row[0] > 2 }
      
      new_data = described_class.new(
        data_labels: original_data.data_labels,
        data_items: filtered_items
      )
      
      expect(new_data.num_instances).to eq(2)
      expect(new_data.data_items[0][0]).to eq(3)
    end
  end
end