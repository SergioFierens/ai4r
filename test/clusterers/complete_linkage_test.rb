require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/ai4r/clusterers/complete_linkage'

class Ai4r::Clusterers::CompleteLinkage
  attr_accessor :data_set, :number_of_clusters, :clusters, :distance_matrix
  public :calc_index_clusters_distance
  public :distance_between_item_and_cluster
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
  
  def test_calc_index_clusters_distance
    clusterer = CompleteLinkage.new
    clusterer.distance_matrix = @@expected_distance_matrix
    assert_equal 98.0, clusterer.calc_index_clusters_distance([0], [1])
    assert_equal 74.0, clusterer.calc_index_clusters_distance([0, 1], [3, 4])
  end

  def test_distance_between_item_and_cluster
    clusterer = CompleteLinkage.new
    assert_equal 32.0, clusterer.distance_between_item_and_cluster([1,2], 
      DataSet.new(:data_items => [[3,4],[5,6]]))
  end
  
end

