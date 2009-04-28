# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/parameterizable' 

 module Ai4r
   
  module NeuralNetwork
    
    class Hopfield
      
      include Ai4r::Data::Parameterizable
      
      attr_reader :weights, :nodes
      
      parameters_info :eval_iterations => "The network will run for a maximum "+
        "of 'eval_iterations' iterations while evaluating an input. 500 by " +
        "default.",
        :active_node_value => "Default: 1",
        :inactive_node_value => "Default: 0",
        :threshold => "Default: 0.5"
            
      def initialize
        @eval_iterations = 500
        @active_node_value = 1
        @inactive_node_value = 0
        @threshold = 0.5
      end
      
      def train(data_set)
        @data_set = data_set
        initialize_nodes(@data_set)
        initialize_weights(@data_set)
      end
      
      def run(input)
        set_input(input)
        propagate
        return @nodes
      end

      def eval(input)
        set_input(input)
        @eval_iterations.times do
          propagate  
          break if @data_set.data_items.include?(@nodes)
        end
        return @nodes
      end
      
      protected 
      def set_input(inputs)
        raise ArgumentError unless inputs.length == @nodes.length
        inputs.each_with_index { |input, i| @nodes[i] = input}
      end
      
      def propagate
        sum = 0
        i = (rand * @nodes.length).floor
        @nodes.each_with_index {|node, j| sum += read_weight(i,j)*node }
        @nodes[i] = (sum > @threshold) ? @active_node_value : @inactive_node_value
      end
            
      def initialize_nodes(data_set)
        @nodes = Array.new(data_set.data_items.first.length, 
          @inactive_node_value)
      end
      
      def initialize_weights(data_set)
        @weights = Array.new(data_set.data_items.length-1) {|l| Array.new(l+1)}
        data_set.data_items.each_with_index do |a, i|
          i.times do |j|
            b = data_set.data_items[j]
            w = 0
            @nodes.times {|n| w += a[n]*b[n]}
            @weights[i-1][j] = w
          end
        end
      end
      
      def read_weight(index_a, index_b)
        return 0 if index_a == index_b
        index_a, index_b = index_b, index_a if index_b > index_a
        return @weights[index_a-1][index_b]
      end
      
    end
    
  end
  
end
