# frozen_string_literal: true

require 'yaml'
require 'ai4r/data/data_set'

module FixtureLoader
  FIXTURE_DIR = File.expand_path('../fixtures/nn', __dir__)

  def load_fixture(id)
    fname = format('fi%02d', id.to_i)
    path = Dir[File.join(FIXTURE_DIR, "#{fname}*_*.yml")].first
    raise "Fixture not found: #{id}" unless path

    data = YAML.safe_load_file(path)
    srand(1234) if data['weight_init'] == 'fixed_seed'
    dataset = Ai4r::Data::DataSet.new(data_items: data['dataset'])
    params = data.except('dataset')
    [dataset, params]
  end
end
