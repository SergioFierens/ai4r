# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/clusterers/complete_linkage'

class Ai4r::Clusterers::CompleteLinkage
  attr_accessor :data_set, :number_of_clusters, :clusters, :distance_matrix
end

class CompleteLinkageTest < Test::Unit::TestCase

  include Ai4r::Clusterers
  include Ai4r::Data

  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]

  @@expected_distance_matrix = [
        [98.0],
        [89.0, 5.0],
        [68.0, 26.0, 9.0],
        [74.0, 4.0, 1.0, 10.0],
        [0.0, 98.0, 89.0, 68.0, 74.0],
        [81.0, 53.0, 26.0, 5.0, 29.0, 81.0],
        [8.0, 106.0, 85.0, 52.0, 74.0, 8.0, 53.0],
        [100.0, 2.0, 1.0, 16.0, 2.0, 100.0, 37.0, 100.0],
        [68.0, 26.0, 9.0, 0.0, 10.0, 68.0, 5.0, 52.0, 16.0],
        [49.0, 49.0, 26.0, 5.0, 25.0, 49.0, 4.0, 29.0, 37.0, 5.0],
        [2.0, 72.0, 65.0, 50.0, 52.0, 2.0, 65.0, 10.0, 74.0, 50.0, 37.0]]

  def setup
    Ai4r::Clusterers::CompleteLinkage.send(:public,
     *Ai4r::Clusterers::CompleteLinkage.protected_instance_methods)
  end

  def test_build_with_distance
    clusterer = Ai4r::Clusterers::CompleteLinkage.new
    clusterer.build(DataSet.new(:data_items => @@data), distance: 4.0)
    # draw_map(clusterer)
    assert_equal 6, clusterer.clusters.length
  end

  def test_linkage_distance
    clusterer = Ai4r::Clusterers::CompleteLinkage.new
    clusterer.distance_matrix = @@expected_distance_matrix
    assert_equal 98, clusterer.linkage_distance(0,1,2)
    assert_equal 74, clusterer.linkage_distance(4,2,5)
  end

  def test_distance_between_item_and_cluster
    clusterer = CompleteLinkage.new
    assert_equal 32.0, clusterer.distance_between_item_and_cluster([1,2],
      DataSet.new(:data_items => [[3,4],[5,6]]))
  end

  private
  def draw_map(clusterer)
    map = Array.new(11) {Array.new(11, 0)}
    clusterer.clusters.each_index do |i|
      clusterer.clusters[i].data_items.each do |point|
        map[point.first][point.last]=(i+1)
      end
    end
    map.each { |row| puts row.inspect}
  end
end
