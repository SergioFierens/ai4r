# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/reinforcement/policy_iteration'

class PolicyIterationUnitTest < Minitest::Test
  include Ai4r::Reinforcement

  STATES = %i[s1 s2]
  ACTIONS = %i[a b]
  TRANS = {
    s1: { a: { s2: 1.0 }, b: { s1: 1.0 } },
    s2: { a: { s2: 1.0 }, b: { s1: 1.0 } }
  }
  REWARD = {
    s1: { a: 0, b: 1 },
    s2: { a: 1, b: 0 }
  }

  def test_returns_optimal_policy
    pi = PolicyIteration.new
    policy = pi.policy_iteration(STATES, ACTIONS, TRANS, REWARD)
    assert_equal({ s1: :b, s2: :a }, policy)
  end
end
