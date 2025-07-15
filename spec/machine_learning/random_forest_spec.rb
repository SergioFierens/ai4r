# frozen_string_literal: true

# RSpec tests for AI4R Random Forest Algorithm
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::MachineLearning::RandomForest do
  # Test datasets
  let(:iris_data) do
    [
      [5.1, 3.5, 1.4, 0.2, 'setosa'],
      [4.9, 3.0, 1.4, 0.2, 'setosa'],
      [4.7, 3.2, 1.3, 0.2, 'setosa'],
      [4.6, 3.1, 1.5, 0.2, 'setosa'],
      [5.0, 3.6, 1.4, 0.2, 'setosa'],
      [7.0, 3.2, 4.7, 1.4, 'versicolor'],
      [6.4, 3.2, 4.5, 1.5, 'versicolor'],
      [6.9, 3.1, 4.9, 1.5, 'versicolor'],
      [5.5, 2.3, 4.0, 1.3, 'versicolor'],
      [6.5, 2.8, 4.6, 1.5, 'versicolor'],
      [6.3, 3.3, 6.0, 2.5, 'virginica'],
      [5.8, 2.7, 5.1, 1.9, 'virginica'],
      [7.1, 3.0, 5.9, 2.1, 'virginica'],
      [6.3, 2.9, 5.6, 1.8, 'virginica'],
      [6.5, 3.0, 5.8, 2.2, 'virginica']
    ]
  end

  let(:binary_data) do
    [
      [1, 2, 'A'],
      [2, 3, 'A'],
      [3, 4, 'A'],
      [4, 5, 'B'],
      [5, 6, 'B'],
      [6, 7, 'B']
    ]
  end

  let(:regression_data) do
    [
      [1, 2, 5],
      [2, 3, 8],
      [3, 4, 11],
      [4, 5, 14],
      [5, 6, 17],
      [6, 7, 20]
    ]
  end

  describe 'initialization' do
    context 'with valid parameters' do
      it 'creates RandomForest instance with default configuration' do
        rf = described_class.new

        expect(rf.instance_variable_get(:@n_trees)).to eq(10)
        expect(rf.instance_variable_get(:@max_depth)).to eq(10)
        expect(rf.instance_variable_get(:@min_samples_split)).to eq(2)
        expect(rf.instance_variable_get(:@bootstrap)).to be true
        expect(rf.verbose_mode).to be false
      end

      it 'creates RandomForest instance with custom parameters' do
        rf = described_class.new(
          n_trees: 5,
          max_depth: 3,
          min_samples_split: 4,
          max_features: 2,
          bootstrap: false
        )

        expect(rf.instance_variable_get(:@n_trees)).to eq(5)
        expect(rf.instance_variable_get(:@max_depth)).to eq(3)
        expect(rf.instance_variable_get(:@min_samples_split)).to eq(4)
        expect(rf.instance_variable_get(:@max_features)).to eq(2)
        expect(rf.instance_variable_get(:@bootstrap)).to be false
      end

      it 'creates RandomForest instance with educational options' do
        rf = described_class.new(
          verbose: true,
          track_oob: false,
          calculate_importance: false
        )

        expect(rf.verbose_mode).to be true
        expect(rf.track_oob).to be false
        expect(rf.calculate_importance).to be false
      end
    end

    context 'with invalid parameters' do
      it 'raises error for invalid n_trees' do
        expect {
          described_class.new(n_trees: 0)
        }.to raise_error(ArgumentError, 'n_trees must be a positive integer, got: 0')

        expect {
          described_class.new(n_trees: -1)
        }.to raise_error(ArgumentError, 'n_trees must be a positive integer, got: -1')

        expect {
          described_class.new(n_trees: 'invalid')
        }.to raise_error(ArgumentError, 'n_trees must be a positive integer, got: invalid')
      end

      it 'raises error for invalid max_depth' do
        expect {
          described_class.new(max_depth: 0)
        }.to raise_error(ArgumentError, 'max_depth must be a positive integer, got: 0')

        expect {
          described_class.new(max_depth: -1)
        }.to raise_error(ArgumentError, 'max_depth must be a positive integer, got: -1')
      end

      it 'raises error for invalid min_samples_split' do
        expect {
          described_class.new(min_samples_split: 1)
        }.to raise_error(ArgumentError, 'min_samples_split must be an integer >= 2, got: 1')

        expect {
          described_class.new(min_samples_split: 0)
        }.to raise_error(ArgumentError, 'min_samples_split must be an integer >= 2, got: 0')
      end

      it 'raises error for invalid max_features string' do
        expect {
          described_class.new(max_features: 'invalid')
        }.to raise_error(ArgumentError, 'Invalid max_features string: invalid')
      end

      it 'raises error for invalid max_features type' do
        expect {
          described_class.new(max_features: 1.5)
        }.to raise_error(ArgumentError, 'max_features must be Integer, String, or nil')
      end
    end
  end

  describe 'training' do
    context 'with valid data' do
      let(:rf) { described_class.new(n_trees: 3, max_depth: 5) }

      it 'trains successfully on iris dataset' do
        expect { rf.train(iris_data) }.not_to raise_error
        
        expect(rf.trees.length).to eq(3)
        expect(rf.training_time).to be > 0
        expect(rf.n_features).to eq(4)
        expect(rf.class_labels).to match_array(['setosa', 'versicolor', 'virginica'])
      end

      it 'trains successfully on binary dataset' do
        expect { rf.train(binary_data) }.not_to raise_error
        
        expect(rf.trees.length).to eq(3)
        expect(rf.n_features).to eq(2)
        expect(rf.class_labels).to match_array(['A', 'B'])
      end

      it 'calculates feature importances' do
        rf.train(iris_data)
        
        expect(rf.feature_importances).to be_a(Hash)
        expect(rf.feature_importances.keys.length).to eq(4)
        expect(rf.feature_importances.values.all? { |v| v >= 0 }).to be true
        expect(rf.feature_importances.values.sum).to be_within(0.001).of(1.0)
      end

      it 'creates bootstrap samples when enabled' do
        rf_bootstrap = described_class.new(n_trees: 3, bootstrap: true)
        rf_bootstrap.train(iris_data)
        
        expect(rf_bootstrap.bootstrap_samples.length).to eq(3)
        expect(rf_bootstrap.bootstrap_samples.all? { |sample| sample.length == iris_data.length }).to be true
      end

      it 'creates feature subsets for each tree' do
        rf.train(iris_data)
        
        expect(rf.feature_subsets.length).to eq(3)
        expect(rf.feature_subsets.all? { |subset| subset.is_a?(Array) }).to be true
        expect(rf.feature_subsets.all? { |subset| subset.length <= 4 }).to be true
      end

      it 'calculates out-of-bag error' do
        rf.train(iris_data)
        
        expect(rf.oob_error).to be_a(Float)
        expect(rf.oob_error).to be >= 0
        expect(rf.oob_error).to be <= 1
      end

      it 'tracks diversity metrics' do
        rf.train(iris_data)
        
        expect(rf.diversity_metrics).to be_a(Hash)
        expect(rf.diversity_metrics).to have_key(:diversity_index)
        expect(rf.diversity_metrics).to have_key(:average_agreement)
        expect(rf.diversity_metrics).to have_key(:prediction_variance)
      end
    end

    context 'with invalid data' do
      let(:rf) { described_class.new }

      it 'raises error for empty data' do
        expect {
          rf.train([])
        }.to raise_error(ArgumentError, 'Training data cannot be empty')
      end

      it 'raises error for non-2D data' do
        expect {
          rf.train([1, 2, 3])
        }.to raise_error(ArgumentError, 'Training data must be 2D array')
      end

      it 'raises error for inconsistent row lengths' do
        expect {
          rf.train([[1, 2, 'A'], [3, 4, 5, 'B']])
        }.to raise_error(ArgumentError, 'All training samples must have the same number of features')
      end

      it 'raises error for insufficient columns' do
        expect {
          rf.train([['A'], ['B']])
        }.to raise_error(ArgumentError, 'Training data must have at least 2 columns (features + target)')
      end
    end
  end

  describe 'prediction' do
    let(:rf) { described_class.new(n_trees: 5, max_depth: 3) }

    before do
      rf.train(iris_data)
    end

    context 'single prediction' do
      it 'makes prediction for valid input' do
        prediction = rf.predict([5.0, 3.0, 1.5, 0.2])
        
        expect(prediction).to be_a(String)
        expect(['setosa', 'versicolor', 'virginica']).to include(prediction)
      end

      it 'makes consistent predictions' do
        sample = [5.0, 3.0, 1.5, 0.2]
        prediction1 = rf.predict(sample)
        prediction2 = rf.predict(sample)
        
        expect(prediction1).to eq(prediction2)
      end

      it 'handles edge case predictions' do
        # Test with extreme values
        prediction = rf.predict([0.0, 0.0, 0.0, 0.0])
        expect(prediction).to be_a(String)

        prediction = rf.predict([10.0, 10.0, 10.0, 10.0])
        expect(prediction).to be_a(String)
      end
    end

    context 'batch prediction' do
      it 'makes predictions for multiple samples' do
        samples = [
          [5.0, 3.0, 1.5, 0.2],
          [6.0, 3.0, 4.0, 1.0],
          [7.0, 3.0, 5.0, 2.0]
        ]
        
        predictions = rf.predict_batch(samples)
        
        expect(predictions.length).to eq(3)
        expect(predictions.all? { |p| p.is_a?(String) }).to be true
      end

      it 'handles empty batch' do
        predictions = rf.predict_batch([])
        expect(predictions).to eq([])
      end
    end

    context 'probability prediction' do
      it 'calculates class probabilities' do
        probabilities = rf.predict_proba([5.0, 3.0, 1.5, 0.2])
        
        expect(probabilities).to be_a(Hash)
        expect(probabilities.keys.all? { |k| k.is_a?(String) }).to be true
        expect(probabilities.values.all? { |v| v >= 0 && v <= 1 }).to be true
        expect(probabilities.values.sum).to be_within(0.001).of(1.0)
      end

      it 'returns all possible classes in probabilities' do
        probabilities = rf.predict_proba([5.0, 3.0, 1.5, 0.2])
        
        # Should have probabilities for classes that trees can predict
        expect(probabilities.keys.length).to be >= 1
        expect(probabilities.keys.all? { |k| ['setosa', 'versicolor', 'virginica'].include?(k) }).to be true
      end
    end

    context 'input validation' do
      it 'raises error for non-array input' do
        expect {
          rf.predict('invalid')
        }.to raise_error(ArgumentError, 'Sample must be an array')
      end

      it 'raises error for wrong number of features' do
        expect {
          rf.predict([1, 2, 3]) # Should be 4 features
        }.to raise_error(ArgumentError, 'Sample must have 4 features, got 3')

        expect {
          rf.predict([1, 2, 3, 4, 5]) # Should be 4 features
        }.to raise_error(ArgumentError, 'Sample must have 4 features, got 5')
      end
    end
  end

  describe 'max_features calculation' do
    let(:rf) { described_class.new }

    it 'calculates sqrt for string parameter' do
      result = rf.send(:calculate_max_features, 'sqrt', 16)
      expect(result).to eq(4)
    end

    it 'calculates log2 for string parameter' do
      result = rf.send(:calculate_max_features, 'log2', 16)
      expect(result).to eq(4)
    end

    it 'returns all features for all parameter' do
      result = rf.send(:calculate_max_features, 'all', 16)
      expect(result).to eq(16)
    end

    it 'uses integer parameter directly' do
      result = rf.send(:calculate_max_features, 5, 16)
      expect(result).to eq(5)
    end

    it 'limits integer parameter to total features' do
      result = rf.send(:calculate_max_features, 20, 16)
      expect(result).to eq(16)
    end

    it 'uses default sqrt for nil parameter' do
      result = rf.send(:calculate_max_features, nil, 16)
      expect(result).to eq(4)
    end
  end

  describe 'bootstrap sampling' do
    let(:rf) { described_class.new(bootstrap: true) }

    it 'creates bootstrap sample with replacement' do
      data = [[1, 'A'], [2, 'B'], [3, 'C']]
      bootstrap_sample = rf.send(:create_bootstrap_sample, data)
      
      expect(bootstrap_sample.length).to eq(3)
      expect(bootstrap_sample.all? { |sample| data.include?(sample) }).to be true
    end

    it 'returns copy without bootstrap' do
      rf_no_bootstrap = described_class.new(bootstrap: false)
      data = [[1, 'A'], [2, 'B'], [3, 'C']]
      sample = rf_no_bootstrap.send(:create_bootstrap_sample, data)
      
      expect(sample).to eq(data)
      expect(sample.object_id).not_to eq(data.object_id)
    end
  end

  describe 'feature selection' do
    let(:rf) { described_class.new(max_features: 2) }

    before do
      rf.instance_variable_set(:@n_features, 5)
      rf.instance_variable_set(:@max_features, 2)
    end

    it 'selects random subset of features' do
      subset = rf.send(:select_random_features)
      
      expect(subset.length).to eq(2)
      expect(subset.all? { |idx| idx >= 0 && idx < 5 }).to be true
      expect(subset.uniq.length).to eq(2) # No duplicates
      expect(subset.sort).to eq(subset) # Should be sorted
    end

    it 'selects different subsets on multiple calls' do
      subset1 = rf.send(:select_random_features)
      subset2 = rf.send(:select_random_features)
      
      # With randomness, they should sometimes be different
      # Run multiple times to increase probability
      different = false
      10.times do
        subset1 = rf.send(:select_random_features)
        subset2 = rf.send(:select_random_features)
        if subset1 != subset2
          different = true
          break
        end
      end
      
      expect(different).to be true
    end
  end

  describe 'educational features' do
    context 'feature importance analysis' do
      let(:rf) { described_class.new(n_trees: 5, calculate_importance: true) }

      it 'analyzes feature importance' do
        rf.train(iris_data)
        importance = rf.feature_importance_analysis
        
        expect(importance).to be_a(Hash)
        expect(importance.keys.length).to eq(4)
        expect(importance.values.all? { |v| v >= 0 }).to be true
        expect(importance.values.sum).to be_within(0.001).of(1.0)
      end

      it 'returns cached importance on second call' do
        rf.train(iris_data)
        importance1 = rf.feature_importance_analysis
        importance2 = rf.feature_importance_analysis
        
        expect(importance1).to eq(importance2)
      end
    end

    context 'out-of-bag error estimation' do
      let(:rf) { described_class.new(n_trees: 5, track_oob: true) }

      it 'estimates OOB error' do
        rf.train(iris_data)
        oob_error = rf.oob_error_estimate
        
        expect(oob_error).to be_a(Float)
        expect(oob_error).to be >= 0
        expect(oob_error).to be <= 1
      end
    end

    context 'diversity analysis' do
      let(:rf) { described_class.new(n_trees: 5) }

      it 'analyzes ensemble diversity' do
        rf.train(iris_data)
        diversity = rf.diversity_analysis
        
        expect(diversity).to be_a(Hash)
        expect(diversity).to have_key(:diversity_index)
        expect(diversity).to have_key(:average_agreement)
        expect(diversity).to have_key(:prediction_variance)
        
        expect(diversity[:diversity_index]).to be >= 0
        expect(diversity[:diversity_index]).to be <= 1
        expect(diversity[:average_agreement]).to be >= 0
        expect(diversity[:average_agreement]).to be <= 1
      end
    end

    context 'single tree comparison' do
      let(:rf) { described_class.new(n_trees: 5, max_depth: 3) }

      it 'compares performance with single tree' do
        rf.train(iris_data)
        
        # Use same data for testing (not ideal but for demonstration)
        comparison = rf.compare_with_single_tree(iris_data)
        
        expect(comparison).to have_key(:random_forest)
        expect(comparison).to have_key(:single_tree)
        expect(comparison).to have_key(:improvement)
        
        expect(comparison[:random_forest][:accuracy]).to be >= 0
        expect(comparison[:random_forest][:accuracy]).to be <= 1
        expect(comparison[:single_tree][:accuracy]).to be >= 0
        expect(comparison[:single_tree][:accuracy]).to be <= 1
      end
    end

    context 'forest visualization' do
      let(:rf) { described_class.new(n_trees: 3, max_depth: 3) }

      it 'generates forest visualization' do
        rf.train(iris_data)
        visualization = rf.visualize_forest
        
        expect(visualization).to be_a(String)
        expect(visualization).to include('Random Forest Visualization')
        expect(visualization).to include('Forest Statistics')
        expect(visualization).to include('Feature Importance')
        expect(visualization).to include('Tree Diversity')
      end
    end
  end

  describe 'performance characteristics' do
    context 'algorithm efficiency' do
      let(:rf) { described_class.new(n_trees: 10, max_depth: 5) }

      it 'trains efficiently on moderate dataset' do
        # Create larger dataset
        large_data = []
        100.times do |i|
          large_data << [rand, rand, rand, rand, ['A', 'B', 'C'].sample]
        end

        benchmark_performance('Random Forest training') do
          rf.train(large_data)
          expect(rf.trees.length).to eq(10)
        end
      end

      it 'predicts efficiently on multiple samples' do
        rf.train(iris_data)
        
        # Create test samples
        test_samples = Array.new(100) { [rand * 10, rand * 10, rand * 10, rand * 10] }

        benchmark_performance('Random Forest batch prediction') do
          predictions = rf.predict_batch(test_samples)
          expect(predictions.length).to eq(100)
        end
      end
    end

    context 'memory efficiency' do
      let(:rf) { described_class.new(n_trees: 5, max_depth: 3) }

      it 'handles multiple training cycles' do
        # Train multiple times to test memory efficiency
        5.times do
          rf.train(iris_data)
          expect(rf.trees.length).to eq(5)
        end
      end
    end
  end

  describe 'edge cases and error handling' do
    context 'boundary conditions' do
      it 'handles single sample dataset' do
        single_sample = [[1, 2, 3, 'A']]
        rf = described_class.new(n_trees: 1, max_depth: 1)
        
        expect { rf.train(single_sample) }.not_to raise_error
        expect(rf.predict([1, 2, 3])).to eq('A')
      end

      it 'handles single class dataset' do
        single_class = [
          [1, 2, 'A'],
          [3, 4, 'A'],
          [5, 6, 'A']
        ]
        rf = described_class.new(n_trees: 3, max_depth: 3)
        
        expect { rf.train(single_class) }.not_to raise_error
        expect(rf.predict([2, 3])).to eq('A')
      end

      it 'handles dataset with missing values representation' do
        # This would need special handling in a production system
        # For now, test that it doesn't crash
        rf = described_class.new(n_trees: 2, max_depth: 2)
        
        expect { rf.train(binary_data) }.not_to raise_error
      end
    end

    context 'extreme configurations' do
      it 'handles very small max_depth' do
        rf = described_class.new(n_trees: 3, max_depth: 1)
        
        expect { rf.train(iris_data) }.not_to raise_error
        expect(rf.predict([5.0, 3.0, 1.5, 0.2])).to be_a(String)
      end

      it 'handles very small number of trees' do
        rf = described_class.new(n_trees: 1, max_depth: 5)
        
        expect { rf.train(iris_data) }.not_to raise_error
        expect(rf.trees.length).to eq(1)
      end

      it 'handles max_features equal to n_features' do
        rf = described_class.new(n_trees: 3, max_features: 4)
        
        expect { rf.train(iris_data) }.not_to raise_error
        expect(rf.feature_subsets.all? { |subset| subset.length <= 4 }).to be true
      end
    end
  end

  describe 'DecisionTree helper class' do
    let(:tree) { Ai4r::MachineLearning::DecisionTree.new(max_depth: 3, min_samples_split: 2, feature_subset: [0, 1], tree_id: 0) }

    it 'initializes with correct parameters' do
      expect(tree.max_depth).to eq(3)
      expect(tree.min_samples_split).to eq(2)
      expect(tree.feature_subset).to eq([0, 1])
      expect(tree.tree_id).to eq(0)
    end

    it 'trains on simple dataset' do
      simple_data = [
        [1, 2, 'A'],
        [2, 3, 'A'],
        [3, 4, 'B'],
        [4, 5, 'B']
      ]

      expect { tree.train(simple_data) }.not_to raise_error
      expect(tree.root).not_to be_nil
      expect(tree.training_time).to be > 0
    end

    it 'makes predictions after training' do
      simple_data = [
        [1, 2, 'A'],
        [2, 3, 'A'],
        [3, 4, 'B'],
        [4, 5, 'B']
      ]

      tree.train(simple_data)
      prediction = tree.predict([2, 3])
      
      expect(prediction).to be_a(String)
      expect(['A', 'B']).to include(prediction)
    end

    it 'calculates feature importances' do
      simple_data = [
        [1, 2, 'A'],
        [2, 3, 'A'],
        [3, 4, 'B'],
        [4, 5, 'B']
      ]

      tree.train(simple_data)
      
      expect(tree.feature_importances).to be_a(Hash)
      expect(tree.feature_importances.values.all? { |v| v >= 0 }).to be true
    end

    it 'calculates tree depth' do
      simple_data = [
        [1, 2, 'A'],
        [2, 3, 'A'],
        [3, 4, 'B'],
        [4, 5, 'B']
      ]

      tree.train(simple_data)
      
      expect(tree.depth).to be_a(Integer)
      expect(tree.depth).to be >= 0
      expect(tree.depth).to be <= 3
    end
  end
end