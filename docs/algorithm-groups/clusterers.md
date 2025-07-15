# Clustering Algorithms

## Overview

The AI4R clustering algorithms group provides a comprehensive collection of unsupervised learning algorithms designed to discover patterns and group similar data points. These algorithms are essential for exploratory data analysis, pattern recognition, and data preprocessing.

## Educational Purpose

Clustering algorithms demonstrate fundamental concepts in unsupervised learning:
- **Pattern Discovery**: Finding hidden structures in unlabeled data
- **Similarity Measures**: Understanding how distance metrics affect grouping
- **Optimization**: Iterative improvement of cluster assignments
- **Evaluation**: Measuring cluster quality and choosing optimal parameters

## Available Algorithms

### Partitional Clustering

#### K-Means
- **File**: `lib/ai4r/clusterers/k_means.rb`
- **Description**: Partitions data into k clusters by minimizing within-cluster variance
- **Use Cases**: Customer segmentation, image compression, data preprocessing
- **Educational Value**: Demonstrates iterative optimization and centroid-based clustering

#### Bisecting K-Means
- **File**: `lib/ai4r/clusterers/bisecting_k_means.rb`
- **Description**: Hierarchical variant that recursively splits clusters using K-means
- **Use Cases**: Creating hierarchical cluster structures, handling large datasets
- **Educational Value**: Shows how to combine hierarchical and partitional approaches

### Hierarchical Clustering

#### Single Linkage
- **File**: `lib/ai4r/clusterers/single_linkage.rb`
- **Description**: Merges clusters based on minimum distance between points
- **Use Cases**: Creating dendrograms, analyzing cluster structure
- **Educational Value**: Demonstrates agglomerative clustering and linkage criteria

#### Complete Linkage
- **File**: `lib/ai4r/clusterers/complete_linkage.rb`
- **Description**: Merges clusters based on maximum distance between points
- **Use Cases**: Creating compact, spherical clusters
- **Educational Value**: Shows how linkage criteria affect cluster shape

#### Average Linkage
- **File**: `lib/ai4r/clusterers/average_linkage.rb`
- **Description**: Merges clusters based on average distance between all points
- **Use Cases**: Balanced cluster shapes, moderate-sized clusters
- **Educational Value**: Demonstrates compromise between single and complete linkage

#### Weighted Average Linkage
- **File**: `lib/ai4r/clusterers/weighted_average_linkage.rb`
- **Description**: Weighted version of average linkage clustering
- **Use Cases**: When cluster sizes matter in merging decisions
- **Educational Value**: Shows how to incorporate cluster size into distance calculations

#### Centroid Linkage
- **File**: `lib/ai4r/clusterers/centroid_linkage.rb`
- **Description**: Merges clusters based on centroid distances
- **Use Cases**: When cluster centers are meaningful representations
- **Educational Value**: Connects hierarchical and centroid-based approaches

#### Median Linkage
- **File**: `lib/ai4r/clusterers/median_linkage.rb`
- **Description**: Uses median-based distance calculation for merging
- **Use Cases**: Robust to outliers in cluster merging
- **Educational Value**: Demonstrates robust statistics in clustering

#### Ward Linkage
- **File**: `lib/ai4r/clusterers/ward_linkage.rb`
- **Description**: Minimizes within-cluster variance when merging
- **Use Cases**: Creating compact, well-separated clusters
- **Educational Value**: Shows optimization-based approach to hierarchical clustering

#### Ward Linkage Hierarchical
- **File**: `lib/ai4r/clusterers/ward_linkage_hierarchical.rb`
- **Description**: Hierarchical implementation of Ward's method
- **Use Cases**: Full dendrogram construction with Ward's criterion
- **Educational Value**: Demonstrates hierarchical optimization

### Divisive Clustering

#### DIANA (Divisive Analysis)
- **File**: `lib/ai4r/clusterers/diana.rb`
- **Description**: Top-down hierarchical clustering by recursive splitting
- **Use Cases**: When top-level structure is more important than details
- **Educational Value**: Shows divisive vs. agglomerative approaches

### Density-Based Clustering

#### DBSCAN
- **File**: `lib/ai4r/clusterers/dbscan.rb`
- **Description**: Density-based clustering that finds arbitrary-shaped clusters
- **Use Cases**: Detecting outliers, handling noise, non-spherical clusters
- **Educational Value**: Demonstrates density-based clustering concepts

### Probabilistic Clustering

#### Gaussian Mixture Model
- **File**: `lib/ai4r/clusterers/gaussian_mixture_model.rb`
- **Description**: Probabilistic clustering using mixture of Gaussians
- **Use Cases**: Soft clustering, probability-based assignments
- **Educational Value**: Shows probabilistic approach to clustering

