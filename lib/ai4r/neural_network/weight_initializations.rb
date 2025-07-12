# frozen_string_literal: true
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module NeuralNetwork
    # Collection of common weight initialization strategies.
    module WeightInitializations
      # Uniform distribution in [-1, 1)
      def uniform
        ->(_n, _i, _j) { rand * 2 - 1 }
      end

      # Xavier/Glorot initialization based on layer dimensions
      def xavier(structure)

        lambda do |layer, _i, _j|
          limit = Math.sqrt(6.0 / (structure[layer] + structure[layer + 1]))
          rand * 2 * limit - limit
        end
      end

      # He initialization suitable for ReLU activations

      def he(structure)

        lambda do |layer, _i, _j|
          limit = Math.sqrt(6.0 / structure[layer])
          rand * 2 * limit - limit
        end
      end

      module_function :uniform, :xavier, :he
    end
  end
end
