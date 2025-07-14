# frozen_string_literal: true

require 'minitest/autorun'
require 'ai4r/hmm/hidden_markov_model'

class HiddenMarkovModelTest < Minitest::Test
  def setup
    @states = %i[Rainy Sunny]
    @observations = %i[walk shop clean]
    @start_prob = [0.6, 0.4]
    @transition = [[0.7, 0.3], [0.4, 0.6]]
    @emission = [[0.1, 0.4, 0.5], [0.6, 0.3, 0.1]]
    @model = Ai4r::Hmm::HiddenMarkovModel.new(
      states: @states,
      observations: @observations,
      start_prob: @start_prob,
      transition_prob: @transition,
      emission_prob: @emission
    )
  end

  def test_eval_probability
    prob = @model.eval(%i[walk shop clean])
    assert_in_delta 0.0336, prob, 0.0001
  end

  def test_decode_path
    path = @model.decode(%i[walk shop clean])
    assert_equal %i[Sunny Rainy Rainy], path
  end
end
