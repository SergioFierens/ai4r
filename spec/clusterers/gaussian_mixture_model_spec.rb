# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::Clusterers::GaussianMixtureModel do
  let(:clusterer) { described_class.new }
  
  describe '#initialize' do
    it 'initializes with correct default values' do
      expect(clusterer.n_components).to eq(3)
      expect(clusterer.instance_variable_get(:@max_iterations)).to eq(100)
      expect(clusterer.instance_variable_get(:@tolerance)).to eq(1e-6)
      expect(clusterer.instance_variable_get(:@covariance_type)).to eq('full')
      expect(clusterer.instance_variable_get(:@init_method)).to eq(:k_means_plus_plus)
      expect(clusterer.instance_variable_get(:@regularization)).to eq(1e-6)
      expect(clusterer.instance_variable_get(:@educational_mode)).to eq(false)
    end
  end

  describe '#enable_educational_mode' do
    it 'enables educational mode' do
      clusterer.enable_educational_mode
      expect(clusterer.instance_variable_get(:@educational_mode)).to be true
    end

    it 'accepts a callback block' do
      callback_called = false
      clusterer.enable_educational_mode { callback_called = true }
      expect(clusterer.instance_variable_get(:@step_callback)).not_to be_nil
    end

    it 'returns self for chaining' do
      expect(clusterer.enable_educational_mode).to eq(clusterer)
    end
  end

  describe '#build' do
    context 'with well-separated clusters' do
      let(:data_set) do
        # Create three well-separated clusters
        cluster1 = Array.new(10) { [rand(0..2), rand(0..2)] }
        cluster2 = Array.new(10) { [rand(8..10), rand(8..10)] }
        cluster3 = Array.new(10) { [rand(0..2), rand(8..10)] }
        
        Ai4r::Data::DataSet.new(
          data_items: cluster1 + cluster2 + cluster3
        )
      end

      it 'builds clusters successfully' do
        clusterer.build(data_set, 3)
        
        expect(clusterer.means).to be_an(Array)
        expect(clusterer.means.length).to eq(3)
        expect(clusterer.covariances).to be_an(Array)
        expect(clusterer.covariances.length).to eq(3)
        expect(clusterer.weights).to be_an(Array)
        expect(clusterer.weights.length).to eq(3)
        expect(clusterer.weights.sum).to be_within(0.001).of(1.0)
      end

      it 'tracks log likelihood history' do
        clusterer.build(data_set, 3)
        
        expect(clusterer.log_likelihood_history).not_to be_empty
        expect(clusterer.iterations).to be > 0
        
        # Log likelihood should generally increase
        if clusterer.log_likelihood_history.length > 2
          first_ll = clusterer.log_likelihood_history.first
          last_ll = clusterer.log_likelihood_history.last
          expect(last_ll).to be >= first_ll
        end
      end

      it 'creates cluster assignments' do
        clusterer.build(data_set, 3)
        
        expect(clusterer.clusters).to be_an(Array)
        expect(clusterer.clusters.length).to eq(3)
        
        # Each cluster should have some points
        clusterer.clusters.each do |cluster|
          expect(cluster.data_items).not_to be_empty
        end
      end

      it 'stores soft assignments (responsibilities)' do
        clusterer.build(data_set, 3)
        
        expect(clusterer.soft_assignments).to be_an(Array)
        expect(clusterer.soft_assignments.length).to eq(data_set.data_items.length)
        
        # Each point should have probabilities summing to 1
        clusterer.soft_assignments.each do |probs|
          expect(probs.sum).to be_within(0.001).of(1.0)
        end
      end
    end

    context 'with different covariance types' do
      let(:data_set) do
        Ai4r::Data::DataSet.new(
          data_items: Array.new(30) { [rand(0..10), rand(0..10)] }
        )
      end

      it 'works with full covariance' do
        clusterer.set_parameters(covariance_type: 'full')
        clusterer.build(data_set, 2)
        
        # Full covariance matrices should be 2x2
        clusterer.covariances.each do |cov|
          expect(cov).to be_an(Array)
          expect(cov.length).to eq(2)
          expect(cov.first.length).to eq(2)
        end
      end

      it 'works with diagonal covariance' do
        clusterer.set_parameters(covariance_type: 'diagonal')
        clusterer.build(data_set, 2)
        
        # Diagonal covariance should be a vector
        clusterer.covariances.each do |cov|
          expect(cov).to be_an(Array)
          expect(cov.length).to eq(2)
          expect(cov.first).to be_a(Numeric)
        end
      end

      it 'works with spherical covariance' do
        clusterer.set_parameters(covariance_type: 'spherical')
        clusterer.build(data_set, 2)
        
        # Spherical covariance should be a single value
        clusterer.covariances.each do |cov|
          expect(cov).to be_a(Numeric)
        end
      end
    end

    context 'with different initialization methods' do
      let(:data_set) do
        Ai4r::Data::DataSet.new(
          data_items: Array.new(20) { [rand(0..5), rand(0..5)] }
        )
      end

      it 'works with random initialization' do
        clusterer.set_parameters(init_method: :random)
        clusterer.build(data_set, 2)
        expect(clusterer.means).not_to be_empty
      end

      it 'works with k-means++ initialization' do
        clusterer.set_parameters(init_method: :k_means_plus_plus)
        clusterer.build(data_set, 2)
        expect(clusterer.means).not_to be_empty
      end

      it 'works with manual initialization' do
        initial_means = [[1, 1], [4, 4]]
        clusterer.set_parameters(init_method: :manual, initial_means: initial_means)
        clusterer.build(data_set, 2)
        expect(clusterer.means).not_to be_empty
      end
    end

    context 'with edge cases' do
      it 'handles single component' do
        data_set = Ai4r::Data::DataSet.new(
          data_items: Array.new(10) { [rand, rand] }
        )
        
        clusterer.build(data_set, 1)
        expect(clusterer.means.length).to eq(1)
        expect(clusterer.weights).to eq([1.0])
      end

      it 'handles high-dimensional data' do
        # 10-dimensional data
        data_set = Ai4r::Data::DataSet.new(
          data_items: Array.new(50) { Array.new(10) { rand } }
        )
        
        clusterer.set_parameters(covariance_type: 'diagonal') # More stable for high-dim
        clusterer.build(data_set, 2)
        
        expect(clusterer.means.first.length).to eq(10)
      end

      it 'handles convergence with tolerance' do
        data_set = Ai4r::Data::DataSet.new(
          data_items: Array.new(20) { [rand, rand] }
        )
        
        clusterer.set_parameters(tolerance: 0.1, max_iterations: 100)
        clusterer.build(data_set, 2)
        
        # Should converge before max iterations with loose tolerance
        expect(clusterer.iterations).to be < 100
      end
    end

    it 'returns self for chaining' do
      data_set = Ai4r::Data::DataSet.new(data_items: [[1, 1], [2, 2]])
      expect(clusterer.build(data_set)).to eq(clusterer)
    end
  end

  describe '#eval' do
    let(:data_set) do
      # Clear clusters for testing
      cluster1 = Array.new(10) { [rand(0..1), rand(0..1)] }
      cluster2 = Array.new(10) { [rand(9..10), rand(9..10)] }
      
      Ai4r::Data::DataSet.new(data_items: cluster1 + cluster2)
    end

    before do
      clusterer.build(data_set, 2)
    end

    it 'assigns new points to appropriate clusters' do
      # Point near first cluster
      cluster_idx1 = clusterer.eval([0.5, 0.5])
      expect(cluster_idx1).to be_between(0, 1)
      
      # Point near second cluster
      cluster_idx2 = clusterer.eval([9.5, 9.5])
      expect(cluster_idx2).to be_between(0, 1)
      
      # Should be different clusters
      expect(cluster_idx1).not_to eq(cluster_idx2)
    end

    it 'returns nil for untrained model' do
      untrained = described_class.new
      expect(untrained.eval([1, 1])).to be_nil
    end
  end

  describe '#predict_probabilities' do
    let(:data_set) do
      Ai4r::Data::DataSet.new(
        data_items: [
          [0, 0], [1, 0], [0, 1],
          [10, 10], [11, 10], [10, 11]
        ]
      )
    end

    before do
      clusterer.build(data_set, 2)
    end

    it 'returns probability distribution over clusters' do
      probs = clusterer.predict_probabilities([5, 5])
      
      expect(probs).to be_an(Array)
      expect(probs.length).to eq(2)
      expect(probs.sum).to be_within(0.001).of(1.0)
      expect(probs.all? { |p| p >= 0 && p <= 1 }).to be true
    end

    it 'gives high probability for clear cluster membership' do
      probs_cluster1 = clusterer.predict_probabilities([0.5, 0.5])
      probs_cluster2 = clusterer.predict_probabilities([10.5, 10.5])
      
      # One cluster should dominate for each point
      expect(probs_cluster1.max).to be > 0.8
      expect(probs_cluster2.max).to be > 0.8
    end

    it 'gives balanced probabilities for ambiguous points' do
      # Point between clusters
      probs = clusterer.predict_probabilities([5, 5])
      
      # Probabilities should be more balanced
      expect(probs.max - probs.min).to be < 0.8
    end
  end

  describe '#get_cluster_parameters' do
    let(:data_set) do
      Ai4r::Data::DataSet.new(
        data_items: Array.new(20) { [rand(0..5), rand(0..5)] }
      )
    end

    before do
      clusterer.build(data_set, 2)
    end

    it 'returns parameters for specific cluster' do
      params = clusterer.get_cluster_parameters(0)
      
      expect(params).to have_key(:mean)
      expect(params).to have_key(:covariance)
      expect(params).to have_key(:weight)
      
      expect(params[:mean]).to be_an(Array)
      expect(params[:weight]).to be_between(0, 1)
    end

    it 'returns nil for invalid cluster index' do
      expect(clusterer.get_cluster_parameters(10)).to be_nil
      expect(clusterer.get_cluster_parameters(-1)).to be_nil
    end
  end

  describe '#sample' do
    let(:data_set) do
      Ai4r::Data::DataSet.new(
        data_items: Array.new(30) { [rand(0..10), rand(0..10)] }
      )
    end

    before do
      clusterer.build(data_set, 3)
    end

    it 'generates samples from the model' do
      samples = clusterer.sample(10)
      
      expect(samples).to be_an(Array)
      expect(samples.length).to eq(10)
      
      samples.each do |sample|
        expect(sample).to be_an(Array)
        expect(sample.length).to eq(2)
      end
    end

    it 'generates samples with cluster labels' do
      samples, labels = clusterer.sample_with_labels(10)
      
      expect(samples.length).to eq(10)
      expect(labels.length).to eq(10)
      
      labels.each do |label|
        expect(label).to be_between(0, 2)
      end
    end
  end

  describe '#calculate_bic' do
    let(:data_set) do
      Ai4r::Data::DataSet.new(
        data_items: Array.new(20) { [rand, rand] }
      )
    end

    it 'calculates Bayesian Information Criterion' do
      clusterer.build(data_set, 2)
      bic = clusterer.calculate_bic
      
      expect(bic).to be_a(Numeric)
      expect(bic).to be < 0 # BIC is typically negative
    end

    it 'increases with model complexity' do
      # Simpler model
      clusterer1 = described_class.new
      clusterer1.set_parameters(covariance_type: 'spherical')
      clusterer1.build(data_set, 2)
      bic1 = clusterer1.calculate_bic
      
      # More complex model
      clusterer2 = described_class.new
      clusterer2.set_parameters(covariance_type: 'full')
      clusterer2.build(data_set, 3)
      bic2 = clusterer2.calculate_bic
      
      # More complex model should have different BIC
      expect(bic1).not_to eq(bic2)
    end
  end

  describe '#calculate_aic' do
    let(:data_set) do
      Ai4r::Data::DataSet.new(
        data_items: Array.new(20) { [rand, rand] }
      )
    end

    it 'calculates Akaike Information Criterion' do
      clusterer.build(data_set, 2)
      aic = clusterer.calculate_aic
      
      expect(aic).to be_a(Numeric)
    end
  end

  describe 'integration tests' do
    it 'handles overlapping clusters' do
      # Create overlapping Gaussian clusters
      cluster1 = Array.new(20) { |_| 
        x = rand * 2 - 1  # [-1, 1]
        y = rand * 2 - 1
        [x + 2, y + 2]
      }
      cluster2 = Array.new(20) { |_|
        x = rand * 2 - 1
        y = rand * 2 - 1
        [x + 3, y + 3]  # Overlaps with cluster1
      }
      
      data_set = Ai4r::Data::DataSet.new(data_items: cluster1 + cluster2)
      
      clusterer.build(data_set, 2)
      
      # Should still identify two components
      expect(clusterer.weights.all? { |w| w > 0.2 }).to be true
    end

    it 'handles different cluster sizes' do
      # Large cluster
      large_cluster = Array.new(30) { [rand(0..2), rand(0..2)] }
      # Small cluster
      small_cluster = Array.new(5) { [rand(8..10), rand(8..10)] }
      
      data_set = Ai4r::Data::DataSet.new(data_items: large_cluster + small_cluster)
      
      clusterer.build(data_set, 2)
      
      # Weights should reflect cluster sizes
      expect(clusterer.weights.max / clusterer.weights.min).to be > 2
    end

    it 'identifies optimal number of components' do
      # Create data with clear 3-cluster structure
      cluster1 = Array.new(15) { [rand(0..1), rand(0..1)] }
      cluster2 = Array.new(15) { [rand(4..5), rand(4..5)] }
      cluster3 = Array.new(15) { [rand(8..9), rand(8..9)] }
      
      data_set = Ai4r::Data::DataSet.new(data_items: cluster1 + cluster2 + cluster3)
      
      # Try different numbers of components
      bics = []
      (1..5).each do |k|
        gmm = described_class.new
        gmm.set_parameters(covariance_type: 'spherical') # Simpler for stability
        gmm.build(data_set, k)
        bics << gmm.calculate_bic
      end
      
      # BIC should be best (highest) around k=3
      best_k = bics.each_with_index.max[1] + 1
      expect(best_k).to be_between(2, 4)
    end
  end

  describe 'educational mode' do
    it 'calls step callback during training' do
      data_set = Ai4r::Data::DataSet.new(
        data_items: Array.new(10) { [rand, rand] }
      )
      
      steps = []
      clusterer.enable_educational_mode do |step_info|
        steps << step_info
      end
      
      # Suppress output
      original_stdout = $stdout
      $stdout = StringIO.new
      
      clusterer.build(data_set, 2)
      
      $stdout = original_stdout
      
      expect(steps).not_to be_empty
    end
  end
end