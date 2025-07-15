#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require_relative '../common/cli'
require_relative 'runners/logistic_regression_runner'
require_relative 'runners/naive_bayes_runner'

module Bench
  module Classifier
    CLASS_METRICS = %i[accuracy duration_ms].freeze

    RUNNERS = {
      'logistic_regression' => Runners::LogisticRegressionRunner,
      'naive_bayes' => Runners::NaiveBayesRunner
    }.freeze

    module_function

    def load_dataset(path)
      Ai4r::Data::DataSet.new.parse_csv_with_labels(path)
    end

    def run(argv)
      cli = Bench::Common::CLI.new('classifier', RUNNERS.keys, CLASS_METRICS) do |opts, options|
        opts.on('--dataset FILE', 'CSV data file') { |v| options[:dataset] = v }
        opts.on('--train-ratio R', Float, 'Training set ratio') { |v| options[:train_ratio] = v }
      end
      options = cli.parse(argv)

      raise ArgumentError, 'Please select algorithms with --algos' if options[:algos].empty?

      path = options[:dataset] || File.join(__dir__, 'datasets', 'logreg.csv')
      data_set = load_dataset(path)
      data_set.shuffle!
      train_ratio = options[:train_ratio] || 0.7
      train_set, test_set = data_set.split(ratio: train_ratio)

      results = options[:algos].map do |name|
        runner = RUNNERS[name].new(train_set, test_set)
        runner.call
      end
      cli.report(results, options[:export])
    end
  end
end

Bench::Classifier.run(ARGV) if $PROGRAM_NAME == __FILE__
