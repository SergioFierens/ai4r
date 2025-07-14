require 'minitest/autorun'
require 'ai4r/som/two_phase_layer'

module Ai4r
  module Som
    class TwoPhaseLayerTest < Minitest::Test
      def setup
        # Use small phase sizes to make schedule deterministic
        @layer = TwoPhaseLayer.new(6, 0.9, 2, 3, 0.5, 0.1)
      end

      def test_radius_schedule
        assert_equal 2, @layer.radius_decay(0)
        assert_equal 2, @layer.radius_decay(1)
        assert_equal 1, @layer.radius_decay(2)
        assert_equal 1, @layer.radius_decay(3)
      end

      def test_learning_rate_schedule
        assert_in_delta 0.7, @layer.learning_rate_decay(0), 1e-6
        assert_in_delta 0.5, @layer.learning_rate_decay(1), 1e-6
        assert_in_delta 0.5, @layer.learning_rate_decay(2), 1e-6
        assert_in_delta 0.366666, @layer.learning_rate_decay(3), 1e-4
        assert_in_delta 0.233333, @layer.learning_rate_decay(4), 1e-4
      end
    end
  end
end
