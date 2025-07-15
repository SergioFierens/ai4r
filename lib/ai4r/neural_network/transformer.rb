# frozen_string_literal: true

#
# Transformer Architecture Implementation for AI4R Educational Framework
#
# This implementation provides a comprehensive, educational version of the Transformer
# architecture supporting encoder-only, decoder-only, and sequence-to-sequence modes,
# designed specifically for students and teachers to understand attention mechanisms
# and modern deep learning architectures.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# The Transformer architecture revolutionized NLP by introducing self-attention
# mechanisms that allow models to process sequences in parallel rather than
# sequentially. This educational implementation focuses on clarity and understanding
# rather than computational efficiency.
#
# Key Educational Concepts:
# - Self-Attention: Allows each position to attend to all positions
# - Multi-Head Attention: Multiple attention mechanisms in parallel
# - Positional Encoding: Adds position information to embeddings
# - Layer Normalization: Stabilizes training
# - Feed-Forward Networks: Position-wise transformations
# - Masking: Prevents attending to future positions (decoder)
#
# Example Usage:
#   # Encoder-only (like BERT)
#   encoder = Transformer.new(
#     mode: :encoder_only,
#     vocab_size: 1000,
#     d_model: 128,
#     n_heads: 4,
#     n_layers: 2
#   )
#   encoded = encoder.forward(input_ids)
#   
#   # Decoder-only (like GPT)
#   decoder = Transformer.new(
#     mode: :decoder_only,
#     vocab_size: 1000,
#     d_model: 128,
#     n_heads: 4,
#     n_layers: 2
#   )
#   output = decoder.forward(input_ids)
#   
#   # Seq2Seq (like original Transformer)
#   seq2seq = Transformer.new(
#     mode: :seq2seq,
#     vocab_size: 1000,
#     d_model: 128,
#     n_heads: 4,
#     n_encoder_layers: 2,
#     n_decoder_layers: 2
#   )
#   output = seq2seq.forward(encoder_input, decoder_input)
#

