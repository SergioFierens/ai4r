require_relative '../../common/metrics'

module Bench
  module Classifier
    module Runners
      class BaseRunner
        def initialize(train_set, test_set)
          @train_set = train_set
          @test_set = test_set
        end

        def call
          start_train = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          model = build_model
          train_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_train

          start_pred = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          predictions = @test_set.data_items.map { |row| model.eval(row[0...-1]) }
          pred_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_pred

          actual = @test_set.data_items.map(&:last)

          metrics = {
            accuracy: Bench::Common.accuracy(actual, predictions),
            precision: Bench::Common.precision(actual, predictions),
            recall: Bench::Common.recall(actual, predictions),
            f1: Bench::Common.f1(actual, predictions),
            training_ms: (train_time * 1000).round(2),
            predict_ms: ((pred_time * 1000) * 100 / @test_set.data_items.length).round(2),
            model_size_kb: (Marshal.dump(model).bytesize / 1024.0).round(2)
          }

          Bench::Common::Metrics.new(algo_name, metrics)
        end

        def algo_name
          self.class.name.split('::').last.sub(/Runner$/, '').downcase
        end

        private

        def build_model
          raise NotImplementedError
        end
      end
    end
  end
end
