module Ai4r
  module Clusterers
    # Mixin to capture merge steps during agglomerative clustering.
    # Stores intermediate clusters in +cluster_tree+. Optional +depth+
    # limits how many last merges are recorded.
    module ClusterTree
      attr_reader :cluster_tree

      # @param depth [Object]
      # @param args [Object]
      # @return [Object]
      def initialize(depth = nil, *args)
        @cluster_tree = []
        @depth = depth
        @merges_so_far = 0
        super(*args)
      end

      # @param data_set [Object]
      # @param number_of_clusters [Object]
      # @param *options [Object]
      # @return [Object]
      def build(data_set, number_of_clusters = 1, **options)
        @total_merges = data_set.data_items.length - number_of_clusters
        super
        @cluster_tree << self.clusters
        @cluster_tree.reverse!
        self
      end

      protected

      # @param index_a [Object]
      # @param index_b [Object]
      # @param index_clusters [Object]
      # @return [Object]
      def merge_clusters(index_a, index_b, index_clusters)
        if @depth.nil? || @merges_so_far > @total_merges - @depth
          stored_distance_matrix = @distance_matrix.dup
          @cluster_tree << build_clusters_from_index_clusters(index_clusters)
          @distance_matrix = stored_distance_matrix
        end
        @merges_so_far += 1
        super
      end
    end
  end
end
