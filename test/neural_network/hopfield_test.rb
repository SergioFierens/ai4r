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

    end
  end
end
