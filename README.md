# AI4R — Artificial Intelligence for Ruby

A Ruby library of AI algorithms for learning and experimentation.

---

This project is an educational Ruby library for machine learning and artificial intelligence, featuring clean, minimal implementations of classical algorithms such as decision trees, neural networks, k-means and genetic algorithms. It is intentionally lightweight—no GPU support, no external dependencies, no production overhead—just a practical way to experiment, compare and learn the fundamental building blocks of AI. Ideal for small-scale explorations, course demos, or simply understanding how these algorithms work line by line.

Maintained over the years mostly for the joy of it (and perhaps a misplaced sense of duty to Ruby), this open-source library supports developers, students and educators who want to understand machine learning in Ruby without drowning in complexity.

## AI4R

AI4R is distributed as a gem and works with modern versions of Ruby.

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

#### Using OneR and ZeroR

```ruby
data = Ai4r::Data::DataSet.new.load_csv_with_labels 'examples/classifiers/zero_one_r_data.csv'

# ZeroR returns the most frequent class. The `tie_break` parameter controls what happens when more than one class has the same frequency.
zero_r = Ai4r::Classifiers::ZeroR.new
zero_r.set_parameters(tie_break: :random)
zero_r.build(data)

# OneR selects the single attribute with the lowest prediction error. You may force the attribute with `selected_attribute` or change the tie break behaviour with `tie_break`.
one_r = Ai4r::Classifiers::OneR.new
one_r.set_parameters(selected_attribute: 0, tie_break: :last)
one_r.build(data)
```

#### SimpleLinearRegression

```ruby
r = Ai4r::Classifiers::SimpleLinearRegression.new.build(data)
puts r.attribute  # attribute name used for the regression
puts r.slope      # regression slope
puts r.intercept  # regression intercept
```

#### LogisticRegression

```ruby
reg = Ai4r::Classifiers::LogisticRegression.new
reg.set_parameters(learning_rate: 0.5, iterations: 2000).build(data)
reg.eval([1, 0])
```

#### DataSet normalization

```ruby
data = Ai4r::Data::DataSet.new(data_items: [[1, 10], [2, 20]])
Ai4r::Data::DataSet.normalized(data, method: :minmax)
data.normalize!  # in place using z-score
```

#### KMeans random seed

```ruby
data = Ai4r::Data::DataSet.new(data_items: [[1, 2], [3, 4], [5, 6]])
data.normalize!
kmeans = Ai4r::Clusterers::KMeans.new
kmeans.set_parameters(random_seed: 1).build(data, 2)
```

#### SOM distance metric

```ruby
layer = Ai4r::Som::TwoPhaseLayer.new(10, distance_metric: :euclidean)
som = Ai4r::Som::Som.new(4, 8, 8, layer)
som.initiate_map
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

### Disclaimer

This software is provided "as is" and without any express or implied warranties, including, without limitation, the implied warranties of merchantibility and fitness for a particular purpose.

