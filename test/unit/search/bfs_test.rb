# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/search/bfs'

class BFSTest < Minitest::Test
  include Ai4r::Search

  def setup
    @graph = {
      a: %i[b c],
      b: %i[d],
      c: %i[d],
      d: []
    }
  end

  def goal_test(node)
    node == :d
  end

  def neighbor_fn(node)
    @graph[node]
  end

  def test_finds_shortest_path
    bfs = BFS.new(method(:goal_test), method(:neighbor_fn))
    path = bfs.search(:a)
    assert_equal %i[a b d], path
  end

  def goal_test_unreach(node)
    node == :x
  end

  def neighbor_fn_unreach(node)
    @graph[node] || []
  end

  def test_returns_nil_when_unreachable
    bfs = BFS.new(method(:goal_test_unreach), method(:neighbor_fn_unreach))
    path = bfs.search(:a)
    assert_nil path
  end
end
