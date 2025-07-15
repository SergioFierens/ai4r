# Neural Network Algorithms

## Overview

The AI4R neural network algorithms group provides a comprehensive collection of artificial neural network implementations designed to demonstrate the fundamental principles of computational neuroscience and deep learning. These algorithms showcase how simple processing units can combine to solve complex pattern recognition and learning tasks.

## Educational Purpose

Neural network algorithms demonstrate key concepts in artificial intelligence:
- **Distributed Processing**: How simple units combine to create complex behavior
- **Learning Rules**: Different approaches to weight adjustment and optimization
- **Non-linear Modeling**: Representing complex relationships in data
- **Biological Inspiration**: Understanding brain-inspired computation

## Available Algorithms

### Feed-Forward Networks

#### Backpropagation Neural Network
- **File**: `lib/ai4r/neural_network/backpropagation.rb`
- **Description**: Multi-layer perceptron with error backpropagation learning
- **Use Cases**: Pattern recognition, function approximation, classification
- **Educational Value**: Demonstrates gradient descent and chain rule application

#### Multilayer Perceptron (Enhanced)
- **File**: `lib/ai4r/neural_network/enhanced_neural_network.rb`
- **Description**: Advanced feed-forward network with modern optimizations
- **Use Cases**: Complex pattern recognition, deep learning foundations
- **Educational Value**: Shows modern neural network techniques

### Associative Memory Networks

#### Hopfield Network
- **File**: `lib/ai4r/neural_network/hopfield.rb`
- **Description**: Recurrent neural network for associative memory
- **Use Cases**: Pattern completion, memory retrieval, optimization
- **Educational Value**: Demonstrates energy-based learning and recurrent dynamics

### Self-Organizing Networks

#### Self-Organizing Map (SOM)
- **File**: `lib/ai4r/som/som.rb`
- **Description**: Unsupervised learning network for dimensionality reduction
- **Use Cases**: Data visualization, clustering, feature mapping
- **Educational Value**: Shows competitive learning and topological preservation

#### Two-Phase SOM
- **File**: `lib/ai4r/som/two_phase_layer.rb`
- **Description**: Enhanced SOM with two-phase learning
- **Use Cases**: Improved convergence, better neighborhood preservation
- **Educational Value**: Demonstrates advanced SOM architectures

### Modern Architectures

#### Transformer Neural Network
- **File**: `lib/ai4r/neural_network/transformer.rb`
- **Description**: State-of-the-art architecture with self-attention mechanisms
- **Use Cases**: Natural language processing, sequence modeling
- **Educational Value**: Demonstrates attention mechanisms and modern deep learning

## Key Components

### Activation Functions
- **Sigmoid**: Smooth, bounded activation for binary classification
- **Tanh**: Symmetric activation with zero-centered output
- **ReLU**: Rectified linear activation for deep networks
- **Softmax**: Probability distribution for multi-class classification
- **File**: `lib/ai4r/neural_network/activation_functions.rb`

### Learning Algorithms
- **Gradient Descent**: Basic optimization algorithm
- **Stochastic Gradient Descent**: Online learning variant
- **Momentum**: Accelerated gradient descent
- **Adaptive Learning Rates**: Self-adjusting optimization
- **File**: `lib/ai4r/neural_network/learning_algorithms.rb`

### Optimization Techniques
- **Adam**: Adaptive moment estimation
- **RMSprop**: Root mean square propagation
- **Adagrad**: Adaptive gradient algorithm
- **Learning Rate Scheduling**: Dynamic rate adjustment
- **File**: `lib/ai4r/neural_network/optimizers.rb`

### Regularization Methods
- **Dropout**: Random neuron deactivation
- **Weight Decay**: L2 regularization
- **Early Stopping**: Preventing overfitting
- **Batch Normalization**: Normalizing layer inputs
- **File**: `lib/ai4r/neural_network/regularization.rb`

## Educational Features

### Interactive Learning
- **Step-by-step Training**: Visualize weight updates
- **Network Visualization**: See network structure and activations
- **Learning Curves**: Monitor training progress
- **File**: `lib/ai4r/neural_network/educational_neural_network.rb`

### Practical Examples
- **XOR Problem**: Classic non-linear separation example
- **Pattern Recognition**: Image and signal processing
- **Function Approximation**: Continuous mapping examples
- **File**: `lib/ai4r/neural_network/educational_examples.rb`

## Common Usage Patterns

### Basic Neural Network
```ruby
# Create network architecture
network = Ai4r::NeuralNetwork::Backpropagation.new([2, 3, 1])

# Training data (XOR problem)
training_data = [
  [[0, 0], [0]],
  [[0, 1], [1]],
  [[1, 0], [1]],
  [[1, 1], [0]]
]

# Train network
training_data.each do |input, target|
  network.train(input, target)
end

# Test network
result = network.eval([1, 0])
puts "XOR(1,0) = #{result}"
```

