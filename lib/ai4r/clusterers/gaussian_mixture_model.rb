# frozen_string_literal: true

# Gaussian Mixture Model (EM Algorithm) for Educational Clustering
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'clusterer'
require_relative '../data/data_set'

module Ai4r
  module Clusterers
    # Gaussian Mixture Model using Expectation-Maximization algorithm
    #
    # GMM represents clusters as Gaussian distributions and uses EM algorithm
    # to find parameters. Unlike K-means, GMM provides:
    # - Soft clustering (probabilistic assignments)
    # - Cluster shape flexibility (covariance matrices)
    # - Principled statistical framework
    # - Ability to handle overlapping clusters
    class GaussianMixtureModel < Clusterer
      attr_reader :n_components, :means, :covariances, :weights, :responsibilities, :log_likelihood_history,
                  :iterations, :data_set, :clusters, :soft_assignments

      parameters_info n_components: 'Number of Gaussian components (clusters) in the mixture',
                      max_iterations: 'Maximum number of EM iterations',
                      tolerance: 'Convergence tolerance for log-likelihood improvement',
                      covariance_type: "Type of covariance matrix: 'full', 'diagonal', 'spherical'",
                      init_method: "Initialization method: 'random', 'k_means_plus_plus', 'manual'",
                      regularization: 'Small value added to diagonal of covariance matrices for stability',
                      educational_mode: 'Enable step-by-step execution with explanations'

      # Covariance matrix types
      COVARIANCE_FULL = 'full' # Full covariance matrix
      COVARIANCE_DIAGONAL = 'diagonal' # Diagonal covariance matrix
      COVARIANCE_SPHERICAL = 'spherical' # Spherical covariance (scalar * identity)

      def initialize
        @n_components = 3
        @max_iterations = 100
        @tolerance = 1e-6
        @covariance_type = COVARIANCE_FULL
        @init_method = :k_means_plus_plus
        @regularization = 1e-6
        @educational_mode = false
        @step_callback = nil

        # Internal state
        @means = nil
        @covariances = nil
        @weights = nil
        @responsibilities = nil
        @log_likelihood_history = []
        @iterations = 0
      end

      # Enable educational step-by-step mode
      def enable_educational_mode(&callback)
        @educational_mode = true
        @step_callback = callback if block_given?
        self
      end

      # Build the Gaussian Mixture Model
      def build(data_set, n_components = @n_components)
        @data_set = data_set
        @n_components = n_components
        @n_samples = data_set.data_items.length
        @n_features = data_set.data_items.first&.length || 0

        validate_parameters

        educational_introduction if @educational_mode

        # Initialize parameters
        initialize_parameters

        # Run EM algorithm
        if @educational_mode
          run_em_with_steps
        else
          run_em_algorithm
        end

        # Create final clustering
        create_final_clusters

        self
      end

      # Predict cluster assignments for new data
      def eval(data_item)
        return nil unless @means && @covariances && @weights

        # Calculate responsibilities for this point
        responsibilities = calculate_single_point_responsibilities(data_item)

        # Return most likely cluster (hard assignment)
        responsibilities.each_with_index.max_by { |prob, _| prob }.last
      end

      # Get soft assignments (probabilities) for all points
      def get_soft_assignments
        @responsibilities
      end

      # Get cluster probabilities for a specific point
      def get_point_probabilities(data_item)
        calculate_single_point_responsibilities(data_item)
      end

      # Calculate log-likelihood of the data
      def log_likelihood
        return -Float::INFINITY unless @responsibilities

        total_ll = 0
        @data_set.data_items.each_with_index do |point, _i|
          point_ll = 0
          @n_components.times do |k|
            point_ll += @weights[k] * gaussian_pdf(point, @means[k], @covariances[k])
          end
          total_ll += Math.log(point_ll) if point_ll > 0
        end

        total_ll
      end

      # Educational explanation of GMM concepts
      def explain_concepts
        puts <<~EXPLANATION
          === Gaussian Mixture Model (GMM) ===

          Key Concepts:

          1. Mixture Model: Data comes from a mixture of K Gaussian distributions
             - Each cluster is a Gaussian with mean μ and covariance Σ
             - Mixing weights π determine relative cluster sizes
          #{'   '}
          2. Latent Variables: Which Gaussian generated each point?
             - Hidden/unobserved variables
             - We estimate these probabilistically
          #{'   '}
          3. EM Algorithm: Expectation-Maximization
             - E-step: Calculate responsibilities (soft assignments)
             - M-step: Update parameters given responsibilities
             - Iterate until convergence
          #{'   '}
          4. Soft Clustering: Points can belong to multiple clusters
             - Probability of belonging to each cluster
             - More realistic than hard assignments
          #{'   '}
          Current Model Configuration:
          • Components: #{@n_components}
          • Covariance type: #{@covariance_type}
          • Max iterations: #{@max_iterations}
          • Convergence tolerance: #{@tolerance}

          Mathematical Foundation:
          • P(x) = Σ πk * N(x | μk, Σk)
          • Responsibility: γ(k|x) = πk * N(x | μk, Σk) / P(x)
          • Complete data log-likelihood maximization

        EXPLANATION
      end

      # Visualize model parameters and fit
      def visualize_model
        return unless @means && @covariances && @weights

        puts "\n=== GMM Model Visualization ==="
        puts

        puts 'Model Parameters:'
        @n_components.times do |k|
          puts "Component #{k}:"
          puts "  Weight: #{@weights[k].round(4)}"
          puts "  Mean: [#{@means[k].map { |m| m.round(3) }.join(', ')}]"

          case @covariance_type
          when COVARIANCE_SPHERICAL
            puts "  Covariance: #{@covariances[k].round(4)} * I"
          when COVARIANCE_DIAGONAL
            puts "  Covariance (diag): [#{@covariances[k].map { |c| c.round(4) }.join(', ')}]"
          when COVARIANCE_FULL
            puts '  Covariance: [full matrix - showing eigenvalues]'
            eigenvals = calculate_eigenvalues(@covariances[k])
            puts "    Eigenvalues: [#{eigenvals.map { |e| e.round(4) }.join(', ')}]"
          end
          puts
        end

        # Show convergence history
        if @log_likelihood_history.length > 1
          puts 'Convergence History:'
          puts 'Iteration | Log-Likelihood | Improvement'
          puts '----------|----------------|------------'

          @log_likelihood_history.each_with_index do |ll, iter|
            if iter == 0
              puts format('%9d | %14.4f | %s', iter, ll, 'Initial')
            else
              improvement = ll - @log_likelihood_history[iter - 1]
              puts format('%9d | %14.4f | %10.6f', iter, ll, improvement)
            end
          end
        end

        # Visualize 2D data if possible
        visualize_2d_gaussian_mixture if @n_features == 2
      end

      protected

      def validate_parameters
        raise ArgumentError, 'Number of components must be positive' if @n_components <= 0
        raise ArgumentError, 'Max iterations must be positive' if @max_iterations <= 0
        raise ArgumentError, 'Data set is empty' if @n_samples == 0
        raise ArgumentError, 'All data points must be numeric' unless all_numeric?

        valid_cov_types = [COVARIANCE_FULL, COVARIANCE_DIAGONAL, COVARIANCE_SPHERICAL]
        unless valid_cov_types.include?(@covariance_type)
          raise ArgumentError, "Invalid covariance type: #{@covariance_type}"
        end
      end

      def all_numeric?
        @data_set.data_items.all? do |item|
          item.all?(Numeric)
        end
      end

      def educational_introduction
        puts "\n#{'=' * 60}"
        puts 'GAUSSIAN MIXTURE MODEL - EDUCATIONAL MODE'
        puts '=' * 60
        puts "Dataset: #{@n_samples} points in #{@n_features}D space"
        puts "Learning #{@n_components} Gaussian components"
        puts
        explain_concepts
        puts "\nStarting EM algorithm..."
        puts '=' * 60
      end

      def initialize_parameters
        puts "\nInitializing parameters..." if @educational_mode

        # Initialize means
        @means = initialize_means

        # Initialize covariances
        @covariances = initialize_covariances

        # Initialize weights (uniform)
        @weights = Array.new(@n_components, 1.0 / @n_components)

        if @educational_mode
          puts "Initial means: #{@means.map { |m| m.map { |x| x.round(3) } }}"
          puts "Initial weights: #{@weights.map { |w| w.round(3) }}"
        end
      end

      def initialize_means
        case @init_method
        when :random
          initialize_means_random
        when :k_means_plus_plus
          initialize_means_kmeans_plus_plus
        when :manual
          # Would use provided means
          initialize_means_random
        else
          initialize_means_random
        end
      end

      def initialize_means_random
        Array.new(@n_components) do
          # Select random data point as mean
          @data_set.data_items.sample.dup
        end
      end

      def initialize_means_kmeans_plus_plus
        means = []

        # First mean: random point
        means << @data_set.data_items.sample.dup

        # Subsequent means: K-means++ style
        (@n_components - 1).times do
          distances = @data_set.data_items.map do |point|
            min_dist_sq = means.map { |mean| squared_distance(point, mean) }.min
            min_dist_sq
          end

          total_dist = distances.sum
          break if total_dist == 0

          target = rand * total_dist
          cumulative = 0

          @data_set.data_items.each_with_index do |point, idx|
            cumulative += distances[idx]
            if cumulative >= target
              means << point.dup
              break
            end
          end
        end

        means
      end

      def initialize_covariances
        case @covariance_type
        when COVARIANCE_SPHERICAL
          # Single variance for all components
          overall_variance = calculate_overall_variance
          Array.new(@n_components, overall_variance)
        when COVARIANCE_DIAGONAL
          # Diagonal covariance matrices
          overall_variances = calculate_overall_variances_per_dimension
          Array.new(@n_components) { overall_variances.dup }
        when COVARIANCE_FULL
          # Full covariance matrices
          overall_cov = calculate_overall_covariance_matrix
          Array.new(@n_components) { deep_copy_matrix(overall_cov) }
        end
      end

      def run_em_algorithm
        @log_likelihood_history = []

        @max_iterations.times do |iteration|
          @iterations = iteration + 1

          # E-step: Calculate responsibilities
          e_step

          # M-step: Update parameters
          m_step

          # Calculate log-likelihood
          current_ll = log_likelihood
          @log_likelihood_history << current_ll

          # Check convergence
          next unless iteration > 0

          improvement = current_ll - @log_likelihood_history[-2]
          if improvement.abs < @tolerance
            puts "Converged after #{iteration + 1} iterations" if @educational_mode
            break
          end
        end
      end

      def run_em_with_steps
        @log_likelihood_history = []

        @max_iterations.times do |iteration|
          @iterations = iteration + 1

          puts "\n--- EM Iteration #{iteration + 1} ---"

          # E-step with explanation
          puts 'E-step: Calculating responsibilities (soft assignments)'
          e_step

          log_step_info('E-step', iteration + 1, {
                          action: 'Calculated responsibilities',
                          description: 'Each point gets probability of belonging to each component'
                        })

          # M-step with explanation
          puts 'M-step: Updating parameters'
          m_step

          log_step_info('M-step', iteration + 1, {
                          action: 'Updated means, covariances, and weights',
                          description: 'Parameters adjusted to maximize likelihood of current assignments'
                        })

          # Calculate and show log-likelihood
          current_ll = log_likelihood
          @log_likelihood_history << current_ll

          puts "Log-likelihood: #{current_ll.round(6)}"

          if iteration > 0
            improvement = current_ll - @log_likelihood_history[-2]
            puts "Improvement: #{improvement.round(8)}"

            if improvement.abs < @tolerance
              puts "\n🎉 Converged! Improvement less than tolerance (#{@tolerance})"
              break
            end
          end

          if @educational_mode
            puts 'Press Enter to continue to next iteration...'
            gets
          end
        end
      end

      def e_step
        @responsibilities = calculate_responsibilities
      end

      def calculate_responsibilities
        responsibilities = Array.new(@n_samples) { Array.new(@n_components, 0.0) }

        @data_set.data_items.each_with_index do |point, i|
          # Calculate unnormalized responsibilities
          unnormalized = Array.new(@n_components)
          @n_components.times do |k|
            unnormalized[k] = @weights[k] * gaussian_pdf(point, @means[k], @covariances[k])
          end

          # Normalize
          total = unnormalized.sum
          if total > 0
            @n_components.times do |k|
              responsibilities[i][k] = unnormalized[k] / total
            end
          else
            # Fallback: uniform responsibilities
            @n_components.times do |k|
              responsibilities[i][k] = 1.0 / @n_components
            end
          end
        end

        responsibilities
      end

      def m_step
        # Calculate effective number of points in each component
        n_k = Array.new(@n_components, 0.0)
        @n_components.times do |k|
          n_k[k] = @responsibilities.sum { |resp| resp[k] }
        end

        # Update weights
        @n_components.times do |k|
          @weights[k] = n_k[k] / @n_samples
        end

        # Update means
        @n_components.times do |k|
          next unless n_k[k] > 0

          @means[k] = Array.new(@n_features, 0.0)
          @data_set.data_items.each_with_index do |point, i|
            @n_features.times do |d|
              @means[k][d] += @responsibilities[i][k] * point[d]
            end
          end
          @means[k].map! { |sum| sum / n_k[k] }
        end

        # Update covariances
        update_covariances(n_k)
      end

      def update_covariances(n_k)
        case @covariance_type
        when COVARIANCE_SPHERICAL
          update_spherical_covariances(n_k)
        when COVARIANCE_DIAGONAL
          update_diagonal_covariances(n_k)
        when COVARIANCE_FULL
          update_full_covariances(n_k)
        end
      end

      def update_spherical_covariances(n_k)
        @n_components.times do |k|
          next unless n_k[k] > 0

          variance = 0.0
          @data_set.data_items.each_with_index do |point, i|
            diff_sq = squared_distance(point, @means[k])
            variance += @responsibilities[i][k] * diff_sq
          end
          @covariances[k] = (variance / (n_k[k] * @n_features)) + @regularization
        end
      end

      def update_diagonal_covariances(n_k)
        @n_components.times do |k|
          next unless n_k[k] > 0

          @covariances[k] = Array.new(@n_features, 0.0)
          @data_set.data_items.each_with_index do |point, i|
            @n_features.times do |d|
              diff = point[d] - @means[k][d]
              @covariances[k][d] += @responsibilities[i][k] * (diff**2)
            end
          end
          @covariances[k].map! { |var| (var / n_k[k]) + @regularization }
        end
      end

      def update_full_covariances(n_k)
        @n_components.times do |k|
          next unless n_k[k] > 0

          cov = Array.new(@n_features) { Array.new(@n_features, 0.0) }

          @data_set.data_items.each_with_index do |point, i|
            diff = point.zip(@means[k]).map { |p, m| p - m }

            @n_features.times do |d1|
              @n_features.times do |d2|
                cov[d1][d2] += @responsibilities[i][k] * diff[d1] * diff[d2]
              end
            end
          end

          # Normalize and add regularization
          @n_features.times do |d1|
            @n_features.times do |d2|
              cov[d1][d2] /= n_k[k]
              cov[d1][d2] += @regularization if d1 == d2
            end
          end

          @covariances[k] = cov
        end
      end

      def create_final_clusters
        @clusters = Array.new(@n_components) do
          Ai4r::Data::DataSet.new(data_labels: @data_set.data_labels)
        end

        @soft_assignments = []

        # Assign points to most likely cluster
        @data_set.data_items.each_with_index do |point, i|
          responsibilities = @responsibilities[i]
          most_likely_cluster = responsibilities.each_with_index.max_by { |prob, _| prob }.last

          @clusters[most_likely_cluster] << point
          @soft_assignments << responsibilities.dup
        end
      end

      # Helper methods

      def gaussian_pdf(x, mean, covariance)
        case @covariance_type
        when COVARIANCE_SPHERICAL
          gaussian_pdf_spherical(x, mean, covariance)
        when COVARIANCE_DIAGONAL
          gaussian_pdf_diagonal(x, mean, covariance)
        when COVARIANCE_FULL
          gaussian_pdf_full(x, mean, covariance)
        end
      end

      def gaussian_pdf_spherical(x, mean, variance)
        diff_sq = squared_distance(x, mean)
        coeff = 1.0 / ((2 * Math::PI * variance)**(@n_features / 2.0))
        exp_term = Math.exp(-diff_sq / (2 * variance))
        coeff * exp_term
      end

      def gaussian_pdf_diagonal(x, mean, variances)
        diff_sq_normalized = x.zip(mean, variances).sum do |xi, mi, vi|
          ((xi - mi)**2) / vi
        end

        det_cov = variances.reduce(:*)
        coeff = 1.0 / Math.sqrt(((2 * Math::PI)**@n_features) * det_cov)
        exp_term = Math.exp(-0.5 * diff_sq_normalized)
        coeff * exp_term
      end

      def gaussian_pdf_full(x, mean, covariance)
        # Simplified implementation - in practice would use proper matrix operations
        diff = x.zip(mean).map { |xi, mi| xi - mi }

        # Calculate determinant and inverse (simplified for 2D case)
        if @n_features == 2
          det = (covariance[0][0] * covariance[1][1]) - (covariance[0][1] * covariance[1][0])
          return 1e-10 if det <= 0 # Avoid numerical issues

          inv_cov = [
            [covariance[1][1] / det, -covariance[0][1] / det],
            [-covariance[1][0] / det, covariance[0][0] / det]
          ]

          quad_form = (diff[0] * ((inv_cov[0][0] * diff[0]) + (inv_cov[0][1] * diff[1]))) +
                      (diff[1] * ((inv_cov[1][0] * diff[0]) + (inv_cov[1][1] * diff[1])))

          coeff = 1.0 / (2 * Math::PI * Math.sqrt(det))
          exp_term = Math.exp(-0.5 * quad_form)
          coeff * exp_term
        else
          # Fallback to diagonal approximation for higher dimensions
          diagonal_vars = (0...@n_features).map { |i| covariance[i][i] }
          gaussian_pdf_diagonal(x, mean, diagonal_vars)
        end
      end

      def calculate_single_point_responsibilities(point)
        unnormalized = Array.new(@n_components) do |k|
          @weights[k] * gaussian_pdf(point, @means[k], @covariances[k])
        end

        total = unnormalized.sum
        return Array.new(@n_components, 1.0 / @n_components) if total == 0

        unnormalized.map { |u| u / total }
      end

      def squared_distance(a, b)
        a.zip(b).sum { |x, y| (x - y)**2 }
      end

      def calculate_overall_variance
        all_distances = []
        @data_set.data_items.each do |point1|
          @data_set.data_items.each do |point2|
            all_distances << squared_distance(point1, point2)
          end
        end
        all_distances.sum / all_distances.length / (2 * @n_features)
      end

      def calculate_overall_variances_per_dimension
        variances = Array.new(@n_features, 0.0)

        # Calculate mean for each dimension
        means = Array.new(@n_features, 0.0)
        @data_set.data_items.each do |point|
          point.each_with_index { |val, dim| means[dim] += val }
        end
        means.map! { |sum| sum / @n_samples }

        # Calculate variance for each dimension
        @data_set.data_items.each do |point|
          point.each_with_index do |val, dim|
            variances[dim] += (val - means[dim])**2
          end
        end
        variances.map! { |var| var / @n_samples }

        variances
      end

      def calculate_overall_covariance_matrix
        # Calculate overall mean
        overall_mean = Array.new(@n_features, 0.0)
        @data_set.data_items.each do |point|
          point.each_with_index { |val, dim| overall_mean[dim] += val }
        end
        overall_mean.map! { |sum| sum / @n_samples }

        # Calculate covariance matrix
        cov = Array.new(@n_features) { Array.new(@n_features, 0.0) }
        @data_set.data_items.each do |point|
          diff = point.zip(overall_mean).map { |p, m| p - m }
          @n_features.times do |i|
            @n_features.times do |j|
              cov[i][j] += diff[i] * diff[j]
            end
          end
        end

        # Normalize
        cov.each { |row| row.map! { |val| val / @n_samples } }
        cov
      end

      def deep_copy_matrix(matrix)
        matrix.map(&:dup)
      end

      def calculate_eigenvalues(matrix)
        # Simplified eigenvalue calculation for 2x2 matrices
        if matrix.length == 2 && matrix[0].length == 2
          a, b, c, d = matrix[0][0], matrix[0][1], matrix[1][0], matrix[1][1]
          trace = a + d
          det = (a * d) - (b * c)
          discriminant = (trace**2) - (4 * det)

          if discriminant >= 0
            sqrt_disc = Math.sqrt(discriminant)
            [(trace + sqrt_disc) / 2, (trace - sqrt_disc) / 2]
          else
            [trace / 2, trace / 2] # Complex eigenvalues, return real part
          end
        else
          # For higher dimensions, return diagonal elements as approximation
          matrix.each_with_index.map { |row, i| row[i] }
        end
      end

      def visualize_2d_gaussian_mixture
        return unless @n_features == 2

        puts "\n=== 2D Gaussian Mixture Visualization ==="
        puts 'Components shown with different symbols'
        puts

        # Create simple ASCII visualization
        plot_width = 50
        plot_height = 20

        # Get coordinates
        points = @data_set.data_items
        x_values = points.map(&:first)
        y_values = points.map(&:last)
        x_min, x_max = x_values.minmax
        y_min, y_max = y_values.minmax

        # Create plot grid
        plot = Array.new(plot_height) { Array.new(plot_width, '.') }

        # Plot data points colored by most likely component
        points.each_with_index do |point, idx|
          x, y = point[0], point[1]
          most_likely = @responsibilities[idx].each_with_index.max_by { |prob, _| prob }.last

          # Scale to plot coordinates
          plot_x = ((x - x_min) / (x_max - x_min) * (plot_width - 1)).to_i
          plot_y = ((y - y_min) / (y_max - y_min) * (plot_height - 1)).to_i

          symbol = ('A'.ord + most_likely).chr
          plot[plot_height - 1 - plot_y][plot_x] = symbol
        end

        # Plot component means
        @means.each_with_index do |mean, _k|
          x, y = mean[0], mean[1]
          plot_x = ((x - x_min) / (x_max - x_min) * (plot_width - 1)).to_i
          plot_y = ((y - y_min) / (y_max - y_min) * (plot_height - 1)).to_i

          plot[plot_height - 1 - plot_y][plot_x] = '*'
        end

        # Print plot
        plot.each { |row| puts row.join }

        puts "\nLegend:"
        @n_components.times do |k|
          symbol = ('A'.ord + k).chr
          puts "  #{symbol} = Component #{k} (weight: #{@weights[k].round(3)})"
        end
        puts '  * = Component mean'
      end

      def log_step_info(step_type, iteration, info)
        return unless @educational_mode && @step_callback

        step_info = {
          step_type: step_type,
          iteration: iteration,
          means: @means.map(&:dup),
          weights: @weights.dup,
          log_likelihood: @log_likelihood_history.last,
          info: info
        }

        @step_callback.call(step_info)
      end
    end

    # Educational helper for GMM parameter analysis
    class GMMParameterHelper
      # Suggest number of components using various criteria
      def self.suggest_components(data_set, max_components = 10)
        puts '=== GMM Component Selection Analysis ==='
        puts

        results = []

        (1..max_components).each do |k|
          puts "Testing #{k} components..."

          gmm = GaussianMixtureModel.new
          gmm.build(data_set, k)

          # Calculate various criteria
          ll = gmm.log_likelihood
          n_params = calculate_num_parameters(k, data_set.data_items.first.length, 'full')
          n_samples = data_set.data_items.length

          aic = (-2 * ll) + (2 * n_params)
          bic = (-2 * ll) + (n_params * Math.log(n_samples))

          results << {
            k: k,
            log_likelihood: ll,
            aic: aic,
            bic: bic,
            n_params: n_params
          }
        end

        # Find optimal K by different criteria
        best_aic = results.min_by { |r| r[:aic] }
        best_bic = results.min_by { |r| r[:bic] }
        results.max_by { |r| r[:log_likelihood] }

        puts "\nResults:"
        puts 'K  | Log-Likelihood |    AIC     |    BIC     | Parameters'
        puts '---|----------------|------------|------------|------------'

        results.each do |result|
          marker_aic = result == best_aic ? '*' : ' '
          marker_bic = result == best_bic ? '*' : ' '

          puts format('%2d | %14.2f | %s%9.2f | %s%9.2f | %10d',
                      result[:k], result[:log_likelihood],
                      marker_aic, result[:aic],
                      marker_bic, result[:bic],
                      result[:n_params])
        end

        puts "\nRecommendations:"
        puts "• AIC suggests K = #{best_aic[:k]} (marked with * in AIC column)"
        puts "• BIC suggests K = #{best_bic[:k]} (marked with * in BIC column)"
        puts '• BIC generally prefers simpler models than AIC'
        puts '• Consider computational cost and interpretability'

        {
          results: results,
          best_aic: best_aic[:k],
          best_bic: best_bic[:k],
          recommendations: generate_k_recommendations(results)
        }
      end

      # Compare different covariance types
      def self.compare_covariance_types(data_set, k = 3)
        puts '=== Covariance Type Comparison ==='
        puts

        covariance_types = %w[spherical diagonal full]
        results = {}

        covariance_types.each do |cov_type|
          puts "Testing #{cov_type} covariance..."

          gmm = GaussianMixtureModel.new
          gmm.instance_variable_set(:@covariance_type, cov_type)
          gmm.build(data_set, k)

          results[cov_type] = {
            log_likelihood: gmm.log_likelihood,
            iterations: gmm.iterations,
            parameters: calculate_num_parameters(k, data_set.data_items.first.length, cov_type)
          }
        end

        puts "\nComparison Results:"
        puts 'Covariance Type | Log-Likelihood | Iterations | Parameters'
        puts '----------------|----------------|------------|------------'

        results.each do |cov_type, result|
          puts format('%-15s | %14.2f | %10d | %10d',
                      cov_type, result[:log_likelihood], result[:iterations], result[:parameters])
        end

        best_type = results.max_by { |_, result| result[:log_likelihood] }.first
        puts "\nBest performance: #{best_type} (highest log-likelihood)"

        puts "\nGuidelines:"
        puts '• Spherical: Assumes circular clusters, fewest parameters'
        puts '• Diagonal: Axis-aligned elliptical clusters, moderate parameters'
        puts '• Full: Arbitrary elliptical clusters, most parameters'
        puts '• Choose based on data structure and computational constraints'

        results
      end

      def self.calculate_num_parameters(k, d, covariance_type)
        # Means: k * d
        # Weights: k - 1 (sum to 1 constraint)
        # Covariances: depends on type

        mean_params = k * d
        weight_params = k - 1

        cov_params = case covariance_type
                     when 'spherical'
                       k # One variance per component
                     when 'diagonal'
                       k * d # d variances per component
                     when 'full'
                       k * d * (d + 1) / 2 # Upper triangular matrix per component
                     else
                       0
                     end

        mean_params + weight_params + cov_params
      end

      def self.generate_k_recommendations(results)
        recommendations = []

        # Look for elbow in log-likelihood
        if results.length >= 3
          improvements = []
          (1...results.length).each do |i|
            improvement = results[i][:log_likelihood] - results[i - 1][:log_likelihood]
            improvements << improvement
          end

          # Find where improvement starts to diminish
          if improvements.length >= 2
            diminish_point = nil
            (1...improvements.length).each do |i|
              if improvements[i] < improvements[i - 1] * 0.5 # 50% reduction in improvement
                diminish_point = i + 1 # +1 because improvements are 0-indexed
                break
              end
            end

            recommendations << "Elbow method suggests K = #{diminish_point + 1}" if diminish_point
          end
        end

        recommendations << 'Start with smaller K for interpretability'
        recommendations << 'Consider computational cost vs. model complexity'
        recommendations
      end
    end
  end
end
