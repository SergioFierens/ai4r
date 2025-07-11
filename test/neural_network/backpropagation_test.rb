#
# neural_network_test.rb
#
# This is a unit test file for the backpropagation neural network implemented
# in ai4r
#
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
#


require 'ai4r/neural_network/backpropagation'
require 'test/unit'
require_relative '../test_helper.rb'

Ai4r::NeuralNetwork::Backpropagation.send(:public, *Ai4r::NeuralNetwork::Backpropagation.protected_instance_methods)
Ai4r::NeuralNetwork::Backpropagation.send(:public, *Ai4r::NeuralNetwork::Backpropagation.private_instance_methods)

module Ai4r

  module NeuralNetwork


    class BackpropagationTest < Test::Unit::TestCase


      def test_init_network
        net_4_2 = Backpropagation.new([4, 2]).init_network
        assert_equal [[1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0]],
          net_4_2.activation_nodes
        assert_equal 1, net_4_2.weights.size
        assert_equal 5, net_4_2.weights.first.size
        net_4_2.weights.first.each do |weights_n|
          assert_equal 2, weights_n.size
        end

        net_2_2_1 = Backpropagation.new([2, 2, 1]).init_network
        assert_equal [[1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0]],
          net_2_2_1.activation_nodes
        assert_equal 2, net_2_2_1.weights.size
        assert_equal 3, net_2_2_1.weights.first.size

        net_2_2_1.disable_bias = true
        net_2_2_1_no_bias = net_2_2_1.init_network
        assert_equal [[1.0, 1.0], [1.0, 1.0], [1.0]],
          net_2_2_1_no_bias.activation_nodes
      end

      def test_eval
        #Test set 1
        net = Backpropagation.new([3, 2])
        y = net.eval([3, 2, 3])
        assert y.length == 2
        #Test set 2
        net = Backpropagation.new([2, 4, 8, 10, 7])
        y = net.eval([2, 3])
        assert y.length == 7
      end

      def test_dump
        net = Backpropagation.new([3, 2]).init_network
        s = Marshal.dump(net)
        x = Marshal.load(s)
        assert_equality_of_nested_list net.structure, x.structure
        assert_equal net.disable_bias, x.disable_bias
        assert_approximate_equality net.learning_rate, x.learning_rate
        assert_approximate_equality net.momentum, x.momentum
        assert_approximate_equality_of_nested_list net.weights, x.weights
        assert_approximate_equality_of_nested_list net.last_changes, x.last_changes
        assert_approximate_equality_of_nested_list net.activation_nodes, x.activation_nodes
      end
      def test_activation_parameter
        net = Backpropagation.new([2, 1], :tanh)
        assert_equal :tanh, net.activation
        assert_in_delta Math.tanh(0.5), net.instance_variable_get(:@propagation_function).call(0.5), 0.0001
        net.set_parameters(activation: :relu)
        assert_equal :relu, net.activation
        assert_equal 0.0, net.instance_variable_get(:@derivative_propagation_function).call(-1.0)
      end

      def test_weight_init_parameter
        net = Backpropagation.new([2, 2, 1], :sigmoid, :xavier).init_network
        limit = Math.sqrt(6.0 / (2 + 2))
        net.weights.first.flatten.each { |w| assert w.abs <= limit }

        net.set_parameters(weight_init: :he)
        net.init_network
        limit = Math.sqrt(6.0 / 2)
        net.weights.first.flatten.each { |w| assert w.abs <= limit }
      end

      def test_loss_function_and_train_return
        net = Backpropagation.new([1, 1])
        assert_in_delta 0.125, net.calculate_loss([0], [0.5]), 0.0001
        net.loss_function = :cross_entropy
        assert_in_delta 0.6931, net.calculate_loss([1], [0.5]), 0.0001

        net = Backpropagation.new([2, 1])
        net.set_parameters(loss_function: :cross_entropy)
        loss = net.train([0, 0], [0])
        assert_in_delta net.calculate_loss([0], net.activation_nodes.last), loss, 0.0000001
        net.set_parameters(loss_function: :mse)
        loss = net.train([1, 1], [1])
        assert_in_delta net.calculate_loss([1], net.activation_nodes.last), loss, 0.0000001
      end


    end

  end

end
