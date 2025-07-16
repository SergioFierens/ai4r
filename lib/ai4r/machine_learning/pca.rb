# frozen_string_literal: true

#
# Principal Component Analysis (PCA) Implementation for AI4R Educational Framework
#
# This implementation provides a comprehensive, educational version of PCA for
# dimensionality reduction, designed specifically for students and teachers to
# understand linear algebra concepts in machine learning.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# PCA is a dimensionality reduction technique that projects high-dimensional data
# onto lower-dimensional spaces while preserving as much variance as possible.
# It finds the principal components (eigenvectors) that explain the most variance
# in the data.
#
# Key Educational Concepts:
# - Dimensionality Reduction: Reducing the number of features while preserving information
# - Variance Preservation: Keeping the dimensions that explain the most data variance
# - Eigenvectors and Eigenvalues: Linear algebra concepts fundamental to PCA
# - Data Standardization: Importance of scaling features before PCA
# - Cumulative Explained Variance: Understanding how many components to retain
#
# Example Usage:
#   # Create dataset
#   data = [
#     [2.5, 2.4, 1.0, 0.8],
#     [0.5, 0.7, 0.2, 0.1],
#     [2.2, 2.9, 1.5, 1.2],
#     [1.9, 2.2, 1.8, 1.6],
#     [3.1, 3.0, 2.1, 2.0]
#   ]
#
#   # Apply PCA
#   pca = PCA.new(n_components: 2)
#   pca.fit(data)
#   transformed = pca.transform(data)
#   puts "Original shape: #{data.length} x #{data[0].length}"
#   puts "Transformed shape: #{transformed.length} x #{transformed[0].length}"
#

