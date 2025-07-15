# AI4R API Reference

This document provides comprehensive API documentation for the AI4R library, organized by module and functionality.

## 📚 Module Overview

- [**Data Handling**](#data-handling) - DataSet, Statistics, Proximity, Parameterizable
- [**Neural Networks**](#neural-networks) - Backpropagation, Hopfield, SOM
- [**Genetic Algorithms**](#genetic-algorithms) - GeneticSearch, Chromosome operators
- [**Classification**](#classification) - ID3, NaiveBayes, OneR, PRISM, and more
- [**Clustering**](#clustering) - K-means, Hierarchical clustering, DIANA
- [**Evaluation**](#evaluation) - ClassifierEvaluator, performance metrics

---

## Data Handling

### Ai4r::Data::DataSet

The core data structure for all AI4R algorithms.

#### Constructor
```ruby
DataSet.new(options = {})
```

**Parameters:**
- `data_items`: Array of arrays containing the actual data
- `data_labels`: Array of strings with column names

**Example:**
```ruby
dataset = Ai4r::Data::DataSet.new(
  data_items: [[1, 2, 'A'], [3, 4, 'B']],
  data_labels: ['x', 'y', 'class']
)
```

#### Key Methods

##### `#load_csv_with_labels(file_path)`
Loads data from a CSV file with header row.

**Parameters:**
- `file_path`: String path to CSV file

**Returns:** DataSet instance

**Example:**
```ruby
dataset = DataSet.new.load_csv_with_labels('data.csv')
```

##### `#split(ratio)`
Splits dataset into training and test sets.

**Parameters:**
- `ratio`: Float between 0 and 1 (training set proportion)

**Returns:** Array of two DataSet instances [training, test]

**Example:**
```ruby
train_set, test_set = dataset.split(0.7)
```

##### `#get_mean_or_mode`
Calculates mean for numeric columns, mode for categorical.

**Returns:** Array of means/modes for each column

##### `#normalize_min_max`
Normalizes numeric data to [0,1] range.

**Returns:** New DataSet with normalized data

##### `#build_domains`
Analyzes data to determine value ranges for each attribute.

**Returns:** Array of domains (Sets for categorical, ranges for numeric)

##### `#[]` (indexing)
Extracts rows by index or range.

**Parameters:**
- `index`: Integer index or Range

**Returns:** DataSet with selected rows

**Example:**
```ruby
first_row = dataset[0]
first_three = dataset[0..2]
```

---

### Ai4r::Data::Statistics

Statistical functions for data analysis.

#### Static Methods

##### `Statistics.mean(array)`
Calculates arithmetic mean.

**Parameters:**
- `array`: Array of numeric values

**Returns:** Float

##### `Statistics.median(array)`
Finds middle value (or average of two middle values).

**Parameters:**
- `array`: Array of numeric values

**Returns:** Numeric

##### `Statistics.mode(array)`
Finds most frequent value.

**Parameters:**
- `array`: Array of values

**Returns:** Most frequent value

##### `Statistics.variance(array)`
Calculates population variance.

**Parameters:**
- `array`: Array of numeric values

**Returns:** Float

##### `Statistics.standard_deviation(array)`
Calculates standard deviation.

**Parameters:**
- `array`: Array of numeric values

**Returns:** Float

##### `Statistics.max(array)` / `Statistics.min(array)`
Find maximum/minimum values.

**Parameters:**
- `array`: Array of numeric values

**Returns:** Numeric

---

### Ai4r::Data::Proximity

Distance and similarity metrics.

#### Distance Methods

##### `Proximity.euclidean_distance(point_a, point_b)`
Calculates Euclidean (L2) distance.

**Parameters:**
- `point_a`, `point_b`: Arrays of numeric values

**Returns:** Float

**Formula:** √(Σ(aᵢ - bᵢ)²)

##### `Proximity.manhattan_distance(point_a, point_b)`
Calculates Manhattan (L1) distance.

**Parameters:**
- `point_a`, `point_b`: Arrays of numeric values

**Returns:** Float

**Formula:** Σ|aᵢ - bᵢ|

##### `Proximity.minkowski_distance(point_a, point_b, p)`
Calculates Minkowski distance (generalized).

**Parameters:**
- `point_a`, `point_b`: Arrays of numeric values
- `p`: Numeric parameter (1=Manhattan, 2=Euclidean)

**Returns:** Float

#### Similarity Methods

##### `Proximity.cosine_similarity(vector_a, vector_b)`
Calculates cosine similarity.

**Parameters:**
- `vector_a`, `vector_b`: Arrays of numeric values

**Returns:** Float between -1 and 1

##### `Proximity.jaccard_similarity(set_a, set_b)`
Calculates Jaccard similarity for binary data.

**Parameters:**
- `set_a`, `set_b`: Arrays of binary values

**Returns:** Float between 0 and 1

---

### Ai4r::Data::Parameterizable

Mixin module for algorithm parameter management.

#### Methods

##### `#set_parameters(params)`
Sets multiple parameters at once.

**Parameters:**
- `params`: Hash of parameter names and values

**Returns:** Self (for chaining)

**Example:**
```ruby
algorithm.set_parameters(
  learning_rate: 0.1,
  momentum: 0.9,
  max_iterations: 1000
)
```

##### `#get_parameters`
Retrieves current parameter values.

**Returns:** Hash of current parameters

---

## Neural Networks

### Ai4r::NeuralNetwork::Backpropagation

Multi-layer feedforward neural network with backpropagation learning.

#### Constructor
```ruby
Backpropagation.new(layer_sizes)
```

**Parameters:**
- `layer_sizes`: Array of integers specifying neurons per layer

**Example:**
```ruby
# 2 inputs, 4 hidden, 1 output
network = Backpropagation.new([2, 4, 1])
```

#### Key Methods

##### `#init_network`
Initializes weights and network structure.

**Returns:** Self (for chaining)

**Example:**
```ruby
network = Backpropagation.new([2, 4, 1]).init_network
```

##### `#train(inputs, outputs)`
Trains network on single input-output pair.

**Parameters:**
- `inputs`: Array of input values
- `outputs`: Array of expected output values

**Example:**
```ruby
network.train([0, 1], [1])  # XOR training example
```

##### `#eval(inputs)`
Evaluates network on given inputs.

**Parameters:**
- `inputs`: Array of input values

**Returns:** Array of output values

**Example:**
```ruby
result = network.eval([0, 1])
puts result  # => [0.95] (approximately 1)
```

##### `#set_parameters(params)`
Sets training parameters.

**Common Parameters:**
- `learning_rate`: Float (default 0.25)
- `momentum`: Float (default 0.1)

**Example:**
```ruby
network.set_parameters(learning_rate: 0.1, momentum: 0.9)
```

---

### Ai4r::NeuralNetwork::Hopfield

Recurrent neural network for associative memory.

#### Constructor
```ruby
Hopfield.new(size)
```

**Parameters:**
- `size`: Integer number of neurons

#### Key Methods

##### `#train(patterns)`
Trains network on multiple patterns.

**Parameters:**
- `patterns`: Array of arrays containing binary patterns

**Example:**
```ruby
hopfield = Hopfield.new(4)
hopfield.train([[1, -1, 1, -1], [-1, 1, -1, 1]])
```

##### `#eval(pattern)`
Retrieves stored pattern most similar to input.

**Parameters:**
- `pattern`: Array of binary values

**Returns:** Array of retrieved pattern

---

### Ai4r::Som::Som

Self-Organizing Map for unsupervised learning.

#### Constructor
```ruby
Som.new(width, height, data_set)
```

**Parameters:**
- `width`, `height`: Integer dimensions of SOM grid
- `data_set`: DataSet containing training data

#### Key Methods

##### `#train(iterations)`
Trains the SOM for specified number of iterations.

**Parameters:**
- `iterations`: Integer number of training cycles

##### `#find_winner(input)`
Finds best matching unit for given input.

**Parameters:**
- `input`: Array of input values

**Returns:** Integer index of winning neuron

---

## Genetic Algorithms

### Ai4r::GeneticAlgorithm::GeneticSearch

Main genetic algorithm implementation.

#### Constructor
```ruby
GeneticSearch.new(initial_population_or_data, config = {})
```

**Parameters:**
- `initial_population_or_data`: Array of chromosomes or problem data
- `config`: Hash of algorithm parameters

#### Key Methods

##### `#run`
Executes the genetic algorithm.

**Returns:** Best chromosome found

**Example:**
```ruby
ga = GeneticSearch.new(cities_data)
best_solution = ga.run
```

##### `#set_parameters(params)`
Sets algorithm parameters.

**Common Parameters:**
- `population_size`: Integer (default 20)
- `max_generation`: Integer (default 100)
- `selection_func`: Symbol (:roulette_wheel, :tournament)
- `mutation_rate`: Float (default 0.01)
- `crossover_rate`: Float (default 0.8)

---

### Ai4r::GeneticAlgorithm::Chromosome

Base class for genetic algorithm solutions.

#### Key Methods

##### `#fitness`
Abstract method returning chromosome quality.

**Returns:** Numeric fitness value (higher = better)

##### `#reproduce(other_chromosome)`
Creates offspring through crossover.

**Parameters:**
- `other_chromosome`: Another chromosome for mating

**Returns:** New chromosome

##### `#mutate`
Applies random changes to chromosome.

**Returns:** Self (modified)

---

## Classification

### Ai4r::Classifiers::ID3

Decision tree classifier using Information Gain.

#### Key Methods

##### `#build(data_set)`
Constructs decision tree from training data.

**Parameters:**
- `data_set`: DataSet with training examples

**Example:**
```ruby
classifier = ID3.new
classifier.build(training_data)
```

##### `#eval(item)`
Classifies a single instance.

**Parameters:**
- `item`: Array of attribute values

**Returns:** Predicted class label

**Example:**
```ruby
prediction = classifier.eval(['sunny', 'hot', 'normal', 'weak'])
```

##### `#get_rules`
Extracts human-readable rules from tree.

**Returns:** Array of rule strings

---

### Ai4r::Classifiers::NaiveBayes

Probabilistic classifier based on Bayes' theorem.

#### Key Methods

##### `#build(data_set)`
Builds probability tables from training data.

##### `#eval(item)`
Classifies using probability calculations.

**Returns:** Most probable class label

---

### Ai4r::Classifiers::OneR

Simple rule-based classifier (One Rule).

#### Key Methods

##### `#build(data_set)`
Finds best single-attribute rule.

##### `#eval(item)`
Applies the learned rule.

---

### Ai4r::Classifiers::PRISM

Rule-based classifier generating multiple rules.

#### Key Methods

##### `#build(data_set)`
Generates covering rule set.

##### `#get_rules`
Returns learned rules in readable format.

---

### Ai4r::Classifiers::ZeroR

Baseline classifier that always predicts majority class.

#### Key Methods

##### `#build(data_set)`
Finds majority class in training data.

##### `#eval(item)`
Always returns majority class.

---

## Clustering

### Ai4r::Clusterers::KMeans

Partitional clustering using centroids.

#### Key Methods

##### `#build(data_set, k)`
Performs k-means clustering.

**Parameters:**
- `data_set`: DataSet to cluster
- `k`: Integer number of clusters

**Returns:** Self with clusters assigned

**Example:**
```ruby
clusterer = KMeans.new
clusterer.build(data, 3)
puts clusterer.clusters.length  # => 3
```

##### `#clusters`
Returns array of cluster DataSets.

##### `#centroids`
Returns array of cluster center points.

---

### Ai4r::Clusterers::SingleLinkage

Hierarchical clustering with single linkage.

#### Key Methods

##### `#build(data_set, k)`
Builds hierarchy and cuts at k clusters.

**Parameters:**
- `data_set`: DataSet to cluster
- `k`: Integer final number of clusters

---

### Ai4r::Clusterers::CompleteLinkage

Hierarchical clustering with complete linkage.

#### Key Methods

##### `#build(data_set, k)`
Similar to SingleLinkage but uses maximum distance between clusters.

---

### Ai4r::Clusterers::Diana

Divisive hierarchical clustering.

#### Key Methods

##### `#build(data_set, k)`
Top-down hierarchical clustering approach.

---

## Evaluation

### Ai4r::Experiment::ClassifierEvaluator

Performance evaluation tools for classifiers.

#### Static Methods

##### `ClassifierEvaluator.accuracy(actual, predicted)`
Calculates classification accuracy.

**Parameters:**
- `actual`: Array of true class labels
- `predicted`: Array of predicted class labels

**Returns:** Float between 0 and 1

**Example:**
```ruby
accuracy = ClassifierEvaluator.accuracy(['A', 'B', 'A'], ['A', 'A', 'A'])
puts accuracy  # => 0.667
```

##### `ClassifierEvaluator.precision(actual, predicted, target_class)`
Calculates precision for specific class.

**Parameters:**
- `actual`: Array of true labels
- `predicted`: Array of predicted labels  
- `target_class`: Class to calculate precision for

**Returns:** Float between 0 and 1

##### `ClassifierEvaluator.recall(actual, predicted, target_class)`
Calculates recall for specific class.

**Parameters:**
- `actual`: Array of true labels
- `predicted`: Array of predicted labels
- `target_class`: Class to calculate recall for

**Returns:** Float between 0 and 1

##### `ClassifierEvaluator.confusion_matrix(actual, predicted)`
Generates confusion matrix.

**Parameters:**
- `actual`: Array of true labels
- `predicted`: Array of predicted labels

**Returns:** Hash of hash showing classification results

---

## 🔧 Parameter Reference

### Common Parameter Patterns

#### Learning Rates
- **Range:** 0.001 to 1.0
- **Typical:** 0.01 to 0.3
- **Higher:** Faster learning, less stability
- **Lower:** Slower learning, more stability

#### Population Sizes (Genetic Algorithms)
- **Range:** 10 to 1000+
- **Typical:** 20 to 100
- **Larger:** Better exploration, slower computation
- **Smaller:** Faster execution, limited diversity

#### Cluster Numbers
- **Range:** 2 to √n (where n = data points)
- **Evaluation:** Use silhouette score or elbow method
- **Domain knowledge:** Often guides selection

---

## 🚀 Quick Reference

### Essential Workflow Patterns

#### Supervised Learning
```ruby
# 1. Prepare data
dataset = DataSet.new(data_items: data, data_labels: labels)
train, test = dataset.split(0.8)

# 2. Train classifier
classifier = ID3.new
classifier.build(train)

# 3. Evaluate
predictions = test.data_items.map { |item| classifier.eval(item[0..-2]) }
actual = test.data_items.map { |item| item[-1] }
accuracy = ClassifierEvaluator.accuracy(actual, predictions)
```

#### Clustering
```ruby
# 1. Prepare data
dataset = DataSet.new(data_items: data, data_labels: labels)

# 2. Cluster
clusterer = KMeans.new
clusterer.build(dataset, 3)

# 3. Analyze
clusterer.clusters.each_with_index do |cluster, i|
  puts "Cluster #{i}: #{cluster.data_items.length} points"
end
```

#### Neural Networks
```ruby
# 1. Create network
network = Backpropagation.new([inputs, hidden, outputs]).init_network

# 2. Train
training_data.each do |input, output|
  network.train(input, output)
end

# 3. Test
test_data.each do |input, expected|
  actual = network.eval(input)
  puts "Expected: #{expected}, Got: #{actual}"
end
```

---

For more detailed examples and explanations, see the [Tutorials](../tutorials/) and [Examples](../examples/) sections.