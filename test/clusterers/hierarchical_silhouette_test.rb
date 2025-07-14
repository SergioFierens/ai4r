# frozen_string_literal: true

require 'minitest/autorun'
require 'ai4r/clusterers/ward_linkage'

class HierarchicalSilhouetteTest < Minitest::Test
  include Ai4r::Clusterers
  include Ai4r::Data

  DATA = [[1, 1], [1, 2], [2, 1], [2, 2], [8, 8], [8, 9], [9, 8], [9, 9]].freeze

  def test_silhouette
    clusterer = WardLinkage.new.build(DataSet.new(data_items: DATA), 2)
    assert_in_delta 0.98639, clusterer.silhouette, 0.0001
  end
end
