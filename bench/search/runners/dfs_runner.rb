require_relative '../../common/base_runner'

module Bench
  module Search
    module Runners
      # Depth-first search runner.
      class DfsRunner < Bench::Common::BaseRunner
        def initialize(problem, max_depth = nil)
          super(problem)
          @max_depth = max_depth
        end

        private

        def run
          start = problem.start_state
          stack = [[start, [start], 0]]
          visited = { start => true }
          until stack.empty?
            frontier_size(stack.size)
            node, path, depth = stack.pop
            return path if problem.goal?(node)
            next if @max_depth && depth >= @max_depth
            expand
            problem.neighbors(node).each_key do |nbr|
              next if visited[nbr]
              visited[nbr] = true
              stack << [nbr, path + [nbr], depth + 1]
            end
          end
          nil
        end
      end
    end
  end
end
