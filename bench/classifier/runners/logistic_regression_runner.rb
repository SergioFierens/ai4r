require_relative '../../common/base_runner'
require 'ai4r/classifiers/logistic_regression'

module Bench
  module Classifier
    module Runners
      class LogisticRegressionRunner < Bench::Common::BaseRunner
        def initialize(train_set, test_set)
          @test_set = test_set
          super(train_set)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          classifier = Ai4r::Classifiers::LogisticRegression.new.build(problem)
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          correct = @test_set.data_items.count do |row|
            classifier.eval(row[0...-1]) == row.last
          end
          accuracy = correct / @test_set.data_items.length.to_f

          metrics = { accuracy: accuracy.round(3), duration_ms: (duration * 1000).round(2) }
          Bench::Common::Metrics.new(algo_name, metrics)
        end
      end
    end
  end
end
