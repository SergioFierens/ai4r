# AI4R User Guide

This guide introduces the AI4R gem. It begins with a minimal example and gradually explains more features.

## Quick Start

1. Install the gem:

   ```bash
   gem install ai4r
   ```

2. Require the library in your project:

   ```ruby
   require 'ai4r'
   ```

### Minimal Example

Create a tiny dataset and build a classifier with the ID3 algorithm:

```ruby
require 'ai4r'

items = [
  ['sunny', 'warm', 'yes'],
  ['sunny', 'cold', 'no']
]
labels = ['weather', 'temperature', 'play']

data = Ai4r::Data::DataSet.new(:data_items => items, :data_labels => labels)
id3  = Ai4r::Classifiers::ID3.new.build(data)
puts id3.eval(['sunny', 'warm'])
```

Running this script prints `"yes"`.

## Working with Data

Datasets can be loaded from CSV files or created directly from arrays. Numeric attributes support normalization with either z-score or min-max scaling.

## Algorithm Overview

AI4R includes several algorithms:

* [ID3 Decision Trees](machine_learning.md)
* [Neural Networks](neural_networks.md) with backpropagation
* [Transformer](transformer.md) for sequence processing
* [Genetic Algorithms](genetic_algorithms.md) for optimization
* Clustering with [KMeans](kmeans.md) and [Hierarchical Clustering](hierarchical_clustering.md)
* Baseline classifiers like OneR, ZeroR and [Hyperpipes](hyperpipes.md)

See the documents in this directory for detailed tutorials on each topic.

## Advanced Features

Algorithms expose parameters through `set_parameters`. Explore available parameters with `get_parameters_info` to tune learning rate, random seeds and more.

## Running Examples

Example scripts live under the `examples/` directory. They demonstrate usage of classifiers, clustering techniques, neural networks and genetic algorithms.

## Testing

Install the development dependencies and run the test suite:

```bash
bundle install
bundle exec rake test
```

