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
    # Collection of common activation functions and their derivatives.
    module ActivationFunctions
      FUNCTIONS = {
        sigmoid: ->(x) { 1.0 / (1.0 + Math.exp(-x)) },
        tanh: ->(x) { Math.tanh(x) },
        relu: ->(x) { x > 0 ? x : 0 }
      }

      DERIVATIVES = {
        sigmoid: ->(y) { y * (1 - y) },
        tanh: ->(y) { 1.0 - y**2 },
        relu: ->(y) { y > 0 ? 1.0 : 0.0 }
      }
    end
  end
end

