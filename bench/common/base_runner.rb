require_relative 'metrics'

module Bench
  module Common
    # Base class for algorithm runners collecting simple metrics.
    class BaseRunner
      attr_reader :problem

      def initialize(problem)
        @problem = problem
        @metrics = {}
      end

      # Execute the algorithm and return a Metrics object.
      def call
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        path = run
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
        @metrics[:duration_ms] = (duration * 1000).round(2)
        @metrics[:solution_depth] = path ? path.length - 1 : nil
        @metrics[:completed] = !path.nil?
        Metrics.new(algo_name, @metrics)
      end

      private

      # Overridden by subclasses to perform the search.
      def run
        raise NotImplementedError
      end

      # Helper called by subclasses when expanding a node.
      def expand
        @metrics[:nodes_expanded] = @metrics.fetch(:nodes_expanded, 0) + 1
      end

      # Helper called by subclasses to update frontier size.
      def frontier_size(size)
        current = @metrics.fetch(:max_frontier_size, 0)
        @metrics[:max_frontier_size] = size if size > current
      end

      def algo_name
        self.class.name.split('::').last.sub(/Runner$/, '').downcase
      end
    end
  end
end
