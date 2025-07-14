# frozen_string_literal: true
require_relative '../../test_helper'
require 'ai4r/clusterers/diana'

class TestDiana < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers

  DATA = [[1],[2],[3],[4]].freeze

  class CountingDiana < Diana
    attr_reader :splits, :first_cluster
    def initialize
      super
      @splits = 0
    end
    def build(ds, k)
      @first_cluster = ds.data_items.clone
      super
    end
    protected
    def max_diameter_cluster(clusters)
      @splits += 1
      super
    end
  end

  def test_dendrogram_height
    ds = DataSet.new(data_items: DATA)
    d = CountingDiana.new.build(ds, DATA.length)
    assert_equal DATA.length - 1, d.splits
  end

  def test_first_cluster_has_all_points
    ds = DataSet.new(data_items: DATA)
    d = CountingDiana.new.build(ds, 3)
    assert_equal DATA, d.first_cluster
  end
end
