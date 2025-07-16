# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::SupportVectorMachine do
  let(:classifier) { described_class.new }
  
  describe '#initialize' do
    it 'initializes with correct default values' do
      expect(classifier.kernel_type).to eq(:rbf)
      expect(classifier.kernel_params).to eq({ gamma: 1.0 })
      expect(classifier.c_parameter).to eq(1.0)
      expect(classifier.support_vectors).to eq([])
      expect(classifier.alphas).to eq([])
      expect(classifier.bias).to eq(0.0)
    end
  end

  describe '#configure' do
    it 'sets kernel type and parameters' do
      classifier.configure(kernel: :linear)
      expect(classifier.kernel_type).to eq(:linear)
      
      classifier.configure(kernel: :polynomial, degree: 3, coef0: 1.0)
      expect(classifier.kernel_type).to eq(:polynomial)
      expect(classifier.kernel_params[:degree]).to eq(3)
      expect(classifier.kernel_params[:coef0]).to eq(1.0)
    end

    it 'sets C parameter' do
      classifier.configure(c: 10.0)
      expect(classifier.c_parameter).to eq(10.0)
    end

    it 'accepts capital C' do
      classifier.configure(C: 5.0)
      expect(classifier.c_parameter).to eq(5.0)
    end

    it 'sets tolerance and max iterations' do
      classifier.configure(tolerance: 1e-4, max_iterations: 500)
      expect(classifier.instance_variable_get(:@tolerance)).to eq(1e-4)
      expect(classifier.instance_variable_get(:@max_iterations)).to eq(500)
    end

    it 'returns self for chaining' do
      expect(classifier.configure(c: 1.0)).to eq(classifier)
    end

    it 'raises error for invalid C parameter' do
      expect { classifier.configure(c: -1.0) }.to raise_error(ArgumentError, 'C parameter must be positive')
    end

    it 'raises error for invalid kernel' do
      expect { classifier.configure(kernel: :invalid) }.to raise_error(ArgumentError, /Unsupported kernel/)
    end
  end

  describe '#enable_educational_mode' do
    it 'enables educational mode' do
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
    context 'with linearly separable data' do
      let(:linear_data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x', 'y', 'class'],
          data_items: [
            [1, 1, 'A'],
            [2, 2, 'A'],
            [1, 2, 'A'],
            [5, 5, 'B'],
            [6, 6, 'B'],
            [5, 6, 'B']
          ]
        )
      end

      it 'trains with linear kernel' do
        classifier.configure(kernel: :linear, c: 1.0)
        classifier.build(linear_data)
        
        expect(classifier.support_vectors).not_to be_empty
        expect(classifier.alphas).not_to be_empty
        expect(classifier.support_vector_indices).not_to be_empty
      end

      it 'identifies support vectors correctly' do
        classifier.configure(kernel: :linear, c: 100.0) # High C for hard margin
        classifier.build(linear_data)
        
        # Support vectors should be near the boundary
        sv_info = classifier.get_support_vectors_info
        expect(sv_info[:count]).to be > 0
        expect(sv_info[:count]).to be < linear_data.data_items.length
      end
    end

    context 'with non-linearly separable data' do
      let(:circular_data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x', 'y', 'class'],
          data_items: [
            # Inner circle - class A
            [0, 0, 'A'],
            [0.5, 0.5, 'A'],
            [-0.5, 0.5, 'A'],
            [0.5, -0.5, 'A'],
            # Outer ring - class B
            [3, 0, 'B'],
            [0, 3, 'B'],
            [-3, 0, 'B'],
            [0, -3, 'B'],
            [2, 2, 'B'],
            [-2, 2, 'B']
          ]
        )
      end

      it 'trains with RBF kernel' do
        classifier.configure(kernel: :rbf, gamma: 0.5, c: 1.0)
        classifier.build(circular_data)
        
        expect(classifier.support_vectors).not_to be_empty
        
        # Should correctly classify points
        expect(classifier.eval([0, 0])).to eq('A')
        expect(classifier.eval([3, 3])).to eq('B')
      end

      it 'trains with polynomial kernel' do
        classifier.configure(kernel: :polynomial, degree: 2, c: 1.0)
        classifier.build(circular_data)
        
        expect(classifier.support_vectors).not_to be_empty
      end
    end

    context 'with soft margin' do
      let(:noisy_data) do
        Ai4r::Data::DataSet.new(
          data_labels: ['x', 'y', 'class'],
          data_items: [
            [1, 1, 'A'],
            [2, 2, 'A'],
            [3, 3, 'B'], # Overlapping point
            [4, 4, 'B'],
            [5, 5, 'B']
          ]
        )
      end

      it 'handles overlapping classes with low C' do
        classifier.configure(kernel: :linear, c: 0.1)
        classifier.build(noisy_data)
        
        # Should train successfully despite overlap
        expect(classifier.support_vectors).not_to be_empty
      end

      it 'creates harder margin with high C' do
        classifier_soft = described_class.new.configure(kernel: :linear, c: 0.1)
        classifier_hard = described_class.new.configure(kernel: :linear, c: 100.0)
        
        classifier_soft.build(noisy_data)
        classifier_hard.build(noisy_data)
        
        # Hard margin should have different behavior
        expect(classifier_soft.support_vectors.length).to be >= classifier_hard.support_vectors.length
      end
    end

    it 'returns self for chaining' do
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'class'],
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
          [-2, -2, 'neg'],
          [-1, -1, 'neg'],
          [1, 1, 'pos'],
          [2, 2, 'pos']
        ]
      )
    end

    before do
      classifier.configure(kernel: :linear, c: 1.0)
      classifier.build(training_data)
    end

    it 'predicts correct class' do
      expect(classifier.eval([-1.5, -1.5])).to eq('neg')
      expect(classifier.eval([1.5, 1.5])).to eq('pos')
    end

    it 'handles boundary cases' do
      prediction = classifier.eval([0, 0])
      expect(['neg', 'pos']).to include(prediction)
    end

    it 'returns nil for untrained classifier' do
      untrained = described_class.new
      expect(untrained.eval([1, 2])).to be_nil
    end
  end

  describe '#decision_function' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'class'],
        data_items: [
          [-2, 'A'],
          [-1, 'A'],
          [1, 'B'],
          [2, 'B']
        ]
      )
    end

    before do
      classifier.configure(kernel: :linear)
      classifier.build(data)
    end

    it 'returns positive values for positive class' do
      expect(classifier.decision_function([1.5])).to be > 0
    end

    it 'returns negative values for negative class' do
      expect(classifier.decision_function([-1.5])).to be < 0
    end

    it 'returns near-zero for points on decision boundary' do
      # Find approximate boundary
      boundary = classifier.decision_function([0])
      expect(boundary.abs).to be < 1.0
    end
  end

  describe '#predict_with_confidence' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 1, 'A'],
          [2, 1, 'A'],
          [5, 5, 'B'],
          [6, 5, 'B']
        ]
      )
    end

    before do
      classifier.configure(kernel: :rbf, gamma: 0.5)
      classifier.build(data)
    end

    it 'returns prediction with confidence metrics' do
      result = classifier.predict_with_confidence([1.5, 1])
      
      expect(result).to have_key(:prediction)
      expect(result).to have_key(:decision_value)
      expect(result).to have_key(:confidence)
      expect(result).to have_key(:distance_from_margin)
      
      expect(result[:prediction]).to eq('A')
      expect(result[:confidence]).to be_between(0, 1)
      expect(result[:distance_from_margin]).to be >= 0
    end

    it 'gives high confidence for clear cases' do
      far_from_boundary = classifier.predict_with_confidence([1, 1])
      near_boundary = classifier.predict_with_confidence([3.5, 3])
      
      expect(far_from_boundary[:confidence]).to be > near_boundary[:confidence]
    end
  end

  describe '#get_support_vectors_info' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 1, 'A'],
          [2, 2, 'A'],
          [4, 4, 'B'],
          [5, 5, 'B']
        ]
      )
    end

    before do
      classifier.configure(kernel: :linear)
      classifier.build(data)
    end

    it 'returns support vector information' do
      info = classifier.get_support_vectors_info
      
      expect(info).to have_key(:count)
      expect(info).to have_key(:percentage)
      expect(info).to have_key(:indices)
      expect(info).to have_key(:alpha_values)
      expect(info).to have_key(:support_vectors)
      
      expect(info[:count]).to be > 0
      expect(info[:percentage]).to be > 0
      expect(info[:percentage]).to be <= 100
    end

    it 'returns empty hash for untrained classifier' do
      untrained = described_class.new
      expect(untrained.get_support_vectors_info).to eq({})
    end
  end

  describe 'kernel functions' do
    let(:data) do
      Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 0, 'A'],
          [0, 1, 'A'],
          [-1, 0, 'B'],
          [0, -1, 'B']
        ]
      )
    end

    it 'works with linear kernel' do
      classifier.configure(kernel: :linear)
      classifier.build(data)
      expect(classifier.support_vectors).not_to be_empty
    end

    it 'works with polynomial kernel' do
      classifier.configure(kernel: :polynomial, degree: 2, coef0: 0.0)
      classifier.build(data)
      expect(classifier.support_vectors).not_to be_empty
    end

    it 'works with RBF kernel' do
      classifier.configure(kernel: :rbf, gamma: 1.0)
      classifier.build(data)
      expect(classifier.support_vectors).not_to be_empty
    end

    it 'works with sigmoid kernel' do
      classifier.configure(kernel: :sigmoid, gamma: 0.1, coef0: 0.0)
      classifier.build(data)
      expect(classifier.support_vectors).not_to be_empty
    end
  end

  describe 'integration tests' do
    it 'handles XOR problem with appropriate kernel' do
      xor_data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [0, 0, 'A'],
          [1, 1, 'A'],
          [0, 1, 'B'],
          [1, 0, 'B']
        ] * 3  # Repeat for stable training
      )
      
      # RBF kernel should handle XOR
      classifier.configure(kernel: :rbf, gamma: 10.0, c: 100.0)
      classifier.build(xor_data)
      
      expect(classifier.eval([0, 0])).to eq('A')
      expect(classifier.eval([1, 1])).to eq('A')
      expect(classifier.eval([0, 1])).to eq('B')
      expect(classifier.eval([1, 0])).to eq('B')
    end

    it 'handles imbalanced classes' do
      # 80% class A, 20% class B
      imbalanced_data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'class'],
        data_items: 
          Array.new(8) { |i| [i, 'A'] } +
          Array.new(2) { |i| [i + 10, 'B'] }
      )
      
      classifier.configure(kernel: :linear, c: 1.0)
      classifier.build(imbalanced_data)
      
      # Should still identify minority class
      expect(classifier.eval([11])).to eq('B')
    end

    it 'scales to higher dimensions' do
      # 5-dimensional data
      high_dim_data = Ai4r::Data::DataSet.new(
        data_labels: ['f1', 'f2', 'f3', 'f4', 'f5', 'class'],
        data_items: [
          [1, 1, 1, 1, 1, 'A'],
          [2, 2, 2, 2, 2, 'A'],
          [-1, -1, -1, -1, -1, 'B'],
          [-2, -2, -2, -2, -2, 'B']
        ] * 2
      )
      
      classifier.configure(kernel: :linear)
      classifier.build(high_dim_data)
      
      expect(classifier.eval([1.5, 1.5, 1.5, 1.5, 1.5])).to eq('A')
      expect(classifier.eval([-1.5, -1.5, -1.5, -1.5, -1.5])).to eq('B')
    end

    it 'provides consistent results across runs' do
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [
          [1, 1, 'A'],
          [2, 2, 'A'],
          [5, 5, 'B'],
          [6, 6, 'B']
        ]
      )
      
      # Train multiple times
      results = []
      3.times do
        svm = described_class.new
        svm.configure(kernel: :rbf, gamma: 0.5, c: 1.0)
        svm.build(data)
        results << svm.eval([3.5, 3.5])
      end
      
      # Should give consistent predictions
      expect(results.uniq.length).to eq(1)
    end
  end

  describe '#visualize_decision_boundary' do
    it 'works for 2D data' do
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'class'],
        data_items: [[1, 1, 'A'], [2, 2, 'B']]
      )
      
      classifier.build(data)
      
      output = capture_stdout { classifier.visualize_decision_boundary(10) }
      expect(output).to include('Decision Boundary Visualization')
    end

    it 'returns early for non-2D data' do
      data = Ai4r::Data::DataSet.new(
        data_labels: ['x', 'y', 'z', 'class'],
        data_items: [[1, 1, 1, 'A'], [2, 2, 2, 'B']]
      )
      
      classifier.build(data)
      
      output = capture_stdout { classifier.visualize_decision_boundary }
      expect(output).to be_empty
    end
  end

  # Helper method
  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end