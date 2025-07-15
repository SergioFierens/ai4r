# Machine Learning Algorithms

## Overview

The AI4R machine learning algorithms group provides implementations of core machine learning techniques that complement the specialized classification and clustering algorithms. These algorithms demonstrate advanced concepts in statistical learning, dimensionality reduction, and sequence modeling.

## Educational Purpose

Machine learning algorithms demonstrate advanced concepts in artificial intelligence:
- **Statistical Learning**: Understanding patterns in data through probability
- **Dimensionality Reduction**: Extracting essential features from high-dimensional data
- **Sequence Modeling**: Understanding temporal and sequential patterns
- **Ensemble Methods**: Combining multiple models for improved performance

## Available Algorithms

### Ensemble Methods

#### Random Forest
- **File**: `lib/ai4r/machine_learning/random_forest.rb`
- **Description**: Ensemble of decision trees with bootstrap aggregating
- **Use Cases**: Classification, regression, feature importance analysis
- **Educational Value**: Demonstrates ensemble learning and variance reduction

**Key Features:**
- Bootstrap sampling for training diversity
- Random feature selection at each split
- Out-of-bag error estimation
- Feature importance calculation

**Example Usage:**
```ruby
# Create Random Forest classifier
rf = Ai4r::MachineLearning::RandomForest.new(
  n_trees: 100,
  max_depth: 10,
  min_samples_split: 5,
  random_features: true
)

# Train on dataset
rf.build(training_data)

# Make predictions
prediction = rf.eval(test_instance)
importance = rf.feature_importance
puts "Feature importance: #{importance}"
```

### Dimensionality Reduction

#### Principal Component Analysis (PCA)
- **File**: `lib/ai4r/machine_learning/pca.rb`
- **Description**: Linear dimensionality reduction through eigenvalue decomposition
- **Use Cases**: Data visualization, feature extraction, noise reduction
- **Educational Value**: Demonstrates linear algebra in machine learning

**Key Features:**
- Eigenvalue decomposition of covariance matrix
- Explained variance ratio calculation
- Data projection and reconstruction
- Visualization of principal components

**Example Usage:**
```ruby
# Create PCA analyzer
pca = Ai4r::MachineLearning::PCA.new(n_components: 2)

# Fit to data and transform
pca.fit(high_dimensional_data)
reduced_data = pca.transform(high_dimensional_data)

# Analyze components
puts "Explained variance: #{pca.explained_variance_ratio}"
puts "Components: #{pca.components}"
```

### Sequence Modeling

#### Hidden Markov Model (HMM)
- **File**: `lib/ai4r/machine_learning/hidden_markov_model.rb`
- **Description**: Probabilistic model for sequence analysis with hidden states
- **Use Cases**: Speech recognition, bioinformatics, time series analysis
- **Educational Value**: Demonstrates probabilistic sequence modeling

**Key Features:**
- Forward algorithm for sequence probability
- Viterbi algorithm for most likely state sequence
- Baum-Welch algorithm for parameter learning
- Sequence generation and evaluation

**Example Usage:**
```ruby
# Define states and observations
states = [:sunny, :rainy]
observations = [:walk, :shop, :clean]

# Create HMM
hmm = Ai4r::MachineLearning::HiddenMarkovModel.new(
  states, 
  observations,
  verbose: true
)

# Train on sequences
sequences = [
  { observations: [:walk, :shop, :clean], states: [:sunny, :sunny, :rainy] },
  { observations: [:clean, :clean, :walk], states: [:rainy, :rainy, :sunny] }
]

hmm.train(sequences, supervised: true)

# Predict state sequence
predicted_states = hmm.viterbi([:walk, :shop])
puts "Most likely states: #{predicted_states}"
```

## Key Concepts Demonstrated

### Statistical Learning Theory
- **Bias-Variance Tradeoff**: Understanding model complexity effects
- **Overfitting and Underfitting**: Balancing model capacity and generalization
- **Cross-Validation**: Robust model evaluation techniques
- **Regularization**: Preventing overfitting through constraints

### Ensemble Learning
- **Bootstrap Aggregating**: Reducing variance through sampling
- **Random Subspace Method**: Feature randomization for diversity
- **Voting Mechanisms**: Combining predictions from multiple models
- **Boosting**: Sequential learning with error correction

### Dimensionality Reduction
- **Linear Methods**: PCA, Linear Discriminant Analysis
- **Non-linear Methods**: Kernel PCA, Manifold Learning
- **Feature Selection**: Choosing relevant features
- **Curse of Dimensionality**: Understanding high-dimensional challenges

### Probabilistic Modeling
- **Bayesian Inference**: Updating beliefs with evidence
- **Maximum Likelihood**: Parameter estimation principles
- **Expectation-Maximization**: Iterative parameter learning
- **Model Selection**: Choosing appropriate model complexity

## Educational Features

### Interactive Analysis
- **Step-by-step Algorithms**: Detailed algorithm execution
- **Visualization Tools**: Graphical representation of concepts
- **Parameter Sensitivity**: Understanding parameter effects
- **Comparative Analysis**: Side-by-side algorithm comparison

### Practical Applications
- **Real-world Datasets**: Working with actual data problems
- **Performance Metrics**: Comprehensive evaluation measures
- **Interpretability**: Understanding model decisions
- **Scalability**: Handling large datasets efficiently

## Common Usage Patterns

### Ensemble Classification
```ruby
# Create ensemble of different classifiers
ensemble = Ai4r::MachineLearning::EnsembleClassifier.new

# Add base classifiers
ensemble.add_classifier(Ai4r::Classifiers::ID3.new)
ensemble.add_classifier(Ai4r::Classifiers::NaiveBayes.new)
ensemble.add_classifier(Ai4r::Classifiers::KNearestNeighbors.new)

# Train ensemble
ensemble.build(training_data)

# Make ensemble prediction
prediction = ensemble.eval(test_instance)
confidence = ensemble.prediction_confidence(test_instance)
```