module Ai4r
  module NeuralNetwork
    # Transformer Architecture Implementation
    #
    # This class implements a comprehensive Transformer with educational features
    # including step-by-step attention visualization, gradient flow analysis,
    # and interpretability tools.
    #
    # The architecture supports three modes:
    # 1. Encoder-only: For tasks like classification, embeddings
    # 2. Decoder-only: For autoregressive generation
    # 3. Seq2Seq: For translation, summarization
    #
    # Educational Features:
    # - Attention weight visualization
    # - Layer-wise activation analysis
    # - Gradient flow tracking
    # - Step-by-step computation
    # - Parameter statistics
    #
    class Transformer
      # Model configuration and parameters
      attr_reader :mode, :vocab_size, :d_model, :n_heads, :n_encoder_layers
      attr_reader :n_decoder_layers, :d_ff, :max_seq_length, :dropout_rate
      attr_reader :parameters, :attention_weights, :activations

      # Educational configuration
      attr_accessor :verbose_mode, :track_attention, :track_gradients

      # Supported modes
      MODES = [:encoder_only, :decoder_only, :seq2seq].freeze

      # Default configuration values
      DEFAULT_D_MODEL = 512
      DEFAULT_N_HEADS = 8
      DEFAULT_N_LAYERS = 6
      DEFAULT_D_FF = 2048
      DEFAULT_MAX_SEQ_LENGTH = 512
      DEFAULT_DROPOUT = 0.1

      # Initialize Transformer with configuration
      #
      # @param mode [Symbol] Operating mode (:encoder_only, :decoder_only, :seq2seq)
      # @param vocab_size [Integer] Size of vocabulary
      # @param d_model [Integer] Model dimension
      # @param n_heads [Integer] Number of attention heads
      # @param options [Hash] Additional configuration options
      #
      def initialize(mode:, vocab_size:, d_model: DEFAULT_D_MODEL, 
                     n_heads: DEFAULT_N_HEADS, **options)
        @mode = validate_mode(mode)
        @vocab_size = validate_vocab_size(vocab_size)
        @d_model = validate_d_model(d_model)
        @n_heads = validate_n_heads(n_heads, d_model)
        
        # Layer configuration
        @n_encoder_layers = options.fetch(:n_encoder_layers, 
                                        options.fetch(:n_layers, DEFAULT_N_LAYERS))
        @n_decoder_layers = options.fetch(:n_decoder_layers, 
                                        options.fetch(:n_layers, DEFAULT_N_LAYERS))
        
        # Model hyperparameters
        @d_ff = options.fetch(:d_ff, DEFAULT_D_FF)
        @max_seq_length = options.fetch(:max_seq_length, DEFAULT_MAX_SEQ_LENGTH)
        @dropout_rate = options.fetch(:dropout_rate, DEFAULT_DROPOUT)
        
        # Educational configuration
        @verbose_mode = options.fetch(:verbose, false)
        @track_attention = options.fetch(:track_attention, true)
        @track_gradients = options.fetch(:track_gradients, false)
        
        # Initialize components
        initialize_parameters
        initialize_layers
        
        # Tracking
        @attention_weights = {}
        @activations = {}
        @gradient_norms = {}
      end

      # Forward pass through the transformer
      #
      # @param encoder_input [Array] Input tokens for encoder (or main input)
      # @param decoder_input [Array] Input tokens for decoder (seq2seq only)
      # @param encoder_mask [Array] Padding mask for encoder
      # @param decoder_mask [Array] Padding mask for decoder
      # @return [Array] Output logits or representations
      #
      # Educational Note:
      # The forward pass demonstrates the complete transformer computation:
      # 1. Embedding and positional encoding
      # 2. Encoder processing (if applicable)
      # 3. Decoder processing (if applicable)
      # 4. Output projection
      #
      def forward(encoder_input, decoder_input = nil, encoder_mask = nil, decoder_mask = nil)
        validate_forward_inputs(encoder_input, decoder_input)
        
        educational_output("🤖 Transformer Forward Pass", <<~MSG)
          Mode: #{@mode}
          Encoder input shape: #{encoder_input.length} tokens
          Decoder input shape: #{decoder_input&.length || 'N/A'} tokens
        MSG
        
        case @mode
        when :encoder_only
          forward_encoder_only(encoder_input, encoder_mask)
        when :decoder_only
          forward_decoder_only(encoder_input, encoder_mask)
        when :seq2seq
          forward_seq2seq(encoder_input, decoder_input, encoder_mask, decoder_mask)
        end
      end

      # Compute attention between queries and keys
      #
      # @param queries [Array] Query vectors
      # @param keys [Array] Key vectors
      # @param values [Array] Value vectors
      # @param mask [Array] Attention mask
      # @return [Array] Attention output and weights
      #
      # Educational Note:
      # Scaled dot-product attention computes:
      # Attention(Q,K,V) = softmax(QK^T / sqrt(d_k))V
      # where d_k is the dimension of the key vectors
      #
      def scaled_dot_product_attention(queries, keys, values, mask = nil)
        d_k = keys[0].length
        
        # Compute attention scores
        scores = compute_attention_scores(queries, keys, d_k)
        
        # Apply mask if provided
        if mask
          scores = apply_attention_mask(scores, mask)
        end
        
        # Apply softmax
        attention_weights = softmax(scores)
        
        # Apply attention to values
        output = matrix_multiply(attention_weights, values)
        
        if @track_attention
          store_attention_weights(attention_weights)
        end
        
        educational_output("📊 Attention Computation", <<~MSG)
          Query shape: #{queries.length} x #{queries[0].length}
          Key shape: #{keys.length} x #{keys[0].length}
          Value shape: #{values.length} x #{values[0].length}
          Attention shape: #{attention_weights.length} x #{attention_weights[0].length}
        MSG
        
        [output, attention_weights]
      end

      # Multi-head attention mechanism
      #
      # @param queries [Array] Query vectors
      # @param keys [Array] Key vectors
      # @param values [Array] Value vectors
      # @param mask [Array] Attention mask
      # @return [Array] Multi-head attention output
      #
      def multi_head_attention(queries, keys, values, mask = nil)
        batch_size = queries.length
        seq_length = queries[0].length
        d_k = @d_model / @n_heads
        
        # Split into multiple heads
        multi_head_queries = split_heads(queries, @n_heads)
        multi_head_keys = split_heads(keys, @n_heads)
        multi_head_values = split_heads(values, @n_heads)
        
        # Apply attention to each head
        head_outputs = []
        head_weights = []
        
        @n_heads.times do |head|
          output, weights = scaled_dot_product_attention(
            multi_head_queries[head],
            multi_head_keys[head],
            multi_head_values[head],
            mask
          )
          head_outputs << output
          head_weights << weights
        end
        
        # Concatenate heads
        concatenated = concat_heads(head_outputs)
        
        # Final linear projection
        output = linear_transform(concatenated, @parameters[:wo])
        
        educational_output("🎯 Multi-Head Attention", <<~MSG)
          Number of heads: #{@n_heads}
          Head dimension: #{d_k}
          Output shape: #{output.length} x #{output[0].length}
        MSG
        
        output
      end

      # Transformer encoder layer
      #
      # @param input [Array] Input vectors
      # @param mask [Array] Padding mask
      # @return [Array] Encoded representations
      #
      def encoder_layer(input, mask = nil)
        # Self-attention
        attention_output = multi_head_attention(input, input, input, mask)
        
        # Add & Norm
        attention_output = layer_norm(add_residual(input, attention_output))
        
        # Feed-forward
        ff_output = feed_forward(attention_output)
        
        # Add & Norm
        output = layer_norm(add_residual(attention_output, ff_output))
        
        output
      end

      # Transformer decoder layer
      #
      # @param input [Array] Input vectors
      # @param encoder_output [Array] Encoder output (for seq2seq)
      # @param self_mask [Array] Self-attention mask
      # @param cross_mask [Array] Cross-attention mask
      # @return [Array] Decoded representations
      #
      def decoder_layer(input, encoder_output = nil, self_mask = nil, cross_mask = nil)
        # Self-attention with causal mask
        self_attention_output = multi_head_attention(input, input, input, self_mask)
        
        # Add & Norm
        self_attention_output = layer_norm(add_residual(input, self_attention_output))
        
        # Cross-attention (if encoder output provided)
        if encoder_output
          cross_attention_output = multi_head_attention(
            self_attention_output,
            encoder_output,
            encoder_output,
            cross_mask
          )
          
          # Add & Norm
          cross_attention_output = layer_norm(
            add_residual(self_attention_output, cross_attention_output)
          )
        else
          cross_attention_output = self_attention_output
        end
        
        # Feed-forward
        ff_output = feed_forward(cross_attention_output)
        
        # Add & Norm
        output = layer_norm(add_residual(cross_attention_output, ff_output))
        
        output
      end

      # Generate text using the model (decoder modes only)
      #
      # @param prompt [Array] Initial tokens
      # @param max_length [Integer] Maximum generation length
      # @param temperature [Float] Sampling temperature
      # @return [Array] Generated tokens
      #
      def generate(prompt, max_length = 50, temperature = 1.0)
        unless [:decoder_only, :seq2seq].include?(@mode)
          raise RuntimeError, "Generation only supported for decoder modes"
        end
        
        generated = prompt.dup
        
        max_length.times do |step|
          # Get model predictions
          if @mode == :decoder_only
            logits = forward(generated)
          else # seq2seq
            # For seq2seq, we'd need encoder input
            raise NotImplementedError, "Seq2seq generation requires encoder input"
          end
          
          # Get next token probabilities
          next_token_logits = logits.last
          next_token_probs = softmax_with_temperature(next_token_logits, temperature)
          
          # Sample next token
          next_token = sample_from_distribution(next_token_probs)
          generated << next_token
          
          # Stop if end token generated (would need to define this)
          break if next_token == 0 # Assuming 0 is end token
          
          educational_output("🎲 Generation Step #{step + 1}", <<~MSG)
            Generated token: #{next_token}
            Total length: #{generated.length}
          MSG if @verbose_mode && step < 5
        end
        
        generated
      end

      # Analyze attention patterns
      #
      # @return [Hash] Attention analysis results
      #
      def analyze_attention
        return {} unless @track_attention
        
        analysis = {}
        
        @attention_weights.each do |layer_name, weights|
          layer_analysis = {
            average_attention: compute_average_attention(weights),
            attention_entropy: compute_attention_entropy(weights),
            most_attended_positions: find_most_attended_positions(weights)
          }
          
          analysis[layer_name] = layer_analysis
        end
        
        analysis
      end

      # Visualize model architecture
      #
      # @return [String] ASCII visualization
      #
      def visualize_architecture
        visualization = "\n🏗️  Transformer Architecture Visualization\n"
        visualization += "=" * 50 + "\n\n"
        
        visualization += "📋 Configuration:\n"
        visualization += "  • Mode: #{@mode}\n"
        visualization += "  • Model dimension: #{@d_model}\n"
        visualization += "  • Attention heads: #{@n_heads}\n"
        visualization += "  • Vocabulary size: #{@vocab_size}\n"
        
        case @mode
        when :encoder_only
          visualization += "  • Encoder layers: #{@n_encoder_layers}\n"
          visualization += "\n🔄 Architecture Flow:\n"
          visualization += "  Input Tokens\n"
          visualization += "      ↓\n"
          visualization += "  Embedding + Positional Encoding\n"
          visualization += "      ↓\n"
          @n_encoder_layers.times do |i|
            visualization += "  Encoder Layer #{i + 1}\n"
            visualization += "    - Multi-Head Self-Attention\n"
            visualization += "    - Add & Norm\n"
            visualization += "    - Feed-Forward\n"
            visualization += "    - Add & Norm\n"
            visualization += "      ↓\n"
          end
          visualization += "  Output Representations\n"
          
        when :decoder_only
          visualization += "  • Decoder layers: #{@n_decoder_layers}\n"
          visualization += "\n🔄 Architecture Flow:\n"
          visualization += "  Input Tokens\n"
          visualization += "      ↓\n"
          visualization += "  Embedding + Positional Encoding\n"
          visualization += "      ↓\n"
          @n_decoder_layers.times do |i|
            visualization += "  Decoder Layer #{i + 1}\n"
            visualization += "    - Masked Multi-Head Self-Attention\n"
            visualization += "    - Add & Norm\n"
            visualization += "    - Feed-Forward\n"
            visualization += "    - Add & Norm\n"
            visualization += "      ↓\n"
          end
          visualization += "  Linear + Softmax\n"
          visualization += "      ↓\n"
          visualization += "  Output Probabilities\n"
          
        when :seq2seq
          visualization += "  • Encoder layers: #{@n_encoder_layers}\n"
          visualization += "  • Decoder layers: #{@n_decoder_layers}\n"
          visualization += "\n🔄 Architecture Flow:\n"
          visualization += "  Source Tokens          Target Tokens\n"
          visualization += "       ↓                      ↓\n"
          visualization += "  Embedding + PE         Embedding + PE\n"
          visualization += "       ↓                      ↓\n"
          visualization += "  [Encoder Stack]       [Decoder Stack]\n"
          @n_encoder_layers.times do |i|
            visualization += "   Encoder #{i + 1}  ←───────→  "
            if i < @n_decoder_layers
              visualization += "Decoder #{i + 1}\n"
            else
              visualization += "\n"
            end
          end
          visualization += "       ↓                      ↓\n"
          visualization += "  Encoder Output ──────→ Cross-Attention\n"
          visualization += "                              ↓\n"
          visualization += "                     Linear + Softmax\n"
          visualization += "                              ↓\n"
          visualization += "                     Output Probabilities\n"
        end
        
        visualization += "\n📊 Parameter Count:\n"
        param_count = calculate_parameter_count
        visualization += "  • Total parameters: #{format_number(param_count[:total])}\n"
        visualization += "  • Embedding parameters: #{format_number(param_count[:embedding])}\n"
        visualization += "  • Attention parameters: #{format_number(param_count[:attention])}\n"
        visualization += "  • Feed-forward parameters: #{format_number(param_count[:feed_forward])}\n"
        
        visualization
      end

      private

      # Validate mode parameter
      def validate_mode(mode)
        unless MODES.include?(mode)
          raise ArgumentError, "Mode must be one of: #{MODES.join(', ')}"
        end
        mode
      end

      # Validate vocabulary size
      def validate_vocab_size(vocab_size)
        unless vocab_size.is_a?(Integer) && vocab_size > 0
          raise ArgumentError, "Vocabulary size must be a positive integer"
        end
        vocab_size
      end

      # Validate model dimension
      def validate_d_model(d_model)
        unless d_model.is_a?(Integer) && d_model > 0 && d_model % 2 == 0
          raise ArgumentError, "Model dimension must be a positive even integer"
        end
        d_model
      end

      # Validate number of heads
      def validate_n_heads(n_heads, d_model)
        unless n_heads.is_a?(Integer) && n_heads > 0
          raise ArgumentError, "Number of heads must be a positive integer"
        end
        unless d_model % n_heads == 0
          raise ArgumentError, "Model dimension must be divisible by number of heads"
        end
        n_heads
      end

      # Initialize model parameters
      def initialize_parameters
        @parameters = {}
        
        # Embedding parameters
        @parameters[:token_embedding] = random_matrix(@vocab_size, @d_model)
        @parameters[:position_embedding] = create_positional_encoding(@max_seq_length, @d_model)
        
        # Attention parameters (per layer)
        @parameters[:wq] = []
        @parameters[:wk] = []
        @parameters[:wv] = []
        @parameters[:wo] = []
        
        # Feed-forward parameters (per layer)
        @parameters[:ff_w1] = []
        @parameters[:ff_w2] = []
        @parameters[:ff_b1] = []
        @parameters[:ff_b2] = []
        
        # Layer norm parameters (per layer)
        @parameters[:ln_gamma] = []
        @parameters[:ln_beta] = []
        
        # Output projection (for decoder modes)
        if [:decoder_only, :seq2seq].include?(@mode)
          @parameters[:output_projection] = random_matrix(@d_model, @vocab_size)
        end
      end

      # Initialize transformer layers
      def initialize_layers
        # Initialize encoder layers
        if [:encoder_only, :seq2seq].include?(@mode)
          @n_encoder_layers.times do
            initialize_layer_parameters
          end
        end
        
        # Initialize decoder layers
        if [:decoder_only, :seq2seq].include?(@mode)
          @n_decoder_layers.times do
            initialize_layer_parameters
          end
        end
      end

      # Initialize parameters for a single layer
      def initialize_layer_parameters
        # Attention parameters
        @parameters[:wq] << random_matrix(@d_model, @d_model)
        @parameters[:wk] << random_matrix(@d_model, @d_model)
        @parameters[:wv] << random_matrix(@d_model, @d_model)
        @parameters[:wo] << random_matrix(@d_model, @d_model)
        
        # Feed-forward parameters
        @parameters[:ff_w1] << random_matrix(@d_model, @d_ff)
        @parameters[:ff_w2] << random_matrix(@d_ff, @d_model)
        @parameters[:ff_b1] << random_vector(@d_ff)
        @parameters[:ff_b2] << random_vector(@d_model)
        
        # Layer norm parameters
        @parameters[:ln_gamma] << ones_vector(@d_model)
        @parameters[:ln_beta] << zeros_vector(@d_model)
      end

      # Forward pass for encoder-only mode
      def forward_encoder_only(input, mask)
        # Embedding and positional encoding
        embeddings = embed_tokens(input)
        
        # Encoder layers
        output = embeddings
        @n_encoder_layers.times do |layer_idx|
          output = encoder_layer(output, mask)
          
          if @track_attention
            @attention_weights["encoder_layer_#{layer_idx}"] = output
          end
        end
        
        output
      end

      # Forward pass for decoder-only mode
      def forward_decoder_only(input, mask)
        # Create causal mask
        seq_length = input.length
        causal_mask = create_causal_mask(seq_length)
        combined_mask = combine_masks(mask, causal_mask) if mask
        
        # Embedding and positional encoding
        embeddings = embed_tokens(input)
        
        # Decoder layers
        output = embeddings
        @n_decoder_layers.times do |layer_idx|
          output = decoder_layer(output, nil, combined_mask || causal_mask)
          
          if @track_attention
            @attention_weights["decoder_layer_#{layer_idx}"] = output
          end
        end
        
        # Output projection
        logits = linear_transform(output, @parameters[:output_projection])
        
        logits
      end

      # Forward pass for seq2seq mode
      def forward_seq2seq(encoder_input, decoder_input, encoder_mask, decoder_mask)
        # Encode
        encoder_embeddings = embed_tokens(encoder_input)
        encoder_output = encoder_embeddings
        
        @n_encoder_layers.times do |layer_idx|
          encoder_output = encoder_layer(encoder_output, encoder_mask)
        end
        
        # Decode
        decoder_embeddings = embed_tokens(decoder_input)
        decoder_output = decoder_embeddings
        
        # Create causal mask for decoder
        seq_length = decoder_input.length
        causal_mask = create_causal_mask(seq_length)
        combined_mask = combine_masks(decoder_mask, causal_mask) if decoder_mask
        
        @n_decoder_layers.times do |layer_idx|
          decoder_output = decoder_layer(
            decoder_output,
            encoder_output,
            combined_mask || causal_mask,
            encoder_mask
          )
        end
        
        # Output projection
        logits = linear_transform(decoder_output, @parameters[:output_projection])
        
        logits
      end

      # Embed tokens with positional encoding
      def embed_tokens(tokens)
        # Token embeddings
        embeddings = tokens.map do |token|
          @parameters[:token_embedding][token].dup
        end
        
        # Add positional encoding
        embeddings.each_with_index do |embedding, pos|
          embedding.each_with_index do |val, dim|
            embedding[dim] = val + @parameters[:position_embedding][pos][dim]
          end
        end
        
        # Apply dropout (simplified - just scaling)
        if @dropout_rate > 0
          embeddings = apply_dropout(embeddings, @dropout_rate)
        end
        
        embeddings
      end

      # Create positional encoding
      def create_positional_encoding(max_length, d_model)
        encoding = Array.new(max_length) { Array.new(d_model, 0.0) }
        
        (0...max_length).each do |pos|
          (0...d_model).each do |dim|
            if dim % 2 == 0
              encoding[pos][dim] = Math.sin(pos / (10000.0 ** (dim.to_f / d_model)))
            else
              encoding[pos][dim] = Math.cos(pos / (10000.0 ** ((dim - 1).to_f / d_model)))
            end
          end
        end
        
        encoding
      end

      # Split input into multiple heads
      def split_heads(input, n_heads)
        batch_size = input.length
        d_k = @d_model / n_heads
        
        heads = Array.new(n_heads) { [] }
        
        input.each do |vector|
          n_heads.times do |head|
            start_idx = head * d_k
            end_idx = (head + 1) * d_k
            heads[head] << vector[start_idx...end_idx]
          end
        end
        
        heads
      end

      # Concatenate multiple heads
      def concat_heads(heads)
        batch_size = heads[0].length
        concatenated = Array.new(batch_size) { [] }
        
        (0...batch_size).each do |i|
          heads.each do |head|
            concatenated[i].concat(head[i])
          end
        end
        
        concatenated
      end

      # Compute attention scores
      def compute_attention_scores(queries, keys, d_k)
        scores = Array.new(queries.length) { Array.new(keys.length, 0.0) }
        
        queries.each_with_index do |query, i|
          keys.each_with_index do |key, j|
            score = dot_product(query, key) / Math.sqrt(d_k)
            scores[i][j] = score
          end
        end
        
        scores
      end

      # Apply attention mask
      def apply_attention_mask(scores, mask)
        masked_scores = scores.map.with_index do |row, i|
          row.map.with_index do |score, j|
            mask[i][j] == 0 ? -1e9 : score
          end
        end
        
        masked_scores
      end

      # Create causal mask
      def create_causal_mask(seq_length)
        mask = Array.new(seq_length) { Array.new(seq_length, 0) }
        
        (0...seq_length).each do |i|
          (0..i).each do |j|
            mask[i][j] = 1
          end
        end
        
        mask
      end

      # Combine two masks
      def combine_masks(mask1, mask2)
        return mask2 unless mask1
        return mask1 unless mask2
        
        combined = Array.new(mask1.length) { Array.new(mask1[0].length, 0) }
        
        mask1.each_with_index do |row, i|
          row.each_with_index do |val, j|
            combined[i][j] = mask1[i][j] * mask2[i][j]
          end
        end
        
        combined
      end

      # Feed-forward network
      def feed_forward(input)
        # First linear layer with ReLU
        hidden = linear_transform(input, @parameters[:ff_w1][0])
        hidden = add_bias(hidden, @parameters[:ff_b1][0])
        hidden = relu(hidden)
        
        # Apply dropout
        if @dropout_rate > 0
          hidden = apply_dropout(hidden, @dropout_rate)
        end
        
        # Second linear layer
        output = linear_transform(hidden, @parameters[:ff_w2][0])
        output = add_bias(output, @parameters[:ff_b2][0])
        
        output
      end

      # Layer normalization
      def layer_norm(input)
        epsilon = 1e-6
        normalized = []
        
        input.each do |vector|
          # Calculate mean and variance
          mean = vector.sum.to_f / vector.length
          variance = vector.map { |x| (x - mean) ** 2 }.sum.to_f / vector.length
          
          # Normalize
          norm_vector = vector.map do |x|
            (x - mean) / Math.sqrt(variance + epsilon)
          end
          
          # Scale and shift (using first layer's parameters)
          scaled = norm_vector.map.with_index do |x, i|
            x * @parameters[:ln_gamma][0][i] + @parameters[:ln_beta][0][i]
          end
          
          normalized << scaled
        end
        
        normalized
      end

      # Add residual connection
      def add_residual(input, output)
        input.map.with_index do |vector, i|
          vector.map.with_index do |val, j|
            val + output[i][j]
          end
        end
      end

      # Linear transformation
      def linear_transform(input, weight)
        output = []
        
        input.each do |vector|
          transformed = Array.new(weight[0].length, 0.0)
          
          weight.each_with_index do |weight_row, i|
            weight_row.each_with_index do |w, j|
              transformed[j] += vector[i] * w
            end
          end
          
          output << transformed
        end
        
        output
      end

      # Add bias to vectors
      def add_bias(input, bias)
        input.map do |vector|
          vector.map.with_index { |val, i| val + bias[i] }
        end
      end

      # Matrix multiplication
      def matrix_multiply(a, b)
        result = Array.new(a.length) { Array.new(b[0].length, 0.0) }
        
        a.each_with_index do |row, i|
          b[0].length.times do |j|
            b.length.times do |k|
              result[i][j] += row[k] * b[k][j]
            end
          end
        end
        
        result
      end

      # Dot product
      def dot_product(vector1, vector2)
        vector1.zip(vector2).sum { |a, b| a * b }
      end

      # Softmax function
      def softmax(scores)
        scores.map do |row|
          max_score = row.max
          exp_scores = row.map { |s| Math.exp(s - max_score) }
          sum_exp = exp_scores.sum
          exp_scores.map { |e| e / sum_exp }
        end
      end

      # Softmax with temperature
      def softmax_with_temperature(logits, temperature)
        scaled_logits = logits.map { |l| l / temperature }
        max_logit = scaled_logits.max
        exp_logits = scaled_logits.map { |l| Math.exp(l - max_logit) }
        sum_exp = exp_logits.sum
        exp_logits.map { |e| e / sum_exp }
      end

      # ReLU activation
      def relu(input)
        input.map do |vector|
          vector.map { |val| [0, val].max }
        end
      end

      # Apply dropout (simplified)
      def apply_dropout(input, rate)
        return input if rate == 0
        
        input.map do |vector|
          vector.map do |val|
            rand > rate ? val / (1 - rate) : 0
          end
        end
      end

      # Sample from probability distribution
      def sample_from_distribution(probs)
        cumulative = 0.0
        rand_val = rand
        
        probs.each_with_index do |prob, idx|
          cumulative += prob
          return idx if rand_val <= cumulative
        end
        
        probs.length - 1
      end

      # Random matrix initialization
      def random_matrix(rows, cols)
        # Xavier initialization
        scale = Math.sqrt(6.0 / (rows + cols))
        Array.new(rows) { Array.new(cols) { (rand - 0.5) * 2 * scale } }
      end

      # Random vector initialization
      def random_vector(size)
        scale = Math.sqrt(1.0 / size)
        Array.new(size) { (rand - 0.5) * 2 * scale }
      end

      # Ones vector
      def ones_vector(size)
        Array.new(size, 1.0)
      end

      # Zeros vector
      def zeros_vector(size)
        Array.new(size, 0.0)
      end

      # Store attention weights for analysis
      def store_attention_weights(weights)
        @attention_weights["step_#{@attention_weights.length}"] = weights
      end

      # Compute average attention
      def compute_average_attention(weights)
        return 0.0 if weights.empty?
        
        total = weights.flatten.sum
        total / (weights.length * weights[0].length)
      end

      # Compute attention entropy
      def compute_attention_entropy(weights)
        entropy = 0.0
        
        weights.each do |row|
          row.each do |prob|
            entropy -= prob * Math.log(prob + 1e-10) if prob > 0
          end
        end
        
        entropy / weights.length
      end

      # Find most attended positions
      def find_most_attended_positions(weights)
        position_scores = Array.new(weights[0].length, 0.0)
        
        weights.each do |row|
          row.each_with_index do |score, pos|
            position_scores[pos] += score
          end
        end
        
        # Return top 5 positions
        position_scores.each_with_index
                      .sort_by { |score, _| -score }
                      .first(5)
                      .map { |score, pos| { position: pos, score: score } }
      end

      # Calculate parameter count
      def calculate_parameter_count
        count = {
          embedding: @vocab_size * @d_model,
          attention: 0,
          feed_forward: 0,
          total: 0
        }
        
        # Attention parameters
        n_attention_layers = case @mode
                           when :encoder_only then @n_encoder_layers
                           when :decoder_only then @n_decoder_layers
                           when :seq2seq then @n_encoder_layers + @n_decoder_layers
                           end
        
        count[:attention] = n_attention_layers * 4 * @d_model * @d_model
        
        # Feed-forward parameters
        count[:feed_forward] = n_attention_layers * 2 * (@d_model * @d_ff + @d_ff + @d_model)
        
        # Output projection
        if [:decoder_only, :seq2seq].include?(@mode)
          count[:embedding] += @d_model * @vocab_size
        end
        
        count[:total] = count.values.sum
        count
      end

      # Format large numbers
      def format_number(num)
        if num >= 1_000_000_000
          "#{(num / 1_000_000_000.0).round(2)}B"
        elsif num >= 1_000_000
          "#{(num / 1_000_000.0).round(2)}M"
        elsif num >= 1_000
          "#{(num / 1_000.0).round(2)}K"
        else
          num.to_s
        end
      end

      # Validate forward inputs
      def validate_forward_inputs(encoder_input, decoder_input)
        raise ArgumentError, "Encoder input cannot be nil" if encoder_input.nil?
        
        if @mode == :seq2seq && decoder_input.nil?
          raise ArgumentError, "Decoder input required for seq2seq mode"
        end
        
        if @mode != :seq2seq && decoder_input
          raise ArgumentError, "Decoder input not used in #{@mode} mode"
        end
      end

      # Educational output helper
      def educational_output(title, content)
        return unless @verbose_mode

        puts "\n#{title}"
        puts '=' * title.length
        puts content
      end
    end

    # Positional encoding utilities
    module PositionalEncoding
      # Sinusoidal positional encoding
      def self.sinusoidal(max_length, d_model)
        encoding = Array.new(max_length) { Array.new(d_model, 0.0) }
        
        (0...max_length).each do |pos|
          (0...d_model).each do |dim|
            if dim % 2 == 0
              encoding[pos][dim] = Math.sin(pos / (10000.0 ** (dim.to_f / d_model)))
            else
              encoding[pos][dim] = Math.cos(pos / (10000.0 ** ((dim - 1).to_f / d_model)))
            end
          end
        end
        
        encoding
      end

      # Learned positional encoding
      def self.learned(max_length, d_model)
        # Initialize random embeddings
        Array.new(max_length) { Array.new(d_model) { (rand - 0.5) * 0.1 } }
      end
    end
  end
end