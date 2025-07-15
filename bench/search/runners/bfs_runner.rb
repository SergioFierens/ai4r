require_relative '../../common/base_runner'

module Bench
  module Search
    module Runners
      # Breadth-first search runner.
      class BfsRunner < Bench::Common::BaseRunner
        def initialize(problem, max_depth = nil)
          super(problem)
          @max_depth = max_depth
        end

        private

        def run
          start = problem.start_state
          queue = [[start, [start], 0]]
          visited = { start => true }
          until queue.empty?
            frontier_size(queue.size)
            node, path, depth = queue.shift
            return path if problem.goal?(node)
            next if @max_depth && depth >= @max_depth
            expand
            problem.neighbors(node).each_key do |nbr|
              next if visited[nbr]
              visited[nbr] = true
              queue << [nbr, path + [nbr], depth + 1]
            end
          end
          nil
        end
      end
    end
  end
end
