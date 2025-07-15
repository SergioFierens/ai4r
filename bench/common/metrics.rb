module Bench
  module Common
    module_function

    # Compute Sum of Squared Errors given data items and clusters of indexes.
    # @param data [Array] Array of data items or DataSet
    # @param clusters [Array<Array<Integer>>]
    # @return [Float]
    def sse(data, clusters)
      items = data.respond_to?(:data_items) ? data.data_items : data
      dims = items.first.size
      centroids = clusters.map do |idxs|
        Array.new(dims, 0.0).tap do |c|
          idxs.each { |i| dims.times { |d| c[d] += items[i][d] } }
          dims.times { |d| c[d] /= idxs.length.to_f } if idxs.any?
        end
      end

      clusters.each_with_index.sum do |idxs, ci|
        idxs.sum do |i|
          dims.times.sum { |d| (items[i][d] - centroids[ci][d])**2 }
        end
      end
    end

    # Compute mean silhouette coefficient for the clustering result.
    # Distances are squared Euclidean.
    # @param data [Array] Array of data items or DataSet
    # @param clusters [Array<Array<Integer>>]
    # @return [Float]
    def silhouette(data, clusters)
      items = data.respond_to?(:data_items) ? data.data_items : data
      total = 0.0
      count = items.length
      dims = items.first.size

      clusters.each_with_index do |cluster, ci|
        cluster.each do |index|
          # mean intra-cluster distance
          a = 0.0
          if cluster.length > 1
            cluster.each do |j|
              next if j == index
              a += dims.times.sum { |d| (items[index][d] - items[j][d])**2 }
            end
            a /= (cluster.length - 1)
          end

          # mean nearest-cluster distance
          b = nil
          clusters.each_with_index do |other_cluster, cj|
            next if ci == cj
            dist = other_cluster.sum do |j|
              dims.times.sum { |d| (items[index][d] - items[j][d])**2 }
            end
            dist /= other_cluster.length
            b = dist if b.nil? || dist < b
          end

          s = b&.positive? ? (b - a) / [a, b].max : 0.0
          total += s
        end
      end

      total / count
    end

    # Compute classification accuracy between expected and predicted labels.
    # @param actual [Array] ground truth labels
    # @param predicted [Array] predicted labels
    # @return [Float]
    def accuracy(actual, predicted)
      correct = actual.zip(predicted).count { |a, p| a == p }
      correct.to_f / actual.length
    end

    # Macro-averaged precision over all labels.
    # @param actual [Array]
    # @param predicted [Array]
    # @return [Float]
    def precision(actual, predicted)
      labels = actual.uniq
      labels.sum do |label|
        tp = 0
        fp = 0
        actual.zip(predicted).each do |a, p|
          if p == label
            if a == label
              tp += 1
            else
              fp += 1
            end
          end
        end
        denom = tp + fp
        denom.zero? ? 0.0 : tp.to_f / denom
      end / labels.length.to_f
    end

    # Macro-averaged recall over all labels.
    def recall(actual, predicted)
      labels = actual.uniq
      labels.sum do |label|
        tp = 0
        fn = 0
        actual.zip(predicted).each do |a, p|
          if a == label
            if p == label
              tp += 1
            else
              fn += 1
            end
          end
        end
        denom = tp + fn
        denom.zero? ? 0.0 : tp.to_f / denom
      end / labels.length.to_f
    end

    # Macro F1 score derived from precision and recall.
    def f1(actual, predicted)
      p = precision(actual, predicted)
      r = recall(actual, predicted)
      denom = p + r
      denom.zero? ? 0.0 : 2 * p * r / denom
    end

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
