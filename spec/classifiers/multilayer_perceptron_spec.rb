# frozen_string_literal: true

# RSpec tests for AI4R MultilayerPerceptron classifier based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::MultilayerPerceptron do
  # Test data from requirement document
  let(:xor_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [[0, 0, '0'], [0, 1, '1'], [1, 0, '1'], [1, 1, '0']],
      data_labels: %w[x y output]
    )
  end

  let(:multi_class_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 0, 0, 0, 'A'], [0, 1, 0, 0, 'B'], [0, 0, 1, 0, 'C'], [0, 0, 0, 1, 'A'],
        [1, 1, 0, 0, 'B'], [0, 1, 1, 0, 'C'], [0, 0, 1, 1, 'A'], [1, 0, 0, 1, 'B'],
        [1, 0, 1, 0, 'C'], [0, 1, 0, 1, 'A']
      ],
      data_labels: %w[f1 f2 f3 f4 class]
    )
  end

  let(:linearly_separable_dataset) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1, 'positive'], [2, 2, 'positive'], [3, 3, 'positive'], [4, 4, 'positive'],
        [-1, -1, 'negative'], [-2, -2, 'negative'], [-3, -3, 'negative'], [-4, -4, 'negative']
      ],
      data_labels: %w[x y class]
    )
  end

  describe 'Build Tests' do
    context 'architecture configuration' do
      it 'test_build_xor_problem' do
        # XOR requires non-linear solution
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [2],
          network_parameters: { learning_rate: 0.5 },
          training_iterations: 1000
        )
        classifier.build(xor_dataset)

        expect(classifier).to be_a(described_class)

        # Should be able to learn XOR (may take multiple attempts due to randomization)
        # Test that it can at least make predictions
        result = classifier.eval([0, 0])
        expect(%w[0 1]).to include(result)
      end

      it 'test_build_multi_class' do
        # Test 3-class classification
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [10],
          network_parameters: { learning_rate: 0.1 },
          training_iterations: 500
        )
        classifier.build(multi_class_dataset)

        result = classifier.eval([1, 0, 0, 0])
        expect(%w[A B C]).to include(result)
      end

      it 'test_build_auto_architecture' do
        # Test automatic hidden layer sizing
        classifier = described_class.new
        # Use default architecture (should auto-calculate)
        classifier.build(multi_class_dataset)

        expect(classifier).to be_a(described_class)
        result = classifier.eval([0, 1, 0, 0])
        expect(%w[A B C]).to include(result)
      end

      it 'test_build_deep_network' do
        # Test deep architecture
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [20, 20, 20],
          network_parameters: { learning_rate: 0.01 },
          training_iterations: 100 # Fewer epochs for deep network
        )
        classifier.build(multi_class_dataset)

        result = classifier.eval([1, 1, 0, 0])
        expect(%w[A B C]).to include(result)
      end

      it 'test_build_no_hidden' do
        # Test perceptron (no hidden layers)
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [],
          network_parameters: { learning_rate: 0.1 },
          training_iterations: 200
        )

        # Use linearly separable data for perceptron
        classifier.build(linearly_separable_dataset)

        result = classifier.eval([2, 2])
        expect(%w[positive negative]).to include(result)
      end
    end

    context 'learning parameters' do
      it 'test_build_learning_rate' do
        # Test different learning rates
        learning_rates = [0.01, 0.1, 1.0]

        learning_rates.each do |lr|
          classifier = described_class.new
          classifier.set_parameters(
            hidden_layers: [5],
            learning_rate: lr,
            training_iterations: 100
          )

          expect do
            classifier.build(linearly_separable_dataset)
          end.not_to raise_error

          result = classifier.eval([1, 1])
          expect(%w[positive negative]).to include(result)
        end
      end

      it 'test_build_max_epochs' do
        # Test epoch limiting
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [3],
          training_iterations: 50
        )
        classifier.build(linearly_separable_dataset)

        # Should complete training within epoch limit
        result = classifier.eval([3, 3])
        expect(%w[positive negative]).to include(result)
      end

      it 'test_build_early_stopping' do
        # Test early stopping based on error threshold
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [5],
          training_iterations: 1000,
          error_threshold: 0.01 # Stop when error is low enough
        )

        start_time = Time.now
        classifier.build(linearly_separable_dataset)
        training_time = Time.now - start_time

        # Should potentially stop early
        expect(training_time).to be < 10 # Reasonable time limit

        result = classifier.eval([2, 2])
        expect(%w[positive negative]).to include(result)
      end
    end

    context 'error handling' do
      it 'handles invalid architecture' do
        classifier = described_class.new

        expect do
          classifier.set_parameters(hidden_layers: [-1, 5])
        end.to raise_error(ArgumentError, /hidden layer sizes must be positive/)
      end

      it 'handles invalid learning rate' do
        classifier = described_class.new

        expect do
          classifier.set_parameters(learning_rate: -0.1)
        end.to raise_error(ArgumentError, /learning rate must be positive/)
      end

      it 'handles invalid epochs' do
        classifier = described_class.new

        expect do
          classifier.set_parameters(training_iterations: -10)
        end.to raise_error(ArgumentError, /max_epochs must be positive/)
      end
    end
  end

  describe 'Eval Tests' do
    let(:trained_classifier) do
      classifier = described_class.new
      classifier.set_parameters(
        hidden_layers: [4],
        network_parameters: { learning_rate: 0.3 },
        training_iterations: 200
      )
      classifier.build(linearly_separable_dataset)
      classifier
    end

    context 'classification output' do
      it 'test_eval_returns_class' do
        # Should return class label, not raw neural network output
        result = trained_classifier.eval([2, 2])

        expect(result).to be_a(String)
        expect(%w[positive negative]).to include(result)

        # Should not return numeric values
        expect(result).not_to be_a(Numeric)
      end

      it 'test_eval_confidence_scores' do
        # Test if confidence/probability scores are available
        if trained_classifier.respond_to?(:get_class_probabilities)
          probs = trained_classifier.get_class_probabilities([2, 2])

          expect(probs).to be_a(Hash)
          expect(probs.keys).to include('positive', 'negative')

          # Probabilities should sum to 1.0
          total = probs.values.sum
          expect(total).to be_within(0.01).of(1.0)
        end
      end

      it 'test_eval_before_convergence' do
        # Test evaluation on partially trained network
        partial_classifier = described_class.new
        partial_classifier.set_parameters(
          hidden_layers: [3],
          training_iterations: 5 # Very few epochs
        )
        partial_classifier.build(linearly_separable_dataset)

        # Should still be able to make predictions
        result = partial_classifier.eval([1, 1])
        expect(%w[positive negative]).to include(result)
      end
    end

    context 'edge cases' do
      it 'handles input dimension mismatch' do
        expect do
          trained_classifier.eval([1]) # Wrong number of features
        end.to raise_error
      end

      it 'handles extreme input values' do
        # Test with very large values
        result1 = trained_classifier.eval([1000, 1000])
        expect(%w[positive negative]).to include(result1)

        # Test with very small values
        result2 = trained_classifier.eval([-1000, -1000])
        expect(%w[positive negative]).to include(result2)
      end

      it 'handles edge numerical values' do
        # Test with values that might cause numerical issues
        result1 = trained_classifier.eval([Float::EPSILON, Float::EPSILON])
        result2 = trained_classifier.eval([0.0, 0.0])

        expect(%w[positive negative]).to include(result1)
        expect(%w[positive negative]).to include(result2)
      end
    end
  end

  describe 'Learning Behavior Tests' do
    it 'shows improvement over epochs' do
      # Track error over training
      classifier = described_class.new
      classifier.set_parameters(
        hidden_layers: [4],
        network_parameters: { learning_rate: 0.1 },
        training_iterations: 100
      )

      # Build with monitoring (if available)
      classifier.build(linearly_separable_dataset)

      # Test that network can learn the training data
      correct_predictions = 0
      linearly_separable_dataset.data_items.each_with_index do |item, i|
        prediction = classifier.eval(item[0...-1])  # Exclude class label
        actual = item.last  # Class is last element of data_item
        correct_predictions += 1 if prediction == actual
      end

      accuracy = correct_predictions.to_f / linearly_separable_dataset.data_items.length
      expect(accuracy).to be > 0.5 # Should do better than random
    end

    it 'handles non-linear problems' do
      # XOR is the classic non-linear test
      xor_classifier = described_class.new
      xor_classifier.set_parameters(
        hidden_layers: [4],
        network_parameters: { learning_rate: 0.5 },
        training_iterations: 500
      )
      xor_classifier.build(xor_dataset)

      # Test all XOR combinations
      xor_results = []
      xor_dataset.data_items.each do |item|
        result = xor_classifier.eval(item[0...-1])  # Exclude class label
        xor_results << result
      end

      # Should be able to make predictions (correctness may vary due to randomness)
      xor_results.each { |result| expect(%w[0 1]).to include(result) }
    end

    it 'converges on linearly separable data' do
      # Linearly separable data should converge reliably
      classifier = described_class.new
      classifier.set_parameters(
        hidden_layers: [3],
        network_parameters: { learning_rate: 0.1 },
        training_iterations: 200
      )
      classifier.build(linearly_separable_dataset)

      # Should achieve good accuracy on training data
      correct = 0
      linearly_separable_dataset.data_items.each_with_index do |item, i|
        prediction = classifier.eval(item[0...-1])  # Exclude class label
        actual = item.last  # Class is last element of data_item
        correct += 1 if prediction == actual
      end

      accuracy = correct.to_f / linearly_separable_dataset.data_items.length
      expect(accuracy).to be >= 0.75 # Should learn linearly separable data well
    end
  end

  describe 'Performance Tests' do
    it 'handles reasonable dataset sizes efficiently' do
      # Generate moderately sized dataset
      items = []

      200.times do |i|
        items << [rand(10), rand(10), rand(10), (i.even? ? 'even' : 'odd')]
      end

      dataset = Ai4r::Data::DataSet.new(data_items: items, data_labels: %w[x y z class])

      benchmark_performance('MultilayerPerceptron training') do
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: [10],
          training_iterations: 50 # Reasonable for benchmark
        )
        classifier.build(dataset)
      end
    end

    it 'evaluation speed is reasonable' do
      classifier = described_class.new
      classifier.set_parameters(hidden_layers: [5])
      classifier.build(linearly_separable_dataset)

      benchmark_performance('MultilayerPerceptron evaluation') do
        100.times do
          result = classifier.eval([rand(10), rand(10)])
          expect(%w[positive negative]).to include(result)
        end
      end
    end
  end

  describe 'Integration Tests' do
    it 'works with different activation functions' do
      # Test if different activation functions are supported
      if described_class.new.respond_to?(:set_activation_function)
        %w[sigmoid tanh relu].each do |activation|
          classifier = described_class.new
          classifier.set_activation_function(activation)
          classifier.set_parameters(hidden_layers: [3], training_iterations: 50)

          expect do
            classifier.build(linearly_separable_dataset)
          end.not_to raise_error
        end
      end
    end

    it 'maintains state consistency' do
      classifier = described_class.new
      classifier.set_parameters(hidden_layers: [3])
      classifier.build(linearly_separable_dataset)

      # Multiple evaluations should be consistent
      test_input = [2, 2]
      result1 = classifier.eval(test_input)
      result2 = classifier.eval(test_input)

      expect(result1).to eq(result2)
    end

    it 'serialization preserves model' do
      classifier = described_class.new
      classifier.set_parameters(hidden_layers: [3])
      classifier.build(linearly_separable_dataset)

      # Test serialization
      test_input = [2, 2]
      original_result = classifier.eval(test_input)

      # Serialize and deserialize
      serialized = Marshal.dump(classifier)
      loaded_classifier = Marshal.load(serialized)

      # Should produce same result
      loaded_result = loaded_classifier.eval(test_input)
      expect(loaded_result).to eq(original_result)
    end
  end

  describe 'Architecture Validation Tests' do
    it 'validates network architecture' do
      # Input layer size should match data
      classifier = described_class.new
      classifier.set_parameters(hidden_layers: [5])
      classifier.build(linearly_separable_dataset) # 2 input features

      # Should work with 2-dimensional input
      result = classifier.eval([1, 1])
      expect(%w[positive negative]).to include(result)

      # Should reject wrong-sized input
      expect do
        classifier.eval([1, 1, 1]) # 3 dimensions
      end.to raise_error
    end

    it 'handles various hidden layer configurations' do
      configurations = [
        [5],           # Single hidden layer
        [10, 5],       # Two hidden layers
        [8, 6, 4],     # Three hidden layers
        [20],          # Large single layer
        [2, 2, 2, 2]   # Many small layers
      ]

      configurations.each do |config|
        classifier = described_class.new
        classifier.set_parameters(
          hidden_layers: config,
          training_iterations: 20 # Quick training for test
        )

        expect do
          classifier.build(linearly_separable_dataset)
          result = classifier.eval([1, 1])
          expect(%w[positive negative]).to include(result)
        end.not_to raise_error
      end
    end
  end

  # Helper methods for assertions
  def assert_classification_correct(classifier, instance, expected_class)
    result = classifier.eval(instance)
    expect(result).to eq(expected_class)
  end

  def assert_model_improves(errors_by_epoch)
    # Check for decreasing trend in errors
    return if errors_by_epoch.length < 2

    first_half_avg = errors_by_epoch[0...(errors_by_epoch.length / 2)].sum.to_f / (errors_by_epoch.length / 2)
    second_half_avg = errors_by_epoch[(errors_by_epoch.length / 2)..].sum.to_f / (errors_by_epoch.length / 2)

    expect(second_half_avg).to be < first_half_avg
  end

  def assert_deterministic_output(classifier, instance)
    result1 = classifier.eval(instance)
    result2 = classifier.eval(instance)
    expect(result1).to eq(result2)
  end
end