## Key Concepts Demonstrated

### Distance Metrics
- **Euclidean Distance**: Standard geometric distance
- **Manhattan Distance**: City-block distance
- **Custom Distance Functions**: User-defined similarity measures
- **File**: `lib/ai4r/clusterers/distance_metrics.rb`

### Cluster Evaluation
- **Silhouette Analysis**: Measures cluster cohesion and separation
- **Within-Cluster Sum of Squares**: Measures cluster compactness
- **Between-Cluster Distance**: Measures cluster separation
- **File**: `lib/ai4r/clusterers/clustering_quality_evaluator.rb`

### Educational Features
- **Interactive Exploration**: Step-by-step clustering visualization
- **Curriculum**: Structured learning path for clustering concepts
- **Synthetic Data**: Generated datasets for educational purposes
- **Files**: 
  - `lib/ai4r/clusterers/educational_clustering.rb`
  - `lib/ai4r/clusterers/interactive_clustering_explorer.rb`
  - `lib/ai4r/clusterers/synthetic_dataset_generator.rb`

## Common Usage Patterns

### Basic Clustering
```ruby
# Load data
data = Ai4r::Data::DataSet.new(data_labels, data_items)

# Create and configure clusterer
clusterer = Ai4r::Clusterers::KMeans.new
clusterer.number_of_clusters = 3

# Perform clustering
clusterer.build(data)

# Access results
puts "Clusters: #{clusterer.clusters.length}"
puts "Centroids: #{clusterer.centroids.inspect}"
```

### Hierarchical Clustering
```ruby
# Create hierarchical clusterer
clusterer = Ai4r::Clusterers::AverageLinkage.new

# Build cluster hierarchy
clusterer.build(data)

# Access dendrogram
puts "Cluster hierarchy: #{clusterer.clusters.inspect}"
```

### Educational Exploration
```ruby
# Create educational clustering environment
explorer = Ai4r::Clusterers::InteractiveClusteringExplorer.new

# Generate synthetic data
data = explorer.generate_synthetic_data(
  n_points: 100,
  n_clusters: 3,
  noise_level: 0.1
)

# Explore different algorithms
explorer.compare_algorithms(data, [:k_means, :dbscan, :ward_linkage])
```

## Integration with Other Components

### Data Preprocessing
- Works with `Ai4r::Data::DataSet` for structured data handling
- Supports custom distance functions and normalization
- Integrates with feature scaling and selection

### Visualization
- Supports 2D and 3D cluster visualization
- Dendrogram generation for hierarchical methods
- Interactive exploration tools

### Evaluation
- Comprehensive cluster quality metrics
- Statistical significance testing
- Comparative algorithm evaluation

## Educational Progression

### Beginner Level
1. **K-Means**: Understand basic partitional clustering
2. **Distance Metrics**: Learn about similarity measures
3. **Cluster Evaluation**: Assess clustering quality

### Intermediate Level
1. **Hierarchical Methods**: Explore agglomerative clustering
2. **Linkage Criteria**: Compare different merging strategies
3. **Parameter Selection**: Choose optimal number of clusters

### Advanced Level
1. **Density-Based Clustering**: Handle arbitrary cluster shapes
2. **Probabilistic Clustering**: Work with soft assignments
3. **Custom Algorithms**: Implement domain-specific clustering

## Performance Considerations

### Time Complexity
- **K-Means**: O(n × k × i × d) where n=points, k=clusters, i=iterations, d=dimensions
- **Hierarchical**: O(n³) for complete methods, O(n²) for optimized versions
- **DBSCAN**: O(n log n) with spatial indexing

### Space Complexity
- **K-Means**: O(n × d + k × d)
- **Hierarchical**: O(n²) for distance matrix storage
- **DBSCAN**: O(n) for point storage

### Scalability
- **Large Datasets**: Use Bisecting K-Means or Mini-Batch K-Means
- **High Dimensions**: Consider dimensionality reduction first
- **Streaming Data**: Implement incremental clustering variants

## Best Practices

### Algorithm Selection
- **K-Means**: For spherical clusters with known k
- **Hierarchical**: For understanding cluster relationships
- **DBSCAN**: For arbitrary shapes and noise handling
- **GMM**: For probabilistic assignments

### Parameter Tuning
- **Number of Clusters**: Use elbow method, silhouette analysis
- **Distance Function**: Choose based on data characteristics
- **Linkage Criteria**: Select based on desired cluster properties

### Data Preparation
- **Normalization**: Standardize features for distance-based methods
- **Outlier Handling**: Consider robust clustering methods
- **Feature Selection**: Remove irrelevant dimensions

This clustering framework provides a comprehensive foundation for understanding unsupervised learning through hands-on implementation and educational exploration.