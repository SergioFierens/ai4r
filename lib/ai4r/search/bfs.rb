# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
#
# Basic breadth-first search implementation.

module Ai4r
  module Search
    # Explore nodes in breadth-first order until a goal is found.
    class BFS
      # Find a path from the start node to a goal.
      #
      # start::      initial node
      # goal_test::   lambda returning true for a goal node
      # neighbor_fn:: lambda returning adjacent nodes for a given node
      #
      # Returns an array of nodes representing the path, or nil if no goal was found.
      def search(start, goal_test, neighbor_fn)
        queue = [[start, [start]]]
        visited = { start => true }
        until queue.empty?
          node, path = queue.shift
          return path if goal_test.call(node)
          neighbor_fn.call(node).each do |n|
            next if visited[n]
            visited[n] = true
            queue << [n, path + [n]]
          end
        end
        nil
      end
    end
  end
end
