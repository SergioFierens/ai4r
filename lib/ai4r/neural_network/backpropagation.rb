# frozen_string_literal: true
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       hhttps://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/parameterizable'
require_relative 'activation_functions'
require_relative 'weight_initializations'

module Ai4r
  
  # Artificial Neural Networks are mathematical or computational models based on 
  # biological neural networks. 
  # 
  # More about neural networks:
  # 
  # * http://en.wikipedia.org/wiki/Artificial_neural_network
  #
  module NeuralNetwork
    
    # = Introduction
    # 
    # This is an implementation of a multilayer perceptron network, using
    # the backpropagation algorithm for learning.
    # 
    # Backpropagation is a supervised learning technique (described 
    # by Paul Werbos in 1974, and further developed by David E. 
    # Rumelhart, Geoffrey E. Hinton and Ronald J. Williams in 1986)
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
    # Use class method get_parameters_info to obtain details on the algorithm
    # parameters. Use set_parameters to set values for this parameters.
    # 
    # * :disable_bias => If true, the algorithm will not use bias nodes.
    #   False by default.
    # * :initial_weight_function => f(n, i, j) must return the initial 
    #   weight for the conection between the node i in layer n, and node j in 
    #   layer n+1. By default a random number in [-1, 1) range.
    # * :propagation_function => By default: 
    #   lambda { |x| 1/(1+Math.exp(-1*(x))) }
    # * :derivative_propagation_function => Derivative of the propagation
    #   function, based on propagation function output.
    #   By default: lambda { |y| y*(1-y) }, where y=propagation_function(x)
    # * :activation => Built-in activation name (:sigmoid, :tanh or :relu).
    #   Selecting this overrides propagation_function and derivative_propagation_function.
    #   Default: :sigmoid
    # * :learning_rate => By default 0.25
    # * :momentum => By default 0.1. Set this parameter to 0 to disable
    #   momentum
    # 
    # = How to use it
    # 
    #   # Create the network with 4 inputs, 1 hidden layer with 3 neurons,
    #   # and 2 outputs
    #   net = Ai4r::NeuralNetwork::Backpropagation.new([4, 3, 2])  
    #
    #   # Train the network 
    #   1000.times do |i|
    #     net.train(example[i], result[i])
    #   end
    #   
    #   # Use it: Evaluate data with the trained network
    #   net.eval([12, 48, 12, 25])  
    #     =>  [0.86, 0.01]   
    #     
    # More about multilayer perceptron neural networks and backpropagation:
    # 
    # * http://en.wikipedia.org/wiki/Backpropagation
    # * http://en.wikipedia.org/wiki/Multilayer_perceptron
    # 
    # = About the project
    # Author::    Sergio Fierens
    # License::   MPL 1.1
    # Url::       https://github.com/SergioFierens/ai4r
    class Backpropagation
      
      include Ai4r::Data::Parameterizable
      
      parameters_info :disable_bias => "If true, the algorithm will not use "+
            "bias nodes. False by default.",
        :initial_weight_function => "f(n, i, j) must return the initial "+
            "weight for the conection between the node i in layer n, and "+
            "node j in layer n+1. By default a random number in [-1, 1) range.",
        :weight_init => "Built-in weight initialization strategy (:uniform, :xavier or :he). Default: :uniform",
        :propagation_function => "By default: " +
            "lambda { |x| 1/(1+Math.exp(-1*(x))) }",
        :derivative_propagation_function => "Derivative of the propagation "+
            "function, based on propagation function output. By default: " +
            "lambda { |y| y*(1-y) }, where y=propagation_function(x)",
        :activation => "Activation function per layer. Provide a symbol or an array of symbols (:sigmoid, :tanh, :relu or :softmax). Default: :sigmoid",
        :learning_rate => "By default 0.25",
        :momentum => "By default 0.1. Set this parameter to 0 to disable "+
            "momentum.",
        :loss_function => "Loss function used when training (:mse or " +
            ":cross_entropy). Default: :mse"
          
      attr_accessor :structure, :weights, :activation_nodes, :last_changes

      # When the activation parameter changes, update internal lambdas for each
      # layer. Accepts a single symbol or an array of symbols (one for each
      # layer except the input layer).
      def activation=(symbols)
        symbols = [symbols] unless symbols.is_a?(Array)
        layer_count = @structure.length - 1
        if symbols.length == 1
          symbols = Array.new(layer_count, symbols.first)
        elsif symbols.length != layer_count
          raise ArgumentError, "Activation array size must match number of layers (#{layer_count})"
        end
        @activation = symbols
        @propagation_functions = @activation.map do |a|
          Ai4r::NeuralNetwork::ActivationFunctions::FUNCTIONS[a] ||
            Ai4r::NeuralNetwork::ActivationFunctions::FUNCTIONS[:sigmoid]
        end
        @derivative_functions = @activation.map do |a|
          Ai4r::NeuralNetwork::ActivationFunctions::DERIVATIVES[a] ||
            Ai4r::NeuralNetwork::ActivationFunctions::DERIVATIVES[:sigmoid]
        end
      end

      def activation
        @activation
      end

      def weight_init=(symbol)
        @weight_init = symbol
        @initial_weight_function = case symbol
          when :xavier
            Ai4r::NeuralNetwork::WeightInitializations.xavier(@structure)
          when :he
            Ai4r::NeuralNetwork::WeightInitializations.he(@structure)
          else
            Ai4r::NeuralNetwork::WeightInitializations.uniform
          end
      end

      def loss_function=(symbol)
        @loss_function = symbol
        if symbol == :cross_entropy && !@activation_overridden && !@custom_propagation
          @set_by_loss = true
          self.activation = :softmax
          @activation_overridden = false
        end
      end
      
      # Creates a new network specifying the its architecture.
      # E.g.
      #    
      #   net = Backpropagation.new([4, 3, 2])  # 4 inputs
      #                                         # 1 hidden layer with 3 neurons, 
      #                                         # 2 outputs    
      #   net = Backpropagation.new([2, 3, 3, 4])   # 2 inputs
      #                                             # 2 hidden layer with 3 neurons each, 
      #                                             # 4 outputs    
      #   net = Backpropagation.new([2, 1])   # 2 inputs
      #                                       # No hidden layer
      #                                       # 1 output      
      def initialize(network_structure, activation = :sigmoid, weight_init = :uniform)
        @structure = network_structure
        self.weight_init = weight_init
        @custom_propagation = false
        @set_by_loss = true
        self.activation = activation
        @activation_overridden = (activation != :sigmoid)
        @set_by_loss = false
        @disable_bias = false
        @learning_rate = 0.25
        @momentum = 0.1
        @loss_function = :mse
      end
      #     net.eval([25, 32.3, 12.8, 1.5])
      #         # =>  [0.83, 0.03]
      def eval(input_values)
        check_input_dimension(input_values.length)
        init_network if !@weights
        feedforward(input_values)
        return @activation_nodes.last.clone
      end
      
      # Evaluates the input and returns most active node
      # E.g.
      #     net = Backpropagation.new([4, 3, 2])
      #     net.eval_result([25, 32.3, 12.8, 1.5])
      #         # eval gives [0.83, 0.03]
      #         # =>  0
      def eval_result(input_values)
        result = eval(input_values)
        result.index(result.max)
      end
      
      # This method trains the network using the backpropagation algorithm.
      # 
      # input: Networks input
      # 
      # output: Expected output for the given input.
      #
      # This method returns the training loss according to +loss_function+.
      def train(inputs, outputs)
        eval(inputs)
        backpropagate(outputs)
        calculate_loss(outputs, @activation_nodes.last)
      end

      # Train a list of input/output pairs and return average loss.
      def train_batch(batch_inputs, batch_outputs)
        raise ArgumentError, "Inputs and outputs size mismatch" if batch_inputs.length != batch_outputs.length
        sum_error = 0.0
        batch_inputs.each_index do |i|
          sum_error += train(batch_inputs[i], batch_outputs[i])
        end
        sum_error / batch_inputs.length.to_f
      end

      # Train for a number of epochs over the dataset. Optionally define a batch size.
      # Data can be shuffled between epochs passing +shuffle: true+ (default).
      # Use +random_seed+ to make shuffling deterministic.
      # Returns an array with the average loss of each epoch.
      def train_epochs(data_inputs, data_outputs, epochs:, batch_size: 1,
                       early_stopping_patience: nil, min_delta: 0.0,
                       shuffle: true, random_seed: nil)
        raise ArgumentError, "Inputs and outputs size mismatch" if data_inputs.length != data_outputs.length
        losses = []
        best_loss = Float::INFINITY
        patience = early_stopping_patience
        patience_counter = 0
        rng = random_seed.nil? ? Random.new : Random.new(random_seed)
        epochs.times do
          epoch_error = 0.0
          epoch_inputs = data_inputs
          epoch_outputs = data_outputs
          if shuffle
            indices = (0...data_inputs.length).to_a.shuffle(random: rng)
            epoch_inputs = data_inputs.values_at(*indices)
            epoch_outputs = data_outputs.values_at(*indices)
          end
          index = 0
          while index < epoch_inputs.length
            batch_in = epoch_inputs[index, batch_size]
            batch_out = epoch_outputs[index, batch_size]
            batch_error = train_batch(batch_in, batch_out)
            epoch_error += batch_error * batch_in.length
            index += batch_size
          end
          epoch_loss = epoch_error / data_inputs.length.to_f
          losses << epoch_loss
          if block
            if block.arity >= 3
              correct = 0
              data_inputs.each_index do |i|
                output = eval(data_inputs[i])
                predicted = output.index(output.max)
                expected = data_outputs[i].index(data_outputs[i].max)
                correct += 1 if predicted == expected
              end
              accuracy = correct.to_f / data_inputs.length
              block.call(epoch, epoch_loss, accuracy)
            else
              block.call(epoch, epoch_loss)
            end
          end
          if patience
            if best_loss - epoch_loss > min_delta
              best_loss = epoch_loss
              patience_counter = 0
            else
              patience_counter += 1
              break if patience_counter >= patience
            end
          end
        end
        losses
      end
      
      # Initialize (or reset) activation nodes and weights, with the 
      # provided net structure and parameters.
      def init_network
        init_activation_nodes
        init_weights
        init_last_changes
        return self
      end

      protected

      # Custom serialization. It used to fail trying to serialize because
      # it uses lambda functions internally, and they cannot be serialized.
      # Now it does not fail, but if you customize the values of
      # * initial_weight_function
      # * propagation_function
      # * derivative_propagation_function
      # you must restore their values manually after loading the instance.
      def marshal_dump
        [
          @structure,
          @disable_bias,
          @learning_rate,
          @momentum,
          @weights,
          @last_changes,
          @activation_nodes,
          @activation
        ]
      end

      def marshal_load(ary)
        @structure,
           @disable_bias,
           @learning_rate,
           @momentum,
           @weights,
           @last_changes,
           @activation_nodes,
           @activation = ary
        self.weight_init = :uniform
        self.activation = @activation || :sigmoid
      end


      # Propagate error backwards
      def backpropagate(expected_output_values)
        check_output_dimension(expected_output_values.length)
        calculate_output_deltas(expected_output_values)
        calculate_internal_deltas
        update_weights
      end
      
      # Propagate values forward
      def feedforward(input_values)
        input_values.each_index do |input_index|
          @activation_nodes.first[input_index] = input_values[input_index]
        end
        @weights.each_index do |n|
          sums = Array.new(@structure[n + 1], 0.0)
          @structure[n + 1].times do |j|
            @activation_nodes[n].each_index do |i|
              sums[j] += (@activation_nodes[n][i] * @weights[n][i][j])
            end
          end
          if @activation[n] == :softmax
            values = @propagation_functions[n].call(sums)
            values.each_index { |j| @activation_nodes[n + 1][j] = values[j] }
          else
            sums.each_index do |j|
              @activation_nodes[n + 1][j] = @propagation_functions[n].call(sums[j])
            end
          end
        end
      end
      
      # Initialize neurons structure.
      def init_activation_nodes
        @activation_nodes = Array.new(@structure.length) do |n| 
          Array.new(@structure[n], 1.0)
        end
        if not disable_bias
          @activation_nodes[0...-1].each {|layer| layer << 1.0 }
        end
      end
      
      # Initialize the weight arrays using function specified with the
      # initial_weight_function parameter
      def init_weights
        @weights = Array.new(@structure.length-1) do |i|
          nodes_origin = @activation_nodes[i].length
          nodes_target = @structure[i+1]
          Array.new(nodes_origin) do |j|
            Array.new(nodes_target) do |k| 
              @initial_weight_function.call(i, j, k)
            end
          end
        end
      end   

      # Momentum usage need to know how much a weight changed in the 
      # previous training. This method initialize the @last_changes 
      # structure with 0 values.
      def init_last_changes
        @last_changes = Array.new(@weights.length) do |w|
          Array.new(@weights[w].length) do |i| 
            Array.new(@weights[w][i].length, 0.0)
          end
        end
      end
      
      # Calculate deltas for output layer
      def calculate_output_deltas(expected_values)
        output_values = @activation_nodes.last
        output_deltas = []
        func = @derivative_functions.last
        output_values.each_index do |output_index|
          if @loss_function == :cross_entropy && @activation == :softmax
            output_deltas << (output_values[output_index] - expected_values[output_index])
          else
            error = expected_values[output_index] - output_values[output_index]
            output_deltas << @derivative_propagation_function.call(
              output_values[output_index]) * error
          end
        end
        @deltas = [output_deltas]
      end
      
      # Calculate deltas for hidden layers
      def calculate_internal_deltas
        prev_deltas = @deltas.last
        (@activation_nodes.length-2).downto(1) do |layer_index|
          layer_deltas = []
          @activation_nodes[layer_index].each_index do |j|
            error = 0.0
            @structure[layer_index+1].times do |k|
              error += prev_deltas[k] * @weights[layer_index][j][k]
            end
            func = @derivative_functions[layer_index - 1]
            layer_deltas[j] = func.call(@activation_nodes[layer_index][j]) * error
          end
          prev_deltas = layer_deltas
          @deltas.unshift(layer_deltas)
        end
      end
      
      # Update weights after @deltas have been calculated.
      def update_weights
        (@weights.length-1).downto(0) do |n|
          @weights[n].each_index do |i|  
            @weights[n][i].each_index do |j|  
              change = @deltas[n][j]*@activation_nodes[n][i]
              @weights[n][i][j] += ( learning_rate * change + 
                  momentum * @last_changes[n][i][j])
              @last_changes[n][i][j] = change
            end
          end
        end
      end
      
      # Calculate quadratic error for an expected output value
      # Error = 0.5 * sum( (expected_value[i] - output_value[i])**2 )
      def calculate_error(expected_output)
        output_values = @activation_nodes.last
        error = 0.0
        expected_output.each_index do |output_index|
          error +=
            0.5*(output_values[output_index]-expected_output[output_index])**2
        end
        return error
      end

      # Calculate loss for expected/actual vectors according to selected
      # loss_function (:mse or :cross_entropy).
      def calculate_loss(expected, actual)
        case @loss_function
        when :cross_entropy
          epsilon = 1e-12
          loss = 0.0
          if @activation == :softmax
            expected.each_index do |i|
              p = [[actual[i], epsilon].max, 1 - epsilon].min
              loss -= expected[i] * Math.log(p)
            end
          else
            expected.each_index do |i|
              p = [[actual[i], epsilon].max, 1 - epsilon].min
              loss -= expected[i] * Math.log(p) + (1 - expected[i]) * Math.log(1 - p)
            end
          end
          loss
        else
          # Mean squared error
          error = 0.0
          expected.each_index do |i|
            error += 0.5 * (expected[i] - actual[i])**2
          end
          error
        end
      end
      
      def check_input_dimension(inputs)
        raise ArgumentError, "Wrong number of inputs. " +
          "Expected: #{@structure.first}, " +
          "received: #{inputs}." if inputs!=@structure.first
      end

      def check_output_dimension(outputs)
        raise ArgumentError, "Wrong number of outputs. " +
          "Expected: #{@structure.last}, " +
          "received: #{outputs}." if outputs!=@structure.last
      end
      
    end
  end
end
