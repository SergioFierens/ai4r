# Hopfield Networks

A Hopfield network is a classical recurrent neural network that stores patterns as stable states. It can remove noise from an input pattern by iteratively updating the neurons until it converges to the closest memorized pattern. While newer models like Transformers excel at sequence learning, Hopfield networks showcase associative memory in its simplest form.

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
net = Ai4r::NeuralNetwork::Hopfield.new(eval_iterations: 1000).train(data)
```

Evaluation uses the same vector format:

```ruby
result = net.eval(noisy_pattern)
```

## Tracing Convergence

Pass `trace: true` to `eval` to record the network state and energy after each
iteration. When enabled, `eval` returns a hash with two arrays:

* `:states` – pattern of neuron activations after every iteration including the
  initial input.
* `:energies` – the network energy corresponding to each state. This value
  should decrease or stay the same as the network converges.

The last elements of each array represent the final pattern and its energy.

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

`Ai4r::NeuralNetwork::Hopfield` supports several parameters which can be set when the network is created or later with `set_parameters`:

* `eval_iterations` – maximum number of iterations when calling `eval` (default `500`).
* `active_node_value` – numeric value representing an active neuron (default `1`).
* `inactive_node_value` – numeric value representing an inactive neuron (default `-1`).
* `threshold` – activation threshold used during propagation (default `0`).
* `weight_scaling` – scale factor applied when computing weights. When left `nil` the factor defaults to `1.0 / patterns_count`.
* `stop_when_stable` – stop evaluation early if the energy does not change between iterations (default `false`).
* `update_strategy` – update mode used during evaluation. `:async_random` (default) updates one randomly chosen neuron each step, while
  `:async_sequential` and `:synchronous` offer alternative behaviors.

```ruby

net.set_parameters(eval_iterations: 1000,
                   update_strategy: :async_random,
                   stop_when_stable: true)
trace = net.train(data).eval(noisy_pattern, trace: true)

```

You can also change the weight scaling factor:


```ruby
net = Ai4r::NeuralNetwork::Hopfield.new
net.set_parameters(weight_scaling: 0.5)
net.train(data)
```

## Theory

Each pattern is stored as a minimum of an energy function defined by the weight matrix. During evaluation the network repeatedly updates random neurons based on the weighted sum of their neighbours until the pattern stabilizes. If the input resembles one of the stored patterns the network will typically converge to it and thus clean the noise.

For further reading see the [Hopfield network](https://en.wikipedia.org/wiki/Hopfield_network) article.
