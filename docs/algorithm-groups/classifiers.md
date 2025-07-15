# Classification Algorithms

## Overview

The AI4R classification algorithms group provides a comprehensive collection of supervised learning algorithms designed to predict class labels for new instances based on training data. These algorithms form the foundation of pattern recognition and predictive modeling in machine learning.

## Educational Purpose

Classification algorithms demonstrate fundamental concepts in supervised learning:
- **Pattern Recognition**: Learning to distinguish between different classes
- **Feature Importance**: Understanding which attributes contribute to classification
- **Generalization**: Building models that work on unseen data
- **Decision Boundaries**: How algorithms separate different classes in feature space

## Available Algorithms

### Decision Trees

#### ID3 (Iterative Dichotomiser 3)
- **File**: `lib/ai4r/classifiers/id3.rb`
- **Description**: Builds decision trees using information gain and entropy
- **Use Cases**: Interpretable models, categorical features, rule extraction
- **Educational Value**: Demonstrates recursive partitioning and information theory

### Rule-Based Classifiers

#### PRISM
- **File**: `lib/ai4r/classifiers/prism.rb`
- **Description**: Generates classification rules using covering algorithm
- **Use Cases**: Interpretable rules, handling inconsistent data
- **Educational Value**: Shows rule-based reasoning and conflict resolution

#### OneR (One Rule)
- **File**: `lib/ai4r/classifiers/one_r.rb`
- **Description**: Creates single-rule classifier based on most informative attribute
- **Use Cases**: Baseline classifier, feature selection insight
- **Educational Value**: Demonstrates simplicity vs. accuracy trade-off

#### ZeroR (Zero Rule)
- **File**: `lib/ai4r/classifiers/zero_r.rb`
- **Description**: Predicts most frequent class (baseline classifier)
- **Use Cases**: Performance baseline, class distribution analysis
- **Educational Value**: Shows importance of baseline comparisons

### Instance-Based Learning

#### IB1 (Instance-Based Learning 1)
- **File**: `lib/ai4r/classifiers/ib1.rb`
- **Description**: Nearest neighbor classifier using stored instances
- **Use Cases**: Local pattern recognition, similarity-based classification
- **Educational Value**: Demonstrates lazy learning and similarity measures

#### Enhanced K-Nearest Neighbors
- **File**: `lib/ai4r/classifiers/enhanced_k_nearest_neighbors.rb`
- **Description**: Advanced k-NN with distance weighting and optimization
- **Use Cases**: Non-linear classification, local decision boundaries
- **Educational Value**: Shows advanced nearest neighbor techniques

### Probabilistic Classifiers

#### Naive Bayes
- **File**: `lib/ai4r/classifiers/naive_bayes.rb`
- **Description**: Probabilistic classifier based on Bayes' theorem
- **Use Cases**: Text classification, spam detection, medical diagnosis
- **Educational Value**: Demonstrates probabilistic reasoning and conditional independence

### Linear Classifiers

#### Simple Linear Regression
- **File**: `lib/ai4r/classifiers/simple_linear_regression.rb`
- **Description**: Linear model for regression and binary classification
- **Use Cases**: Continuous target prediction, linear relationships
- **Educational Value**: Shows linear modeling and least squares optimization

#### Logistic Regression
- **File**: `lib/ai4r/classifiers/logistic_regression.rb`
- **Description**: Linear classifier using logistic function
- **Use Cases**: Binary classification, probability estimation
- **Educational Value**: Demonstrates logistic function and maximum likelihood

#### Support Vector Machine
- **File**: `lib/ai4r/classifiers/support_vector_machine.rb`
- **Description**: Finds optimal separating hyperplane with maximum margin
- **Use Cases**: High-dimensional data, non-linear classification with kernels
- **Educational Value**: Shows margin optimization and kernel methods

### Geometric Classifiers

#### Hyperpipes
- **File**: `lib/ai4r/classifiers/hyperpipes.rb`
- **Description**: Creates axis-parallel hyperrectangles for each class
- **Use Cases**: Simple geometric classification, fast training
- **Educational Value**: Demonstrates geometric approach to classification

### Neural Network Classifiers

#### Multilayer Perceptron
- **File**: `lib/ai4r/classifiers/multilayer_perceptron.rb`
- **Description**: Feed-forward neural network with backpropagation
- **Use Cases**: Non-linear classification, complex pattern recognition
- **Educational Value**: Shows neural network learning and backpropagation

### Ensemble Methods

#### Votes
- **File**: `lib/ai4r/classifiers/votes.rb`
- **Description**: Combines multiple classifiers using voting
- **Use Cases**: Improving accuracy, reducing overfitting
- **Educational Value**: Demonstrates ensemble learning principles

## Key Concepts Demonstrated

