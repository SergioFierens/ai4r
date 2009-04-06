# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/ai4r/clusterers/k_means'

class KMeansTest < Test::Unit::TestCase
  
  include Ai4r::Clusterers
  include Ai4r::Data

  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]
  
  def test_build
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = KMeans.new.build(data_set, 4)
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
  
  def test_eval
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = KMeans.new.build(data_set, 4)
    item = [10,0]
    cluster_index = clusterer.eval(item)
    # Must return a valid cluster index [0-3]
    assert cluster_index >= 0 && cluster_index < 4
    # Distance to cluster centroid must be less than distance to any other
    # centroid
    min_distance = clusterer.distance(clusterer.centroids[cluster_index], item)
    clusterer.centroids.each do |centroid|
      assert clusterer.distance(centroid, item) >= min_distance
    end
  end
  
  def test_distance
    clusterer = KMeans.new
    # By default, distance returns the eucledian distance to the power of 2
    assert_equal 2385, clusterer.distance(
      [1, 10, "Chicago", 2], 
      [10, 10, "London", 50])
    # Test new distance definition
    manhattan_distance = lambda do |a, b| 
        dist = 0.0
        a.each_index do |index|
          if a[index].is_a?(Numeric) && b[index].is_a?(Numeric)
            dist = dist + (a[index]-b[index]).abs
          end
        end
        dist
    end
    clusterer.set_parameters({:distance_function => manhattan_distance})
    assert_equal 57, clusterer.distance(
      [1, 10, "Chicago", 2], 
      [10, 10, "London", 50])
  end

  def test_max_iterations
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = KMeans.new.
      set_parameters({:max_iterations=>1}).
      build(data_set, 4)
    assert_equal 1, clusterer.iterations
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

