# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/search'

class AStarUnitTest < Minitest::Test
  include Ai4r::Search

  GRAPH = {
    'A' => { 'B' => 1, 'C' => 4 },
    'B' => { 'C' => 2, 'D' => 5, 'E' => 12 },
    'C' => { 'D' => 2, 'F' => 3 },
    'D' => { 'G' => 1 },
    'E' => { 'G' => 5 },
    'F' => { 'G' => 7 }
  }

  HEURISTIC = {
    'A' => 6, 'B' => 5, 'C' => 3,
    'D' => 1, 'E' => 5, 'F' => 7, 'G' => 0
  }

  def neighbor_fn(node)
    GRAPH[node] || {}
  end

  def heuristic_fn(node)
    HEURISTIC[node] || 0
  end

  def goal_test(node)
    node == 'G'
  end

  def test_finds_shortest_path
    astar = AStar.new('A', method(:goal_test), method(:neighbor_fn), method(:heuristic_fn))
    path = astar.search
    assert_equal %w[A B C D G], path
  end

  def test_returns_nil_when_unreachable
    bad_graph = lambda { |n| n == 'A' ? { 'B' => 1 } : {} }
    astar = AStar.new('A', method(:goal_test), bad_graph, method(:heuristic_fn))
    assert_nil astar.search
  end
end
