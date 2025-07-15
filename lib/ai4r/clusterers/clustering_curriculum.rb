# frozen_string_literal: true

# Educational Clustering Curriculum for Progressive Learning
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'synthetic_dataset_generator'

module Ai4r
  module Clusterers
    
    # Progressive clustering curriculum for educational purposes
    class ClusteringCurriculum
      
      def initialize(framework)
        @framework = framework
        @current_lesson = 0
        @student_progress = {}
      end
      
      # Beginner curriculum: Basic clustering concepts
      def run_beginner_curriculum
        puts "="*70
        puts "CLUSTERING ALGORITHMS - BEGINNER CURRICULUM"
        puts "="*70
        puts
        puts "Welcome to the comprehensive clustering algorithms course!"
        puts "This curriculum will guide you through clustering concepts step by step."
        puts
        puts "Beginner curriculum covers:"
        puts "1. What is clustering? (Conceptual introduction)"
        puts "2. Distance metrics and their importance"
        puts "3. K-Means clustering (your first algorithm)"
        puts "4. Choosing the right number of clusters"
        puts "5. Understanding clustering results"
        puts "6. When clustering works vs. when it fails"
        puts
        
        wait_for_user("Press Enter to start Lesson 1...")
        
        lesson_1_clustering_concepts
        lesson_2_distance_metrics
        lesson_3_first_kmeans
        lesson_4_choosing_k
        lesson_5_interpreting_results
        lesson_6_clustering_limitations
        
        puts "\n🎉 Congratulations! You've completed the beginner curriculum!"
        puts "You now understand the fundamentals of clustering algorithms."
        puts "\nNext steps:"
        puts "• Try the intermediate curriculum for hierarchical clustering"
        puts "• Experiment with your own datasets"
        puts "• Explore different distance metrics"
      end
      
      # Intermediate curriculum: Multiple algorithms and comparisons
      def run_intermediate_curriculum
        puts "="*70
        puts "CLUSTERING ALGORITHMS - INTERMEDIATE CURRICULUM"
        puts "="*70
        puts
        puts "Intermediate curriculum covers:"
        puts "1. Hierarchical clustering concepts"
        puts "2. Different linkage methods comparison"
        puts "3. Dendrograms and cluster trees"
        puts "4. DBSCAN and density-based clustering"
        puts "5. Algorithm comparison and selection"
        puts "6. Real-world applications"
        puts
        
        wait_for_user("Press Enter to start intermediate lessons...")
        
        lesson_7_hierarchical_concepts
        lesson_8_linkage_methods
        lesson_9_dbscan_introduction
        lesson_10_algorithm_comparison
        lesson_11_real_world_applications
        
        puts "\n🎉 Excellent! You've completed the intermediate curriculum!"
        puts "You can now choose appropriate algorithms for different data types."
      end
      
      # Advanced curriculum: Specialized techniques and optimization
      def run_advanced_curriculum
        puts "="*70
        puts "CLUSTERING ALGORITHMS - ADVANCED CURRICULUM" 
        puts "="*70
        puts
        puts "Advanced curriculum covers:"
        puts "1. Parameter optimization techniques"
        puts "2. High-dimensional clustering challenges"
        puts "3. Clustering validation methods"
        puts "4. Handling special data types"
        puts "5. Ensemble clustering methods"
        puts "6. Research frontiers and new developments"
        puts
        
        wait_for_user("Press Enter to start advanced lessons...")
        
        lesson_12_parameter_optimization
        lesson_13_high_dimensional_challenges
        lesson_14_clustering_validation
        lesson_15_special_data_types
        lesson_16_ensemble_methods
        
        puts "\n🏆 Outstanding! You've mastered advanced clustering techniques!"
        puts "You're now ready to tackle complex real-world clustering problems."
      end
      
      private
      
      def lesson_1_clustering_concepts
        puts "\n" + "="*50
        puts "LESSON 1: What is Clustering?"
        puts "="*50
        
        puts <<~LESSON
          Clustering is the task of grouping similar objects together.
          
          Key concepts:
          • Unsupervised learning: No target labels provided
          • Similarity: Objects in same cluster should be similar
          • Dissimilarity: Objects in different clusters should be different
          
          Real-world examples:
          • Customer segmentation for marketing
          • Gene expression analysis in biology
          • Image segmentation in computer vision
          • Document categorization in text mining
          
          Types of clustering:
          1. Partitional: Divide data into non-overlapping groups (K-Means)
          2. Hierarchical: Create tree of clusters (Single/Complete Linkage)
          3. Density-based: Find dense regions (DBSCAN)
          4. Model-based: Assume statistical models (Gaussian Mixture)
          
          What makes clustering challenging:
          • Defining "similarity" appropriately
          • Choosing the right number of clusters
          • Handling different cluster shapes and sizes
          • Dealing with noise and outliers
        LESSON
        
        wait_for_user("\nReady for a simple clustering example? Press Enter...")
        
        # Create simple example
        generator = SyntheticDatasetGenerator.new
        simple_data = generator.generate_blobs(3, 150, 0.3)
        @framework.add_dataset(:lesson1_simple, simple_data, 
                              "Simple well-separated clusters for demonstration")
        
        puts "\nI've created a simple dataset with 3 well-separated groups."
        puts "Let's visualize what clustering should achieve..."
        
        # Run K-means with correct K
        result = @framework.run_algorithm(:k_means, :lesson1_simple, 
                                        { k: 3, verbose: true })
        
        puts "\nNotice how the algorithm found the 3 natural groups in the data!"
        @student_progress[:lesson_1] = :completed
      end
      
      def lesson_2_distance_metrics
        puts "\n" + "="*50
        puts "LESSON 2: Distance Metrics - The Foundation of Clustering"
        puts "="*50
        
        puts <<~LESSON
          Distance metrics determine how we measure similarity between data points.
          The choice of distance metric can dramatically affect clustering results!
          
          Why distance matters:
          • Different metrics emphasize different aspects of similarity
          • Some metrics work better for certain data types
          • Wrong choice can lead to poor clustering results
          
          Let's explore the most common distance metrics...
        LESSON
        
        # Interactive distance metrics exploration
        DistanceMetrics.compare_metrics_educational
        puts
        DistanceMetrics.test_metrics_with_samples
        
        wait_for_user("\nNow let's see how different metrics affect clustering...")
        
        # Create dataset where metric choice matters
        generator = SyntheticDatasetGenerator.new
        elongated_data = generator.generate_anisotropic(200)
        @framework.add_dataset(:lesson2_elongated, elongated_data,
                              "Elongated clusters - shows distance metric importance")
        
        # Compare results with different distance metrics
        puts "\nComparing K-means with different distance metrics:"
        puts "(Note: In practice, you'd need to modify K-means to use different metrics)"
        
        result1 = @framework.run_algorithm(:k_means, :lesson2_elongated, 
                                         { k: 2, verbose: false })
        
        puts "\nKey takeaway: Always consider your data characteristics when choosing"
        puts "a distance metric. Euclidean distance assumes spherical clusters!"
        
        @student_progress[:lesson_2] = :completed
      end
      
      def lesson_3_first_kmeans
        puts "\n" + "="*50
        puts "LESSON 3: Your First K-Means Algorithm"
        puts "="*50
        
        puts <<~LESSON
          K-Means is often the first clustering algorithm students learn.
          
          How K-Means works:
          1. Choose K (number of clusters)
          2. Initialize K cluster centers (centroids)
          3. Assign each point to nearest centroid
          4. Update centroids to center of assigned points
          5. Repeat steps 3-4 until convergence
          
          Key concepts:
          • Centroid: The center point of a cluster
          • Assignment: Which cluster each point belongs to
          • Convergence: When centroids stop moving significantly
          • Local optima: Different starting points can give different results
          
          Let's run K-Means step by step to see how it works...
        LESSON
        
        # Generate ideal K-means data
        generator = SyntheticDatasetGenerator.new
        kmeans_data = generator.generate_blobs(4, 300, 0.5)
        @framework.add_dataset(:lesson3_kmeans, kmeans_data,
                              "Perfect for K-means - spherical, well-separated clusters")
        
        # Enable step mode for educational purposes
        @framework.enable_step_mode.enable_visualization
        
        puts "\nRunning K-means with step-by-step explanation..."
        puts "Watch how the centroids move and clusters form!"
        
        result = @framework.run_algorithm(:k_means, :lesson3_kmeans,
                                        { k: 4, verbose: true })
        
        puts "\nExercise: Try different values of K to see the effect:"
        [2, 3, 5, 6].each do |k|
          puts "\nK = #{k}:"
          @framework.run_algorithm(:k_means, :lesson3_kmeans,
                                  { k: k, verbose: false })
        end
        
        @student_progress[:lesson_3] = :completed
      end
      
      def lesson_4_choosing_k
        puts "\n" + "="*50
        puts "LESSON 4: Choosing the Right Number of Clusters (K)"
        puts "="*50
        
        puts <<~LESSON
          One of the biggest challenges in clustering: How many clusters?
          
          Common approaches:
          1. Domain knowledge: You know the expected number
          2. Elbow method: Look for "elbow" in within-cluster sum of squares
          3. Silhouette analysis: Measure how well points fit their clusters
          4. Gap statistic: Compare to random data
          5. Cross-validation: Use clustering stability
          
          Let's explore these methods...
        LESSON
        
        # Create dataset with ambiguous K
        generator = SyntheticDatasetGenerator.new
        ambiguous_data = generator.generate_blobs(5, 400, 1.0)  # Some overlap
        @framework.add_dataset(:lesson4_ambiguous, ambiguous_data,
                              "Ambiguous number of clusters - practice choosing K")
        
        puts "\nElbow Method Analysis:"
        puts "We'll try K from 1 to 10 and look for the 'elbow'"
        
        elbow_results = []
        (1..10).each do |k|
          result = @framework.run_algorithm(:k_means, :lesson4_ambiguous,
                                          { k: k, verbose: false })
          wcss = result[:quality_metrics][:within_cluster_sum_of_squares] || 0
          elbow_results << { k: k, wcss: wcss }
          puts "K=#{k}: WCSS=#{wcss.round(2)}"
        end
        
        puts "\nSilhouette Analysis:"
        (2..8).each do |k|
          result = @framework.run_algorithm(:k_means, :lesson4_ambiguous,
                                          { k: k, verbose: false })
          silhouette = result[:quality_metrics][:silhouette_score] || 0
          puts "K=#{k}: Silhouette Score=#{silhouette.round(4)}"
        end
        
        puts <<~ANALYSIS
          
          Interpreting the results:
          • Elbow method: Look for the K where WCSS stops decreasing rapidly
          • Silhouette: Higher scores are better (closer to 1.0)
          • Consider multiple methods - no single method is perfect
          • Domain knowledge often trumps statistical measures
        ANALYSIS
        
        @student_progress[:lesson_4] = :completed
      end
      
      def lesson_5_interpreting_results
        puts "\n" + "="*50
        puts "LESSON 5: Interpreting and Validating Clustering Results"
        puts "="*50
        
        puts <<~LESSON
          Getting clusters is just the beginning - you need to interpret them!
          
          Quality metrics to understand:
          • Silhouette Score: How well points fit their assigned clusters
          • Within-Cluster Sum of Squares (WCSS): Compactness of clusters
          • Between-Cluster Sum of Squares (BCSS): Separation between clusters
          • Davies-Bouldin Index: Lower is better (compactness vs separation)
          
          Practical interpretation:
          • Look at cluster sizes - are they reasonable?
          • Examine cluster centers - do they make sense?
          • Check for outliers or noise points
          • Validate with domain knowledge
        LESSON
        
        # Use previous result for detailed analysis
        puts "\nDetailed analysis of our clustering result:"
        
        result = @framework.run_algorithm(:k_means, :lesson4_ambiguous,
                                        { k: 5, verbose: false })
        
        puts "\nCluster Quality Metrics:"
        result[:quality_metrics].each do |metric, value|
          puts "#{metric}: #{value.round(4) if value.is_a?(Numeric)}"
        end
        
        puts "\nCluster Characteristics:"
        result[:stats][:cluster_sizes].each_with_index do |size, i|
          percentage = (size * 100.0 / result[:stats][:cluster_sizes].sum).round(1)
          puts "Cluster #{i}: #{size} points (#{percentage}%)"
        end
        
        puts <<~INTERPRETATION
          
          What to look for:
          ✓ Balanced cluster sizes (unless domain expects otherwise)
          ✓ High silhouette scores (> 0.5 is good, > 0.7 is excellent)
          ✓ Low Davies-Bouldin index (< 1.0 is good)
          ✗ One huge cluster with tiny others (poor clustering)
          ✗ Very negative silhouette scores (wrong number of clusters)
        INTERPRETATION
        
        @student_progress[:lesson_5] = :completed
      end
      
      def lesson_6_clustering_limitations
        puts "\n" + "="*50
        puts "LESSON 6: When Clustering Works vs. When It Fails"
        puts "="*50
        
        puts <<~LESSON
          Important: Clustering doesn't always work!
          Understanding limitations prevents misuse.
          
          K-Means works well when:
          ✓ Clusters are spherical (roughly circular)
          ✓ Clusters have similar sizes
          ✓ Clusters have similar densities
          ✓ Data is numeric and well-scaled
          
          K-Means struggles with:
          ✗ Non-spherical shapes (crescents, elongated clusters)
          ✗ Very different cluster sizes
          ✗ Different cluster densities
          ✗ Lots of noise or outliers
          
          Let's see examples of when K-Means fails...
        LESSON
        
        # Generate challenging datasets
        generator = SyntheticDatasetGenerator.new
        
        # Non-spherical clusters
        moons_data = generator.generate_moons(300, 0.1)
        @framework.add_dataset(:lesson6_moons, moons_data,
                              "Non-spherical clusters - K-means challenge")
        
        circles_data = generator.generate_circles(300, 0.05)
        @framework.add_dataset(:lesson6_circles, circles_data,
                              "Concentric circles - K-means fails here")
        
        varied_density = generator.generate_varied_density(400)
        @framework.add_dataset(:lesson6_density, varied_density,
                              "Different cluster densities")
        
        puts "\nExample 1: Non-spherical clusters (crescents)"
        @framework.run_algorithm(:k_means, :lesson6_moons, { k: 2, verbose: false })
        puts "→ K-means tries to make spherical clusters, misses the true structure"
        
        puts "\nExample 2: Concentric circles"
        @framework.run_algorithm(:k_means, :lesson6_circles, { k: 2, verbose: false })
        puts "→ K-means cannot separate circles - they're not linearly separable"
        
        puts "\nExample 3: Different densities"
        @framework.run_algorithm(:k_means, :lesson6_density, { k: 3, verbose: false })
        puts "→ K-means biased toward similar-sized clusters"
        
        puts <<~TAKEAWAY
          
          Key takeaways:
          • Always visualize your data first (if possible)
          • Consider the assumptions of your chosen algorithm
          • No single algorithm works for all data types
          • Sometimes clustering isn't the right approach at all
          
          This is why we need multiple clustering algorithms!
          In the next curriculum, we'll learn about hierarchical clustering and DBSCAN,
          which can handle some of these challenging cases.
        TAKEAWAY
        
        @student_progress[:lesson_6] = :completed
      end
      
      def lesson_7_hierarchical_concepts
        puts "\n" + "="*50
        puts "LESSON 7: Hierarchical Clustering Concepts"
        puts "="*50
        
        puts <<~LESSON
          Hierarchical clustering creates a tree of clusters.
          
          Two approaches:
          1. Agglomerative (bottom-up): Start with individual points, merge similar clusters
          2. Divisive (top-down): Start with all points, split clusters
          
          Advantages:
          • No need to specify number of clusters beforehand
          • Creates hierarchy showing relationships
          • Deterministic results (no random initialization)
          • Works with any distance metric
          
          Disadvantages:
          • Computationally expensive O(n³)
          • Difficult to handle large datasets
          • Sensitive to noise and outliers
          • Hard to undo early decisions
          
          The key decision: How to measure distance between clusters?
          This is called the "linkage method"...
        LESSON
        
        @student_progress[:lesson_7] = :completed
      end
      
      def lesson_8_linkage_methods
        puts "\n" + "="*50
        puts "LESSON 8: Linkage Methods Comparison"
        puts "="*50
        
        puts <<~LESSON
          Linkage methods define how to measure distance between clusters:
          
          1. Single Linkage: Minimum distance between any two points
             → Creates elongated, chain-like clusters
             → Sensitive to noise (chaining effect)
          
          2. Complete Linkage: Maximum distance between any two points
             → Creates compact, spherical clusters
             → Less sensitive to outliers
          
          3. Average Linkage: Average distance between all pairs
             → Balanced approach between single and complete
             → Good general-purpose choice
          
          4. Ward's Method: Minimizes within-cluster variance
             → Similar to K-means objective
             → Works best for spherical clusters
          
          Let's compare these methods on the same dataset...
        LESSON
        
        # Generate dataset suitable for comparison
        generator = SyntheticDatasetGenerator.new
        comparison_data = generator.generate_mixed_shapes(300)
        @framework.add_dataset(:lesson8_comparison, comparison_data,
                              "Mixed cluster shapes for linkage comparison")
        
        linkage_methods = [
          :hierarchical_single,
          :hierarchical_complete, 
          :hierarchical_average,
          :hierarchical_ward
        ]
        
        puts "\nComparing linkage methods on the same dataset:"
        
        @framework.compare_algorithms(linkage_methods, :lesson8_comparison)
        
        puts <<~ANALYSIS
          
          Observations:
          • Single linkage: Good for elongated/irregular shapes, prone to chaining
          • Complete linkage: Compact clusters, may split natural groups
          • Average linkage: Often the best compromise
          • Ward's method: Best when clusters are roughly spherical
          
          Choice depends on:
          • Expected cluster shapes
          • Presence of noise/outliers
          • Dataset size (computational constraints)
        ANALYSIS
        
        @student_progress[:lesson_8] = :completed
      end
      
      def lesson_9_dbscan_introduction
        puts "\n" + "="*50
        puts "LESSON 9: DBSCAN - Density-Based Clustering"
        puts "="*50
        
        puts <<~LESSON
          DBSCAN solves many K-means limitations!
          
          Key concepts:
          • Density-based: Clusters are dense regions separated by sparse regions
          • ε (epsilon): Maximum distance for points to be neighbors
          • MinPts: Minimum points needed to form a dense region
          • Core points: Points with ≥ MinPts neighbors
          • Border points: Non-core points near core points
          • Noise points: Points that are neither core nor border
          
          Advantages:
          ✓ Finds clusters of arbitrary shape
          ✓ Automatically determines number of clusters
          ✓ Handles noise and outliers naturally
          ✓ Deterministic results
          
          Disadvantages:
          ✗ Sensitive to ε and MinPts parameters
          ✗ Struggles with varying densities
          ✗ Can be computationally expensive
        LESSON
        
        # Demonstrate DBSCAN on challenging datasets
        puts "\nDBSCAN on challenging datasets where K-means failed:"
        
        puts "\n1. Crescent-shaped clusters:"
        result1 = @framework.run_algorithm(:dbscan, :lesson6_moons,
                                         { eps: 0.3, min_pts: 5, verbose: false })
        puts "→ DBSCAN correctly identifies the two crescents!"
        
        puts "\n2. Clusters with noise:"
        noisy_data = SyntheticDatasetGenerator.new.generate_with_noise(300, 0.2)
        @framework.add_dataset(:lesson9_noisy, noisy_data, "Data with 20% noise")
        
        result2 = @framework.run_algorithm(:dbscan, :lesson9_noisy,
                                         { eps: 0.5, min_pts: 8, verbose: false })
        
        if result2[:stats][:num_noise_points]
          puts "→ DBSCAN found #{result2[:stats][:num_noise_points]} noise points"
        end
        
        puts "\nParameter selection is crucial for DBSCAN!"
        puts "Let's explore how to choose ε and MinPts..."
        
        # Parameter analysis
        DBSCANParameterHelper.analyze_parameters(@framework.datasets[:lesson9_noisy][:data_set])
        
        @student_progress[:lesson_9] = :completed
      end
      
      def lesson_10_algorithm_comparison
        puts "\n" + "="*50
        puts "LESSON 10: Algorithm Comparison and Selection"
        puts "="*50
        
        puts <<~LESSON
          Now you know multiple clustering algorithms!
          How do you choose the right one?
          
          Decision factors:
          1. Data characteristics (shape, size, noise)
          2. Domain knowledge about expected clusters
          3. Computational constraints
          4. Interpretability requirements
          5. Need for hierarchy vs. flat clustering
          
          Algorithm selection guide:
          • K-Means: Spherical clusters, known K, fast computation needed
          • Hierarchical: Unknown K, need cluster relationships, small datasets
          • DBSCAN: Arbitrary shapes, noise handling, unknown K
          
          Let's compare all algorithms on various datasets...
        LESSON
        
        test_datasets = [:lesson1_simple, :lesson6_moons, :lesson6_circles, :lesson9_noisy]
        algorithms = [:k_means, :hierarchical_average, :dbscan]
        
        test_datasets.each do |dataset|
          next unless @framework.datasets[dataset]
          
          puts "\n#{dataset.to_s.upcase}:"
          puts @framework.datasets[dataset][:description]
          
          # Run comparison with appropriate parameters
          params_map = {
            k_means: { k: 3 },
            hierarchical_average: { num_clusters: 3 },
            dbscan: { eps: 0.5, min_pts: 5 }
          }
          
          @framework.compare_algorithms(algorithms, dataset, params_map)
        end
        
        @student_progress[:lesson_10] = :completed
      end
      
      def lesson_11_real_world_applications
        puts "\n" + "="*50
        puts "LESSON 11: Real-World Applications"
        puts "="*50
        
        puts <<~LESSON
          Let's see clustering in action across different domains:
          
          1. Customer Segmentation (Business)
          • Features: Age, income, purchase history, website behavior
          • Algorithm: K-means (interpretable segments)
          • Goal: Targeted marketing campaigns
          
          2. Gene Expression Analysis (Biology)
          • Features: Expression levels of thousands of genes
          • Algorithm: Hierarchical (shows gene relationships)
          • Goal: Understand gene function and disease mechanisms
          
          3. Image Segmentation (Computer Vision)
          • Features: Pixel colors, textures, positions
          • Algorithm: DBSCAN (handles irregular shapes)
          • Goal: Separate objects from background
          
          4. Document Clustering (Text Mining)
          • Features: Word frequencies (TF-IDF vectors)
          • Algorithm: K-means with cosine distance
          • Goal: Organize large document collections
          
          5. Anomaly Detection (Security)
          • Features: Network traffic patterns, user behaviors
          • Algorithm: DBSCAN (noise points = anomalies)
          • Goal: Detect intrusions or fraud
        LESSON
        
        # Simulate a customer segmentation example
        puts "\nPractical Example: Customer Segmentation"
        puts "Let's create a realistic customer dataset..."
        
        customer_data = generate_customer_data(500)
        @framework.add_dataset(:customers, customer_data,
                              "Simulated customer data: age, income, spending")
        
        puts "\nAnalyzing customer segments with K-means:"
        
        # Try different K values
        (2..6).each do |k|
          result = @framework.run_algorithm(:k_means, :customers,
                                          { k: k, verbose: false })
          puts "K=#{k}: Silhouette Score = #{result[:quality_metrics][:silhouette_score]&.round(4)}"
        end
        
        # Use the best K for final analysis
        final_result = @framework.run_algorithm(:k_means, :customers,
                                              { k: 4, verbose: false })
        
        puts "\nCustomer segments identified:"
        final_result[:algorithm_instance].clusters.each_with_index do |cluster, i|
          if cluster.data_items.length > 0
            avg_age = cluster.data_items.map { |c| c[0] }.sum / cluster.data_items.length
            avg_income = cluster.data_items.map { |c| c[1] }.sum / cluster.data_items.length
            avg_spending = cluster.data_items.map { |c| c[2] }.sum / cluster.data_items.length
            
            puts "Segment #{i+1}: #{cluster.data_items.length} customers"
            puts "  Avg Age: #{avg_age.round(1)}, Income: $#{avg_income.round(0)}, Spending: $#{avg_spending.round(0)}"
          end
        end
        
        @student_progress[:lesson_11] = :completed
      end
      
      def lesson_12_parameter_optimization
        puts "\n" + "="*50
        puts "LESSON 12: Parameter Optimization Techniques"
        puts "="*50
        
        puts <<~LESSON
          Advanced topic: How to systematically find the best parameters.
          
          Approaches:
          1. Grid Search: Try all combinations in a grid
          2. Random Search: Random sampling of parameter space
          3. Bayesian Optimization: Use previous results to guide search
          4. Cross-validation: Split data to avoid overfitting
          
          For clustering, we need different validation strategies since
          we don't have ground truth labels...
        LESSON
        
        @student_progress[:lesson_12] = :completed
      end
      
      def lesson_13_high_dimensional_challenges
        puts "\n" + "="*50
        puts "LESSON 13: High-Dimensional Clustering Challenges"
        puts "="*50
        
        puts <<~LESSON
          The "curse of dimensionality" affects clustering severely.
          
          Problems in high dimensions:
          • Distance metrics become less meaningful
          • All points seem equally far apart
          • Visualization becomes impossible
          • Computational complexity increases
          
          Solutions:
          • Dimensionality reduction (PCA, t-SNE)
          • Feature selection
          • Specialized distance metrics
          • Subspace clustering
        LESSON
        
        @student_progress[:lesson_13] = :completed
      end
      
      def lesson_14_clustering_validation
        puts "\n" + "="*50
        puts "LESSON 14: Clustering Validation Methods"
        puts "="*50
        
        puts <<~LESSON
          How do you know if your clustering is good?
          
          Internal validation (no ground truth needed):
          • Silhouette analysis
          • Davies-Bouldin index
          • Calinski-Harabasz index
          • Within/between cluster sum of squares
          
          External validation (when you have ground truth):
          • Adjusted Rand Index
          • Normalized Mutual Information
          • Fowlkes-Mallows Score
          
          Stability-based validation:
          • Bootstrap sampling
          • Cross-validation
          • Parameter sensitivity analysis
        LESSON
        
        @student_progress[:lesson_14] = :completed
      end
      
      def lesson_15_special_data_types
        puts "\n" + "="*50
        puts "LESSON 15: Handling Special Data Types"
        puts "="*50
        
        puts <<~LESSON
          Not all data is numeric! How to cluster:
          
          Categorical data:
          • Use appropriate distance metrics (Hamming, Jaccard)
          • K-modes algorithm (categorical K-means)
          • Consider encoding strategies
          
          Mixed data types:
          • K-prototypes (combines K-means and K-modes)
          • Gower distance
          • Feature-specific preprocessing
          
          Time series data:
          • Dynamic Time Warping distance
          • Shape-based clustering
          • Consider temporal relationships
          
          Text data:
          • TF-IDF vectorization
          • Cosine similarity
          • Topic modeling integration
        LESSON
        
        @student_progress[:lesson_15] = :completed
      end
      
      def lesson_16_ensemble_methods
        puts "\n" + "="*50
        puts "LESSON 16: Ensemble Clustering Methods"
        puts "="*50
        
        puts <<~LESSON
          Combine multiple clustering results for better performance.
          
          Approaches:
          1. Consensus clustering: Find agreement across methods
          2. Evidence accumulation: Vote on pairwise co-occurrences
          3. Multi-view clustering: Different feature sets
          4. Parameter bootstrapping: Multiple parameter settings
          
          Benefits:
          • More robust results
          • Better handling of uncertainty
          • Can combine strengths of different algorithms
          
          This represents the cutting edge of clustering research!
        LESSON
        
        @student_progress[:lesson_16] = :completed
      end
      
      def wait_for_user(message = "Press Enter to continue...")
        puts message
        gets
      end
      
      def generate_customer_data(n_customers)
        # Simulate realistic customer data
        data_items = []
        labels = ["age", "income", "spending"]
        
        # Create 4 customer segments
        segments = [
          { age: [25, 35], income: [30000, 50000], spending: [500, 1500] },    # Young, low income
          { age: [35, 50], income: [50000, 80000], spending: [1500, 3000] },   # Middle-aged, moderate
          { age: [50, 65], income: [70000, 120000], spending: [2000, 5000] },  # Older, high income
          { age: [20, 30], income: [60000, 100000], spending: [3000, 8000] }   # Young professionals
        ]
        
        segment_sizes = [n_customers/4] * 4
        
        segments.each_with_index do |segment, seg_idx|
          segment_sizes[seg_idx].times do
            age = rand(segment[:age][1] - segment[:age][0]) + segment[:age][0]
            income = rand(segment[:income][1] - segment[:income][0]) + segment[:income][0]
            spending = rand(segment[:spending][1] - segment[:spending][0]) + segment[:spending][0]
            
            # Add some noise
            age += rand(-3..3)
            income += rand(-5000..5000)
            spending += rand(-200..200)
            
            data_items << [age.to_f, income.to_f, spending.to_f]
          end
        end
        
        # Shuffle to remove ordering
        data_items.shuffle!
        
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
    end
  end
end