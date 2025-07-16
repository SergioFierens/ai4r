require_relative '../../common/base_runner'
require_relative '../../common/metrics'
require 'ai4r/clusterers/k_means'

module Bench
  module Clusterer
    module Runners
      # Benchmark runner for K-Means clustering.
      class KmeansRunner < Bench::Common::BaseRunner
        def initialize(data_set, k_value)
          @k = k_value
          super(data_set)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          clusterer = Ai4r::Clusterers::KMeans.new.build(problem, @k)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          assignments = problem.data_items.map { |item| clusterer.eval(item) }
          clusters = Array.new(@k) { [] }
          assignments.each_with_index { |c, i| clusters[c] << i }

          metrics = {
            clusters: clusters,
            sse: clusterer.sse,
            silhouette: Bench::Common.silhouette(problem, clusters),
            duration_ms: (duration * 1000).round(2),
            iterations: clusterer.iterations,
            memory_peaked: false,
            notes: "iter=#{clusterer.iterations}"
          }
          Bench::Common::Metrics.new(algo_name, metrics)
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
