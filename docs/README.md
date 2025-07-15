# AI4R :: Artificial Intelligence for Ruby

**Educational AI Framework for Students and Teachers**

## 🎓 Educational Mission

AI4R is specifically designed as an educational platform for learning artificial intelligence and machine learning concepts. Unlike production ML libraries, AI4R prioritizes **clear, understandable implementations** that help students and teachers explore AI algorithms step-by-step.

## 🚀 Quick Start for Educators

### Installation
```bash
gem install ai4r
```

### Your First AI Program
```ruby
require 'ai4r'

# Train a neural network to solve XOR
network = Ai4r::NeuralNetwork::Backpropagation.new([2, 4, 1])
network.init_network

# Training data: XOR truth table
inputs = [[0,0], [0,1], [1,0], [1,1]]
outputs = [[0], [1], [1], [0]]

# Train the network
100.times do
  inputs.each_with_index do |input, i|
    network.train(input, outputs[i])
  end
end

# Test the trained network
inputs.each_with_index do |input, i|
  result = network.eval(input)
  puts "#{input} -> #{result.first.round(2)} (expected: #{outputs[i].first})"
end
```

## 📚 What AI4R Teaches

### Core AI Concepts
- **Neural Networks**: How brain-inspired algorithms learn patterns
- **Genetic Algorithms**: How evolution solves optimization problems  
- **Classification**: How machines make decisions from data
- **Clustering**: How to discover hidden patterns
- **Data Processing**: The foundation of all machine learning

### Educational Philosophy
1. **Learn by Doing**: Hands-on examples you can run immediately
2. **Understand the Why**: Clear explanations of how algorithms work
3. **Experiment Safely**: Modify parameters and see immediate results
4. **Build Intuition**: Visual and conceptual understanding, not just math

## 🎯 Perfect for Learning

### For Students
- **Start Simple**: Basic concepts with clear examples
- **Progress Gradually**: Build complexity step by step
- **Experiment Freely**: Safe environment for exploration
- **See Results**: Immediate feedback on algorithm changes

### For Teachers
- **Classroom Ready**: Examples designed for live demonstration
- **Assignment Friendly**: Easy to modify for homework problems
- **Conceptually Clear**: Focus on understanding, not just implementation
- **Comprehensive**: Covers major AI topics in one framework

## 🏗️ Complete AI Coverage

### 🧠 Neural Networks
- **Backpropagation**: Multi-layer perceptron with clear training visualization
- **Hopfield Networks**: Associative memory and pattern completion
- **Self-Organizing Maps**: Unsupervised learning and data visualization

### 🧬 Genetic Algorithms  
- **Optimization**: Solve complex problems like Traveling Salesman
- **Evolution Operators**: Selection, crossover, and mutation
- **Parameter Exploration**: See how population size affects results

### 🎯 Machine Learning Classifiers
- **Decision Trees**: ID3 algorithm with interpretable rules
- **Naive Bayes**: Probabilistic classification
- **k-Nearest Neighbors**: Instance-based learning
- **Rule-based Learning**: OneR and PRISM algorithms
- **Ensemble Methods**: Combining multiple classifiers

### 📊 Data Clustering
- **K-means**: Partitional clustering with centroid visualization
- **Hierarchical Clustering**: Single, complete, average, and Ward linkage
- **Divisive Clustering**: DIANA algorithm for top-down clustering
- **Cluster Evaluation**: Methods to assess clustering quality

### 📈 Data Handling
- **Preprocessing**: Cleaning, normalization, and feature engineering
- **Statistics**: Descriptive statistics and data analysis
- **Distance Metrics**: Euclidean, Manhattan, and similarity measures
- **Cross-Validation**: Proper experimental design

## 📖 Learning Resources

### 📚 [Complete Tutorials](tutorials/)
- [**Data Handling Tutorial**](tutorials/data-handling.md) - Start here for ML fundamentals
- [**Neural Networks Tutorial**](tutorials/neural-networks.md) - Brain-inspired learning
- [**Genetic Algorithms Tutorial**](tutorials/genetic-algorithms.md) - Evolutionary computation
- [**Classification Tutorial**](tutorials/classification-tutorial.md) - Decision-making algorithms
- [**Clustering Tutorial**](tutorials/clustering-tutorial.md) - Pattern discovery

