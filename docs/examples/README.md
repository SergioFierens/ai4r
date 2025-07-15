# AI4R Examples

This directory contains practical examples demonstrating AI4R's capabilities. These examples are designed to be educational, showing real-world applications of the algorithms and techniques covered in the tutorials.

## 📁 Example Categories

### Classification Examples
Located in: `examples/classifiers/`

- **ID3 Decision Tree** (`id3_example.rb`)
  - Complete example with sample data
  - Demonstrates tree building and classification
  - Includes data file: `id3_data.csv`

- **Naive Bayes Classification** (`naive_bayes_example.rb`)
  - Text classification example
  - Shows probability calculations
  - Includes data file: `naive_bayes_data.csv`

- **Linear Regression** (`simple_linear_regression_example.rb`)
  - Predicting continuous values
  - Statistical analysis of results
  - Includes data file: `simple_linear_regression_example.csv`

### Neural Network Examples
Located in: `examples/neural_network/`

- **XOR Problem** (`xor_example.rb`)
  - Classic neural network demonstration
  - Shows non-linear problem solving
  - Step-by-step training visualization

- **Backpropagation Training** (`backpropagation_example.rb`)
  - Complete training cycle example
  - Parameter adjustment demonstrations
  - Performance monitoring

- **Pattern Recognition** (`patterns_with_noise.rb`)
  - Noise-resistant pattern learning
  - Real-world data challenges
  - Robustness testing

### Clustering Examples
Located in: `examples/clusterers/`

- **General Clustering** (`clusterer_example.rb`)
  - Multiple clustering algorithms
  - Comparative analysis
  - Visualization of results

### Genetic Algorithm Examples
Located in: `examples/genetic_algorithm/`

- **Traveling Salesman Problem** (`genetic_algorithm_example.rb`)
  - Classic optimization problem
  - Evolution visualization
  - Parameter tuning demonstrations
  - Includes city data: `travel_cost.csv`

### Self-Organizing Map Examples
Located in: `examples/som/`

- **Single Node Training** (`som_single_example.rb`)
  - Basic SOM concepts
  - Simple visualization
  - Training process demonstration

- **Multi-Node Network** (`som_multi_node_example.rb`)
  - Complex pattern organization
  - Topology preservation
  - Advanced visualization

### Educational Demonstrations
Located in main `examples/` directory:

- **Classification Demo** (`educational_classification_demo.rb`)
  - Interactive classifier comparison
  - Multiple datasets and algorithms
  - Performance analysis tools

- **Clustering Demo** (`educational_clustering_demo.rb`)
  - Clustering algorithm showcase
  - Parameter sensitivity analysis
  - Cluster quality evaluation

## 🚀 Running Examples

### Prerequisites
```bash
gem install ai4r
```

### Basic Usage
```bash
cd examples/classifiers
ruby id3_example.rb
```

### With Custom Data
Most examples accept command-line parameters:
```bash
ruby naive_bayes_example.rb --data my_data.csv --verbose
```

## 📚 Learning from Examples

### For Beginners
1. Start with **XOR Example** - demonstrates basic neural network concepts
2. Try **ID3 Example** - shows decision tree learning
3. Explore **Simple Clustering** - understand unsupervised learning
4. Experiment with **Genetic Algorithm** - see optimization in action

### For Intermediate Users
1. **Pattern Recognition** - handle noisy real-world data
2. **Educational Demos** - compare multiple algorithms
3. **SOM Multi-Node** - understand self-organization
4. **Parameter Tuning** - optimize algorithm performance

### For Advanced Users
- Modify examples to test new ideas
- Combine multiple techniques
- Create custom visualization tools
- Benchmark performance on large datasets

## 🔧 Example Structure

Each example follows a consistent pattern:

