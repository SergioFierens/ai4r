require 'ai4r/classifiers/simple_linear_regression'
require 'ai4r/data/data_set'
require 'test/unit'

include Ai4r::Classifiers
include Ai4r::Data

class SimpleLinearRegressionTest < Test::Unit::TestCase

  @@data_labels = ["symboling", "normalized-losses", "wheel-base", "length", "width", "height", "curb-weight",
                   "engine-size", "bore" , "stroke", "compression-ratio", "horsepower", "peak-rpm", "city-mpg",
                   "highway-mpg", "class"]

  @@data_items = [
      [2,164,99.8,176.6,66.2,54.3,2337,109,3.19,3.4,10,102,5500,24,30,13950],
      [2,164,99.4,176.6,66.4,54.3,2824,136,3.19,3.4,8,115,5500,18,22,17450],
      [1,158,105.8,192.7,71.4,55.7,2844,136,3.19,3.4,8.5,110,5500,19,25,17710],
      [1,158,105.8,192.7,71.4,55.9,3086,131,3.13,3.4,8.3,140,5500,17,20,23875],
      [2,192,101.2,176.8,64.8,54.3,2395,108,3.5,2.8,8.8,101,5800,23,29,16430],
      [0,192,101.2,176.8,64.8,54.3,2395,108,3.5,2.8,8.8,101,5800,23,29,16925],
      [0,188,101.2,176.8,64.8,54.3,2710,164,3.31,3.19,9,121,4250,21,28,20970],
      [0,188,101.2,176.8,64.8,54.3,2765,164,3.31,3.19,9,121,4250,21,28,21105],
      [2,121,88.4,141.1,60.3,53.2,1488,61,2.91,3.03,9.5,48,5100,47,53,5151],
  ]

  def setup
    @data_set = DataSet.new
    @data_set = DataSet.new(:data_items => @@data_items, :data_labels => @@data_labels)
    @c = SimpleLinearRegression.new.build @data_set
  end

  def test_eval
    result = @c.eval([-1,95,109.1,188.8,68.9,55.5,3062,141,3.78,3.15,9.5,114,5400,19,25])
    assert_equal 17218.444444444445, result
  end

end