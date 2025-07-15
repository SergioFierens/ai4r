# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/data/proximity'

module Ai4r
  module Data
    class ProximityTest < Test::Unit::TestCase
          
      @@delta = 0.0000001    
      @@data1 = [rand*10, rand*10, rand*-10]
      @@data2 = [rand*10, rand*-10, rand*10]
      
      def test_squared_euclidean_distance
          assert_equal 0, Proximity.squared_euclidean_distance(@@data1, @@data1)
          assert_equal  Proximity.squared_euclidean_distance(@@data1, @@data2), 
                        Proximity.squared_euclidean_distance(@@data2, @@data1)
          assert 0 <= Proximity.squared_euclidean_distance(@@data1, @@data1)
          assert_equal 2, Proximity.squared_euclidean_distance([1,1], [2,2])
          assert_equal 9, Proximity.squared_euclidean_distance([3], [0])
      end
      
      def test_euclidean_distance
          assert_equal 0, Proximity.euclidean_distance(@@data1, @@data1)
          assert_equal  Proximity.euclidean_distance(@@data1, @@data2), 
                        Proximity.euclidean_distance(@@data2, @@data1)
          assert 0 <= Proximity.euclidean_distance(@@data1, @@data1)                        
          assert_equal Math.sqrt(2), Proximity.euclidean_distance([1,1], [2,2])
          assert_equal 3, Proximity.euclidean_distance([3], [0])
      end

      def test_manhattan_distance
          assert_equal 0, Proximity.manhattan_distance(@@data1, @@data1)
          assert_equal  Proximity.manhattan_distance(@@data1, @@data2), 
                        Proximity.manhattan_distance(@@data2, @@data1)
          assert 0 <= Proximity.manhattan_distance(@@data1, @@data1)                        
          assert_equal 2, Proximity.manhattan_distance([1,1], [2,2])
          assert_equal 9, Proximity.manhattan_distance([1,10], [2,2])
          assert_equal 3, Proximity.manhattan_distance([3], [0])
      end      
      
      def test_sup_distance
          assert_equal 0, Proximity.sup_distance(@@data1, @@data1)
          assert_equal  Proximity.sup_distance(@@data1, @@data2), 
                        Proximity.sup_distance(@@data2, @@data1)
          assert 0 <= Proximity.sup_distance(@@data1, @@data1)                        
          assert_equal 1, Proximity.sup_distance([1,1], [2,2])
          assert_equal 8, Proximity.sup_distance([1,10], [2,2])
          assert_equal 3, Proximity.sup_distance([3], [0])
      end  
      
      def test_hamming_distance
          assert_equal 0, Proximity.hamming_distance(@@data1, @@data1)
          assert_equal  Proximity.hamming_distance(@@data1, @@data2), 
                        Proximity.hamming_distance(@@data2, @@data1)
          assert 0 <= Proximity.hamming_distance(@@data1, @@data1)                        
          assert_equal 1, Proximity.hamming_distance([1,1], [0,1])
          assert_equal 2, Proximity.hamming_distance([1,10], [2,2])
          assert_equal 1, Proximity.hamming_distance([3], [0])
      end 
      
      def test_simple_matching_distance
          assert_equal 0, Proximity.simple_matching_distance(@@data1, @@data1)
          assert_equal  Proximity.simple_matching_distance(@@data1, @@data2), 
                        Proximity.simple_matching_distance(@@data2, @@data1)
          assert 0 <= Proximity.simple_matching_distance(@@data1, @@data1)                        
          assert_equal 1, Proximity.simple_matching_distance([1,2], [0,1])
          assert_equal 1.0/0, Proximity.simple_matching_distance([1,10], [2,2])
          assert_equal 1.0/0, Proximity.simple_matching_distance([3], [0])
      end       
      
      def test_cosine_distance
          assert_in_delta 0.0, Proximity.cosine_distance(@@data1, @@data1), @@delta
          assert_equal  Proximity.cosine_distance(@@data1, @@data2), 
                        Proximity.cosine_distance(@@data2, @@data1)
          assert_in_delta 0.0, Proximity.cosine_distance(@@data1, @@data1), @@delta
      end
    end
  end
end
