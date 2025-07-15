# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/classifier/classifier_bench'

class ClassifierBenchTest < Minitest::Test
  include Bench::Classifier::Runners

  DATA_PATH = File.expand_path('../../bench/classifier/datasets/play_tennis.csv', __dir__)

  def setup
    data = Bench::Classifier.load_dataset(DATA_PATH)
    @train, @test = data.split(ratio: 0.7)
  end

  def test_runners
    runners = {
      id3: Id3Runner,
      naive_bayes: NaiveBayesRunner,
      ib1: Ib1Runner,
      hyperpipes: HyperpipesRunner
    }

    results = runners.map { |_, klass| klass.new(@train, @test).call }

    results.each do |r|
      assert r[:accuracy] >= 0.5
    end
  end
end
