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
require_relative '../classifiers/classifier'
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
                                           "repeated. By default: #{TRAINING_ITERATIONS}",
                      active_node_value: 'Default: 1',
                      inactive_node_value: 'Default: 0'

      # @return [Object]
      def initialize
        @network_class = Ai4r::NeuralNetwork::Backpropagation
        @hidden_layers = []
        @training_iterations = TRAINING_ITERATIONS
        @network_parameters = {}
        @active_node_value = 1
        @inactive_node_value = 0
      end

      # Build a new MultilayerPerceptron classifier. You must provide a DataSet
      # instance as parameter. The last attribute of each item is considered as
      # the item class.
      # @param data_set [Object]
      # @return [Object]
      def build(data_set)
        data_set.check_not_empty
        @data_set = data_set
        @domains = @data_set.build_domains.collect(&:to_a)
        @outputs = @domains.last.length
        @inputs = 0
        @domains[0...-1].each { |domain| @inputs += domain.length }
        @structure = [@inputs] + @hidden_layers + [@outputs]
        @network = @network_class.new @structure
        inputs = []
        outputs = []
        data_set.data_items.each do |data_item|
          inputs << data_to_input(data_item[0...-1])
          outputs << data_to_output(data_item.last)
        end
        @network.train_epochs(inputs, outputs,
                              epochs: @training_iterations, batch_size: 1)
        self
      end

      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      # @param data [Object]
      # @return [Object]
      def eval(data)
        input_values = data_to_input(data)
        output_values = @network.eval(input_values)
        @domains.last[get_max_index(output_values)]
      end

      # Multilayer Perceptron Classifiers cannot generate
      # human-readable rules.
      # @return [Object]
      def get_rules
        "raise 'Neural networks classifiers do not generate human-readable rules.'"
      end

      protected

      # @param data_item [Object]
      # @return [Object]
      def data_to_input(data_item)
        input_values = Array.new(@inputs, @inactive_node_value)
        accum_index = 0
        data_item.each_index do |att_index|
          att_value = data_item[att_index]
          domain_index = @domains[att_index].index(att_value)
          input_values[domain_index + accum_index] = @active_node_value
          accum_index += @domains[att_index].length
        end
        input_values
      end

      # @param data_item [Object]
      # @return [Object]
      def data_to_output(data_item)
        output_values = Array.new(@outputs, @inactive_node_value)
        output_values[@domains.last.index(data_item)] = @active_node_value
        output_values
      end

      # @param output_values [Object]
      # @return [Object]
      def get_max_index(output_values)
        max_value = @inactive_node_value
        max_index = 0
        output_values.each_index do |output_index|
          if max_value < output_values[output_index]
            max_value = output_values[output_index]
            max_index = output_index
          end
        end
        max_index
      end
    end
  end
end
