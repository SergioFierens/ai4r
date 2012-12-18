require 'test/unit'
require 'ai4r/classifiers/zero_r'
require 'ai4r/data/data_set'

class ZeroRTest < Test::Unit::TestCase
  
  include Ai4r::Classifiers
  include Ai4r::Data

  @@data_examples = [
          ['New York',  '[30-50)',  'F', 'N'],
          ['New York',  '<30',      'M', 'Y'],
          ['Chicago',     '<30',      'M', 'Y'],
          ['New York',  '<30',      'M', 'Y'],
          ['Chicago',     '[30-50)',  'F', 'Y'],
          ['New York',  '[30-50)',  'F', 'N'],
          ['Chicago',     '[50-80]', 'M', 'N'],
  ]

  @@data_labels = [ 'city', 'age_range', 'gender', 'marketing_target'  ]
  
  def test_build
    assert_raise(ArgumentError) { ZeroR.new.build(DataSet.new) } 
    classifier = ZeroR.new.build(DataSet.new(:data_items => @@data_examples))
    assert_equal("Y", classifier.class_value)
    assert_equal("attribute_1", classifier.data_set.data_labels.first)
    assert_equal("class_value", classifier.data_set.category_label)
    classifier = ZeroR.new.build(DataSet.new(:data_items => @@data_examples, 
        :data_labels => @@data_labels))
    assert_equal("Y", classifier.class_value)
    assert_equal("city", classifier.data_set.data_labels.first)
    assert_equal("marketing_target", classifier.data_set.category_label)
  end
  
  def test_eval
    classifier = ZeroR.new.build(DataSet.new(:data_items => @@data_examples))
    assert_equal('Y', classifier.eval(@@data_examples.first) )
    assert_equal('Y', classifier.eval(@@data_examples.last) )
  end
  
  def test_get_rules
    classifier = ZeroR.new.build(DataSet.new(:data_items => @@data_examples,
      :data_labels => @@data_labels))
    marketing_target = nil
    eval(classifier.get_rules) 
    assert_equal('Y', marketing_target)
  end
  
end

