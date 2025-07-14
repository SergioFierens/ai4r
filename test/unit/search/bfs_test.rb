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

  def test_finds_shortest_path
    bfs = BFS.new(->(n) { n == :d }, ->(n) { @graph[n] })
    path = bfs.search(:a)
    assert_equal %i[a b d], path
  end

  def test_returns_nil_when_unreachable
    bfs = BFS.new(->(n) { n == :x }, ->(n) { @graph[n] || [] })
    path = bfs.search(:a)
    assert_nil path
  end
end
