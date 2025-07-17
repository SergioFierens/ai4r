# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../bench/clusterer/cluster_bench'

class ClustererLoadDatasetTest < Minitest::Test
  def test_load_dataset_with_and_without_labels
    Tempfile.create(['data', '.csv']) do |f|
      f.write("1,2,3\n4,5,6\n")
      f.close
      ds_with = Bench::Clusterer.load_dataset(f.path, true)
      ds_without = Bench::Clusterer.load_dataset(f.path, false)

      assert_equal [[1.0, 2.0], [4.0, 5.0]], ds_with.data_items
      assert_equal [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]], ds_without.data_items
    end
  end
end
