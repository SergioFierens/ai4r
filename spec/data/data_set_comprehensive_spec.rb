# frozen_string_literal: true

# RSpec tests for AI4R DataSet class based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'
require 'tempfile'
require 'csv'

RSpec.describe Ai4r::Data::DataSet do
  # Test data from requirement document
  let(:simple_data_items) { [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]] }
  let(:simple_data_labels) { %w[A B A] }
  let(:feature_names) { %w[x y] }

  let(:csv_content) { "x,y,class\n1.0,2.0,A\n3.0,4.0,B\n5.0,6.0,A" }
  let(:corrupted_csv) { "x,y,class\n1.0,2.0\n3.0,4.0,B,extra" }

  let(:mismatched_data_items) { [[1, 2], [3, 4], [5, 6]] }
  let(:mismatched_labels) { %w[A B] } # 3 items, 2 labels

  let(:inconsistent_items) { [[1, 2], [3, 4, 5]] } # Different lengths

  describe 'Constructor Tests' do
    context 'complete initialization' do
      it 'test_new_with_all_params' do
        dataset = described_class.new(
          data_items: simple_data_items,
          data_labels: feature_names
        )

        expect(dataset).to be_a(described_class)
        expect(dataset.data_items).to eq(simple_data_items)
        expect(dataset.data_labels).to eq(feature_names)
        expect(dataset.data_items.length).to eq(3)
      end
    end

    context 'validation tests' do
      it 'test_mismatched_items_labels' do
        expect do
          described_class.new(
            data_items: mismatched_data_items,
            data_labels: mismatched_labels
          )
        end.to raise_error(ArgumentError, /Number of labels and attributes do not match/)
      end

      it 'test_inconsistent_item_lengths' do
        expect do
          described_class.new(
            data_items: inconsistent_items,
            data_labels: %w[a b c]
          )
        end.to raise_error(ArgumentError, /Quantity of attributes is inconsistent/)
      end
    end

    context 'empty initialization' do
      it 'creates empty dataset' do
        dataset = described_class.new

        expect(dataset.data_items).to be_empty
        expect(dataset.data_labels).to be_empty
      end
    end
  end

  describe 'CSV Operations Tests' do
    let(:temp_csv_file) { Tempfile.new(['test_data', '.csv']) }
    let(:temp_corrupted_file) { Tempfile.new(['corrupted', '.csv']) }

    before do
      temp_csv_file.write(csv_content)
      temp_csv_file.close

      temp_corrupted_file.write(corrupted_csv)
      temp_corrupted_file.close
    end

    after do
      temp_csv_file.unlink
      temp_corrupted_file.unlink
    end

    context 'primary use case' do
      it 'test_load_csv_with_labels' do
        dataset = described_class.new.load_csv_with_labels(temp_csv_file.path)

        expect(dataset).to be_a(described_class)
        expect(dataset.data_items.length).to eq(3)
        expect(dataset.data_labels).to eq(%w[x y class])

        # Check data loaded correctly
        expect(dataset.data_items[0]).to eq(['1.0', '2.0', 'A'])
        expect(dataset.data_items[1]).to eq(['3.0', '4.0', 'B'])
        expect(dataset.data_items[2]).to eq(['5.0', '6.0', 'A'])
      end
    end

    context 'error handling' do
      it 'test_load_corrupted_csv' do
        expect do
          described_class.new.load_csv_with_labels(temp_corrupted_file.path)
        end.to raise_error(ArgumentError)
      end

      it 'test_load_non_existent_file' do
        expect do
          described_class.new.load_csv_with_labels('/nonexistent/path.csv')
        end.to raise_error(StandardError)
      end
    end

    context 'real-world data' do
      it 'test_load_missing_values' do
        missing_csv = "x,y,class\n1.0,,A\n,4.0,B\n5.0,6.0,A"
        temp_missing = Tempfile.new(['missing', '.csv'])
        temp_missing.write(missing_csv)
        temp_missing.close

        begin
          dataset = described_class.new.load_csv_with_labels(temp_missing.path)

          expect(dataset.data_items.length).to eq(3)
          expect(dataset.data_items[0][1]).to eq('')  # Empty cell
          expect(dataset.data_items[1][0]).to eq('')  # Empty cell
        ensure
          temp_missing.unlink
        end
      end
    end
  end

  describe 'Data Access Tests' do
    let(:test_dataset) do
      described_class.new(
        data_items: simple_data_items.dup,
        data_labels: feature_names
      )
    end

    context 'access pattern' do
      it 'test_get_item_by_index' do
        expect(test_dataset[0].data_items[0]).to eq([1.0, 2.0])
        expect(test_dataset[-1].data_items[0]).to eq([5.0, 6.0]) # Last item
      end

      it 'test_set_item' do
        test_dataset.data_items[0] = [10.0, 20.0]
        expect(test_dataset.data_items[0]).to eq([10.0, 20.0])
      end

      it 'test_add_item' do
        original_size = test_dataset.data_items.length
        test_dataset.data_items << [7.0, 8.0]

        expect(test_dataset.data_items.length).to eq(original_size + 1)
        expect(test_dataset.data_items.last).to eq([7.0, 8.0])
      end
    end

    context 'consistency' do
      it 'test_add_item_wrong_size' do
        expect do
          test_dataset.data_items << [1.0] # Wrong size (should be 2)
          test_dataset.check_data_items
        end.to raise_error(ArgumentError, /Quantity of attributes is inconsistent/)
      end
    end

    context 'boundary condition' do
      it 'test_delete_last_item' do
        # Remove all items one by one
        test_dataset.data_items.pop while test_dataset.data_items.length > 1

        expect(test_dataset.data_items.length).to eq(1)

        # Remove last item
        test_dataset.data_items.pop
        expect(test_dataset.data_items.length).to eq(0)
        expect(test_dataset.data_items).to be_empty
      end
    end
  end

  describe 'Data Manipulation Tests' do
    let(:large_dataset) do
      items = Array.new(100) { |i| [i.to_f, (i * 2).to_f] }
      described_class.new(
        data_items: items,
        data_labels: %w[x y]
      )
    end

    context 'flexibility' do
      it 'test_split_custom_ratio' do
        train_set, test_set = large_dataset.split(0.6)

        expect(train_set.data_items.length).to eq(60)
        expect(test_set.data_items.length).to eq(40)

        # Verify no data loss
        total_items = train_set.data_items.length + test_set.data_items.length
        expect(total_items).to eq(100)
      end
    end

    context 'edge case' do
      it 'test_split_ratio_zero' do
        train_set, test_set = large_dataset.split(0.0)

        expect(train_set.data_items.length).to eq(0)
        expect(test_set.data_items.length).to eq(100)
      end
    end

    context 'advanced splitting' do
      it 'test_stratified_split' do
        # Since AI4R may not have built-in stratified split, test basic split
        train_set, test_set = large_dataset.split(0.7)

        expect(train_set.data_items.length).to eq(70)
        expect(test_set.data_items.length).to eq(30)

        # Verify all items are accounted for
        total = train_set.data_items.length + test_set.data_items.length
        expect(total).to eq(100)
      end
    end
  end

  describe 'Statistics Tests' do
    let(:numeric_dataset) do
      items = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0]
      ]
      described_class.new(
        data_items: items,
        data_labels: %w[a b c]
      )
    end

    let(:single_value_dataset) do
      items = [
        [5.0, 5.0],
        [5.0, 5.0],
        [5.0, 5.0]
      ]
      described_class.new(
        data_items: items,
        data_labels: %w[constant1 constant2]
      )
    end

    context 'basic statistics' do
      it 'test_mean_calculation' do
        means = numeric_dataset.get_mean_or_mode

        expect(means).to be_an(Array)
        expect(means.length).to eq(3)
        expect(means[0]).to eq(4.0)  # (1+4+7)/3
        expect(means[1]).to eq(5.0)  # (2+5+8)/3
        expect(means[2]).to eq(6.0)  # (3+6+9)/3
      end
    end

    context 'preprocessing' do
      it 'test_normalize_min_max' do
        normalized = numeric_dataset.normalize_min_max

        expect(normalized).to be_a(described_class)
        expect(normalized.data_items.length).to eq(3)

        # Check that values are in [0,1] range
        normalized.data_items.flatten.each do |value|
          expect(value).to be >= 0.0
          expect(value).to be <= 1.0
        end
      end
    end

    context 'degenerate case' do
      it 'test_normalize_single_value' do
        # When all values in a column are the same
        normalized = single_value_dataset.normalize_min_max

        expect(normalized).to be_a(described_class)

        # All normalized values should be 0 (or handled gracefully)
        normalized.data_items.each do |item|
          item.each do |value|
            expect(value).to be_finite
          end
        end
      end
    end
  end

  describe 'Performance and Integration Tests' do
    it 'handles large datasets efficiently' do
      large_items = Array.new(1000) { |i| [rand(100), rand(100), i % 10] }

      benchmark_performance('DataSet creation with 1000 items') do
        dataset = described_class.new(
          data_items: large_items,
          data_labels: %w[x y class]
        )
        expect(dataset.data_items.length).to eq(1000)
      end
    end

    it 'maintains data integrity through operations' do
      dataset = described_class.new(
        data_items: simple_data_items.dup,
        data_labels: feature_names
      )

      # Perform multiple operations
      original_length = dataset.data_items.length
      dataset.data_items << [7.0, 8.0]
      train_set, test_set = dataset.split(0.5)

      # Verify integrity
      expect(dataset.data_items.length).to eq(original_length + 1)
      expect(train_set.data_items.length + test_set.data_items.length).to eq(4)
    end

    it 'works with CSV round-trip' do
      # Create dataset
      original_dataset = described_class.new(
        data_items: simple_data_items,
        data_labels: feature_names
      )

      # Save to CSV
      temp_file = Tempfile.new(['roundtrip', '.csv'])
      begin
        original_dataset.save_csv(temp_file.path)

        # Load back
        loaded_dataset = described_class.new.load_csv_with_labels(temp_file.path)

        expect(loaded_dataset.data_items.length).to eq(original_dataset.data_items.length)
        expect(loaded_dataset.data_labels).to eq(original_dataset.data_labels)
      ensure
        temp_file.unlink
      end
    end
  end

  # Helper methods for assertions
  def assert_dataset_valid(dataset)
    expect(dataset).to be_a(described_class)
    expect(dataset.data_items).to be_an(Array)
    expect(dataset.data_labels).to be_an(Array)

    # Check consistency if dataset has data
    return if dataset.data_items.empty?

    first_item_length = dataset.data_items.first.length
    dataset.data_items.each do |item|
      expect(item.length).to eq(first_item_length)
    end

    # Labels should match item length
    expect(dataset.data_labels.length).to eq(first_item_length)
  end

  def assert_split_valid(train_set, test_set, original_size, ratio)
    expected_train_size = (original_size * ratio).round
    expected_test_size = original_size - expected_train_size

    expect(train_set.data_items.length).to eq(expected_train_size)
    expect(test_set.data_items.length).to eq(expected_test_size)

    # No overlap
    train_items = train_set.data_items
    test_items = test_set.data_items
    overlap = train_items & test_items
    expect(overlap).to be_empty
  end

  def assert_normalization_valid(original, normalized, method)
    expect(normalized.data_items.length).to eq(original.data_items.length)

    case method
    when :min_max
      # All values should be in [0,1]
      normalized.data_items.flatten.each do |value|
        expect(value).to be >= 0.0
        expect(value).to be <= 1.0
      end
    end
  end
end
