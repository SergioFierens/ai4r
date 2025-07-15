# frozen_string_literal: true

require_relative '../../lib/ai4r/classifiers/naive_bayes'
require_relative '../../lib/ai4r/data/data_set'
require_relative '../../lib/ai4r/classifiers/id3'
require 'benchmark'

data_set = Ai4r::Data::DataSet.new
data_set.load_csv_with_labels "#{File.dirname(__FILE__)}/naive_bayes_data.csv"

b = Ai4r::Classifiers::NaiveBayes.new
                                 .set_parameters({ m: 3 })
                                 .build data_set
p b.eval(%w[Red SUV Domestic])
p b.get_probability_map(%w[Red SUV Domestic])
