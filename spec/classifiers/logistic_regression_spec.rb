# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::LogisticRegression do
  let(:classifier) { described_class.new }
  
  describe '#initialize' do
    it 'initializes with correct default values' do
      expect(classifier.weights).to eq([])
      expect(classifier.bias).to eq(0.0)
      expect(classifier.learning_rate).to eq(0.01)
      expect(classifier.regularization_type).to eq(:none)
      expect(classifier.lambda).to eq(0.0)
      expect(classifier.cost_history).to eq([])
      expect(classifier.iteration_count).to eq(0)
    end
  end

  describe '#configure' do
    it 'sets learning rate' do
      classifier.configure(learning_rate: 0.1)
      expect(classifier.learning_rate).to eq(0.1)
    end

    it 'sets regularization parameters' do
      classifier.configure(regularization: :l2, lambda: 0.5)
      expect(classifier.regularization_type).to eq(:l2)
      expect(classifier.lambda).to eq(0.5)
    end

    it 'accepts multiple parameters' do
      classifier.configure(
        learning_rate: 0.05,
        max_iterations: 500,
        tolerance: 1e-4,
        normalize_features: false
      )
      expect(classifier.learning_rate).to eq(0.05)
      expect(classifier.instance_variable_get(:@max_iterations)).to eq(500)
      expect(classifier.instance_variable_get(:@tolerance)).to eq(1e-4)
      expect(classifier.instance_variable_get(:@normalize_features)).to eq(false)
    end

    it 'returns self for chaining' do
      expect(classifier.configure(learning_rate: 0.1)).to eq(classifier)
    end

    it 'raises error for invalid learning rate' do
      expect { classifier.configure(learning_rate: -0.1) }.to raise_error(ArgumentError, 'Learning rate must be positive')
    end

    it 'raises error for invalid regularization type' do
      expect { classifier.configure(regularization: :invalid) }.to raise_error(ArgumentError, /Unsupported regularization/)
    end
  end

  describe '#enable_educational_mode' do
    it 'enables educational mode' do
      # Capture stdout to avoid test output pollution
      original_stdout = $stdout
      $stdout = StringIO.new
      
      classifier.enable_educational_mode
      expect(classifier.educational_mode).to be true
      expect(classifier.instance_variable_get(:@verbose)).to be true
      
      $stdout = original_stdout
    end

    it 'returns self for chaining' do
      original_stdout = $stdout
      $stdout = StringIO.new
      
      expect(classifier.enable_educational_mode).to eq(classifier)
      
      $stdout = original_stdout
    end
  end

  describe '#build' do
    context 'with binary classification data' do
      let(:binary_data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x1', 'x2', 'class'],
          data_items: [
            [0.5, 0.5, 'A'],
            [1.5, 0.5, 'A'],
            [3.0, 3.5, 'B'],
            [4.0, 3.0, 'B'],
            [3.5, 4.5, 'B']
          ]
        )
      end

      it 'trains binary classifier' do
        classifier.configure(max_iterations: 100)
        classifier.build(binary_data)
        
        expect(classifier.class_labels).to eq(['A', 'B'])
        expect(classifier.weights.length).to eq(2)
        expect(classifier.cost_history).not_to be_empty
        expect(classifier.iteration_count).to be > 0
      end

      it 'normalizes features when enabled' do
        classifier.configure(normalize_features: true)
        classifier.build(binary_data)
        
        feature_means = classifier.instance_variable_get(:@feature_means)
        feature_stds = classifier.instance_variable_get(:@feature_stds)
        
        expect(feature_means).not_to be_empty
        expect(feature_stds).not_to be_empty
      end

      it 'converges with proper configuration' do
        classifier.configure(learning_rate: 0.5, max_iterations: 1000, tolerance: 1e-6)
        classifier.build(binary_data)
        
        # Check cost decreased
        expect(classifier.cost_history.last).to be < classifier.cost_history.first
      end
    end

    context 'with multinomial classification data' do
      let(:multi_data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x1', 'x2', 'class'],
          data_items: [
            [1.0, 1.0, 'A'],
            [1.5, 1.5, 'A'],
            [3.0, 1.0, 'B'],
            [3.5, 1.5, 'B'],
            [2.0, 3.0, 'C'],
            [2.5, 3.5, 'C']
          ]
        )
      end

      it 'trains multinomial classifier' do
        classifier.configure(max_iterations: 200)
        classifier.build(multi_data)
        
        expect(classifier.class_labels).to eq(['A', 'B', 'C'])
        expect(classifier.weights.length).to eq(3)  # One set of weights per class
        expect(classifier.weights.first.length).to eq(2)  # Two features
      end
    end

    context 'with regularization' do
      let(:data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x1', 'x2', 'x3', 'x4', 'class'],
          data_items: [
            [1, 2, 3, 4, 'pos'],
            [2, 3, 4, 5, 'pos'],
            [5, 4, 3, 2, 'neg'],
            [4, 3, 2, 1, 'neg']
          ]
        )
      end

      it 'applies L1 regularization' do
        classifier.configure(regularization: :l1, lambda: 0.1, max_iterations: 100)
        classifier.build(data)
        
        # L1 should create sparse weights
        zero_weights = classifier.weights.count { |w| w.abs < 0.01 }
        expect(zero_weights).to be > 0
      end

      it 'applies L2 regularization' do
        classifier.configure(regularization: :l2, lambda: 0.1, max_iterations: 100)
        classifier.build(data)
        
        # L2 should prevent extreme weight values
        expect(classifier.weights.all? { |w| w.abs < 10 }).to be true
      end

      it 'applies elastic net regularization' do
        classifier.configure(regularization: :elastic_net, lambda: 0.1, max_iterations: 100)
        classifier.build(data)
        
        expect(classifier.weights).not_to be_empty
      end
    end

    it 'returns self for chaining' do
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y'],
        data_items: [[1, 'A'], [2, 'B']]
      )
      expect(classifier.build(data)).to eq(classifier)
    end
  end

  describe '#eval' do
    let(:training_data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 1, 'red'],
          [2, 2, 'red'],
          [5, 5, 'blue'],
          [6, 6, 'blue']
        ]
      )
    end

    before do
      classifier.configure(max_iterations: 200, learning_rate: 0.1)
      classifier.build(training_data)
    end

    it 'predicts correct class for clear cases' do
      expect(classifier.eval([1.5, 1.5])).to eq('red')
      expect(classifier.eval([5.5, 5.5])).to eq('blue')
    end

    it 'handles boundary cases' do
      # Point near decision boundary
      prediction = classifier.eval([3.5, 3.5])
      expect(['red', 'blue']).to include(prediction)
    end

    it 'returns nil for untrained classifier' do
      untrained = described_class.new
      expect(untrained.eval([1, 2])).to be_nil
    end
  end

  describe '#predict_with_probabilities' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['feature', 'class'],
        data_items: [
          [1, 'A'],
          [2, 'A'],
          [8, 'B'],
          [9, 'B']
        ]
      )
    end

    before do
      classifier.configure(max_iterations: 200)
      classifier.build(data)
    end

    it 'returns prediction with probabilities' do
      result = classifier.predict_with_probabilities([1.5])
      
      expect(result).to have_key(:prediction)
      expect(result).to have_key(:probabilities)
      expect(result).to have_key(:confidence)
      
      expect(result[:prediction]).to eq('A')
      expect(result[:probabilities]['A']).to be > result[:probabilities]['B']
      expect(result[:confidence]).to be_between(0.5, 1.0)
    end

    it 'probabilities sum to 1' do
      result = classifier.predict_with_probabilities([5])
      prob_sum = result[:probabilities].values.sum
      expect(prob_sum).to be_within(0.001).of(1.0)
    end

    context 'with multinomial classification' do
      let(:multi_data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x', 'y', 'class'],
          data_items: [
            [1, 1, 'A'],
            [5, 1, 'B'],
            [3, 5, 'C']
          ] * 3  # Repeat for better training
        )
      end

      before do
        classifier.build(multi_data)
      end

      it 'returns probabilities for all classes' do
        result = classifier.predict_with_probabilities([3, 3])
        
        expect(result[:probabilities].keys.sort).to eq(['A', 'B', 'C'])
        expect(result[:probabilities].values.sum).to be_within(0.001).of(1.0)
      end
    end
  end

  describe '#calculate_feature_importance' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['important', 'noise', 'class'],
        data_items: [
          [10, rand, 'pos'],
          [20, rand, 'pos'],
          [-10, rand, 'neg'],
          [-20, rand, 'neg']
        ] * 5  # Repeat for stable training
      )
    end

    before do
      classifier.configure(max_iterations: 300)
      classifier.build(data)
    end

    it 'calculates feature importance' do
      importance = classifier.calculate_feature_importance
      
      expect(importance).to be_an(Array)
      expect(importance.length).to eq(2)
      
      # First feature should be more important
      expect(importance[0]).to be > importance[1]
    end

    it 'returns empty array for untrained classifier' do
      untrained = described_class.new
      expect(untrained.calculate_feature_importance).to eq([])
    end
  end

  describe '#plot_cost_history' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'class'],
        data_items: [[1, 'A'], [2, 'B']] * 5
      )
    end

    it 'outputs cost history' do
      classifier.configure(max_iterations: 10)
      classifier.build(data)
      
      output = capture_stdout { classifier.plot_cost_history }
      
      expect(output).to include('Cost Function History')
      expect(output).to include('Iteration')
      expect(output).to include('Final cost:')
      expect(output).to include('Total iterations:')
    end
  end

  describe '#evaluate_performance' do
    let(:training_data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 1, 'A'],
          [2, 1, 'A'],
          [5, 5, 'B'],
          [6, 5, 'B']
        ] * 3  # Repeat for better training
      )
    end

    let(:test_data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1.5, 1, 'A'],
          [5.5, 5, 'B']
        ]
      )
    end

    before do
      classifier.configure(max_iterations: 200)
      classifier.build(training_data)
    end

    it 'evaluates performance metrics' do
      performance = classifier.evaluate_performance(test_data)
      
      expect(performance).to have_key(:accuracy)
      expect(performance).to have_key(:log_loss)
      expect(performance).to have_key(:class_metrics)
      expect(performance).to have_key(:predictions)
      expect(performance).to have_key(:actual_labels)
      
      expect(performance[:accuracy]).to be_between(0, 1)
      expect(performance[:log_loss]).to be >= 0
    end

    it 'calculates class-specific metrics' do
      performance = classifier.evaluate_performance(test_data)
      
      expect(performance[:class_metrics]).to have_key('A')
      expect(performance[:class_metrics]).to have_key('B')
      
      performance[:class_metrics].each do |_class, metrics|
        expect(metrics).to have_key(:precision)
        expect(metrics).to have_key(:recall)
        expect(metrics).to have_key(:f1_score)
        expect(metrics).to have_key(:support)
      end
    end

    it 'handles perfect predictions' do
      perfect_test = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 1, 'A'],
          [6, 5, 'B']
        ]
      )
      
      performance = classifier.evaluate_performance(perfect_test)
      expect(performance[:accuracy]).to eq(1.0)
    end
  end

  describe 'integration tests' do
    it 'handles linearly separable data perfectly' do
      # Create clearly separable data
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'class'],
        data_items: [
          [-2, 'neg'],
          [-1, 'neg'],
          [1, 'pos'],
          [2, 'pos']
        ] * 5
      )
      
      classifier.configure(learning_rate: 0.1, max_iterations: 500)
      classifier.build(data)
      
      expect(classifier.eval([-1.5])).to eq('neg')
      expect(classifier.eval([1.5])).to eq('pos')
    end

    it 'handles XOR problem with sufficient features' do
      # XOR problem with polynomial features
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x1', 'x2', 'x1x2', 'class'],
        data_items: [
          [0, 0, 0, 'A'],
          [0, 1, 0, 'B'],
          [1, 0, 0, 'B'],
          [1, 1, 1, 'A']
        ] * 10
      )
      
      classifier.configure(learning_rate: 0.5, max_iterations: 1000)
      classifier.build(data)
      
      expect(classifier.eval([0, 0, 0])).to eq('A')
      expect(classifier.eval([0, 1, 0])).to eq('B')
      expect(classifier.eval([1, 0, 0])).to eq('B')
      expect(classifier.eval([1, 1, 1])).to eq('A')
    end

    it 'handles imbalanced classes' do
      # 90% class A, 10% class B
      data_items = []
      90.times { data_items << [rand, 'A'] }
      10.times { data_items << [rand + 5, 'B'] }
      
      data = Ai4r::Data::DataSet.new(
        data_labels: ['feature', 'class'],
        data_items: data_items
      )
      
      classifier.configure(max_iterations: 500)
      classifier.build(data)
      
      # Should still identify class B for high values
      expect(classifier.eval([6])).to eq('B')
    end

    it 'prevents overfitting with regularization' do
      # Small dataset with many features (prone to overfitting)
      data = Ai4r::Data::DataSet.new(
        data_labels: ['f1', 'f2', 'f3', 'f4', 'f5', 'class'],
        data_items: [
          [1, 2, 3, 4, 5, 'A'],
          [2, 3, 4, 5, 6, 'A'],
          [5, 4, 3, 2, 1, 'B'],
          [6, 5, 4, 3, 2, 'B']
        ]
      )
      
      # Train without regularization
      classifier_no_reg = described_class.new
      classifier_no_reg.configure(max_iterations: 1000, regularization: :none)
      classifier_no_reg.build(data)
      
      # Train with L2 regularization
      classifier_reg = described_class.new
      classifier_reg.configure(max_iterations: 1000, regularization: :l2, lambda: 1.0)
      classifier_reg.build(data)
      
      # Regularized weights should be smaller in magnitude
      weights_no_reg = classifier_no_reg.weights.map(&:abs).sum
      weights_reg = classifier_reg.weights.map(&:abs).sum
      
      expect(weights_reg).to be < weights_no_reg
    end
  end

  # Helper method to capture stdout
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end