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
    # - +actions.call(state)+ returns available actions for a state.
    # - +transition.call(state, action)+ computes the next state.
    # - +terminal.call(state)+ returns true if the state has no children.
    # - +reward.call(state)+ yields a numeric payoff for terminal states.
    #
    # Example:
    #   env = {
    #     actions: ->(s) { s == :root ? %i[a b] : [] },
    #     transition: ->(s, a) { a == :a ? :win : :lose },
    #     terminal: ->(s) { %i[win lose].include?(s) },
    #     reward: ->(s) { s == :win ? 1.0 : 0.0 }
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
      def initialize(actions:, transition:, terminal:, reward:, exploration: Math.sqrt(2))
        @actions = actions
        @transition = transition
        @terminal = terminal
        @reward = reward
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
        until @terminal.call(node.state)
          actions = @actions.call(node.state)
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
        state = @transition.call(node.state, action)
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
        until @terminal.call(current)
          action = @actions.call(current).sample
          current = @transition.call(current, action)
        end
        @reward.call(current)
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
