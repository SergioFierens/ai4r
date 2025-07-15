require 'ai4r/data/proximity'

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

    module_function

    def silhouette(data_set, index_clusters)
      return nil if index_clusters.empty?

      dist = lambda do |i, j|
        Ai4r::Data::Proximity.squared_euclidean_distance(
          data_set.data_items[i],
          data_set.data_items[j]
        )
      end

      total = 0.0
      count = data_set.data_items.length

      index_clusters.each do |cluster|
        cluster.each do |index|
          a = 0.0
          if cluster.length > 1
            cluster.each { |j| a += dist.call(index, j) unless j == index }
            a /= (cluster.length - 1)
          end

          b = nil
          index_clusters.each do |other|
            next if other.equal?(cluster)

            d = 0.0
            other.each { |j| d += dist.call(index, j) }
            d /= other.length
            b = d if b.nil? || d < b
          end

          s = b&.positive? ? (b - a) / [a, b].max : 0.0
          total += s
        end
      end

      total / count
    end

    def sse(data_set, index_clusters)
      return 0.0 if index_clusters.empty?

      centroids = index_clusters.map do |cluster|
        sums = Array.new(data_set.data_items.first.length, 0.0)
        cluster.each do |idx|
          data_set.data_items[idx].each_with_index do |val, i|
            sums[i] += val.to_f
          end
        end
        sums.map { |s| s / cluster.length }
      end

      total = 0.0
      index_clusters.each_with_index do |cluster, ci|
        centroid = centroids[ci]
        cluster.each do |idx|
          total += Ai4r::Data::Proximity.squared_euclidean_distance(
            data_set.data_items[idx], centroid
          )
        end
      end
      total
    end
  end
end
