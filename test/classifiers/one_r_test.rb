require 'test/unit'
require 'ai4r/classifiers/one_r'

class OneRTest < Test::Unit::TestCase
  
  include Ai4r::Classifiers
  include Ai4r::Data
  
  @@data_examples = [   ['New York',  '<30',      'M', 'Y'],
                ['Chicago',     '<30',      'M', 'Y'],
                ['New York',  '<30',      'M', 'Y'],
                ['New York',  '[30-50)',  'F', 'N'],
                ['Chicago',     '[30-50)',  'F', 'Y'],
                ['New York',  '[30-50)',  'F', 'N'],
                ['Chicago',     '[50-80]', 'M', 'N']
              ]

  @@data_labels = [ 'city', 'age_range', 'gender', 'marketing_target'  ]
  
  def test_build
    assert_raise(ArgumentError) { OneR.new.build(DataSet.new) } 
    classifier = OneR.new.build(DataSet.new(:data_items => @@data_examples))
    assert_not_nil(classifier.data_set.data_labels)
    assert_not_nil(classifier.rule)
    assert_equal("attribute_1", classifier.data_set.data_labels.first)
    assert_equal("class_value", classifier.data_set.category_label)
    classifier = OneR.new.build(DataSet.new(:data_items => @@data_examples,
      :data_labels => @@data_labels))
    assert_not_nil(classifier.data_set.data_labels)
    assert_not_nil(classifier.rule)
    assert_equal("city", classifier.data_set.data_labels.first)
    assert_equal("marketing_target", classifier.data_set.category_label)
    assert_equal(1, classifier.rule[:attr_index])
  end
  
  def test_eval
    classifier = OneR.new.build(DataSet.new(:data_items => @@data_examples))
    assert_equal("Y", classifier.eval(['New York',  '<30',      'M']))
    assert_equal("N", classifier.eval(['New York',  '[30-50)',      'M']))
    assert_equal("N", classifier.eval(['Chicago',  '[50-80]',      'M']))
  end
  
  def test_get_rules
    classifier = OneR.new.build(DataSet.new(:data_items => @@data_examples,
      :data_labels => @@data_labels))
    marketing_target = nil
    age_range = nil
    eval(classifier.get_rules) 
    assert_nil(marketing_target)
    age_range = '<30'
    eval(classifier.get_rules) 
    assert_equal("Y", marketing_target)
    age_range = '[30-50)'
    eval(classifier.get_rules) 
    assert_equal("N", marketing_target)
    age_range = '[50-80]'
    eval(classifier.get_rules) 
    assert_equal("N", marketing_target)    
  end

  def test_selected_attribute
    classifier = OneR.new.set_parameters({:selected_attribute => 0}).build(
      DataSet.new(:data_items => @@data_examples, :data_labels => @@data_labels))
    assert_equal(0, classifier.rule[:attr_index])
  end

  def test_tie_break
    tie_examples = [
      ['A', 'X', 'foo', 'Y'],
      ['B', 'X', 'foo', 'Y'],
      ['A', 'Y', 'foo', 'Y'],
      ['B', 'Y', 'foo', 'N']
    ]
    labels = ['att0', 'att1', 'att2', 'class']
    ds = DataSet.new(:data_items => tie_examples, :data_labels => labels)
    c_first = OneR.new.build(ds)
    assert_equal(0, c_first.rule[:attr_index])
    c_last = OneR.new.set_parameters({:tie_break => :last}).build(ds)
    assert_equal(1, c_last.rule[:attr_index])
  end
  
end

