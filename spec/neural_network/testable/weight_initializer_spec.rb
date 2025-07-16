# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/weight_initializer'

RSpec.describe Ai4r::NeuralNetwork::Testable::WeightInitializer do
  describe 'Random initializer' do
    let(:random_init) { described_class::Random.new(seed: 42) }
    
    it 'generates values in correct range' do
      100.times do
        value = random_init.initialize_weight(10, 5)
        expect(value).to be_between(-1.0, 1.0)
      end
    end

    it 'uses custom range when specified' do
      custom_init = described_class::Random.new(min: -0.5, max: 0.5)
      100.times do
        value = custom_init.initialize_weight(10, 5)
        expect(value).to be_between(-0.5, 0.5)
      end
    end

    it 'produces deterministic results with seed' do
      init1 = described_class::Random.new(seed: 123)
      init2 = described_class::Random.new(seed: 123)
      
      values1 = Array.new(10) { init1.initialize_weight(5, 3) }
      values2 = Array.new(10) { init2.initialize_weight(5, 3) }
      
      expect(values1).to eq(values2)
    end

    it 'produces different results without seed' do
      init1 = described_class::Random.new
      init2 = described_class::Random.new
      
      values1 = Array.new(10) { init1.initialize_weight(5, 3) }
      values2 = Array.new(10) { init2.initialize_weight(5, 3) }
      
      expect(values1).not_to eq(values2)
    end
  end

  describe 'Xavier/Glorot initializer' do
    let(:xavier_init) { described_class::Xavier.new }
    
    it 'scales based on fan-in and fan-out' do
      # For Xavier, std = sqrt(2 / (fan_in + fan_out))
      values = Array.new(1000) { xavier_init.initialize_weight(3, 2) }
      
      expected_std = Math.sqrt(2.0 / (3 + 2))
      actual_std = Math.sqrt(values.map { |v| v ** 2 }.sum / values.size)
      
      expect(actual_std).to be_within(0.1).of(expected_std)
    end

    it 'produces smaller values for larger layers' do
      small_layer_values = Array.new(100) { xavier_init.initialize_weight(2, 2).abs }
      large_layer_values = Array.new(100) { xavier_init.initialize_weight(100, 100).abs }
      
      expect(small_layer_values.sum / 100).to be > (large_layer_values.sum / 100)
    end
  end

  describe 'He initializer' do
    let(:he_init) { described_class::He.new }
    
    it 'scales based on fan-in' do
      # For He, std = sqrt(2 / fan_in)
      values = Array.new(1000) { he_init.initialize_weight(4, 2) }
      
      expected_std = Math.sqrt(2.0 / 4)
      actual_std = Math.sqrt(values.map { |v| v ** 2 }.sum / values.size)
      
      expect(actual_std).to be_within(0.1).of(expected_std)
    end

    it 'is optimized for ReLU networks' do
      # He initialization should produce larger values than Xavier for same layer size
      he_values = Array.new(100) { he_init.initialize_weight(10, 10).abs }
      xavier_values = Array.new(100) { described_class::Xavier.new.initialize_weight(10, 10).abs }
      
      expect(he_values.sum / 100).to be > (xavier_values.sum / 100)
    end
  end

  describe 'Fixed initializer' do
    let(:fixed_init) { described_class::Fixed.new(value: 0.5) }
    
    it 'always returns the same value' do
      100.times do
        expect(fixed_init.initialize_weight(10, 5)).to eq(0.5)
      end
    end

    it 'ignores fan-in and fan-out' do
      expect(fixed_init.initialize_weight(1, 1)).to eq(0.5)
      expect(fixed_init.initialize_weight(100, 100)).to eq(0.5)
    end

    it 'is useful for testing' do
      # Can create networks with known weights
      zero_init = described_class::Fixed.new(value: 0.0)
      one_init = described_class::Fixed.new(value: 1.0)
      
      expect(zero_init.initialize_weight(5, 5)).to eq(0.0)
      expect(one_init.initialize_weight(5, 5)).to eq(1.0)
    end
  end

  describe 'Custom initializer' do
    it 'allows custom initialization logic' do
      # Example: Initialize based on layer position
      position_based = described_class::Custom.new do |fan_in, fan_out|
        (fan_in - fan_out).to_f / (fan_in + fan_out)
      end
      
      expect(position_based.initialize_weight(10, 5)).to eq(1.0/3.0)
      expect(position_based.initialize_weight(5, 10)).to eq(-1.0/3.0)
    end

    it 'can implement complex strategies' do
      # Example: Different initialization for different layer sizes
      adaptive = described_class::Custom.new do |fan_in, fan_out|
        if fan_in < 10
          0.1  # Small weights for small layers
        elsif fan_in > 100
          0.001  # Very small weights for large layers
        else
          0.01  # Medium weights otherwise
        end
      end
      
      expect(adaptive.initialize_weight(5, 5)).to eq(0.1)
      expect(adaptive.initialize_weight(50, 50)).to eq(0.01)
      expect(adaptive.initialize_weight(200, 200)).to eq(0.001)
    end
  end

  describe 'Initialize matrix' do
    it 'creates correct matrix dimensions' do
      initializer = described_class::Fixed.new(value: 0.5)
      matrix = initializer.initialize_matrix(3, 4, 2)
      
      expect(matrix.size).to eq(3)
      expect(matrix[0].size).to eq(4)
      expect(matrix.flatten.all? { |v| v == 0.5 }).to be true
    end

    it 'uses fan-in and fan-out correctly' do
      xavier = described_class::Xavier.new
      matrix = xavier.initialize_matrix(2, 3, 4)
      
      # Each weight should be initialized with fan_in=2, fan_out=4
      expect(matrix.size).to eq(2)
      expect(matrix[0].size).to eq(3)
    end
  end

  describe 'Comparison of initializers' do
    let(:layer_sizes) { [[2, 10], [10, 50], [50, 100], [100, 10], [10, 1]] }
    
    it 'different initializers produce different distributions' do
      initializers = {
        random: described_class::Random.new,
        xavier: described_class::Xavier.new,
        he: described_class::He.new,
        fixed: described_class::Fixed.new(value: 0.1)
      }
      
      results = {}
      initializers.each do |name, init|
        values = []
        layer_sizes.each do |fan_in, fan_out|
          100.times { values << init.initialize_weight(fan_in, fan_out) }
        end
        
        results[name] = {
          mean: values.sum / values.size,
          std: Math.sqrt(values.map { |v| (v - results.dig(name, :mean) || 0) ** 2 }.sum / values.size),
          min: values.min,
          max: values.max
        }
      end
      
      # Fixed should have no variance
      expect(results[:fixed][:std]).to eq(0)
      
      # He should have larger variance than Xavier
      expect(results[:he][:std]).to be > results[:xavier][:std]
      
      # Random should be bounded
      expect(results[:random][:min]).to be >= -1.0
      expect(results[:random][:max]).to be <= 1.0
    end
  end
end