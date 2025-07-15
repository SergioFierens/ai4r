# Neural Networks Tutorial

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Basic Neural Network Concepts](#basic-neural-network-concepts)
4. [Educational Framework Overview](#educational-framework-overview)
5. [Hands-On Examples](#hands-on-examples)
6. [Advanced Topics](#advanced-topics)
7. [Self-Organizing Maps](#self-organizing-maps)
8. [Best Practices](#best-practices)
9. [Further Reading](#further-reading)

## Introduction

Welcome to the AI4R Neural Networks Tutorial! This comprehensive guide will take you through the fundamentals of artificial neural networks using the AI4R library's educational framework. Whether you're a student learning about neural networks for the first time or a teacher looking for educational resources, this tutorial provides hands-on examples and detailed explanations.

### What You'll Learn

- Fundamental concepts of neural networks
- How to build and train different types of neural networks
- Understanding activation functions and their effects
- Learning algorithms and optimization techniques
- Practical applications through real examples
- Self-organizing maps and unsupervised learning

## Getting Started

### Installation

First, ensure you have the AI4R library installed:

```ruby
require 'ai4r'
```

### Quick Test

Let's verify everything is working with a simple example:

```ruby
# Load the educational framework
require 'ai4r'

# Quick neural network demo
network = Ai4r::NeuralNetwork::EducationalExamples.xor_problem(verbose: false)
puts "Neural network created successfully!"
```

## Basic Neural Network Concepts

### What is a Neural Network?

A neural network is a computational model inspired by biological neural networks. It consists of interconnected nodes (neurons) that process information by applying mathematical functions to inputs and passing the results through connections with weights.

Key components:
- **Neurons**: Processing units that apply activation functions
- **Weights**: Strength of connections between neurons
- **Layers**: Groups of neurons (input, hidden, output)
- **Activation Functions**: Functions that determine neuron output
- **Training**: Process of adjusting weights to learn patterns

### Types of Neural Networks

1. **Feedforward Networks**: Information flows in one direction
2. **Recurrent Networks**: Can have feedback loops
3. **Convolutional Networks**: Specialized for image processing
4. **Self-Organizing Maps**: Unsupervised learning networks

## Educational Framework Overview

The AI4R educational framework provides several tools for learning:

### EducationalNeuralNetwork Class

The main class for creating and training neural networks with educational features:

```ruby
# Create a network with educational features
network = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(
  :backpropagation,  # Network type
  [2, 3, 1],         # Structure: 2 inputs, 3 hidden, 1 output
  {
    learning_rate: 0.3,
    momentum: 0.1,
    verbose: true
  }
)

# Enable step-by-step mode for detailed learning
network.enable_step_mode
network.enable_visualization
```

### Key Features

- **Step-by-step training**: See each epoch's progress
- **Visualization**: ASCII charts and network diagrams
- **Parameter explanations**: Understand what each setting does
- **Performance monitoring**: Track learning progress
- **Export capabilities**: Save networks and training data

## Hands-On Examples

### Example 1: XOR Problem (Classic Example)

The XOR problem demonstrates why neural networks need hidden layers:

```ruby
# Run the XOR example
network = Ai4r::NeuralNetwork::EducationalExamples.xor_problem(
  verbose: true,
  step_mode: false
)

# Test the trained network
test_cases = [[0, 0], [0, 1], [1, 0], [1, 1]]
test_cases.each do |input|
  output = network.eval(input)
  puts "#{input.inspect} XOR = #{output.first.round(3)}"
end
```

**What you'll learn:**
- Why linear models can't solve XOR
- How hidden layers enable non-linear learning
- Training process visualization
- Network architecture effects

### Example 2: Digit Recognition

Learn pattern recognition with simple 3x3 digit patterns:

```ruby
# Train a digit recognition network
network = Ai4r::NeuralNetwork::EducationalExamples.digit_recognition(
  verbose: true,
  step_mode: false
)

# The network learns to recognize patterns for digits 0, 1, and 2
# Even with noise in the input patterns
```

**What you'll learn:**
- Pattern classification
- Handling noisy inputs
- One-hot encoding for multiple classes
- Network confidence interpretation

### Example 3: Function Approximation

Learn how neural networks can approximate mathematical functions:

```ruby
# Approximate a sine function
network = Ai4r::NeuralNetwork::EducationalExamples.function_approximation(
  verbose: true,
  step_mode: false
)

# The network learns f(x) = sin(x) + 0.5*cos(2x)
```

**What you'll learn:**
- Regression vs classification
- Data normalization importance
- Function approximation capabilities
- Activation function choices

### Example 4: Hopfield Associative Memory

Explore a different type of neural network for pattern completion:

```ruby
# Create an associative memory
network = Ai4r::NeuralNetwork::EducationalExamples.hopfield_memory(
  verbose: true,
  step_mode: false
)

# Stores patterns and can recall them from partial/noisy inputs
```

**What you'll learn:**
- Recurrent neural networks
- Associative memory concepts
- Pattern completion
- Energy minimization

### Running All Examples

To see all examples in sequence:

```ruby
# Run complete tutorial
Ai4r::NeuralNetwork::NeuralNetworkTutorial.run_all_examples

# Or with step-by-step mode for detailed learning
Ai4r::NeuralNetwork::NeuralNetworkTutorial.run_all_examples(step_mode: true)
```

## Advanced Topics

### Activation Functions

Understanding different activation functions and their properties:

```ruby
# Explore activation functions
Ai4r::NeuralNetwork::ActivationFunctions::ActivationFactory.compare_functions

# Plot a specific function
Ai4r::NeuralNetwork::ActivationFunctions::ActivationAnalyzer.plot_function(:relu)

# Analyze gradients
Ai4r::NeuralNetwork::ActivationFunctions::ActivationAnalyzer.analyze_gradients(:sigmoid)
```

**Available activation functions:**
- **Sigmoid**: Classic S-shaped, outputs 0-1
- **Tanh**: Zero-centered, outputs -1 to 1
- **ReLU**: Fast, modern default choice
- **Leaky ReLU**: Fixes "dying ReLU" problem
- **ELU**: Smooth alternative to ReLU
- **Swish**: Self-gated function
- **Linear**: For regression outputs

### Learning Algorithms

Explore different optimization algorithms:

```ruby
# Compare learning algorithms
Ai4r::NeuralNetwork::LearningAlgorithms::LearningAlgorithmFactory.compare_algorithms

# Demonstrate convergence
Ai4r::NeuralNetwork::LearningAlgorithms::LearningAnalyzer.demonstrate_convergence(:adam)

# Compare on a problem
Ai4r::NeuralNetwork::LearningAlgorithms::LearningAnalyzer.compare_on_problem(:quadratic)
```

**Available optimizers:**
- **SGD**: Stochastic Gradient Descent
- **Momentum**: Accelerated gradient descent
- **AdaGrad**: Adaptive learning rates
- **RMSprop**: Improved AdaGrad
- **Adam**: Combines momentum and adaptive rates
- **AdamW**: Adam with weight decay

### Custom Networks

Create your own networks with specific configurations:

```ruby
# Create a custom network for binary classification
network = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(
  :backpropagation,
  [4, 8, 4, 2],  # 4 inputs, two hidden layers, 2 outputs
  {
    learning_rate: 0.001,
    momentum: 0.9,
    activation_function: :relu,
    verbose: true
  }
)

# Configure for your specific problem
network.configure({
  learning_rate: 0.01,
  convergence_threshold: 0.001
})

# Train with your data
training_data = [
  # [input, expected_output],
  [[1, 0, 1, 0], [1, 0]],
  [[0, 1, 0, 1], [0, 1]],
  # ... more training examples
]

network.train(training_data, 1000)
```

## Self-Organizing Maps

Self-Organizing Maps (SOMs) are unsupervised learning networks that create topological representations of input data.

### Basic SOM Usage

```ruby
# Create an educational SOM
som = Ai4r::Som::EducationalSom.new(
  2,      # Input dimension
  5,      # Map size (5x5 grid)
  {
    epochs: 100,
    initial_learning_rate: 0.1,
    initial_radius: 2.0,
    verbose: true
  }
)

# Generate sample 2D data
training_data = []
50.times do
  training_data << [rand * 10, rand * 10]
end

# Train the SOM
som.enable_step_mode
som.enable_visualization
som.train(training_data)

# Analyze the results
som.visualize
som.calculate_map_quality
som.analyze_topology
```

### SOM Features

- **Step-by-step training**: Watch the map organize
- **Quality metrics**: Quantization and topographic error
- **Topology analysis**: Understand map organization
- **Visualization**: See weight distributions and training progress
- **Export capabilities**: Save maps and analysis

### Advanced SOM Example

```ruby
# Create SOM with advanced configuration
som = Ai4r::Som::EducationalSom.new(3, 8, {
  epochs: 200,
  initial_learning_rate: 0.1,
  initial_radius: 3.0,
  layer_type: :two_phase,
  neighborhood_function: :gaussian,
  verbose: true
})

# Configure parameters with explanations
som.configure({
  epochs: 300,
  initial_learning_rate: 0.05
})

# Train and analyze
som.train(your_data)
quality_metrics = som.calculate_map_quality
topology_analysis = som.analyze_topology

# Export results
som.export_som("my_som_results.json")
```

## Best Practices

### 1. Data Preparation

```ruby
# Always normalize your data
def normalize_data(data)
  # Min-max normalization
  min_vals = data.transpose.map(&:min)
  max_vals = data.transpose.map(&:max)
  
  data.map do |example|
    example.each_with_index.map do |value, i|
      range = max_vals[i] - min_vals[i]
      range > 0 ? (value - min_vals[i]) / range : 0.5
    end
  end
end
```

### 2. Network Architecture

- Start simple (fewer layers and neurons)
- Add complexity gradually if needed
- Use ReLU for hidden layers in most cases
- Use appropriate output activation (sigmoid for binary, softmax for multi-class, linear for regression)

### 3. Training Process

```ruby
# Monitor training progress
network.configure({ verbose: true })

# Use validation data to check for overfitting
# Split your data into training and validation sets

# Early stopping if validation error increases
```

### 4. Hyperparameter Tuning

```ruby
# Start with common values
config = {
  learning_rate: 0.001,  # Try 0.1, 0.01, 0.001
  momentum: 0.9,
  activation_function: :relu
}

# Use grid search or random search for optimization
learning_rates = [0.1, 0.01, 0.001]
momentum_values = [0.5, 0.9, 0.95]

# Test combinations and choose best performing
```

### 5. Debugging Networks

```ruby
# Use step mode to understand training
network.enable_step_mode

# Visualize to see what's happening
network.enable_visualization

# Analyze weights and activations
network.analyze_weights

# Check gradient flow
Ai4r::NeuralNetwork::ActivationFunctions::ActivationAnalyzer.analyze_gradients(:your_function)
```

## Troubleshooting Common Issues

### Problem: Network Not Learning

**Symptoms**: Loss stays high, no improvement
**Solutions**:
- Check learning rate (try 0.1, 0.01, 0.001)
- Verify data normalization
- Ensure sufficient network capacity
- Check for data quality issues

```ruby
# Debug with verbose mode
network.configure({ verbose: true, explain_predictions: true })
```

### Problem: Overfitting

**Symptoms**: Training accuracy high, validation low
**Solutions**:
- Reduce network complexity
- Add regularization
- Get more training data
- Use early stopping

### Problem: Vanishing Gradients

**Symptoms**: Deep network trains slowly
**Solutions**:
- Use ReLU instead of sigmoid/tanh
- Reduce network depth
- Use modern optimizers (Adam)

```ruby
# Switch to ReLU
network.configure({ activation_function: :relu })
```

### Problem: Exploding Gradients

**Symptoms**: Loss becomes NaN or very large
**Solutions**:
- Reduce learning rate
- Use gradient clipping
- Check weight initialization

## Performance Tips

### 1. Choose Appropriate Algorithms

```ruby
# For different problem types
Ai4r::NeuralNetwork::ActivationFunctions::ActivationFactory.recommend_function(:binary_classification)
Ai4r::NeuralNetwork::LearningAlgorithms::LearningAlgorithmFactory.recommend_algorithm({
  fast_convergence: true,
  deep_network: true
})
```

### 2. Monitor Training

```ruby
# Use built-in monitoring
network.enable_visualization

# Export training history for analysis
network.export_network("training_history.json")
```

### 3. Batch Your Data

For large datasets, process in batches rather than individual examples.

## Educational Exercises

### Exercise 1: Experiment with Activation Functions

```ruby
# Try different activation functions on the same problem
activations = [:sigmoid, :tanh, :relu, :leaky_relu]

activations.each do |activation|
  puts "Testing #{activation}:"
  network = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(
    :backpropagation, [2, 4, 1], { activation_function: activation }
  )
  # Train on your data and compare results
end
```

### Exercise 2: Architecture Comparison

```ruby
# Compare different network architectures
architectures = [
  [2, 1],      # No hidden layer
  [2, 3, 1],   # One hidden layer
  [2, 5, 3, 1], # Two hidden layers
  [2, 10, 1]   # Wider hidden layer
]

architectures.each do |arch|
  puts "Testing architecture #{arch.inspect}:"
  # Train and compare performance
end
```

### Exercise 3: Learning Rate Impact

```ruby
# See how learning rate affects training
learning_rates = [0.001, 0.01, 0.1, 1.0]

learning_rates.each do |lr|
  puts "Learning rate: #{lr}"
  network = Ai4r::NeuralNetwork::EducationalNeuralNetwork.new(
    :backpropagation, [2, 3, 1], { learning_rate: lr, verbose: true }
  )
  # Train and observe convergence speed
end
```

## Further Reading

### Books
- "Neural Networks for Pattern Recognition" by Christopher Bishop
- "Deep Learning" by Ian Goodfellow, Yoshua Bengio, and Aaron Courville
- "Pattern Recognition and Machine Learning" by Christopher Bishop

### Online Resources
- [Neural Networks and Deep Learning](http://neuralnetworksanddeeplearning.com/)
- [Deep Learning Specialization (Coursera)](https://www.coursera.org/specializations/deep-learning)
- [CS231n: Convolutional Neural Networks for Visual Recognition](http://cs231n.stanford.edu/)

### Papers
- "Learning representations by back-propagating errors" (Rumelhart, Hinton, Williams, 1986)
- "Deep Learning" (LeCun, Bengio, Hinton, 2015)
- "Gradient-based learning applied to document recognition" (LeCun et al., 1998)

### Advanced Topics to Explore
- Convolutional Neural Networks (CNNs)
- Recurrent Neural Networks (RNNs) and LSTMs
- Generative Adversarial Networks (GANs)
- Transformer architectures
- Reinforcement Learning with neural networks

## Conclusion

This tutorial has introduced you to neural networks using the AI4R educational framework. You've learned:

- Fundamental neural network concepts
- How to create, train, and evaluate networks
- Different activation functions and learning algorithms
- Self-organizing maps for unsupervised learning
- Best practices and troubleshooting techniques

The AI4R educational framework provides a solid foundation for understanding neural networks. Use the interactive examples, experiment with different configurations, and observe how changes affect network behavior.

Remember: the best way to learn neural networks is through hands-on experimentation. Start with simple problems, understand the basics thoroughly, then gradually tackle more complex challenges.

Happy learning!

---

*For questions, issues, or contributions to this tutorial, please visit the [AI4R GitHub repository](https://github.com/SergioFierens/ai4r).*