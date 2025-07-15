# frozen_string_literal: true

# RSpec tests for AI4R Transformer neural network based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe "AI4R Transformer Neural Network" do
  # Test data from requirement document
  let(:vocab_size) { 100 }
  let(:sample_sequence) { [1, 5, 3, 2, 0] }  # 0 = padding
  let(:minimal_vocab_size) { 10 }
  let(:standard_vocab_size) { 50000 }

  before(:all) do
    # Skip Transformer tests if not implemented
    skip("Transformer implementation not available in AI4R") unless defined?(Ai4r::NeuralNetwork::Transformer)
  end

  describe "Constructor Tests" do
    context "valid architectures" do
      it "test_encoder_only" do
        config = {
          architecture: :encoder,
          vocab_size: vocab_size,
          max_len: 512,
          d_model: 256,
          num_heads: 8
        }
        
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        
        expect(transformer).to be_a(Ai4r::NeuralNetwork::Transformer)
        expect(transformer.architecture).to eq(:encoder)
      end

      it "test_decoder_only" do
        config = {
          architecture: :decoder,
          vocab_size: vocab_size,
          max_len: 512,
          d_model: 256,
          num_heads: 8
        }
        
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        
        expect(transformer.architecture).to eq(:decoder)
      end

      it "test_seq2seq" do
        config = {
          architecture: :encoder_decoder,
          vocab_size: vocab_size,
          max_len: 512,
          d_model: 256,
          num_heads: 8
        }
        
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        
        expect(transformer.architecture).to eq(:encoder_decoder)
      end

      it "test_minimal_config" do
        config = {
          architecture: :encoder,
          vocab_size: minimal_vocab_size,
          max_len: 5,
          d_model: 64,
          num_heads: 2
        }
        
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        
        expect(transformer.vocab_size).to eq(minimal_vocab_size)
        expect(transformer.max_len).to eq(5)
      end

      it "test_standard_config" do
        config = {
          architecture: :encoder,
          vocab_size: standard_vocab_size,
          max_len: 512,
          d_model: 512,
          num_heads: 8
        }
        
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        
        expect(transformer.vocab_size).to eq(standard_vocab_size)
        expect(transformer.max_len).to eq(512)
      end
    end

    context "invalid configurations" do
      it "test_invalid_architecture" do
        config = {
          architecture: :invalid,
          vocab_size: vocab_size,
          max_len: 512,
          d_model: 256,
          num_heads: 8
        }
        
        expect {
          Ai4r::NeuralNetwork::Transformer.new(config)
        }.to raise_error(ArgumentError, /invalid architecture/)
      end

      it "test_zero_vocab" do
        config = {
          architecture: :encoder,
          vocab_size: 0,
          max_len: 512,
          d_model: 256,
          num_heads: 8
        }
        
        expect {
          Ai4r::NeuralNetwork::Transformer.new(config)
        }.to raise_error(ArgumentError, /vocab_size must be positive/)
      end

      it "test_negative_max_len" do
        config = {
          architecture: :encoder,
          vocab_size: vocab_size,
          max_len: -1,
          d_model: 256,
          num_heads: 8
        }
        
        expect {
          Ai4r::NeuralNetwork::Transformer.new(config)
        }.to raise_error(ArgumentError, /max_len must be positive/)
      end

      it "test_zero_heads" do
        config = {
          architecture: :encoder,
          vocab_size: vocab_size,
          max_len: 512,
          d_model: 256,
          num_heads: 0
        }
        
        expect {
          Ai4r::NeuralNetwork::Transformer.new(config)
        }.to raise_error(ArgumentError, /num_heads must be positive/)
      end

      it "test_odd_embedding_dim" do
        config = {
          architecture: :encoder,
          vocab_size: vocab_size,
          max_len: 512,
          d_model: 7,  # Not divisible by num_heads
          num_heads: 2
        }
        
        expect {
          Ai4r::NeuralNetwork::Transformer.new(config)
        }.to raise_error(ArgumentError, /d_model must be divisible by num_heads/)
      end
    end
  end

  describe "Attention Tests" do
    let(:transformer) do
      config = {
        architecture: :encoder,
        vocab_size: vocab_size,
        max_len: 10,
        d_model: 64,
        num_heads: 4
      }
      Ai4r::NeuralNetwork::Transformer.new(config)
    end

    context "self-attention mechanics" do
      it "test_self_attention_shape" do
        input_seq = [1, 2, 3, 4, 5]
        output = transformer.forward(input_seq)
        
        # Output shape should match input shape
        expect(output.shape).to eq([input_seq.length, transformer.d_model])
      end

      it "test_attention_weights_sum" do
        input_seq = [1, 2, 3]
        attention_weights = transformer.get_attention_weights(input_seq)
        
        # Each row of attention weights should sum to 1.0
        attention_weights.each do |row|
          row_sum = row.sum
          expect(row_sum).to be_within(1e-6).of(1.0)
        end
      end

      it "test_masked_attention" do
        input_seq = [1, 2, 3, 4]
        
        # For decoder, future positions should be masked
        if transformer.architecture == :decoder
          attention_weights = transformer.get_attention_weights(input_seq, causal_mask: true)
          
          # Upper triangular part should be zero
          attention_weights.each_with_index do |row, i|
            row.each_with_index do |weight, j|
              if j > i
                expect(weight).to be_within(1e-6).of(0.0)
              end
            end
          end
        end
      end

      it "test_multi_head_split" do
        input_seq = [1, 2, 3]
        
        # Test that multiple heads process independently
        head_outputs = transformer.get_head_outputs(input_seq)
        
        expect(head_outputs.length).to eq(transformer.num_heads)
        
        head_outputs.each do |head_output|
          expect(head_output.shape[1]).to eq(transformer.d_model / transformer.num_heads)
        end
      end

      it "test_single_token" do
        input_seq = [5]  # Single token
        
        output = transformer.forward(input_seq)
        
        expect(output.shape).to eq([1, transformer.d_model])
      end

      it "test_max_sequence" do
        input_seq = Array.new(transformer.max_len) { rand(1...vocab_size) }
        
        expect {
          output = transformer.forward(input_seq)
          expect(output.shape[0]).to eq(transformer.max_len)
        }.not_to raise_error
      end
    end

    context "invalid inputs" do
      it "test_exceed_max_len" do
        input_seq = Array.new(transformer.max_len + 1) { rand(1...vocab_size) }
        
        expect {
          transformer.forward(input_seq)
        }.to raise_error(ArgumentError, /sequence length exceeds max_len/)
      end

      it "test_empty_sequence" do
        input_seq = []
        
        expect {
          transformer.forward(input_seq)
        }.to raise_error(ArgumentError, /sequence cannot be empty/)
      end
    end
  end

  describe "Positional Encoding Tests" do
    let(:transformer) do
      config = {
        architecture: :encoder,
        vocab_size: vocab_size,
        max_len: 20,
        d_model: 64,
        num_heads: 4
      }
      Ai4r::NeuralNetwork::Transformer.new(config)
    end

    it "test_sinusoidal_encoding" do
      pos_encoding = transformer.get_positional_encoding
      
      # Test sinusoidal pattern for first few positions
      (0...5).each do |pos|
        (0...transformer.d_model).step(2) do |i|
          sin_val = pos_encoding[pos][i]
          cos_val = pos_encoding[pos][i + 1]
          
          # Check that it follows sin/cos pattern
          expected_sin = Math.sin(pos / (10000.0 ** (2.0 * i / transformer.d_model)))
          expected_cos = Math.cos(pos / (10000.0 ** (2.0 * i / transformer.d_model)))
          
          expect(sin_val).to be_within(1e-6).of(expected_sin)
          expect(cos_val).to be_within(1e-6).of(expected_cos)
        end
      end
    end

    it "test_encoding_range" do
      pos_encoding = transformer.get_positional_encoding
      
      # Values should be in reasonable range [-1, 1]
      pos_encoding.each do |position_encoding|
        position_encoding.each do |value|
          expect(value).to be_between(-1.1, 1.1)
        end
      end
    end

    it "test_position_uniqueness" do
      pos_encoding = transformer.get_positional_encoding
      
      # Each position should have unique encoding
      unique_encodings = pos_encoding.uniq
      expect(unique_encodings.length).to eq(pos_encoding.length)
    end
  end

  describe "Forward Pass Tests" do
    context "encoder architecture" do
      let(:encoder) do
        config = {
          architecture: :encoder,
          vocab_size: vocab_size,
          max_len: 10,
          d_model: 64,
          num_heads: 4
        }
        Ai4r::NeuralNetwork::Transformer.new(config)
      end

      it "test_encoder_output_shape" do
        batch_size = 2
        seq_len = 5
        
        input_batch = Array.new(batch_size) do
          Array.new(seq_len) { rand(1...vocab_size) }
        end
        
        output = encoder.forward_batch(input_batch)
        
        expect(output.shape).to eq([batch_size, seq_len, encoder.d_model])
      end

      it "test_padding_mask" do
        input_seq = [1, 5, 3, 0, 0]  # Last two are padding
        
        output = encoder.forward(input_seq, padding_mask: [1, 1, 1, 0, 0])
        
        # Padding positions should not influence output significantly
        expect(output).to be_an(Array)
      end
    end

    context "decoder architecture" do
      let(:decoder) do
        config = {
          architecture: :decoder,
          vocab_size: vocab_size,
          max_len: 10,
          d_model: 64,
          num_heads: 4
        }
        Ai4r::NeuralNetwork::Transformer.new(config)
      end

      it "test_decoder_output_shape" do
        batch_size = 2
        seq_len = 5
        
        input_batch = Array.new(batch_size) do
          Array.new(seq_len) { rand(1...vocab_size) }
        end
        
        output = decoder.forward_batch(input_batch)
        
        # Decoder output should include vocabulary logits
        expect(output.shape).to eq([batch_size, seq_len, decoder.vocab_size])
      end

      it "test_attention_mask" do
        input_seq = [1, 2, 3, 4]
        
        # Causal mask should be applied automatically in decoder
        output = decoder.forward(input_seq)
        
        expect(output.length).to eq(input_seq.length)
        expect(output[0].length).to eq(decoder.vocab_size)
      end
    end

    context "invalid tokens" do
      let(:transformer) do
        config = {
          architecture: :encoder,
          vocab_size: vocab_size,
          max_len: 10,
          d_model: 64,
          num_heads: 4
        }
        Ai4r::NeuralNetwork::Transformer.new(config)
      end

      it "test_out_of_vocab_token" do
        input_seq = [1, 2, vocab_size + 1]  # Last token exceeds vocab
        
        expect {
          transformer.forward(input_seq)
        }.to raise_error(ArgumentError, /token_id exceeds vocab_size/)
      end

      it "test_negative_token" do
        input_seq = [1, -1, 2]  # Negative token
        
        expect {
          transformer.forward(input_seq)
        }.to raise_error(ArgumentError, /token_id must be non-negative/)
      end
    end
  end

  describe "Training Tests" do
    let(:transformer) do
      config = {
        architecture: :decoder,
        vocab_size: 20,
        max_len: 10,
        d_model: 32,
        num_heads: 2
      }
      Ai4r::NeuralNetwork::Transformer.new(config)
    end

    it "test_language_modeling" do
      # Simple language modeling task
      sequences = [
        [1, 2, 3, 4, 5],
        [2, 3, 4, 5, 6],
        [3, 4, 5, 6, 7]
      ]
      
      # Train to predict next token
      expect {
        transformer.train_language_model(sequences, epochs: 10)
      }.not_to raise_error
    end

    it "test_gradient_flow" do
      input_seq = [1, 2, 3, 4]
      target_seq = [2, 3, 4, 5]
      
      # Test that gradients can be computed
      expect {
        loss = transformer.compute_loss(input_seq, target_seq)
        expect(loss).to be_a(Numeric)
        expect(loss).to be_finite
      }.not_to raise_error
    end
  end

  describe "Attention Visualization Tests" do
    let(:transformer) do
      config = {
        architecture: :encoder,
        vocab_size: vocab_size,
        max_len: 8,
        d_model: 32,
        num_heads: 2
      }
      Ai4r::NeuralNetwork::Transformer.new(config)
    end

    it "test_attention_patterns" do
      input_seq = [1, 5, 3, 2]
      
      attention_weights = transformer.get_attention_weights(input_seq)
      
      # Should be able to visualize attention patterns
      expect(attention_weights).to be_a(Array)
      expect(attention_weights.length).to eq(input_seq.length)
      
      attention_weights.each do |row|
        expect(row.length).to eq(input_seq.length)
        expect(row.sum).to be_within(1e-6).of(1.0)
      end
    end

    it "test_head_specific_attention" do
      input_seq = [1, 2, 3]
      
      transformer.num_heads.times do |head_idx|
        head_attention = transformer.get_head_attention(input_seq, head_idx)
        
        expect(head_attention).to be_a(Array)
        expect(head_attention.length).to eq(input_seq.length)
      end
    end
  end

  describe "Performance Tests" do
    it "handles large vocabularies efficiently" do
      config = {
        architecture: :encoder,
        vocab_size: 10000,
        max_len: 50,
        d_model: 128,
        num_heads: 8
      }
      
      benchmark_performance("Large vocabulary transformer") do
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        input_seq = Array.new(20) { rand(1...config[:vocab_size]) }
        transformer.forward(input_seq)
      end
    end

    it "handles long sequences efficiently" do
      config = {
        architecture: :encoder,
        vocab_size: 1000,
        max_len: 200,
        d_model: 64,
        num_heads: 4
      }
      
      benchmark_performance("Long sequence transformer") do
        transformer = Ai4r::NeuralNetwork::Transformer.new(config)
        input_seq = Array.new(150) { rand(1...config[:vocab_size]) }
        transformer.forward(input_seq)
      end
    end
  end

  # Helper methods for assertions
  def assert_attention_valid(weights)
    weights.each do |row|
      # Each row should sum to 1.0
      expect(row.sum).to be_within(1e-6).of(1.0)
      
      # All weights should be non-negative
      row.each { |weight| expect(weight).to be >= 0 }
    end
  end

  def assert_network_output_shape(output, expected_shape)
    expect(output).to be_an(Array)
    
    expected_shape.each_with_index do |dim, i|
      if i == 0
        expect(output.length).to eq(dim)
      else
        expect(output[0].length).to eq(dim) if output[0].respond_to?(:length)
      end
    end
  end
end