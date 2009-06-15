# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'csv'
require 'set'
require File.dirname(__FILE__) + '/statistics'
require File.dirname(__FILE__) + '/data_entry'

module Ai4r
  module Data
    class CsvDataSet < DataSet

      attr_accessor :klasses

      def load_csv_with_labels(filepath)
        super filepath

        @data_items = @data_items.map { |item| DataEntry.new(item, klass_index) }
        @klasses = @data_items.map{|di| di.klass }.uniq

        self
      end

      def klass_index
        @data_labels.index("Class") || @data_labels.length - 1
      end

    end    
  end
end

