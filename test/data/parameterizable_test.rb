# frozen_string_literal: true

require 'minitest/autorun'
require 'ai4r/data/parameterizable'

class DummyParamClass
  include Ai4r::Data::Parameterizable
  parameters_info(max_iterations: 'desc')
end

module Ai4r
  module Data
    class ParameterizableTest < Minitest::Test
      def test_unknown_keys_are_ignored
        dummy = DummyParamClass.new
        dummy.set_parameters(max_iterations: 10, unknown: 'foo')
        assert_equal 10, dummy.max_iterations
        refute dummy.respond_to?(:unknown)
      end
    end
  end
end
