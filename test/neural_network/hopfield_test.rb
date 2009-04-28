# This is a unit test file for the hopfield neural network AI4r implementation
# 
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../../lib/ai4r'
require 'test/unit'

Ai4r::NeuralNetwork::Hopfield.send(:public, *Ai4r::NeuralNetwork::Hopfield.protected_instance_methods)  

module Ai4r
  
  module NeuralNetwork


    class HopfieldTest < Test::Unit::TestCase
      
      def test_initialize_nodes
        net = Hopfield.new
        data_set = Ai4r::Data::DataSet.new :data_items => [[1,1,0,0,1,1,0,0]]
        assert_equal [0,0,0,0,0,0,0,0], net.initialize_nodes(data_set)
        net.inactive_node_value = -1
        assert_equal [-1,-1,-1,-1,-1,-1,-1,-1], net.initialize_nodes(data_set)
      end
      
      def test_initialize_weights
        #TODO
      end

    end

  end

end