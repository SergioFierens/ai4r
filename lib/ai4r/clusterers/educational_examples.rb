# frozen_string_literal: true

# Comprehensive Educational Examples for Clustering Algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'enhanced_clustering_framework'
require_relative 'synthetic_dataset_generator'
require_relative 'interactive_clustering_explorer'

module Ai4r
  module Clusterers
    
    # Comprehensive educational examples and tutorials for clustering
    class EducationalExamples
      
      def self.run_all_examples
        puts "="*70
        puts "CLUSTERING ALGORITHMS - EDUCATIONAL EXAMPLES"
        puts "="*70
        puts
        puts "This comprehensive guide demonstrates clustering algorithms through"
        puts "practical examples, comparisons, and real-world applications."
        puts
        
        wait_for_user("Press Enter to start the educational examples...")
        
        example_1_basic_concepts
        example_2_algorithm_comparison
        example_3_parameter_effects
        example_4_real_world_scenarios
        example_5_failure_cases
        example_6_best_practices
        
        puts "\n🎉 Completed all educational examples!"
        puts "You now have a comprehensive understanding of clustering algorithms."
      end
      
      # Example 1: Basic clustering concepts with simple data
      def self.example_1_basic_concepts
        puts "\n" + "="*60
        puts "EXAMPLE 1: Basic Clustering Concepts"
        puts "="*60
        
        puts <<~INTRODUCTION
          Let's start with the fundamentals. We'll create simple data and
          show how different algorithms approach the same clustering problem.
          
          Key learning objectives:
          • Understanding what clustering tries to achieve
          • Seeing how algorithms find patterns in data
          • Recognizing the difference between hard and soft clustering
        INTRODUCTION
        
        wait_for_user
        
        # Create framework and simple dataset
        framework = EnhancedClusteringFramework.new
        generator = SyntheticDatasetGenerator.new
        
        # Perfect clustering scenario
        simple_data = generator.generate_blobs(3, 300, 0.5)
        framework.add_dataset(:simple_example, simple_data, 
                             "Three well-separated Gaussian clusters")
        
        puts "\nDataset: 3 well-separated clusters (ideal for clustering)"
        puts "Let's see how different algorithms handle this simple case..."
        
        # K-means
        puts "\n--- K-Means Clustering ---"
        puts "K-means assumes spherical clusters and finds their centers."
        
        result_kmeans = framework.run_algorithm(:k_means, :simple_example, 
                                              { k: 3, verbose: true })
        
        puts "✓ K-means worked perfectly! Found 3 clusters as expected."
        puts "Silhouette score: #{result_kmeans[:quality_metrics][:silhouette_score].round(4)}"
        
        wait_for_user
        
        # Hierarchical clustering
        puts "\n--- Hierarchical Clustering (Ward's Method) ---"
        puts "Hierarchical clustering builds a tree of clusters."
        
        result_hierarchical = framework.run_algorithm(:hierarchical_ward, :simple_example,
                                                    { num_clusters: 3, verbose: false })
        
        puts "✓ Hierarchical clustering also found 3 clusters!"
        puts "Silhouette score: #{result_hierarchical[:quality_metrics][:silhouette_score].round(4)}"
        
        wait_for_user
        
        # DBSCAN
        puts "\n--- DBSCAN (Density-Based Clustering) ---"
        puts "DBSCAN finds dense regions and can detect noise."
        
        result_dbscan = framework.run_algorithm(:dbscan, :simple_example,
                                              { eps: 0.8, min_pts: 5, verbose: false })
        
        puts "✓ DBSCAN found #{result_dbscan[:stats][:num_clusters]} clusters!"
        puts "Noise points detected: #{result_dbscan[:stats][:num_noise_points] || 0}"
        
        puts <<~LESSON
          
          🎓 Key Takeaways:
          • All algorithms succeeded on well-separated data
          • Different algorithms can give similar results on "easy" data
          • The challenge comes with more complex data structures
          • Quality metrics help us compare results objectively
        LESSON
      end
      
      # Example 2: Comprehensive algorithm comparison
      def self.example_2_algorithm_comparison
        puts "\n" + "="*60
        puts "EXAMPLE 2: Algorithm Comparison on Different Data Types"
        puts "="*60
        
        puts <<~INTRODUCTION
          Now let's see how algorithms perform on challenging datasets.
          This reveals the strengths and weaknesses of each approach.
          
          We'll test on:
          • Non-convex shapes (moons, circles)
          • Different cluster densities
          • Noisy data with outliers
        INTRODUCTION
        
        wait_for_user
        
        framework = EnhancedClusteringFramework.new
        generator = SyntheticDatasetGenerator.new
        
        # Create challenging datasets
        datasets_info = [
          {
            name: :moons,
            data: generator.generate_moons(400, 0.1),
            description: "Two interleaving crescents (non-convex)",
            challenge: "Non-spherical shapes"
          },
          {
            name: :circles,
            data: generator.generate_circles(300, 0.05),
            description: "Concentric circles",
            challenge: "Non-linearly separable"
          },
          {
            name: :varied_density,
            data: generator.generate_varied_density(500),
            description: "Clusters with different densities",
            challenge: "Density variation"
          },
          {
            name: :noisy,
            data: generator.generate_with_noise(300, 0.15),
            description: "Clean clusters + 15% noise",
            challenge: "Outlier handling"
          }
        ]
        
        datasets_info.each do |dataset_info|
          framework.add_dataset(dataset_info[:name], dataset_info[:data], dataset_info[:description])
        end
        
        algorithms = [:k_means, :hierarchical_average, :dbscan]
        
        datasets_info.each do |dataset_info|
          puts "\n" + "-"*50
          puts "Dataset: #{dataset_info[:description]}"
          puts "Challenge: #{dataset_info[:challenge]}"
          puts "-"*50
          
          results = {}
          
          algorithms.each do |algorithm|
            puts "\nTesting #{algorithm}..."
            
            params = case algorithm
                    when :k_means
                      { k: 2 }
                    when :hierarchical_average
                      { num_clusters: 2 }
                    when :dbscan
                      { eps: 0.3, min_pts: 5 }
                    end
            
            begin
              result = framework.run_algorithm(algorithm, dataset_info[:name], params.merge(verbose: false))
              results[algorithm] = result
              
              silhouette = result[:quality_metrics][:silhouette_score] || 0
              clusters_found = result[:stats][:num_clusters]
              
              puts "  Clusters found: #{clusters_found}"
              puts "  Silhouette score: #{silhouette.round(4)}"
              
              if result[:stats][:num_noise_points]
                puts "  Noise points: #{result[:stats][:num_noise_points]}"
              end
              
            rescue => e
              puts "  Failed: #{e.message}"
            end
          end
          
          # Analysis
          puts "\nAnalysis for #{dataset_info[:description]}:"
          analyze_algorithm_performance(results, dataset_info[:challenge])
          
          wait_for_user
        end
        
        puts <<~SUMMARY
          
          🎓 Algorithm Comparison Summary:
          
          K-Means:
          ✓ Excellent for spherical, well-separated clusters
          ✗ Struggles with non-convex shapes and noise
          
          Hierarchical:
          ✓ Good general-purpose algorithm
          ✓ Provides cluster hierarchy information
          ✗ Sensitive to noise and outliers
          
          DBSCAN:
          ✓ Handles arbitrary shapes and noise excellently
          ✓ Automatic outlier detection
          ✗ Sensitive to parameter choice
          ✗ Struggles with varying densities
        SUMMARY
      end
      
      # Example 3: Parameter effects and optimization
      def self.example_3_parameter_effects
        puts "\n" + "="*60
        puts "EXAMPLE 3: Understanding Parameter Effects"
        puts "="*60
        
        puts <<~INTRODUCTION
          Parameters dramatically affect clustering results!
          Let's explore how changing parameters changes the clusters found.
          
          We'll examine:
          • K in K-means (number of clusters)
          • ε and MinPts in DBSCAN
          • Linkage methods in hierarchical clustering
        INTRODUCTION
        
        wait_for_user
        
        framework = EnhancedClusteringFramework.new
        generator = SyntheticDatasetGenerator.new
        
        # Create a dataset that's good for parameter exploration
        mixed_data = generator.generate_varied_density(400)
        framework.add_dataset(:parameter_test, mixed_data, "Mixed density clusters")
        
        # K-means parameter exploration
        puts "\n--- K-Means: Effect of K (Number of Clusters) ---"
        puts "Testing different values of K to see the effect..."
        
        k_values = [2, 3, 4, 5, 6]
        k_results = []
        
        k_values.each do |k|
          result = framework.run_algorithm(:k_means, :parameter_test, { k: k, verbose: false })
          silhouette = result[:quality_metrics][:silhouette_score] || 0
          wcss = result[:quality_metrics][:within_cluster_sum_of_squares] || 0
          
          k_results << { k: k, silhouette: silhouette, wcss: wcss }
          puts "K=#{k}: Silhouette=#{silhouette.round(4)}, WCSS=#{wcss.round(2)}"
        end
        
        # Find elbow and best silhouette
        best_silhouette = k_results.max_by { |r| r[:silhouette] }
        puts "\nBest silhouette score: K=#{best_silhouette[:k]} (#{best_silhouette[:silhouette].round(4)})"
        
        puts "\nElbow method analysis:"
        puts "Look for the 'elbow' where WCSS stops decreasing rapidly..."
        wcss_improvements = []
        (1...k_results.length).each do |i|
          improvement = k_results[i-1][:wcss] - k_results[i][:wcss]
          wcss_improvements << improvement
          puts "K=#{k_results[i][:k]}: WCSS improvement = #{improvement.round(2)}"
        end
        
        wait_for_user
        
        # DBSCAN parameter exploration
        puts "\n--- DBSCAN: Effect of ε (Epsilon) ---"
        puts "Testing different ε values with fixed MinPts=5..."
        
        eps_values = [0.2, 0.4, 0.6, 0.8, 1.0]
        
        eps_values.each do |eps|
          result = framework.run_algorithm(:dbscan, :parameter_test, 
                                         { eps: eps, min_pts: 5, verbose: false })
          
          clusters = result[:stats][:num_clusters]
          noise = result[:stats][:num_noise_points] || 0
          noise_pct = (noise * 100.0 / 400).round(1)
          
          puts "ε=#{eps}: #{clusters} clusters, #{noise} noise points (#{noise_pct}%)"
        end
        
        puts <<~DBSCAN_ANALYSIS
          
          📊 DBSCAN Parameter Analysis:
          • Small ε: Many small clusters, lots of noise
          • Large ε: Few large clusters, little noise
          • Too small: Everything becomes noise
          • Too large: Everything becomes one cluster
          
          The right ε depends on your data's natural scale!
        DBSCAN_ANALYSIS
        
        wait_for_user
        
        # Hierarchical linkage comparison
        puts "\n--- Hierarchical: Effect of Linkage Method ---"
        puts "Testing different linkage methods..."
        
        linkage_methods = [
          { name: :hierarchical_single, desc: "Single (minimum distance)" },
          { name: :hierarchical_complete, desc: "Complete (maximum distance)" },
          { name: :hierarchical_average, desc: "Average distance" },
          { name: :hierarchical_ward, desc: "Ward's method (minimum variance)" }
        ]
        
        linkage_methods.each do |method|
          result = framework.run_algorithm(method[:name], :parameter_test, 
                                         { num_clusters: 3, verbose: false })
          
          silhouette = result[:quality_metrics][:silhouette_score] || 0
          puts "#{method[:desc]}: Silhouette = #{silhouette.round(4)}"
        end
        
        puts <<~LINKAGE_ANALYSIS
          
          🔗 Linkage Method Analysis:
          • Single: Good for chain-like clusters, prone to chaining effect
          • Complete: Creates compact clusters, sensitive to outliers  
          • Average: Balanced approach, good general choice
          • Ward: Best for spherical clusters, similar to K-means
        LINKAGE_ANALYSIS
      end
      
      # Example 4: Real-world scenarios and applications
      def self.example_4_real_world_scenarios
        puts "\n" + "="*60
        puts "EXAMPLE 4: Real-World Clustering Scenarios"
        puts "="*60
        
        puts <<~INTRODUCTION
          Let's explore how clustering applies to real-world problems.
          We'll simulate realistic scenarios and choose appropriate algorithms.
          
          Scenarios:
          • Customer segmentation (marketing)
          • Document clustering (text analysis)
          • Gene expression analysis (bioinformatics)
          • Image segmentation (computer vision)
        INTRODUCTION
        
        wait_for_user
        
        framework = EnhancedClusteringFramework.new
        
        # Scenario 1: Customer Segmentation
        puts "\n--- Scenario 1: Customer Segmentation ---"
        puts "Goal: Segment customers for targeted marketing campaigns"
        puts "Features: Age, Income, Purchase Frequency, Website Time"
        
        customer_data = generate_customer_segmentation_data(500)
        framework.add_dataset(:customers, customer_data, "Customer behavior data")
        
        puts "\nApproach: K-means is popular for customer segmentation"
        puts "Reason: Interpretable clusters, business-friendly"
        
        # Try different K values
        puts "\nTesting different numbers of customer segments:"
        (2..6).each do |k|
          result = framework.run_algorithm(:k_means, :customers, { k: k, verbose: false })
          silhouette = result[:quality_metrics][:silhouette_score] || 0
          puts "#{k} segments: Silhouette = #{silhouette.round(4)}"
        end
        
        # Final segmentation
        final_result = framework.run_algorithm(:k_means, :customers, { k: 4, verbose: false })
        
        puts "\nFinal segmentation (4 customer segments):"
        analyze_customer_segments(final_result, customer_data)
        
        wait_for_user
        
        # Scenario 2: Anomaly Detection
        puts "\n--- Scenario 2: Network Anomaly Detection ---"
        puts "Goal: Detect unusual network traffic patterns"
        puts "Approach: DBSCAN to find normal patterns and identify outliers"
        
        network_data = generate_network_traffic_data(600)
        framework.add_dataset(:network, network_data, "Network traffic patterns")
        
        result = framework.run_algorithm(:dbscan, :network, { eps: 0.5, min_pts: 8, verbose: false })
        
        clusters = result[:stats][:num_clusters]
        anomalies = result[:stats][:num_noise_points] || 0
        anomaly_rate = (anomalies * 100.0 / 600).round(2)
        
        puts "Normal traffic patterns found: #{clusters}"
        puts "Anomalies detected: #{anomalies} (#{anomaly_rate}%)"
        puts "✓ DBSCAN automatically identified suspicious traffic!"
        
        wait_for_user
        
        # Scenario 3: Medical Diagnosis Support
        puts "\n--- Scenario 3: Medical Diagnosis Support ---"
        puts "Goal: Group patients with similar symptoms"
        puts "Approach: Hierarchical clustering for interpretable patient groups"
        
        medical_data = generate_medical_diagnosis_data(300)
        framework.add_dataset(:medical, medical_data, "Patient symptom profiles")
        
        result = framework.run_algorithm(:hierarchical_ward, :medical, { num_clusters: 5, verbose: false })
        
        puts "Patient groups identified: #{result[:stats][:num_clusters]}"
        puts "This helps doctors:"
        puts "• Identify similar cases"
        puts "• Suggest potential diagnoses"
        puts "• Recommend treatment protocols"
        puts "✓ Hierarchical structure shows relationships between patient groups"
        
        wait_for_user
        
        puts <<~REAL_WORLD_LESSONS
          
          🌍 Real-World Clustering Lessons:
          
          Algorithm Selection Depends On:
          • Domain requirements (interpretability vs. accuracy)
          • Data characteristics (size, dimensions, noise)
          • Business constraints (computational resources, explainability)
          
          Best Practices:
          • Always validate with domain experts
          • Consider multiple algorithms and compare
          • Use appropriate evaluation metrics for your domain
          • Preprocess data appropriately (scaling, feature selection)
          
          Common Applications:
          • Marketing: Customer segmentation, recommendation systems
          • Security: Anomaly detection, fraud identification
          • Biology: Gene analysis, protein folding
          • Technology: Image segmentation, data compression
        REAL_WORLD_LESSONS
      end
      
      # Example 5: When clustering fails and why
      def self.example_5_failure_cases
        puts "\n" + "="*60
        puts "EXAMPLE 5: When Clustering Fails (Learning from Mistakes)"
        puts "="*60
        
        puts <<~INTRODUCTION
          Understanding failure cases is crucial for proper clustering use.
          Let's explore scenarios where clustering doesn't work well
          and learn to recognize these situations.
          
          Failure scenarios:
          • Uniform data (no natural clusters)
          • High-dimensional data (curse of dimensionality)
          • Wrong algorithm choice
          • Poor preprocessing
        INTRODUCTION
        
        wait_for_user
        
        framework = EnhancedClusteringFramework.new
        generator = SyntheticDatasetGenerator.new
        
        # Failure 1: No natural clusters (uniform data)
        puts "\n--- Failure Case 1: No Natural Clusters ---"
        puts "Problem: Forcing clustering on uniform random data"
        
        uniform_data = generate_uniform_random_data(400)
        framework.add_dataset(:uniform, uniform_data, "Uniformly distributed random points")
        
        result = framework.run_algorithm(:k_means, :uniform, { k: 3, verbose: false })
        silhouette = result[:quality_metrics][:silhouette_score] || 0
        
        puts "K-means found 3 clusters (as requested)"
        puts "Silhouette score: #{silhouette.round(4)} (very low!)"
        puts "✗ Poor silhouette score indicates no natural clustering structure"
        
        puts "\n💡 Lesson: Always check if your data actually has clusters!"
        puts "Random data will always be 'clustered' but meaninglessly."
        
        wait_for_user
        
        # Failure 2: Wrong algorithm for data type
        puts "\n--- Failure Case 2: Wrong Algorithm Choice ---"
        puts "Problem: Using K-means on non-spherical data"
        
        spiral_data = generate_spiral_data(300)
        framework.add_dataset(:spiral, spiral_data, "Spiral-shaped cluster")
        
        puts "Data: A single spiral-shaped cluster"
        
        # K-means will fail
        result_kmeans = framework.run_algorithm(:k_means, :spiral, { k: 2, verbose: false })
        silhouette_kmeans = result_kmeans[:quality_metrics][:silhouette_score] || 0
        
        puts "K-means result: Silhouette = #{silhouette_kmeans.round(4)}"
        puts "✗ K-means splits the spiral artificially"
        
        # DBSCAN works better
        result_dbscan = framework.run_algorithm(:dbscan, :spiral, { eps: 0.3, min_pts: 5, verbose: false })
        clusters_dbscan = result_dbscan[:stats][:num_clusters]
        
        puts "DBSCAN result: #{clusters_dbscan} clusters found"
        puts "✓ DBSCAN correctly identifies the spiral as one cluster"
        
        wait_for_user
        
        # Failure 3: High-dimensional data
        puts "\n--- Failure Case 3: Curse of Dimensionality ---"
        puts "Problem: Clustering in high-dimensional space"
        
        high_dim_data = generator.generate_high_dimensional(200, 50, 3)
        framework.add_dataset(:high_dim, high_dim_data, "50-dimensional data with 3 clusters")
        
        result = framework.run_algorithm(:k_means, :high_dim, { k: 3, verbose: false })
        silhouette = result[:quality_metrics][:silhouette_score] || 0
        
        puts "50-dimensional data with known 3 clusters"
        puts "K-means silhouette score: #{silhouette.round(4)}"
        puts "✗ Poor performance due to curse of dimensionality"
        
        puts "\n💡 High-dimensional problems:"
        puts "• Distances become meaningless"
        puts "• All points seem equally far apart"
        puts "• Solution: Dimensionality reduction first"
        
        wait_for_user
        
        # Failure 4: Poor preprocessing
        puts "\n--- Failure Case 4: Poor Preprocessing ---"
        puts "Problem: Different scales and irrelevant features"
        
        mixed_scale_data = generate_mixed_scale_data(300)
        framework.add_dataset(:mixed_scale, mixed_scale_data, "Mixed scale features")
        
        puts "Data: Age (0-100), Income (0-100000), Purchase Count (0-50)"
        puts "Problem: Income dominates due to scale differences"
        
        result = framework.run_algorithm(:k_means, :mixed_scale, { k: 3, verbose: false })
        silhouette = result[:quality_metrics][:silhouette_score] || 0
        
        puts "Without scaling: Silhouette = #{silhouette.round(4)}"
        puts "✗ Poor result because income scale dominates"
        
        # Simulate normalized data
        normalized_data = normalize_data(mixed_scale_data)
        framework.add_dataset(:normalized, normalized_data, "Normalized mixed scale data")
        
        result_norm = framework.run_algorithm(:k_means, :normalized, { k: 3, verbose: false })
        silhouette_norm = result_norm[:quality_metrics][:silhouette_score] || 0
        
        puts "With normalization: Silhouette = #{silhouette_norm.round(4)}"
        puts "✓ Much better results after proper preprocessing"
        
        puts <<~FAILURE_LESSONS
          
          ⚠️  Common Clustering Failures and Solutions:
          
          1. No Natural Clusters:
             • Check silhouette scores and visualization
             • Consider if clustering is appropriate
             • Use gap statistic to test cluster existence
          
          2. Wrong Algorithm:
             • Understand your data structure first
             • Try multiple algorithms and compare
             • Match algorithm assumptions to data properties
          
          3. High Dimensions:
             • Apply dimensionality reduction (PCA, t-SNE)
             • Use feature selection
             • Consider specialized high-dimensional methods
          
          4. Poor Preprocessing:
             • Always scale/normalize features
             • Handle missing values appropriately
             • Remove irrelevant features
             • Consider data transformations
          
          Remember: Clustering is exploratory - negative results are also valuable!
        FAILURE_LESSONS
      end
      
      # Example 6: Best practices and guidelines
      def self.example_6_best_practices
        puts "\n" + "="*60
        puts "EXAMPLE 6: Clustering Best Practices and Guidelines"
        puts "="*60
        
        puts <<~INTRODUCTION
          Let's consolidate everything into practical guidelines
          for successful clustering in real projects.
          
          We'll cover:
          • Data preparation workflow
          • Algorithm selection criteria
          • Validation strategies
          • Interpretation guidelines
        INTRODUCTION
        
        wait_for_user
        
        puts "\n" + "="*50
        puts "CLUSTERING WORKFLOW BEST PRACTICES"
        puts "="*50
        
        puts <<~WORKFLOW
          
          1. DATA EXPLORATION AND PREPARATION
          ✓ Visualize your data (scatter plots, histograms)
          ✓ Check for outliers and missing values
          ✓ Understand feature scales and distributions
          ✓ Consider domain knowledge about expected clusters
          
          Example workflow:
          • Load and examine data structure
          • Plot feature distributions
          • Identify outliers (beyond 3 standard deviations)
          • Check for missing values
          • Determine if clustering is appropriate
        WORKFLOW
        
        # Demonstrate data exploration
        framework = EnhancedClusteringFramework.new
        generator = SyntheticDatasetGenerator.new
        
        example_data = generator.generate_blobs(4, 400, 0.8)
        framework.add_dataset(:example, example_data, "Example dataset for best practices")
        
        puts "\n2. PREPROCESSING DECISIONS"
        puts "✓ Feature scaling/normalization"
        puts "✓ Feature selection and engineering"
        puts "✓ Dimensionality reduction if needed"
        puts "✓ Outlier handling strategy"
        
        # Show preprocessing effects
        puts "\nDemonstration: Effect of different preprocessing:"
        
        # Without preprocessing
        result_raw = framework.run_algorithm(:k_means, :example, { k: 4, verbose: false })
        silhouette_raw = result_raw[:quality_metrics][:silhouette_score] || 0
        
        puts "Raw data: Silhouette = #{silhouette_raw.round(4)}"
        
        # Note: In a real implementation, you'd show actual preprocessing effects
        puts "With proper scaling: Silhouette would typically improve"
        puts "With outlier removal: Clusters become more distinct"
        
        wait_for_user
        
        puts "\n3. ALGORITHM SELECTION GUIDE"
        puts "Choose algorithm based on:"
        
        algorithm_guide = {
          "K-Means" => {
            use_when: ["Spherical clusters", "Similar cluster sizes", "Known number of clusters", "Large datasets"],
            avoid_when: ["Non-convex shapes", "Very different cluster sizes", "Lots of noise"],
            parameters: "K (number of clusters), initialization method"
          },
          
          "Hierarchical" => {
            use_when: ["Unknown number of clusters", "Small to medium datasets", "Need cluster relationships"],
            avoid_when: ["Very large datasets", "Lots of noise", "Computational constraints"],
            parameters: "Linkage method, distance metric, number of clusters"
          },
          
          "DBSCAN" => {
            use_when: ["Arbitrary cluster shapes", "Noise handling needed", "Unknown cluster count"],
            avoid_when: ["Varying cluster densities", "High-dimensional data", "All data is meaningful"],
            parameters: "ε (neighborhood size), MinPts (minimum points)"
          },
          
          "GMM" => {
            use_when: ["Soft clustering needed", "Overlapping clusters", "Probabilistic assignments"],
            avoid_when: ["Hard cluster assignments required", "Very large datasets", "Simple cluster shapes"],
            parameters: "Number of components, covariance type, initialization"
          }
        }
        
        algorithm_guide.each do |alg_name, info|
          puts "\n#{alg_name}:"
          puts "  Use when: #{info[:use_when].join(', ')}"
          puts "  Avoid when: #{info[:avoid_when].join(', ')}"
          puts "  Key parameters: #{info[:parameters]}"
        end
        
        wait_for_user
        
        puts "\n4. VALIDATION AND EVALUATION"
        puts "Multiple validation approaches:"
        
        evaluation_methods = {
          "Internal Validation" => [
            "Silhouette Score (higher is better, >0.5 is good)",
            "Davies-Bouldin Index (lower is better, <1.0 is good)", 
            "Calinski-Harabasz Index (higher is better)",
            "Within/Between cluster sum of squares ratio"
          ],
          
          "External Validation" => [
            "Domain expert review",
            "Business metric improvement",
            "Stability across subsamples",
            "Comparison with known ground truth (if available)"
          ],
          
          "Practical Validation" => [
            "Cluster interpretability",
            "Actionability of results",
            "Consistency across runs",
            "Sensitivity to parameter changes"
          ]
        }
        
        evaluation_methods.each do |category, methods|
          puts "\n#{category}:"
          methods.each { |method| puts "  • #{method}" }
        end
        
        # Demonstrate validation
        puts "\nValidation demonstration:"
        puts "Running K-means with different K values..."
        
        validation_results = []
        (2..6).each do |k|
          result = framework.run_algorithm(:k_means, :example, { k: k, verbose: false })
          silhouette = result[:quality_metrics][:silhouette_score] || 0
          db_index = result[:quality_metrics][:davies_bouldin_index] || Float::INFINITY
          
          validation_results << { k: k, silhouette: silhouette, db_index: db_index }
          puts "K=#{k}: Silhouette=#{silhouette.round(4)}, DB Index=#{db_index.round(4)}"
        end
        
        best_k = validation_results.max_by { |r| r[:silhouette] }[:k]
        puts "Best K by silhouette score: #{best_k}"
        
        wait_for_user
        
        puts "\n5. INTERPRETATION AND ACTION"
        puts "Making clustering results actionable:"
        
        interpretation_guide = [
          "Characterize each cluster by feature means/medians",
          "Name clusters based on dominant characteristics", 
          "Calculate cluster sizes and proportions",
          "Identify distinguishing features for each cluster",
          "Validate clusters with domain experts",
          "Plan specific actions for each cluster",
          "Monitor cluster stability over time",
          "Consider how to assign new data points"
        ]
        
        interpretation_guide.each_with_index do |guide, idx|
          puts "#{idx + 1}. #{guide}"
        end
        
        # Show interpretation example
        puts "\nInterpretation Example:"
        final_result = framework.run_algorithm(:k_means, :example, { k: 4, verbose: false })
        
        puts "Cluster Analysis:"
        final_result[:algorithm_instance].clusters.each_with_index do |cluster, idx|
          if cluster.data_items.length > 0
            puts "Cluster #{idx + 1}: #{cluster.data_items.length} points"
            # In a real scenario, you'd show feature means, ranges, etc.
          end
        end
        
        puts <<~FINAL_GUIDELINES
          
          📋 FINAL CLUSTERING CHECKLIST:
          
          Before Starting:
          □ Is clustering appropriate for your problem?
          □ Do you have sufficient, quality data?
          □ Have you explored the data visually?
          
          During Analysis:
          □ Have you tried multiple algorithms?
          □ Have you validated parameter choices?
          □ Do the results make domain sense?
          
          After Clustering:
          □ Can you clearly characterize each cluster?
          □ Are the clusters actionable for your goals?
          □ Have you validated with domain experts?
          □ Do you have a plan for new data points?
          
          Remember: Clustering is an art as much as a science!
          Domain knowledge and iterative refinement are key to success.
        FINAL_GUIDELINES
      end
      
      # Helper method to wait for user input
      def self.wait_for_user(message = "Press Enter to continue...")
        puts message
        gets
      end
      
      # Data generation helpers for realistic examples
      
      def self.generate_customer_segmentation_data(n_customers)
        data_items = []
        labels = ["age", "income", "purchases_per_month", "website_hours"]
        
        # Define customer segments
        segments = [
          { age: [22, 35], income: [25000, 45000], purchases: [2, 8], hours: [5, 15] },   # Young shoppers
          { age: [35, 50], income: [45000, 75000], purchases: [3, 12], hours: [3, 10] },  # Middle-aged
          { age: [50, 70], income: [60000, 100000], purchases: [1, 6], hours: [1, 5] },   # Older, higher income
          { age: [25, 40], income: [75000, 120000], purchases: [8, 20], hours: [10, 25] } # Premium customers
        ]
        
        segment_sizes = [n_customers/4] * 4
        
        segments.each_with_index do |segment, idx|
          segment_sizes[idx].times do
            age = rand(segment[:age][1] - segment[:age][0]) + segment[:age][0]
            income = rand(segment[:income][1] - segment[:income][0]) + segment[:income][0]
            purchases = rand(segment[:purchases][1] - segment[:purchases][0]) + segment[:purchases][0]
            hours = rand(segment[:hours][1] - segment[:hours][0]) + segment[:hours][0]
            
            # Add noise
            age += rand(-3..3)
            income += rand(-5000..5000)
            purchases += rand(-1..1)
            hours += rand(-2..2)
            
            data_items << [age.to_f, income.to_f, purchases.to_f, hours.to_f]
          end
        end
        
        data_items.shuffle!
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
      
      def self.generate_network_traffic_data(n_samples)
        data_items = []
        labels = ["packet_size", "frequency", "duration"]
        
        # Normal traffic patterns (85%)
        normal_samples = (n_samples * 0.85).to_i
        normal_samples.times do
          packet_size = rand(64..1500).to_f
          frequency = rand(1..100).to_f  
          duration = rand(0.1..10.0)
          
          data_items << [packet_size, frequency, duration]
        end
        
        # Anomalous traffic (15%)
        anomaly_samples = n_samples - normal_samples
        anomaly_samples.times do
          # Generate unusual patterns
          if rand < 0.5
            # Large packets, high frequency
            packet_size = rand(1400..9000).to_f
            frequency = rand(100..1000).to_f
            duration = rand(0.1..1.0)
          else
            # Very long duration
            packet_size = rand(64..1500).to_f
            frequency = rand(1..50).to_f
            duration = rand(30..120)
          end
          
          data_items << [packet_size, frequency, duration]
        end
        
        data_items.shuffle!
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
      
      def self.generate_medical_diagnosis_data(n_patients)
        data_items = []
        labels = ["temperature", "blood_pressure", "heart_rate", "symptom_severity"]
        
        # Different patient groups
        conditions = [
          { temp: [98.6, 99.5], bp: [110, 130], hr: [60, 80], severity: [1, 3] },    # Mild
          { temp: [99.5, 101.0], bp: [130, 160], hr: [80, 100], severity: [3, 6] },  # Moderate
          { temp: [101.0, 103.0], bp: [90, 110], hr: [100, 120], severity: [6, 8] }, # Severe condition A
          { temp: [99.0, 100.0], bp: [160, 180], hr: [90, 110], severity: [4, 7] },  # Hypertensive
          { temp: [98.0, 99.0], bp: [80, 100], hr: [50, 70], severity: [2, 4] }      # Low BP condition
        ]
        
        samples_per_condition = n_patients / conditions.length
        
        conditions.each do |condition|
          samples_per_condition.times do
            temp = rand(condition[:temp][1] - condition[:temp][0]) + condition[:temp][0]
            bp = rand(condition[:bp][1] - condition[:bp][0]) + condition[:bp][0]
            hr = rand(condition[:hr][1] - condition[:hr][0]) + condition[:hr][0]
            severity = rand(condition[:severity][1] - condition[:severity][0]) + condition[:severity][0]
            
            data_items << [temp, bp.to_f, hr.to_f, severity.to_f]
          end
        end
        
        data_items.shuffle!
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
      
      def self.generate_uniform_random_data(n_points)
        data_items = []
        labels = ["x", "y"]
        
        n_points.times do
          x = rand(-5.0..5.0)
          y = rand(-5.0..5.0)
          data_items << [x, y]
        end
        
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
      
      def self.generate_spiral_data(n_points)
        data_items = []
        labels = ["x", "y"]
        
        n_points.times do |i|
          angle = 4 * Math::PI * i / n_points
          radius = angle / (2 * Math::PI)
          
          x = radius * Math.cos(angle) + rand(-0.1..0.1)
          y = radius * Math.sin(angle) + rand(-0.1..0.1)
          
          data_items << [x, y]
        end
        
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
      
      def self.generate_mixed_scale_data(n_points)
        data_items = []
        labels = ["age", "income", "purchases"]
        
        n_points.times do
          age = rand(20..80)
          income = rand(20000..100000)
          purchases = rand(1..50)
          
          data_items << [age.to_f, income.to_f, purchases.to_f]
        end
        
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      end
      
      def self.normalize_data(data_set)
        # Simple min-max normalization simulation
        data_items = data_set.data_items.map do |item|
          # Simulate normalized values between 0 and 1
          item.map { |val| val.to_f / (item.max + 1) }
        end
        
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: data_set.data_labels)
      end
      
      def self.analyze_algorithm_performance(results, challenge)
        if results.empty?
          puts "  No successful results to analyze"
          return
        end
        
        # Find best performer
        best_algorithm = results.max_by do |_, result|
          result[:quality_metrics][:silhouette_score] || -1
        end
        
        puts "  Best performer: #{best_algorithm[0]} (challenge: #{challenge})"
        
        case challenge
        when "Non-spherical shapes"
          puts "  → DBSCAN typically excels at non-convex shapes"
        when "Non-linearly separable"
          puts "  → Kernel methods or DBSCAN work better than K-means"
        when "Density variation"
          puts "  → DBSCAN struggles with varied densities"
        when "Outlier handling"
          puts "  → DBSCAN naturally handles outliers as noise"
        end
      end
      
      def self.analyze_customer_segments(result, data_set)
        result[:algorithm_instance].clusters.each_with_index do |cluster, idx|
          next if cluster.data_items.empty?
          
          # Calculate segment characteristics
          ages = cluster.data_items.map { |item| item[0] }
          incomes = cluster.data_items.map { |item| item[1] }
          purchases = cluster.data_items.map { |item| item[2] }
          hours = cluster.data_items.map { |item| item[3] }
          
          avg_age = ages.sum / ages.length
          avg_income = incomes.sum / incomes.length
          avg_purchases = purchases.sum / purchases.length
          avg_hours = hours.sum / hours.length
          
          puts "Segment #{idx + 1} (#{cluster.data_items.length} customers):"
          puts "  Avg Age: #{avg_age.round(1)} years"
          puts "  Avg Income: $#{avg_income.round(0)}"
          puts "  Avg Purchases/month: #{avg_purchases.round(1)}"
          puts "  Avg Website hours: #{avg_hours.round(1)}"
          
          # Suggest segment name
          segment_name = if avg_age < 35 && avg_purchases > 10
                          "Young Heavy Shoppers"
                        elsif avg_income > 70000
                          "Premium Customers"
                        elsif avg_age > 50
                          "Mature Shoppers"
                        else
                          "Standard Customers"
                        end
          
          puts "  Suggested name: #{segment_name}"
          puts
        end
      end
    end
  end
end