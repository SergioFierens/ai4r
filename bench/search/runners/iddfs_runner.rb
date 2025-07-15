require_relative '../../common/base_runner'

module Bench
  module Search
    module Runners
      # Iterative deepening depth-first search runner.
      class IddfsRunner < Bench::Common::BaseRunner
        private

        def run
          depth = 0
          loop do
            result = depth_limited_search(problem.start_state, depth)
            return result if result

            depth += 1
          end
        end

        def depth_limited_search(start, limit)
          stack = [[start, [start], 0]]
          visited = { start => 0 }
          until stack.empty?
            frontier_size(stack.size)
            node, path, d = stack.pop
            return path if problem.goal?(node)
            next if d == limit

            expand
            problem.neighbors(node).each_key do |nbr|
              next if visited.key?(nbr) && visited[nbr] <= d + 1

              visited[nbr] = d + 1
              stack << [nbr, path + [nbr], d + 1]
            end
          end
          nil
        end
      end
    end
  end
end
