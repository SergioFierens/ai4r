# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../test_helper'
require 'ai4r/data/proximity'

module Ai4r
  module Data
    class ProximityTest < Minitest::Test
      DELTA = 0.0000001
      DATA1 = [rand * 10, rand * 10, rand * -10].freeze
      DATA2 = [rand * 10, rand * -10, rand * 10].freeze

      def test_squared_euclidean_distance
        assert_equal 0, Proximity.squared_euclidean_distance(DATA1, DATA1)
        assert_equal  Proximity.squared_euclidean_distance(DATA1, DATA2),
                      Proximity.squared_euclidean_distance(DATA2, DATA1)
        assert Proximity.squared_euclidean_distance(DATA1, DATA1) >= 0
        assert_equal 2, Proximity.squared_euclidean_distance([1, 1], [2, 2])
        assert_equal 9, Proximity.squared_euclidean_distance([3], [0])
      end

      def test_euclidean_distance
        assert_equal 0, Proximity.euclidean_distance(DATA1, DATA1)
        assert_equal  Proximity.euclidean_distance(DATA1, DATA2),
                      Proximity.euclidean_distance(DATA2, DATA1)
        assert Proximity.euclidean_distance(DATA1, DATA1) >= 0
        assert_equal Math.sqrt(2), Proximity.euclidean_distance([1, 1], [2, 2])
        assert_equal 3, Proximity.euclidean_distance([3], [0])
      end

      def test_manhattan_distance
        assert_equal 0, Proximity.manhattan_distance(DATA1, DATA1)
        assert_equal  Proximity.manhattan_distance(DATA1, DATA2),
                      Proximity.manhattan_distance(DATA2, DATA1)
        assert Proximity.manhattan_distance(DATA1, DATA1) >= 0
        assert_equal 2, Proximity.manhattan_distance([1, 1], [2, 2])
        assert_equal 9, Proximity.manhattan_distance([1, 10], [2, 2])
        assert_equal 3, Proximity.manhattan_distance([3], [0])
      end

      def test_sup_distance
        assert_equal 0, Proximity.sup_distance(DATA1, DATA1)
        assert_equal  Proximity.sup_distance(DATA1, DATA2),
                      Proximity.sup_distance(DATA2, DATA1)
        assert Proximity.sup_distance(DATA1, DATA1) >= 0
        assert_equal 1, Proximity.sup_distance([1, 1], [2, 2])
        assert_equal 8, Proximity.sup_distance([1, 10], [2, 2])
        assert_equal 3, Proximity.sup_distance([3], [0])
      end

      def test_hamming_distance
        assert_equal 0, Proximity.hamming_distance(DATA1, DATA1)
        assert_equal  Proximity.hamming_distance(DATA1, DATA2),
                      Proximity.hamming_distance(DATA2, DATA1)
        assert Proximity.hamming_distance(DATA1, DATA1) >= 0
        assert_equal 1, Proximity.hamming_distance([1, 1], [0, 1])
        assert_equal 2, Proximity.hamming_distance([1, 10], [2, 2])
        assert_equal 1, Proximity.hamming_distance([3], [0])
      end

      def test_simple_matching_distance
        assert_equal 0, Proximity.simple_matching_distance(DATA1, DATA1)
        assert_equal  Proximity.simple_matching_distance(DATA1, DATA2),
                      Proximity.simple_matching_distance(DATA2, DATA1)
        assert Proximity.simple_matching_distance(DATA1, DATA1) >= 0
        assert_equal 1, Proximity.simple_matching_distance([1, 2], [0, 1])
        assert_equal 1.0 / 0, Proximity.simple_matching_distance([1, 10], [2, 2])
        assert_equal 1.0 / 0, Proximity.simple_matching_distance([3], [0])
      end

      def test_cosine_distance
        assert_in_delta 0.0, Proximity.cosine_distance(DATA1, DATA1), DELTA
        assert_equal  Proximity.cosine_distance(DATA1, DATA2),
                      Proximity.cosine_distance(DATA2, DATA1)
        assert_in_delta 0.0, Proximity.cosine_distance(DATA1, DATA1), DELTA
      end
    end
  end
end
