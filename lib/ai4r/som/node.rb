require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'

module Ai4r

  module Som

    class Node

      include Ai4r::Data::Parameterizable

      parameters_info :weights => "holds the current weight",
                      :instantiated_weight => "holds the very first weight",
                      :x => "holds the row ID of the unit in the map",
                      :y => "holds the column ID of the unit in the map",
                      :id => "id of the node"      

      def self.create(id, total, dimensions)
        n = Node.new
        n.id = id
        n.instantiate_weight dimensions
        n.x = id % total
        n.y = (id / total).to_i
        n
      end

      def instantiate_weight(dimensions)
        @weights = Array.new dimensions
        @instantiated_weight = Array.new dimensions
        @weights.each_with_index do |weight, index|
          @weights[index] = rand
          @instantiated_weight[index] = @weights[index]
        end
      end

      def distance_to_input(input)
        dist = 0
        input.each_with_index do |i, index|
          dist += (i - @weights[index]) ** 2
        end

        Math.sqrt(dist)
      end

      def distance_to_node(node)
        max((self.x - node.x).abs, (self.y - node.y).abs)
      end

      private

      def max(a, b)
        a > b ? a : b
      end

    end

  end

end
