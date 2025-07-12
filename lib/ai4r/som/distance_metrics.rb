module Ai4r
  module Som
    # Helper module with distance metrics for node coordinates
    module DistanceMetrics
      def self.chebyshev(dx, dy)
        [dx.abs, dy.abs].max
      end

      def self.euclidean(dx, dy)
        Math.sqrt(dx**2 + dy**2)
      end

      def self.manhattan(dx, dy)
        dx.abs + dy.abs
      end
    end
  end
end
