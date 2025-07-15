require_relative '../../common/base_runner'

module Bench
  module Search
    module Runners
      # Breadth-first search runner.
      class BfsRunner < Bench::Common::BaseRunner
        private

        def run
          start = problem.start_state
          queue = [[start, [start]]]
          visited = { start => true }
          until queue.empty?
            frontier_size(queue.size)
            node, path = queue.shift
            return path if problem.goal?(node)

            expand
            problem.neighbors(node).each_key do |nbr|
              next if visited[nbr]

              visited[nbr] = true
              queue << [nbr, path + [nbr]]
            end
          end
          nil
        end
      end
    end
  end
end
