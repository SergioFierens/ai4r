# frozen_string_literal: true
# Minimal Transformer implementation
# Author::    OpenAI Assistant
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../data/parameterizable'
require_relative 'activation_functions'

module Ai4r
  module NeuralNetwork
    # A tiny Transformer encoder with embeddings, positional encoding,
    # multi-head self-attention and a feed-forward layer.
    # Weights are initialized randomly and the model is not trainable.
    class Transformer
      include Ai4r::Data::Parameterizable

      parameters_info embed_dim: 'Embedding dimension.',
                      num_heads: 'Number of attention heads.',
                      ff_dim: 'Feed-forward hidden size.',
                      vocab_size: 'Vocabulary size.',
                      max_len: 'Maximum sequence length.'

      attr_accessor :embed_dim, :num_heads, :ff_dim, :vocab_size, :max_len

      # Initialize the Transformer with given hyperparameters.
      def initialize(vocab_size:, max_len:, embed_dim: 8, num_heads: 2, ff_dim: 32)
        @vocab_size = vocab_size
        @max_len = max_len
        @embed_dim = embed_dim
        @num_heads = num_heads
        @ff_dim = ff_dim
        raise ArgumentError, 'embed_dim must be divisible by num_heads' if embed_dim % num_heads != 0
        init_weights
        build_positional_encoding
      end

      # Evaluate a sequence of integer token ids. Returns an array of
      # length seq_len with embed_dim sized vectors.
      def eval(tokens)
        raise ArgumentError, 'sequence too long' if tokens.length > @max_len
        x = tokens.map.with_index { |t, i| add(@token_embeddings[t], @positional[i]) }
        x = multi_head_attention(x)
        feed_forward(x)
      end

      private

      def head_dim
        @embed_dim / @num_heads
      end

      def init_weights
        @token_embeddings = Array.new(@vocab_size) { Array.new(@embed_dim) { rand * 2 - 1 } }
        hd = head_dim
        @heads = Array.new(@num_heads) do
          {
            q: Array.new(@embed_dim) { Array.new(hd) { rand * 2 - 1 } },
            k: Array.new(@embed_dim) { Array.new(hd) { rand * 2 - 1 } },
            v: Array.new(@embed_dim) { Array.new(hd) { rand * 2 - 1 } }
          }
        end
        @wo = Array.new(@num_heads * hd) { Array.new(@embed_dim) { rand * 2 - 1 } }
        @w1 = Array.new(@embed_dim) { Array.new(@ff_dim) { rand * 2 - 1 } }
        @b1 = Array.new(@ff_dim, 0.0)
        @w2 = Array.new(@ff_dim) { Array.new(@embed_dim) { rand * 2 - 1 } }
        @b2 = Array.new(@embed_dim, 0.0)
      end

      def build_positional_encoding
        @positional = Array.new(@max_len) do |pos|
          Array.new(@embed_dim) do |i|
            angle = pos / (10000.0 ** ((2 * (i / 2)) / @embed_dim.to_f))
            i.even? ? Math.sin(angle) : Math.cos(angle)
          end
        end
      end

      def add(a, b)
        a.each_index.map { |i| a[i] + b[i] }
      end

      def dot(a, b)
        sum = 0.0
        a.each_index { |i| sum += a[i] * b[i] }
        sum
      end

      def matmul(mat, weights)
        mat.map do |row|
          weights.transpose.map { |w| dot(row, w) }
        end
      end

      def softmax(vec)
        m = vec.max
        exps = vec.map { |v| Math.exp(v - m) }
        sum = exps.inject(:+)
        exps.map { |e| e / sum }
      end

      def multi_head_attention(x)
        hd = head_dim
        heads_out = @heads.map do |h|
          q = matmul(x, h[:q])
          k = matmul(x, h[:k])
          v = matmul(x, h[:v])
          scores = matmul(q, k.transpose)
          scale = Math.sqrt(hd.to_f)
          scores.map! { |row| softmax(row.map { |v| v / scale }) }
          matmul(scores, v)
        end
        concat = Array.new(x.length) { [] }
        heads_out.each do |head|
          head.each_index do |i|
            concat[i].concat(head[i])
          end
        end
        matmul(concat, @wo)
      end

      def relu(x)
        x > 0 ? x : 0
      end

      def affine(mat, weights, bias)
        mat.map do |row|
          weights.transpose.map.with_index { |w, j| dot(row, w) + bias[j] }
        end
      end

      def feed_forward(x)
        h = affine(x, @w1, @b1)
        h.map! { |row| row.map { |v| relu(v) } }
        affine(h, @w2, @b2)
      end
    end
  end
end

