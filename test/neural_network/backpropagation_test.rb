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
require 'minitest/autorun'
require 'rspec/autorun'
require 'rspec/parameterized'
require_relative '../test_helper.rb'



module Ai4r

  module NeuralNetwork


    class BackpropagationTest < Minitest::Test



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
        assert_equal [:tanh], net.activation
        assert_in_delta Math.tanh(0.5), net.instance_variable_get(:@propagation_functions).first.call(0.5), 0.0001
        net.set_parameters(activation: :relu)
        assert_equal [:relu], net.activation
        assert_equal 0.0, net.instance_variable_get(:@derivative_functions).first.call(-1.0)
      end

      def test_layer_specific_activation
        net = Backpropagation.new([2, 2, 2], [:relu, :softmax])
        net.disable_bias = true
        net.init_network
        net.weights = [
          [[1.0, -1.0], [1.0, -1.0]],
          [[1.0, 0.0], [0.0, 1.0]]
        ]
        net.send(:feedforward, [1, 1])
        assert_equal [2.0, 0.0], net.activation_nodes[1]
        exp2 = Math.exp(2)
        soft = [exp2 / (exp2 + 1), 1.0 / (exp2 + 1)]
        assert_in_delta soft[0], net.activation_nodes.last[0], 0.000001
        assert_in_delta soft[1], net.activation_nodes.last[1], 0.000001
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
        assert_in_delta 0.125, net.send(:calculate_loss, [0], [0.5]), 0.0001
        net.loss_function = :cross_entropy
        assert_in_delta 0.6931, net.send(:calculate_loss, [1], [0.5]), 0.0001

        net = Backpropagation.new([2, 1])
        net.set_parameters(loss_function: :cross_entropy)
        loss = net.train([0, 0], [0])
        assert_in_delta net.send(:calculate_loss, [0], net.activation_nodes.last), loss, 0.0000001
        net.set_parameters(loss_function: :mse)
        loss = net.train([1, 1], [1])
        assert_in_delta net.send(:calculate_loss, [1], net.activation_nodes.last), loss, 0.0000001
      end

      def test_cross_entropy_auto_softmax
        net = Backpropagation.new([2, 2])
        net.set_parameters(loss_function: :cross_entropy)
        assert_equal :softmax, net.activation
        net2 = Backpropagation.new([2, 2], :tanh)
        net2.set_parameters(loss_function: :cross_entropy)
        assert_equal :tanh, net2.activation
      end

      def test_softmax_output_probabilities
        net = Backpropagation.new([2, 2])
        net.set_parameters(loss_function: :cross_entropy)
        net.train([0, 0], [1, 0])
        output = net.eval([0, 0])
        sum = output.inject(0.0) { |a, v| a + v }
        assert_in_delta 1.0, sum, 0.0001
      end

      def test_train_epochs_with_early_stopping
        net = Backpropagation.new([1, 1])
        # Mock train_batch to return predefined losses
        losses = [0.5, 0.4, 0.41, 0.42]
        net.define_singleton_method(:train_batch) do |_, _|
          losses.shift
        end
        history = net.train_epochs([[0]], [[0]], epochs: 10, early_stopping_patience: 1)
        assert_equal 3, history.length
        assert history[0] > history[1]
      end

      def test_train_batch_differs_from_sequential_training
        data_in = [[0, 0], [1, 1]]
        data_out = [[0], [1]]
        seq_net = Backpropagation.new([2, 1]).init_network
        batch_net = Marshal.load(Marshal.dump(seq_net))

        seq_net.train(data_in[0], data_out[0])
        seq_net.train(data_in[1], data_out[1])

        batch_net.train_batch(data_in, data_out)

        diff_found = false
        seq_net.weights.each_index do |n|
          seq_net.weights[n].each_index do |i|
            seq_net.weights[n][i].each_index do |j|
              if (seq_net.weights[n][i][j] - batch_net.weights[n][i][j]).abs > 1e-6
                diff_found = true
                break
              end
            end
          end
        end
        assert diff_found, "Batch training should update weights differently"
      end


      def test_train_epochs_yields_epoch_and_loss
        net = Backpropagation.new([1, 1])
        losses = [0.2, 0.1]
        net.define_singleton_method(:train_batch) do |_, _|
          losses.shift
        end
        net.define_singleton_method(:eval) do |_|
          [0]
        end
        yielded = []
        net.train_epochs([[0]], [[0]], epochs: 2) do |epoch, loss, acc|
          yielded << [epoch, loss, acc]
        end
        assert_equal [[0, 0.2, 1.0], [1, 0.1, 1.0]], yielded
      end

      def test_train_epochs_shuffling
        net = Backpropagation.new([1, 1])
        order = []
        net.define_singleton_method(:train_batch) do |batch_in, _|
          order << batch_in.first.first
          0.0
        end
        inputs = [[0], [1], [2], [3]]
        outputs = [[0], [1], [2], [3]]
        net.train_epochs(inputs, outputs, epochs: 1, batch_size: 1, shuffle: false)
        assert_equal [0, 1, 2, 3], order

        order.clear
        seed = 42
        net.train_epochs(inputs, outputs, epochs: 1, batch_size: 1,
                         shuffle: true, random_seed: seed)
        expected = (0...4).to_a.shuffle(random: Random.new(seed))
        assert_equal expected, order
      end

      def test_train_epochs_shuffling_reproducible
        inputs = [[0], [1], [2], [3]]
        outputs = [[0], [1], [2], [3]]
        seed = 99

        order1 = []
        net1 = Backpropagation.new([1, 1])
        net1.define_singleton_method(:train_batch) do |batch_in, _|
          order1 << batch_in.first.first
          0.0
        end
        net1.train_epochs(inputs, outputs, epochs: 1, batch_size: 1,
                          shuffle: true, random_seed: seed)

        order2 = []
        net2 = Backpropagation.new([1, 1])
        net2.define_singleton_method(:train_batch) do |batch_in, _|
          order2 << batch_in.first.first
          0.0
        end
        net2.train_epochs(inputs, outputs, epochs: 1, batch_size: 1,
                          shuffle: true, random_seed: seed)

        assert_equal order1, order2
      end


    end

  end

end

RSpec.describe Ai4r::NeuralNetwork::Backpropagation do
  include RSpec::Parameterized::TableSyntax

  where(:structure, :expected_nodes, :disable_bias) do
    [
      [[4, 2], [[1.0, 1.0, 1.0, 1.0, 1.0], [1.0, 1.0]], false],
      [[2, 2, 1], [[1.0, 1.0, 1.0], [1.0, 1.0, 1.0], [1.0]], false],
      [[2, 2, 1], [[1.0, 1.0], [1.0, 1.0], [1.0]], true]
    ]
  end

  with_them do
    it 'initializes networks with given structure' do
      net = described_class.new(structure)
      net.disable_bias = true if disable_bias
      net.init_network
      expect(net.activation_nodes).to eq(expected_nodes)
    end
  end
end
