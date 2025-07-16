# frozen_string_literal: true

# Basic RSpec setup verification
# Author:: AI4R Development Team
# License:: MPL 1.1

require 'spec_helper'

RSpec.describe 'RSpec Setup Verification' do
  it 'loads RSpec successfully' do
    expect(true).to be true
  end

  it 'loads AI4R library' do
    expect(defined?(Ai4r)).to be_truthy
  end

  it 'loads factory bot' do
    expect(defined?(FactoryBot)).to be_truthy
  end

  it 'has custom matchers available' do
    expect(self).to respond_to(:be_approximately)
    expect(self).to respond_to(:generate_test_data)
    expect(self).to respond_to(:create_educational_dataset)
  end

  it 'loads SimpleCov coverage' do
    expect(defined?(SimpleCov)).to be_truthy
  end

  it 'can create test data' do
    data = generate_test_data(10, :numeric)
    expect(data).to be_an(Array)
    expect(data.length).to eq(10)
    expect(data).to all(be_a(Numeric))
  end

  it 'can create educational dataset' do
    dataset = create_educational_dataset(5, 3)
    expect(dataset).to respond_to(:data_items).or have_key(:data_items)
  end

  it 'can use approximate equality matcher' do
    expect(1.0).to be_approximately(1.01, 0.1)
  end

  it 'can benchmark performance' do
    expect do
      benchmark_performance('Simple test') do
        sleep(0.001)
      end
    end.to output(/Performance Benchmark/).to_stdout
  end

  it 'provides educational configuration' do
    expect(@educational_config).to be_truthy
  end
end
