#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../../lib', __dir__))
require 'ai4r'
require 'csv'

$LOAD_PATH.unshift(File.expand_path('../../lib', __dir__))

require_relative '../common/cli'
require_relative 'runners/kmeans_runner'
require_relative 'runners/single_linkage_runner'
require_relative 'runners/average_linkage_runner'
require_relative 'runners/diana_runner'
require_relative 'runners/dbscan_runner'

# Benchmark runners for clustering algorithms
module Bench
  # Namespace for clustering benchmark runners
  module Clusterer
    CLUSTER_METRICS = %i[silhouette sse duration_ms notes].freeze

    RUNNERS = {
      'kmeans' => Runners::KmeansRunner,
      'single_linkage' => Runners::SingleLinkageRunner,
      'average_linkage' => Runners::AverageLinkageRunner,
      'diana' => Runners::DianaRunner,
      'dbscan' => Runners::DbscanRunner
    }.freeze

    module_function

    def load_dataset(path, with_labels)
      data = []
      CSV.foreach(path) do |row|
        row = row.map(&:to_f)
        data << (with_labels ? row[0...-1] : row)
      end
      Ai4r::Data::DataSet.new(data_items: data)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    def run(argv)
      cli = Bench::Common::CLI.new('clusterer', RUNNERS.keys, CLUSTER_METRICS) do |opts, options|
        opts.on('--dataset FILE', 'CSV data file') { |v| options[:dataset] = v }
        opts.on('--k N', Integer, 'Number of clusters') { |v| options[:k] = v }
        opts.on('--epsilon N', Float, 'DBSCAN squared radius') { |v| options[:epsilon] = v }
        opts.on('--min-points N', Integer,
                'DBSCAN minimum neighbours') { |v| options[:min_points] = v }
        opts.on('--with-ground-truth', 'Use labels column') { options[:with_gt] = true }
      end
      options = cli.parse(argv)

      raise ArgumentError, 'Please select algorithms with --algos' if options[:algos].empty?

      path = options[:dataset] || File.join(__dir__, 'datasets', 'blobs.csv')
      data_set = load_dataset(path, options[:with_gt])
      k = options[:k] || 3

      results = options[:algos].map do |name|
        runner = case name
                 when 'dbscan'
                   eps = options[:epsilon] || 4.0
                   min_p = options[:min_points] || 3
                   RUNNERS[name].new(data_set, eps, min_p)
                 else
                   RUNNERS[name].new(data_set, k)
                 end
        runner.call
      end
      cli.report(results, options[:export])
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  end
end

Bench::Clusterer.run(ARGV) if $PROGRAM_NAME == __FILE__
