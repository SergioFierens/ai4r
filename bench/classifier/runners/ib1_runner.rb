require_relative 'base_runner'
require 'ai4r/classifiers/ib1'

module Bench
  module Classifier
    module Runners
      class Ib1Runner < BaseRunner
        private

        def build_model
          Ai4r::Classifiers::IB1.new.build(@train_set)
        end
      end
    end
  end
end
