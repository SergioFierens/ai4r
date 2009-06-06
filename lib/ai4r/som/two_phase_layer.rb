require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'

module Ai4r
  module Som
    class TwoPhaseLayer < Layer

      def initialize(nodes, learning_rate = 0.5, phase_one = 150, phase_two = 100, phase_one_learning_rate = 0.1, phase_two_learning_rate = 0)
        super nodes, phase_one + phase_two, learning_rate
        @phase_one = phase_one
        @phase_two = phase_two
        @lr = @initial_learning_rate

        @phase_one_learning_rate = phase_one_learning_rate
        @phase_two_learning_rate = phase_two_learning_rate

        @radius_reduction = @phase_one / (nodes/2 - 1) + 1
        @delta_lr = (@lr - @phase_one_learning_rate)/ @phase_one
        @radius = (nodes / 2).to_i
      end

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

      def learning_rate_decay(epoch)
        if epoch < @phase_one
          @lr -= @delta_lr
          return @lr
        elsif epoch == @phase_one
          @lr = @phase_one_learning_rate
          @delta_lr = (@phase_one_learning_rate - @phase_two_learning_rate)/@phase_two
          return @lr
        end

        @lr -= @delta_lr
        @lr
      end

    end
  end
end

