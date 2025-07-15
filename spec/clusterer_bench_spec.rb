require 'ai4r'
require_relative '../bench/clusterer/cluster_bench'

RSpec.describe 'Clusterer runners' do
  DATASET = File.expand_path('../bench/clusterer/datasets/blobs.csv', __dir__)

  let(:data_set) do
    ds = Ai4r::Data::DataSet.new
    ds.load_csv(DATASET, parse_numeric: true)
    ds
  end
  let(:k) { 3 }

  it 'runs kmeans' do
    runner = Bench::Clusterer::Runners::KmeansRunner.new(data_set, k)
    result = runner.call
    expect(result[:silhouette]).to be_between(-1.0, 1.0)
    expect(result[:clusters].size).to eq(k)
  end

  it 'runs single linkage' do
    runner = Bench::Clusterer::Runners::SingleLinkageRunner.new(data_set, k)
    result = runner.call
    expect(result[:silhouette]).to be_between(-1.0, 1.0)
  end

  it 'runs average linkage' do
    runner = Bench::Clusterer::Runners::AverageLinkageRunner.new(data_set, k)
    result = runner.call
    expect(result[:silhouette]).to be_between(-1.0, 1.0)
  end

  it 'runs diana' do
    runner = Bench::Clusterer::Runners::DianaRunner.new(data_set, k)
    result = runner.call
    expect(result[:silhouette]).to be_between(-1.0, 1.0)
  end
end
