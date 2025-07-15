# frozen_string_literal: true

require 'ai4r/classifiers/random_forest'
require 'ai4r/data/data_set'
require_relative '../test_helper'

include Ai4r::Classifiers
include Ai4r::Data

class RandomForestTest < Minitest::Test
  DATA_LABELS = %w[city age_range gender marketing_target].freeze
  DATA_ITEMS = [
    ['New York', '<30', 'M', 'Y'],
    ['Chicago', '<30', 'M', 'Y'],
    ['Chicago', '<30', 'F', 'Y'],
    ['New York', '<30', 'M', 'Y'],
    ['New York', '<30', 'M', 'Y'],
    ['Chicago', '[30-50)', 'M', 'Y'],
    ['New York', '[30-50)', 'F', 'N'],
    ['Chicago', '[30-50)', 'F', 'Y'],
    ['New York', '[30-50)', 'F', 'N'],
    ['Chicago', '[50-80]', 'M', 'N'],
    ['New York', '[50-80]', 'F', 'N'],
    ['New York', '[50-80]', 'M', 'N'],
    ['Chicago', '[50-80]', 'M', 'N'],
    ['New York', '[50-80]', 'F', 'N'],
    ['Chicago', '>80', 'F', 'Y']
  ].freeze

  def setup
    ds = DataSet.new(data_items: DATA_ITEMS, data_labels: DATA_LABELS)
    @forest = RandomForest.new.set_parameters(n_trees: 3, random_seed: 1).build(ds)
  end

  def test_eval
    result = @forest.eval(['New York', '<30', 'F'])
    assert_equal 'Y', result
  end
end
