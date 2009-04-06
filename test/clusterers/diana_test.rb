# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/ai4r/clusterers/diana'

class Ai4r::Clusterers::Diana
  attr_accessor :data_set, :number_of_clusters, :clusters
end

class DianaTest < Test::Unit::TestCase
  
  include Ai4r::Clusterers
  include Ai4r::Data

  def setup
    Diana.send(:public, *Diana.protected_instance_methods)
  end
  
  @@data = [  [10, 3], [3, 10], [2, 8], [2, 5], [3, 8], [10, 3],
              [1, 3], [8, 1], [2, 9], [2, 5], [3, 3], [9, 4]]
              
  def test_build
    #TODO
  end
  
  def test_eval
    #TODO
  end
  
  def notest_cluster_diameter
    data_set = DataSet.new(:data_items => @@data)
    clusterer = Diana.new
    assert_equal 106, clusterer.cluster_diameter(data_set)
    assert_equal 98, clusterer.cluster_diameter(data_set[0..2])
  end
  
  def notest_max_diameter_cluster
    data_set = DataSet.new(:data_items => @@data)
    clusterer = Diana.new
    assert_equal 0, clusterer.max_diameter_cluster([data_set,data_set[0..2]])
    assert_equal 1, clusterer.max_diameter_cluster([data_set[0..2], data_set])
  end 

  def test_init_splinter_group
    clusterer = Diana.new 
    assert_equal [10,3], clusterer.
      init_splinter_group(DataSet.new(:data_items => @@data)).data_items[0]
  end
  
end