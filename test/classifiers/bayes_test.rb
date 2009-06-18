require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/bayes'
require File.dirname(__FILE__) + '/../../lib/ai4r/data/csv_data_set'
require 'test/unit'

include Ai4r::Classifiers
include Ai4r::Data

class BayesTest < Test::Unit::TestCase

  def test_known_attributes
    data = CsvDataSet.new
    data.load_csv_with_labels File.dirname(__FILE__) + "/bayes_data.csv"

    b = Bayes.new data, 3
    result = b.eval(["Red", "SUV", "Domestic"])
    assert_equal "No", result.first
    assert_in_delta 0.58, result[1], 0.01
  end

end