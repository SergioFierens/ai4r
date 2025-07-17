# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'csv'
require 'set'
require_relative 'statistics'

module Ai4r
  module Data

    # A data set is a collection of N data items. Each data item is
    # described by a set of attributes, represented as an array.
    # Optionally, you can assign a label to the attributes, using
    # the data_labels property.
    class DataSet

      attr_reader :data_labels, :data_items

      # Create a new DataSet. By default, empty.
      # Optionaly, you can provide the initial data items and data labels.
      #
      # e.g. DataSet.new(:data_items => data_items, :data_labels => labels)
      #
      # If you provide data items, but no data labels, the data set will
      # use the default data label values (see set_data_labels)
      def initialize(options = {})
        @data_labels = []
        @data_items = options[:data_items] || []
        set_data_labels(options[:data_labels]) if options[:data_labels]
        set_data_items(options[:data_items]) if options[:data_items]
      end

      # Retrieve a new DataSet, with the item(s) selected by the provided
      # index. You can specify an index range, too.
      def [](index)
        raise ArgumentError, 'Index cannot be nil' if index.nil?
        return DataSet.new(data_items: [], data_labels: @data_labels) if @data_items.empty?

        if index.is_a?(Integer)
          # Handle negative indices Ruby-style
          actual_index = index < 0 ? @data_items.length + index : index
          
          # Return empty dataset for out-of-bounds
          return DataSet.new(data_items: [], data_labels: @data_labels) if actual_index < 0 || actual_index >= @data_items.length

          selected_items = [@data_items[actual_index]]
        else
          selected_items = @data_items[index] || []
        end

        return DataSet.new(data_items: selected_items,
                           data_labels: @data_labels)
      end

      # Load data items from csv file
      def load_csv(filepath)
        items = []
        open_csv_file(filepath) do |entry|
          items << entry
        end
        set_data_items(items)
      end

      # opens a csv-file and reads it line by line
      # for each line, a block is called and the row is passed to the block
      def open_csv_file(filepath, &block)
        CSV.parse(File.open(filepath, 'r')) do |row|
          block.call row
        end
      end

      # Load data items from csv file. The first row is used as data labels.
      def load_csv_with_labels(filepath)
        load_csv(filepath)
        @data_labels = @data_items.shift
        return self
      end

      # Same as load_csv, but it will try to convert cell contents as numbers.
      def parse_csv(filepath)
        items = []
        open_csv_file(filepath) do |row|
          items << row.collect{|x| is_number?(x) ? Float(x) : x }
        end
        set_data_items(items)
      end

      # Same as load_csv_with_labels, but it will try to convert cell contents as numbers.
      def parse_csv_with_labels(filepath)
        parse_csv(filepath)
        @data_labels = @data_items.shift
        return self
      end

      # Set data labels.
      # Data labels must have the following format:
      #     [ 'city', 'age_range', 'gender', 'marketing_target'  ]
      #
      # If you do not provide labels for you data, the following labels will
      # be created by default:
      #     [ 'attribute_1', 'attribute_2', 'attribute_3', 'class_value'  ]
      def set_data_labels(labels)
        check_data_labels(labels)
        @data_labels = labels
        return self
      end

      # Set the data items.
      # M data items with  N attributes must have the following
      # format:
      #
      #     [   [ATT1_VAL1, ATT2_VAL1, ATT3_VAL1, ... , ATTN_VAL1,  CLASS_VAL1],
      #         [ATT1_VAL2, ATT2_VAL2, ATT3_VAL2, ... , ATTN_VAL2,  CLASS_VAL2],
      #         ...
      #         [ATTM1_VALM, ATT2_VALM, ATT3_VALM, ... , ATTN_VALM, CLASS_VALM],
      #     ]
      #
      # e.g.
      #     [   ['New York',  '<30',      'M', 'Y'],
      #          ['Chicago',     '<30',      'M', 'Y'],
      #          ['Chicago',     '<30',      'F', 'Y'],
      #          ['New York',  '<30',      'M', 'Y'],
      #          ['New York',  '<30',      'M', 'Y'],
      #          ['Chicago',     '[30-50)',  'M', 'Y'],
      #          ['New York',  '[30-50)',  'F', 'N'],
      #          ['Chicago',     '[30-50)',  'F', 'Y'],
      #          ['New York',  '[30-50)',  'F', 'N'],
      #          ['Chicago',     '[50-80]', 'M', 'N'],
      #          ['New York',  '[50-80]', 'F', 'N'],
      #          ['New York',  '[50-80]', 'M', 'N'],
      #          ['Chicago',     '[50-80]', 'M', 'N'],
      #          ['New York',  '[50-80]', 'F', 'N'],
      #          ['Chicago',     '>80',      'F', 'Y']
      #        ]
      #
      # This method returns the classifier (self), allowing method chaining.
      def set_data_items(items)
        check_data_items(items)
        @data_labels = default_data_labels(items) if @data_labels.empty?
        @data_items = items
        return self
      end

      # Returns an array with the domain of each attribute:
      # * Set instance containing all possible values for nominal attributes
      # * Array with min and max values for numeric attributes (i.e. [min, max])
      #
      # Return example:
      # => [#<Set: {"New York", "Chicago"}>,
      #     #<Set: {"<30", "[30-50)", "[50-80]", ">80"}>,
      #     #<Set: {"M", "F"}>,
      #     [5, 85],
      #     #<Set: {"Y", "N"}>]
      def build_domains
        @data_labels.collect {|attr_label| build_domain(attr_label) }
      end

      # Returns a Set instance containing all possible values for an attribute
      # The parameter can be an attribute label or index (0 based).
      # * Set instance containing all possible values for nominal attributes
      # * Array with min and max values for numeric attributes (i.e. [min, max])
      #
      #   build_domain("city")
      #   => #<Set: {"New York", "Chicago"}>
      #
      #   build_domain("age")
      #   => [5, 85]
      #
      #   build_domain(2) # In this example, the third attribute is gender
      #   => #<Set: {"M", "F"}>
      def build_domain(attr)
        check_not_empty
        index = get_index(attr)
        return Set.new if @data_items.empty?

        first_item = @data_items.first
        return Set.new if first_item.nil?

        if index.is_a?(Integer)
          raise ArgumentError, "Index #{index} out of bounds" if index < 0 || index >= first_item.length
        end

        return [Statistics.min(self, index), Statistics.max(self, index)] if first_item[index].is_a?(Numeric)

        domain = Set.new
        @data_items.each do |item|
          next if item.nil? || item.length <= index

          domain << item[index] if item[index]
        end
        return domain
      end

      # Returns attributes number, including class attribute
      def num_attributes
        return 0 if @data_items.empty?

        first_item = @data_items.first
        return 0 if first_item.nil?

        return first_item.size
      end

      # Returns the index of a given attribute (0-based).
      # For example, if "gender" is the third attribute, then:
      #   get_index("gender")
      #   => 2
      def get_index(attr)
        return attr if attr.is_a?(Integer) || attr.is_a?(Range)

        index = @data_labels.index(attr)
        raise ArgumentError, "Attribute '#{attr}' not found in data labels" if index.nil?

        return index
      end

      # Raise an exception if there is no data item.
      def check_not_empty
        if @data_items.empty?
          raise ArgumentError, 'Examples data set must not be empty.'
        end
      end

      # Add a data item to the data set
      def <<(data_item)
        if data_item.nil? || !data_item.is_a?(Enumerable) || data_item.empty?
          raise ArgumentError, 'Data must not be an non empty array.'
        elsif @data_items.empty?
          set_data_items([data_item])
        elsif data_item.length != num_attributes
          raise ArgumentError,
