# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module Data
  
    # This module provides classical distance functions
    module Proximity
      
      # This is a faster computational replacement for eclidean distance.
      # Parameters a and b are vectors with continuous attributes.
      def self.squared_euclidean_distance(a, b)
        sum = 0.0
        a.each_with_index do |item_a, i|
          item_b = b[i]
          sum += (item_a - item_b)**2
        end
        return sum
      end
      
      # Euclidean distance, or L2 norm.
      # Parameters a and b are vectors with continuous attributes.
      # Euclidean distance tends to form hyperspherical 
      # clusters(Clustering, Xu and Wunsch, 2009). 
      # Translations and rotations do not cause a 
      # distortion in distance relation (Duda et al, 2001)
      # If attributes are measured with different units, 
      # attributes with larger values and variance will 
      # dominate the metric.
      def self.euclidean_distance(a, b)
        Math.sqrt(squared_euclidean_distance(a, b))
      end
      
      
      # city block, Manhattan distance, or L1 norm.
      # Parameters a and b are vectors with continuous attributes.
      def self.manhattan_distance(a, b)
        sum = 0.0
        a.each_with_index do |item_a, i|
          item_b = b[i]
          sum += (item_a - item_b).abs
        end
        return sum
      end
      
      # Sup distance, or L-intinity norm
      # Parameters a and b are vectors with continuous attributes.      
      def self.sup_distance(a, b)
        distance = 0.0
        a.each_with_index do |item_a, i|
          item_b = b[i]
          diff = (item_a - item_b).abs
          distance = diff if diff > distance
        end
        return distance
      end
      
      # The Hamming distance between two attributes vectors of equal 
      # length is the number of attributes for which the corresponding 
      # vectors are different
      # This distance function is frequently used with binary attributes,
      # though it can be used with other discrete attributes.
      def self.hamming_distance(a,b)
        count = 0
        a.each_index do |i|
          count += 1 if a[i] != b[i]
        end
        return count
      end
      
    end
    
  end
  
end
    