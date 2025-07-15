# id3_test.rb
# 
# This is a unit test file for the ID3 algorithm (Quinlan) implemented
# in ai4r  
# 
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'ai4r/classifiers/id3'
require 'test/unit'

DATA_LABELS = [ 'city', 'age_range', 'gender', 'marketing_target'  ]

DATA_ITEMS = [  ['New York',  '<30',      'M', 'Y'],
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

NEW_YORK_DATA_ITEMS = [
                      ["New York", "<30", "M", "Y"],
                      ["New York", "<30", "M", "Y"],
                      ["New York", "<30", "M", "Y"],
                      ["New York", "[30-50)", "F", "N"],
                      ["New York", "[30-50)", "F", "N"],
                      ["New York", "[50-80]", "F", "N"],
                      ["New York", "[50-80]", "M", "N"],
                      ["New York", "[50-80]", "F", "N"]]

CHICAGO_DATA_ITEMS =  [
                      ["Chicago", "<30", "M", "Y"],
                      ["Chicago", "<30", "F", "Y"],
                      ["Chicago", "[30-50)", "M", "Y"],
                      ["Chicago", "[30-50)", "F", "Y"],
                      ["Chicago", "[50-80]", "M", "N"],
                      ["Chicago", "[50-80]", "M", "N"],
                      ["Chicago", ">80", "F", "Y"]]

YOUNG_DATA_ITEMS =  [
                    ["New York", "<30", "M", "Y"],
                    ["Chicago", "<30", "M", "Y"],
                    ["Chicago", "<30", "F", "Y"],
                    ["New York", "<30", "M", "Y"],
                    ["New York", "<30", "M", "Y"]]

MIDDLE_AGE_DATA_ITEMS = [
                        ["Chicago", "[30-50)", "M", "Y"],
                        ["New York", "[30-50)", "F", "N"],
                        ["Chicago", "[30-50)", "F", "Y"],
                        ["New York", "[30-50)", "F", "N"]]

OLD_DATA_ITEMS =  [
                  ["Chicago", "[50-80]", "M", "N"],
                  ["New York", "[50-80]", "F", "N"],
                  ["New York", "[50-80]", "M", "N"],
                  ["Chicago", "[50-80]", "M", "N"],
                  ["New York", "[50-80]", "F", "N"]]

ELDER_DATA_ITEMS =  [
                    ["Chicago", ">80", "F", "Y"]]

SPLIT_DATA_ITEMS_BY_CITY = [ NEW_YORK_DATA_ITEMS, CHICAGO_DATA_ITEMS ]
SPLIT_DATA_ITEMS_BY_AGE = [ YOUNG_DATA_ITEMS, MIDDLE_AGE_DATA_ITEMS, OLD_DATA_ITEMS, ELDER_DATA_ITEMS ]
SPLIT_DATA_ITEMS_BY_CITY_HASH = {
                                'New York' => NEW_YORK_DATA_ITEMS,
                                'Chicago' => CHICAGO_DATA_ITEMS }
SPLIT_DATA_ITEMS_BY_AGE_HASH = {
                              '<30' => YOUNG_DATA_ITEMS,
                              '[30-50)' => MIDDLE_AGE_DATA_ITEMS,
                              '[50-80]' => OLD_DATA_ITEMS,
                              '>80' => ELDER_DATA_ITEMS }

  EXPECTED_RULES_STRING =  
    "if age_range=='<30' then marketing_target='Y'\n"+
    "elsif age_range=='[30-50)' and city=='Chicago' then marketing_target='Y'\n"+
    "elsif age_range=='[30-50)' and city=='New York' then marketing_target='N'\n"+
    "elsif age_range=='[50-80]' then marketing_target='N'\n"+
    "elsif age_range=='>80' then marketing_target='Y'\n"+
    "else raise 'There was not enough information during training to do a proper induction for this data element' end"
    
include Ai4r::Classifiers
include Ai4r::Data

class ID3Test < Test::Unit::TestCase

  def test_build
    Ai4r::Classifiers::ID3.send(:public, *Ai4r::Classifiers::ID3.protected_instance_methods)
    Ai4r::Classifiers::ID3.send(:public, *Ai4r::Classifiers::ID3.private_instance_methods)
  end

  def test_log2
    assert_equal 1.0, ID3.log2(2)
    assert_equal 0.0, ID3.log2(0)
    assert 1.585 - ID3.log2(3) < 0.001
  end

  def test_sum
    assert_equal 28, ID3.sum([5, 0, 22, 1])
    assert_equal 0, ID3.sum([])
  end

  def test_data_labels
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS))
    expected_default = [ 'attribute_1', 'attribute_2', 'attribute_3', 'class_value' ]
    assert_equal(expected_default, id3.data_set.data_labels)
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    assert_equal(DATA_LABELS, id3.data_set.data_labels)
  end

  def test_domain
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    expected_domain = [["New York", "Chicago"], ["<30", "[30-50)", "[50-80]", ">80"], ["M", "F"], ["Y", "N"]]
    assert_equal expected_domain, id3.domain(DATA_ITEMS)
  end

  def test_grid
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    expected_grid = [[3, 5], [5, 2]]
    domain = id3.domain(DATA_ITEMS)
    assert_equal expected_grid, id3.freq_grid(0, DATA_ITEMS, domain)
    expected_grid = [[5, 0], [2, 2], [0, 5], [1, 0]]
    assert_equal expected_grid, id3.freq_grid(1, DATA_ITEMS, domain)
  end

  def test_entropy
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    expected_entropy = 0.9118
    domain = id3.domain(DATA_ITEMS)
    freq_grid = id3.freq_grid(0, DATA_ITEMS, domain)
    assert expected_entropy - id3.entropy(freq_grid, DATA_ITEMS.length) < 0.0001
    expected_entropy = 0.2667
    freq_grid = id3.freq_grid(1, DATA_ITEMS, domain)
    assert expected_entropy - id3.entropy(freq_grid, DATA_ITEMS.length) < 0.0001
    expected_entropy = 0.9688
    freq_grid = id3.freq_grid(2, DATA_ITEMS, domain)
    assert expected_entropy - id3.entropy(freq_grid, DATA_ITEMS.length) < 0.0001
  end

  def test_min_entropy_index
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    domain = id3.domain(DATA_ITEMS)
    assert_equal 1, id3.min_entropy_index(DATA_ITEMS, domain)
    assert_equal 0, id3.min_entropy_index(DATA_ITEMS, domain, [1])
    assert_equal 2, id3.min_entropy_index(DATA_ITEMS, domain, [1, 0])
  end

  def test_split_data_examples_by_value
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    res = id3.split_data_examples_by_value(DATA_ITEMS, 0)
    assert_equal(SPLIT_DATA_ITEMS_BY_CITY_HASH, res)
    res = id3.split_data_examples_by_value(DATA_ITEMS, 1)
    assert_equal(SPLIT_DATA_ITEMS_BY_AGE_HASH, res)
  end

  def test_split_data_examples
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    domain = id3.domain(DATA_ITEMS)
    res = id3.split_data_examples(DATA_ITEMS, domain, 0)
    assert_equal(SPLIT_DATA_ITEMS_BY_CITY, res)
    res = id3.split_data_examples(DATA_ITEMS, domain, 1)
    assert_equal(SPLIT_DATA_ITEMS_BY_AGE, res)
  end

  def test_most_freq
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    domain = id3.domain(DATA_ITEMS)
    assert_equal 'Y', id3.most_freq(DATA_ITEMS, domain)
    assert_equal 'Y', id3.most_freq(SPLIT_DATA_ITEMS_BY_AGE[3], domain)
    assert_equal 'N', id3.most_freq(SPLIT_DATA_ITEMS_BY_AGE[2], domain)
  end

  def test_get_rules
    assert_equal [["marketing_target='N'"]], CategoryNode.new('marketing_target', 'N').get_rules
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    assert_equal EXPECTED_RULES_STRING, id3.get_rules
  end

  def test_eval
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    #if age_range='<30' then marketing_target='Y'
    assert_equal 'Y', id3.eval(['New York', '<30', 'F'])
    assert_equal 'Y', id3.eval(['Chicago', '<30', 'M'])
    #if age_range='[30-50)' and city='Chicago' then marketing_target='Y'
    assert_equal 'Y', id3.eval(['Chicago', '[30-50)', 'F'])
    assert_equal 'Y', id3.eval(['Chicago', '[30-50)', 'M'])
    #if age_range='[30-50)' and city='New York' then marketing_target='N'
    assert_equal 'N', id3.eval(['New York', '[30-50)', 'F'])
    assert_equal 'N', id3.eval(['New York', '[30-50)', 'M'])      
    #if age_range='[50-80]' then marketing_target='N'
    assert_equal 'N', id3.eval(['New York', '[50-80]', 'F'])
    assert_equal 'N', id3.eval(['Chicago', '[50-80]', 'M'])      
    #if age_range='>80' then marketing_target='Y'
    assert_equal 'Y', id3.eval(['New York', '>80', 'M'])      
    assert_equal 'Y', id3.eval(['Chicago', '>80', 'F'])      
  end

  def test_rules_eval
    id3 = ID3.new.build(DataSet.new(:data_items =>DATA_ITEMS, :data_labels => DATA_LABELS))
    #if age_range='<30' then marketing_target='Y'
    age_range = '<30'
    marketing_target = nil
    eval id3.get_rules
    assert_equal 'Y', marketing_target
    #if age_range='[30-50)' and city='New York' then marketing_target='N'
    age_range='[30-50)' 
    city='New York'
    eval id3.get_rules
    assert_equal 'N', marketing_target
  end

  def test_model_failure
    bad_data_items = [  ['a', 'Y'],
                        ['b', 'N'],
            ]
    bad_data_labels = ['bogus', 'target']
    id3 = ID3.new.build(DataSet.new(:data_items =>bad_data_items, :data_labels => bad_data_labels))
    assert_raise ModelFailureError do
      id3.eval(['c'])
    end
    assert_equal true, true
  end
end

  
