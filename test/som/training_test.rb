require 'minitest/autorun'
require 'ai4r/som/som'

module Ai4r
  module Som
    class TrainingTest < Minitest::Test
      DATA = [[0.0, 0.0], [1.0, 1.0]]

      def setup
        layer = TwoPhaseLayer.new(4, 0.5, 1, 1, 0.5, 0.2)
        @som = Som.new(2, 2, 2, layer, { range: 0..1, random_seed: 1 })
        @som.initiate_map
      end

      def test_global_error_decreases
        before = @som.global_error(DATA)
        @som.train(DATA)
        after = @som.global_error(DATA)
        assert after < before, "expected error to decrease"
      end
    end
  end
end
