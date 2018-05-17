# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'

module Ai4r

  module Som

    # responsible for the implementation of the algorithm's decays, extends the class Layer.
    # currently overrides the radius and learning rate decay methods of Layer.
    # Has two phases, phase one has a decay in both the learning rate and the radius. The number
    # of epochs for both phases can be passed and the total number of epochs is the sum of epoch
    # for phase one and phase two.
    # In the scond phase, the learning and radius decay is steady, normally set to a small number (ie. 0.01)
    #
    # = Parameters
    # * nodes => number of nodes in the SOM (nodes x nodes). Has to be the same number
    # you pass to the SOM. Has to be an integer
    # * radius => the initial radius for the neighborhood
    # * phase_one => number of epochs for phase one, has to be an integer. By default it is set to 150
    # * phase_two => number of epochs for phase two, has to be an integer. By default it is set to 100
    # * learning_rate => sets the initial learning rate
    # * phase_one_learning_rate  => sets the learning rate for phase one
    # * phase_two_learning_rate  => sets the learning rate for phase two

    class TwoPhaseLayer < Layer

      def initialize(nodes, learning_rate = 0.9, phase_one = 150, phase_two = 100,
              phase_one_learning_rate = 0.1, phase_two_learning_rate = 0)
        super nodes, nodes, phase_one + phase_two, learning_rate
        @phase_one = phase_one
        @phase_two = phase_two
        @lr = @initial_learning_rate

        @phase_one_learning_rate = phase_one_learning_rate
        @phase_two_learning_rate = phase_two_learning_rate

        @radius_reduction = @phase_one / (nodes/2.0 - 1) + 1
        @delta_lr = (@lr - @phase_one_learning_rate)/ @phase_one
        @radius = (nodes / 2.0).to_i
      end

      # two different values will be returned, depending on the phase
      # in phase one, the radius will incrementially reduced by 1 every @radius_reduction time
      # in phase two, the radius is fixed to 1
      def radius_decay(epoch)
        if epoch > @phase_one
          return 1
        else
          if (epoch % @radius_reduction) == 0
            @radius -= 1
          end
          @radius
        end

      end

      # two different values will be returned, depending on the phase
      # in phase one, the rate will incrementially reduced everytime this method is called
      # on the switch of phases, the learning rate will be reset and the delta_lr (which signals
      # the decay value of the learning rate) is reset as well
      # in  phase two, the newly reset delta_lr rate will be used to incrementially reduce the
      # learning rate
      def learning_rate_decay(epoch)
        if epoch < @phase_one
          @lr -= @delta_lr
          return @lr
        elsif epoch == @phase_one
          @lr = @phase_one_learning_rate
          @delta_lr = (@phase_one_learning_rate - @phase_two_learning_rate)/@phase_two
          return @lr
        else
          @lr -= @delta_lr
        end
      end

    end

  end

end

