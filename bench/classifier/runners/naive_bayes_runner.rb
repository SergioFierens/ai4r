require_relative 'base_runner'
require 'ai4r/classifiers/naive_bayes'

module Bench
  module Classifier
    module Runners
      class NaiveBayesRunner < BaseRunner
        private

        def build_model
          Ai4r::Classifiers::NaiveBayes.new.build(@train_set)
        end
      end
    end
  end
end
