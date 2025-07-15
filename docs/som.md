# Self-Organizing Maps

AI4R provides a lightweight implementation of Kohonen's Self-Organizing
Map (SOM) under `Ai4r::Som`. A SOM maps high dimensional data into a
lower dimensional grid where nearby nodes respond to similar patterns.

## Quick Example

```ruby
require 'ai4r/som/som'

layer = Ai4r::Som::TwoPhaseLayer.new(10, distance_metric: :euclidean)
som = Ai4r::Som::Som.new(4, 8, 8, layer)
som.initiate_map

# `data` is an array of numeric vectors. The iris dataset from
# `examples/som/som_data.rb` works well.
10.times do
  som.train_step(data)
end
```

`train_step` updates the map for a single epoch and returns the global
error. You can call `train` to run until the configured epoch count or
an optional `error_threshold` is reached.

```ruby
errors = som.train(data, error_threshold: 1000) do |err|
  puts "epoch #{som.epoch} error=#{err}"
end
```

## Customizing Parameters

Both layers and nodes accept a `distance_metric` parameter
(`:chebyshev`, `:euclidean` or `:manhattan`). The `TwoPhaseLayer`
additionally lets you tune the number of epochs for each phase and the
learning rates:

```ruby
layer = Ai4r::Som::TwoPhaseLayer.new(
  10,                 # nodes per side
  0.9,                # initial learning rate
  150,                # phase one epochs
  100,                # phase two epochs
  0.1,                # phase one learning rate
  0.01,               # phase two learning rate
  distance_metric: :euclidean
)
```

Weights are initialized randomly in `[0, 1)` by default. Pass
`random_seed:` to `Som#initiate_map` for reproducible runs.

See `examples/som` for complete scripts exploring early stopping and map
size effects.
