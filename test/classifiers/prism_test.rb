require 'test/unit'
require 'ai4r/classifiers/prism'


class PrismTest < Test::Unit::TestCase
  
  include Ai4r::Classifiers
  include Ai4r::Data

  @@data_examples = [   ['New York',  '<30',      'M', 'Y'],
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

  @@data_labels = [ 'city', 'age_range', 'gender', 'marketing_target'  ]
  
  def test_build
    assert_raise(ArgumentError) { Prism.new.build(DataSet.new) } 
    classifier = Prism.new.build(DataSet.new(:data_items=>@@data_examples))
    assert_not_nil(classifier.data_set.data_labels)
    assert_not_nil(classifier.rules)
    assert_equal("attribute_1", classifier.data_set.data_labels.first)
    assert_equal("class_value", classifier.data_set.category_label)
    classifier = Prism.new.build(DataSet.new(:data_items => @@data_examples, 
        :data_labels => @@data_labels))
    assert_not_nil(classifier.data_set.data_labels)
    assert_not_nil(classifier.rules)
    assert_equal("city", classifier.data_set.data_labels.first)
    assert_equal("marketing_target", classifier.data_set.category_label)
    assert !classifier.rules.empty?

    Prism.send(:public, *Prism.protected_instance_methods)
    Prism.send(:public, *Prism.private_instance_methods)
  end
  
  def test_eval
    classifier = Prism.new.build(DataSet.new(:data_items=>@@data_examples))
    @@data_examples.each do |data|
      assert_equal(data.last, classifier.eval(data[0...-1]))
    end
  end
  
  def test_get_rules
    classifier = Prism.new.build(DataSet.new(:data_items => @@data_examples, 
        :data_labels => @@data_labels))
    marketing_target = nil
    age_range = nil
    city = 'Chicago'
    eval(classifier.get_rules) 
    age_range = '<30'
    eval(classifier.get_rules) 
    assert_equal("Y", marketing_target)
    age_range = '[30-50)'
    eval(classifier.get_rules) 
    assert_equal("Y", marketing_target)
    age_range = '[30-50)'
    city = 'New York'
    eval(classifier.get_rules) 
    assert_equal("N", marketing_target)
    age_range = '[50-80]'
    eval(classifier.get_rules) 
    assert_equal("N", marketing_target)   
  end
    
  def test_matches_conditions
    classifier = Prism.new.build(DataSet.new(:data_labels => @@data_labels,
      :data_items => @@data_examples))

    assert classifier.matches_conditions(['New York', '<30', 'M', 'Y'], {"age_range" => "<30"})
    assert !classifier.matches_conditions(['New York', '<30', 'M', 'Y'], {"age_range" => "[50-80]"})
  end
end