### 💻 [Practical Examples](examples/)
Ready-to-run code demonstrating each algorithm:
- XOR neural network training
- Traveling salesman optimization
- Decision tree classification
- Customer segmentation clustering
- Pattern recognition with SOMs

### 📋 [Reference Guides](guides/)
- [**Genetic Algorithms Guide**](guides/genetic-algorithms.md)
- [**Neural Networks Guide**](guides/neural-networks.md)  
- [**Machine Learning Guide**](guides/machine-learning.md)

### 🔧 [API Documentation](reference/api.md)
Complete method reference for all classes and modules.

## 🎯 Educational Use Cases

### Computer Science Courses
- **AI Fundamentals**: Introduce core concepts with working examples
- **Machine Learning**: Hands-on experience with real algorithms
- **Data Science**: Complete data processing pipeline
- **Optimization**: Genetic algorithms for complex problems

### Self-Study
- **Structured Learning**: Follow tutorials in recommended order
- **Experimentation**: Modify examples to test understanding
- **Project-Based**: Build on examples for personal projects
- **Comprehensive**: One framework covering multiple AI domains

### Research and Development
- **Algorithm Prototyping**: Rapid implementation of new ideas
- **Comparative Studies**: Evaluate different approaches
- **Educational Research**: Study how students learn AI concepts
- **Open Source**: Contribute improvements and new algorithms

## 🌟 Why Choose AI4R for Education?

### ✅ Educational Focus
- Clear, readable code prioritized over performance
- Extensive documentation and examples
- Step-by-step explanations of complex algorithms
- Focus on understanding concepts, not just using tools

### ✅ Comprehensive Coverage
- Neural networks, genetic algorithms, classification, clustering
- Data preprocessing and statistical analysis
- Evaluation methods and experimental design
- Real-world problem examples

### ✅ Hands-On Learning
- Runnable examples for every algorithm
- Parameter exploration and visualization
- Safe environment for experimentation
- Immediate feedback on changes

### ✅ Classroom Ready
- Examples designed for live demonstration
- Assignments and exercises included
- Progressive difficulty levels
- Supports both individual and group learning

## 🚀 Getting Started

### Choose Your Path
1. **New to AI?** Start with [Data Handling Tutorial](tutorials/data-handling.md)
2. **Want Neural Networks?** Go to [Neural Networks Tutorial](tutorials/neural-networks.md)
3. **Interested in Optimization?** Try [Genetic Algorithms Tutorial](tutorials/genetic-algorithms.md)
4. **Need Classification?** Begin with [Classification Tutorial](tutorials/classification-tutorial.md)

### Quick Test
```ruby
require 'ai4r'

# Test installation
puts "AI4R loaded successfully!"

# Quick classification example
data = [
  ['sunny', 'hot', 'high', 'weak', 'no'],
  ['sunny', 'hot', 'high', 'strong', 'no'],
  ['overcast', 'hot', 'high', 'weak', 'yes'],
  ['rainy', 'mild', 'high', 'weak', 'yes']
]

dataset = Ai4r::Data::DataSet.new(
  data_items: data,
  data_labels: ['outlook', 'temp', 'humidity', 'wind', 'play']
)

classifier = Ai4r::Classifiers::ID3.new
classifier.build(dataset)

prediction = classifier.eval(['sunny', 'mild', 'normal', 'strong'])
puts "Prediction: #{prediction}"
```

## 📧 Contact and Community

**Educational Support**: For questions about using AI4R in courses or educational settings, please reach out to the maintainers.

**Original Creator**: [Sergio Fierens](https://github.com/SergioFierens) - sergio.fierens@gmail.com

**Contributing**: We welcome contributions that improve the educational value of AI4R. See our [contribution guidelines](../CONTRIBUTING.md) for details.

## 📄 License

AI4R is provided under the Mozilla Public License 1.1 (MPL 1.1), making it free for educational use, modification, and distribution.

---

**Ready to start your AI journey?** 🎓

Begin with our [Getting Started Guide](tutorials/) or jump into any [tutorial](tutorials/) that interests you!