# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../test_helper'
require 'ai4r/data/data_set'

module Ai4r
  module Data
    class DataSetTest < Minitest::Test
      def test_load_csv_with_labels
        set = DataSet.new.load_csv_with_labels("#{File.dirname(__FILE__)}/data_set.csv")
        assert_equal 120, set.data_items.length
        assert_equal %w[zone rooms size price], set.data_labels
        assert_equal ['Moron Sur (GBA)', '2', '[28 m2 - 39 m2]', '[29K-35K]'], set.data_items.first

        set = DataSet.new.load_csv_with_labels("#{File.dirname(__FILE__)}/data_set.csv",
                                               parse_numeric: true)
        assert_equal ['Moron Sur (GBA)', 2.0, '[28 m2 - 39 m2]', '[29K-35K]'], set.data_items.first
      end

      def test_parse_csv_with_labels
        set = DataSet.new.parse_csv_with_labels("#{File.dirname(__FILE__)}/data_set.csv")
        assert_equal 120, set.data_items.length
        assert_equal %w[zone rooms size price], set.data_labels
        assert_equal ['Moron Sur (GBA)', 2.0, '[28 m2 - 39 m2]', '[29K-35K]'], set.data_items.first
      end

      def test_open_csv_file
        rows = []
        DataSet.new.open_csv_file("#{File.dirname(__FILE__)}/data_set.csv") do |row|
          rows << row
        end
        assert_equal 121, rows.length
        assert_equal %w[zone rooms size price], rows.first
      end

      def test_build_domains
        domains = [Set.new(['New York', 'Chicago']),
                   Set.new(%w[M F]),
                   [5, 85],
                   Set.new(%w[Y N])]
        data = [['New York', 'M', 23, 'Y'],
                ['Chicago', 'M', 85, 'Y'],
                ['New York', 'F', 32, 'Y'],
                ['New York', 'M', 5, 'N'],
                ['Chicago', 'M', 15, 'N'],
                ['Chicago', 'F', 45, 'Y']]
        labels = %w[city gender age result]
        set = DataSet.new({ data_items: data, data_labels: labels })
        assert_equal domains, set.build_domains
        assert_equal domains[0], set.build_domain('city')
        assert_equal domains[1], set.build_domain(1)
        assert_equal domains[2], set.build_domain('age')
        assert_equal domains[3], set.build_domain('result')
      end

      def test_set_data_labels
        labels = %w[A B]
        set = DataSet.new.set_data_labels(labels)
        assert_equal labels, set.data_labels
        set = DataSet.new(data_labels: labels)
        assert_equal labels, set.data_labels
        set = DataSet.new(data_items: [[1, 2, 3]])
        assert_raises(ArgumentError) { set.set_data_labels(labels) }
      end

      def test_set_data_items
        items = [['New York', 'M', 'Y'],
                 ['Chicago', 'M', 'Y'],
                 ['New York', 'F', 'Y'],
                 ['New York', 'M', 'N'],
                 ['Chicago', 'M', 'N'],
                 ['Chicago', 'F', 'Y']]
        set = DataSet.new.set_data_items(items)
        assert_equal items, set.data_items
        assert_equal 3, set.data_labels.length
        items << items.first[0..-2]
        assert_raises(ArgumentError) { set.set_data_items(items) }
        assert_raises(ArgumentError) { set.set_data_items(nil) }
        assert_raises(ArgumentError) { set.set_data_items([1]) }
      end

      def test_get_mean_or_mode
        items = [['New York', 25, 'Y'],
                 ['New York', 55, 'Y'],
                 ['Chicago', 23, 'Y'],
                 ['Boston', 23, 'N'],
                 ['Chicago', 12, 'N'],
                 ['Chicago', 87, 'Y']]
        set = DataSet.new.set_data_items(items)
        assert_equal ['Chicago', 37.5, 'Y'], set.get_mean_or_mode
      end

      def test_index
        items = [['New York', 25, 'Y'],
                 ['New York', 55, 'Y'],
                 ['Chicago', 23, 'Y'],
                 ['Boston', 23, 'N'],
                 ['Chicago', 12, 'N'],
                 ['Chicago', 87, 'Y']]
        set = DataSet.new.set_data_items(items)
        assert_equal set.data_labels, set[0].data_labels
        assert_equal [['New York', 25, 'Y']], set[0].data_items
        assert_equal [['Chicago', 23, 'Y'], ['Boston', 23, 'N']], set[2..3].data_items
        assert_equal items[1..], set[1..].data_items
      end

      def test_category_label
        labels = ['Feature_1', 'Feature_2', 'Category Label']
        set = DataSet.new(data_labels: labels)
        assert_equal 'Category Label', set.category_label
      end

      def test_normalize_inplace
        items = [['A', 10], ['B', 20], ['C', 30]]
        labels = %w[name value]
        set = DataSet.new(data_items: items, data_labels: labels)
        set.normalize!(:zscore)
        assert_equal [['A', -1.0], ['B', 0.0], ['C', 1.0]], set.data_items
      end

      def test_normalized_returns_new_dataset
        items = [['A', 10, 'x'], ['B', 20, 'y'], ['A', 30, 'z']]
        labels = %w[city num class]
        set = DataSet.new(data_items: items, data_labels: labels)
        copy = DataSet.normalized(set, method: :minmax)
        assert_equal items, set.data_items
        assert_equal [['A', 0.0, 'x'], ['B', 0.5, 'y'], ['A', 1.0, 'z']], copy.data_items
      end

      def test_shuffle_deterministic
        items = [[1], [2], [3], [4]]
        set = DataSet.new(data_items: items, data_labels: ['val'])
        expected = items.shuffle(random: Random.new(5))
        result = set.shuffle!(seed: 5)
        assert_equal set, result
        assert_equal expected, set.data_items
      end

      def test_split_ratio
        items = (1..5).map { |i| [i] }
        labels = ['v']
        set = DataSet.new(data_items: items, data_labels: labels)
        first, second = set.split(ratio: 0.6)
        assert_equal items, set.data_items
        assert_equal [[1], [2], [3]], first.data_items
        assert_equal [[4], [5]], second.data_items
        assert_equal labels, first.data_labels
        assert_equal labels, second.data_labels
      end
    end
  end
end
