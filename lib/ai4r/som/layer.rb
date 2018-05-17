# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/parameterizable'

module Ai4r

  module Som

    # responsible for the implementation of the algorithm's decays
    # currently has methods for the decay of the radius, influence and learning rate.
    # Has only one phase, which ends after the number of epochs is passed by the Som-class.
    #
    # = Parameters
    # * nodes => number of nodes in the SOM (nodes x nodes). Has to be the same number
    # you pass to the SOM. Has to be an integer
    # * radius => the initial radius for the neighborhood
    # * epochs => number of epochs the algorithm runs, has to be an integer. By default it is set to 100
    # * learning_rate => sets the initial learning rate
    class Layer

      include Ai4r::Data::Parameterizable

      parameters_info :nodes => "number of nodes, has to be equal to the som",
                      :epochs => "number of epochs the algorithm has to run",
                      :radius => "sets the initial neighborhoud radius"

      def initialize(nodes, radius, epochs = 100, learning_rate = 0.7)
        raise("Too few nodes") if nodes < 3
        
        @nodes = nodes
        @epochs = epochs
        @radius = radius
        @time_for_epoch = @epochs / Math.log(nodes / 4.0)
        @time_for_epoch = @epochs + 1.0 if @time_for_epoch < @epochs

        @initial_learning_rate = learning_rate
      end

      # calculates the influnce decay for a certain distance and the current radius
      # of the epoch
      def influence_decay(distance, radius)
        Math.exp(- (distance.to_f**2 / 2.0 / radius.to_f**2))
      end

      # calculates the radius decay for the current epoch. Uses @time_for_epoch
      # which has to be higher than the number  of epochs, otherwise the decay will be - Infinity
      def radius_decay(epoch)
        (@radius * ( 1 - epoch/ @time_for_epoch)).round
      end

      # calculates the learning rate decay. uses @time_for_epoch again and same rule applies:
      # @time_for_epoch has to be higher than the number  of epochs, otherwise the decay will be - Infinity
      def learning_rate_decay(epoch)
        @initial_learning_rate * ( 1 - epoch / @time_for_epoch)
      end

    end

  end

end
