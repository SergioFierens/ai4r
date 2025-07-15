# Multilayer Perceptron

This wrapper trains a backpropagation neural network for classification. Inputs are one‑hot encoded and the last column of the dataset holds the class label.

## Parameters

* `network_class` – underlying network implementation. Default uses `Ai4r::NeuralNetwork::Backpropagation`.
* `network_parameters` – options forwarded to the neural network constructor.
* `hidden_layers` – array describing the hidden layer sizes. Default is an empty array.
* `training_iterations` – number of training epochs. Default is `500`.

## Example

```ruby
require 'ai4r/classifiers/multilayer_perceptron'
require 'ai4r/data/data_set'

items = [['New York', '<30', 'Y'], ['Chicago', '<30', 'N']]
labels = %w[city age class]
set = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)
mlp = Ai4r::Classifiers::MultilayerPerceptron.new.set_parameters(hidden_layers: [5]).build(set)
puts mlp.eval(['Chicago', '<30'])
```

For more background on neural networks see the [Neural Networks](neural_networks.md) page.
