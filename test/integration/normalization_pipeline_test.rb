# frozen_string_literal: true

require_relative '../test_helper'
require 'ai4r'

class NormalizationPipelineTest < Minitest::Test
  include Ai4r::Data
  include Ai4r::Clusterers
  include Ai4r::Classifiers

  DATA_FILE = File.expand_path('../../examples/classifiers/hyperpipes_data.csv', __dir__)

  def setup
    raw = DataSet.new.parse_csv_with_labels(DATA_FILE)
    @feature_set = DataSet.new(
      data_items: raw.data_items.map { |r| r[0..-2] },
      data_labels: raw.data_labels[0..-2]
    )
  end

  def test_normalization_with_clusterer_and_classifier
    original = Marshal.load(Marshal.dump(@feature_set.data_items))
    norm = DataSet.normalized(@feature_set, method: :minmax)
    assert_equal original, @feature_set.data_items

    kmeans = KMeans.new.set_parameters(random_seed: 1).build(norm, 2)
    assert_equal 2, kmeans.clusters.length

    labeled = norm.data_items.map { |row| row + [kmeans.eval(row)] }
    labels = norm.data_labels + ['cluster']
    classifier = ID3.new.build(DataSet.new(data_items: labeled, data_labels: labels))

    sample = norm.data_items.first
    assert_equal kmeans.eval(sample), classifier.eval(sample)
  end
end