### Dimensionality Reduction Pipeline
```ruby
# Create preprocessing pipeline
pipeline = Ai4r::MachineLearning::PreprocessingPipeline.new

# Add preprocessing steps
pipeline.add_step(Ai4r::Data::FeatureScaler.new(method: :standardization))
pipeline.add_step(Ai4r::MachineLearning::PCA.new(n_components: 0.95))

# Process data
transformed_data = pipeline.transform(raw_data)

# Train classifier on reduced data
classifier = Ai4r::Classifiers::SVM.new
classifier.build(transformed_data)
```

### Time Series Analysis
```ruby
# Create time series analyzer
analyzer = Ai4r::MachineLearning::TimeSeriesAnalyzer.new

# Build HMM for sequence modeling
hmm = analyzer.build_hmm(
  observations: time_series_data,
  n_states: 3,
  learning_method: :baum_welch
)

# Analyze patterns
patterns = analyzer.find_patterns(time_series_data)
anomalies = analyzer.detect_anomalies(time_series_data)
```

## Integration with Other Components

### Data Preprocessing
- Works with `Ai4r::Data::DataSet` for structured data
- Supports feature scaling and normalization
- Handles missing values and outliers
- Integrates with feature selection methods

### Visualization
- PCA projection visualization
- Random Forest feature importance plots
- HMM state transition diagrams
- Learning curve analysis

### Model Evaluation
- Cross-validation support
- Performance metrics calculation
- Model comparison tools
- Statistical significance testing

## Educational Progression

### Beginner Level
1. **PCA**: Understanding linear dimensionality reduction
2. **Random Forest**: Learning ensemble methods
3. **Basic HMM**: Introduction to probabilistic modeling

### Intermediate Level
1. **Advanced PCA**: Kernel PCA and non-linear methods
2. **Ensemble Techniques**: Boosting and stacking
3. **HMM Applications**: Speech and text processing

### Advanced Level
1. **Custom Ensembles**: Designing problem-specific ensembles
2. **Manifold Learning**: Non-linear dimensionality reduction
3. **Advanced Sequence Models**: Conditional Random Fields

## Performance Considerations

### Time Complexity
- **Random Forest**: O(n × log n × m × t) where n=samples, m=features, t=trees
- **PCA**: O(n × m²) for covariance matrix computation
- **HMM Training**: O(n × s² × t) where s=states, t=sequence length

### Space Complexity
- **Random Forest**: O(t × n) for storing trees
- **PCA**: O(m²) for covariance matrix
- **HMM**: O(s²) for transition matrices

### Scalability
- **Large Datasets**: Use mini-batch PCA, online learning
- **High Dimensions**: Implement sparse matrix operations
- **Long Sequences**: Use forward-backward algorithm optimizations

## Best Practices

### Random Forest
- **Tree Count**: 50-200 trees for most problems
- **Feature Sampling**: √m features for classification, m/3 for regression
- **Depth Control**: Balance between overfitting and underfitting
- **Bootstrap Sampling**: Enable for variance reduction

### PCA
- **Standardization**: Scale features before PCA
- **Component Selection**: Use explained variance ratio
- **Interpretation**: Analyze component loadings
- **Validation**: Check reconstruction error

### HMM
- **State Count**: Use cross-validation for selection
- **Initialization**: Random or data-driven starting parameters
- **Convergence**: Monitor log-likelihood improvements
- **Evaluation**: Use held-out data for testing

### Common Pitfalls
- **Data Leakage**: Ensure proper train/test separation
- **Overfitting**: Use validation data for model selection
- **Scaling**: Normalize features for distance-based methods
- **Assumptions**: Verify model assumptions are met

## Advanced Topics

### Ensemble Methods
- **Bagging**: Bootstrap aggregating for variance reduction
- **Boosting**: Sequential learning with error correction
- **Stacking**: Meta-learning for ensemble combination
- **Dynamic Ensembles**: Adaptive ensemble selection

### Manifold Learning
- **t-SNE**: Non-linear dimensionality reduction
- **ISOMAP**: Geodesic distance preservation
- **Locally Linear Embedding**: Local neighborhood preservation
- **Spectral Methods**: Graph-based dimensionality reduction

### Advanced Sequence Models
- **Conditional Random Fields**: Discriminative sequence labeling
- **Recurrent Neural Networks**: Deep learning for sequences
- **LSTM/GRU**: Long-term dependency modeling
- **Attention Mechanisms**: Focusing on relevant sequence parts

### Model Interpretability
- **Feature Importance**: Understanding model decisions
- **Partial Dependence**: Feature effect visualization
- **SHAP Values**: Unified interpretation framework
- **Local Explanations**: Instance-specific interpretations

## Real-World Applications

### Computer Vision
- **Image Classification**: Using ensemble methods
- **Dimensionality Reduction**: PCA for image compression
- **Object Detection**: Combining multiple detection models
- **Feature Extraction**: Principal component analysis

### Natural Language Processing
- **Text Classification**: Ensemble classifiers for sentiment analysis
- **Sequence Labeling**: HMM for part-of-speech tagging
- **Topic Modeling**: Dimensionality reduction for document analysis
- **Language Modeling**: Probabilistic sequence generation

### Bioinformatics
- **Gene Expression**: PCA for exploratory analysis
- **Protein Sequences**: HMM for motif finding
- **Phylogenetic Analysis**: Ensemble methods for tree construction
- **Drug Discovery**: Machine learning for compound screening

This machine learning framework provides a comprehensive foundation for understanding advanced statistical learning techniques through hands-on implementation and practical application.