### Feature Engineering
- **Feature Selection**: Identifying most relevant attributes
- **Feature Scaling**: Normalizing feature ranges
- **Feature Transformation**: Creating new features from existing ones
- **File**: `lib/ai4r/classifiers/feature_engineering.rb`

### Model Evaluation
- **Cross-Validation**: Assessing model performance
- **Confusion Matrix**: Detailed classification results
- **ROC Curves**: Threshold-independent evaluation
- **File**: `lib/ai4r/classifiers/classifier_evaluation_suite.rb`

### Educational Features
- **Interactive Learning**: Step-by-step algorithm visualization
- **Algorithm Comparison**: Side-by-side performance analysis
- **Concept Demonstrations**: Visual learning aids
- **Files**: 
  - `lib/ai4r/classifiers/educational_classification.rb`
  - `lib/ai4r/classifiers/educational_algorithms.rb`
  - `lib/ai4r/classifiers/educational_examples.rb`

## Common Usage Patterns

### Basic Classification
```ruby
# Load training data
data = Ai4r::Data::DataSet.new(data_labels, data_items)

# Create and train classifier
classifier = Ai4r::Classifiers::ID3.new
classifier.build(data)

# Make predictions
prediction = classifier.eval(['New York', '<30', 'M'])
puts "Prediction: #{prediction}"
```

### Model Evaluation
```ruby
# Create evaluation suite
evaluator = Ai4r::Classifiers::ClassifierEvaluationSuite.new

# Evaluate multiple algorithms
results = evaluator.evaluate(
  data,
  classifiers: [
    Ai4r::Classifiers::ID3.new,
    Ai4r::Classifiers::NaiveBayes.new,
    Ai4r::Classifiers::KNearestNeighbors.new
  ]
)

# Compare performance
puts "Accuracy comparison: #{results[:accuracy]}"
```

### Feature Engineering
```ruby
# Create feature engineer
engineer = Ai4r::Classifiers::FeatureEngineering.new

# Transform features
transformed_data = engineer.transform(data)

# Select best features
selected_features = engineer.select_features(data, target_column: -1)
```

## Integration with Other Components

### Data Preprocessing
- Works with `Ai4r::Data::DataSet` for structured data handling
- Supports feature scaling and normalization
- Handles missing values and outliers

### Visualization
- Supports decision tree visualization
- ROC curve plotting
- Feature importance charts

### Evaluation
- Comprehensive performance metrics
- Statistical significance testing
- Cross-validation support

## Educational Progression

### Beginner Level
1. **ZeroR**: Understand baseline classification
2. **OneR**: Learn single-rule classifiers
3. **Decision Trees**: Explore tree-based reasoning

### Intermediate Level
1. **Naive Bayes**: Understand probabilistic classification
2. **k-NN**: Learn instance-based methods
3. **Linear Models**: Explore linear decision boundaries

### Advanced Level
1. **Neural Networks**: Understand non-linear learning
2. **SVM**: Learn margin-based classification
3. **Ensemble Methods**: Combine multiple models

## Performance Considerations

### Time Complexity
- **Decision Trees**: O(n × log n × m) for training, O(log n) for prediction
- **Naive Bayes**: O(n × m) for training, O(m) for prediction
- **k-NN**: O(1) for training, O(n × m) for prediction
- **SVM**: O(n²) to O(n³) for training, O(k × m) for prediction

### Space Complexity
- **Decision Trees**: O(n) for tree storage
- **Naive Bayes**: O(m × c) for probability tables
- **k-NN**: O(n × m) for instance storage
- **SVM**: O(k × m) for support vectors

### Scalability
- **Large Datasets**: Use linear models or ensemble methods
- **High Dimensions**: Consider feature selection or dimensionality reduction
- **Real-time Prediction**: Use simple models like Naive Bayes or OneR

## Best Practices

### Algorithm Selection
- **Interpretability**: Decision trees, rule-based methods
- **Speed**: Naive Bayes, OneR, linear models
- **Accuracy**: Neural networks, SVM, ensemble methods
- **Small Datasets**: k-NN, simple linear models

### Data Preparation
- **Categorical Features**: One-hot encoding, ordinal encoding
- **Numerical Features**: Normalization, standardization
- **Missing Values**: Imputation, indicator variables
- **Outliers**: Robust scaling, outlier detection

### Model Validation
- **Cross-Validation**: K-fold, leave-one-out
- **Holdout Validation**: Train/validation/test splits
- **Performance Metrics**: Accuracy, precision, recall, F1-score
- **Bias-Variance Trade-off**: Model complexity vs. generalization

### Hyperparameter Tuning
- **Grid Search**: Exhaustive parameter search
- **Random Search**: Random parameter sampling
- **Validation Curves**: Parameter impact visualization
- **Early Stopping**: Preventing overfitting

This classification framework provides a comprehensive foundation for understanding supervised learning through hands-on implementation and educational exploration.