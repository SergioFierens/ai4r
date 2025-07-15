# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
#
# Basic tabular Q-learning implementation.

require_relative '../data/parameterizable'

module Ai4r
  module Reinforcement
    # Simple Q-learning agent storing Q-values in a Hash.
    class QLearning
      include Ai4r::Data::Parameterizable

      parameters_info learning_rate: 'Update step size',
                      discount: 'Discount factor',
                      exploration: 'Exploration rate'

      def initialize
        @learning_rate = 0.1
        @discount = 0.9
        @exploration = 0.1
        @q = Hash.new { |h, k| h[k] = Hash.new(0.0) }
      end

      # Update Q(s,a) from an observed transition.
      def update(state, action, reward, next_state)
        best_next = @q[next_state].values.max || 0.0
        @q[state][action] += @learning_rate * (
          reward + @discount * best_next - @q[state][action]
        )
      end

      # Choose an action using an ε-greedy strategy.
      def choose_action(state)
        return nil if @q[state].empty?

        if rand < @exploration
          @q[state].keys.sample
        else
          @q[state].max_by { |_, v| v }.first
        end
      end

      # Direct access to learned Q-values.
      attr_reader :q
    end
  end
end
