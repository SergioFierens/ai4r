require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/ai4r/clusterers/single_linkage'

class Ai4r::Clusterers::SingleLinkage
  attr_accessor :data_set, :number_of_clusters, :clusters, :distance_matrix
end

class Ai4r::Clusterers::SingleLinkageTest < Test::Unit::TestCase
  
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
    SingleLinkage.send(:public, *SingleLinkage.protected_instance_methods)
  end
  
  def test_build
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.build(DataSet.new(:data_items => @@data), 4)
    #draw_map(clusterer)
    assert_equal 4, clusterer.clusters.length
  end
  
  def test_eval
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.build(DataSet.new(:data_items => @@data), 4)
    assert_equal 2, clusterer.eval([0,8])
    assert_equal 0, clusterer.eval([8,0])
  end

  def test_create_distance_matrix
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.create_distance_matrix(DataSet.new(:data_items => @@data))
    assert clusterer.distance_matrix
    clusterer.distance_matrix.each_with_index do |row, row_index|
      assert_equal row_index+1, row.length
    end
    assert_equal @@expected_distance_matrix, clusterer.distance_matrix
  end
  
  def test_read_distance_matrix
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.distance_matrix = @@expected_distance_matrix
    assert_equal 9.0, clusterer.read_distance_matrix(3, 2)
    assert_equal 9.0, clusterer.read_distance_matrix(2, 3)
    assert_equal 0, clusterer.read_distance_matrix(5, 5)
  end
  
  def test_calc_index_clusters_distance
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.distance_matrix = @@expected_distance_matrix
    assert_equal 98.0, clusterer.calc_index_clusters_distance([0], [1])
    assert_equal 4.0, clusterer.calc_index_clusters_distance([0, 1], [3, 4])
  end
  
  def test_get_closest_clusters
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.distance_matrix = @@expected_distance_matrix
    assert_equal [1,0], clusterer.get_closest_clusters([[0,1], [3,4]])
    assert_equal [2,1], clusterer.get_closest_clusters([[3,4], [0,1], [5,6]])
   end
   
  def test_create_initial_index_clusters
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusterer.data_set = DataSet.new :data_items => @@data
    index_clusters = clusterer.create_initial_index_clusters
    assert_equal @@data.length, index_clusters.length
    assert_equal 0, index_clusters.first.first
    assert_equal @@data.length-1, index_clusters.last.first
  end
  
  def test_merge_clusters
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    clusters = clusterer.merge_clusters([1,2], [[1,2],[3,4],[5,6]])
    assert_equal [[1,2], [3,4,5,6]], clusters.collect {|x| x.sort}
    clusters = clusterer.merge_clusters([2,1], [[1,2],[3,4],[5,6]])
    assert_equal [[1,2], [3,4,5,6]], clusters.collect {|x| x.sort}
  end
  
  def test_distance_between_item_and_cluster
    clusterer = Ai4r::Clusterers::SingleLinkage.new
    assert_equal 8.0, clusterer.distance_between_item_and_cluster([1,2], 
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

