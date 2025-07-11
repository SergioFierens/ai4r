# This is a unit test file for the SOM algorithm implemented
# in ai4r
#
# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r/som/som'
require 'test/unit'

module Ai4r

  module Som

    class SomTest < Test::Unit::TestCase

      def setup
        @som = Som.new 2, 5, 5, Layer.new(3, 3)
        @som.initiate_map
      end

      def test_random_initiation
        assert_equal 25, @som.nodes.length

        @som.nodes.each do |node|
          assert_equal 2, node.weights.length

          node.weights.each do |weight|
            assert weight < 1
            assert weight > 0
          end

        end
      end


      # bmu

      def test_find_bmu
        bmu = @som.find_bmu([0.5, 0.5])
      end

      def test_adjust_nodes
        @som.adjust_nodes [1, 2], @som.find_bmu([0.5, 0.5]), 2, 0.1
      end

      def test_access_to_nodes
        ex = assert_raise(ArgumentError) { @som.get_node(5, 5) }
        assert_equal 'invalid node coordinates (5, 5)', ex.message

        ex = assert_raise(ArgumentError) { @som.get_node(5, -3) }
        assert_equal 'invalid node coordinates (5, -3)', ex.message

        assert_equal Node, @som.get_node(0, 0).class
      end

      def test_distance_for_same_row
        assert_equal 2, distancer(0, 0, 0, 2)
        assert_equal 2, distancer(0, 4, 0, 2)
        assert_equal 0, distancer(0, 0, 0, 0)
      end

      def test_distance_for_same_column
        assert_equal 1, distancer(0, 0, 1, 0)
        assert_equal 2, distancer(2, 0, 0, 0)
      end

      def test_distance_for_diagonally_point
        assert_equal 1, distancer(1, 0, 0, 1)
        assert_equal 2, distancer(2, 2, 0, 0)
        assert_equal 2, distancer(3, 2, 1, 4)
      end

      def test_distance_for_screwed_diagonally_point
        assert_equal 2, distancer(0, 0, 2, 1)
        assert_equal 4, distancer(3, 4, 1, 0)
        assert_equal 2, distancer(3, 2, 1, 3)
      end

      def test_weight_options
        som = Som.new 2, 2, 2, Layer.new(3, 3), { range: -1..0, seed: 1 }
        som.initiate_map
        som.nodes.each do |node|
          node.weights.each do |w|
            assert w <= 0
            assert w >= -1
          end
        end

        other = Som.new 2, 2, 2, Layer.new(3, 3)
        other.set_parameters({ :init_weight_options => { range: -1..0, seed: 1 } })
        other.initiate_map
        assert_equal som.nodes.map(&:weights), other.nodes.map(&:weights)
      end

      def test_rectangular_node_positions
        som = Som.new 1, 2, 3, Layer.new(3, 3)
        som.initiate_map
        assert_equal 6, som.nodes.length
        assert_equal [0, 0], [som.get_node(0, 0).x, som.get_node(0, 0).y]
        assert_equal [2, 0], [som.get_node(0, 2).x, som.get_node(0, 2).y]
        assert_equal [1, 1], [som.get_node(1, 1).x, som.get_node(1, 1).y]
      end

      def test_train_with_error_threshold
        som = Som.new 2, 3, 3, Layer.new(3, 3, 10)
        som.initiate_map
        errors = som.train([[0, 0], [1, 1]], error_threshold: 0.01)
        assert errors.length < som.layer.epochs
        assert_operator errors.last, :<=, 0.01
      end

      private

      def distancer(x1, y1, x2, y2)
        @som.get_node(x1, y1).distance_to_node(@som.get_node(x2, y2))
      end

    end

  end

end
