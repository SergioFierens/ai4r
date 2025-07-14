# Minimal Transformer

`Ai4r::NeuralNetwork::Transformer` implements a tiny transformer architecture. It can operate as an encoder, a decoder or a full encoder‑decoder (sequence‑to‑sequence) model. Token embeddings, sinusoidal positional encodings, multi‑head attention and a two‑layer feed‑forward network are provided. Weights are initialized randomly and the model is not trainable.

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

## Toy Text Classification Example

The example script `examples/neural_network/transformer_text_classification.rb`
shows how to pair the encoder with logistic regression for a tiny
sentence classifier. A handful of short greetings and farewells are
converted into token ids, passed through the Transformer encoder and the
resulting vectors averaged. Logistic regression then learns to classify
those mean vectors.

Run the script with:

```bash
ruby examples/neural_network/transformer_text_classification.rb
```