"Number of attributes do not match. #{data_item.length} attributes provided, #{num_attributes} attributes expected."
        else
          @data_items << data_item
        end
      end

      # Returns an array with the mean value of numeric attributes, and
      # the most frequent value of non numeric attributes
      def get_mean_or_mode
        return [] if @data_items.empty?

        first_item = @data_items.first
        return [] if first_item.nil?

        mean = []
        num_attributes.times do |i|
          mean[i] =
                  if first_item[i].is_a?(Numeric)
                    Statistics.mean(self, i)
                  else
                    Statistics.mode(self, i)
                  end
        end
        return mean
      end

      # Returns label of category
      def category_label
        data_labels.last
      end

      protected

      def is_number?(x)
        true if Float(x) rescue false
      end

      def check_data_items(data_items)
        if !data_items || data_items.empty?
          raise ArgumentError, 'Examples data set must not be empty.'
        elsif !data_items.first.is_a?(Enumerable)
          raise ArgumentError, 'Unkown format for example data.'
        end

        attributes_num = data_items.first.length
        data_items.each_index do |index|
          if data_items[index].length != attributes_num
            raise ArgumentError,
                  "Quantity of attributes is inconsistent. The first item has #{attributes_num} attributes and row #{index} has #{data_items[index].length} attributes"
          end
        end
      end

      def check_data_labels(labels)
        return if @data_items.empty?

        if labels.length != @data_items.first.length
          raise ArgumentError,
                "Number of labels and attributes do not match. #{labels.length} labels and #{@data_items.first.length} attributes found."
        end
      end

      def default_data_labels(data_items)
        return [] if data_items.nil? || data_items.empty?

        first_item = data_items[0]
        return [] if first_item.nil? || first_item.empty?

        data_labels = []
        first_item[0..-2].each_index do |i|
          data_labels[i] = "attribute_#{i+1}"
        end
        data_labels[data_labels.length]='class_value'
        return data_labels
      end

      # Returns a human-readable string representation of the dataset
      def to_s
        "#<#{self.class.name}: #{@data_items.length} rows, #{@data_labels.length} columns>"
      end

      # Returns detailed inspection string for debugging
      def inspect
        "#<#{self.class.name}:0x#{object_id.to_s(16)} @data_items=#{@data_items.length} rows, @data_labels=#{@data_labels.inspect}>"
      end

    end
  end
end
