require_relative '../test_helper'
require 'ai4r/clusterers/clusterer'

class ClustererBaseTest < Minitest::Test
  include Ai4r::Clusterers

  def test_base_methods_raise_and_support_eval
    clusterer = Clusterer.new
    assert clusterer.supports_eval?
    assert_raises(NotImplementedError) { clusterer.build(nil, 1) }
    assert_raises(NotImplementedError) { clusterer.eval(nil) }
  end

  def test_get_min_index
    clusterer = Clusterer.new
    assert_equal 1, clusterer.send(:get_min_index, [5, 2, 3])
    assert_equal 0, clusterer.send(:get_min_index, [-1, 0, 1])
  end
end
