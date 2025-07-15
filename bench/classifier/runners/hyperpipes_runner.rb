require_relative 'base_runner'
require 'ai4r/classifiers/hyperpipes'

module Bench
  module Classifier
    module Runners
      class HyperpipesRunner < BaseRunner
        private

        def build_model
          Ai4r::Classifiers::Hyperpipes.new.build(@train_set)
        end
      end
    end
  end
end
