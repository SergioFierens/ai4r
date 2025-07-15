# frozen_string_literal: true

# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
#
# Classical policy iteration for finite MDPs.

require_relative '../data/parameterizable'

module Ai4r
  module Reinforcement
    # Compute an optimal policy for a known MDP.
    class PolicyIteration
      include Ai4r::Data::Parameterizable

      parameters_info discount: 'Discount factor'

      def initialize
        @discount = 0.9
      end

      # Perform policy iteration.
      # states:: Array of states
      # actions:: Array of actions
      # transition:: Hash[state][action] => {next_state => prob}
      # reward:: Hash[state][action] => reward
      def policy_iteration(states, actions, transition, reward)
        policy = {}
        states.each { |s| policy[s] = actions.first }
        values = Hash.new(0.0)

        loop do
          # Policy evaluation
          delta = Float::INFINITY
          while delta > 1e-6
            delta = 0.0
            states.each do |s|
              v = values[s]
              a = policy[s]
              new_v = reward[s][a] +
                      @discount * transition[s][a].sum { |s2, p| p * values[s2] }
              values[s] = new_v
              diff = (v - new_v).abs
              delta = diff if diff > delta
            end
          end

          # Policy improvement
          stable = true
          states.each do |s|
            old = policy[s]
            best = actions.max_by do |a|
              reward[s][a] +
                @discount * transition[s][a].sum { |s2, p| p * values[s2] }
            end
            policy[s] = best
            stable = false if best != old
          end
          break if stable
        end
        policy
      end
    end
  end
end
