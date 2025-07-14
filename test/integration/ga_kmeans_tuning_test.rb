# frozen_string_literal: true

require_relative '../test_helper'
require 'ai4r/clusterers/k_means'
require 'ai4r/data/data_set'

class GaKmeansTuningTest < Minitest::Test
  include Ai4r::Clusterers
  include Ai4r::Data

  SCRIPT = File.expand_path('../../examples/genetic_algorithm/kmeans_seed_tuning.rb', __dir__)

  def test_cli_improves_sse
    load File.expand_path('../../examples/som/som_data.rb', __dir__)
    data = DataSet.new(data_items: SOM_DATA.first(30))
    baseline = KMeans.new.set_parameters(random_seed: 10).build(data, 3).sse
    improved = `ruby #{SCRIPT}`.to_f
    assert improved < baseline * 0.8
  end
end
