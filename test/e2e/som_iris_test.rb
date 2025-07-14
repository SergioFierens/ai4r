# frozen_string_literal: true
require_relative '../test_helper'
require 'ai4r/som/two_phase_layer'
require 'ai4r/som/som'

class SomIrisTest < Minitest::Test
  DATA = File.readlines('examples/som/som_data.rb').grep(/\[.*\]/).first(30).map do |line|
    line.strip.sub(/[\[\],]/,'').split(',').map(&:to_f)
  end

  def test_purity
    layer = Ai4r::Som::TwoPhaseLayer.new(3, 0.5, 1, 1, 0.5, 0.2)
    som = Ai4r::Som::Som.new(4, 3, 3, layer)
    som.initiate_map
    som.train(DATA)
    assert som.nodes.any?
  end
end
