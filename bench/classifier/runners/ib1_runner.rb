# frozen_string_literal: true

require_relative '../../common/base_runner'
require_relative '../../common/metrics'
require 'ai4r/classifiers/ib1'

module Bench
  module Classifier
    module Runners
      class Ib1Runner < Bench::Common::BaseRunner
        def initialize(train_set, test_set)
          @test_set = test_set
          super(train_set)
        end

        def call
          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          classifier = Ai4r::Classifiers::IB1.new.build(problem)
          training = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          predictions = @test_set.data_items.map { |row| classifier.eval(row[0...-1]) }
          pred_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start

          truth = @test_set.data_items.map(&:last)

          metrics = {
            accuracy: Bench::Common.accuracy(truth, predictions).round(2),
            precision: Bench::Common.precision(truth, predictions).round(2),
            recall: Bench::Common.recall(truth, predictions).round(2),
            f1: Bench::Common.f1(truth, predictions).round(2),
            training_ms: (training * 1000).round(2),
            predict_ms: ((pred_time / predictions.length) * 1000 * 100).round(2),
            model_size_kb: (Marshal.dump(classifier).bytesize / 1024.0).round(2)
          }
          Bench::Common::Metrics.new(algo_name, metrics)
        end
      end
    end
  end
end
