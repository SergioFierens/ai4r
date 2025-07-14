# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/search/mcts'

class MCTSTest < Minitest::Test
  include Ai4r::Search

  def setup
    @env = {
      actions: ->(s) { s == :root ? %i[a b] : [] },
      transition: ->(s, a) { a == :a ? :win : :lose },
      terminal: ->(s) { %i[win lose].include?(s) },
      reward: ->(s) { s == :win ? 1.0 : 0.0 }
    }
    @mcts = MCTS.new(**@env)
  end

  def test_selects_best_action
    best = @mcts.search(:root, 50)
    assert_equal :a, best
  end
end
