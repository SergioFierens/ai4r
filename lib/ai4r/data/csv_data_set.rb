# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/data_set'
require File.dirname(__FILE__) + '/data_entry'

module Ai4r
  module Data

    # extends the class DataSet by adding the entries into an instance of DataEntry
    # overrides data_items with instances of DataEntry
    # stores all the classes in the attribute classes
    # cleans the labels and data by removing the Class-column
    # if the label Class is not given, the last column is used as class
    class CsvDataSet < DataSet

      attr_accessor :klasses

      def load_csv_with_labels(filepath)
        super filepath

        @data_items.map! { |item| DataEntry.new(item, klass_index) }
        clean_labels
        @klasses = @data_items.map{|di| di.klass }.uniq

        self
      end

      private

      # removes the Class-column from the labels
      def clean_labels
        @data_labels.delete_at klass_index
      end

      # returns the column index of the Class-column in the data
      # if the label Class is not given, the last column is used as class
      def klass_index
        @data_labels.index("Class") || @data_labels.length - 1
      end

    end    
  end
end

