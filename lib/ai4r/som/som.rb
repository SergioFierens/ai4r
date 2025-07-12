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
require 'yaml'
require_relative 'layer'
require_relative 'two_phase_layer'
require_relative 'node'

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
    # * rows => number of rows for the map
    # * columns => number of columns for the map
    # * layer => instante of a layer-algorithm class
    #
    # = About the project
    # Author::    Thomas Kern
    # License::   MPL 1.1
    # Url::       https://github.com/SergioFierens/ai4r

    class Som

      include Ai4r::Data::Parameterizable

      parameters_info rows: "number of rows for the map",
                      columns: "number of columns for the map",
                      nodes: "array holding all nodes of the map",
                      dimension: "sets the dimension of the input",
                      layer: "instance of a layer, defines how the training algorithm works",
                      epoch: "number of finished epochs",
                      init_weight_options: "Hash with :range and :seed to initialize node weights"

      def initialize(dim, rows, columns, layer, init_weight_options = { range: 0..1, seed: nil })

        @layer = layer
        @dimension = dim
        @rows = rows
        @columns = columns
        @nodes = Array.new(rows * columns)
        @epoch = 0
        @cache = {}
        opts = { range: 0..1, random_seed: nil, seed: nil }.merge(init_weight_options)
        opts[:random_seed] = opts[:random_seed] || opts[:seed]
        @init_weight_options = opts
      end

      # finds the best matching unit (bmu) of a certain input in all the @nodes
      # returns an array of length 2 => [node, distance] (distance is of eucledian type, not
      # a neighborhood distance)
      # @param input [Object]
      # @return [Object]
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
      # @param input [Object]
      # @param bmu [Object]
      # @param radius [Object]
      # @param learning_rate [Object]
      # @return [Object]
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
      # @param data [Object]
      # @param error_threshold [Object]
      # @return [Object]
      def train(data, error_threshold: nil)
        errors = []
        while @epoch < @layer.epochs
          error = train_step(data, error_threshold: error_threshold)
          errors << error
          yield error if block_given?
        end
        errors
      end

      # calculates the global distance error for all data entries
      # @param data [Object]
      # @return [Object]
      def global_error(data)
        data.inject(0) {|sum,entry| sum + find_bmu(entry)[1]**2 }
       end

      # Train the map for one epoch using +data+.
      # Returns the computed +global_error+ for that epoch. If a block is
      # provided, the error is yielded instead of returned.
      # Training stops early when +error_threshold+ is defined and the computed
      # error falls below it.
      # @param data [Object]
      # @param error_threshold [Object]
      # @return [Object]
      def train_step(data, error_threshold: nil)
        return nil if @epoch >= @layer.epochs

        radius = @layer.radius_decay @epoch
        learning_rate = @layer.learning_rate_decay @epoch

        data.each do |entry|
          adjust_nodes entry, find_bmu(entry), radius, learning_rate
        end

        @epoch += 1
        error = global_error(data)
        @epoch = @layer.epochs if error_threshold && error <= error_threshold
        yield error if block_given?
        error
      end

      # returns the node at position (x,y) in the map
      # @param x [Object]
      # @param y [Object]
      # @return [Object]
      def get_node(x, y)
        if check_param_for_som(x, y)
          raise ArgumentError, "invalid node coordinates (#{x}, #{y})"
        end
        @nodes[y + x * @columns]
      end

      # intitiates the map by creating (@rows * @columns) nodes
      # @return [Object]
      def initiate_map
        seed = @init_weight_options[:random_seed]
        srand(seed) unless seed.nil?
        @nodes.each_with_index do |node, i|
          options = @init_weight_options.merge(distance_metric: @layer.distance_metric)
          @nodes[i] = Node.create i, @rows, @columns, @dimension, options
        end
      end

      # Serialize this SOM to a Ruby Hash.  The resulting structure includes
      # map dimensions, layer parameters and all node weights.
      # @return [Object]
      def to_h
        {
          'rows' => @rows,
          'columns' => @columns,
          'dimension' => @dimension,
          'epoch' => @epoch,
          'layer' => {
            'class' => @layer.class.name,
            'parameters' => @layer.get_parameters,
            'initial_learning_rate' => @layer.instance_variable_get('@initial_learning_rate')
          },
          'nodes' => @nodes.map(&:weights)
        }
      end

      # Build a new SOM instance from the Hash generated by +to_h+.
      # @param hash [Object]
      # @return [Object]
      def self.from_h(hash)
        layer_class = Object.const_get(hash['layer']['class'])
        raw_params = hash['layer']['parameters'] || {}
        params = {}
        raw_params.each do |k, v|
          params[k.to_s] = v
        end
        ilr = hash['layer']['initial_learning_rate']

        layer = if layer_class == TwoPhaseLayer
                   layer_class.new(
                     params['nodes'],
                     ilr || 0.9,
                     params['epochs'],
                     0,
                     0.1,
                     0
                   )
                 else
                   layer_class.new(
                     params['nodes'],
                     params['radius'],
                     params['epochs'],
                     ilr || 0.7
                   )
                 end
        layer.set_parameters(params) if layer.respond_to?(:set_parameters)

        som = Som.new(hash['dimension'], hash['rows'], hash['columns'], layer)
        som.epoch = hash['epoch']
        som.nodes = hash['nodes'].each_with_index.map do |weights, i|
          node = Node.new
          node.id = i
          node.x = i % hash['columns']
          node.y = (i / hash['columns'].to_f).to_i
          node.weights = weights.dup
          node.instantiated_weight = weights.dup
          node
        end
        som
      end

      # Save this SOM to a YAML file.
      # @param path [Object]
      # @return [Object]
      def save_yaml(path)
        File.open(path, 'w') { |f| f.write(YAML.dump(to_h)) }
      end

      # Load a SOM from a YAML file created by +save_yaml+.
      # @param path [Object]
      # @return [Object]
      def self.load_yaml(path)
        from_h(YAML.load_file(path))
      end

      private

      # checks whether or not there is a node in the map at the coordinates (x,y).
      # x is the row, y the column indicator
      # @param x [Object]
      # @param y [Object]
      # @return [Object]
      def check_param_for_som(x, y)
        y > @columns - 1 || x > @rows - 1  || x < 0 || y < 0
      end

    end

  end

end
