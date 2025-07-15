require 'ai4r/classifiers/naive_bayes'
require 'ai4r/data/data_set'
require 'test/unit'

include Ai4r::Classifiers
include Ai4r::Data

class NaiveBayesTest < Test::Unit::TestCase

  @@data_labels = %w(Color Type Origin Stolen?)

  @@data_items = [
    %w(Red    Sports  Domestic Yes),
    %w(Red    Sports  Domestic No),
    %w(Red    Sports  Domestic Yes),
    %w(Yellow Sports  Domestic No),
    %w(Yellow Sports  Imported Yes),
    %w(Yellow SUV     Imported No),
    %w(Yellow SUV     Imported Yes),
    %w(Yellow Sports  Domestic No),
    %w(Red    SUV     Imported No),
    %w(Red    Sports  Imported Yes)
  ]

  def setup
    @data_set = DataSet.new
    @data_set = DataSet.new(:data_items => @@data_items, :data_labels => @@data_labels)
    @b = NaiveBayes.new.set_parameters({:m => 3}).build @data_set
  end

  def test_eval
    result = @b.eval(%w(Red SUV Domestic))
    assert_equal 'No', result
  end

  def test_get_probability_map
    map = @b.get_probability_map(%w(Red SUV Domestic))
    assert_equal 2, map.keys.length
    assert_in_delta 0.42, map['Yes'], 0.1
    assert_in_delta 0.58, map['No'], 0.1
  end

end
