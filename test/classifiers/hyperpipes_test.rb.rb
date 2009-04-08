# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/hyperpipes'
require 'test/unit'

DATA_LABELS = [ 'city', 'age_range', 'gender', 'marketing_target'  ]

DATA_ITEMS = [['New York',  '<30',      'M', 'Y'],
              ['Chicago',     '<30',      'M', 'Y'],
              ['Chicago',     '<30',      'F', 'Y'],
              ['New York',  '<30',      'M', 'Y'],
              ['New York',  '<30',      'M', 'Y'],
              ['Chicago',     '[30-50)',  'M', 'Y'],
              ['New York',  '[30-50)',  'F', 'N'],
              ['Chicago',     '[30-50)',  'F', 'Y'],
              ['New York',  '[30-50)',  'F', 'N'],
              ['Chicago',     '[50-80]', 'M', 'N'],
              ['New York',  '[50-80]', 'F', 'N'],
              ['New York',  '[50-80]', 'M', 'N'],
              ['Chicago',     '[50-80]', 'M', 'N'],
              ['New York',  '[50-80]', 'F', 'N'],
              ['Chicago',     '>80',      'F', 'Y']
            ]
 
class Ai4r::Classifiers::Hyperpipes
  attr_accessor :data_set, :pipes
end

include Ai4r::Classifiers
include Ai4r::Data

class HyperpipesTest < Test::Unit::TestCase

  def setup
    Hyperpipes.send(:public, *Hyperpipes.protected_instance_methods)
    @data_set = DataSet.new(:data_items => DATA_ITEMS, :data_labels => DATA_LABELS)
  end
  
  def test_build_pipe
     classifier = Hyperpipes.new
    assert_equal [{}, {}, {}], classifier.build_pipe(@data_set)
  end
  
  def test_get_rules
    
  end

  def test_eval
       
  end

  def nntest_rules_eval
    classifier = Hyperpipes.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    #if age_range='<30' then marketing_target='Y'
    age_range = '<30'
    marketing_target = nil
    eval classifier.get_rules
    assert_equal 'Y', marketing_target
    #if age_range='[30-50)' and city='New York' then marketing_target='N'
    age_range='[30-50)' 
    city='New York'
    eval classifier.get_rules
    assert_equal 'N', marketing_target
  end
end

  