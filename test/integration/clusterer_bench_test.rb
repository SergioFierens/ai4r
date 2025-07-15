# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/clusterer/cluster_bench'

class ClustererBenchTest < Minitest::Test
  include Bench::Clusterer::Runners

  DATA_PATH = File.expand_path('../../bench/clusterer/datasets/blobs.csv', __dir__)

  def setup
    @data = Bench::Clusterer.load_dataset(DATA_PATH, false)
  end

  def test_runners
    results = {
      kmeans: KmeansRunner,
      single_linkage: SingleLinkageRunner,
      average_linkage: AverageLinkageRunner,
      diana: DianaRunner
    }.map do |_, klass|
      klass.new(@data, 3).call
    end

    kmeans = results.find { |r| r.algorithm == 'kmeans' }
    assert_equal 3, kmeans[:clusters].size

    results.each do |res|
      assert res[:silhouette] >= -1 && res[:silhouette] <= 1
    end
  end
end
