# frozen_string_literal: true

require 'English'
require_relative '../test_helper'

class ExamplesTest < Minitest::Test
  EXAMPLES_DIR = File.expand_path('../../examples/classifiers', __dir__)

  def run_example(name)
    path = File.join(EXAMPLES_DIR, name)
    output = `ruby -I. #{path}`
    assert $CHILD_STATUS.success?, "Example #{name} failed"
    output
  end

  def test_naive_bayes_example
    out = run_example('naive_bayes_example.rb')
    assert_match(/\{"No"|"No"/, out)
  end

  def test_simple_linear_regression_example
    out = run_example('simple_linear_regression_example.rb')
    assert_match(/Predicted value:/, out)
  end
end
