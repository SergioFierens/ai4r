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
require File.dirname(__FILE__) + '/statistics'

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
        selected_items = (index.is_a?(Fixnum)) ?
                [@data_items[index]] : @data_items[index]
        return DataSet.new(:data_items => selected_items,
                           :data_labels =>@data_labels)
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
      # ruby1.8 and 1.9 safe
      def open_csv_file(filepath, &block)
        if CSV.const_defined? :Reader
          CSV::Reader.parse(File.open(filepath, 'r')) do |row|
            block.call row
          end
        else
          CSV.parse(File.open(filepath, 'r')) do |row|
            block.call row
          end
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
        index = get_index(attr)
        if @data_items.first[index].is_a?(Numeric)
          return [Statistics.min(self, index), Statistics.max(self, index)]
        else
          return @data_items.inject(Set.new){|domain, x| domain << x[index]}
        end
      end

      # Returns attributes number, including class attribute
      def num_attributes
        return (@data_items.empty?) ? 0 : @data_items.first.size
      end

      # Returns the index of a given attribute (0-based).
      # For example, if "gender" is the third attribute, then:
      #   get_index("gender") 
      #   => 2
      def get_index(attr)
        return (attr.is_a?(Fixnum) || attr.is_a?(Range)) ? attr : @data_labels.index(attr)
      end

      # Raise an exception if there is no data item.
      def check_not_empty
        if @data_items.empty?
          raise ArgumentError, "Examples data set must not be empty."
        end
      end

      # Add a data item to the data set
      def << data_item
        if data_item.nil? || !data_item.is_a?(Enumerable) || data_item.empty?
          raise ArgumentError, "Data must not be an non empty array."
        elsif @data_items.empty?
          set_data_items([data_item])
        elsif data_item.length != num_attributes
          raise ArgumentError, "Number of attributes do not match. " +
                  "#{data_item.length} attributes provided, " +
                  "#{num_attributes} attributes expected."
        else
          @data_items << data_item
        end
      end

      # Returns an array with the mean value of numeric attributes, and 
      # the most frequent value of non numeric attributes
      def get_mean_or_mode
        mean = []
        num_attributes.times do |i|
          mean[i] =
                  if @data_items.first[i].is_a?(Numeric)
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
          raise ArgumentError, "Examples data set must not be empty."
        elsif !data_items.first.is_a?(Enumerable)
          raise ArgumentError, "Unkown format for example data."
        end
        attributes_num = data_items.first.length
        data_items.each_index do |index|
          if data_items[index].length != attributes_num
            raise ArgumentError,
                  "Quantity of attributes is inconsistent. " +
                          "The first item has #{attributes_num} attributes "+
                          "and row #{index} has #{data_items[index].length} attributes"
          end
        end
      end

      def check_data_labels(labels)
        if !@data_items.empty?
          if labels.length != @data_items.first.length
            raise ArgumentError,
                  "Number of labels and attributes do not match. " +
                          "#{labels.length} labels and " +
                          "#{@data_items.first.length} attributes found."
          end
        end
      end

      def default_data_labels(data_items)
        data_labels = []
        data_items[0][0..-2].each_index do |i|
          data_labels[i] = "attribute_#{i+1}"
        end
        data_labels[data_labels.length]="class_value"
        return data_labels
      end

    end
  end
end
