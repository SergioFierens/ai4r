# AI4R - Artificial Intelligence for Ruby

*A comprehensive AI library where algorithms are transparent, not black boxes.*

---

## What Makes AI4R Different

AI4R provides readable, educational implementations of AI algorithms. Built for understanding first, performance second. Perfect for students learning AI, teachers demonstrating concepts, and researchers prototyping ideas.

### Quick Start
```ruby
gem install ai4r
```

```ruby
require 'ai4r'

# Neural network learns XOR in seconds
brain = Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 1])
brain.train([[0,0], [0]], [[1,0], [1]], [[0,1], [1]], [[1,1], [0]])

brain.eval([1, 0])  # => [0.99] - it learned!
```

---

## Learning Paths

### 🎯 [Beginner Track](docs/tutorials/beginner-track.md)
Foundation concepts through hands-on experiments. Classification, pathfinding, and algorithm comparison.

### 📈 [Intermediate Track](docs/tutorials/intermediate-track.md)  
Neural networks, game-playing AI, optimization techniques, and ensemble methods.

### 🔬 [Advanced Track](docs/tutorials/advanced-track.md)
Transformer architectures, distributed systems, meta-learning, and research-grade implementations.

**→ [Browse All Tutorials](docs/tutorials/)**

---

## Key Implementations

### Genetic Algorithms
```ruby
# Evolution tackles the Traveling Salesman Problem
ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(cities)
best_route = ga.run  # Observe natural selection optimize routes
```

### Transformer Architecture
```ruby
# Build modern transformer models with educational transparency
transformer = Ai4r::NeuralNetwork::Transformer.new(
  mode: :decoder_only,
  vocab_size: 1000,
  d_model: 512,
  n_heads: 8
)
```

### Hidden Markov Models
```ruby
# Sequence prediction with observable internals
hmm = Ai4r::MachineLearning::HiddenMarkovModel.new(states, observations)
predicted = hmm.viterbi(observed_sequence)
```

### A* Pathfinding
```ruby
# Intelligent navigation with multiple heuristics
astar = Ai4r::Search::AStar.new(maze, heuristic: :manhattan)
optimal_path = astar.find_path(start, goal)
```

---

## Algorithm Benchmarking

Compare algorithms systematically with built-in benchmarking tools.

### Classification Bench
```ruby
bench = Ai4r::Experiment::ClassifierBench.new(verbose: true)
bench.add_classifier(:decision_tree, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:neural_net, Ai4r::Classifiers::MultilayerPerceptron.new([4, 6, 3]))
bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)

results = bench.run(iris_dataset)
bench.display_results(results)
```

### Search Algorithm Bench
```ruby
bench = Ai4r::Experiment::SearchBench.new(verbose: true)
bench.add_algorithm(:astar_manhattan, Ai4r::Search::AStar.new(maze, heuristic: :manhattan))
bench.add_algorithm(:minimax, Ai4r::Search::Minimax.new(max_depth: 6))

results = bench.run()
bench.export_results(:html, "search_comparison.html")
```

**Applications:**
- **Education**: Demonstrate algorithm trade-offs empirically
- **Research**: Establish baselines, compare variations
- **Development**: Select optimal algorithms for production

---

## Algorithm Categories

Browse our comprehensive collection of **50+ algorithms** across all major AI domains:

| **Neural Networks** | **Search & Optimization** | **Machine Learning** |
|:---:|:---:|:---:|
| Backpropagation | A* Search | Decision Trees (ID3, PRISM) |
| Hopfield Networks | Minimax with α-β Pruning | K-Means & Hierarchical Clustering |
| Transformer Models | Genetic Algorithms | Naive Bayes & SVM |
| Self-Organizing Maps | Particle Swarm | Hidden Markov Models |

| **Data Processing** | **Evaluation** | **Educational Tools** |
|:---:|:---:|:---:|
| Statistical Analysis | Cross-Validation | Step-by-step Execution |
| Data Normalization | Confusion Matrices | Algorithm Visualization |
| Feature Engineering | ROC/AUC Analysis | Comparative Benchmarks |

**→ [View Complete Algorithm Catalog](docs/algorithm-catalog.md)** - Detailed list with direct links to implementations

---

## Why Choose AI4R

### For Students
- **Readable code**: Every algorithm is implemented clearly
- **No prerequisites**: Runs on any machine, no GPU required
- **Working examples**: Learn by experimentation

### For Educators
- **Live demonstrations**: Show algorithms in action
- **Modifiable**: Adjust implementations during lectures
- **Comprehensive**: Covers standard AI curriculum

### For Researchers
- **Rapid prototyping**: Test hypotheses quickly
- **Pure implementations**: No framework overhead
- **Extensible**: Ruby's flexibility enables experimentation

---

## Development Tools

### Run Tests
```bash
bundle exec rspec
```

### Generate Coverage Report
```bash
bundle exec rake coverage
# Open coverage/index.html for detailed report
```

### Code Quality
```bash
bundle exec rubocop        # Check code style
bundle exec rake quality   # Run all quality checks
```

### Interactive Console
```bash
bundle exec rake console   # Ruby console with AI4R loaded
```

---

## Getting Started

```bash
# Install
gem install ai4r

# Run benchmarks
bundle exec rake benchmark:classifiers
bundle exec rake benchmark:search

# Explore examples
ruby examples/neural_network/backpropagation_example.rb
ruby examples/genetic_algorithm/traveling_salesman_example.rb
```

**→ [Complete Documentation](docs/)**  
**→ [API Reference](docs/api/)**  
**→ [Example Gallery](examples/)**

---

## Contributing

- **Report Issues** → [GitHub Issues](https://github.com/SergioFierens/ai4r/issues)
- **Discuss Ideas** → [GitHub Discussions](https://github.com/SergioFierens/ai4r/discussions)
- **Submit Code** → Fork, branch, test, pull request

---

## License

**Public Domain** - No restrictions. See [UNLICENSE](UNLICENSE).

---

[⭐ **Star on GitHub**](https://github.com/SergioFierens/ai4r) | [📚 **Documentation**](docs/) | [💬 **Discussions**](https://github.com/SergioFierens/ai4r/discussions)