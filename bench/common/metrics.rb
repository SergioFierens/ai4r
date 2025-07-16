# Helper metrics used by benchmark scripts.
module Bench
  # Common benchmark metrics.
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

    # Classification metrics -------------------------------------------------

    # @param truth [Array] ground truth labels
    # @param preds [Array] predicted labels
    # @return [Float]
    def accuracy(truth, preds)
      correct = truth.zip(preds).count { |t, p| t == p }
      correct / truth.length.to_f
    end

    def precision(truth, preds)
      labels = truth.uniq
      sum = labels.sum do |label|
        tp = 0
        fp = 0
        truth.each_index do |i|
          next unless preds[i] == label

          if truth[i] == label
            tp += 1
          else
            fp += 1
          end
        end
        (tp + fp).positive? ? tp.to_f / (tp + fp) : 0.0
      end
      sum / labels.size.to_f
    end

    def recall(truth, preds)
      labels = truth.uniq
      sum = labels.sum do |label|
        tp = 0
        fn = 0
        truth.each_index do |i|
          next unless truth[i] == label

          if preds[i] == label
            tp += 1
          else
            fn += 1
          end
        end
        (tp + fn).positive? ? tp.to_f / (tp + fn) : 0.0
      end
      sum / labels.size.to_f
    end

    def f1(truth, preds)
      p = precision(truth, preds)
      r = recall(truth, preds)
      (p + r).positive? ? 2 * p * r / (p + r) : 0.0
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
