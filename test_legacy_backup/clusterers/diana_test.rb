# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/clusterers/diana'

class Ai4r::Clusterers::Diana
  attr_accessor :data_set, :number_of_clusters, :clusters
end

class DianaTest < Test::Unit::TestCase

  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]
              
  include Ai4r::Clusterers
  include Ai4r::Data

  def setup
    Diana.send(:public, *Diana.protected_instance_methods)
    @data_set = DataSet.new(:data_items => @@data.clone)
  end
          
  def test_build
    clusterer = Diana.new.build(@data_set, 4)
    assert_equal 4, clusterer.clusters.length
  end
  
  def test_eval
    clusterer = Diana.new.build(@data_set, 4)
    assert_equal 0, clusterer.eval([0, 0])
    assert_equal 1, clusterer.eval([9, 3])
    assert_equal 2, clusterer.eval([0,10])
    assert_equal 3, clusterer.eval([8, 0])
  end
  
  def test_cluster_diameter
    clusterer = Diana.new
    assert_equal 106, clusterer.cluster_diameter(@data_set)
    assert_equal 98, clusterer.cluster_diameter(@data_set[0..2])
  end
  
  def test_max_diameter_cluster
    clusterer = Diana.new
    assert_equal 0, clusterer.max_diameter_cluster([@data_set, @data_set[0..2]])
    assert_equal 1, clusterer.max_diameter_cluster([@data_set[0..2], @data_set])
  end 

  def test_init_splinter_cluster
    clusterer = Diana.new 
    assert_equal [10,3], clusterer.
      init_splinter_cluster(@data_set).data_items[0]
  end
  
  def test_max_distance_difference
    clusterer = Diana.new 
    data_set_a = @data_set[1..-1]
    data_set_b = @data_set[0]
    assert_equal [63.7, 4], clusterer.
      max_distance_difference(data_set_a, data_set_b)
  end
  
end
