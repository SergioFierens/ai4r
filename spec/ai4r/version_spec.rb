# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/version'

RSpec.describe 'Ai4r::VERSION' do
  it 'has a version number' do
    expect(Ai4r::VERSION).not_to be_nil
  end

  it 'has a valid semantic version format' do
    expect(Ai4r::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it 'returns the current version' do
    expect(Ai4r::VERSION).to eq('2.0.0')
  end
end