# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r/classifiers/ib1'
require 'test/unit'

class Ai4r::Classifiers::IB1
  attr_accessor :data_set, :min_values, :max_values
end

include Ai4r::Classifiers
include Ai4r::Data

class IB1Test < Test::Unit::TestCase

  @@data_labels = [ 'city', 'age', 'gender', 'marketing_target'  ]

  @@data_items = [['New York',  25, 'M', 'Y'],
              ['New York',  23, 'M', 'Y'],
              ['New York',  18, 'M', 'Y'],
              ['Chicago',   43, 'M', 'Y'],
              ['New York',  34, 'F', 'N'],
              ['Chicago',   33, 'F', 'Y'],
              ['New York',  31, 'F', 'N'],
              ['Chicago',   55, 'M', 'N'],
              ['New York',  58, 'F', 'N'],
              ['New York',  59, 'M', 'N'],
              ['Chicago',   71, 'M', 'N'],
              ['New York',  60, 'F', 'N'],
              ['Chicago',   85, 'F', 'Y']
            ]
  
  
  def setup
    IB1.send(:public, *IB1.protected_instance_methods)
    @data_set = DataSet.new(:data_items => @@data_items, :data_labels => @@data_labels)
    @classifier = IB1.new.build(@data_set)
  end
  
  def test_build
    assert_raise(ArgumentError) { IB1.new.build(DataSet.new) }
    assert @classifier.data_set
    assert_equal [nil, 18, nil, nil], @classifier.min_values
    assert_equal [nil, 85, nil, nil], @classifier.max_values
  end

  def test_norm
    assert_equal(0,@classifier.norm('Chicago', 0))
    assert_in_delta(0.5522,@classifier.norm(55, 1),0.0001)
    assert_equal(0,@classifier.norm('F', 0))
  end

  def test_distance
    item = ['Chicago',   55, 'M', 'N']
    assert_equal(0, @classifier.distance(['Chicago',  55, 'M'], item))
    assert_equal(1, @classifier.distance([nil,  55, 'M'], item))
    assert_equal(1, @classifier.distance(['New York',  55, 'M'], item))
    assert_in_delta(0.2728, @classifier.distance(['Chicago',  20, 'M'], item), 0.0001)
  end

  def test_eval
    classifier = IB1.new.build(@data_set)
    assert classifier
    assert_equal('N', classifier.eval(['Chicago',  55, 'M']))
    assert_equal('N', classifier.eval(['New York', 35, 'F']))
    assert_equal('Y', classifier.eval(['New York', 25, 'M']))
    assert_equal('Y', classifier.eval(['Chicago',  85, 'F'])) 
  end

end

  
