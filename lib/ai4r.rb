# frozen_string_literal: true

#
# AI4R - Artificial Intelligence for Ruby
# A comprehensive educational machine learning library
#
# This file loads all algorithm implementations organized by functional groups.
# Each group represents a major area of artificial intelligence and machine learning.
#

# =============================================================================
# 1. DATA HANDLING AND PREPROCESSING
# =============================================================================
# Core data structures and preprocessing utilities

# Core Data Structures
require_relative 'ai4r/data/data_set'
require_relative 'ai4r/data/statistics'
require_relative 'ai4r/data/proximity'
require_relative 'ai4r/data/parameterizable'

# Data Preprocessing and Quality
require_relative 'ai4r/data/data_preprocessing'
require_relative 'ai4r/data/data_normalizer'
require_relative 'ai4r/data/feature_scaler'
require_relative 'ai4r/data/missing_value_handler'
require_relative 'ai4r/data/outlier_detector'
require_relative 'ai4r/data/data_splitter'
require_relative 'ai4r/data/feature_engineer'

# Data Visualization and Analysis
require_relative 'ai4r/data/data_visualization'
require_relative 'ai4r/data/enhanced_data_set'

# Educational Data Framework
require_relative 'ai4r/data/educational_data_set'
require_relative 'ai4r/data/educational_examples'

# =============================================================================
# 2. CLUSTERING ALGORITHMS
# =============================================================================
# Unsupervised learning algorithms for pattern discovery

# Core Clustering Framework
require_relative 'ai4r/clusterers/clusterer'

# Partitional Clustering
require_relative 'ai4r/clusterers/k_means'
require_relative 'ai4r/clusterers/bisecting_k_means'

# Hierarchical Clustering
require_relative 'ai4r/clusterers/single_linkage'
require_relative 'ai4r/clusterers/complete_linkage'
require_relative 'ai4r/clusterers/average_linkage'
require_relative 'ai4r/clusterers/weighted_average_linkage'
require_relative 'ai4r/clusterers/centroid_linkage'
require_relative 'ai4r/clusterers/median_linkage'
require_relative 'ai4r/clusterers/ward_linkage'
require_relative 'ai4r/clusterers/ward_linkage_hierarchical'

# Divisive Clustering
require_relative 'ai4r/clusterers/diana'

# Density-Based Clustering
require_relative 'ai4r/clusterers/dbscan'

# Probabilistic Clustering
require_relative 'ai4r/clusterers/gaussian_mixture_model'

# Clustering Support and Evaluation
require_relative 'ai4r/clusterers/distance_metrics'
require_relative 'ai4r/clusterers/clustering_quality_evaluator'

# Educational Clustering Framework
require_relative 'ai4r/clusterers/educational_clustering'
require_relative 'ai4r/clusterers/educational_algorithms'
require_relative 'ai4r/clusterers/educational_examples'
require_relative 'ai4r/clusterers/enhanced_clustering_framework'
require_relative 'ai4r/clusterers/interactive_clustering_explorer'
require_relative 'ai4r/clusterers/synthetic_dataset_generator'
require_relative 'ai4r/clusterers/clustering_curriculum'

# =============================================================================
# 3. CLASSIFICATION ALGORITHMS
# =============================================================================
# Supervised learning algorithms for predictive modeling

# Core Classification Framework
require_relative 'ai4r/classifiers/classifier'

# Decision Trees and Rule-Based
require_relative 'ai4r/classifiers/id3'
require_relative 'ai4r/classifiers/prism'
require_relative 'ai4r/classifiers/one_r'
require_relative 'ai4r/classifiers/zero_r'

# Probabilistic Classifiers
require_relative 'ai4r/classifiers/naive_bayes'
require_relative 'ai4r/classifiers/logistic_regression'

# Instance-Based Learning
require_relative 'ai4r/classifiers/ib1'
require_relative 'ai4r/classifiers/enhanced_k_nearest_neighbors'

