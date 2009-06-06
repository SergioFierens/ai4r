# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/parameterizable'

module Ai4r

  module Som

    class Layer

      include Ai4r::Data::Parameterizable

      parameters_info :nodes => "number of nodes, has to be equal to the som",
                      :epochs => "number of epochs the algorithm has to run",
                      :radius => "sets the initial neighborhoud radius"

      def initialize(nodes, radius, epochs = 100, learning_rate = 0.7)
        @nodes = nodes
        @epochs = epochs
        @radius = radius
        @time_to_epochs = @epochs / Math.log(@nodes / 2)
        @initial_learning_rate = learning_rate
      end

      def influence_decay(distance, radius)
        Math.exp(- (distance.to_f**2 / 2.0 / radius.to_f**2))
      end

      def radius_decay(epoch)
        (@radius * ( 1 - epoch/ @time_to_epochs)).round
      end

      def learning_rate_decay(epoch)
        @initial_learning_rate * ( 1 - epoch / @time_to_epochs)
      end

    end

  end

end
