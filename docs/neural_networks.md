# Neural Networks: Backpropagation OCR

AI4R includes a backpropagation neural network implementation. Neural networks infer functions from observations and are useful when business rules are hard to define.

## OCR Example

The library demonstrates a simple optical character recognition system. Patterns such as triangles, squares and crosses are represented by 16x16 matrices where pixels range from 0 (white) to 10 (black). The network has 256 input neurons and three outputs corresponding to the shapes.

Training data looks like this:

```ruby
net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3])
# TRIANGLE, SQUARE and CROSS are 16x16 matrices
100.times do
  net.train(TRIANGLE.flatten.map { |v| v.to_f / 10 }, [1,0,0])
  net.train(SQUARE.flatten.map { |v| v.to_f / 10 }, [0,1,0])
  net.train(CROSS.flatten.map { |v| v.to_f / 10 }, [0,0,1])
end
```

After training, the network can evaluate noisy patterns with good accuracy.

## Customizing Parameters

You can tweak the learning rate, momentum and propagation function:

```ruby
net.set_parameters(
  momentum: 0.15,
  learning_rate: 0.5,
  propagation_function: ->(x) { Math.tanh(x) },
  derivative_propagation_function: ->(y) { 1.0 - y**2 }
)
```

For a recurrent associative network that can recall patterns from noisy inputs see the [Hopfield network](hopfield_network.md) document.

See the [Artificial Neural Network](http://en.wikipedia.org/wiki/Artificial_neural_network) and [Backpropagation](http://en.wikipedia.org/wiki/Backpropagation) articles for more information.
