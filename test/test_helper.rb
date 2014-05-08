#
# neural_network_test.rb
#
# This is a unit test helper file for ai4r
#
# Author::    Olav Stetter
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt
#


require 'test/unit'


def assert_approximate_equality(expected, real, delta=0.01)
  assert (expected - real).abs < delta
end

def assert_approximate_equality_of_nested_list(expected, real, delta=0.01)
  if expected.respond_to?(:each) && real.respond_to?(:each) && expected.length == real.length
    [expected, real].transpose.each{ |ex, re| assert_approximate_equality_of_nested_list(ex, re, delta) }
  else
    assert expected == real
  end
end

def assert_equality_of_nested_list(expected, real)
  if expected.respond_to?(:each) && real.respond_to?(:each) && expected.length == real.length
    [expected, real].transpose.each{ |ex, re| assert_equality_of_nested_list(ex, re) }
  else
    assert expected == real
  end
end
