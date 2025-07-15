require_relative '../../common/base_runner'
require 'ai4r/clusterers/single_linkage'
require_relative '../../common/metrics'

module Bench
  module Clusterer
    module Runners
      class SingleLinkageRunner < Bench::Common::BaseRunner
        def initialize(data_set, k)
          @data_set = data_set
          @original_items = data_set.data_items.dup
          @k = k
          super(nil)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          clusterer = Ai4r::Clusterers::SingleLinkage.new.build(@data_set, @k)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
          index_clusters = clusterer.clusters.map do |cluster|
            cluster.data_items.map { |item| @original_items.index(item) }
          end
          @metrics[:duration_ms] = (duration * 1000).round(2)
          @metrics[:silhouette] = clusterer.silhouette.round(2)
          Bench::Common::Metrics.new(algo_name, clusters: index_clusters,
                      sse: nil,
                      silhouette: @metrics[:silhouette],
                      duration_ms: @metrics[:duration_ms])
        end

        private

        def run; end
      end
    end
  end
end
