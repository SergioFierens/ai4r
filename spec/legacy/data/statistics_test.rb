# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'test/unit'
require 'ai4r/data/statistics'

module Ai4r
  module Data
    class StatisticsTest < Test::Unit::TestCase
      
      DELTA = 0.00001
      
      def setup
        @data_set = DataSet.new.
          parse_csv "#{File.dirname(__FILE__)}/statistics_data_set.csv"
      end
    
      def test_mean
          assert_equal 2, Statistics.mean(@data_set, 1)
          assert_equal 2.502, Statistics.mean(@data_set, 0)
      end
      
      def test_variance
          assert_equal 0, Statistics.variance(@data_set, 1)
          assert_in_delta 4.47302, Statistics.variance(@data_set, 0), DELTA
      end
 
     def test_standard_deviation
          assert_equal 0, Statistics.standard_deviation(@data_set, 1)
          assert_in_delta 2.11495, Statistics.standard_deviation(@data_set, 0), DELTA
      end
 
      def test_mode
        items = [ [ "New York", 25, "Y"],
                  [ "New York", 55, "Y"],
                  [ "Chicago", 23, "Y"],
                  [ "Boston", 23, "N"],
                  [ "Chicago", 12, "N"],
                  [ "Chicago", 87, "Y"] ]
        set = DataSet.new.set_data_items(items)
        assert_equal "Chicago", Statistics.mode(set,0)
        assert_equal 23, Statistics.mode(set,1)
        assert_equal "Y", Statistics.mode(set,2)
      end

      def test_min
          assert_equal 2, Statistics.min(@data_set, 1)
          assert_equal 1, Statistics.min(@data_set, 0)
      end
      
      def test_max
          assert_equal 2, Statistics.max(@data_set, 1)
          assert_equal 6, Statistics.max(@data_set, 0)
          assert_equal 3.7, Statistics.max(@data_set, 2)
      end      
      
    end
  end
end
