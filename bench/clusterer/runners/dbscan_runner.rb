# frozen_string_literal: true

require_relative '../../common/base_runner'
require_relative '../../common/metrics'
require 'ai4r/clusterers/dbscan'

module Bench
  module Clusterer
    module Runners
      # Benchmark runner for DBSCAN clustering.
      class DbscanRunner < Bench::Common::BaseRunner
        def initialize(data_set, epsilon, min_points)
          @epsilon = epsilon
          @min_points = min_points
          super(data_set)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          clusterer = Ai4r::Clusterers::DBSCAN.new
          clusterer.set_parameters(epsilon: @epsilon, min_points: @min_points)
                   .build(problem)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          clusters = clusterer.cluster_indices
          metrics = {
            clusters: clusters,
            sse: nil,
            silhouette: Bench::Common.silhouette(problem, clusters),
            duration_ms: (duration * 1000).round(2),
            iterations: nil,
            memory_peaked: false,
            notes: "eps=#{@epsilon}"
          }
          Bench::Common::Metrics.new(algo_name, metrics)
        end
      end
    end
  end
end
