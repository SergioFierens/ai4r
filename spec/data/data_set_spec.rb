# frozen_string_literal: true

# RSpec tests for AI4R DataSet class
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Data::DataSet do
  let(:sample_data) do
    [
      ['New York', 25, 'Y'],
      ['Chicago', 55, 'Y'],
      ['Chicago', 23, 'Y'],
      ['Boston', 23, 'N'],
      ['Chicago', 12, 'N'],
      ['Chicago', 87, 'Y']
    ]
  end

  let(:sample_labels) { %w[city age result] }

  let(:dataset) { described_class.new(data_items: sample_data, data_labels: sample_labels) }

  describe 'initialization' do
    it 'creates an empty dataset' do
      empty_dataset = described_class.new
      expect(empty_dataset.data_items).to be_empty
      expect(empty_dataset.data_labels).to be_empty
    end

    it 'creates a dataset with data and labels' do
      expect(dataset.data_items).to eq(sample_data)
      expect(dataset.data_labels).to eq(sample_labels)
    end

    it 'validates data consistency during initialization' do
      inconsistent_data = [
        ['New York', 25, 'Y'],
        ['Chicago', 55] # Missing one column
      ]

      expect do
        described_class.new(data_items: inconsistent_data, data_labels: sample_labels)
      end.to raise_error(ArgumentError, /Inconsistent row lengths/)
    end
  end

  describe '#load_csv_with_labels' do
    let(:csv_file) { "#{File.dirname(__FILE__)}/data_set.csv" }

    context 'when CSV file exists' do
      it 'loads data from CSV file' do
        skip 'CSV file not available' unless File.exist?(csv_file)

        dataset = described_class.new.load_csv_with_labels(csv_file)
        expect(dataset.data_items).not_to be_empty
        expect(dataset.data_labels).not_to be_empty
        expect(dataset.data_items.first).to be_an(Array)
      end
    end

    context "when CSV file doesn't exist" do
      it 'raises an error' do
        expect do
          described_class.new.load_csv_with_labels('nonexistent.csv')
        end.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe '#parse_csv_with_labels' do
    let(:csv_file) { "#{File.dirname(__FILE__)}/data_set.csv" }

    context 'when CSV file exists' do
      it 'parses numeric values from CSV' do
        skip 'CSV file not available' unless File.exist?(csv_file)

        dataset = described_class.new.parse_csv_with_labels(csv_file)
        expect(dataset.data_items).not_to be_empty
        expect(dataset.data_labels).not_to be_empty

        # Check that numeric values are parsed
        numeric_values = dataset.data_items.flatten.select { |v| v.is_a?(Numeric) }
        expect(numeric_values).not_to be_empty
      end
    end
  end

  describe '#build_domains' do
    it 'builds domains for all columns' do
      domains = dataset.build_domains
      expect(domains).to have(3).items

      # City domain (categorical)
      expect(domains[0]).to be_a(Set)
      expect(domains[0]).to include('New York', 'Chicago', 'Boston')

      # Age domain (numeric range)
      expect(domains[1]).to be_an(Array)
      expect(domains[1]).to eq([12, 87])

      # Result domain (categorical)
      expect(domains[2]).to be_a(Set)
      expect(domains[2]).to include('Y', 'N')
    end

    it 'builds domain for specific column by name' do
      city_domain = dataset.build_domain('city')
      expect(city_domain).to be_a(Set)
      expect(city_domain).to include('New York', 'Chicago', 'Boston')
    end

    it 'builds domain for specific column by index' do
      age_domain = dataset.build_domain(1)
      expect(age_domain).to be_an(Array)
      expect(age_domain).to eq([12, 87])
    end

    it 'raises error for invalid column reference' do
      expect do
        dataset.build_domain('invalid_column')
      end.to raise_error(ArgumentError)
    end
  end

  describe '#set_data_labels' do
    it 'sets data labels for dataset' do
      new_labels = %w[location years outcome]
      dataset.set_data_labels(new_labels)
      expect(dataset.data_labels).to eq(new_labels)
    end

    it "raises error when labels don't match data width" do
      invalid_labels = %w[location years] # Too few labels
      expect do
        dataset.set_data_labels(invalid_labels)
      end.to raise_error(ArgumentError)
    end

    it 'allows setting labels for empty dataset' do
      empty_dataset = described_class.new
      labels = %w[col1 col2]
      empty_dataset.set_data_labels(labels)
      expect(empty_dataset.data_labels).to eq(labels)
    end
  end

  describe '#set_data_items' do
    it 'sets data items for dataset' do
      new_data = [['A', 1], ['B', 2]]
      dataset.set_data_items(new_data)
      expect(dataset.data_items).to eq(new_data)
    end

    it 'automatically generates labels when none exist' do
      empty_dataset = described_class.new
      data = [['A', 1], ['B', 2]]
      empty_dataset.set_data_items(data)
      expect(empty_dataset.data_labels).to have(2).items
    end

    it 'raises error for inconsistent row lengths' do
      inconsistent_data = [['A', 1], ['B', 2, 3]]
      expect do
        dataset.set_data_items(inconsistent_data)
      end.to raise_error(ArgumentError)
    end

    it 'raises error for invalid input types' do
      expect do
        dataset.set_data_items(nil)
      end.to raise_error(ArgumentError)

      expect do
        dataset.set_data_items([1, 2, 3]) # Not array of arrays
      end.to raise_error(ArgumentError)
    end
  end

  describe '#get_mean_or_mode' do
    it 'calculates mean for numeric columns and mode for categorical' do
      result = dataset.get_mean_or_mode
      expect(result).to have(3).items

      # Most common city
      expect(result[0]).to eq('Chicago')

      # Mean age
      expect(result[1]).to be_approximately(37.5, 0.1)

      # Most common result
      expect(result[2]).to eq('Y')
    end

    it 'handles empty dataset' do
      empty_dataset = described_class.new
      expect(empty_dataset.get_mean_or_mode).to be_empty
    end

    it 'handles single row dataset' do
      single_row_dataset = described_class.new(
        data_items: [['NYC', 30, 'Y']],
        data_labels: %w[city age result]
      )

      result = single_row_dataset.get_mean_or_mode
      expect(result).to eq(['NYC', 30, 'Y'])
    end
  end

  describe '#[] (indexing)' do
    it 'returns specific row as dataset' do
      row_dataset = dataset[0]
      expect(row_dataset).to be_a(described_class)
      expect(row_dataset.data_items).to eq([['New York', 25, 'Y']])
      expect(row_dataset.data_labels).to eq(sample_labels)
    end

    it 'returns range of rows as dataset' do
      range_dataset = dataset[1..3]
      expect(range_dataset).to be_a(described_class)
      expect(range_dataset.data_items).to have(3).items
      expect(range_dataset.data_items.first).to eq(['Chicago', 55, 'Y'])
      expect(range_dataset.data_labels).to eq(sample_labels)
    end

    it 'supports negative indices' do
      last_row = dataset[-1]
      expect(last_row.data_items).to eq([['Chicago', 87, 'Y']])
    end

    it 'returns empty dataset for out-of-bounds index' do
      empty_result = dataset[100]
      expect(empty_result.data_items).to be_empty
    end
  end

  describe '#category_label' do
    it 'returns last label as category label' do
      expect(dataset.category_label).to eq('result')
    end

    it 'returns nil for empty dataset' do
      empty_dataset = described_class.new
      expect(empty_dataset.category_label).to be_nil
    end
  end

  describe '#get_index' do
    it 'returns index for valid label' do
      expect(dataset.get_index('city')).to eq(0)
      expect(dataset.get_index('age')).to eq(1)
      expect(dataset.get_index('result')).to eq(2)
    end

    it 'raises error for invalid label' do
      expect do
        dataset.get_index('invalid')
      end.to raise_error(ArgumentError)
    end
  end

  describe 'data validation' do
    it 'validates data consistency' do
      valid_data = [
        ['A', 1, 'X'],
        ['B', 2, 'Y'],
        ['C', 3, 'Z']
      ]

      expect do
        described_class.new(data_items: valid_data, data_labels: %w[col1 col2 col3])
      end.not_to raise_error
    end

    it 'detects inconsistent row lengths' do
      invalid_data = [
        ['A', 1, 'X'],
        ['B', 2], # Missing column
        ['C', 3, 'Z']
      ]

      expect do
        described_class.new(data_items: invalid_data, data_labels: %w[col1 col2 col3])
      end.to raise_error(ArgumentError)
    end

    it 'handles empty rows gracefully' do
      data_with_empty = [
        ['A', 1, 'X'],
        [],
        ['C', 3, 'Z']
      ]

      expect do
        described_class.new(data_items: data_with_empty, data_labels: %w[col1 col2 col3])
      end.to raise_error(ArgumentError)
    end
  end

  describe 'educational features' do
    it 'provides helpful error messages for common mistakes' do
      expect do
        described_class.new(data_items: 'not an array', data_labels: sample_labels)
      end.to raise_error(ArgumentError, /data_items must be an array/)
    end

    it 'provides suggestions for data format issues' do
      expect do
        described_class.new(data_items: [1, 2, 3], data_labels: sample_labels)
      end.to raise_error(ArgumentError, /Each data item must be an array/)
    end
  end

  describe 'performance characteristics' do
    it 'handles large datasets efficiently' do
      large_data = build(:large_dataset)

      benchmark_performance('Large dataset creation') do
        described_class.new(
          data_items: large_data[:data_items],
          data_labels: large_data[:data_labels]
        )
      end
    end

    it 'performs domain building efficiently' do
      large_dataset = described_class.new(
        data_items: build(:large_dataset)[:data_items],
        data_labels: build(:large_dataset)[:data_labels]
      )

      benchmark_performance('Domain building') do
        large_dataset.build_domains
      end
    end
  end

  describe 'property-based testing' do
    it 'maintains data integrity through operations' do
      expect(dataset).to satisfy_property('data integrity') do |ds|
        original_size = ds.data_items.length
        subset = ds[0..2]

        subset.data_items.length <= original_size &&
          subset.data_labels == ds.data_labels
      end
    end

    it 'preserves structure consistency' do
      expect(dataset).to satisfy_property('structure consistency') do |ds|
        domains = ds.build_domains

        domains.length == ds.data_labels.length &&
          domains.all? { |domain| domain.respond_to?(:include?) || domain.respond_to?(:cover?) }
      end
    end
  end

  describe 'educational helpers' do
    it 'provides meaningful string representation' do
      expect(dataset.to_s).to include('DataSet')
      expect(dataset.to_s).to include('6 rows')
      expect(dataset.to_s).to include('3 columns')
    end

    it 'supports inspection for debugging' do
      expect(dataset.inspect).to include('data_items')
      expect(dataset.inspect).to include('data_labels')
    end
  end
end
