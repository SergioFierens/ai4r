require_relative '../../common/base_runner'
require_relative '../../common/metrics'
require 'ai4r/clusterers/average_linkage'

module Bench
  module Clusterer
    module Runners
      class AverageLinkageRunner < Bench::Common::BaseRunner
        def initialize(data_set, k)
          @k = k
          super(data_set)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          clusterer = Ai4r::Clusterers::AverageLinkage.new.build(problem, @k)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          clusters = clusterer.instance_variable_get(:@index_clusters)
          metrics = {
            clusters: clusters,
            sse: nil,
            silhouette: clusterer.silhouette,
            duration_ms: (duration * 1000).round(2),
            iterations: nil,
            memory_peaked: true,
            notes: 'memory\u25B2'
          }
          Bench::Common::Metrics.new(algo_name, metrics)
        end
      end
    end
  end
end