module Ai4r
  module MachineLearning
    # Principal Component Analysis (PCA) Implementation
    #
    # This class implements PCA with comprehensive educational features including
    # step-by-step computation visualization, variance analysis, and reconstruction
    # capabilities.
    #
    # The algorithm works by:
    # 1. Standardizing the data (centering and scaling)
    # 2. Computing the covariance matrix
    # 3. Finding eigenvalues and eigenvectors
    # 4. Selecting principal components based on explained variance
    # 5. Transforming data into the new coordinate system
    #
    # Educational Features:
    # - Variance explained by each component
    # - Cumulative variance analysis
    # - Data reconstruction from reduced dimensions
    # - Visualization of principal components
    # - Standardization impact analysis
    #
    class PCA
      # Analysis results and statistics
      attr_reader :components, :explained_variance, :explained_variance_ratio
      attr_reader :singular_values, :mean_values, :std_values, :n_samples, :n_features, :cumulative_variance,
                  :feature_names, :standardized_data, :covariance_matrix

      # Educational configuration
      attr_accessor :verbose_mode, :standardize, :store_covariance

      # Default configuration values
      DEFAULT_N_COMPONENTS = 2
      DEFAULT_STANDARDIZE = true
      DEFAULT_TOL = 1e-10

      # Initialize PCA with configuration
      #
      # @param n_components [Integer, Float] Number of components to keep
      # @param standardize [Boolean] Whether to standardize data before PCA
      # @param options [Hash] Additional configuration options
      #
      def initialize(n_components: DEFAULT_N_COMPONENTS, standardize: DEFAULT_STANDARDIZE, **options)
        @n_components = validate_n_components(n_components)
        @standardize = standardize
        @tolerance = options.fetch(:tolerance, DEFAULT_TOL)

        # Educational configuration
        @verbose_mode = options.fetch(:verbose, false)
        @store_covariance = options.fetch(:store_covariance, true)

        # Initialize components
        @components = []
        @explained_variance = []
        @explained_variance_ratio = []
        @singular_values = []
        @mean_values = []
        @std_values = []
        @cumulative_variance = []
        @feature_names = []
        @standardized_data = []
        @covariance_matrix = []

        # State
        @fitted = false
      end

      # Fit PCA model to training data
      #
      # @param data [Array<Array>] Training data matrix
      # @param feature_names [Array<String>] Optional feature names
      # @return [PCA] Self for method chaining
      #
      # Educational Note:
      # This method demonstrates the complete PCA fitting process:
      # 1. Validate and prepare input data
      # 2. Standardize data if requested
      # 3. Compute covariance matrix
      # 4. Find eigenvalues and eigenvectors
      # 5. Sort components by explained variance
      # 6. Select top components
      # 7. Calculate explained variance ratios
      #
      def fit(data, feature_names = nil)
        validate_input_data(data)

        educational_output('📊 PCA Fitting Starting', <<~MSG)
          Data shape: #{data.length} samples × #{data[0].length} features
          N components: #{@n_components}
          Standardize: #{@standardize}
        MSG

        # Prepare data
        @n_samples = data.length
        @n_features = data[0].length
        @feature_names = feature_names || (0...@n_features).map { |i| "feature_#{i}" }

        # Determine actual number of components
        @n_components = determine_n_components(@n_components, @n_features)

        educational_output('🔧 Data Preparation', <<~MSG)
          Actual components to extract: #{@n_components}
          Feature names: #{@feature_names.join(', ')}
        MSG

        # Standardize data if requested
        if @standardize
          @standardized_data = standardize_data(data)
          educational_output('📏 Data Standardization', 'Data standardized (mean=0, std=1)')
        else
          @standardized_data = center_data(data)
          educational_output('📏 Data Centering', 'Data centered (mean=0)')
        end

        # Compute covariance matrix
        @covariance_matrix = compute_covariance_matrix(@standardized_data)
        educational_output('🔢 Covariance Matrix', "Covariance matrix computed (#{@n_features}×#{@n_features})")

        # Find eigenvalues and eigenvectors
        eigenvalues, eigenvectors = compute_eigendecomposition(@covariance_matrix)
        educational_output('🔍 Eigendecomposition', "Found #{eigenvalues.length} eigenvalues/eigenvectors")

        # Sort by eigenvalue magnitude (descending)
        sorted_indices = eigenvalues.each_with_index.sort_by { |val, _| -val.abs }.map(&:last)

        # Select top components
        @components = sorted_indices.first(@n_components).map { |i| eigenvectors[i] }
        @explained_variance = sorted_indices.first(@n_components).map { |i| eigenvalues[i] }
        @singular_values = @explained_variance.map { |var| Math.sqrt(var.abs * (@n_samples - 1)) }

        # Calculate explained variance ratios
        total_variance = eigenvalues.sum(&:abs)
        @explained_variance_ratio = @explained_variance.map { |var| var.abs / total_variance }
        @cumulative_variance = calculate_cumulative_variance(@explained_variance_ratio)

        educational_output('📈 Variance Analysis', <<~MSG)
          Total variance: #{total_variance.round(4)}
          Explained variance: #{@explained_variance.map { |v| v.round(4) }}
          Explained variance ratio: #{@explained_variance_ratio.map { |v| v.round(4) }}
          Cumulative variance: #{@cumulative_variance.map { |v| v.round(4) }}
        MSG

        @fitted = true
        educational_output('✅ PCA Fitting Complete', 'Model ready for transformation')

        self
      end

      # Transform data using fitted PCA model
      #
      # @param data [Array<Array>] Data to transform
      # @return [Array<Array>] Transformed data
      #
      def transform(data)
        validate_fitted
        validate_input_data(data)
        raise ArgumentError, "Data must have #{@n_features} features" unless data[0].length == @n_features

        # Standardize new data using stored parameters
        standardized_data = if @standardize
                              standardize_new_data(data)
                            else
                              center_new_data(data)
                            end

        # Project data onto principal components
        transformed_data = []
        standardized_data.each do |sample|
          transformed_sample = @components.map do |component|
            dot_product(sample, component)
          end
          transformed_data << transformed_sample
        end

        educational_output('🔄 Data Transformation', <<~MSG)
          Transformed #{data.length} samples
          Original dimensions: #{@n_features}
          Reduced dimensions: #{@n_components}
        MSG

        transformed_data
      end

      # Fit and transform data in one step
      #
      # @param data [Array<Array>] Training data
      # @param feature_names [Array<String>] Optional feature names
      # @return [Array<Array>] Transformed data
      #
      def fit_transform(data, feature_names = nil)
        fit(data, feature_names)
        transform(data)
      end

      # Reconstruct data from reduced dimensions
      #
      # @param transformed_data [Array<Array>] Data in reduced dimensions
      # @return [Array<Array>] Reconstructed data
      #
      def inverse_transform(transformed_data)
        validate_fitted
        validate_input_data(transformed_data)
        unless transformed_data[0].length == @n_components
          raise ArgumentError, "Data must have #{@n_components} components"
        end

        # Reconstruct in standardized space
        reconstructed_data = []
        transformed_data.each do |sample|
          reconstructed_sample = Array.new(@n_features, 0.0)

          sample.each_with_index do |component_value, comp_idx|
            @components[comp_idx].each_with_index do |weight, feature_idx|
              reconstructed_sample[feature_idx] += component_value * weight
            end
          end

          reconstructed_data << reconstructed_sample
        end

        # Reverse standardization
        reconstructed_data = if @standardize
                               destandardize_data(reconstructed_data)
                             else
                               decenter_data(reconstructed_data)
                             end

        educational_output('🔄 Data Reconstruction', <<~MSG)
          Reconstructed #{transformed_data.length} samples
          Reduced dimensions: #{@n_components}
          Original dimensions: #{@n_features}
        MSG

        reconstructed_data
      end

      # Analyze explained variance and component selection
      #
      # @param threshold [Float] Minimum cumulative variance to retain
      # @return [Hash] Variance analysis results
      #
      def explained_variance_analysis(threshold = 0.95)
        validate_fitted

        # Find number of components needed for threshold
        components_needed = @cumulative_variance.index { |cum_var| cum_var >= threshold } || @n_components

        # Calculate information loss
        information_retained = @cumulative_variance[@n_components - 1]
        information_lost = 1.0 - information_retained

        {
          explained_variance: @explained_variance,
          explained_variance_ratio: @explained_variance_ratio,
          cumulative_variance: @cumulative_variance,
          components_for_threshold: components_needed + 1,
          information_retained: information_retained,
          information_lost: information_lost,
          dimensionality_reduction: (@n_features - @n_components).to_f / @n_features
        }
      end

      # Calculate reconstruction error
      #
      # @param original_data [Array<Array>] Original data
      # @return [Hash] Reconstruction error metrics
      #
      def reconstruction_error(original_data)
        validate_fitted
        validate_input_data(original_data)

        # Transform and reconstruct
        transformed_data = transform(original_data)
        reconstructed_data = inverse_transform(transformed_data)

        # Calculate errors
        errors = []
        mse_per_sample = []

        original_data.each_with_index do |original_sample, sample_idx|
          reconstructed_sample = reconstructed_data[sample_idx]

          sample_error = original_sample.zip(reconstructed_sample).map do |orig, recon|
            (orig - recon)**2
          end

          errors.concat(sample_error)
          mse_per_sample << (sample_error.sum / sample_error.length)
        end

        # Calculate metrics
        mse = errors.sum / errors.length
        rmse = Math.sqrt(mse)
        mae = errors.sum { |e| Math.sqrt(e) } / errors.length

        {
          mean_squared_error: mse,
          root_mean_squared_error: rmse,
          mean_absolute_error: mae,
          mse_per_sample: mse_per_sample,
          max_error: errors.max,
          min_error: errors.min
        }
      end

      # Analyze component contributions to features
      #
      # @return [Hash] Component analysis results
      #
      def component_analysis
        validate_fitted

        # Calculate feature contributions to each component
        feature_contributions = []
        @components.each_with_index do |component, comp_idx|
          contributions = {}
          component.each_with_index do |weight, feature_idx|
            feature_name = @feature_names[feature_idx]
            contributions[feature_name] = weight.abs
          end

          # Sort by contribution magnitude
          sorted_contributions = contributions.sort_by { |_, contrib| -contrib }
          feature_contributions << {
            component: comp_idx + 1,
            explained_variance: @explained_variance_ratio[comp_idx],
            top_features: sorted_contributions.first(5),
            all_contributions: contributions
          }
        end

        # Find most important features overall
        overall_importance = Hash.new(0.0)
        @components.each_with_index do |component, comp_idx|
          variance_weight = @explained_variance_ratio[comp_idx]
          component.each_with_index do |weight, feature_idx|
            feature_name = @feature_names[feature_idx]
            overall_importance[feature_name] += weight.abs * variance_weight
          end
        end

        sorted_importance = overall_importance.sort_by { |_, importance| -importance }

        {
          component_contributions: feature_contributions,
          feature_importance: sorted_importance,
          most_important_features: sorted_importance.first(5)
        }
      end

      # Generate educational visualization
      #
      # @return [String] ASCII visualization of PCA results
      #
      def visualize_analysis
        validate_fitted

        visualization = "\n📊 PCA Analysis Visualization\n"
        visualization += "#{'=' * 50}\n\n"

        # Data summary
        visualization += "📈 Data Summary:\n"
        visualization += "  • Original dimensions: #{@n_features}\n"
        visualization += "  • Reduced dimensions: #{@n_components}\n"
        visualization += "  • Samples: #{@n_samples}\n"
        visualization += "  • Dimensionality reduction: #{((@n_features - @n_components).to_f / @n_features * 100).round(2)}%\n\n"

        # Explained variance
        visualization += "🔍 Explained Variance:\n"
        @explained_variance_ratio.each_with_index do |ratio, idx|
          bar_length = (ratio * 50).to_i
          bar = '█' * bar_length
          visualization += "  PC#{idx + 1}: #{(ratio * 100).round(2)}% #{bar}\n"
        end
        visualization += "  Cumulative: #{(@cumulative_variance[@n_components - 1] * 100).round(2)}%\n\n"

        # Component analysis
        if @n_components <= 3
          visualization += "🎯 Principal Components:\n"
          @components.each_with_index do |component, idx|
            visualization += "  PC#{idx + 1} (#{(@explained_variance_ratio[idx] * 100).round(2)}% variance):\n"
            component.each_with_index do |weight, feature_idx|
              feature_name = @feature_names[feature_idx]
              visualization += "    #{feature_name}: #{weight.round(4)}\n"
            end
            visualization += "\n"
          end
        end

        # Recommendations
        visualization += "💡 Recommendations:\n"
        total_variance = @cumulative_variance[@n_components - 1]
        visualization += if total_variance >= 0.95
                           "  • Excellent: #{(total_variance * 100).round(2)}% variance retained\n"
                         elsif total_variance >= 0.90
                           "  • Good: #{(total_variance * 100).round(2)}% variance retained\n"
                         else
                           "  • Consider more components: Only #{(total_variance * 100).round(2)}% variance retained\n"
                         end

        visualization
      end

      private

      # Validate n_components parameter
      def validate_n_components(n_components)
        case n_components
        when Integer
          raise ArgumentError, 'n_components must be positive' if n_components <= 0

          n_components
        when Float
          unless n_components > 0 && n_components <= 1
            raise ArgumentError, 'n_components as float must be between 0 and 1'
          end

          n_components
        else
          raise ArgumentError, 'n_components must be Integer or Float'
        end
      end

      # Validate input data
      def validate_input_data(data)
        raise ArgumentError, 'Data cannot be empty' if data.empty?
        raise ArgumentError, 'Data must be 2D array' unless data.all?(Array)

        first_row_length = data[0].length
        unless data.all? { |row| row.length == first_row_length }
          raise ArgumentError, 'All samples must have the same number of features'
        end

        raise ArgumentError, 'Data must have at least 2 features' if first_row_length < 2
        raise ArgumentError, 'Data must have at least 2 samples' if data.length < 2
      end

      # Validate that model is fitted
      def validate_fitted
        raise 'PCA model must be fitted before use' unless @fitted
      end

      # Determine actual number of components
      def determine_n_components(n_components, n_features)
        case n_components
        when Integer
          [n_components, n_features].min
        when Float
          # For float, we'll determine this after eigendecomposition
          n_features
        end
      end

      # Standardize data (mean=0, std=1)
      def standardize_data(data)
        # Calculate means
        @mean_values = Array.new(@n_features, 0.0)
        data.each do |sample|
          sample.each_with_index do |value, idx|
            @mean_values[idx] += value
          end
        end
        @mean_values.map! { |sum| sum / @n_samples }

        # Calculate standard deviations
        @std_values = Array.new(@n_features, 0.0)
        data.each do |sample|
          sample.each_with_index do |value, idx|
            @std_values[idx] += (value - @mean_values[idx])**2
          end
        end
        @std_values.map! { |sum| Math.sqrt(sum / (@n_samples - 1)) }

        # Avoid division by zero
        @std_values.map! { |std| std < @tolerance ? 1.0 : std }

        # Standardize
        data.map do |sample|
          sample.each_with_index.map do |value, idx|
            (value - @mean_values[idx]) / @std_values[idx]
          end
        end
      end

      # Center data (mean=0)
      def center_data(data)
        # Calculate means
        @mean_values = Array.new(@n_features, 0.0)
        data.each do |sample|
          sample.each_with_index do |value, idx|
            @mean_values[idx] += value
          end
        end
        @mean_values.map! { |sum| sum / @n_samples }

        # Set std_values to 1 for consistency
        @std_values = Array.new(@n_features, 1.0)

        # Center
        data.map do |sample|
          sample.each_with_index.map do |value, idx|
            value - @mean_values[idx]
          end
        end
      end

      # Standardize new data using stored parameters
      def standardize_new_data(data)
        data.map do |sample|
          sample.each_with_index.map do |value, idx|
            (value - @mean_values[idx]) / @std_values[idx]
          end
        end
      end

      # Center new data using stored parameters
      def center_new_data(data)
        data.map do |sample|
          sample.each_with_index.map do |value, idx|
            value - @mean_values[idx]
          end
        end
      end

      # Reverse standardization
      def destandardize_data(data)
        data.map do |sample|
          sample.each_with_index.map do |value, idx|
            (value * @std_values[idx]) + @mean_values[idx]
          end
        end
      end

      # Reverse centering
      def decenter_data(data)
        data.map do |sample|
          sample.each_with_index.map do |value, idx|
            value + @mean_values[idx]
          end
        end
      end

      # Compute covariance matrix
      def compute_covariance_matrix(standardized_data)
        covariance_matrix = Array.new(@n_features) { Array.new(@n_features, 0.0) }

        (0...@n_features).each do |i|
          (0...@n_features).each do |j|
            covariance = 0.0
            standardized_data.each do |sample|
              covariance += sample[i] * sample[j]
            end
            covariance_matrix[i][j] = covariance / (@n_samples - 1)
          end
        end

        covariance_matrix
      end

      # Compute eigenvalues and eigenvectors using power iteration
      def compute_eigendecomposition(matrix)
        eigenvalues = []
        eigenvectors = []

        # Simple eigenvalue decomposition using power iteration
        # For educational purposes - in production, use a proper linear algebra library
        matrix_copy = matrix.map(&:dup)

        (0...@n_features).each do |_|
          eigenvalue, eigenvector = power_iteration(matrix_copy)

          next unless eigenvalue.abs > @tolerance

          eigenvalues << eigenvalue
          eigenvectors << eigenvector

          # Deflate matrix to find next eigenvalue
          matrix_copy = deflate_matrix(matrix_copy, eigenvalue, eigenvector)
        end

        [eigenvalues, eigenvectors]
      end

      # Power iteration to find dominant eigenvalue/eigenvector
      def power_iteration(matrix, max_iterations = 1000)
        # Initialize random vector
        vector = Array.new(@n_features) { rand - 0.5 }

        max_iterations.times do
          # Matrix-vector multiplication
          new_vector = matrix_vector_multiply(matrix, vector)

          # Normalize
          norm = Math.sqrt(new_vector.sum { |v| v * v })
          norm = 1.0 if norm < @tolerance

          new_vector.map! { |v| v / norm }

          # Check convergence
          if vectors_close?(vector, new_vector, @tolerance)
            eigenvalue = dot_product(new_vector, matrix_vector_multiply(matrix, new_vector))
            return [eigenvalue, new_vector]
          end

          vector = new_vector
        end

        # If not converged, return best estimate
        eigenvalue = dot_product(vector, matrix_vector_multiply(matrix, vector))
        [eigenvalue, vector]
      end

      # Deflate matrix by removing found eigenvalue/eigenvector
      def deflate_matrix(matrix, eigenvalue, eigenvector)
        # Subtract eigenvalue * eigenvector * eigenvector^T from matrix
        deflated = matrix.map(&:dup)

        (0...@n_features).each do |i|
          (0...@n_features).each do |j|
            deflated[i][j] -= eigenvalue * eigenvector[i] * eigenvector[j]
          end
        end

        deflated
      end

      # Matrix-vector multiplication
      def matrix_vector_multiply(matrix, vector)
        result = Array.new(@n_features, 0.0)

        (0...@n_features).each do |i|
          (0...@n_features).each do |j|
            result[i] += matrix[i][j] * vector[j]
          end
        end

        result
      end

      # Dot product of two vectors
      def dot_product(vector1, vector2)
        vector1.zip(vector2).sum { |a, b| a * b }
      end

      # Check if two vectors are close
      def vectors_close?(vector1, vector2, tolerance)
        vector1.zip(vector2).all? { |a, b| (a - b).abs < tolerance }
      end

      # Calculate cumulative variance
      def calculate_cumulative_variance(variance_ratios)
        cumulative = []
        sum = 0.0

        variance_ratios.each do |ratio|
          sum += ratio
          cumulative << sum
        end

        cumulative
      end

      # Educational output helper
      def educational_output(title, content)
        return unless @verbose_mode

        puts "\n#{title}"
        puts '=' * title.length
        puts content
      end
    end
  end
end
