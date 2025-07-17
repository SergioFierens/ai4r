# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/classifier/classifier_bench'

class ClassifierCliRunTest < Minitest::Test
  StubRunner = Class.new do
    attr_reader :train, :test

    @@instances = []

    def self.instances
      @@instances
    end

    def initialize(train, test)
      @train = train
      @test = test
      @@instances << self
    end

    def call
      Bench::Common::Metrics.new('stub', {})
    end
  end

  def with_const(mod, const, val)
    old = mod.const_get(const)
    mod.send(:remove_const, const)
    mod.const_set(const, val)
    yield
  ensure
    mod.send(:remove_const, const)
    mod.const_set(const, old)
  end

  def test_run_splits_data_and_reports
    StubRunner.instances.clear

    options = { algos: %w[foo], dataset: 'ignore.csv', split: 0.25, export: nil }
    cli = Minitest::Mock.new
    cli.expect(:parse, options, [Array])
    captured = nil
    cli.expect(:report, nil) { |results, _| captured = results }

    train_set = 'train'
    test_set = 'test'
    dataset = Object.new
    dataset.define_singleton_method(:shuffle!) { dataset }
    dataset.define_singleton_method(:split) do |ratio:|
      raise 'ratio mismatch' unless (ratio - 0.75).abs < 0.0001

      [train_set, test_set]
    end

    stub_new = lambda do |_name, _algos, _metrics, &block|
      block&.call(Object.new.tap { |o| def o.on(*); end }, {})
      cli
    end

    Bench::Common::CLI.stub(:new, stub_new) do
      Bench::Classifier.stub(:load_dataset, dataset) do
        with_const(Bench::Classifier, :RUNNERS, { 'foo' => StubRunner }) do
          Bench::Classifier.run([])
        end
      end
    end

    cli.verify

    assert_equal 1, StubRunner.instances.size
    assert_equal train_set, StubRunner.instances.first.train
    assert_equal test_set, StubRunner.instances.first.test

    assert_equal 1, captured.size
    assert_kind_of Bench::Common::Metrics, captured.first
  end
end
