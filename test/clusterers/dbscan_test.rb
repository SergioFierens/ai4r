# Author::    Gwénaël Rault (implementation)
# License::   AGPL-3.0
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require 'minitest/autorun'
require 'ai4r/clusterers/dbscan'

class DBSCANTest < Minitest::Test

  include Ai4r::Clusterers
  include Ai4r::Data

  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]

  def test_build
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = DBSCAN.new.set_parameters({:epsilon => 8, :min_points => 3}).build(data_set)

    # draw_map(clusterer)
    # Verify that 3 clusters are created
    assert_equal 3, clusterer.clusters.length
    total_length = 0
    clusterer.clusters.each do |cluster|
      total_length += cluster.length
    end
    assert @@data.length >= total_length
    # Data inside clusters must be the same as original data
    clusterer.clusters.each do |cluster|
     cluster.each do |data_item|
       assert @@data.include?(data_item)
     end
    end
  end

  def test_distance
    clusterer = DBSCAN.new.set_parameters(:epsilon => 2)
    # By default, distance returns the euclidean distance to the power of 2
    assert_equal 2385, clusterer.distance(
      [1, 10, "Chicago", 2],
      [10, 10, "London", 50])

    # Ensure default distance raises error for nil argument
    assert_raises(TypeError) {clusterer.distance([1, 10], [nil, nil])}

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

  def test_on_empty
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    clusterer = DBSCAN.new.set_parameters(:epsilon => 0).build(data_set)
    # Verify that every item is defined as noise
    assert clusterer.labels.all?{ |label| label == :noise}
    # Verify that none cluster has been created
    assert_equal 0, clusterer.clusters.length
  end

  def test_undefined_epsilon
    data_set = DataSet.new(:data_items => @@data, :data_labels => ["X", "Y"])
    assert_raises(ArgumentError) {DBSCAN.new.build(data_set)}
  end

  def test_eval_unsupported
    clusterer = DBSCAN.new
    assert_raises(NotImplementedError) { clusterer.eval([0, 0]) }
  end

  private
  def draw_map(clusterer)
    map = Array.new(11) {Array.new(11, 0)}
    clusterer.clusters.each_index do |i|
      clusterer.clusters[i].each do |point|
        map[point.first][point.last]=(i+1)
      end
    end
    map.each { |row| puts row.inspect}
  end
end
