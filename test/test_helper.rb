#
# neural_network_test.rb
#
# This is a unit test helper file for ai4r
#
# Author::    Olav Stetter
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
#


require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter '/test/'
end

require 'minitest/autorun'
Minitest::Test.i_suck_and_my_tests_are_order_dependent!

require_relative 'helpers/numeric_assertions'
require_relative 'helpers/fixture_loader'

Minitest::Test.include NumericAssertions
Minitest::Test.include FixtureLoader


def assert_approximate_equality(expected, real, delta=0.01)
  if expected.respond_to?(:abs) && real.respond_to?(:abs)
    assert (expected - real).abs < delta, "<#{expected}> and <#{real}> are not equal enough"
  else
    assert_equal expected, real
  end
end

def assert_approximate_equality_of_nested_list(expected, real, delta=0.01)
  if expected.respond_to?(:each) && real.respond_to?(:each) && expected.length == real.length
    [expected, real].transpose.each{ |ex, re| assert_approximate_equality_of_nested_list(ex, re, delta) }
  else
    assert_approximate_equality expected, real
  end
end

def assert_equality_of_nested_list(expected, real)
  if expected.respond_to?(:each) && real.respond_to?(:each) && expected.length == real.length
    [expected, real].transpose.each{ |ex, re| assert_equality_of_nested_list(ex, re) }
  else
    assert_equal expected, real
  end
end

def assert_sse_decreases(series)
  series.each_cons(2) { |a, b| assert b <= a, 'SSE should not increase' }
end

def assert_purity(actual, truth, min)
  correct = actual.zip(truth).count { |a, t| a == t }
  purity = correct.to_f / actual.length
  assert purity >= min, "Purity #{purity} below #{min}"
end
