require 'test/unit'
require 'ai4r/classifiers/multilayer_perceptron'
require 'ai4r/data/data_set'

# Make all accessors and methods public
class Ai4r::Classifiers::MultilayerPerceptron
  attr_accessor :data_set, :class_value, :network, :domains, :outputs
  public :get_max_index
  public :data_to_output
end

class MultilayerPerceptronTest < Test::Unit::TestCase
  
  include Ai4r::Classifiers
  include Ai4r::Data
  
  @@data_set = DataSet.new(:data_items =>[   ['New York',  '<30',      'M', 'Y'],
                ['Chicago',     '<30',      'M', 'Y'],
                ['New York',  '<30',      'M', 'Y'],
                ['New York',  '[30-50)',  'F', 'N'],
                ['Chicago',     '[30-50)',  'F', 'Y'],
                ['New York',  '[30-50)',  'F', 'N'],
                ['Chicago',     '[50-80]', 'M', 'N'],
              ])

  def test_initialize
    classifier = MultilayerPerceptron.new
    assert_equal 1, classifier.active_node_value
    assert_equal 0, classifier.inactive_node_value
    assert_equal Ai4r::NeuralNetwork::Backpropagation, classifier.network_class
    assert_equal [], classifier.hidden_layers
    assert classifier.network_parameters
    assert classifier.network_parameters.empty?
    assert classifier.training_iterations > 1
  end
  
  def test_build
    assert_raise(ArgumentError) { MultilayerPerceptron.new.build(DataSet.new) }
    classifier = MultilayerPerceptron.new
    classifier.training_iterations = 1
    classifier.build(@@data_set)
    assert_equal [7,2], classifier.network.structure
    classifier.hidden_layers = [6, 4]
    classifier.build(@@data_set)  
    assert_equal [7,6,4,2], classifier.network.structure    
  end
  
  def test_eval
    classifier = MultilayerPerceptron.new.build(@@data_set)
    assert classifier
    assert_equal('N', classifier.eval(['Chicago', '[50-80]', 'M']))
    assert_equal('N', classifier.eval(['New York', '[30-50)', 'F']))
    assert_equal('Y', classifier.eval(['New York', '<30', 'M']))
    assert_equal('Y', classifier.eval(['Chicago',  '[30-50)', 'F']))    
  end
  
  def test_get_rules
    assert_match(/raise/, MultilayerPerceptron.new.get_rules)
  end
  
  def test_get_max_index
    classifier = MultilayerPerceptron.new
    assert_equal(0, classifier.get_max_index([3, 1, 0.2, -9, 0, 2.99]))
    assert_equal(2, classifier.get_max_index([3, 1, 5, -9, 0, 2.99]))
    assert_equal(5, classifier.get_max_index([3, 1, 5, -9, 0, 6]))
  end
  
  def test_data_to_output
    classifier = MultilayerPerceptron.new
    classifier.outputs = 4
    classifier.outputs = 4
    classifier.domains = [nil, nil, nil, ["A", "B", "C", "D"]]
    assert_equal([1,0,0,0], classifier.data_to_output("A"))
    assert_equal([0,0,1,0], classifier.data_to_output("C"))
    assert_equal([0,0,0,1], classifier.data_to_output("D"))
  end
  
end

