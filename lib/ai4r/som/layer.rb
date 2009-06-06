require File.dirname(__FILE__) + '/../data/parameterizable'

module Ai4r

  module Som

    class Layer

      include Ai4r::Data::Parameterizable

      parameters_info :nodes => "number of nodes, has to be equal to the som",
                      :epochs => "number of epochs the algorithm has to run"

      def initialize(nodes, epochs = 10, learning_rate = 0.5)
        @nodes = nodes
        @epochs = epochs
        @time_to_epochs = @epochs / Math.log(@nodes / 2)
        @initial_learning_rate = learning_rate
      end

      def influence_decay(distance, radius)
        Math.exp(- (distance.to_f / 2.0 / radius.to_f))
      end

      def radius_decay(epoch)
        @nodes / 2 * Math.exp(- (epoch.to_f / @time_to_epochs))
      end

      def learning_rate_decay(epoch)
        @initial_learning_rate * Math.exp(- (epoch.to_f / @epochs - epoch))
      end

    end

  end
end
