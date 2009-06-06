require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'
require File.dirname(__FILE__) + '/node'

module Ai4r

  module Som

    class Som

      include Ai4r::Data::Parameterizable

      parameters_info :nodes  => "sets the architecture of the map (nodes x nodes)",
                      :dimension => "sets the dimension of the input",
                      :layer => "instance of a layer, defines how the training algorithm works"

      def initialize(dim, number_of_nodes, layer)
        @layer = layer
        @dimension = dim
        @number_of_nodes = number_of_nodes
        @nodes = Array.new(number_of_nodes * number_of_nodes)
      end

      def neighboorhood_for(node, radius)
         []
      end

      def get_node(x, y)
        raise if y > @number_of_nodes - 1 || x > @number_of_nodes - 1        
        @nodes[y + x * @number_of_nodes]
      end

      def initiate_map
        @nodes.each_with_index do |node, i|
          @nodes[i] = Node.create i, @number_of_nodes, @dimension
        end
      end

      def node_distance(node1, node2)
        max((node1.x - node2.x).abs, (node1.y - node2.y).abs)
      end

      private

      def max(a, b)
        a > b ? a : b
      end
      
    end

  end

end