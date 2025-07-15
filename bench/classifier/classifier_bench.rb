#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require_relative '../common/cli'
require_relative 'runners/id3_runner'
require_relative 'runners/naive_bayes_runner'
require_relative 'runners/ib1_runner'
require_relative 'runners/hyperpipes_runner'

module Bench
  module Classifier
    CLASSIFIER_METRICS = %i[accuracy f1 training_ms predict_ms model_size_kb].freeze

    RUNNERS = {
      'id3' => Runners::Id3Runner,
      'naive_bayes' => Runners::NaiveBayesRunner,
      'ib1' => Runners::Ib1Runner,
      'hyperpipes' => Runners::HyperpipesRunner
    }.freeze

    module_function

    def load_dataset(path)
      Ai4r::Data::DataSet.new.parse_csv_with_labels(path)
    end

    def run(argv)
      cli = Bench::Common::CLI.new('classifier', RUNNERS.keys, CLASSIFIER_METRICS) do |opts, options|
        opts.on('--dataset FILE', 'CSV data file') { |v| options[:dataset] = v }
        opts.on('--split RATIO', Float, 'Test split ratio') { |v| options[:split] = v }
      end
      options = cli.parse(argv)

      raise ArgumentError, 'Please select algorithms with --algos' if options[:algos].empty?

      path = options[:dataset] || File.join(__dir__, 'datasets', 'iris.csv')
      data_set = load_dataset(path)
      train_ratio = 1.0 - (options[:split] || 0.3)
      train_set, test_set = data_set.split(ratio: train_ratio)

      results = options[:algos].map do |name|
        RUNNERS[name].new(train_set, test_set).call
      end
      cli.report(results, options[:export])
    end
  end
end

Bench::Classifier.run(ARGV) if $PROGRAM_NAME == __FILE__
