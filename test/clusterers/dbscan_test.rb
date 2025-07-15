# frozen_string_literal: true

# Author::    Gwénaël Rault (implementation)
# License::   AGPL-3.0
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../test_helper'
require 'ai4r/clusterers/dbscan'

class DBSCANTest < Minitest::Test
  include Ai4r::Clusterers
  include Ai4r::Data

  @@data = [[10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
            [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]

  def test_build
    data_set = DataSet.new(data_items: @@data, data_labels: %w[X Y])
    clusterer = DBSCAN.new.set_parameters({ epsilon: 8, min_points: 3 }).build(data_set)

    # draw_map(clusterer)
    # Verify that 3 clusters are created
    assert_equal 3, clusterer.clusters.length
    total_length = 0
    clusterer.clusters.each do |cluster|
      total_length += cluster.data_items.length
    end
    assert @@data.length >= total_length
    # Data inside clusters must be the same as original data
    clusterer.clusters.each do |cluster|
      cluster.data_items.each do |data_item|
        assert @@data.include?(data_item)
      end
    end
  end

  def test_number_of_clusters_attribute
    data_set = DataSet.new(data_items: @@data, data_labels: %w[X Y])
    clusterer = DBSCAN.new.set_parameters(epsilon: 8, min_points: 3).build(data_set)
    assert_equal clusterer.clusters.length, clusterer.number_of_clusters
    assert clusterer.number_of_clusters.positive?
  end

  def test_build_resets_state
    data_set = DataSet.new(data_items: @@data, data_labels: %w[X Y])
    clusterer = DBSCAN.new.set_parameters(epsilon: 8, min_points: 3)
    first = clusterer.build(data_set)
    assert_equal first.clusters.length, first.number_of_clusters
    second = clusterer.build(data_set)
    assert_equal first.clusters.length, second.clusters.length
    assert_equal second.clusters.length, second.number_of_clusters
  end

  def test_distance
    clusterer = DBSCAN.new.set_parameters(epsilon: 2)
    # By default, distance returns the euclidean distance to the power of 2
    assert_equal 2385, clusterer.distance(
      [1, 10, 'Chicago', 2],
      [10, 10, 'London', 50]
    )

    # Ensure default distance raises error for nil argument
    assert_raises(TypeError) { clusterer.distance([1, 10], [nil, nil]) }

    # Test new distance definition
    manhattan_distance = lambda do |a, b|
      dist = 0.0
      a.each_index do |index|
        dist += (a[index] - b[index]).abs if a[index].is_a?(Numeric) && b[index].is_a?(Numeric)
      end
      dist
    end
    clusterer.set_parameters({ distance_function: manhattan_distance })
    assert_equal 57, clusterer.distance(
      [1, 10, 'Chicago', 2],
      [10, 10, 'London', 50]
    )
  end

  def test_on_empty
    data_set = DataSet.new(data_items: @@data, data_labels: %w[X Y])
    clusterer = DBSCAN.new.set_parameters(epsilon: 0).build(data_set)
    # Verify that every item is defined as noise
    assert(clusterer.labels.all? { |label| label == :noise })
    # Verify that none cluster has been created
    assert_equal 0, clusterer.clusters.length
    assert_equal 0, clusterer.number_of_clusters
  end

  def test_undefined_epsilon
    data_set = DataSet.new(data_items: @@data, data_labels: %w[X Y])
    assert_raises(ArgumentError) { DBSCAN.new.build(data_set) }
  end

  def test_eval_unsupported
    clusterer = DBSCAN.new
    assert_raises(NotImplementedError) { clusterer.eval([0, 0]) }
  end

  def test_labels_are_valid
    data_set = DataSet.new(data_items: @@data, data_labels: %w[X Y])
    clusterer = DBSCAN.new.set_parameters(epsilon: 8, min_points: 3).build(data_set)
    valid = (1..clusterer.number_of_clusters).to_a + [:noise]
    assert(clusterer.labels.all? { |label| valid.include?(label) })
  end

  private

  def draw_map(clusterer)
    map = Array.new(11) { Array.new(11, 0) }
    clusterer.clusters.each_index do |i|
      clusterer.clusters[i].data_items.each do |point|
        map[point.first][point.last] = (i + 1)
      end
    end
    map.each { |row| puts row.inspect }
  end
end
