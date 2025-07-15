require_relative 'base_runner'
require 'ai4r/classifiers/id3'

module Bench
  module Classifier
    module Runners
      class Id3Runner < BaseRunner
        private

        def build_model
          Ai4r::Classifiers::ID3.new.build(@train_set)
        end
      end
    end
  end
end
