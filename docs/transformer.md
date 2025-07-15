# Minimal Transformer

`Ai4r::NeuralNetwork::Transformer` is a bite‑sized implementation of the Transformer architecture. It keeps the core ideas—token embeddings, sinusoidal positional encodings, multi‑head attention and a two‑layer feed‑forward network—while discarding the heavy training machinery. Everything is initialized at random, so you can focus on understanding the flow of data rather than achieving state‑of‑the‑art results.

## Architecture options

When creating a Transformer you pick one of three modes:

* **Encoder** – processes a single sequence and returns its contextualized token vectors. Useful for classification or as the first half of a sequence‑to‑sequence model.
* **Decoder** – predicts a sequence given its own past tokens. It uses causal attention so each position only attends to previous ones. Great for toy language models or decode‑only classifiers.
* **Seq2seq** – combines an encoder and a decoder. The decoder attends both to its own history and to the encoder output, mimicking translation or summarization setups.

## Usage

```ruby
require 'ai4r/neural_network/transformer'

encoder = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  architecture: :encoder
)
enc_output = encoder.eval([1, 2, 3, 4])
# => array of 4 vectors of length encoder.embed_dim

decoder = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  architecture: :decoder
)
dec_output = decoder.eval([4, 5, 6])

seq2seq = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  architecture: :seq2seq
)
seq2seq_output = seq2seq.eval([1, 2, 3], [4, 5])
```

## Examples

* **Decode‑only text classification** – [`examples/transformer/decode_classifier_example.rb`](../examples/transformer/decode_classifier_example.rb) shows how to build embeddings with a decoder and train logistic regression on top.
* **Encoder sentiment demo** – [`examples/neural_network/transformer_text_classification.rb`](../examples/neural_network/transformer_text_classification.rb) uses the encoder to create sentence vectors for a tiny sentiment dataset.
