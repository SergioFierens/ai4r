# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
#
# Minimal Monte Carlo Tree Search implementation.

require_relative '../data/parameterizable'

module Ai4r
  module Search
    # Basic UCT-style Monte Carlo Tree Search.
    #
    # This generic implementation expects four callbacks:
    # - +actions_fn.call(state)+ returns available actions for a state.
    # - +transition_fn.call(state, action)+ computes the next state.
    # - +terminal_fn.call(state)+ returns true if the state has no children.
    # - +reward_fn.call(state)+ yields a numeric payoff for terminal states.
    #
    # Example:
    #   env = {
    #     actions_fn: ->(s) { s == :root ? %i[a b] : [] },
    #     transition_fn: ->(s, a) { a == :a ? :win : :lose },
    #     terminal_fn: ->(s) { %i[win lose].include?(s) },
    #     reward_fn: ->(s) { s == :win ? 1.0 : 0.0 }
    #   }
    #   mcts = Ai4r::Search::MCTS.new(**env)
    #   best = mcts.search(:root, 50)
    #   # => :a
    class MCTS
      include Ai4r::Data::Parameterizable

      Node = Struct.new(:state, :parent, :action, :children, :visits, :value) do
        def initialize(state, parent = nil, action = nil)
          super(state, parent, action, [], 0, 0.0)
        end
      end

      parameters_info exploration: 'UCT exploration constant'

      # Create a new search object.
      #
      # actions_fn::     returns available actions for a state
      # transition_fn::  computes the next state given a state and action
      # terminal_fn::    predicate to detect terminal states
      # reward_fn::      numeric payoff for terminal states
      def initialize(actions_fn:, transition_fn:, terminal_fn:, reward_fn:, exploration: Math.sqrt(2))
        @actions_fn = actions_fn
        @transition_fn = transition_fn
        @terminal_fn = terminal_fn
        @reward_fn = reward_fn
        @exploration = exploration
      end

      # Run MCTS starting from +root_state+ for a number of +iterations+.
      # Returns the action considered best from the root.
      def search(root_state, iterations)
        root = Node.new(root_state)
        iterations.times do
          node = tree_policy(root)
          reward = default_policy(node.state)
          backup(node, reward)
        end
        best_child(root, 0)&.action
      end

      private

      def tree_policy(node)
        until @terminal_fn.call(node.state)
          actions = @actions_fn.call(node.state)
          if node.children.length < actions.length
            return expand(node, actions)
          else
            node = best_child(node, @exploration)
          end
        end
        node
      end

      def expand(node, actions)
        tried = node.children.map(&:action)
        untried = actions - tried
        action = untried.sample
        state = @transition_fn.call(node.state, action)
        child = Node.new(state, node, action)
        node.children << child
        child
      end

      def best_child(node, c)
        node.children.max_by do |child|
          exploitation = child.value / (child.visits.nonzero? || 1)
          exploration = c * Math.sqrt(Math.log(node.visits + 1) / (child.visits.nonzero? || 1))
          exploitation + exploration
        end
      end

      def default_policy(state)
        current = state
        until @terminal_fn.call(current)
          action = @actions_fn.call(current).sample
          current = @transition_fn.call(current, action)
        end
        @reward_fn.call(current)
      end

      def backup(node, reward)
        while node
          node.visits += 1
          node.value += reward
          node = node.parent
        end
      end
    end
  end
end