```ruby
# 1. Setup and requirements
require 'ai4r'

# 2. Data preparation
data = load_data_from_file_or_generate

# 3. Algorithm configuration
algorithm = Ai4r::SomeAlgorithm.new(parameters)

# 4. Training/Building
algorithm.build(data) # or train(data)

# 5. Testing/Evaluation
results = algorithm.eval(test_data)

# 6. Analysis and output
display_results(results)
analyze_performance(algorithm, results)
```

## 📊 Data Files

### Format Standards
- **CSV files**: Comma-separated with headers
- **Data encoding**: UTF-8
- **Missing values**: Represented as empty strings or 'N/A'
- **Class labels**: Always in the last column for supervised learning

### Creating Custom Data
```ruby
# For classification
data = [
  ['feature1', 'feature2', 'class'],
  [1.0, 2.0, 'A'],
  [2.0, 3.0, 'B']
]

# For clustering (no class labels)
data = [
  ['feature1', 'feature2'],
  [1.0, 2.0],
  [2.0, 3.0]
]
```

## 🎯 Educational Use

### For Classroom Teaching
- Use examples as live demonstrations
- Have students modify parameters and observe changes
- Assign examples as homework with different datasets
- Create group projects extending existing examples

### For Self-Study
- Run each example and understand the output
- Modify parameters to see their effects
- Try examples with your own data
- Combine techniques from different examples

### For Research
- Use examples as starting points for new algorithms
- Benchmark new methods against these implementations
- Validate theoretical work with practical examples
- Create reproducible experimental setups

## 🔍 Understanding Output

### Common Output Patterns

**Classification Results:**
```
Accuracy: 85.2%
Confusion Matrix:
     A    B    C
A   12    2    1
B    1   15    0
C    0    1   18

Precision: 89.1%
Recall: 87.3%
```

**Clustering Results:**
```
Cluster 1: 15 points (center: [2.3, 4.1])
Cluster 2: 12 points (center: [7.8, 1.2])
Cluster 3: 8 points (center: [5.5, 9.3])

Within-cluster sum of squares: 156.7
Silhouette score: 0.73
```

**Neural Network Training:**
```
Epoch 1: Error = 0.825
Epoch 2: Error = 0.672
...
Epoch 100: Error = 0.023

Training completed in 2.3 seconds
Final accuracy: 94.5%
```

## 🛠️ Customization Tips

### Modifying Examples
1. **Change parameters** to see their effects
2. **Add visualization** to better understand results
3. **Include timing** to measure performance
4. **Add validation** to assess generalization
5. **Create comparisons** between different approaches

### Common Modifications
```ruby
# Add timing
start_time = Time.now
algorithm.train(data)
training_time = Time.now - start_time
puts "Training took #{training_time} seconds"

# Add cross-validation
require 'ai4r/experiment/classifier_evaluator'
accuracy = Ai4r::Experiment::ClassifierEvaluator.accuracy(actual, predicted)

# Add visualization (requires additional gems)
# plot_results(data, clusters) if defined?(plot_results)
```

## 📝 Exercise Ideas

### Beginner Exercises
1. Run the ID3 example with different datasets
2. Modify neural network parameters and observe training time
3. Compare clustering results with different k values
4. Test genetic algorithm with different population sizes

### Intermediate Exercises
1. Implement cross-validation for all classifiers
2. Create performance comparison charts
3. Add data preprocessing steps to examples
4. Combine multiple algorithms in ensemble methods

### Advanced Exercises
1. Implement new variants of existing algorithms
2. Create interactive parameter tuning interfaces
3. Add sophisticated visualization capabilities
4. Design experiments to test algorithmic hypotheses

## 🔗 Related Resources

- [Tutorial Documentation](../tutorials/) - Detailed explanations of concepts
- [API Reference](../reference/) - Complete method documentation
- [Test Suite](../../spec/) - Comprehensive usage examples
- [Source Code](../reference/source-code.md) - Implementation details

---

**Ready to explore?** Start with the examples that match your current learning goals and interests!