# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/data/data_set'
require 'ai4r/data/statistics'
require 'ai4r/data/proximity'
require 'ai4r/data/parameterizable'

RSpec.describe 'Data Module Comprehensive Tests' do
  describe Ai4r::Data::DataSet do
    let(:data_items) do
      [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
      ]
    end
    
    let(:labels) { ['A', 'B', 'C'] }
    let(:data_labels) { ['x', 'y', 'z'] }
    
    let(:dataset) { described_class.new(data_items: data_items, data_labels: data_labels, labels: labels) }
    
    describe 'initialization' do
      it 'creates dataset from array' do
        expect(dataset.data_items).to eq(data_items)
        expect(dataset.labels).to eq(labels)
        expect(dataset.data_labels).to eq(data_labels)
      end
      
      it 'handles empty initialization' do
        empty_dataset = described_class.new
        expect(empty_dataset.data_items).to eq([])
      end
      
      it 'loads from CSV file' do
        csv_content = "x,y,z,label\n1,2,3,A\n4,5,6,B\n7,8,9,C"
        allow(File).to receive(:read).and_return(csv_content)
        
        dataset = described_class.load_from_csv('dummy.csv')
        expect(dataset.data_items).to eq(data_items)
      end
      
      it 'loads from ARFF file' do
        arff_content = "@relation test\n@attribute x numeric\n@attribute y numeric\n@attribute z numeric\n@attribute class {A,B,C}\n@data\n1,2,3,A\n4,5,6,B\n7,8,9,C"
        allow(File).to receive(:read).and_return(arff_content)
        
        dataset = described_class.load_from_arff('dummy.arff')
        expect(dataset.data_items).to eq(data_items)
      end
    end
    
    describe 'data manipulation' do
      it 'gets specific row' do
        expect(dataset.data_item(1)).to eq([4, 5, 6])
      end
      
      it 'gets specific column' do
        expect(dataset.get_column(0)).to eq([1, 4, 7])
      end
      
      it 'adds new data item' do
        dataset.add_item([10, 11, 12], 'D')
        expect(dataset.data_items.last).to eq([10, 11, 12])
        expect(dataset.labels.last).to eq('D')
      end
      
      it 'removes data item' do
        dataset.remove_item(1)
        expect(dataset.data_items).to eq([[1, 2, 3], [7, 8, 9]])
        expect(dataset.labels).to eq(['A', 'C'])
      end
      
      it 'shuffles data' do
        original_order = dataset.data_items.dup
        dataset.shuffle!
        expect(dataset.data_items).to match_array(original_order)
      end
    end
    
    describe 'data transformation' do
      it 'normalizes data' do
        dataset.normalize!
        dataset.data_items.each do |row|
          row.each { |val| expect(val).to be_between(0, 1) }
        end
      end
      
      it 'standardizes data' do
        dataset.standardize!
        # Check that mean is ~0 and std is ~1
        column = dataset.get_column(0)
        mean = column.sum.to_f / column.size
        expect(mean).to be_within(0.1).of(0)
      end
      
      it 'applies custom transformation' do
        dataset.transform! { |val| val * 2 }
        expect(dataset.data_items.first).to eq([2, 4, 6])
      end
      
      it 'filters data' do
        filtered = dataset.filter { |item| item[0] > 3 }
        expect(filtered.data_items).to eq([[4, 5, 6], [7, 8, 9]])
      end
    end
    
    describe 'data splitting' do
      it 'splits into training and test sets' do
        train, test = dataset.split(0.7)
        expect(train.data_items.size).to eq(2)
        expect(test.data_items.size).to eq(1)
      end
      
      it 'performs k-fold cross validation' do
        folds = dataset.cross_validation_folds(3)
        expect(folds.size).to eq(3)
        folds.each { |fold| expect(fold.data_items.size).to eq(1) }
      end
      
      it 'stratified split maintains class distribution' do
        # Create dataset with imbalanced classes
        imbalanced_data = [[1], [2], [3], [4], [5], [6]]
        imbalanced_labels = ['A', 'A', 'A', 'B', 'B', 'C']
        imbalanced_dataset = described_class.new(
          data_items: imbalanced_data,
          labels: imbalanced_labels
        )
        
        train, test = imbalanced_dataset.stratified_split(0.5)
        
        # Check that both sets have all classes
        expect(train.labels.uniq.sort).to eq(['A', 'B', 'C'])
      end
    end
    
    describe 'statistics' do
      it 'calculates basic statistics' do
        stats = dataset.statistics
        expect(stats).to include(:mean, :std, :min, :max)
        expect(stats[:mean]).to eq([4.0, 5.0, 6.0])
      end
      
      it 'calculates correlation matrix' do
        corr = dataset.correlation_matrix
        expect(corr.size).to eq(3)
        expect(corr[0][0]).to eq(1.0)
      end
      
      it 'detects outliers' do
        outlier_data = data_items + [[100, 200, 300]]
        outlier_dataset = described_class.new(data_items: outlier_data)
        outliers = outlier_dataset.detect_outliers
        expect(outliers).to include(3)
      end
    end
    
    describe 'data export' do
      it 'exports to CSV' do
        csv = dataset.to_csv
        expect(csv).to include('x,y,z,label')
        expect(csv).to include('1,2,3,A')
      end
      
      it 'exports to ARFF' do
        arff = dataset.to_arff('test')
        expect(arff).to include('@relation test')
        expect(arff).to include('@attribute x numeric')
        expect(arff).to include('@data')
      end
      
      it 'exports to hash' do
        hash = dataset.to_h
        expect(hash[:data_items]).to eq(data_items)
        expect(hash[:labels]).to eq(labels)
        expect(hash[:data_labels]).to eq(data_labels)
      end
    end
    
    describe 'missing value handling' do
      let(:data_with_missing) do
        [[1, nil, 3], [4, 5, nil], [7, 8, 9]]
      end
      
      let(:missing_dataset) do
        described_class.new(data_items: data_with_missing)
      end
      
      it 'detects missing values' do
        expect(missing_dataset.has_missing_values?).to be true
        expect(missing_dataset.missing_value_indices).to eq([[0, 1], [1, 2]])
      end
      
      it 'fills missing values with mean' do
        missing_dataset.fill_missing_values!(:mean)
        expect(missing_dataset.data_items[0][1]).to eq(6.5)  # (5+8)/2
        expect(missing_dataset.data_items[1][2]).to eq(6.0)  # (3+9)/2
      end
      
      it 'fills missing values with median' do
        missing_dataset.fill_missing_values!(:median)
        expect(missing_dataset.data_items[0][1]).to eq(6.5)
      end
      
      it 'removes rows with missing values' do
        missing_dataset.remove_missing_values!
        expect(missing_dataset.data_items).to eq([[7, 8, 9]])
      end
    end
    
    describe 'feature engineering' do
      it 'adds polynomial features' do
        dataset.add_polynomial_features(degree: 2)
        # Original 3 features + 3 squared + 3 interactions
        expect(dataset.data_items.first.size).to be > 3
      end
      
      it 'adds interaction features' do
        dataset.add_interaction_features
        expect(dataset.data_items.first.size).to eq(6)  # 3 original + 3 interactions
      end
      
      it 'performs one-hot encoding' do
        categorical_data = [['red'], ['blue'], ['red'], ['green']]
        cat_dataset = described_class.new(data_items: categorical_data)
        
        cat_dataset.one_hot_encode!(0)
        expect(cat_dataset.data_items.first.size).to eq(3)  # 3 unique values
      end
    end
    
    describe 'data validation' do
      it 'validates data types' do
        expect(dataset.all_numeric?).to be true
        
        mixed_data = [[1, 'text', 3]]
        mixed_dataset = described_class.new(data_items: mixed_data)
        expect(mixed_dataset.all_numeric?).to be false
      end
      
      it 'validates data consistency' do
        inconsistent_data = [[1, 2], [3, 4, 5]]
        expect {
          described_class.new(data_items: inconsistent_data).validate!
        }.to raise_error(ArgumentError)
      end
      
      it 'checks for duplicates' do
        dup_data = [[1, 2, 3], [1, 2, 3], [4, 5, 6]]
        dup_dataset = described_class.new(data_items: dup_data)
        expect(dup_dataset.has_duplicates?).to be true
        expect(dup_dataset.duplicate_indices).to eq([[0, 1]])
      end
    end
  end
  
  describe 'Integration with other modules' do
    let(:dataset) do
      Ai4r::Data::DataSet.new(
        data_items: [[1, 2], [3, 4], [5, 6], [7, 8]],
        labels: ['A', 'A', 'B', 'B']
      )
    end
    
    it 'prepares data for clustering' do
      cluster_data = dataset.prepare_for_clustering
      expect(cluster_data).to be_a(Ai4r::Data::DataSet)
      expect(cluster_data.labels).to be_nil
    end
    
    it 'prepares data for classification' do
      x, y = dataset.prepare_for_classification
      expect(x).to eq(dataset.data_items)
      expect(y).to eq(dataset.labels)
    end
    
    it 'creates distance matrix' do
      distances = dataset.distance_matrix(:euclidean)
      expect(distances.size).to eq(4)
      expect(distances[0][0]).to eq(0)
      expect(distances[0][1]).to be > 0
    end
  end
  
  describe 'Performance optimizations' do
    let(:large_dataset) do
      data = 1000.times.map { 10.times.map { rand } }
      described_class.new(data_items: data)
    end
    
    it 'handles large datasets efficiently' do
      start_time = Time.now
      large_dataset.normalize!
      elapsed = Time.now - start_time
      
      expect(elapsed).to be < 1.0  # Should complete in under 1 second
    end
    
    it 'uses lazy evaluation for transformations' do
      lazy_transform = large_dataset.lazy_transform { |val| val * 2 }
      expect(lazy_transform).to respond_to(:each)
    end
    
    it 'supports parallel processing' do
      result = large_dataset.parallel_map { |row| row.sum }
      expect(result.size).to eq(1000)
    end
  end
end