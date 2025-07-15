# frozen_string_literal: true

# Comprehensive Clustering Quality Evaluation
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Clusterers
    
    # Comprehensive clustering quality evaluation with educational explanations
    class ClusteringQualityEvaluator
      
      def initialize(data_set, clusters, distance_function = nil)
        @data_set = data_set
        @clusters = clusters
        @distance_function = distance_function || default_distance_function
      end
      
      # Evaluate all quality metrics with educational explanations
      def evaluate_all_metrics
        metrics = {
          silhouette_score: calculate_silhouette_score,
          within_cluster_sum_of_squares: calculate_wcss,
          between_cluster_sum_of_squares: calculate_bcss,
          davies_bouldin_index: calculate_davies_bouldin_index,
          calinski_harabasz_index: calculate_calinski_harabasz_index,
          dunn_index: calculate_dunn_index,
          cluster_statistics: calculate_cluster_statistics
        }
        
        metrics[:total_sum_of_squares] = metrics[:within_cluster_sum_of_squares] + 
                                        metrics[:between_cluster_sum_of_squares]
        
        metrics[:variance_ratio] = metrics[:between_cluster_sum_of_squares] > 0 ? 
                                  metrics[:between_cluster_sum_of_squares] / metrics[:total_sum_of_squares] : 0
        
        metrics
      end
      
      # Generate educational report explaining metrics
      def generate_educational_report(metrics = nil)
        metrics ||= evaluate_all_metrics
        
        report = []
        report << "=== Clustering Quality Evaluation Report ==="
        report << ""
        report << "Dataset: #{@data_set.data_items.length} points, #{@clusters.length} clusters"
        report << ""
        
        # Silhouette Score
        report << "Silhouette Score: #{metrics[:silhouette_score]&.round(4) || 'N/A'}"
        report << explain_silhouette_score(metrics[:silhouette_score])
        report << ""
        
        # Within-Cluster Sum of Squares (WCSS)
        report << "Within-Cluster Sum of Squares (WCSS): #{metrics[:within_cluster_sum_of_squares]&.round(2) || 'N/A'}"
        report << explain_wcss(metrics[:within_cluster_sum_of_squares])
        report << ""
        
        # Between-Cluster Sum of Squares (BCSS)
        report << "Between-Cluster Sum of Squares (BCSS): #{metrics[:between_cluster_sum_of_squares]&.round(2) || 'N/A'}"
        report << explain_bcss(metrics[:between_cluster_sum_of_squares])
        report << ""
        
        # Variance Ratio
        report << "Variance Ratio (BCSS/TSS): #{metrics[:variance_ratio]&.round(4) || 'N/A'}"
        report << explain_variance_ratio(metrics[:variance_ratio])
        report << ""
        
        # Davies-Bouldin Index
        report << "Davies-Bouldin Index: #{metrics[:davies_bouldin_index]&.round(4) || 'N/A'}"
        report << explain_davies_bouldin(metrics[:davies_bouldin_index])
        report << ""
        
        # Calinski-Harabasz Index
        report << "Calinski-Harabasz Index: #{metrics[:calinski_harabasz_index]&.round(2) || 'N/A'}"
        report << explain_calinski_harabasz(metrics[:calinski_harabasz_index])
        report << ""
        
        # Dunn Index
        report << "Dunn Index: #{metrics[:dunn_index]&.round(4) || 'N/A'}"
        report << explain_dunn_index(metrics[:dunn_index])
        report << ""
        
        # Cluster Statistics
        report << "Cluster Statistics:"
        metrics[:cluster_statistics].each_with_index do |stats, idx|
          report << "  Cluster #{idx}: #{stats[:size]} points, diameter: #{stats[:diameter]&.round(3)}"
        end
        report << ""
        
        # Overall Assessment
        report << generate_overall_assessment(metrics)
        
        report.join("\n")
      end
      
      # Compare multiple clustering results
      def self.compare_clusterings(evaluations)
        puts "=== Clustering Results Comparison ==="
        puts
        
        # Create comparison table
        metrics = evaluations.first[:metrics].keys.select { |k| k != :cluster_statistics }
        
        printf("%-25s", "Algorithm")
        metrics.each { |metric| printf(" | %15s", metric.to_s[0..14]) }
        puts
        puts "-" * (25 + metrics.length * 18)
        
        evaluations.each do |eval_result|
          printf("%-25s", eval_result[:algorithm].to_s)
          metrics.each do |metric|
            value = eval_result[:metrics][metric]
            if value.is_a?(Numeric)
              printf(" | %15.4f", value)
            else
              printf(" | %15s", "N/A")
            end
          end
          puts
        end
        
        puts
        generate_comparison_insights(evaluations)
      end
      
      private
      
      def default_distance_function
        lambda do |a, b|
          numeric_a = a.select { |attr| attr.is_a?(Numeric) }
          numeric_b = b.select { |attr| attr.is_a?(Numeric) }
          sum = numeric_a.zip(numeric_b).sum { |x, y| (x - y) ** 2 }
          Math.sqrt(sum)
        end
      end
      
      # Silhouette Score: measures how well points fit their clusters
      def calculate_silhouette_score
        return 0 if @clusters.length < 2
        
        total_silhouette = 0
        total_points = 0
        
        @clusters.each_with_index do |cluster, cluster_index|
          cluster.data_items.each do |point|
            a = average_intra_cluster_distance(point, cluster)
            b = min_inter_cluster_distance(point, cluster_index)
            
            silhouette = b == 0 ? 0 : (b - a) / [a, b].max
            total_silhouette += silhouette
            total_points += 1
          end
        end
        
        total_points > 0 ? total_silhouette / total_points : 0
      end
      
      # Within-Cluster Sum of Squares: measures cluster compactness
      def calculate_wcss
        @clusters.sum do |cluster|
          next 0 if cluster.data_items.empty?
          
          centroid = calculate_centroid(cluster)
          cluster.data_items.sum do |point|
            @distance_function.call(point, centroid) ** 2
          end
        end
      end
      
      # Between-Cluster Sum of Squares: measures cluster separation
      def calculate_bcss
        return 0 if @clusters.empty?
        
        overall_centroid = calculate_overall_centroid
        
        @clusters.sum do |cluster|
          next 0 if cluster.data_items.empty?
          
          cluster_centroid = calculate_centroid(cluster)
          cluster.data_items.length * (@distance_function.call(cluster_centroid, overall_centroid) ** 2)
        end
      end
      
      # Davies-Bouldin Index: ratio of within-cluster to between-cluster distances
      def calculate_davies_bouldin_index
        return 0 if @clusters.length < 2
        
        cluster_dispersions = @clusters.map { |cluster| calculate_cluster_dispersion(cluster) }
        
        total_db = 0
        @clusters.each_with_index do |cluster_i, i|
          max_ratio = 0
          @clusters.each_with_index do |cluster_j, j|
            next if i == j
            
            centroid_i = calculate_centroid(cluster_i)
            centroid_j = calculate_centroid(cluster_j)
            centroid_distance = @distance_function.call(centroid_i, centroid_j)
            
            ratio = centroid_distance > 0 ? (cluster_dispersions[i] + cluster_dispersions[j]) / centroid_distance : 0
            max_ratio = [max_ratio, ratio].max
          end
          total_db += max_ratio
        end
        
        total_db / @clusters.length
      end
      
      # Calinski-Harabasz Index: ratio of between-cluster to within-cluster variance
      def calculate_calinski_harabasz_index
        return 0 if @clusters.length < 2
        
        bcss = calculate_bcss
        wcss = calculate_wcss
        
        n = @data_set.data_items.length
        k = @clusters.length
        
        return 0 if wcss == 0 || k == 1
        
        (bcss / (k - 1)) / (wcss / (n - k))
      end
      
      # Dunn Index: ratio of minimum inter-cluster to maximum intra-cluster distance
      def calculate_dunn_index
        return 0 if @clusters.length < 2
        
        # Find minimum inter-cluster distance
        min_inter_cluster = Float::INFINITY
        (0...@clusters.length).each do |i|
          ((i+1)...@clusters.length).each do |j|
            dist = min_cluster_distance(@clusters[i], @clusters[j])
            min_inter_cluster = [min_inter_cluster, dist].min
          end
        end
        
        # Find maximum intra-cluster distance
        max_intra_cluster = 0
        @clusters.each do |cluster|
          max_dist = max_intra_cluster_distance(cluster)
          max_intra_cluster = [max_intra_cluster, max_dist].max
        end
        
        max_intra_cluster > 0 ? min_inter_cluster / max_intra_cluster : 0
      end
      
      # Calculate detailed statistics for each cluster
      def calculate_cluster_statistics
        @clusters.map do |cluster|
          {
            size: cluster.data_items.length,
            diameter: calculate_cluster_diameter(cluster),
            centroid: calculate_centroid(cluster),
            dispersion: calculate_cluster_dispersion(cluster)
          }
        end
      end
      
      # Helper methods
      
      def average_intra_cluster_distance(point, cluster)
        other_points = cluster.data_items.reject { |p| p == point }
        return 0 if other_points.empty?
        
        total_distance = other_points.sum { |p| @distance_function.call(point, p) }
        total_distance / other_points.length
      end
      
      def min_inter_cluster_distance(point, current_cluster_index)
        min_distance = Float::INFINITY
        
        @clusters.each_with_index do |cluster, cluster_index|
          next if cluster_index == current_cluster_index
          next if cluster.data_items.empty?
          
          avg_distance = cluster.data_items.sum { |p| @distance_function.call(point, p) } / cluster.data_items.length
          min_distance = [min_distance, avg_distance].min
        end
        
        min_distance == Float::INFINITY ? 0 : min_distance
      end
      
      def calculate_centroid(cluster)
        return [] if cluster.data_items.empty?
        
        n_features = cluster.data_items.first.length
        centroid = Array.new(n_features, 0.0)
        
        cluster.data_items.each do |point|
          point.each_with_index do |value, i|
            centroid[i] += value if value.is_a?(Numeric)
          end
        end
        
        centroid.map { |sum| sum / cluster.data_items.length }
      end
      
      def calculate_overall_centroid
        return [] if @data_set.data_items.empty?
        
        n_features = @data_set.data_items.first.length
        centroid = Array.new(n_features, 0.0)
        
        @data_set.data_items.each do |point|
          point.each_with_index do |value, i|
            centroid[i] += value if value.is_a?(Numeric)
          end
        end
        
        centroid.map { |sum| sum / @data_set.data_items.length }
      end
      
      def calculate_cluster_dispersion(cluster)
        return 0 if cluster.data_items.empty?
        
        centroid = calculate_centroid(cluster)
        total_distance = cluster.data_items.sum { |point| @distance_function.call(point, centroid) }
        total_distance / cluster.data_items.length
      end
      
      def calculate_cluster_diameter(cluster)
        return 0 if cluster.data_items.length < 2
        
        max_distance = 0
        cluster.data_items.each do |point1|
          cluster.data_items.each do |point2|
            next if point1 == point2
            distance = @distance_function.call(point1, point2)
            max_distance = [max_distance, distance].max
          end
        end
        
        max_distance
      end
      
      def min_cluster_distance(cluster1, cluster2)
        min_distance = Float::INFINITY
        
        cluster1.data_items.each do |point1|
          cluster2.data_items.each do |point2|
            distance = @distance_function.call(point1, point2)
            min_distance = [min_distance, distance].min
          end
        end
        
        min_distance
      end
      
      def max_intra_cluster_distance(cluster)
        return 0 if cluster.data_items.length < 2
        
        max_distance = 0
        cluster.data_items.each do |point1|
          cluster.data_items.each do |point2|
            next if point1 == point2
            distance = @distance_function.call(point1, point2)
            max_distance = [max_distance, distance].max
          end
        end
        
        max_distance
      end
      
      # Educational explanations
      
      def explain_silhouette_score(score)
        return "Silhouette score could not be calculated" unless score
        
        explanation = "Interpretation: "
        case score
        when 0.7..1.0
          explanation += "Excellent clustering (0.7-1.0) - strong, well-separated clusters"
        when 0.5..0.7
          explanation += "Good clustering (0.5-0.7) - reasonable structure with some overlap"
        when 0.2..0.5
          explanation += "Weak clustering (0.2-0.5) - artificial clustering or poor fit"
        when -1.0..0.2
          explanation += "Poor clustering (-1.0-0.2) - points may be in wrong clusters"
        else
          explanation += "Invalid score range"
        end
        
        explanation += "\nSilhouette measures how well points fit their assigned clusters vs neighboring clusters."
      end
      
      def explain_wcss(wcss)
        return "WCSS could not be calculated" unless wcss
        
        "WCSS measures cluster compactness - lower values indicate tighter clusters.\n" +
        "Use with caution: WCSS always decreases as number of clusters increases.\n" +
        "Current WCSS: #{wcss.round(2)} - compare relative to other clustering attempts."
      end
      
      def explain_bcss(bcss)
        return "BCSS could not be calculated" unless bcss
        
        "BCSS measures cluster separation - higher values indicate better separated clusters.\n" +
        "Good clustering maximizes BCSS while keeping WCSS reasonable.\n" +
        "Current BCSS: #{bcss.round(2)} - higher is generally better."
      end
      
      def explain_variance_ratio(ratio)
        return "Variance ratio could not be calculated" unless ratio
        
        explanation = "Variance ratio (BCSS/TSS): #{ratio.round(4)}\n"
        explanation += "This measures what fraction of total variance is between clusters.\n"
        
        case ratio
        when 0.8..1.0
          explanation += "Excellent (0.8-1.0) - most variance is between clusters"
        when 0.6..0.8
          explanation += "Good (0.6-0.8) - clusters explain substantial variance"
        when 0.4..0.6
          explanation += "Moderate (0.4-0.6) - some clustering structure present"
        when 0.0..0.4
          explanation += "Poor (0.0-0.4) - weak clustering structure"
        end
        
        explanation
      end
      
      def explain_davies_bouldin(db_index)
        return "Davies-Bouldin index could not be calculated" unless db_index
        
        explanation = "Davies-Bouldin Index: #{db_index.round(4)} (lower is better)\n"
        
        case db_index
        when 0.0..0.5
          explanation += "Excellent clustering (0.0-0.5) - compact and well-separated clusters"
        when 0.5..1.0
          explanation += "Good clustering (0.5-1.0) - reasonable cluster quality"
        when 1.0..2.0
          explanation += "Moderate clustering (1.0-2.0) - some overlap or poor separation"
        else
          explanation += "Poor clustering (>2.0) - clusters poorly defined"
        end
        
        explanation += "\nDB index measures average similarity between each cluster and its most similar cluster."
      end
      
      def explain_calinski_harabasz(ch_index)
        return "Calinski-Harabasz index could not be calculated" unless ch_index
        
        explanation = "Calinski-Harabasz Index: #{ch_index.round(2)} (higher is better)\n"
        explanation += "Also called Variance Ratio Criterion - measures cluster separation vs compactness.\n"
        
        if ch_index > 100
          explanation += "High score suggests well-defined clusters with good separation."
        elsif ch_index > 50
          explanation += "Moderate score - reasonable clustering structure."
        else
          explanation += "Low score - weak clustering structure or poor parameter choice."
        end
        
        explanation
      end
      
      def explain_dunn_index(dunn_index)
        return "Dunn index could not be calculated" unless dunn_index
        
        explanation = "Dunn Index: #{dunn_index.round(4)} (higher is better)\n"
        explanation += "Ratio of minimum inter-cluster distance to maximum intra-cluster distance.\n"
        
        case dunn_index
        when 0.5..Float::INFINITY
          explanation += "Excellent clustering (>0.5) - well-separated, compact clusters"
        when 0.2..0.5
          explanation += "Good clustering (0.2-0.5) - reasonable separation"
        when 0.1..0.2
          explanation += "Moderate clustering (0.1-0.2) - some overlap"
        else
          explanation += "Poor clustering (<0.1) - significant overlap or poor structure"
        end
        
        explanation
      end
      
      def generate_overall_assessment(metrics)
        assessment = ["=== Overall Assessment ==="]
        
        # Collect positive indicators
        positives = []
        negatives = []
        
        if metrics[:silhouette_score] && metrics[:silhouette_score] > 0.5
          positives << "Good silhouette score (#{metrics[:silhouette_score].round(3)})"
        elsif metrics[:silhouette_score] && metrics[:silhouette_score] < 0.2
          negatives << "Poor silhouette score (#{metrics[:silhouette_score].round(3)})"
        end
        
        if metrics[:variance_ratio] && metrics[:variance_ratio] > 0.6
          positives << "High variance ratio (#{metrics[:variance_ratio].round(3)})"
        elsif metrics[:variance_ratio] && metrics[:variance_ratio] < 0.4
          negatives << "Low variance ratio (#{metrics[:variance_ratio].round(3)})"
        end
        
        if metrics[:davies_bouldin_index] && metrics[:davies_bouldin_index] < 1.0
          positives << "Low Davies-Bouldin index (#{metrics[:davies_bouldin_index].round(3)})"
        elsif metrics[:davies_bouldin_index] && metrics[:davies_bouldin_index] > 2.0
          negatives << "High Davies-Bouldin index (#{metrics[:davies_bouldin_index].round(3)})"
        end
        
        # Generate summary
        if positives.length > negatives.length
          assessment << "✓ Overall: GOOD clustering quality"
          assessment << "Strengths: #{positives.join(', ')}"
          assessment << "Areas for improvement: #{negatives.join(', ')}" if negatives.any?
        elsif negatives.length > positives.length
          assessment << "✗ Overall: POOR clustering quality"
          assessment << "Issues: #{negatives.join(', ')}"
          assessment << "Strengths: #{positives.join(', ')}" if positives.any?
        else
          assessment << "≈ Overall: MODERATE clustering quality"
          assessment << "Mixed results - consider different parameters or algorithms"
        end
        
        assessment << ""
        assessment << "Recommendations:"
        
        if metrics[:silhouette_score] && metrics[:silhouette_score] < 0.3
          assessment << "• Try different number of clusters or algorithm"
        end
        
        if metrics[:variance_ratio] && metrics[:variance_ratio] < 0.5
          assessment << "• Clusters may not be well-separated - check data structure"
        end
        
        if metrics[:cluster_statistics]
          sizes = metrics[:cluster_statistics].map { |s| s[:size] }
          if sizes.max > sizes.min * 10
            assessment << "• Large variation in cluster sizes - consider different algorithm"
          end
        end
        
        assessment.join("\n")
      end
      
      def self.generate_comparison_insights(evaluations)
        puts "=== Comparison Insights ==="
        puts
        
        # Find best performing algorithm for each metric
        metrics = [:silhouette_score, :variance_ratio, :calinski_harabasz_index]
        
        metrics.each do |metric|
          best = evaluations.max_by { |e| e[:metrics][metric] || -Float::INFINITY }
          if best && best[:metrics][metric]
            puts "Best #{metric}: #{best[:algorithm]} (#{best[:metrics][metric].round(4)})"
          end
        end
        
        # Find algorithms with consistent good performance
        consistent_performers = evaluations.select do |eval_result|
          metrics = eval_result[:metrics]
          (metrics[:silhouette_score] || 0) > 0.4 &&
          (metrics[:variance_ratio] || 0) > 0.5 &&
          (metrics[:davies_bouldin_index] || Float::INFINITY) < 1.5
        end
        
        if consistent_performers.any?
          puts "\nConsistently good performers: #{consistent_performers.map { |p| p[:algorithm] }.join(', ')}"
        else
          puts "\nNo algorithms performed consistently well across all metrics."
          puts "Consider: different parameters, preprocessing, or alternative algorithms."
        end
      end
    end
  end
end