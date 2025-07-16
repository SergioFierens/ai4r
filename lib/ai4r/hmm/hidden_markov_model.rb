# frozen_string_literal: true

# Author::    OpenAI Codex
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/parameterizable'

module Ai4r
  module Hmm
    # = Introduction
    #
    # A simple implementation of a discrete Hidden Markov Model (HMM).
    # You must provide the states and observations as well as the
    # probability matrices. This class exposes two main operations:
    #
    # * +eval(sequence)+: probability of the observation sequence.
    # * +decode(sequence)+: most likely hidden state sequence (Viterbi).
    #
    # Probabilities are provided as arrays. Example:
    #
    #   states = [:Rainy, :Sunny]
    #   observations = [:walk, :shop, :clean]
    #   start_prob = [0.6, 0.4]
    #   transition = [[0.7, 0.3], [0.4, 0.6]]
    #   emission = [[0.1, 0.4, 0.5], [0.6, 0.3, 0.1]]
    #   hmm = Ai4r::Hmm::HiddenMarkovModel.new(
    #     states: states,
    #     observations: observations,
    #     start_prob: start_prob,
    #     transition_prob: transition,
    #     emission_prob: emission
    #   )
    #   hmm.eval([:walk, :shop, :clean])
    #   hmm.decode([:walk, :shop, :clean])
    class HiddenMarkovModel
      include Ai4r::Data::Parameterizable

      attr_accessor :states, :observations, :start_prob,
                    :transition_prob, :emission_prob

      parameters_info states: 'Array of hidden states',
                      observations: 'Array of observation symbols',
                      start_prob: 'Initial state probabilities',
                      transition_prob: 'State transition probability matrix',
                      emission_prob: 'Observation probability matrix'

      def initialize(params = {})
        @states = []
        @observations = []
        @start_prob = []
        @transition_prob = []
        @emission_prob = []
        set_parameters(params) if params && !params.empty?
      end

      # Probability of the given observation sequence using the
      # forward algorithm.
      def eval(sequence)
        forward(sequence).last.sum
      end

      # Return the most likely hidden state sequence for the given
      # observations using the Viterbi algorithm.
      def decode(sequence)
        viterbi(sequence)
      end

      protected

      def forward(sequence)
        probs = []
        sequence.each_with_index do |obs, t|
          probs[t] = []
          obs_index = @observations.index(obs)
          if t.zero?
            @states.each_index do |i|
              probs[t][i] = @start_prob[i] * @emission_prob[i][obs_index]
            end
          else
            @states.each_index do |j|
              sum = 0.0
              @states.each_index do |i|
                sum += probs[t - 1][i] * @transition_prob[i][j]
              end
              probs[t][j] = sum * @emission_prob[j][obs_index]
            end
          end
        end
        probs
      end

      # rubocop:disable Metrics/MethodLength
      def viterbi(sequence)
        v = []
        bptr = []
        sequence.each_with_index do |obs, t|
          obs_index = @observations.index(obs)
          v[t] = []
          bptr[t] = []
          if t.zero?
            @states.each_index do |i|
              v[t][i] = @start_prob[i] * @emission_prob[i][obs_index]
              bptr[t][i] = 0
            end
          else
            @states.each_index do |j|
              max_prob = -Float::INFINITY
              max_state = 0
              @states.each_index do |i|
                prob = v[t - 1][i] * @transition_prob[i][j]
                if prob > max_prob
                  max_prob = prob
                  max_state = i
                end
              end
              v[t][j] = max_prob * @emission_prob[j][obs_index]
              bptr[t][j] = max_state
            end
          end
        end
        path = Array.new(sequence.length)
        last_state = v.last.each_with_index.max[1]
        path[-1] = @states[last_state]
        (sequence.length - 1).downto(1) do |t|
          last_state = bptr[t][last_state]
          path[t - 1] = @states[last_state]
        end
        path
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
