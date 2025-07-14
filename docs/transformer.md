# Minimal Transformer

`Ai4r::NeuralNetwork::Transformer` implements a small self‑attention encoder. It includes token embeddings, sinusoidal positional encoding, multi‑head attention and a two‑layer feed‑forward network. Weights are initialized randomly and the model is not trainable.

## Usage

```ruby
require 'ai4r/neural_network/transformer'

model = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  embed_dim: 8,
  num_heads: 2,
  ff_dim: 16
)

output = model.eval([1, 2, 3, 4])
# => array of 4 vectors of length 8
```
