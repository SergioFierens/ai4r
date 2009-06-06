require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'
require File.dirname(__FILE__) + '/two_phase_layer'
require File.dirname(__FILE__) + '/node'

module Ai4r

  module Som

    class Som

      include Ai4r::Data::Parameterizable

      parameters_info :nodes  => "sets the architecture of the map (nodes x nodes)",
                      :dimension => "sets the dimension of the input",
                      :layer => "instance of a layer, defines how the training algorithm works",
                      :epoch => "number of finished epochs"

      def initialize(dim, number_of_nodes, layer)
        @layer = layer
        @dimension = dim
        @number_of_nodes = number_of_nodes
        @nodes = Array.new(number_of_nodes * number_of_nodes)
        @epoch = 0
      end

      def neighboorhood_for(bmu, radius)
        @nodes.select do |node|
          node.distance_to_node(bmu) <= radius && node.distance_to_node(bmu) > 0
        end
      end

      def find_bmu(input)
        bmu = @nodes.first
        dist = bmu.distance_to_input input
        @nodes.each do |node|
            if (tmp_dist = node.distance_to_input(input)) < dist
              dist = tmp_dist
              bmu = node
            end
        end
        bmu
      end

      def adjust_nodes(input, bmu, radius, learning_rate)
        hood = neighboorhood_for bmu, radius
        hood.each do |node| 
          influence = @layer.influence_decay node.distance_to_node(bmu), radius
          node.weights.each_with_index do |weight, index|
              weight += influence * learning_rate * (input[index] - weight)
          end
        end
      end

      def train(data)
        while !train_step(data)          
        end
      end

      def train_step(data)
        return true if @epoch >= @layer.epochs

        radius = @layer.radius_decay @epoch
        learning_rate = @layer.learning_rate_decay @epoch

        data.each do |entry|
            adjust_nodes entry, find_bmu(entry), radius, learning_rate
        end

        @epoch += 1
        false
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
        node1.distance_to_node node2
      end

    end

  end

end