# Linear and Geometric Classifiers
require_relative 'ai4r/classifiers/support_vector_machine'
require_relative 'ai4r/classifiers/hyperpipes'
require_relative 'ai4r/classifiers/simple_linear_regression'

# Neural Network Classifiers
require_relative 'ai4r/classifiers/multilayer_perceptron'

# Ensemble Methods
require_relative 'ai4r/classifiers/votes'

# Feature Engineering and Evaluation
require_relative 'ai4r/classifiers/feature_engineering'
require_relative 'ai4r/classifiers/classifier_evaluation_suite'

# Educational Classification Framework
require_relative 'ai4r/classifiers/educational_classification'
require_relative 'ai4r/classifiers/educational_algorithms'
require_relative 'ai4r/classifiers/educational_examples'

# =============================================================================
# 4. NEURAL NETWORKS
# =============================================================================
# Artificial neural networks for complex pattern recognition

# Core Neural Network Architectures
require_relative 'ai4r/neural_network/backpropagation'
require_relative 'ai4r/neural_network/hopfield'
require_relative 'ai4r/neural_network/transformer'

# Neural Network Components
require_relative 'ai4r/neural_network/activation_functions'
require_relative 'ai4r/neural_network/learning_algorithms'
require_relative 'ai4r/neural_network/optimizers'
require_relative 'ai4r/neural_network/regularization'

# Enhanced Neural Networks
require_relative 'ai4r/neural_network/enhanced_neural_network'

# Educational Neural Network Framework
require_relative 'ai4r/neural_network/educational_neural_network'
require_relative 'ai4r/neural_network/educational_examples'

# =============================================================================
# 5. SELF-ORGANIZING MAPS
# =============================================================================
# Competitive learning and topology-preserving neural networks

# Core SOM Implementation
require_relative 'ai4r/som/som'
require_relative 'ai4r/som/layer'
require_relative 'ai4r/som/node'
require_relative 'ai4r/som/two_phase_layer'

# Educational SOM Framework
require_relative 'ai4r/som/educational_som'

# =============================================================================
# 6. GENETIC ALGORITHMS
# =============================================================================
# Evolutionary computation and optimization algorithms

# Core Genetic Algorithms
require_relative 'ai4r/genetic_algorithm/genetic_algorithm'
require_relative 'ai4r/genetic_algorithm/modern_genetic_search'

# Genetic Algorithm Components
require_relative 'ai4r/genetic_algorithm/chromosome'
require_relative 'ai4r/genetic_algorithm/operators'
require_relative 'ai4r/genetic_algorithm/enhanced_operators'
require_relative 'ai4r/genetic_algorithm/configuration'

# Evolution Monitoring and Analysis
require_relative 'ai4r/genetic_algorithm/evolution_monitor'
require_relative 'ai4r/genetic_algorithm/visualization_tools'

# Educational Genetic Algorithm Framework
require_relative 'ai4r/genetic_algorithm/educational_genetic_search'
require_relative 'ai4r/genetic_algorithm/examples'
require_relative 'ai4r/genetic_algorithm/tutorial'

# =============================================================================
# 7. SEARCH ALGORITHMS
# =============================================================================
# Systematic exploration and optimization algorithms

# Informed Search
require_relative 'ai4r/search/a_star'

# Game Tree Search
require_relative 'ai4r/search/minimax'

# =============================================================================
# 8. MACHINE LEARNING ALGORITHMS
# =============================================================================
# Advanced machine learning techniques

# Ensemble Methods
require_relative 'ai4r/machine_learning/random_forest'

# Dimensionality Reduction
require_relative 'ai4r/machine_learning/pca'

# Sequence Modeling
require_relative 'ai4r/machine_learning/hidden_markov_model'

# =============================================================================
# 9. EVALUATION AND EXPERIMENTATION
# =============================================================================
# Tools for algorithm evaluation and comparison

# Evaluation Framework
require_relative 'ai4r/experiment/classifier_evaluator'
require_relative 'ai4r/experiment/classifier_bench'
require_relative 'ai4r/experiment/search_bench'
