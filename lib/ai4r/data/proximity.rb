# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
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
      
      # The "Simple matching" distance between two attribute sets is given 
      # by the number of values present on both vectors.
      # If sets a and b have lengths da and db then:
      # 
      #  S = 2/(da + db) * Number of values present on both sets
      #  D = 1.0/S - 1
      # 
      # Some considerations: 
      # * a and b must not include repeated items
      # * all attributes are treated equally
      # * all attributes are treated equally
      def self.simple_matching_distance(a,b)
        similarity = 0.0
        a.each {|item| similarity += 2 if b.include?(item)}
        similarity /= (a.length + b.length)
        return 1.0/similarity - 1
      end      
      
      # Cosine similarity is a measure of similarity between two vectors 
      # of an inner product space that measures the cosine of the 
      # angle between them (http://en.wikipedia.org/wiki/Cosine_similarity).
      # 
      # Parameters a and b are vectors with continuous attributes.
      #
      # D = sum(a[i] * b[i]) / sqrt(sum(a[i]**2)) * sqrt(sum(b[i]**2))
      def self.cosine_distance(a,b)
        dot_product = 0.0
        norm_a = 0.0
        norm_b = 0.0
        magnitude = 0.0
        
        a.each_index do |i|
          dot_product += a[i] * b[i]
          norm_a += a[i] ** 2
          norm_b += b[i] ** 2
        end
        
        magnitude = Math.sqrt(norm_a) * Math.sqrt(norm_b)
        return 1 - (dot_product / magnitude)
      end
    end
    
  end
  
end
    
