require_relative '../../common/base_runner'
require_relative '../../common/metrics'
require 'ai4r/clusterers/diana'

module Bench
  module Clusterer
    module Runners
      class DianaRunner < Bench::Common::BaseRunner
        def initialize(data_set, k)
          @k = k
          super(data_set)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          data_copy = Ai4r::Data::DataSet.new(
            data_items: problem.data_items.map(&:dup)
          )
          clusterer = Ai4r::Clusterers::Diana.new.build(data_copy, @k)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          assignments = problem.data_items.map { |item| clusterer.eval(item) }
          clusters = Array.new(@k) { [] }
          assignments.each_with_index { |c, i| clusters[c] << i }

          metrics = {
            clusters: clusters,
            sse: nil,
            silhouette: Bench::Common.silhouette(problem, clusters),
            duration_ms: (duration * 1000).round(2),
            iterations: nil,
            memory_peaked: false,
            notes: 'divisive'
          }
          Bench::Common::Metrics.new(algo_name, metrics)
        end
      end
    end
  end
end
