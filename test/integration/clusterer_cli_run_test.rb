# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/clusterer/cluster_bench'

class ClustererCliRunTest < Minitest::Test
  StubRunner = Class.new do
    attr_reader :data_set, :k

    @instances = []
    class << self
      attr_reader :instances
    end

    def initialize(data_set, k)
      @data_set = data_set
      @k = k
      self.class.instances << self
    end

    def call
      Bench::Common::Metrics.new('stub', {})
    end
  end

  StubDbscan = Class.new do
    attr_reader :data_set, :epsilon, :min_points

    @instances = []
    class << self
      attr_reader :instances
    end

    def initialize(data_set, epsilon, min_points)
      @data_set = data_set
      @epsilon = epsilon
      @min_points = min_points
      self.class.instances << self
    end

    def call
      Bench::Common::Metrics.new('dbscan', {})
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

  def test_run_invokes_runners_and_reports_results
    StubRunner.instances.clear
    StubDbscan.instances.clear

    options = {
      algos: %w[foo dbscan],
      dataset: 'dummy.csv',
      k: 3,
      epsilon: 0.4,
      min_points: 2,
      with_gt: false,
      export: nil
    }
    cli = Minitest::Mock.new
    cli.expect(:parse, options, [Array])
    captured = nil
    cli.expect(:report, nil) { |results, _| captured = results }

    data_set = Ai4r::Data::DataSet.new(data_items: [[1, 2]])

    stub_new = lambda do |_name, _algos, _metrics, &block|
      block&.call(Object.new.tap { |o| def o.on(*); end }, {})
      cli
    end

    Bench::Common::CLI.stub(:new, stub_new) do
      Bench::Clusterer.stub(:load_dataset, data_set) do
        with_const(Bench::Clusterer, :RUNNERS, { 'foo' => StubRunner, 'dbscan' => StubDbscan }) do
          Bench::Clusterer.run([])
        end
      end
    end

    cli.verify

    assert_equal 1, StubRunner.instances.size
    assert_equal data_set, StubRunner.instances.first.data_set
    assert_equal 3, StubRunner.instances.first.k

    assert_equal 1, StubDbscan.instances.size
    assert_equal data_set, StubDbscan.instances.first.data_set
    assert_equal 0.4, StubDbscan.instances.first.epsilon
    assert_equal 2, StubDbscan.instances.first.min_points

    assert_equal 2, captured.size
    assert_kind_of Bench::Common::Metrics, captured.first
  end
end
