# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/clusterers/bisecting_k_means'

class BisectingKMeansTest < Test::Unit::TestCase
  
  include Ai4r::Clusterers
  include Ai4r::Data

  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]
  
  def test_build_without_refine
    build(false)
  end
  
  def test_build_with_refine
    build(true)
  end
  
  protected
  def build(refine)
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = BisectingKMeans.new
    clusterer.set_parameters :refine => refine
    clusterer.build(data_set, 4)
    #draw_map(clusterer)
    # Verify that all 4 clusters are created
    assert_equal 4, clusterer.clusters.length
    assert_equal 4, clusterer.centroids.length
    # The addition of all instances of every cluster must be equal than
    # the number of data points
    total_length = 0
    clusterer.clusters.each do |cluster| 
      total_length += cluster.data_items.length
    end
    assert_equal @@data.length, total_length
    # Data inside clusters must be the same as orifinal data
    clusterer.clusters.each do |cluster| 
     cluster.data_items.each do |data_item|
       assert @@data.include?(data_item)
     end
    end
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

