# Neural Networks: Backpropagation OCR

AI4R includes a classic backpropagation neural network implementation. While [decision trees](machine_learning.md) or [logistic regression](logistic_regression.md) rely on explicit rules and formulas, neural networks learn directly from examples. They map inputs to outputs through weighted layers, the basis of modern deep learning.

For attention-based models see the [Transformer](transformer.md) guide. The rest of this page covers the feed-forward network used in the library.

The library demonstrates a simple optical character recognition system. Patterns such as triangles, squares and crosses are represented by 16x16 matrices where pixels range from 0 (white) to 10 (black). The network has 256 input neurons and three outputs corresponding to the shapes.

Training data looks like this using the `train_epochs` helper:

```ruby
net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3])
# TRIANGLE, SQUARE and CROSS are 16x16 matrices
inputs  = [TRIANGLE, SQUARE, CROSS].map { |m| m.flatten.map { |v| v.to_f / 10 } }
outputs = [[1,0,0], [0,1,0], [0,0,1]]
net.train_epochs(inputs, outputs, epochs: 100, batch_size: 1)
```

After training, the network can evaluate noisy patterns with good accuracy.

## Customizing Parameters

Adjust learning rate, momentum and propagation function, or simply set `activation` to a built-in one:

```ruby
net.set_parameters(
  momentum: 0.15,
  learning_rate: 0.5,
  propagation_function: ->(x) { Math.tanh(x) },
  derivative_propagation_function: ->(y) { 1.0 - y**2 }
)
```
Choose weight initialization via `weight_init`: `:uniform`, `:xavier`, or `:he`:
```ruby
net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3], :tanh, :xavier)
net.set_parameters(weight_init: :he)
```
`uniform` replicates the classic random weights in `[-1, 1)`. `xavier` works
well with sigmoid or tanh activations while `he` is better suited for ReLU
networks.

Alternatively you can simply specify the activation name. Available activations
are `:sigmoid`, `:tanh`, `:relu` and `:softmax`:

```ruby
net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3], :tanh)
net.set_parameters(activation: :relu)
```

## Loss Functions

Backpropagation returns the training loss after each update. The default
loss is mean squared error (`:mse`) which is suitable for regression or
continuous outputs. For classification problems you can switch to
cross entropy (`:cross_entropy`) which penalizes confident mistakes:

```ruby
net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3])
net.set_parameters(loss_function: :cross_entropy)
```
This will automatically use the `:softmax` activation on the output layer
unless you override the activation or propagation functions.

## Batch Training API

Use `train_batch` to update the network with a list of examples and
`train_epochs` to run multiple passes over the dataset. `train_epochs`
returns an array with the loss of each epoch so you can easily plot the
learning curve. Training can also stop early by providing
`early_stopping_patience` and `min_delta` parameters.

```ruby
history = net.train_epochs(
  inputs, outputs,
  epochs: 100,
  batch_size: 1,
  early_stopping_patience: 5,
  min_delta: 0.001
)

require 'gruff'
g = Gruff::Line.new
g.title = 'Training Loss'
g.data(:loss, history)
g.write('loss.png')
```

For a recurrent associative network that can recall patterns from noisy inputs see the [Hopfield network](hopfield_network.md) document. For unsupervised feature mapping see [Self-Organizing Maps](som.md).

### Additional Examples

Example scripts under `examples/neural_network` demonstrate other uses:

* `xor_example.rb` – trains a tiny network to learn the XOR logic gate.
* `patterns_with_noise.rb` – shows how the OCR network copes with noisy data.
* `hopfield_example.rb` – associative memory with Hopfield networks.
* `transformer_text_classification.rb` – pairs a Transformer encoder with logistic regression for text sentiment.
* `../som/som_single_example.rb` – explores Self-Organizing Maps.

See the [Artificial Neural Network](http://en.wikipedia.org/wiki/Artificial_neural_network) and [Backpropagation](http://en.wikipedia.org/wiki/Backpropagation) articles for more information.
