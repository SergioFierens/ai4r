# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/clusterers/k_means'

class KMeansTest < Test::Unit::TestCase

  include Ai4r::Clusterers
  include Ai4r::Data

  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]

  # k-means will generate an empty cluster with this data and initial centroid assignment
  @@empty_cluster_data = [[-0.1, 0], [0, 0], [0.1, 0], [-0.1, 10], [0.1, 10], [0.2, 10]]
  @@empty_centroid_indices = [0,1,2]

  def test_build
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = KMeans.new.build(data_set, 4)
    #draw_map(clusterer)
    # Verify that all 4 clusters are created
    assert_equal 4, clusterer.clusters.length
    assert_equal 4, clusterer.centroids.length
    # The addition of all instances of every cluster must be equal to
    # the number of data points
    total_length = 0
    clusterer.clusters.each do |cluster|
      total_length += cluster.data_items.length
    end
    assert_equal @@data.length, total_length
    # Data inside clusters must be the same as original data
    clusterer.clusters.each do |cluster|
     cluster.data_items.each do |data_item|
       assert @@data.include?(data_item)
     end
    end
  end

  def test_build_and_eliminate_empty_clusters
    data_set = DataSet.new(:data_items => @@empty_cluster_data, :data_labels => ["X", "Y"])
    # :eliminate is the :on_empty default, so we don't need to pass it as a parameter for it
    clusterer = KMeans.new.set_parameters({:centroid_indices=>@@empty_centroid_indices}).build(data_set, @@empty_centroid_indices.size)

    # Verify that one cluster was eliminated
    assert_equal @@empty_centroid_indices.size - 1, clusterer.clusters.length
    assert_equal @@empty_centroid_indices.size - 1, clusterer.centroids.length

    # The addition of all instances of every cluster must be equal to
    # the number of data points
    total_length = 0
    clusterer.clusters.each do |cluster|
      total_length += cluster.data_items.length
    end
    assert_equal @@empty_cluster_data.length, total_length
    # Data inside clusters must be the same as original data
    clusterer.clusters.each do |cluster|
     cluster.data_items.each do |data_item|
       assert @@empty_cluster_data.include?(data_item)
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
    # By default, distance returns the euclidean distance to the power of 2
    assert_equal 2385, clusterer.distance(
      [1, 10, "Chicago", 2],
      [10, 10, "London", 50])

    # Ensure default distance raises error for nil argument
    exception = assert_raise(TypeError) {clusterer.distance([1, 10], [nil, nil])}

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

  def test_centroid_indices
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    # centroid_indices need not be specified:
    KMeans.new.build(data_set, 4)
    # centroid_indices can be specified:
    KMeans.new.set_parameters({:centroid_indices=>[0,1,2,3]}).build(data_set, 4)
    # raises exception if number of clusters differs from length of centroid_indices:
    exception = assert_raise(ArgumentError) {KMeans.new.set_parameters({:centroid_indices=>[0,1,2,3]}).build(data_set, 2)}
    assert_equal('Length of centroid indices array differs from the specified number of clusters', exception.message)
    # raises exception for bad centroid index:
    exception = assert_raise(ArgumentError) {KMeans.new.set_parameters({:centroid_indices=>[0,1,2,@@data.size+10]}).build(data_set, 4)}
    assert_equal("Invalid centroid index #{@@data.size+10}", exception.message)
  end

  def test_on_empty
    data_set = DataSet.new(:data_items => @@empty_cluster_data, :data_labels => ["X", "Y"])
    clusterer = KMeans.new.set_parameters({:centroid_indices=>@@empty_centroid_indices}).build(data_set, @@empty_centroid_indices.size)
    # Verify that one cluster was eliminated
    assert_equal @@empty_centroid_indices.size - 1, clusterer.clusters.length
    # Verify that eliminate is the on_empty default
    assert_equal 'eliminate', clusterer.on_empty
    # Verify that invalid on_empty option throws an argument error
    exception = assert_raise(ArgumentError) {KMeans.new.set_parameters({:centroid_indices=>@@empty_centroid_indices, :on_empty=>'ldkfje'}).build(data_set, @@empty_centroid_indices.size)}
    assert_equal("Invalid value for on_empty", exception.message)
    # Verify that on_empty option 'terminate' raises an error when an empty cluster arises
    exception = assert_raise(TypeError) {KMeans.new.set_parameters({:centroid_indices=>@@empty_centroid_indices, :on_empty=>'terminate'}).build(data_set, @@empty_centroid_indices.size)}
    clusterer = KMeans.new.set_parameters({:centroid_indices=>@@empty_centroid_indices, :on_empty=>'random'}).build(data_set, @@empty_centroid_indices.size)
    # Verify that cluster was not eliminated
    assert_equal @@empty_centroid_indices.size, clusterer.clusters.length
    clusterer = KMeans.new.set_parameters({:centroid_indices=>@@empty_centroid_indices, :on_empty=>'outlier'}).build(data_set, @@empty_centroid_indices.size)
    # Verify that cluster was not eliminated
    assert_equal @@empty_centroid_indices.size, clusterer.clusters.length
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

