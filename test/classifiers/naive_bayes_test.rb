require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/naive_bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'
require 'test/unit'

include Ai4r::Classifiers
include Ai4r::Data

class NaiveBayesTest < Test::Unit::TestCase

  @@data_labels = [ "Color","Type","Origin","Stolen?" ]

  @@data_items = [
              ["Red",   "Sports", "Domestic", "Yes"],
              ["Red",   "Sports", "Domestic", "No"],
              ["Red",   "Sports", "Domestic", "Yes"],
              ["Yellow","Sports", "Domestic", "No"],
              ["Yellow","Sports", "Imported", "Yes"],
              ["Yellow","SUV",    "Imported", "No"],
              ["Yellow","SUV",    "Imported", "Yes"],
              ["Yellow","Sports", "Domestic", "No"],
              ["Red",   "SUV",    "Imported", "No"],
              ["Red",   "Sports", "Imported", "Yes"]
            ]

  def setup
    @data_set = DataSet.new
    @data_set = DataSet.new(:data_items => @@data_items, :data_labels => @@data_labels)
    @b = NaiveBayes.new.set_parameters({:m=>3}).build @data_set
  end

  def test_eval
    result = @b.eval(["Red", "SUV", "Domestic"])
    assert_equal "No", result
  end

  def test_get_probability_map
    map = @b.get_probability_map(["Red", "SUV", "Domestic"])
    assert_equal 2, map.keys.length
    assert_in_delta 0.42, map["Yes"], 0.1
    assert_in_delta 0.58, map["No"], 0.1
  end

end