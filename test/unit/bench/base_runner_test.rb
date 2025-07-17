require_relative '../../test_helper'
require_relative '../../../bench/common/base_runner'

class DummyRunner < Bench::Common::BaseRunner
  def initialize(problem, path)
    super(problem)
    @path = path
  end

  def run
    expand
    frontier_size(2)
    @path
  end
end

class BenchBaseRunnerTest < Minitest::Test
  def test_metrics_collection
    runner = DummyRunner.new(:prob, %w[a b c])
    result = runner.call
    assert_equal 'dummy', result.algorithm
    data = result.to_h
    assert data[:duration_ms] >= 0
    assert_equal 2, data[:solution_depth]
    assert_equal true, data[:completed]
    assert_equal 1, data[:nodes_expanded]
    assert_equal 2, data[:max_frontier_size]
  end
end
