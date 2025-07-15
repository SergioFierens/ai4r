# Self-Organizing Maps (SOM)

## Overview

The AI4R Self-Organizing Maps group provides implementations of unsupervised neural networks that create topology-preserving mappings from high-dimensional input spaces to low-dimensional output spaces. These algorithms demonstrate competitive learning and self-organization principles.

## Educational Purpose

Self-Organizing Maps demonstrate key concepts in unsupervised learning:
- **Competitive Learning**: Winner-take-all mechanisms in neural networks
- **Topology Preservation**: Maintaining spatial relationships during mapping
- **Dimensionality Reduction**: Reducing data dimensions while preserving structure
- **Self-Organization**: Emergent structure formation without supervision

## Available Algorithms

### Core SOM Implementation

#### Self-Organizing Map
- **File**: `lib/ai4r/som/som.rb`
- **Description**: Classic Kohonen self-organizing map implementation
- **Use Cases**: Data visualization, clustering, dimensionality reduction
- **Educational Value**: Demonstrates competitive learning and neighborhood functions

**Key Features:**
- Configurable grid topology (rectangular, hexagonal)
- Multiple distance metrics (Euclidean, Manhattan)
- Adaptive learning rate and neighborhood radius
- Winner neuron selection and update

#### Two-Phase SOM
- **File**: `lib/ai4r/som/two_phase_layer.rb`
- **Description**: Enhanced SOM with two-phase learning process
- **Use Cases**: Improved convergence, better topology preservation
- **Educational Value**: Shows advanced SOM architectures

**Key Features:**
- Ordering phase: Rapid initial topology formation
- Tuning phase: Fine-tuning of final map
- Separate parameters for each phase
- Improved convergence guarantees

### Supporting Components

#### SOM Layer
- **File**: `lib/ai4r/som/layer.rb`
- **Description**: Neural layer implementation for SOM networks
- **Use Cases**: Building custom SOM architectures
- **Educational Value**: Understanding SOM internal structure

#### SOM Node
- **File**: `lib/ai4r/som/node.rb`
- **Description**: Individual neuron implementation
- **Use Cases**: Custom node behaviors, extended functionality
- **Educational Value**: Shows neuron-level operations

### Educational Framework

#### Educational SOM
- **File**: `lib/ai4r/som/educational_som.rb`
- **Description**: Interactive SOM with visualization and step-by-step learning
- **Use Cases**: Teaching and learning SOM concepts
- **Educational Value**: Complete transparency of learning process

**Educational Features:**
- Step-by-step weight updates
- Neighborhood visualization
- Learning curve tracking
- Interactive parameter adjustment

## Key Concepts Demonstrated

### Competitive Learning
- **Winner-Take-All**: Only one neuron wins per input
- **Lateral Inhibition**: Suppressing nearby neurons
- **Adaptation**: Weight updates based on competition
- **Convergence**: Stabilization of competitive process

### Topology Preservation
- **Neighborhood Functions**: Gaussian, Mexican hat, bubble
- **Distance Metrics**: Euclidean, Manhattan, grid distance
- **Shrinking Neighborhoods**: Decreasing influence over time
- **Mapping Quality**: Measuring topology preservation

### Self-Organization
- **Emergent Structure**: Patterns arising from local interactions
- **Ordering Phase**: Initial rough organization
- **Tuning Phase**: Fine-scale adjustments
- **Stability**: Maintaining learned organization

## Common Usage Patterns

### Basic SOM Training
```ruby
# Create SOM with 10x10 grid
som = Ai4r::Som::Som.new(10, 10)

# Training data (3-dimensional)
training_data = [
  [0.1, 0.2, 0.3],
  [0.4, 0.5, 0.6],
  [0.7, 0.8, 0.9],
  [0.2, 0.3, 0.1],
  [0.5, 0.6, 0.4]
]

# Configure learning parameters
som.learning_rate = 0.1
som.neighborhood_radius = 3.0
som.max_iterations = 1000

# Train the SOM
som.train(training_data)

# Find best matching unit for input
winner = som.winner([0.3, 0.4, 0.5])
puts "Winner coordinates: #{winner}"
```

### Interactive SOM Learning
```ruby
# Create educational SOM
edu_som = Ai4r::Som::EducationalSom.new(
  width: 8,
  height: 8,
  input_dimension: 2,
  visualization: true
)

# Configure learning parameters
edu_som.configure_learning(
  initial_learning_rate: 0.5,
  initial_neighborhood_radius: 4.0,
  max_iterations: 500
)

# Train with visualization
edu_som.train_with_visualization(training_data) do |iteration, som|
  puts "Iteration #{iteration}: Learning rate = #{som.learning_rate}"
  puts "Neighborhood radius = #{som.neighborhood_radius}"
end
```

### Two-Phase SOM
```ruby
# Create two-phase SOM
two_phase_som = Ai4r::Som::TwoPhaseLayer.new(
  width: 12,
  height: 12,
  input_dimension: 3
)

# Configure phases
two_phase_som.configure_ordering_phase(
  iterations: 500,
  learning_rate: 0.9,
  neighborhood_radius: 6.0
)

two_phase_som.configure_tuning_phase(
  iterations: 1000,
  learning_rate: 0.1,
  neighborhood_radius: 1.0
)

# Train with two phases
two_phase_som.train(training_data)

# Analyze results
puts "Ordering phase complete"
puts "Tuning phase complete"
puts "Final quantization error: #{two_phase_som.quantization_error}"
```

