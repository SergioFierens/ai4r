require 'test/unit'
require 'ai4r/som/node'

module Ai4r
  module Som
    class NodeTest < Test::Unit::TestCase
      def test_distance_to_input
        node = Node.new
        node.weights = [0.0, 0.0]
        assert_in_delta 0.0, node.distance_to_input([0.0, 0.0]), 1e-6
        assert_in_delta 5.0, node.distance_to_input([3.0, 4.0]), 1e-6
      end

      def test_distance_to_node
        a = Node.new
        a.x = 0
        a.y = 0
        b = Node.new
        b.x = 3
        b.y = 2
        assert_equal 3, a.distance_to_node(b)
      end
    end
  end
end
