# frozen_string_literal: true

# Author::    Sergio Fierens (Implementation only)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require_relative '../data/data_set'
require_relative 'classifier'
require_relative '../neural_network/backpropagation'

module Ai4r
  module Classifiers
    # = Introduction
    #
    # The idea behind the MultilayerPerceptron classifier is to
    # train a Multilayer Perceptron neural network with the provided examples,
    # and predict the class for new data items.
    #
    # = Parameters
    #
    # Use class method get_parameters_info to obtain details on the algorithm
    # parameters. Use set_parameters to set values for this parameters.
    # See Parameterizable module documentation.
    #
    # * :network_class => Neural network implementation class.
    #   By default: Ai4r::NeuralNetwork::Backpropagation.
    # * :network_parameters => Parameters to be forwarded to the back end
    #   neural ntework.
    # * :hidden_layers => Hidden layer structure. E.g. [8, 6] will generate
    #   2 hidden layers with 8 and 6 neurons each. By default []
    # * :training_iterations => How many times the training should be repeated.
    #   By default: 500.
    # :active_node_value => Default: 1
    # :inactive_node_value => Default: 1
    class MultilayerPerceptron < Classifier
      attr_reader :data_set, :class_value, :network, :domains

      TRAINING_ITERATIONS = 500

      parameters_info network_class: 'Neural network implementation class.' \
                                     'By default: Ai4r::NeuralNetwork::Backpropagation.',
                      network_parameters: 'parameters to be forwarded to the back end ' \
                                          'neural network.',
                      hidden_layers: 'Hidden layer structure. E.g. [8, 6] will generate ' \
                                     '2 hidden layers with 8 and 6 neurons each. By default []',
                      training_iterations: 'How many times the training should be ' \
                                           'repeated. By default: ' + TRAINING_ITERATIONS.to_s,
                      active_node_value: 'Default: 1',
                      inactive_node_value: 'Default: 0',
                      error_threshold: 'Optional early stopping error threshold'

      def initialize
        super
        @network_class = Ai4r::NeuralNetwork::Backpropagation
        @hidden_layers = []
        @training_iterations = TRAINING_ITERATIONS
        @network_parameters = {}
        @active_node_value = 1
        @inactive_node_value = 0
        @error_threshold = nil
      end

      def set_parameters(params)
        # Handle learning_rate as direct parameter or in network_parameters
        if params[:learning_rate]
          params[:network_parameters] ||= {}
          params[:network_parameters][:learning_rate] = params[:learning_rate]
          params.delete(:learning_rate)
        end
        
        super
        
        # Validate parameters
        if @hidden_layers && @hidden_layers.any? { |size| size <= 0 }
          raise ArgumentError, 'All hidden layer sizes must be positive'
        end
        if @network_parameters[:learning_rate] && @network_parameters[:learning_rate] <= 0
          raise ArgumentError, 'learning rate must be positive'
        end
        if @training_iterations && @training_iterations <= 0
          raise ArgumentError, 'max_epochs must be positive'
        end
      end

      # Build a new MultilayerPerceptron classifier. You must provide a DataSet
      # instance as parameter. The last attribute of each item is considered as
      # the item class.
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @domains = @data_set.build_domains
        
        # For the output (last attribute), convert to array if it's a Set
        @outputs = @domains.last.is_a?(Set) ? @domains.last.to_a.length : 1
        
        # Calculate input size
        @inputs = 0
        @domains[0...-1].each do |domain|
          if domain.is_a?(Set)
            @inputs += domain.size  # Categorical: one input per category
          else
            @inputs += 1  # Numeric: single normalized input
          end
        end
        
        @structure = [@inputs] + @hidden_layers + [@outputs]
        @network = @network_class.new @structure
        
        # Set network parameters if provided
        if @network_parameters && !@network_parameters.empty?
          @network_parameters.each do |param, value|
            if @network.respond_to?("#{param}=")
              @network.send("#{param}=", value)
            elsif @network.instance_variable_defined?("@#{param}")
              @network.instance_variable_set("@#{param}", value)
            end
          end
        end
        
        # Training with optional early stopping
        @training_iterations.times do |epoch|
          total_error = 0.0
          data_set.data_items.each do |data_item|
            input_values = data_to_input(data_item[0...-1])
            output_values = data_to_output(data_item.last)
            @network.train(input_values, output_values)
            
            # Calculate error if threshold is set
            if @error_threshold
              predicted = @network.eval(input_values)
              error = 0.0
              predicted.each_index do |i|
                error += (predicted[i] - output_values[i]) ** 2
              end
              total_error += error
            end
          end
          
          # Early stopping check
          if @error_threshold && (total_error / data_set.data_items.length) < @error_threshold
            break
          end
        end
        return self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      def eval(data)
        input_values = data_to_input(data)
        output_values = @network.eval(input_values)
        
        domain = @domains.last
        if domain.is_a?(Set)
          # Categorical output: return class with highest activation
          domain_array = domain.to_a
          return domain_array[get_max_index(output_values)]
        else
          # Numeric output: denormalize
          min_val, max_val = domain
          if max_val == min_val
            return min_val
          else
            return output_values[0] * (max_val - min_val) + min_val
          end
        end
      end

      # Multilayer Perceptron Classifiers cannot generate
      # human-readable rules.
      def get_rules
        return "raise 'Neural networks classifiers do not generate human-readable rules.'"
      end

      protected

      def data_to_input(data_item)
        input_values = []
        
        data_item.each_index do |att_index|
          att_value = data_item[att_index]
          domain = @domains[att_index]
          
          if domain.is_a?(Set)
            # Categorical attribute: one-hot encoding
            domain_array = domain.to_a
            domain_index = domain_array.index(att_value)
            raise ArgumentError, "Unknown attribute value '#{att_value}' for attribute #{att_index}" if domain_index.nil?
            
            # Create one-hot vector
            domain_array.each_index do |i|
              input_values << (i == domain_index ? @active_node_value : @inactive_node_value)
            end
          else
            # Numeric attribute: normalize to [0, 1]
            min_val, max_val = domain
            if max_val == min_val
              input_values << 0.5  # If all values are the same, use middle value
            else
              normalized = (att_value.to_f - min_val) / (max_val - min_val)
              input_values << normalized
            end
          end
        end
        
        return input_values
      end

      def data_to_output(data_item)
        domain = @domains.last
        
        if domain.is_a?(Set)
          # Categorical output: one-hot encoding
          output_values = Array.new(@outputs, @inactive_node_value)
          domain_array = domain.to_a
          class_index = domain_array.index(data_item)
          raise ArgumentError, "Unknown class value '#{data_item}'" if class_index.nil?
          output_values[class_index] = @active_node_value
          return output_values
        else
          # Numeric output: normalize
          min_val, max_val = domain
          if max_val == min_val
            return [0.5]
          else
            normalized = (data_item.to_f - min_val) / (max_val - min_val)
            return [normalized]
          end
        end
      end

      def get_max_index(output_values)
        max_value = @inactive_node_value
        max_index = 0
        output_values.each_index do |output_index|
          if max_value < output_values[output_index]
            max_value = output_values[output_index]
            max_index = output_index
          end
        end
        return max_index
      end
    end
  end
end
