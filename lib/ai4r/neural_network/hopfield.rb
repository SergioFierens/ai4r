# frozen_string_literal: true
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/parameterizable' 

 module Ai4r
   
  module NeuralNetwork
    
    # = Hopfield Net =
    # 
    # A Hopfield Network is a recurrent Artificial Neural Network.
    # Hopfield nets are able to memorize a set of patterns, and then evaluate 
    # an input, returning the most similar stored pattern (although
    # convergence to one of the stored patterns is not guaranteed).
    # Hopfield nets are great to deal with input noise. If a system accepts a 
    # discrete set of inputs, but inputs are subject to noise, you can use a 
    # Hopfield net to eliminate noise and identified the given input.
    #
    # = How to Use =
    # 
    #   data_set = Ai4r::Data::DataSet.new :data_items => array_of_patterns
    #   net = Ai4r::NeuralNetworks::Hopfield.new.train data_set
    #   net.eval input
    #     => one of the stored patterns in array_of_patterns
    class Hopfield
      
      include Ai4r::Data::Parameterizable
      
      attr_reader :weights, :nodes

      parameters_info eval_iterations: "The network will run for a maximum "+
        "of 'eval_iterations' iterations while evaluating an input. 500 by " +
        "default.",
        active_node_value: "Default: 1",
        inactive_node_value: "Default: -1",
        threshold: "Default: 0",
        weight_scaling: "Scale factor applied when computing weights. " +
          "Default 1.0 / patterns_count",
        stop_when_stable: "Stop evaluation when consecutive energy " +
          "values do not change. False by default",
        update_strategy: "Update mode: :async_random (default), " +
          ":async_sequential, :synchronous"
            
      def initialize(params = {})
        @eval_iterations = 500
        @active_node_value = 1
        @inactive_node_value = -1
        @threshold = 0
        @weight_scaling = nil
        @stop_when_stable = false
        @update_strategy = :async_sequential
        set_parameters(params) if params && !params.empty?
      end

      # Prepares the network to memorize the given data set.
      # Future calls to eval (should) return one of the memorized data items.
      # A Hopfield network converges to a local minimum, but converge to one 
      # of the "memorized" patterns is not guaranteed.
      def train(data_set)
        @data_set = data_set
        validate_training_data
        initialize_nodes(@data_set)
        initialize_weights(@data_set)
        return self
      end

      # You can use run instead of eval to propagate values step by step.
      # With this you can verify the progress of the network output with 
      # each step.
      # 
      # E.g.:
      #   pattern = input
      #   100.times do
      #      pattern = net.run(pattern)
      #      puts pattern.inspect
      #   end
      def run(input)
        set_input(input)
        propagate
        return @nodes
      end

      # Propagates the input until the network returns one of the memorized
      # patterns, or a maximum of "eval_iterations" times.
      #
      # If +trace: true+ is passed the method returns a hash with the
      # :states and :energies recorded at every iteration (including the
      # initial state). This can be used to visualize convergence.
      def eval(input, trace: false)
        set_input(input)
        prev_energy = energy
        if trace
          states = [@nodes.clone]
          energies = [prev_energy]
        end
        @eval_iterations.times do
          propagate
          new_energy = energy
          if trace
            states << @nodes.clone
            energies << new_energy
          end
          return(trace ? { states: states, energies: energies } : @nodes) if @data_set.data_items.include?(@nodes)
          break if @stop_when_stable && new_energy == prev_energy
          prev_energy = new_energy
        end
        trace ? { states: states, energies: energies } : @nodes
      end

      # Calculate network energy using current node states and weights.
      # Energy = -0.5 * Σ w_ij * s_i * s_j
      def energy
        sum = 0.0
        @nodes.each_with_index do |s_i, i|
          i.times do |j|
            sum += read_weight(i, j) * s_i * @nodes[j]
          end
        end
        -sum
      end

      protected
      # Set all nodes state to the given input.
      # inputs parameter must have the same dimension as nodes
      def set_input(inputs)
        raise ArgumentError unless inputs.length == @nodes.length
        inputs.each_with_index { |input, i| @nodes[i] = input}
      end
      
      # Propagate network state according to configured update strategy.
      def propagate
        case @update_strategy
        when :async_sequential
          propagate_async_sequential
        when :synchronous
          propagate_synchronous
        else
          propagate_async_random
        end
      end

      # Select a single node randomly and propagate its state to all other nodes
      def propagate_async_random
        sum = 0
        i = (rand * @nodes.length).floor
        @nodes.each_with_index { |node, j| sum += read_weight(i, j) * node }
        @nodes[i] = (sum > @threshold) ? @active_node_value : @inactive_node_value
      end

      # Iterate through nodes sequentially, updating each immediately
      def propagate_async_sequential
        @nodes.each_index do |i|
          sum = 0
          @nodes.each_with_index { |node, j| sum += read_weight(i, j) * node }
          @nodes[i] = (sum > @threshold) ? @active_node_value : @inactive_node_value
        end
      end

      # Update all nodes simultaneously using previous state
      def propagate_synchronous
        new_nodes = Array.new(@nodes.length)
        @nodes.each_index do |i|
          sum = 0
          @nodes.each_with_index { |node, j| sum += read_weight(i, j) * node }
          new_nodes[i] = (sum > @threshold) ? @active_node_value : @inactive_node_value
        end
        @nodes = new_nodes
      end

      # Initialize all nodes with "inactive" state.
      def initialize_nodes(data_set)
        @nodes = Array.new(data_set.data_items.first.length,
          @inactive_node_value)
      end

      # Ensure training data only contains active or inactive values.
      def validate_training_data
        allowed = [@active_node_value, @inactive_node_value]
        @data_set.data_items.each_with_index do |item, row|
          item.each_with_index do |v, col|
            unless allowed.include?(v)
              raise ArgumentError, "Invalid value #{v} in item #{row}, position #{col}"
            end
          end
        end
      end

      # Create a partial weigth matrix:
      #   [
      #     [w(1,0)],
      #     [w(2,0)], [w(2,1)],
      #     [w(3,0)], [w(3,1)], [w(3,2)],
      #     ... 
      #     [w(n-1,0)], [w(n-1,1)], [w(n-1,2)], ... , [w(n-1,n-2)]
      #   ]
      # where n is the number of nodes.
      # 
      # We are saving memory here, as:
      # 
      # * w[i][i] = 0 (no node connects with itself)
      # * w[i][j] = w[j][i] (weigths are symmetric)
      # 
      # Use read_weight(i,j) to find out weight between node i and j
      def initialize_weights(data_set)
        patterns_count = data_set.data_items.length
        scaling = @weight_scaling || (1.0 / patterns_count)
        @weights = Array.new(@nodes.length-1) {|l| Array.new(l+1)}
        @nodes.each_index do |i|
          i.times do |j|
            sum = data_set.data_items.inject(0) { |s, item| s + item[i] * item[j] }
            @weights[i-1][j] = sum * scaling
          end
        end
      end
      
      # read_weight(i,j) reads the weigth matrix and returns weight between 
      # node i and j
      def read_weight(index_a, index_b)
        return 0 if index_a == index_b
        index_a, index_b = index_b, index_a if index_b > index_a
        return @weights[index_a-1][index_b]
      end
      
    end
    
  end
  
end
