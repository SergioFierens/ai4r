# Minimal Transformer

`Ai4r::NeuralNetwork::Transformer` implements a tiny transformer architecture. Classical feed‑forward networks process each input independently, but transformers use self‑attention to relate every token in a sequence to every other token. This idea sparked a revolution in natural language processing and beyond.

The implementation here is intentionally minimal. It can operate as an encoder, a decoder or a full encoder‑decoder (sequence‑to‑sequence) model. Token embeddings, sinusoidal positional encodings, multi‑head attention and a two‑layer feed‑forward network are provided. Weights are initialized randomly and the model is not trainable.

## Usage

```ruby
require 'ai4r/neural_network/transformer'

model = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  embed_dim: 8,
  num_heads: 2,
  ff_dim: 16,
  architecture: :encoder
)

output = model.eval([1, 2, 3, 4])
# => array of 4 vectors of length 8

decoder = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  architecture: :decoder
)

decoder_output = decoder.eval([4, 5, 6])

seq2seq = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  architecture: :seq2seq
)

seq2seq_output = seq2seq.eval([1, 2, 3], [4, 5])
```

For a full toy classification demo using the decode-only configuration, see `examples/transformer/decode_classifier_example.rb`.

Transformers build on the same fundamentals as the backpropagation network described in [Neural Networks](neural_networks.md), but attention lets them capture long-range dependencies. Even this toy implementation highlights how sequences can be processed as a whole rather than token by token.
