# Hopfield Networks

A Hopfield network is a recurrent neural network that stores patterns as stable states. It can remove noise from an input pattern by iteratively updating the neurons until it converges to the closest memorized pattern.

## Input Format

Training requires an `Ai4r::Data::DataSet` where each `data_item` is an array of values. Values must match the `active_node_value` and `inactive_node_value` parameters (by default `1` and `-1`). Any other value will cause `train` to raise `ArgumentError`. All patterns must have the same length.

```ruby
require 'ai4r/neural_network/hopfield'
require 'ai4r/data/data_set'

patterns = [
  [1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, -1],
  [-1, -1, 1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, -1, 1, 1]
]

data = Ai4r::Data::DataSet.new(data_items: patterns)
net = Ai4r::NeuralNetwork::Hopfield.new.train(data)
```

Evaluation uses the same vector format:

```ruby
result = net.eval(noisy_pattern)
```

## Tracing Convergence

Pass `trace: true` to `eval` to record the network state and energy after each
iteration. The method returns a hash with `:states` and `:energies` arrays.

```ruby
trace = net.eval(noisy_pattern, trace: true)

require 'gnuplot'
Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title = 'Hopfield Energy'
    plot.data << Gnuplot::DataSet.new(trace[:energies]) { |ds| ds.with = 'lines' }
  end
end
```

The resulting plot shows how the energy decreases as the network converges.

## Parameters

`Ai4r::NeuralNetwork::Hopfield` supports several parameters which can be set with `set_parameters`:

* `eval_iterations` – maximum number of iterations when calling `eval` (default `500`).
* `active_node_value` – value representing an active neuron (default `1`).
* `inactive_node_value` – value representing an inactive neuron (default `-1`).
* `threshold` – activation threshold used during propagation (default `0`).
* `update_strategy` – update mode used during evaluation. `:async_random` (default) updates one randomly chosen neuron each step, while
  `:async_sequential` and `:synchronous` offer alternative behaviors.

```ruby
net.set_parameters(eval_iterations: 1000, threshold: 0.2)
```

## Theory

Each pattern is stored as a minimum of an energy function defined by the weight matrix. During evaluation the network repeatedly updates random neurons based on the weighted sum of their neighbours until the pattern stabilizes. If the input resembles one of the stored patterns the network will typically converge to it and thus clean the noise.

For further reading see the [Hopfield network](https://en.wikipedia.org/wiki/Hopfield_network) article.
