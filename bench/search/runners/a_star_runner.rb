require 'set'
require_relative '../../common/base_runner'

module Bench
  module Search
    module Runners
      # A* search runner.
      class AStarRunner < Bench::Common::BaseRunner
        private

        def run
          start = problem.start_state
          open_set = [start]
          came_from = {}
          g = { start => 0 }
          f = { start => problem.heuristic(start) }
          closed = Set.new

          until open_set.empty?
            frontier_size(open_set.size)
            current = open_set.min_by { |n| f[n] }
            return reconstruct_path(came_from, current) if problem.goal?(current)

            open_set.delete(current)
            closed << current
            expand
            problem.neighbors(current).each do |nbr, cost|
              next if closed.include?(nbr)

              tentative_g = g[current] + cost
              next unless g[nbr].nil? || tentative_g < g[nbr]

              came_from[nbr] = current
              g[nbr] = tentative_g
              f[nbr] = tentative_g + problem.heuristic(nbr)
              open_set << nbr unless open_set.include?(nbr)
            end
          end
          nil
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

        def reconstruct_path(came_from, node)
          path = [node]
          while came_from.key?(node)
            node = came_from[node]
            path.unshift(node)
          end
          path
        end
      end
    end
  end
end
