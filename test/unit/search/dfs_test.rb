# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/search/dfs'

class DFSTest < Minitest::Test
  include Ai4r::Search

  def setup
    @graph = {
      a: %i[b c],
      b: %i[d],
      c: %i[e],
      d: [],
      e: []
    }
  end

  def test_explores_depth_first
    dfs = DFS.new(->(n) { n == :e }, ->(n) { @graph[n] })
    path = dfs.search(:a)
    assert_equal %i[a c e], path
  end
end
