# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/classifier/classifier_bench'

class ClassifierBenchTest < Minitest::Test
  include Bench::Classifier::Runners

  DATA_PATH = File.expand_path('../../bench/classifier/datasets/play_tennis.csv', __dir__)

  def setup
    @data = Bench::Classifier.load_dataset(DATA_PATH)
  end

  def test_runners_accuracy
    {
      id3: Id3Runner,
      naive_bayes: NaiveBayesRunner,
      ib1: Ib1Runner,
      hyperpipes: HyperpipesRunner
    }.each_value do |klass|
      result = klass.new(@data, @data).call
      assert result[:accuracy] >= 0.6, "#{klass} accuracy too low"
    end
  end
end
