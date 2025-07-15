#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../common/cli'
require 'ai4r/data/data_set'
require_relative 'runners/kmeans_runner'
require_relative 'runners/single_linkage_runner'
require_relative 'runners/average_linkage_runner'
require_relative 'runners/diana_runner'

module Bench
  module Clusterer
    CLUSTER_METRICS = %i[silhouette sse duration_ms iterations].freeze

    RUNNERS = {
      'kmeans' => Runners::KmeansRunner,
      'single_linkage' => Runners::SingleLinkageRunner,
      'average_linkage' => Runners::AverageLinkageRunner,
      'diana' => Runners::DianaRunner
    }.freeze

    DEFAULT_DATASET = File.join(__dir__, 'datasets', 'blobs.csv')

    module_function

    def run(argv)
      cli = Bench::Common::CLI.new('clusterer', RUNNERS.keys, CLUSTER_METRICS) do |opts, options|
        opts.on('--dataset FILE', 'CSV dataset') { |v| options[:dataset] = v }
        opts.on('--k N', Integer, 'Number of clusters') { |v| options[:k] = v }
        opts.on('--with-ground-truth', 'Ignore last column label') { options[:gt] = true }
      end
      options = cli.parse(argv)
      raise ArgumentError, 'Please select algorithms with --algos' if options[:algos].empty?

      data_set = Ai4r::Data::DataSet.new
      data_set.load_csv(options[:dataset] || DEFAULT_DATASET, parse_numeric: true)
      data_set.data_items.each { |row| row.pop if options[:gt] }

      k = options[:k] || 3

      results = options[:algos].map do |name|
        runner = RUNNERS[name].new(data_set, k)
        runner.call
      end
      cli.report(results, options[:export])
    end
  end
end

Bench::Clusterer.run(ARGV) if $PROGRAM_NAME == __FILE__
