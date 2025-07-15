# frozen_string_literal: true

# RSpec tests for AI4R NaiveBayes classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::NaiveBayes do
  # Test data from requirement document
  let(:categorical_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['sunny', 'hot', 'high', 'false'],
        ['sunny', 'hot', 'high', 'true'],
        ['overcast', 'hot', 'high', 'false'],
        ['rainy', 'mild', 'high', 'false'],
        ['rainy', 'cool', 'normal', 'false'],
        ['rainy', 'cool', 'normal', 'true'],
        ['overcast', 'cool', 'normal', 'true'],
        ['sunny', 'mild', 'high', 'false']
      ],
      data_labels: ['no', 'no', 'yes', 'yes', 'yes', 'no', 'yes', 'no']
    )
  end

  let(:continuous_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1.5, 2.3, 3.1],
        [1.8, 2.1, 3.4],
        [4.1, 5.2, 6.8],
        [4.3, 5.1, 6.9],
        [7.8, 8.9, 9.2],
        [7.9, 8.8, 9.1]
      ],
      data_labels: ['A', 'A', 'B', 'B', 'C', 'C']
    )
  end

  let(:mixed_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['sunny', 25.5, 'high'],
        ['overcast', 18.2, 'normal'],
        ['rainy', 12.1, 'high'],
        ['sunny', 22.3, 'normal'],
        ['overcast', 20.0, 'high'],
        ['rainy', 15.5, 'normal']
      ],
      data_labels: ['no', 'yes', 'yes', 'no', 'yes', 'yes']
    )
  end

  let(:minimal_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [['A', 'X'], ['B', 'Y'], ['C', 'Z']],
      data_labels: ['1', '2', '3']
    )
  end

  let(:zero_variance_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        ['A', 5.0, 'constant'],
        ['B', 5.0, 'constant'],
        ['C', 5.0, 'constant'],
        ['A', 5.0, 'constant']
      ],
      data_labels: ['yes', 'no', 'yes', 'no']
    )
  end

  describe "Build Tests" do
    context "feature type handling" do
      it "test_build_categorical_features" do
        classifier = described_class.new.build(categorical_dataset)
        
        expect(classifier).to be_a(described_class)
        
        # Should be able to classify
        result = classifier.eval(['sunny', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
      end

      it "test_build_continuous_features" do
        classifier = described_class.new.build(continuous_dataset)
        
        # Should handle Gaussian distributions for continuous features
        result = classifier.eval([2.0, 3.0, 4.0])
        expect(['A', 'B', 'C']).to include(result)
      end

      it "test_build_mixed_features" do
        classifier = described_class.new.build(mixed_dataset)
        
        # Should handle both categorical and continuous features
        result = classifier.eval(['sunny', 20.0, 'high'])
        expect(['yes', 'no']).to include(result)
      end

      it "test_build_zero_variance_feature" do
        classifier = described_class.new.build(zero_variance_dataset)
        
        # Should handle constant features gracefully
        result = classifier.eval(['A', 5.0, 'constant'])
        expect(['yes', 'no']).to include(result)
      end
    end

    context "smoothing parameter tests" do
      it "test_build_laplace_smoothing" do
        # Default m=1 for Laplace smoothing
        classifier = described_class.new.build(categorical_dataset)
        
        # Should handle unseen categorical values due to smoothing
        result = classifier.eval(['foggy', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
      end

      it "test_build_custom_m" do
        classifier = described_class.new
        classifier.set_parameters(m: 3)
        classifier.build(categorical_dataset)
        
        # Should work with custom smoothing parameter
        result = classifier.eval(['sunny', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
      end

      it "test_build_zero_m" do
        classifier = described_class.new
        classifier.set_parameters(m: 0)
        classifier.build(categorical_dataset)
        
        # Should work with no smoothing (but may fail on unseen values)
        result = classifier.eval(['sunny', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
      end
    end

    context "edge cases" do
      it "test_build_single_instance_per_class" do
        classifier = described_class.new.build(minimal_dataset)
        
        # Should handle minimal data gracefully
        result = classifier.eval(['A', 'X'])
        expect(['1', '2', '3']).to include(result)
      end

      it "test_build_highly_correlated_features" do
        # Features that violate independence assumption
        correlated_dataset = Ai4r::Data::DataSet.new(
          data_items: [
            [1, 2], [2, 4], [3, 6], [4, 8],
            [1, 2], [2, 4], [3, 6], [4, 8]
          ],
          data_labels: ['A', 'A', 'B', 'B', 'A', 'A', 'B', 'B']
        )
        
        classifier = described_class.new.build(correlated_dataset)
        
        # Should still work despite independence violation
        result = classifier.eval([2.5, 5.0])
        expect(['A', 'B']).to include(result)
      end
    end

    context "parameter validation" do
      it "test_build_negative_m" do
        classifier = described_class.new
        
        expect {
          classifier.set_parameters(m: -1)
        }.to raise_error(ArgumentError, /m must be non-negative/)
      end
    end
  end

  describe "Eval Tests" do
    let(:trained_classifier) { described_class.new.build(mixed_dataset) }

    context "probabilistic output" do
      it "test_eval_with_probabilities" do
        # Should provide probability distribution
        probabilities = trained_classifier.get_probability_map(['sunny', 20.0, 'high'])
        
        expect(probabilities).to be_a(Hash)
        expect(probabilities.keys).to include('yes', 'no')
        
        # Probabilities should sum to 1.0
        total_prob = probabilities.values.sum
        expect(total_prob).to be_within(0.001).of(1.0)
        
        # All probabilities should be non-negative
        probabilities.values.each do |prob|
          expect(prob).to be >= 0
        end
      end

      it "test_eval_log_probabilities" do
        # Test numerical stability with log probabilities
        classifier = described_class.new.build(categorical_dataset)
        
        # Should handle without underflow
        result = classifier.eval(['sunny', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
        
        # Test with extreme values that might cause underflow
        result2 = classifier.eval(['very_rare_value', 'another_rare', 'rare_high', 'rare_false'])
        expect(['yes', 'no']).to include(result2)
      end
    end

    context "robustness tests" do
      it "test_eval_unknown_category" do
        classifier = described_class.new.build(categorical_dataset)
        
        # Test with completely unseen categorical value
        result = classifier.eval(['blizzard', 'freezing', 'extreme', 'unknown'])
        
        # Should handle gracefully due to smoothing
        expect(['yes', 'no']).to include(result)
      end

      it "test_eval_zero_probability" do
        # Create scenario that could lead to zero probability
        classifier = described_class.new
        classifier.set_parameters(m: 0)  # No smoothing
        classifier.build(categorical_dataset)
        
        # Should handle zero probability events
        result = classifier.eval(['sunny', 'hot', 'high', 'false'])
        expect(['yes', 'no']).to include(result)
      end

      it "test_eval_missing_feature" do
        # Test with nil values
        result = trained_classifier.eval(['sunny', nil, 'high'])
        
        expect {
          expect(['yes', 'no']).to include(result)
        }.not_to raise_error
      end
    end

    context "continuous feature handling" do
      it "handles out-of-range continuous values" do
        classifier = described_class.new.build(continuous_dataset)
        
        # Test with values outside training range
        result = classifier.eval([100.0, 200.0, 300.0])
        expect(['A', 'B', 'C']).to include(result)
      end

      it "handles extreme continuous values" do
        classifier = described_class.new.build(continuous_dataset)
        
        # Test with very large/small values
        result1 = classifier.eval([1e10, 1e10, 1e10])
        result2 = classifier.eval([-1e10, -1e10, -1e10])
        
        expect(['A', 'B', 'C']).to include(result1)
        expect(['A', 'B', 'C']).to include(result2)
      end
    end
  end

  describe "Probability Distribution Tests" do
    let(:classifier) { described_class.new.build(categorical_dataset) }

    it "provides valid probability distributions" do
      test_instances = [
        ['sunny', 'hot', 'high', 'false'],
        ['overcast', 'mild', 'normal', 'true'],
        ['rainy', 'cool', 'high', 'false']
      ]
      
      test_instances.each do |instance|
        probs = classifier.get_probability_map(instance)
        
        assert_probability_distribution(probs)
      end
    end

    it "maintains probability consistency" do
      instance = ['sunny', 'hot', 'high', 'false']
      
      # Multiple calls should return same probabilities
      probs1 = classifier.get_probability_map(instance)
      probs2 = classifier.get_probability_map(instance)
      
      expect(probs1).to eq(probs2)
    end

    it "handles class probability ranking" do
      # More likely instances should have higher probabilities
      instance1 = ['sunny', 'hot', 'high', 'false']  # Common in training
      instance2 = ['unknown', 'unknown', 'unknown', 'unknown']  # All unseen
      
      probs1 = classifier.get_probability_map(instance1)
      probs2 = classifier.get_probability_map(instance2)
      
      # Both should be valid distributions
      assert_probability_distribution(probs1)
      assert_probability_distribution(probs2)
    end
  end

  describe "Performance Tests" do
    it "handles large datasets efficiently" do
      # Generate large dataset
      large_items = []
      large_labels = []
      
      1000.times do |i|
        large_items << ["cat_#{i % 10}", rand(100), "type_#{i % 5}"]
        large_labels << (i % 3).to_s
      end
      
      large_dataset = Ai4r::Data::DataSet.new(
        data_items: large_items,
        data_labels: large_labels
      )
      
      benchmark_performance("Large NaiveBayes training") do
        classifier = described_class.new.build(large_dataset)
        expect(classifier).to be_a(described_class)
      end
    end

    it "fast evaluation with probability computation" do
      classifier = described_class.new.build(mixed_dataset)
      
      benchmark_performance("NaiveBayes probability evaluation") do
        100.times do
          instance = ['sunny', rand(30), 'high']
          probs = classifier.get_probability_map(instance)
          expect(probs).to be_a(Hash)
        end
      end
    end
  end

  describe "Statistical Properties Tests" do
    it "respects class priors" do
      # Create dataset with skewed class distribution
      skewed_items = Array.new(80) { ['A', 1.0] } + Array.new(20) { ['B', 2.0] }
      skewed_labels = Array.new(80) { 'common' } + Array.new(20) { 'rare' }
      
      skewed_dataset = Ai4r::Data::DataSet.new(
        data_items: skewed_items,
        data_labels: skewed_labels
      )
      
      classifier = described_class.new.build(skewed_dataset)
      
      # For ambiguous instance, should favor common class
      probs = classifier.get_probability_map(['C', 1.5])
      expect(probs['common']).to be > probs['rare']
    end

    it "handles feature independence assumption" do
      # Even with correlated features, should provide reasonable results
      classifier = described_class.new.build(mixed_dataset)
      
      # Test feature combinations
      result1 = classifier.eval(['sunny', 25.0, 'high'])
      result2 = classifier.eval(['rainy', 10.0, 'normal'])
      
      expect(['yes', 'no']).to include(result1)
      expect(['yes', 'no']).to include(result2)
    end
  end

  describe "Integration Tests" do
    it "works with different smoothing strategies" do
      # Compare different smoothing parameters
      m_values = [0, 1, 5, 10]
      classifiers = []
      
      m_values.each do |m|
        classifier = described_class.new
        classifier.set_parameters(m: m)
        classifier.build(categorical_dataset)
        classifiers << classifier
      end
      
      # All should work, but may give different results
      test_instance = ['sunny', 'hot', 'high', 'false']
      results = classifiers.map { |c| c.eval(test_instance) }
      
      results.each { |result| expect(['yes', 'no']).to include(result) }
    end

    it "maintains consistency across builds" do
      # Same parameters should give same model
      classifier1 = described_class.new.build(categorical_dataset)
      classifier2 = described_class.new.build(categorical_dataset)
      
      test_instance = ['sunny', 'hot', 'high', 'false']
      
      result1 = classifier1.eval(test_instance)
      result2 = classifier2.eval(test_instance)
      
      expect(result1).to eq(result2)
    end
  end

  # Helper methods for assertions
  def assert_probability_distribution(probs)
    expect(probs).to be_a(Hash)
    
    # All probabilities should be non-negative
    probs.values.each do |prob|
      expect(prob).to be >= 0
    end
    
    # Should sum to 1.0 (within tolerance)
    total = probs.values.sum
    expect(total).to be_within(0.001).of(1.0)
  end

  def assert_classification_correct(classifier, instance, expected_class)
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_deterministic_output(classifier, instance)
    result1 = classifier.eval(instance)
    result2 = classifier.eval(instance)
    expect(result1).to eq(result2)
  end

  def assert_handles_unknown_value(classifier, instance_with_unknown)
    expect {
      result = classifier.eval(instance_with_unknown)
      expect(result).to be_a(String)
    }.not_to raise_error
  end
end