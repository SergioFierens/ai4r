# frozen_string_literal: true

require_relative '../../test_helper'
require 'ai4r/reinforcement/q_learning'

class QLearningUnitTest < Minitest::Test
  include Ai4r::Reinforcement

  def setup
    srand(123)
    @agent = QLearning.new
    @agent.set_parameters(learning_rate: 0.5, discount: 1.0, exploration: 0.0)
    # prime state-action pairs
    @agent.q[:s1][:a] = 0.0
    @agent.q[:s1][:b] = 0.0
    @agent.q[:s2][:a] = 1.0
  end

  def test_update_adjusts_q_values
    @agent.update(:s1, :a, 0, :s2)
    assert_in_delta 0.5, @agent.q[:s1][:a], 1e-6
    @agent.update(:s1, :a, 0, :s2)
    assert_in_delta 0.75, @agent.q[:s1][:a], 1e-6
  end

  def test_choose_action_returns_best
    @agent.q[:s1][:a] = 0.2
    @agent.q[:s1][:b] = 0.5
    assert_equal :b, @agent.choose_action(:s1)
  end
end
