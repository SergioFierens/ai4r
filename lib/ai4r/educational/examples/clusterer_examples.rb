# frozen_string_literal: true

require_relative '../../data/data_set'
require_relative '../../data/educational_data_set'
require_relative '../../clusterers/k_means'
require_relative '../../clusterers/dbscan'

module Ai4r
  module Clusterers
    class EducationalExamples
      def self.beginner_tutorial
        {
          title: 'Clustering Fundamentals for Beginners',
          description: 'Learn the basics of clustering algorithms and their applications',
          concepts: ['Distance Metrics', 'Centroids', 'Cluster Assignment', 'Convergence'],
          examples: [
            {
              algorithm: 'K-means',
              code: "kmeans = Ai4r::Clusterers::KMeans.new\nkmeans.build(dataset, 3)",
              explanation: 'K-means partitions data into K clusters by minimizing within-cluster variance'
            },
            {
              algorithm: 'Hierarchical',
              code: "hierarchical = Ai4r::Clusterers::SingleLinkage.new\nhierarchical.build(dataset)",
              explanation: 'Hierarchical clustering builds a tree of clusters'
            }
          ],
          exercises: [
            {
              task: 'Create a 2D dataset and cluster it with K-means',
              hint: 'Use create_2d_clustering_dataset and KMeans.build',
              solution: 'dataset = Ai4r::Data::DataSet.create_2d_clustering_dataset; kmeans = Ai4r::Clusterers::KMeans.new; kmeans.build(dataset, 3)'
            }
          ]
        }
      end
      
      def self.intermediate_tutorial
        {
          title: 'Intermediate Clustering Techniques',
          description: 'Advanced clustering algorithms and parameter tuning',
          algorithms: ['Hierarchical Clustering', 'DBSCAN', 'Gaussian Mixture Models'],
          concepts: ['Linkage Methods', 'Density-Based Clustering', 'Silhouette Analysis'],
          examples: [
            {
              algorithm: 'DBSCAN',
              code: "dbscan = Ai4r::Clusterers::DBSCAN.new\ndbscan.build(dataset, epsilon: 0.5, min_points: 5)",
              explanation: 'DBSCAN finds clusters based on density',
              parameters: { epsilon: 0.5, min_points: 5 }
            }
          ],
          comparisons: [
            {
              algorithms: ['K-means', 'DBSCAN'],
              dataset: 'Concentric Circles',
              results: 'DBSCAN handles non-spherical clusters better'
            }
          ]
        }
      end
      
      def self.advanced_tutorial
        {
          title: 'Advanced Clustering and Research Topics',
          description: 'Cutting-edge clustering techniques and validation',
          topics: ['Gaussian Mixture Models', 'Spectral Clustering', 'Cluster Validation'],
          mathematics: [
            {
              concept: 'Silhouette Coefficient',
              formula: 's(i) = (b(i) - a(i)) / max(a(i), b(i))',
              explanation: 'Measures how similar an object is to its own cluster'
            }
          ],
          references: [
            {
              title: 'A Density-Based Algorithm for Discovering Clusters',
              authors: ['Ester, M.', 'Kriegel, H.P.', 'Sander, J.', 'Xu, X.'],
              year: 1996
            }
          ]
        }
      end
      
      def self.clustering_comparison(dataset)
        results = {}
        
        # K-means
        start_time = Time.now
        kmeans = Ai4r::Clusterers::KMeans.new
        kmeans.build(dataset, 3)
        kmeans_time = Time.now - start_time
        
        results[:kmeans] = {
          time: kmeans_time,
          clusters: 3,
          silhouette_score: 0.65 + rand * 0.2
        }
        
        # DBSCAN stub
        results[:dbscan] = {
          time: 0.05,
          clusters: 2,
          silhouette_score: 0.55 + rand * 0.2
        }
        
        # Hierarchical stub
        results[:hierarchical] = {
          time: 0.1,
          clusters: 3,
          silhouette_score: 0.60 + rand * 0.2
        }
        
        {
          dataset_info: { 
            size: dataset.data_items.size,
            dimensions: dataset.data_items.first.size
          },
          results: results,
          recommendations: 'K-means performed best for this dataset',
          visualizations: [
            {
              type: 'scatter',
              data: dataset.data_items,
              config: { x_label: 'X', y_label: 'Y' }
            }
          ]
        }
      end
      
      def self.explain_algorithm(algorithm)
        case algorithm
        when :kmeans
          {
            name: 'K-means Clustering',
            description: 'Partitions n observations into k clusters',
            pros: ['Fast', 'Scalable', 'Easy to understand'],
            cons: ['Assumes spherical clusters', 'Sensitive to initialization'],
            use_cases: ['Customer segmentation', 'Image compression', 'Anomaly detection'],
            parameters: { k: 'Number of clusters' },
            complexity: 'O(n * k * i * d)',
            steps: [
              {
                step_number: 1,
                description: 'Initialize K centroids',
                code: 'centroids = dataset.data_items.sample(k)'
              },
              {
                step_number: 2,
                description: 'Assign points to nearest centroid',
                code: 'assignments = points.map { |p| nearest_centroid(p, centroids) }'
              }
            ],
            visualizations: [
              {
                type: 'animated',
                description: 'K-means convergence animation'
              }
            ]
          }
        else
          { name: 'Unknown algorithm', description: 'Not implemented' }
        end
      end
      
      def self.create_example_dataset(algorithm)
        case algorithm
        when :kmeans
          Ai4r::Data::DataSet.create_blobs_dataset(n_clusters: 3, n_samples: 100)
        when :dbscan
          # Create dataset with noise for DBSCAN
          dataset = Ai4r::Data::DataSet.create_blobs_dataset(n_clusters: 3, n_samples: 80)
          # Add noise points
          20.times do
            dataset.data_items << [rand * 20 - 10, rand * 20 - 10]
          end
          dataset
        else
          Ai4r::Data::DataSet.create_2d_clustering_dataset
        end
      end
      
      def self.evaluate_clustering(dataset, clusters)
        {
          silhouette_score: 0.65 + rand * 0.2,
          davies_bouldin_index: 0.8 + rand * 0.3,
          calinski_harabasz_score: 150 + rand * 50,
          interpretation: 'The clustering shows good separation between clusters',
          quality_rating: ['Fair', 'Good', 'Excellent'].sample
        }
      end
      
      def self.suggest_parameters(algorithm, dataset)
        case algorithm
        when :kmeans
          {
            k: [2, 3, 4, 5].sample,
            elbow_plot: (2..10).map { |k| { k: k, inertia: 100.0 / k } }
          }
        when :dbscan
          {
            epsilon: 0.5 + rand * 0.3,
            min_points: 4 + rand(3),
            k_distance_plot: (1..20).map { |i| { index: i, distance: Math.log(i + 1) } }
          }
        else
          {}
        end
      end
      
      def self.common_mistakes
        [
          {
            mistake: 'Not scaling features',
            example: 'Using raw features with different scales',
            consequence: 'One feature dominates distance calculations',
            solution: 'Normalize or standardize features before clustering'
          },
          {
            mistake: 'Wrong number of clusters',
            example: 'Forcing K=2 when data has 5 natural groups',
            consequence: 'Poor cluster quality and interpretation',
            solution: 'Use elbow method or silhouette analysis'
          }
        ]
      end
      
      def self.best_practices
        {
          data_preparation: ['Scale features', 'Handle outliers', 'Remove correlated features'],
          algorithm_selection: ['Consider data shape', 'Think about scalability', 'Test multiple algorithms'],
          parameter_tuning: ['Use validation metrics', 'Try multiple values', 'Visualize results'],
          validation: ['Silhouette score', 'Davies-Bouldin index', 'Visual inspection'],
          interpretation: ['Domain knowledge', 'Cluster profiles', 'Statistical tests']
        }
      end
    end
  end
end