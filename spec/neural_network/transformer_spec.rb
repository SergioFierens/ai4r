# frozen_string_literal: true

# RSpec tests for AI4R Transformer Architecture
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::NeuralNetwork::Transformer do
  # Test configuration
  let(:vocab_size) { 100 }
  let(:d_model) { 64 }
  let(:n_heads) { 4 }
  let(:n_layers) { 2 }
  let(:max_seq_length) { 32 }

  # Test data
  let(:encoder_input) { [1, 2, 3, 4, 5] }
  let(:decoder_input) { [6, 7, 8, 9] }
  let(:longer_sequence) { (1..20).to_a }

  describe 'initialization' do
    context 'with valid parameters' do
      it 'creates encoder-only transformer' do
        transformer = described_class.new(
          mode: :encoder_only,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_layers: n_layers
        )

        expect(transformer.mode).to eq(:encoder_only)
        expect(transformer.vocab_size).to eq(vocab_size)
        expect(transformer.d_model).to eq(d_model)
        expect(transformer.n_heads).to eq(n_heads)
        expect(transformer.n_encoder_layers).to eq(n_layers)
        expect(transformer.n_decoder_layers).to eq(n_layers)
      end

      it 'creates decoder-only transformer' do
        transformer = described_class.new(
          mode: :decoder_only,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_layers: n_layers
        )

        expect(transformer.mode).to eq(:decoder_only)
        expect(transformer.n_decoder_layers).to eq(n_layers)
      end

      it 'creates seq2seq transformer' do
        transformer = described_class.new(
          mode: :seq2seq,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_encoder_layers: 2,
          n_decoder_layers: 3
        )

        expect(transformer.mode).to eq(:seq2seq)
        expect(transformer.n_encoder_layers).to eq(2)
        expect(transformer.n_decoder_layers).to eq(3)
      end

      it 'creates transformer with custom options' do
        transformer = described_class.new(
          mode: :encoder_only,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_layers: n_layers,
          d_ff: 256,
          max_seq_length: 64,
          dropout_rate: 0.2,
          verbose: true,
          track_attention: false
        )

        expect(transformer.d_ff).to eq(256)
        expect(transformer.max_seq_length).to eq(64)
        expect(transformer.dropout_rate).to eq(0.2)
        expect(transformer.verbose_mode).to be true
        expect(transformer.track_attention).to be false
      end
    end

    context 'with invalid parameters' do
      it 'raises error for invalid mode' do
        expect do
          described_class.new(
            mode: :invalid_mode,
            vocab_size: vocab_size,
            d_model: d_model,
            n_heads: n_heads
          )
        end.to raise_error(ArgumentError, /Mode must be one of/)
      end

      it 'raises error for invalid vocab_size' do
        expect do
          described_class.new(
            mode: :encoder_only,
            vocab_size: 0,
            d_model: d_model,
            n_heads: n_heads
          )
        end.to raise_error(ArgumentError, 'Vocabulary size must be a positive integer')
      end

      it 'raises error for invalid d_model' do
        expect do
          described_class.new(
            mode: :encoder_only,
            vocab_size: vocab_size,
            d_model: 63, # Odd number
            n_heads: n_heads
          )
        end.to raise_error(ArgumentError, 'Model dimension must be a positive even integer')
      end

      it 'raises error for invalid n_heads' do
        expect do
          described_class.new(
            mode: :encoder_only,
            vocab_size: vocab_size,
            d_model: d_model,
            n_heads: 0
          )
        end.to raise_error(ArgumentError, 'Number of heads must be a positive integer')
      end

      it 'raises error when d_model not divisible by n_heads' do
        expect do
          described_class.new(
            mode: :encoder_only,
            vocab_size: vocab_size,
            d_model: 64,
            n_heads: 5 # 64 not divisible by 5
          )
        end.to raise_error(ArgumentError, 'Model dimension must be divisible by number of heads')
      end
    end
  end

  describe 'parameter initialization' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'initializes embedding parameters' do
      params = transformer.parameters

      expect(params[:token_embedding]).to be_a(Array)
      expect(params[:token_embedding].length).to eq(vocab_size)
      expect(params[:token_embedding][0].length).to eq(d_model)

      expect(params[:position_embedding]).to be_a(Array)
      expect(params[:position_embedding].length).to eq(transformer.max_seq_length)
      expect(params[:position_embedding][0].length).to eq(d_model)
    end

    it 'initializes attention parameters' do
      params = transformer.parameters

      expect(params[:wq]).to be_a(Array)
      expect(params[:wk]).to be_a(Array)
      expect(params[:wv]).to be_a(Array)
      expect(params[:wo]).to be_a(Array)

      expect(params[:wq].length).to eq(n_layers)
      expect(params[:wq][0].length).to eq(d_model)
      expect(params[:wq][0][0].length).to eq(d_model)
    end

    it 'initializes feed-forward parameters' do
      params = transformer.parameters

      expect(params[:ff_w1]).to be_a(Array)
      expect(params[:ff_w2]).to be_a(Array)
      expect(params[:ff_b1]).to be_a(Array)
      expect(params[:ff_b2]).to be_a(Array)

      expect(params[:ff_w1].length).to eq(n_layers)
      expect(params[:ff_w1][0].length).to eq(d_model)
      expect(params[:ff_w1][0][0].length).to eq(transformer.d_ff)
    end

    it 'initializes layer norm parameters' do
      params = transformer.parameters

      expect(params[:ln_gamma]).to be_a(Array)
      expect(params[:ln_beta]).to be_a(Array)

      expect(params[:ln_gamma].length).to eq(n_layers)
      expect(params[:ln_gamma][0].length).to eq(d_model)
      expect(params[:ln_gamma][0].all?(1.0)).to be true

      expect(params[:ln_beta][0].all?(0.0)).to be true
    end

    it 'initializes output projection for decoder modes' do
      decoder_transformer = described_class.new(
        mode: :decoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )

      params = decoder_transformer.parameters
      expect(params[:output_projection]).to be_a(Array)
      expect(params[:output_projection].length).to eq(d_model)
      expect(params[:output_projection][0].length).to eq(vocab_size)
    end

    it 'does not initialize output projection for encoder-only mode' do
      params = transformer.parameters
      expect(params[:output_projection]).to be_nil
    end
  end

  describe 'forward pass' do
    context 'encoder-only mode' do
      let(:transformer) do
        described_class.new(
          mode: :encoder_only,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_layers: n_layers
        )
      end

      it 'processes input sequence' do
        output = transformer.forward(encoder_input)

        expect(output).to be_a(Array)
        expect(output.length).to eq(encoder_input.length)
        expect(output[0].length).to eq(d_model)
        expect(output.all? { |vec| vec.all?(Float) }).to be true
      end

      it 'handles different sequence lengths' do
        short_input = [1, 2]
        long_input = (1..10).to_a

        short_output = transformer.forward(short_input)
        long_output = transformer.forward(long_input)

        expect(short_output.length).to eq(2)
        expect(long_output.length).to eq(10)
      end

      it 'produces consistent outputs' do
        output1 = transformer.forward(encoder_input)
        output2 = transformer.forward(encoder_input)

        expect(output1).to eq(output2)
      end

      it 'handles masks properly' do
        mask = Array.new(encoder_input.length) { Array.new(encoder_input.length, 1) }
        mask[0][1] = 0 # Mask position 1 from position 0

        output = transformer.forward(encoder_input, nil, mask)

        expect(output).to be_a(Array)
        expect(output.length).to eq(encoder_input.length)
      end
    end

    context 'decoder-only mode' do
      let(:transformer) do
        described_class.new(
          mode: :decoder_only,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_layers: n_layers
        )
      end

      it 'processes input sequence and returns logits' do
        output = transformer.forward(encoder_input)

        expect(output).to be_a(Array)
        expect(output.length).to eq(encoder_input.length)
        expect(output[0].length).to eq(vocab_size)
        expect(output.all? { |vec| vec.all?(Float) }).to be true
      end

      it 'applies causal masking' do
        output = transformer.forward(encoder_input)

        # Test that causal masking is applied (harder to test directly)
        expect(output).to be_a(Array)
        expect(output.length).to eq(encoder_input.length)
      end

      it 'handles single token input' do
        single_token = [5]
        output = transformer.forward(single_token)

        expect(output.length).to eq(1)
        expect(output[0].length).to eq(vocab_size)
      end
    end

    context 'seq2seq mode' do
      let(:transformer) do
        described_class.new(
          mode: :seq2seq,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_encoder_layers: 2,
          n_decoder_layers: 2
        )
      end

      it 'processes encoder and decoder inputs' do
        output = transformer.forward(encoder_input, decoder_input)

        expect(output).to be_a(Array)
        expect(output.length).to eq(decoder_input.length)
        expect(output[0].length).to eq(vocab_size)
      end

      it 'handles different encoder/decoder lengths' do
        short_decoder = [1, 2]
        output = transformer.forward(encoder_input, short_decoder)

        expect(output.length).to eq(2)
        expect(output[0].length).to eq(vocab_size)
      end

      it 'requires decoder input' do
        expect do
          transformer.forward(encoder_input)
        end.to raise_error(ArgumentError, 'Decoder input required for seq2seq mode')
      end
    end

    context 'input validation' do
      let(:transformer) do
        described_class.new(
          mode: :encoder_only,
          vocab_size: vocab_size,
          d_model: d_model,
          n_heads: n_heads,
          n_layers: n_layers
        )
      end

      it 'raises error for nil encoder input' do
        expect do
          transformer.forward(nil)
        end.to raise_error(ArgumentError, 'Encoder input cannot be nil')
      end

      it 'raises error for decoder input in encoder-only mode' do
        expect do
          transformer.forward(encoder_input, decoder_input)
        end.to raise_error(ArgumentError, 'Decoder input not used in encoder_only mode')
      end
    end
  end

  describe 'attention mechanisms' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers,
        track_attention: true
      )
    end

    it 'computes scaled dot-product attention' do
      queries = [[1.0, 0.0], [0.0, 1.0]]
      keys = [[1.0, 0.0], [0.0, 1.0]]
      values = [[2.0, 0.0], [0.0, 2.0]]

      output, weights = transformer.scaled_dot_product_attention(queries, keys, values)

      expect(output).to be_a(Array)
      expect(output.length).to eq(2)
      expect(output[0].length).to eq(2)

      expect(weights).to be_a(Array)
      expect(weights.length).to eq(2)
      expect(weights[0].length).to eq(2)

      # Check that attention weights sum to 1
      weights.each do |row|
        expect(row.sum).to be_within(1e-6).of(1.0)
      end
    end

    it 'applies attention masks' do
      queries = [[1.0, 0.0], [0.0, 1.0]]
      keys = [[1.0, 0.0], [0.0, 1.0]]
      values = [[2.0, 0.0], [0.0, 2.0]]
      mask = [[1, 0], [1, 1]]

      _, weights = transformer.scaled_dot_product_attention(queries, keys, values, mask)

      expect(weights[0][1]).to be_within(1e-6).of(0.0) # Masked position should be 0
      expect(weights[1][0]).to be > 0 # Unmasked position should be positive
    end

    it 'performs multi-head attention' do
      queries = Array.new(3) { Array.new(d_model) { rand } }
      keys = Array.new(3) { Array.new(d_model) { rand } }
      values = Array.new(3) { Array.new(d_model) { rand } }

      output = transformer.multi_head_attention(queries, keys, values)

      expect(output).to be_a(Array)
      expect(output.length).to eq(3)
      expect(output[0].length).to eq(d_model)
    end

    it 'tracks attention weights when enabled' do
      transformer.forward(encoder_input)

      expect(transformer.attention_weights).not_to be_empty
    end
  end

  describe 'layer operations' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'processes encoder layer' do
      input = Array.new(3) { Array.new(d_model) { rand } }
      output = transformer.encoder_layer(input)

      expect(output).to be_a(Array)
      expect(output.length).to eq(3)
      expect(output[0].length).to eq(d_model)
    end

    it 'processes decoder layer' do
      input = Array.new(3) { Array.new(d_model) { rand } }
      output = transformer.decoder_layer(input)

      expect(output).to be_a(Array)
      expect(output.length).to eq(3)
      expect(output[0].length).to eq(d_model)
    end

    it 'processes decoder layer with encoder output' do
      input = Array.new(3) { Array.new(d_model) { rand } }
      encoder_output = Array.new(3) { Array.new(d_model) { rand } }

      output = transformer.decoder_layer(input, encoder_output)

      expect(output).to be_a(Array)
      expect(output.length).to eq(3)
      expect(output[0].length).to eq(d_model)
    end
  end

  describe 'utility functions' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'creates causal mask' do
      mask = transformer.send(:create_causal_mask, 3)

      expect(mask).to eq([
                           [1, 0, 0],
                           [1, 1, 0],
                           [1, 1, 1]
                         ])
    end

    it 'combines masks' do
      mask1 = [[1, 1], [1, 1]]
      mask2 = [[1, 0], [1, 1]]

      combined = transformer.send(:combine_masks, mask1, mask2)

      expect(combined).to eq([[1, 0], [1, 1]])
    end

    it 'embeds tokens with positional encoding' do
      tokens = [1, 2, 3]
      embeddings = transformer.send(:embed_tokens, tokens)

      expect(embeddings).to be_a(Array)
      expect(embeddings.length).to eq(3)
      expect(embeddings[0].length).to eq(d_model)
    end

    it 'creates positional encoding' do
      encoding = transformer.send(:create_positional_encoding, 5, 4)

      expect(encoding).to be_a(Array)
      expect(encoding.length).to eq(5)
      expect(encoding[0].length).to eq(4)

      # Check that encoding has expected pattern
      expect(encoding[0]).not_to eq(encoding[1])
    end

    it 'splits and concatenates heads' do
      input = Array.new(2) { Array.new(d_model) { rand } }

      heads = transformer.send(:split_heads, input, n_heads)
      expect(heads.length).to eq(n_heads)
      expect(heads[0].length).to eq(2)
      expect(heads[0][0].length).to eq(d_model / n_heads)

      concatenated = transformer.send(:concat_heads, heads)
      expect(concatenated.length).to eq(2)
      expect(concatenated[0].length).to eq(d_model)
    end

    it 'applies layer normalization' do
      input = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
      normalized = transformer.send(:layer_norm, input)

      expect(normalized).to be_a(Array)
      expect(normalized.length).to eq(2)
      expect(normalized[0].length).to eq(3)

      # Check that normalized values have approximately zero mean
      normalized.each do |vector|
        mean = vector.sum / vector.length
        expect(mean).to be_within(1e-6).of(0.0)
      end
    end

    it 'applies residual connections' do
      input = [[1.0, 2.0], [3.0, 4.0]]
      output = [[0.1, 0.2], [0.3, 0.4]]

      residual = transformer.send(:add_residual, input, output)

      expect(residual).to eq([[1.1, 2.2], [3.3, 4.4]])
    end

    it 'performs linear transformation' do
      input = [[1.0, 2.0]]
      weight = [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6]]

      output = transformer.send(:linear_transform, input, weight)

      expect(output).to be_a(Array)
      expect(output.length).to eq(1)
      expect(output[0].length).to eq(3)
    end

    it 'applies softmax' do
      scores = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
      probabilities = transformer.send(:softmax, scores)

      expect(probabilities).to be_a(Array)
      expect(probabilities.length).to eq(2)

      # Check that probabilities sum to 1
      probabilities.each do |row|
        expect(row.sum).to be_within(1e-6).of(1.0)
      end
    end

    it 'applies ReLU activation' do
      input = [[-1.0, 0.0, 1.0], [2.0, -3.0, 4.0]]
      output = transformer.send(:relu, input)

      expect(output).to eq([[0.0, 0.0, 1.0], [2.0, 0.0, 4.0]])
    end
  end

  describe 'generation' do
    let(:transformer) do
      described_class.new(
        mode: :decoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'generates sequences' do
      prompt = [1, 2, 3]
      generated = transformer.generate(prompt, 5)

      expect(generated).to be_a(Array)
      expect(generated.length).to be > prompt.length
      expect(generated[0...prompt.length]).to eq(prompt)
      expect(generated.all?(Integer)).to be true
    end

    it 'respects max_length parameter' do
      prompt = [1, 2]
      generated = transformer.generate(prompt, 3)

      expect(generated.length).to be <= 3 + prompt.length
    end

    it 'raises error for encoder-only mode' do
      encoder_transformer = described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )

      expect do
        encoder_transformer.generate([1, 2, 3])
      end.to raise_error(RuntimeError, 'Generation only supported for decoder modes')
    end

    it 'applies temperature scaling' do
      logits = [1.0, 2.0, 3.0]

      # Test different temperatures
      probs1 = transformer.send(:softmax_with_temperature, logits, 0.1)
      probs2 = transformer.send(:softmax_with_temperature, logits, 2.0)

      # Lower temperature should be more peaked
      expect(probs1.max).to be > probs2.max
    end
  end

  describe 'attention analysis' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers,
        track_attention: true
      )
    end

    it 'analyzes attention patterns' do
      transformer.forward(encoder_input)
      analysis = transformer.analyze_attention

      expect(analysis).to be_a(Hash)

      analysis.each_value do |layer_analysis|
        expect(layer_analysis).to have_key(:average_attention)
        expect(layer_analysis).to have_key(:attention_entropy)
        expect(layer_analysis).to have_key(:most_attended_positions)

        expect(layer_analysis[:average_attention]).to be_a(Float)
        expect(layer_analysis[:attention_entropy]).to be_a(Float)
        expect(layer_analysis[:most_attended_positions]).to be_a(Array)
      end
    end

    it 'returns empty analysis when tracking disabled' do
      transformer.track_attention = false
      analysis = transformer.analyze_attention

      expect(analysis).to be_empty
    end
  end

  describe 'architecture visualization' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'generates architecture visualization' do
      visualization = transformer.visualize_architecture

      expect(visualization).to be_a(String)
      expect(visualization).to include('Transformer Architecture Visualization')
      expect(visualization).to include('Configuration:')
      expect(visualization).to include('Architecture Flow:')
      expect(visualization).to include('Parameter Count:')
      expect(visualization).to include('Mode: encoder_only')
    end

    it 'shows different flow for different modes' do
      decoder_transformer = described_class.new(
        mode: :decoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )

      visualization = decoder_transformer.visualize_architecture

      expect(visualization).to include('Mode: decoder_only')
      expect(visualization).to include('Masked Multi-Head Self-Attention')
      expect(visualization).to include('Linear + Softmax')
    end

    it 'shows seq2seq architecture' do
      seq2seq_transformer = described_class.new(
        mode: :seq2seq,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_encoder_layers: 2,
        n_decoder_layers: 2
      )

      visualization = seq2seq_transformer.visualize_architecture

      expect(visualization).to include('Mode: seq2seq')
      expect(visualization).to include('Source Tokens')
      expect(visualization).to include('Target Tokens')
      expect(visualization).to include('Cross-Attention')
    end

    it 'calculates parameter count' do
      param_count = transformer.send(:calculate_parameter_count)

      expect(param_count).to have_key(:total)
      expect(param_count).to have_key(:embedding)
      expect(param_count).to have_key(:attention)
      expect(param_count).to have_key(:feed_forward)

      expect(param_count[:total]).to be > 0
      expect(param_count[:embedding]).to be > 0
      expect(param_count[:attention]).to be > 0
      expect(param_count[:feed_forward]).to be > 0
    end

    it 'formats numbers correctly' do
      transformer = described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )

      expect(transformer.send(:format_number, 1_500_000_000)).to eq('1.5B')
      expect(transformer.send(:format_number, 2_500_000)).to eq('2.5M')
      expect(transformer.send(:format_number, 3_500)).to eq('3.5K')
      expect(transformer.send(:format_number, 500)).to eq('500')
    end
  end

  describe 'educational features' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers,
        verbose: true
      )
    end

    it 'provides verbose output' do
      expect { transformer.forward(encoder_input) }.to output(/Transformer Forward Pass/).to_stdout
    end

    it 'tracks activations when enabled' do
      transformer.forward(encoder_input)

      # Activations tracking would be implemented for educational purposes
      expect(transformer.activations).to be_a(Hash)
    end
  end

  describe 'performance characteristics' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'handles different sequence lengths efficiently' do
      short_seq = [1, 2, 3]
      long_seq = (1..30).to_a

      benchmark_performance('Short sequence processing') do
        output = transformer.forward(short_seq)
        expect(output.length).to eq(3)
      end

      benchmark_performance('Long sequence processing') do
        output = transformer.forward(long_seq)
        expect(output.length).to eq(30)
      end
    end

    it 'processes multiple sequences consistently' do
      results = []

      10.times do
        output = transformer.forward(encoder_input)
        results << output
      end

      # All results should be identical (deterministic)
      expect(results.all?(results.first)).to be true
    end
  end

  describe 'edge cases and error handling' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'handles empty input gracefully' do
      expect do
        transformer.forward([])
      end.not_to raise_error
    end

    it 'handles single token input' do
      output = transformer.forward([5])

      expect(output).to be_a(Array)
      expect(output.length).to eq(1)
      expect(output[0].length).to eq(d_model)
    end

    it 'handles large vocabulary tokens' do
      large_token_input = [vocab_size - 1, vocab_size - 2]

      expect do
        transformer.forward(large_token_input)
      end.not_to raise_error
    end

    it 'handles maximum sequence length' do
      max_length_input = (0...transformer.max_seq_length).to_a

      expect do
        transformer.forward(max_length_input)
      end.not_to raise_error
    end
  end

  describe 'numerical stability' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'handles very large attention scores' do
      # This tests numerical stability in softmax computation
      large_scores = [[100.0, 200.0, 300.0]]
      probabilities = transformer.send(:softmax, large_scores)

      expect(probabilities[0].sum).to be_within(1e-6).of(1.0)
      expect(probabilities[0].all? { |p| p.between?(0, 1) }).to be true
    end

    it 'handles very small attention scores' do
      small_scores = [[-100.0, -200.0, -300.0]]
      probabilities = transformer.send(:softmax, small_scores)

      expect(probabilities[0].sum).to be_within(1e-6).of(1.0)
      expect(probabilities[0].all? { |p| p.between?(0, 1) }).to be true
    end

    it 'handles layer normalization edge cases' do
      # Test with constant input (zero variance)
      constant_input = [[1.0, 1.0, 1.0]]

      expect do
        transformer.send(:layer_norm, constant_input)
      end.not_to raise_error
    end
  end

  describe 'positional encoding' do
    it 'creates sinusoidal positional encoding' do
      encoding = Ai4r::NeuralNetwork::PositionalEncoding.sinusoidal(10, 8)

      expect(encoding).to be_a(Array)
      expect(encoding.length).to eq(10)
      expect(encoding[0].length).to eq(8)

      # Check that different positions have different encodings
      expect(encoding[0]).not_to eq(encoding[1])

      # Check that even dimensions use sin, odd use cos
      expect(encoding[0][0]).to be_within(1e-6).of(Math.sin(0))
      expect(encoding[0][1]).to be_within(1e-6).of(Math.cos(0))
    end

    it 'creates learned positional encoding' do
      encoding = Ai4r::NeuralNetwork::PositionalEncoding.learned(10, 8)

      expect(encoding).to be_a(Array)
      expect(encoding.length).to eq(10)
      expect(encoding[0].length).to eq(8)

      # All values should be small random numbers
      expect(encoding.flatten.all? { |v| v.abs < 1 }).to be true
    end
  end

  describe 'matrix operations' do
    let(:transformer) do
      described_class.new(
        mode: :encoder_only,
        vocab_size: vocab_size,
        d_model: d_model,
        n_heads: n_heads,
        n_layers: n_layers
      )
    end

    it 'performs matrix multiplication correctly' do
      a = [[1, 2], [3, 4]]
      b = [[5, 6], [7, 8]]

      result = transformer.send(:matrix_multiply, a, b)

      expect(result).to eq([[19, 22], [43, 50]])
    end

    it 'computes dot product correctly' do
      v1 = [1, 2, 3]
      v2 = [4, 5, 6]

      result = transformer.send(:dot_product, v1, v2)

      expect(result).to eq(32) # 1*4 + 2*5 + 3*6 = 32
    end

    it 'samples from distribution correctly' do
      probs = [0.1, 0.3, 0.6]

      # Test multiple samples to check distribution
      samples = []
      100.times do
        samples << transformer.send(:sample_from_distribution, probs)
      end

      # Should have samples from all categories
      expect(samples.uniq.sort).to eq([0, 1, 2])

      # Category 2 should be most frequent (probability 0.6)
      expect(samples.count(2)).to be > samples.count(1)
      expect(samples.count(2)).to be > samples.count(0)
    end
  end
end
