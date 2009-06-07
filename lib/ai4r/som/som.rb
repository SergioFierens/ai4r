# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'
require File.dirname(__FILE__) + '/two_phase_layer'
require File.dirname(__FILE__) + '/node'

module Ai4r

  # A self-organizing map (SOM) or self-organizing feature map (SOFM) is a type
  # of artificial neural network that is trained using unsupervised learning to
  # produce a low-dimensional (typically two-dimensional), discretized
  # representation of the input space of the training samples, called a map.

  # for more have a look at http://en.wikipedia.org/wiki/Self-organizing_map
  # an in-depth explanation is provided by Sandhya Samarasinghe in
  # 'Neural Networks for Applied Sciences and Engineering'

  module Som

    # = Introduction
    #
    # This is an implementation of a self organizing map according to the explanation
    # in the book 'Neural Networks for Applied Sciences and Engineering' by Sandhya
    # Samarasinghe
    #
    # = Features
    #
    # * Support for any network architecture (number of layers and neurons)
    # * Configurable propagation function
    # * Optional usage of bias
    # * Configurable momentum
    # * Configurable learning rate
    # * Configurable initial weight function
    # * 100% ruby code, no external dependency
    #
    # = Parameters
    #
    # = About the project
    # Author::    Thomas Kern
    # License::   MPL 1.1
    # Url::       http://ai4r.rubyforge.org

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
          node.distance_to_node(bmu) <= radius
        end
      end

      def find_bmu(input)
        bmu = @nodes.first
        dist = bmu.distance_to_input input
        @nodes.each do |node|

          tmp_dist = node.distance_to_input(input)
          if tmp_dist <= dist
            dist = tmp_dist
            bmu = node
          end
        end
        bmu
      end

      def adjust_nodes(input, bmu, radius, learning_rate)
        neighboorhood_for(bmu, radius).each_with_index do |node, index|
          influence = @layer.influence_decay node.distance_to_node(bmu), radius
          node.weights.each_with_index do |weight, index|
            node.weights[index] += influence * learning_rate * (input[index] - weight)
          end
        end
      end

      def train(data)
        while !train_step(data)
        end
      end

      def global_error(data)
        sum = 0
        data.each do |entry|
          bmu = find_bmu(entry)
          sum += bmu.distance_to_input(entry)**2

        end
        sum
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
        raise if check_param_for_som(x,y)
        @nodes[y + x * @number_of_nodes]
      end

      def check_param_for_som(x, y)
        y > @number_of_nodes - 1 || x > @number_of_nodes - 1
      end

      def initiate_map
        @nodes.each_with_index do |node, i|
          @nodes[i] = Node.create i, @number_of_nodes, @dimension
        end
      end

    end

  end

end