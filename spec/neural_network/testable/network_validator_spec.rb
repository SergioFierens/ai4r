# frozen_string_literal: true

require 'spec_helper'
require 'ai4r/neural_network/testable/network_validator'

RSpec.describe Ai4r::NeuralNetwork::Testable::NetworkValidator do
  let(:validator) { described_class.new }

  describe '#validate_structure' do
    context 'with valid structure' do
      it 'accepts simple 2-layer network' do
        expect { validator.validate_structure([2, 1]) }.not_to raise_error
      end

      it 'accepts multi-layer network' do
        expect { validator.validate_structure([784, 128, 64, 10]) }.not_to raise_error
      end
    end

    context 'with invalid structure' do
      it 'rejects nil structure' do
        expect { validator.validate_structure(nil) }
          .to raise_error(ArgumentError, 'Network structure cannot be nil')
      end

      it 'rejects empty structure' do
        expect { validator.validate_structure([]) }
          .to raise_error(ArgumentError, 'Network structure cannot be empty')
      end

      it 'rejects single layer' do
        expect { validator.validate_structure([10]) }
          .to raise_error(ArgumentError, 'Network must have at least 2 layers')
      end

      it 'rejects non-positive layer sizes' do
        expect { validator.validate_structure([2, 0, 1]) }
          .to raise_error(ArgumentError, /Layer 1 size must be a positive integer/)
      end

      it 'rejects non-integer layer sizes' do
        expect { validator.validate_structure([2, 2.5, 1]) }
          .to raise_error(ArgumentError, /Layer 1 size must be a positive integer/)
      end
    end
  end

  describe '#validate_input' do
    context 'with valid input' do
      it 'accepts matching input size' do
        expect { validator.validate_input([0.5, 0.7], 2) }.not_to raise_error
      end

      it 'accepts integer values' do
        expect { validator.validate_input([1, 2, 3], 3) }.not_to raise_error
      end
    end

    context 'with invalid input' do
      it 'rejects nil input' do
        expect { validator.validate_input(nil, 2) }
          .to raise_error(ArgumentError, 'Input cannot be nil')
      end

      it 'rejects non-array input' do
        expect { validator.validate_input('not an array', 2) }
          .to raise_error(ArgumentError, 'Input must be an array')
      end

      it 'rejects mismatched size' do
        expect { validator.validate_input([0.5], 2) }
          .to raise_error(ArgumentError, 'Input size mismatch. Expected 2, got 1')
      end

      it 'rejects non-numeric values' do
        expect { validator.validate_input(['a', 'b'], 2) }
          .to raise_error(ArgumentError, /Input\[0\] must be numeric/)
      end

      it 'rejects NaN values' do
        expect { validator.validate_input([Float::NAN, 0.5], 2) }
          .to raise_error(ArgumentError, /Input\[0\] must be finite/)
      end

      it 'rejects infinite values' do
        expect { validator.validate_input([Float::INFINITY, 0.5], 2) }
          .to raise_error(ArgumentError, /Input\[0\] must be finite/)
      end
    end
  end

  describe '#validate_output' do
    context 'with valid output' do
      it 'accepts matching output size' do
        expect { validator.validate_output([0.1, 0.9], 2) }.not_to raise_error
      end
    end

    context 'with invalid output' do
      it 'rejects nil output' do
        expect { validator.validate_output(nil, 1) }
          .to raise_error(ArgumentError, 'Output cannot be nil')
      end

      it 'rejects mismatched size' do
        expect { validator.validate_output([0.5, 0.5], 1) }
          .to raise_error(ArgumentError, 'Output size mismatch. Expected 1, got 2')
      end
    end
  end

  describe '#validate_training_data' do
    let(:valid_data) do
      [
        { input: [0, 0], output: [0] },
        { input: [0, 1], output: [1] },
        { input: [1, 0], output: [1] },
        { input: [1, 1], output: [0] }
      ]
    end

    context 'with valid training data' do
      it 'accepts well-formed data' do
        expect { validator.validate_training_data(valid_data, 2, 1) }.not_to raise_error
      end
    end

    context 'with invalid training data' do
      it 'rejects nil data' do
        expect { validator.validate_training_data(nil, 2, 1) }
          .to raise_error(ArgumentError, 'Training data cannot be nil')
      end

      it 'rejects empty data' do
        expect { validator.validate_training_data([], 2, 1) }
          .to raise_error(ArgumentError, 'Training data cannot be empty')
      end

      it 'rejects non-array data' do
        expect { validator.validate_training_data('not an array', 2, 1) }
          .to raise_error(ArgumentError, 'Training data must be an array')
      end

      it 'rejects missing input key' do
        data = [{ output: [0] }]
        expect { validator.validate_training_data(data, 2, 1) }
          .to raise_error(ArgumentError, /must have :input and :output keys/)
      end

      it 'rejects mismatched input size' do
        data = [{ input: [0], output: [0] }]
        expect { validator.validate_training_data(data, 2, 1) }
          .to raise_error(ArgumentError, /Training example 0:.*Input size mismatch/)
      end

      it 'rejects invalid values in training data' do
        data = [{ input: [0, 'invalid'], output: [0] }]
        expect { validator.validate_training_data(data, 2, 1) }
          .to raise_error(ArgumentError, /Training example 0:.*must be numeric/)
      end
    end
  end

  describe 'edge cases' do
    it 'handles very large networks' do
      structure = Array.new(100) { rand(1..1000) }
      expect { validator.validate_structure(structure) }.not_to raise_error
    end

    it 'provides clear error messages with context' do
      data = [
        { input: [0, 0], output: [0] },
        { input: [0, Float::NAN], output: [1] }
      ]
      
      expect { validator.validate_training_data(data, 2, 1) }
        .to raise_error(ArgumentError, /Training example 1:.*Input\[1\] must be finite/)
    end
  end
end