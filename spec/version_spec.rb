# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/version'

RSpec.describe 'Ai4r::VERSION' do
  it 'has a version number' do
    expect(Ai4r::VERSION).not_to be nil
  end

  it 'is a string' do
    expect(Ai4r::VERSION).to be_a(String)
  end

  it 'follows semantic versioning format' do
    expect(Ai4r::VERSION).to match(/^\d+\.\d+\.\d+/)
  end

  it 'is 2.0.0' do
    expect(Ai4r::VERSION).to eq('2.0.0')
  end
end