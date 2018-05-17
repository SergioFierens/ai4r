# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
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
    # This is an implementation of a Kohonen Self-Organizing Maps
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
    # * dim => dimension of the input vector
    # * number_of_nodes => is the number of nodes per row/column (square som).
    # * layer => instante of a layer-algorithm class
    #
    # = About the project
    # Author::    Thomas Kern
    # License::   MPL 1.1
    # Url::       https://github.com/SergioFierens/ai4r

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
        @cache = {}
      end

      # finds the best matching unit (bmu) of a certain input in all the @nodes
      # returns an array of length 2 => [node, distance] (distance is of eucledian type, not
      # a neighborhood distance)
      def find_bmu(input)
        bmu = @nodes.first
        dist = bmu.distance_to_input input
        @nodes[1..-1].each do |node|
          tmp_dist = node.distance_to_input(input)
          if tmp_dist <= dist
            dist = tmp_dist
            bmu = node
          end
        end
        [bmu, dist]
      end

      # adjusts all nodes within a certain radius to the bmu
      def adjust_nodes(input, bmu, radius, learning_rate)
        @nodes.each do |node|
          dist = node.distance_to_node(bmu[0])
          next unless dist < radius

          influence = @layer.influence_decay dist, radius
          node.weights.each_with_index do |weight, index|
            node.weights[index] +=  influence * learning_rate * (input[index] - weight)
          end
        end
      end

      # main method for the som. trains the map with the passed data vector
      # calls train_step as long as train_step returns false
      def train(data)
        while !train_step(data)
        end
      end

      # calculates the global distance error for all data entries
      def global_error(data)
        data.inject(0) {|sum,entry| sum + find_bmu(entry)[1]**2 }
       end

      # trains the map with the data as long as the @epoch is smaller than the epoch-value of
      # @layer
      # returns true if @epoch is greater than the fixed epoch-value in @layer, otherwise false
      # 1 is added to @epoch at each method call
      # the radius and learning rate is decreased at each method call/epoch as well
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

      # returns the node at position (x,y) in the square map
      def get_node(x, y)
        raise(Exception.new) if check_param_for_som(x,y)
        @nodes[y + x * @number_of_nodes]
      end

      # intitiates the map by creating (@number_of_nodes * @number_of_nodes) nodes
      def initiate_map
        @nodes.each_with_index do |node, i|
          @nodes[i] = Node.create i, @number_of_nodes, @dimension
        end
      end

      private

      # checks whether or not there is a node in the map at the coordinates (x,y).
      # x is the row, y the column indicator
      def check_param_for_som(x, y)
        y > @number_of_nodes - 1 || x > @number_of_nodes - 1  || x < 0 || y < 0
      end

    end

  end

end
