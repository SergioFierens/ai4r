# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
#
# Generic A* search algorithm.

require 'set'

module Ai4r
  module Search
    # Generic A* search implementation operating on arbitrary graph
    # representations.
    #
    # Initialize with start node, a goal predicate, a neighbor function and a
    # heuristic.
    #
    # The neighbor function must return a hash mapping neighbor nodes to edge
    # costs. The heuristic receives a node and returns the estimated remaining
    # cost to reach the goal.
    class AStar
      # @param start [Object] initial node
      # @param goal_test [Proc] predicate returning true when node is goal
      # @param neighbor_fn [Proc] -> node { neighbor => cost, ... }
      # @param heuristic_fn [Proc] -> node => estimated remaining cost
      def initialize(start, goal_test, neighbor_fn, heuristic_fn)
        @start = start
        @goal_test = goal_test
        @neighbor_fn = neighbor_fn
        @heuristic_fn = heuristic_fn
      end

      # Execute the search and return the path as an array of nodes or nil
      # if the goal cannot be reached.
      def search
        open_set = [@start]
        came_from = {}
        g = { @start => 0 }
        f = { @start => @heuristic_fn.call(@start) }
        closed = Set.new

        until open_set.empty?
          current = open_set.min_by { |n| f[n] }
          return reconstruct_path(came_from, current) if @goal_test.call(current)

          open_set.delete(current)
          closed << current
          @neighbor_fn.call(current).each do |neighbor, cost|
            next if closed.include?(neighbor)

            tentative_g = g[current] + cost
            if g[neighbor].nil? || tentative_g < g[neighbor]
              came_from[neighbor] = current
              g[neighbor] = tentative_g
              f[neighbor] = tentative_g + @heuristic_fn.call(neighbor)
              open_set << neighbor unless open_set.include?(neighbor)
            end
          end
        end
        nil
      end

      private

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
