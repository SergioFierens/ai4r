require_relative '../../common/base_runner'

module Bench
  module Search
    module Runners
      # Depth-first search runner.
      class DfsRunner < Bench::Common::BaseRunner
        private

        def run
          start = problem.start_state
          stack = [[start, [start]]]
          visited = { start => true }
          until stack.empty?
            frontier_size(stack.size)
            node, path = stack.pop
            return path if problem.goal?(node)

            expand
            problem.neighbors(node).each_key do |nbr|
              next if visited[nbr]

              visited[nbr] = true
              stack << [nbr, path + [nbr]]
            end
          end
          nil
        end
      end
    end
  end
end
