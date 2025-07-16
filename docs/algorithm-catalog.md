# AI4R Algorithm Catalog

*Complete reference of all implemented algorithms with direct links to source code.*

---

## Table of Contents

- [Classifiers](#classifiers)
- [Clusterers](#clusterers)
- [Neural Networks](#neural-networks)
- [Search Algorithms](#search-algorithms)
- [Genetic Algorithms](#genetic-algorithms)
- [Machine Learning](#machine-learning)
- [Self-Organizing Maps](#self-organizing-maps)
- [Benchmarking Tools](#benchmarking-tools)
- [Data Processing](#data-processing-utilities)

---

## Classifiers

Algorithms for supervised learning and classification tasks.

### Decision Trees & Rule-Based

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **ID3** | Decision tree using information gain and entropy | [`lib/ai4r/classifiers/id3.rb`](../lib/ai4r/classifiers/id3.rb) |
| **Prism** | Rule-based classification algorithm | [`lib/ai4r/classifiers/prism.rb`](../lib/ai4r/classifiers/prism.rb) |
| **OneR** | Single-rule classifier (One Rule) | [`lib/ai4r/classifiers/one_r.rb`](../lib/ai4r/classifiers/one_r.rb) |

### Neural Network Classifiers

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **MultilayerPerceptron** | Feedforward neural network for classification | [`lib/ai4r/classifiers/multilayer_perceptron.rb`](../lib/ai4r/classifiers/multilayer_perceptron.rb) |
| **LogisticRegression** | Binary and multi-class logistic regression | [`lib/ai4r/classifiers/logistic_regression.rb`](../lib/ai4r/classifiers/logistic_regression.rb) |

### Instance-Based Learning

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **IB1** | Instance-based learning (1-nearest neighbor) | [`lib/ai4r/classifiers/ib1.rb`](../lib/ai4r/classifiers/ib1.rb) |
| **EnhancedKNearestNeighbors** | k-NN with distance weighting and optimization | [`lib/ai4r/classifiers/enhanced_k_nearest_neighbors.rb`](../lib/ai4r/classifiers/enhanced_k_nearest_neighbors.rb) |
| **Hyperpipes** | Hyperrectangle-based classification | [`lib/ai4r/classifiers/hyperpipes.rb`](../lib/ai4r/classifiers/hyperpipes.rb) |

### Probabilistic Classifiers

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **NaiveBayes** | Probabilistic classifier using Bayes' theorem | [`lib/ai4r/classifiers/naive_bayes.rb`](../lib/ai4r/classifiers/naive_bayes.rb) |
| **SupportVectorMachine** | SVM for binary and multi-class classification | [`lib/ai4r/classifiers/support_vector_machine.rb`](../lib/ai4r/classifiers/support_vector_machine.rb) |

### Baseline & Regression

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **ZeroR** | Baseline classifier (predicts most frequent class) | [`lib/ai4r/classifiers/zero_r.rb`](../lib/ai4r/classifiers/zero_r.rb) |
| **SimpleLinearRegression** | Linear regression for continuous values | [`lib/ai4r/classifiers/simple_linear_regression.rb`](../lib/ai4r/classifiers/simple_linear_regression.rb) |

### Educational Implementations

Educational wrappers with step-by-step execution and visualization:
- [`lib/ai4r/classifiers/educational_classification.rb`](../lib/ai4r/classifiers/educational_classification.rb)
- [`lib/ai4r/classifiers/educational_algorithms.rb`](../lib/ai4r/classifiers/educational_algorithms.rb)

---

## Clusterers

Algorithms for unsupervised learning and clustering tasks.

### Partitioning Methods

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **KMeans** | Classic k-means clustering | [`lib/ai4r/clusterers/k_means.rb`](../lib/ai4r/clusterers/k_means.rb) |
| **BisectingKMeans** | Hierarchical k-means using bisection | [`lib/ai4r/clusterers/bisecting_k_means.rb`](../lib/ai4r/clusterers/bisecting_k_means.rb) |
| **GaussianMixtureModel** | GMM clustering with expectation-maximization | [`lib/ai4r/clusterers/gaussian_mixture_model.rb`](../lib/ai4r/clusterers/gaussian_mixture_model.rb) |

### Hierarchical Clustering

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **SingleLinkage** | Minimum distance linkage | [`lib/ai4r/clusterers/single_linkage.rb`](../lib/ai4r/clusterers/single_linkage.rb) |
| **CompleteLinkage** | Maximum distance linkage | [`lib/ai4r/clusterers/complete_linkage.rb`](../lib/ai4r/clusterers/complete_linkage.rb) |
| **AverageLinkage** | Average distance linkage | [`lib/ai4r/clusterers/average_linkage.rb`](../lib/ai4r/clusterers/average_linkage.rb) |
| **WeightedAverageLinkage** | Weighted average linkage | [`lib/ai4r/clusterers/weighted_average_linkage.rb`](../lib/ai4r/clusterers/weighted_average_linkage.rb) |
| **CentroidLinkage** | Centroid-based linkage | [`lib/ai4r/clusterers/centroid_linkage.rb`](../lib/ai4r/clusterers/centroid_linkage.rb) |
| **MedianLinkage** | Median-based linkage | [`lib/ai4r/clusterers/median_linkage.rb`](../lib/ai4r/clusterers/median_linkage.rb) |
| **WardLinkage** | Ward's minimum variance method | [`lib/ai4r/clusterers/ward_linkage.rb`](../lib/ai4r/clusterers/ward_linkage.rb) |
| **WardLinkageHierarchical** | Enhanced Ward with dendrogram support | [`lib/ai4r/clusterers/ward_linkage_hierarchical.rb`](../lib/ai4r/clusterers/ward_linkage_hierarchical.rb) |
| **Diana** | Divisive Analysis clustering | [`lib/ai4r/clusterers/diana.rb`](../lib/ai4r/clusterers/diana.rb) |

### Density-Based Clustering

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **DBSCAN** | Density-based spatial clustering | [`lib/ai4r/clusterers/dbscan.rb`](../lib/ai4r/clusterers/dbscan.rb) |

### Educational Implementations

- [`lib/ai4r/clusterers/educational_clustering.rb`](../lib/ai4r/clusterers/educational_clustering.rb)
- [`lib/ai4r/clusterers/educational_algorithms.rb`](../lib/ai4r/clusterers/educational_algorithms.rb)

---

## Neural Networks

Deep learning architectures and components.

### Core Architectures

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **Backpropagation** | Classic feedforward neural network | [`lib/ai4r/neural_network/backpropagation.rb`](../lib/ai4r/neural_network/backpropagation.rb) |
| **Hopfield** | Recurrent neural network for associative memory | [`lib/ai4r/neural_network/hopfield.rb`](../lib/ai4r/neural_network/hopfield.rb) |
| **Transformer** | Modern attention-based architecture | [`lib/ai4r/neural_network/transformer.rb`](../lib/ai4r/neural_network/transformer.rb) |
| **EnhancedNeuralNetwork** | Advanced features and optimizations | [`lib/ai4r/neural_network/enhanced_neural_network.rb`](../lib/ai4r/neural_network/enhanced_neural_network.rb) |

### Components

#### Activation Functions
[`lib/ai4r/neural_network/activation_functions.rb`](../lib/ai4r/neural_network/activation_functions.rb)
- **Sigmoid** - Classic logistic function
- **Tanh** - Hyperbolic tangent
- **ReLU** - Rectified Linear Unit
- **LeakyReLU** - ReLU with small negative slope
- **ELU** - Exponential Linear Unit
- **Swish** - Self-gated activation
- **GELU** - Gaussian Error Linear Unit
- **Softmax** - Probability distribution

#### Optimizers
[`lib/ai4r/neural_network/optimizers.rb`](../lib/ai4r/neural_network/optimizers.rb)
- **SGD** - Stochastic Gradient Descent
- **Momentum** - SGD with momentum
- **NAG** - Nesterov Accelerated Gradient
- **AdaGrad** - Adaptive gradient
- **RMSprop** - Root Mean Square propagation
- **Adam** - Adaptive moment estimation
- **AdamW** - Adam with weight decay

#### Learning Algorithms
[`lib/ai4r/neural_network/learning_algorithms.rb`](../lib/ai4r/neural_network/learning_algorithms.rb)

#### Regularization
[`lib/ai4r/neural_network/regularization.rb`](../lib/ai4r/neural_network/regularization.rb)
- **Dropout** - Random neuron deactivation
- **L1/L2** - Weight penalty regularization
- **ElasticNet** - Combined L1/L2
- **BatchNormalization** - Normalize layer inputs
- **EarlyStopping** - Prevent overfitting

### Educational Implementations

- [`lib/ai4r/neural_network/educational_neural_network.rb`](../lib/ai4r/neural_network/educational_neural_network.rb)
- [`lib/ai4r/neural_network/educational_examples.rb`](../lib/ai4r/neural_network/educational_examples.rb)

---

## Search Algorithms

Algorithms for pathfinding and game tree search.

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **AStar** | A* pathfinding with multiple heuristics | [`lib/ai4r/search/a_star.rb`](../lib/ai4r/search/a_star.rb) |
| **Minimax** | Game tree search with alpha-beta pruning | [`lib/ai4r/search/minimax.rb`](../lib/ai4r/search/minimax.rb) |

---

## Genetic Algorithms

Evolutionary computation and optimization.

### Core Implementations

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **GeneticSearch** | Classic genetic algorithm | [`lib/ai4r/genetic_algorithm/genetic_algorithm.rb`](../lib/ai4r/genetic_algorithm/genetic_algorithm.rb) |
| **ModernGeneticSearch** | Modular GA framework | [`lib/ai4r/genetic_algorithm/modern_genetic_search.rb`](../lib/ai4r/genetic_algorithm/modern_genetic_search.rb) |
| **EducationalGeneticSearch** | GA with learning features | [`lib/ai4r/genetic_algorithm/educational_genetic_search.rb`](../lib/ai4r/genetic_algorithm/educational_genetic_search.rb) |

### Chromosome Types
[`lib/ai4r/genetic_algorithm/chromosome.rb`](../lib/ai4r/genetic_algorithm/chromosome.rb)
- **BinaryChromosome** - Binary string representation
- **PermutationChromosome** - Order-based problems
- **RealChromosome** - Real-valued optimization
- **TSPChromosome** - Traveling Salesman Problem

### Genetic Operators

#### Selection Operators
[`lib/ai4r/genetic_algorithm/operators.rb`](../lib/ai4r/genetic_algorithm/operators.rb)
- **FitnessProportionate** - Roulette wheel selection
- **Tournament** - Competition-based selection
- **Rank** - Rank-based selection
- **Boltzmann** - Temperature-based selection

#### Crossover Operators
[`lib/ai4r/genetic_algorithm/enhanced_operators.rb`](../lib/ai4r/genetic_algorithm/enhanced_operators.rb)
- **SinglePoint** - Single crossover point
- **TwoPoint** - Two crossover points
- **Uniform** - Gene-by-gene exchange
- **Order** - Preserves order (permutations)
- **Cycle** - Cycle-based (permutations)

#### Mutation Operators
- **BitFlip** - Binary mutation
- **Gaussian** - Normal distribution noise
- **Polynomial** - Polynomial probability
- **Swap** - Exchange positions
- **Adaptive** - Self-adjusting rate

---

## Machine Learning

Additional machine learning algorithms.

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **RandomForest** | Ensemble of decision trees | [`lib/ai4r/machine_learning/random_forest.rb`](../lib/ai4r/machine_learning/random_forest.rb) |
| **PCA** | Principal Component Analysis | [`lib/ai4r/machine_learning/pca.rb`](../lib/ai4r/machine_learning/pca.rb) |
| **HiddenMarkovModel** | Sequential data modeling | [`lib/ai4r/machine_learning/hidden_markov_model.rb`](../lib/ai4r/machine_learning/hidden_markov_model.rb) |

---

## Self-Organizing Maps

Kohonen networks for unsupervised learning.

| Algorithm | Description | Source |
|-----------|-------------|--------|
| **Som** | Self-Organizing Map | [`lib/ai4r/som/som.rb`](../lib/ai4r/som/som.rb) |
| **TwoPhaseLayer** | Two-phase SOM training | [`lib/ai4r/som/two_phase_layer.rb`](../lib/ai4r/som/two_phase_layer.rb) |
| **EducationalSom** | SOM with visualization | [`lib/ai4r/som/educational_som.rb`](../lib/ai4r/som/educational_som.rb) |

---

## Benchmarking Tools

Tools for algorithm comparison and evaluation.

| Tool | Description | Source |
|------|-------------|--------|
| **ClassifierBench** | Compare classifier performance | [`lib/ai4r/experiment/classifier_bench.rb`](../lib/ai4r/experiment/classifier_bench.rb) |
| **SearchBench** | Compare search algorithms | [`lib/ai4r/experiment/search_bench.rb`](../lib/ai4r/experiment/search_bench.rb) |
| **ClassifierEvaluator** | Detailed performance metrics | [`lib/ai4r/experiment/classifier_evaluator.rb`](../lib/ai4r/experiment/classifier_evaluator.rb) |

---

## Data Processing Utilities

Tools for data manipulation and analysis.

### Core Data Structures
- **DataSet** - Primary data container ([`lib/ai4r/data/data_set.rb`](../lib/ai4r/data/data_set.rb))
- **EnhancedDataSet** - Advanced features ([`lib/ai4r/data/enhanced_data_set.rb`](../lib/ai4r/data/enhanced_data_set.rb))

### Data Processing
- **DataNormalizer** - Feature normalization ([`lib/ai4r/data/data_normalizer.rb`](../lib/ai4r/data/data_normalizer.rb))
- **DataSplitter** - Train/test splitting ([`lib/ai4r/data/data_splitter.rb`](../lib/ai4r/data/data_splitter.rb))
- **FeatureScaler** - Feature scaling ([`lib/ai4r/data/feature_scaler.rb`](../lib/ai4r/data/feature_scaler.rb))
- **FeatureEngineer** - Feature creation ([`lib/ai4r/data/feature_engineer.rb`](../lib/ai4r/data/feature_engineer.rb))

### Data Quality
- **OutlierDetector** - Anomaly detection ([`lib/ai4r/data/outlier_detector.rb`](../lib/ai4r/data/outlier_detector.rb))
- **MissingValueHandler** - Handle missing data ([`lib/ai4r/data/missing_value_handler.rb`](../lib/ai4r/data/missing_value_handler.rb))

### Analysis
- **Statistics** - Statistical utilities ([`lib/ai4r/data/statistics.rb`](../lib/ai4r/data/statistics.rb))
- **Proximity** - Distance metrics ([`lib/ai4r/data/proximity.rb`](../lib/ai4r/data/proximity.rb))

### Visualization
- **DataVisualization** - Data plotting ([`lib/ai4r/data/data_visualization.rb`](../lib/ai4r/data/data_visualization.rb))
- **VisualizationTools** - Algorithm visualization ([`lib/ai4r/genetic_algorithm/visualization_tools.rb`](../lib/ai4r/genetic_algorithm/visualization_tools.rb))

---

## Usage Examples

### Quick Classification
```ruby
require 'ai4r'

# Load data
data = Ai4r::Data::DataSet.new(...)

# Train classifier
classifier = Ai4r::Classifiers::ID3.new
classifier.build(data)

# Make predictions
result = classifier.eval([feature1, feature2, ...])
```

### Algorithm Comparison
```ruby
# Set up benchmark
bench = Ai4r::Experiment::ClassifierBench.new
bench.add_classifier(:tree, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:bayes, Ai4r::Classifiers::NaiveBayes.new)

# Run comparison
results = bench.run(dataset)
bench.display_results(results)
```

### Neural Network Training
```ruby
# Create network
nn = Ai4r::NeuralNetwork::Backpropagation.new([4, 8, 3])

# Train
nn.train(inputs, outputs)

# Evaluate
prediction = nn.eval(new_input)
```

---

## Contributing New Algorithms

To add a new algorithm:

1. Implement in appropriate category directory
2. Include `Parameterizable` module for configuration
3. Add educational wrapper if applicable
4. Write comprehensive tests
5. Update this catalog

See [Contributing Guide](../CONTRIBUTING.md) for details.

---

**[← Back to Documentation](./)**