### SOM Analysis and Visualization
```ruby
# Create SOM for analysis
som = Ai4r::Som::Som.new(15, 15)
som.train(training_data)

# Calculate quality metrics
quantization_error = som.quantization_error(training_data)
topographic_error = som.topographic_error(training_data)

puts "Quantization error: #{quantization_error}"
puts "Topographic error: #{topographic_error}"

# Visualize weight vectors
som.visualize_weights do |x, y, weights|
  puts "Node (#{x}, #{y}): #{weights.inspect}"
end

# Create U-matrix for visualization
u_matrix = som.u_matrix
puts "U-matrix: #{u_matrix.inspect}"
```

## Integration with Other Components

### Data Preprocessing
- Works with `Ai4r::Data::DataSet` for structured input
- Supports feature scaling and normalization
- Handles missing values through imputation
- Integrates with dimensionality reduction

### Clustering
- Can be used as preprocessing for clustering algorithms
- Provides cluster prototypes through neuron weights
- Supports hierarchical clustering of map units
- Enables cluster visualization

### Visualization
- Supports 2D map visualization
- U-matrix representation for cluster boundaries
- Component planes for individual features
- Hit histograms for data distribution

## Educational Progression

### Beginner Level
1. **Basic SOM**: Understanding competitive learning
2. **Neighborhood Functions**: Learning spatial relationships
3. **Parameter Effects**: Exploring learning rate and radius impact

### Intermediate Level
1. **Topology Preservation**: Understanding mapping quality
2. **Different Topologies**: Rectangular vs. hexagonal grids
3. **Quality Metrics**: Quantization and topographic errors

### Advanced Level
1. **Advanced Architectures**: Two-phase and hierarchical SOMs
2. **Custom Implementations**: Building specialized SOM variants
3. **Applications**: Real-world SOM applications

## Performance Considerations

### Time Complexity
- **Training**: O(n × m × k × i) where n=data points, m=map size, k=dimensions, i=iterations
- **Winner Finding**: O(m × k) for each input
- **Neighborhood Updates**: O(r²) where r=neighborhood radius

### Space Complexity
- **Weight Storage**: O(m × k) for neuron weights
- **Neighborhood Cache**: O(m × r²) for distance calculations
- **Training Data**: O(n × k) for input vectors

### Optimization Strategies
- **Batch Training**: Update weights after processing all inputs
- **Adaptive Parameters**: Decrease learning rate and radius over time
- **Early Stopping**: Monitor convergence criteria
- **Parallel Processing**: Distribute neighborhood calculations

## Best Practices

### Parameter Selection
- **Map Size**: Balance between resolution and computational cost
- **Learning Rate**: Start high (0.9) and decrease to low (0.01)
- **Neighborhood Radius**: Start large (half map size) and shrink
- **Iterations**: Sufficient for convergence (typically 500-5000)

### Training Strategies
- **Data Normalization**: Scale features to similar ranges
- **Random Initialization**: Initialize weights randomly
- **Decreasing Schedule**: Reduce parameters over time
- **Monitoring**: Track quantization error for convergence

### Quality Assessment
- **Quantization Error**: Measure average distance to winners
- **Topographic Error**: Measure topology preservation
- **Visual Inspection**: Check for smooth weight transitions
- **Cluster Validation**: Verify meaningful cluster formation

### Common Pitfalls
- **Poor Initialization**: Random weights should span input space
- **Inappropriate Parameters**: Too fast learning or small neighborhood
- **Insufficient Training**: Not enough iterations for convergence
- **Data Scaling**: Unscaled features can dominate learning

## Advanced Topics

### SOM Variants
- **Hierarchical SOM**: Multi-level organization
- **Growing SOM**: Dynamic map size adjustment
- **Temporal SOM**: Handling sequential data
- **Supervised SOM**: Incorporating labeled data

### Specialized Applications
- **Image Processing**: Feature map extraction
- **Time Series**: Temporal pattern analysis
- **Text Mining**: Document organization
- **Gene Expression**: Biological data analysis

### Visualization Techniques
- **U-Matrix**: Unified distance matrix for boundaries
- **Component Planes**: Individual feature visualization
- **Hit Histograms**: Data distribution on map
- **Trajectory Tracking**: Following data evolution

### Quality Measures
- **Quantization Error**: Average distance to best matching units
- **Topographic Error**: Proportion of non-adjacent winners
- **Trustworthiness**: Preservation of local neighborhoods
- **Continuity**: Smoothness of the mapping

## Real-World Applications

### Data Mining
- **Customer Segmentation**: Grouping customers by behavior
- **Market Research**: Analyzing consumer preferences
- **Anomaly Detection**: Identifying unusual patterns
- **Data Exploration**: Visualizing high-dimensional data

### Signal Processing
- **Speech Recognition**: Phoneme classification
- **Image Classification**: Visual pattern recognition
- **Sensor Networks**: Data fusion and analysis
- **Quality Control**: Defect detection

### Bioinformatics
- **Gene Expression**: Clustering gene profiles
- **Protein Analysis**: Sequence pattern recognition
- **Drug Discovery**: Molecular similarity analysis
- **Evolutionary Studies**: Phylogenetic analysis

This Self-Organizing Maps framework provides a comprehensive foundation for understanding competitive learning and self-organization through hands-on implementation of topology-preserving neural networks.