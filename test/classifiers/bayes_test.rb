require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/data_set'
require 'test/unit'

include Ai4r::Classifiers
include Ai4r::Data

class BayesTest < Test::Unit::TestCase

  def setup
    @data_set = DataSet.new
    @data_set.load_csv_with_labels File.dirname(__FILE__) + "/bayes_data.csv"
    @b = Bayes.new.set_parameters({:m=>3}).build @data_set
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