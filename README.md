# AI4R — Artificial Intelligence for Ruby

A Ruby library of AI algorithms for learning and experimentation.

---

This project is an educational Ruby library for machine learning and artificial intelligence, featuring clean, minimal implementations of classical algorithms such as decision trees, neural networks, k-means and genetic algorithms. It is intentionally lightweight—no GPU support, no external dependencies, no production overhead—just a practical way to experiment, compare and learn the fundamental building blocks of AI. Ideal for small-scale explorations, course demos, or simply understanding how these algorithms work line by line.

Maintained over the years mostly for the joy of it (and perhaps a misplaced sense of duty to Ruby), this open-source library supports developers, students and educators who want to understand machine learning in Ruby without drowning in complexity.

Over time the project has stretched beyond classical techniques. A bite-sized Transformer implementation now ships with AI4R, so you can tinker with encoder-only, decoder-only and seq2seq modes—the modern building blocks of today's language models—without leaving the comfort of Ruby.

## AI4R

AI4R is distributed as a gem and requires Ruby 3.2 or later.

### Installation

Install the gem using RubyGems:

```bash
gem install ai4r
```

Add the library to your code:

```ruby
require 'ai4r'
```

OneR and Prism support numeric attributes by discretizing them into a fixed number of bins. The amount of bins can be controlled with the `bin_count` parameter.

### Usage examples

#### Genetic algorithm

```ruby
require 'ai4r/genetic_algorithm/genetic_algorithm'
Ai4r::GeneticAlgorithm::TspChromosome.set_cost_matrix(cost_matrix)
search = Ai4r::GeneticAlgorithm::GeneticSearch.new(
  800, 100, Ai4r::GeneticAlgorithm::TspChromosome, 0.3, 0.4
)
best = search.run
puts best.fitness
```

#### Self-Organizing Maps (SOM)

```ruby
layer = Ai4r::Som::TwoPhaseLayer.new(10, distance_metric: :euclidean)
som = Ai4r::Som::Som.new(4, 8, 8, layer)
som.initiate_map
10.times { som.train_step(data) }
```

#### Multilayer Perceptron with Backpropagation

```ruby
net = Ai4r::NeuralNetwork::Backpropagation.new([256, 3])
inputs  = [TRIANGLE, SQUARE, CROSS].map { |m| m.flatten.map { |v| v.to_f / 10 } }
outputs = [[1,0,0], [0,1,0], [0,0,1]]
net.train_epochs(inputs, outputs, epochs: 100, batch_size: 1)
```

#### ID3 Decision Trees

```ruby
items  = [['sunny', 'warm', 'yes'], ['sunny', 'cold', 'no']]
labels = ['weather', 'temperature', 'play']
data   = Ai4r::Data::DataSet.new(data_items: items, data_labels: labels)
id3    = Ai4r::Classifiers::ID3.new.build(data)
id3.eval(['sunny', 'warm'])  # => 'yes'
```

#### Hopfield Networks

```ruby
patterns = [[1, 1, -1, -1], [-1, -1, 1, 1]]
data = Ai4r::Data::DataSet.new(data_items: patterns)
net = Ai4r::NeuralNetwork::Hopfield.new.train(data)
net.eval([1, -1, -1, -1])
```

#### Naive Bayes

```ruby
set = Ai4r::Data::DataSet.new
set.load_csv_with_labels 'examples/classifiers/naive_bayes_data.csv'

classifier = Ai4r::Classifiers::NaiveBayes.new
classifier.set_parameters(m: 3).build(set)
puts classifier.eval(['Red', 'SUV', 'Domestic'])
```

#### Transformer

```ruby
encoder = Ai4r::NeuralNetwork::Transformer.new(
  vocab_size: 50,
  max_len: 10,
  architecture: :encoder
)
encoder.eval([1, 2, 3, 4])
```

Scripts under `examples/clusterers` showcase additional features such as custom distance functions and dendrogram generation. Some hierarchical algorithms cannot classify new items once built—use `supports_eval?` to verify before calling `eval`.

### Documentation

Tutorials for genetic algorithms, ID3 decision trees, Hyperpipes, neural networks, Naive Bayes, IB1, PRISM and more are available in the `docs/` directory. Examples under `examples/` demonstrate how to run several algorithms. All clustering algorithms expose a uniform interface:

```ruby
clusterer.build(data_set, number_of_clusters = nil)
```

`number_of_clusters` is ignored by algorithms such as DBSCAN that determine the count from the data. Clusters are returned as `Ai4r::Data::DataSet` objects for consistency across implementations.

### Running Tests

Install development dependencies with Bundler and run the test suite:

```bash
bundle install
bundle exec rake test
```

### Limitations

- Not optimized for performance
- No support for GPU, parallelism, or distributed training
- Not intended for production deployment

### Disclaimer

This software is provided "as is" and without any express or implied warranties, including, without limitation, the implied warranties of merchantibility and fitness for a particular purpose.

