module Bench
  module Common
    # Simple container for benchmark metrics.
    class Metrics
      attr_reader :algorithm, :data

      def initialize(algorithm, data = {})
        @algorithm = algorithm
        @data = data
      end

      def [](key)
        @data[key]
      end

      def to_h
        { algorithm: @algorithm }.merge(@data)
      end
    end
  end
end
