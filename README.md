# AI4R - Artificial Intelligence for Ruby 🧠

*"The AI library that makes algorithms click, not just compute."*

---

## 🚀 What Makes AI4R Special

**AI4R isn't just another library** - it's an educational playground where AI concepts come alive. Built for students, teachers, and curious minds who want to understand how AI really works.

### ⚡ Quick Start
```ruby
gem install ai4r
```

```ruby
require 'ai4r'

# Build your first neural network in 30 seconds
brain = Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 1])
brain.train([[0,0], [0]], [[1,0], [1]], [[0,1], [1]], [[1,1], [0]])

puts brain.eval([1, 0])  # => It learned XOR! 🤯
```

---

## 🎯 Choose Your Learning Path

### 🌱 [Beginner Track](docs/tutorials/beginner-track.md) - "Your First Steps into AI"
Perfect for newcomers. Learn classification, pathfinding, and algorithm comparison through hands-on experiments.

### ⚡ [Intermediate Track](docs/tutorials/intermediate-track.md) - "Level Up Your AI Game"  
Neural networks, strategic search, optimization, and ensemble methods. For developers ready to dive deeper.

### 🎓 [Advanced Track](docs/tutorials/advanced-track.md) - "Research-Level AI Engineering"
Transformer architectures, distributed systems, meta-learning, and cutting-edge research techniques.

**→ [Start Your Journey](docs/tutorials/)**

---

## 🔥 Coolest Implementations

### 🧬 Genetic Algorithms
```ruby
# Evolution solves the Traveling Salesman Problem
ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(cities)
best_route = ga.run  # Watch evolution find optimal paths!
```

### 🤖 Transformer Architecture
```ruby
# Build GPT-style models with educational insights
transformer = Ai4r::NeuralNetwork::Transformer.new(
  mode: :decoder_only,  # GPT-style
  vocab_size: 1000,
  d_model: 512,
  n_heads: 8
)
```

### 🎯 Hidden Markov Models
```ruby
# Sequence modeling with step-by-step learning
hmm = Ai4r::MachineLearning::HiddenMarkovModel.new(states, observations)
predicted_sequence = hmm.viterbi(observations)
```

### 🔍 A* Pathfinding
```ruby
# Smart navigation with multiple heuristics
astar = Ai4r::Search::AStar.new(maze, heuristic: :manhattan)
path = astar.find_path(start, goal)
```

---

## ⚖️ The Ultimate AI Showdown - Algorithm Benches

**Compare algorithms like a pro researcher!**

### 🥊 Classification Bench
```ruby
bench = Ai4r::Experiment::ClassifierBench.new(verbose: true)
bench.add_classifier(:decision_tree, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:neural_net, Ai4r::Classifiers::MultilayerPerceptron.new([4, 6, 3]))
bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)

results = bench.run(iris_dataset)
bench.display_results(results)
# See which algorithm wins on your data!
```

### 🔍 Search Bench
```ruby
bench = Ai4r::Experiment::SearchBench.new(verbose: true)
bench.add_algorithm(:astar_manhattan, Ai4r::Search::AStar.new(maze, heuristic: :manhattan))
bench.add_algorithm(:astar_euclidean, Ai4r::Search::AStar.new(maze, heuristic: :euclidean))
bench.add_algorithm(:minimax, Ai4r::Search::Minimax.new(max_depth: 6))

results = bench.run()
# Race pathfinding algorithms head-to-head!
```

**Perfect for:**
- 🎓 **Students**: See algorithm trade-offs in action
- 👨‍🏫 **Teachers**: Live demos that make concepts clear  
- 🔬 **Researchers**: Rapid prototyping and baseline comparisons

---

## 🎪 Core Algorithm Arsenal

| **Neural Networks** | **Search & Optimization** | **Machine Learning** |
|:---:|:---:|:---:|
| 🧠 Backpropagation | 🔍 A* Search | 🎯 Decision Trees |
| 🌐 Hopfield Networks | 🎮 Minimax | 📊 K-Means Clustering |
| 🤖 Transformers | 🧬 Genetic Algorithms | 🔮 Naive Bayes |
| 🗺️ Self-Organizing Maps | 🎯 Particle Swarm | 📈 Hidden Markov Models |

| **Data Science** | **Evaluation** | **Educational** |
|:---:|:---:|:---:|
| 📊 Statistics | ⚖️ Cross-Validation | 🎓 Step-by-step Tutorials |
| 🔧 Preprocessing | 📈 Performance Metrics | 🔬 Interactive Experiments |
| 📈 Visualization | 📊 Confusion Matrices | 🎯 Benchmarking Frameworks |

---

## 🌟 Why Students & Teachers Love AI4R

### 🎓 **For Students:**
- **"I can actually see what's happening!"** - Clear, readable implementations
- **"It runs on my laptop!"** - No GPU requirements
- **"The examples just work!"** - Copy, paste, learn, experiment

### 👨‍🏫 **For Teachers:**
- **"Perfect for live coding demos"** - Algorithms in action
- **"Students ask better questions"** - Understanding breeds curiosity
- **"Covers my entire AI curriculum"** - Comprehensive coverage

### 🔬 **For Researchers:**
- **"Rapid prototyping paradise"** - Test ideas quickly
- **"Clean baselines for comparison"** - Pure algorithm implementations
- **"Easy to modify and extend"** - Ruby's flexibility shines

---

## 🚀 Real Examples That Inspire

### 🧠 **XOR Neural Network**
See how a simple network learns the "impossible" XOR function that stumped early AI!

### 🗺️ **Evolution Finds Routes**
Watch genetic algorithms solve traveling salesman problems in real-time!

### 🌸 **Iris Classification Showdown**
Compare 5 different algorithms on the classic flower dataset!

### 🤖 **Strategic Game AI**
Build Minimax algorithms that think several moves ahead!

---

## 🎯 Get Started Now

```bash
# Install
gem install ai4r

# Your first experiment
require 'ai4r'

# Compare algorithms on the iris dataset
bench = Ai4r::Experiment::ClassifierBench.new
bench.add_classifier(:tree, Ai4r::Classifiers::ID3.new)
bench.add_classifier(:bayes, Ai4r::Classifiers::NaiveBayes.new)

results = bench.run(iris_data)
bench.display_results(results)
```

**→ [Complete Tutorial Tracks](docs/tutorials/)**  
**→ [API Documentation](docs/)**  
**→ [Working Examples](examples/)**

---

## 🤝 Join the Community

- 🐛 **Found a bug?** → [Open an issue](https://github.com/SergioFierens/ai4r/issues)
- 💡 **Cool example idea?** → [Share it with us](https://github.com/SergioFierens/ai4r/discussions)
- 📚 **Teaching with AI4R?** → [Tell us your story](https://github.com/SergioFierens/ai4r/discussions)

---

## 📄 License

**Public Domain** - Use it anywhere, anytime, for any purpose. See [UNLICENSE](UNLICENSE) for details.

**Made with ❤️ for curious minds everywhere**

[⭐ **Star this repo**](https://github.com/SergioFierens/ai4r) if AI4R sparks your curiosity!