### Self-Organizing Map
```ruby
# Create SOM
som = Ai4r::Som::Som.new(10, 10)  # 10x10 grid

# Training data
data = [
  [0.1, 0.2, 0.3],
  [0.4, 0.5, 0.6],
  [0.7, 0.8, 0.9]
]

# Train SOM
som.train(data)

# Find best matching unit
winner = som.winner([0.2, 0.3, 0.4])
puts "Best matching unit: #{winner}"
```

### Hopfield Network
```ruby
# Create Hopfield network
network = Ai4r::NeuralNetwork::Hopfield.new(9)

# Store patterns
patterns = [
  [1, -1, 1, -1, 1, -1, 1, -1, 1],
  [-1, 1, -1, 1, -1, 1, -1, 1, -1]
]

patterns.each { |pattern| network.train(pattern) }

# Retrieve pattern
noisy_pattern = [1, -1, 1, -1, 1, -1, 1, 1, 1]
result = network.eval(noisy_pattern)
puts "Recovered pattern: #{result}"
```

### Transformer Architecture
```ruby
# Create transformer (encoder-only mode)
transformer = Ai4r::NeuralNetwork::Transformer.new(
  mode: :encoder_only,
  vocab_size: 1000,
  d_model: 128,
  n_heads: 8,
  n_layers: 6
)

# Process input sequence
input_ids = [1, 2, 3, 4, 5]
encoded = transformer.forward(input_ids)
puts "Encoded representation: #{encoded.length} vectors"
```

## Integration with Other Components

### Data Preprocessing
- Works with `Ai4r::Data::DataSet` for structured data
- Supports feature scaling and normalization
- Handles categorical encoding and missing values

### Visualization
- Network architecture diagrams
- Weight matrix visualizations
- Learning curve plots
- Activation pattern displays

### Evaluation
- Performance metrics for different tasks
- Cross-validation support
- Overfitting detection
- Convergence analysis

## Educational Progression

### Beginner Level
1. **Perceptron**: Linear classification with single layer
2. **Multi-layer Perceptron**: Non-linear classification
3. **Backpropagation**: Understanding gradient-based learning

### Intermediate Level
1. **Hopfield Networks**: Associative memory and energy functions
2. **Self-Organizing Maps**: Unsupervised learning and topology
3. **Activation Functions**: Different non-linearities and their effects

### Advanced Level
1. **Deep Networks**: Many-layer architectures
2. **Regularization**: Preventing overfitting in complex models
3. **Modern Architectures**: Transformers and attention mechanisms

## Performance Considerations

### Time Complexity
- **Training**: O(n × m × e) where n=samples, m=parameters, e=epochs
- **Inference**: O(m) for forward pass
- **Backpropagation**: O(m) for gradient computation

### Space Complexity
- **Network Storage**: O(m) for weights and biases
- **Training**: O(n × m) for batch processing
- **Gradients**: O(m) for optimization state

### Scalability
- **Large Networks**: Use mini-batch training
- **Memory Constraints**: Implement gradient checkpointing
- **Distributed Training**: Parallel processing across devices

## Best Practices

### Architecture Design
- **Layer Sizes**: Gradually decreasing hidden layer sizes
- **Activation Functions**: ReLU for hidden layers, appropriate output activation
- **Regularization**: Dropout for overfitting prevention
- **Initialization**: Proper weight initialization strategies

### Training Strategies
- **Learning Rate**: Start high, decay during training
- **Batch Size**: Balance between stability and efficiency
- **Epochs**: Monitor validation loss for early stopping
- **Optimization**: Use adaptive optimizers like Adam

### Debugging Neural Networks
- **Gradient Checking**: Numerical gradient verification
- **Activation Monitoring**: Check for dead neurons
- **Loss Curves**: Monitor training and validation loss
- **Weight Visualization**: Inspect learned representations

### Common Pitfalls
- **Vanishing Gradients**: Use proper initialization and activation functions
- **Exploding Gradients**: Implement gradient clipping
- **Overfitting**: Use regularization and validation monitoring
- **Poor Convergence**: Tune learning rate and architecture

## Advanced Topics

### Modern Architectures
- **Residual Networks**: Skip connections for deep networks
- **Attention Mechanisms**: Focusing on relevant information
- **Convolutional Networks**: Specialized for image processing
- **Recurrent Networks**: Handling sequential data

### Optimization Advances
- **Adaptive Learning Rates**: Self-adjusting optimization
- **Batch Normalization**: Stabilizing training
- **Learning Rate Scheduling**: Dynamic rate adjustment
- **Gradient Accumulation**: Handling large batches

### Specialized Applications
- **Computer Vision**: Image classification and object detection
- **Natural Language Processing**: Text analysis and generation
- **Reinforcement Learning**: Decision making and control
- **Generative Models**: Data generation and synthesis

This neural network framework provides a comprehensive foundation for understanding artificial intelligence through hands-on implementation of brain-inspired computational models.