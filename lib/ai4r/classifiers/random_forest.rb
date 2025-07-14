# frozen_string_literal: true

# Author::    OpenAI ChatGPT
# License::   MPL 1.1
# Project::   ai4r
#
# A simple Random Forest implementation using ID3 decision trees.

require_relative 'id3'
require_relative '../data/data_set'
require_relative '../classifiers/classifier'
require_relative 'votes'

module Ai4r
  module Classifiers
    class RandomForest < Classifier
      parameters_info n_trees: 'Number of trees to build. Default 10.',
                      sample_size: 'Number of data items for each tree (with replacement). Default: data set size.',
                      feature_fraction: 'Fraction of attributes sampled for each tree. Default: sqrt(num_attributes)/num_attributes.',
                      random_seed: 'Seed for reproducible randomness.'

      attr_reader :trees, :features

      def initialize
        @n_trees = 10
        @sample_size = nil
        @feature_fraction = nil
        @random_seed = nil
      end

      def build(data_set)
        data_set.check_not_empty
        rng = @random_seed ? Random.new(@random_seed) : Random.new
        num_attributes = data_set.data_labels.length - 1
        frac = @feature_fraction || (Math.sqrt(num_attributes) / num_attributes)
        feature_count = [1, (num_attributes * frac).round].max
        @sample_size ||= data_set.data_items.length
        @trees = []
        @features = []
        @n_trees.times do
          sampled = Array.new(@sample_size) { data_set.data_items.sample(random: rng) }
          feature_idx = (0...num_attributes).to_a.sample(feature_count, random: rng)
          tree_items = sampled.map do |item|
            values = feature_idx.map { |i| item[i] }
            values + [item.last]
          end
          labels = feature_idx.map { |i| data_set.data_labels[i] } + [data_set.data_labels.last]
          ds = Ai4r::Data::DataSet.new(data_items: tree_items, data_labels: labels)
          @trees << ID3.new.build(ds)
          @features << feature_idx
        end
        self
      end

      def eval(data)
        votes = Votes.new
        @trees.each_with_index do |tree, idx|
          sub_data = @features[idx].map { |i| data[i] }
          votes.increment_category(tree.eval(sub_data))
        end
        votes.get_winner
      end

      def get_rules
        'RandomForest does not support rule extraction.'
      end
    end
  end
end
