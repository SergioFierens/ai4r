# AI4R Educational Documentation

**Artificial Intelligence for Ruby - Educational Framework**

AI4R is a comprehensive Ruby library designed for AI education, providing hands-on learning experiences for students and teachers of artificial intelligence and machine learning.

## 🎓 For Students and Educators

This documentation is specifically designed for:
- **Students** learning AI and machine learning concepts
- **Teachers** looking for practical educational tools
- **Researchers** needing a clear, educational implementation platform

## 📚 Learning Paths

### 🚀 Quick Start
- [Getting Started](README.md) - Installation and basic setup
- [Your First AI Program](tutorials/README.md) - Step-by-step introduction

### 📖 Comprehensive Tutorials
- [**Data Handling Tutorial**](tutorials/data-handling.md) - Learn data preprocessing, cleaning, and feature engineering
- [**Neural Networks Tutorial**](tutorials/neural-networks.md) - Complete guide to neural networks with hands-on examples  
- [**Genetic Algorithms Tutorial**](tutorials/genetic-algorithms.md) - Evolutionary computation and optimization
- [**Classification Tutorial**](tutorials/classification-tutorial.md) - Decision trees, naive Bayes, and more classifiers
- [**Clustering Tutorial**](tutorials/clustering-tutorial.md) - Unsupervised learning and pattern discovery

### 📋 Reference Guides
- [**Algorithm Catalog**](algorithm-catalog.md) - Complete list of 50+ implemented algorithms with source links
- [**Genetic Algorithms Guide**](guides/genetic-algorithms.md) - Algorithm details and implementation
- [**Neural Networks Guide**](guides/neural-networks.md) - Network architectures and training methods
- [**Machine Learning Guide**](guides/machine-learning.md) - ML algorithms and techniques

### 💻 Practical Examples
- [**Example Programs**](examples/README.md) - Ready-to-run code examples
- [**Educational Demos**](examples/educational-demos.md) - Interactive learning demonstrations

### 🔧 Reference Materials
- [**API Reference**](reference/api.md) - Complete class and method documentation
- [**Source Code Guide**](reference/source-code.md) - Understanding the codebase

## 🎯 Learning Objectives

By working through this documentation, you will:

1. **Understand Core AI Concepts**
   - How neural networks learn from data
   - How genetic algorithms solve optimization problems
   - How classification algorithms make decisions
   - How clustering reveals patterns in data

2. **Gain Practical Skills**
   - Data preprocessing and feature engineering
   - Model training and evaluation
   - Parameter tuning and optimization
   - Experimental design and analysis

3. **Develop Problem-Solving Abilities**
   - Choose appropriate algorithms for different problems
   - Debug and improve model performance
   - Design experiments to test hypotheses
   - Interpret and communicate results

## 🏗️ Framework Features

### Educational Design
- **Progressive Learning**: Start simple, build complexity gradually
- **Interactive Examples**: Hands-on experimentation with immediate feedback
- **Visual Understanding**: Clear explanations with visual aids where possible
- **Comparative Analysis**: Compare different approaches side-by-side

### Comprehensive Coverage
- **Neural Networks**: Backpropagation, Hopfield networks, Self-Organizing Maps
- **Genetic Algorithms**: Selection, crossover, mutation operators with TSP examples
- **Classification**: Decision trees, naive Bayes, k-NN, and more
- **Clustering**: K-means, hierarchical clustering, density-based methods
- **Data Processing**: Cleaning, normalization, feature engineering, validation

### Code Quality
- **Well-Tested**: Comprehensive test suite with RSpec
- **Educational Focus**: Clear, readable code with extensive documentation
- **Modular Design**: Easy to understand and extend
- **Best Practices**: Follows Ruby and ML development standards

## 📖 How to Use This Documentation

### For Students
1. **Start with [Getting Started](README.md)** to set up your environment
2. **Choose a learning path** based on your interests:
   - New to AI? Start with [Data Handling](tutorials/data-handling.md)
   - Interested in neural networks? Go to [Neural Networks Tutorial](tutorials/neural-networks.md)
   - Want to solve optimization problems? Try [Genetic Algorithms](tutorials/genetic-algorithms.md)
3. **Work through examples** in each tutorial
4. **Experiment** with the code and try variations
5. **Refer to guides** for deeper understanding

### For Teachers
1. **Review the [Educational Philosophy](tutorials/README.md)** behind the framework
2. **Use tutorials as course material** - they're designed for classroom use
3. **Assign example programs** as homework or lab exercises
4. **Create custom assignments** using the framework as a foundation
5. **Encourage experimentation** - the framework is designed to be safe to explore

### For Self-Study
- **Follow the tutorials in order** for a structured learning experience
- **Try all the examples** and modify them to test your understanding
- **Use the reference guides** to dive deeper into topics that interest you
- **Join the community** - contribute examples or ask questions

## 🚀 Quick Example

Here's a taste of what you can do with AI4R:

```ruby
require 'ai4r'

# Train a neural network to solve XOR
network = Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 1])
network.train([[0,0],[0,1],[1,0],[1,1]], [0,1,1,0])

# Use genetic algorithm for traveling salesman
cities = [[0,0], [1,1], [2,0], [0,2]]
ga = Ai4r::GeneticAlgorithm::GeneticSearch.new(cities)
best_route = ga.run

# Classify data with decision trees
classifier = Ai4r::Classifiers::ID3.new
classifier.build(training_data)
prediction = classifier.eval(test_instance)
```

## 🤝 Contributing

This is an educational project - contributions that improve the learning experience are welcome! See our [contribution guidelines](CONTRIBUTING.md) for details.

## 📄 License

AI4R is provided under the Mozilla Public License 1.1 (MPL 1.1), making it free for educational use.

---

**Ready to start learning?** Begin with [Getting Started](README.md) or jump into any tutorial that interests you!