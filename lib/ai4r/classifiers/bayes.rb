require 'set'
require File.dirname(__FILE__) + '/../data/csv_data_set'
require File.dirname(__FILE__) + '/../classifiers/classifier'

module Ai4r
  module Classifiers
    class Bayes < Classifier

      def initialize(data)
        raise "Error instance must be passed" unless data.is_a?(DataSet)

        @data = data
        build data
      end

      def build(data)
        calculate_class_probabilities
      end

      private

      def calculate_class_probabilities

        @class_counts = {}
        @data.klasses.each {|dl| @class_counts[dl] = 0}

        @data.data_items.each do |entry|
            @class_counts[entry.klass] += 1
        end

      end

    end
  end
end
