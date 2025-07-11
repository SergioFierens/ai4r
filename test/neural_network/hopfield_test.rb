# This is a unit test file for the hopfield neural network AI4r implementation
# 
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r'
require 'test/unit'

Ai4r::NeuralNetwork::Hopfield.send(:public, *Ai4r::NeuralNetwork::Hopfield.protected_instance_methods)  

module Ai4r
  
  module NeuralNetwork


    class HopfieldTest < Test::Unit::TestCase
      
      def setup
        @data_set = Ai4r::Data::DataSet.new :data_items => [
          [1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1],
          [-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1],
          [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,1],
          [1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1],
          ]
      end
      
      def test_initialize_nodes
        net = Hopfield.new
        data_set = Ai4r::Data::DataSet.new :data_items => [[1,1,0,0,1,1,0,0]]
        assert_equal [-1,-1,-1,-1,-1,-1,-1,-1], net.initialize_nodes(data_set)
      end
      
      def test_initialize_weights
        net = Hopfield.new
        net.initialize_nodes @data_set
        net.initialize_weights(@data_set)
        assert_equal 15, net.weights.length
        net.weights.each_with_index {|w_row, i| assert_equal i+1, w_row.length}
        assert_in_delta 1.0, net.read_weight(1,0), 0.00001
      end
      
      def test_run
        net = Hopfield.new
        net.train @data_set
        pattern = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
        100.times do
          pattern = net.run(pattern)
        end
        assert_equal [1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1], pattern
      end

      def test_run_async_sequential
        net = Hopfield.new
        net.update_strategy = :async_sequential
        net.train @data_set
        pattern = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
        100.times do
          pattern = net.run(pattern)
        end
        assert_equal [1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1], pattern
      end

      def test_run_synchronous
        net = Hopfield.new
        net.update_strategy = :synchronous
        net.train @data_set
        pattern = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
        100.times do
          pattern = net.run(pattern)
        end
        assert_equal [1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,1,1,-1,-1], pattern
      end
      
      def test_eval
        net = Hopfield.new
        net.train @data_set
        p = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
        assert_equal @data_set.data_items[0], net.eval(p)
        p = [-1,-1,1,1,1,-1,1,1,-1,-1,1,-1,-1,-1,1,1]
        assert_equal @data_set.data_items[1], net.eval(p)
        p = [-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1]
        assert_equal @data_set.data_items[2], net.eval(p)
        p = [-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,1,-1,-1,-1]
        assert_equal @data_set.data_items[3], net.eval(p)
      end

      def test_energy
        net = Hopfield.new
        data_set = Ai4r::Data::DataSet.new :data_items => [[1,-1]]
        net.train data_set
        net.set_input([1,-1])
        assert_equal(-1.0, net.energy)
      end

      def test_eval_trace
        net = Hopfield.new
        net.eval_iterations = 10
        net.train @data_set
        pattern = [1,1,-1,1,1,1,-1,-1,1,1,-1,-1,1,1,1,-1]
        trace = net.eval(pattern, trace: true)
        assert_kind_of Hash, trace
        assert_kind_of Array, trace[:states]
        assert_kind_of Array, trace[:energies]
        assert_equal trace[:states].length, trace[:energies].length
        assert_equal @data_set.data_items[0], trace[:states].last
      end

      class CountingHopfield < Hopfield
        attr_reader :propagate_count
        def propagate
          @propagate_count ||= 0
          @propagate_count += 1
          super
        end
      end

      def test_eval_convergence_break
        data_set = Ai4r::Data::DataSet.new :data_items => [[1,-1]]
        net = CountingHopfield.new
        net.eval_iterations = 5
        net.stop_when_stable = true
        net.train data_set
        assert_equal [-1,1], net.eval([-1,1])
        assert_operator net.propagate_count, :<, 5

        net2 = CountingHopfield.new
        net2.eval_iterations = 5
        net2.stop_when_stable = false
        net2.train data_set
        assert_equal [-1,1], net2.eval([-1,1])
        assert_equal 5, net2.propagate_count
      end

      def test_train_validates_values
        net = Hopfield.new
        invalid = Ai4r::Data::DataSet.new :data_items => [[1, 0, -1]]
        assert_raise(ArgumentError) { net.train(invalid) }

        net.active_node_value = 1
        net.inactive_node_value = 0
        valid = Ai4r::Data::DataSet.new :data_items => [[1,0,1,0]]
        net.train(valid)
        invalid2 = Ai4r::Data::DataSet.new :data_items => [[1,2,0]]
        assert_raise(ArgumentError) { net.train(invalid2) }
      end

    end
  end
end
