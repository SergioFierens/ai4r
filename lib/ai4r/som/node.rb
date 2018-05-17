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

module Ai4r

  module Som

    # this class is used for the individual node and will be (nodes * nodes)-time instantiated
    #
    # = attributes
    #
    # * direct access to the x and y values is granted, those show the position of the node in
    # the square map
    # * id => is the uniq and sequential ID of the node
    # * weights => values of the current weights are stored in an array of dimension 'dimensions'.
    # Weights are of type float
    # * instantiated_weight => the values of the first instantiation of weights. these values are
    # never changed 

    class Node

      include Ai4r::Data::Parameterizable

      parameters_info :weights => "holds the current weight",
                      :instantiated_weight => "holds the very first weight",
                      :x => "holds the row ID of the unit in the map",
                      :y => "holds the column ID of the unit in the map",
                      :id => "id of the node"      

      # creates an instance of Node and instantiates the weights
      # the parameters is a uniq and sequential ID as well as the number of total nodes
      # dimensions signals the dimension of the input vector
      def self.create(id, total, dimensions)
        n = Node.new
        n.id = id
        n.instantiate_weight dimensions
        n.x = id % total
        n.y = (id / total.to_f).to_i
        n
      end

      # instantiates the weights to the dimension (of the input vector)
      # for backup reasons, the instantiated weight is stored into @instantiated_weight  as well
      def instantiate_weight(dimensions)
        @weights = Array.new dimensions
        @instantiated_weight = Array.new dimensions
        @weights.each_with_index do |weight, index|
          @weights[index] = rand
          @instantiated_weight[index] = @weights[index]
        end
      end

      # returns the square distance between the current weights and the input
      # the input is a vector/array of the same size as weights
      # at the end, the square root is extracted from the sum of differences
      def distance_to_input(input)
        dist = 0
        input.each_with_index do |i, index|
          dist += (i - @weights[index]) ** 2
        end

        Math.sqrt(dist)
      end

      # returns the distance in square-form from the instance node to the passed node
      # example:
      # 2 2 2 2 2
      # 2 1 1 1 2
      # 2 1 0 1 2
      # 2 1 1 1 2
      # 2 2 2 2 2
      # 0 being the current node
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
