# frozen_string_literal: true
# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/parameterizable'
require_relative 'layer'
require_relative 'distance_metrics'

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

      parameters_info weights: "holds the current weight",
                      instantiated_weight: "holds the very first weight",
                      x: "holds the row ID of the unit in the map",
                      y: "holds the column ID of the unit in the map",
                      id: "id of the node",
                      distance_metric: "metric used to compute node distance"

      # creates an instance of Node and instantiates the weights
      #
      # +id+:: unique identifier for this node
      # +rows+:: number of rows of the SOM grid
      # +columns+:: number of columns of the SOM grid
      # +dimensions+:: dimension of the input vector
      # @param id [Object]
      # @param rows [Object]
      # @param columns [Object]
      # @param dimensions [Object]
      # @param options [Object]
      # @option options [Range] :range (0..1) range used to initialize weights
      # @option options [Integer] :random_seed Seed for Ruby's RNG. The
      #   deprecated :seed key is supported for backward compatibility.
      # @return [Object]
      def self.create(id, rows, columns, dimensions, options = {})
        n = Node.new
        n.id = id
        n.distance_metric = options[:distance_metric] || :chebyshev
        n.instantiate_weight dimensions, options
        n.x = id % columns
        n.y = (id / columns.to_f).to_i
        n
      end

      # instantiates the weights to the dimension (of the input vector)
      # for backup reasons, the instantiated weight is stored into @instantiated_weight  as well
      # @param dimensions [Object]
      # @param options [Object]
      # @option options [Range] :range (0..1) range used to initialize weights
      # @option options [Integer] :random_seed Seed for Ruby's RNG. The
      #   deprecated :seed key is supported for backward compatibility.
      # @return [Object]
      def instantiate_weight(dimensions, options = {})
        opts = { range: 0..1, random_seed: nil, seed: nil }.merge(options)
        seed = opts[:random_seed] || opts[:seed]
        srand(seed) unless seed.nil?
        range = opts[:range] || (0..1)
        min = range.first.to_f
        max = range.last.to_f
        span = max - min
        @weights = Array.new dimensions
        @instantiated_weight = Array.new dimensions
        @weights.each_with_index do |weight, index|
          @weights[index] = min + rand * span
          @instantiated_weight[index] = @weights[index]
        end
      end

      # returns the square distance between the current weights and the input
      # the input is a vector/array of the same size as weights
      # at the end, the square root is extracted from the sum of differences
      # @param input [Object]
      # @return [Object]
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
      # @param node [Object]
      # @return [Object]
      def distance_to_node(node)
        dx = self.x - node.x
        dy = self.y - node.y
        metric = (@distance_metric || :chebyshev)
        DistanceMetrics.send(metric, dx, dy)
      end

    end

  end

end
