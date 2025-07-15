require_relative '../../common/base_runner'
require 'ai4r/clusterers/k_means'
require 'ai4r/data/data_set'
require_relative '../../common/metrics'

module Bench
  module Clusterer
    module Runners
      class KmeansRunner < Bench::Common::BaseRunner
        def initialize(data_set, k)
          @data_set = data_set
          @original_items = data_set.data_items.dup
          @k = k
          super(nil)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          clusterer = Ai4r::Clusterers::KMeans.new.build(@data_set, @k)
          index_clusters = Array.new(@k) { [] }
          @original_items.each_with_index do |item, idx|
            c = clusterer.eval(item)
            index_clusters[c] << idx
          end
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
          @metrics[:duration_ms] = (duration * 1000).round(2)
          @metrics[:iterations] = clusterer.iterations
          @metrics[:sse] = clusterer.sse.round(4)
          orig_set = Ai4r::Data::DataSet.new(data_items: @original_items)
          @metrics[:silhouette] = Bench::Common.silhouette(orig_set, index_clusters).round(2)
          Bench::Common::Metrics.new(algo_name, clusters: index_clusters,
                      sse: @metrics[:sse],
                      silhouette: @metrics[:silhouette],
                      duration_ms: @metrics[:duration_ms],
                      iterations: clusterer.iterations)
        end

        private

        def run; end
      end
    end
  end
end
