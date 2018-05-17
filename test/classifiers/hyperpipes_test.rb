# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r/classifiers/hyperpipes'
require 'test/unit'

class Ai4r::Classifiers::Hyperpipes
  attr_accessor :data_set, :pipes
end

include Ai4r::Classifiers
include Ai4r::Data

class HyperpipesTest < Test::Unit::TestCase

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
    Hyperpipes.send(:public, *Hyperpipes.protected_instance_methods)
    @data_set = DataSet.new(:data_items => @@data_items, :data_labels => @@data_labels)
  end
  
  def test_build_pipe
    classifier = Hyperpipes.new
    assert_equal [{}, {:max=>-1.0/0, :min=>1.0/0}, {}], classifier.build_pipe(@data_set)
  end
  
  def test_build
    assert_raise(ArgumentError) { Hyperpipes.new.build(DataSet.new) }
    classifier = Hyperpipes.new.build(@data_set)
    assert classifier.pipes.include?("Y")
    assert classifier.pipes.include?("N")
  end

  def test_eval
    classifier = Hyperpipes.new.build(@data_set)
    assert classifier
    assert_equal('N', classifier.eval(['Chicago',  55, 'M']))
    assert_equal('N', classifier.eval(['New York', 35, 'F']))
    assert_equal('Y', classifier.eval(['New York', 25, 'M']))
    assert_equal('Y', classifier.eval(['Chicago',  85, 'F'])) 
  end

  def test_get_rules
    classifier = Hyperpipes.new.build(@data_set)
    age = 28
    gender = "M"
    marketing_target = nil
    eval classifier.get_rules
    assert_equal 'Y', marketing_target
    age = 44 
    city='New York'
    eval classifier.get_rules
    assert_equal 'N', marketing_target
  end
end

  
