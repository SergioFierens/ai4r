# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'

module Ai4r
  module Experiment
    # Utility methods for experiment workflows.
    module Split
      module_function

      # Split a dataset into +k+ folds.
      # @param data_set [Ai4r::Data::DataSet] dataset to split
      # @param k [Integer] number of folds
      # @return [Array<Ai4r::Data::DataSet>] list of folds
      def split(data_set, k:)
        raise ArgumentError, 'k must be greater than 0' unless k.positive?

        items = data_set.data_items.dup
        labels = data_set.data_labels
        fold_size = (items.length.to_f / k).ceil
        folds = []
        k.times do |i|
          part = items.slice(i * fold_size, fold_size) || []
          folds << Ai4r::Data::DataSet.new(data_items: part, data_labels: labels)
        end
        folds
      end
    end
  end
end
