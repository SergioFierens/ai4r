# frozen_string_literal: true

module Ai4r
  module Som
    # Helper module with distance metrics for node coordinates
    module DistanceMetrics
      # @param dx [Object]
      # @param dy [Object]
      # @return [Object]
      def self.chebyshev(dx, dy)
        [dx.abs, dy.abs].max
      end

      # @param dx [Object]
      # @param dy [Object]
      # @return [Object]
      def self.euclidean(dx, dy)
        Math.sqrt((dx**2) + (dy**2))
      end

      # @param dx [Object]
      # @param dy [Object]
      # @return [Object]
      def self.manhattan(dx, dy)
        dx.abs + dy.abs
      end
    end
  end
end
