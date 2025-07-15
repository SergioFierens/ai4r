# frozen_string_literal: true

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
      def squared_euclidean_distance(vec_a, vec_b)
        sum = 0.0
        vec_a.each_with_index do |item_a, i|
          item_b = vec_b[i]
          sum += (item_a - item_b)**2
        end
        sum
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
      def euclidean_distance(vec_a, vec_b)
        Math.sqrt(squared_euclidean_distance(vec_a, vec_b))
      end

      # city block, Manhattan distance, or L1 norm.
      # Parameters a and b are vectors with continuous attributes.
      def manhattan_distance(vec_a, vec_b)
        sum = 0.0
        vec_a.each_with_index do |item_a, i|
          item_b = vec_b[i]
          sum += (item_a - item_b).abs
        end
        sum
      end

      # Sup distance, or L-intinity norm
      # Parameters a and b are vectors with continuous attributes.
      def sup_distance(vec_a, vec_b)
        distance = 0.0
        vec_a.each_with_index do |item_a, i|
          item_b = vec_b[i]
          diff = (item_a - item_b).abs
          distance = diff if diff > distance
        end
        distance
      end

      # The Hamming distance between two attributes vectors of equal
      # length is the number of attributes for which the corresponding
      # vectors are different
      # This distance function is frequently used with binary attributes,
      # though it can be used with other discrete attributes.
      def hamming_distance(vec_a, vec_b)
        count = 0
        vec_a.each_index do |i|
          count += 1 if vec_a[i] != vec_b[i]
        end
        count
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
      def simple_matching_distance(vec_a, vec_b)
        similarity = 0.0
        vec_a.each { |item| similarity += 2 if vec_b.include?(item) }
        similarity /= (vec_a.length + vec_b.length)
        (1.0 / similarity) - 1
      end

      # Cosine similarity is a measure of similarity between two vectors
      # of an inner product space that measures the cosine of the
      # angle between them (http://en.wikipedia.org/wiki/Cosine_similarity).
      #
      # Parameters a and b are vectors with continuous attributes.
      #
      # D = sum(a[i] * b[i]) / sqrt(sum(a[i]**2)) * sqrt(sum(b[i]**2))
      def cosine_distance(vec_a, vec_b)
        dot_product = 0.0
        norm_a = 0.0
        norm_b = 0.0

        vec_a.each_index do |i|
          dot_product += vec_a[i] * vec_b[i]
          norm_a += vec_a[i]**2
          norm_b += vec_b[i]**2
        end

        magnitude = Math.sqrt(norm_a) * Math.sqrt(norm_b)
        1 - (dot_product / magnitude)
      end

      module_function :squared_euclidean_distance, :euclidean_distance,
                      :manhattan_distance, :sup_distance,
                      :hamming_distance, :simple_matching_distance,
                      :cosine_distance
    end
  end
end
