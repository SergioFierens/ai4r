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

  def test_default_parameters
    c = IB1.new
    assert_equal 1, c.k
    assert_nil c.distance_function
    assert_equal :first, c.tie_break
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


  def test_neighbors_for
    expected = [
      ['Chicago', 55, 'M', 'N'],
      ['Chicago', 43, 'M', 'Y'],
      ['Chicago', 71, 'M', 'N']
    ]
    assert_equal(expected, @classifier.neighbors_for(['Chicago', 55, 'M'], 3))
  end

  def test_k_nearest
    classifier = IB1.new.set_parameters(:k => 3).build(@data_set)
    assert_equal('N', classifier.eval(['Chicago', 47, 'M']))
  end

  def test_tie_break
    classifier = IB1.new.set_parameters(:k => 2, :tie_break => :first).build(@data_set)
    assert_equal('Y', classifier.eval(['Chicago', 47, 'M']))
    srand(1)
    classifier = IB1.new.set_parameters(:k => 2, :tie_break => :random).build(@data_set)
    assert_equal('N', classifier.eval(['Chicago', 47, 'M']))
  end

  def test_custom_distance
    dist = proc { |a, b| a.first == b.first ? 0 : 1 }
    classifier = IB1.new.set_parameters(:distance_function => dist).build(@data_set)
    assert_equal('Y', classifier.eval(['Chicago', 55, 'M']))
  end    
   
  def test_add_instance
    items = @@data_items[0...7]
    data_set = DataSet.new(data_items: items, data_labels: @@data_labels)
    classifier = IB1.new.build(data_set)
    assert_equal('Y', classifier.eval(['Chicago', 55, 'M']))
    classifier.add_instance(['Chicago', 55, 'M', 'N'])
    assert_equal('N', classifier.eval(['Chicago', 55, 'M']))
    assert_equal 8, classifier.data_set.data_items.length
  end

  def test_eval_does_not_update_ranges
    classifier = IB1.new.build(@data_set)
    before_min = classifier.min_values.clone
    before_max = classifier.max_values.clone
    classifier.eval(['Chicago', 90, 'M'])
    assert_equal(before_min, classifier.min_values)
    assert_equal(before_max, classifier.max_values)
  end

  def test_update_with_instance
    classifier = IB1.new.build(@data_set)
    size = classifier.data_set.data_items.length
    classifier.update_with_instance(['Chicago', 90, 'M', 'N'])
    assert_equal 90, classifier.max_values[1]
    assert_equal size, classifier.data_set.data_items.length
    classifier.update_with_instance(['Chicago', 90, 'M', 'N'], learn: true)
    assert_equal size + 1, classifier.data_set.data_items.length
  end

end

  
