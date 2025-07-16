# frozen_string_literal: true

# Support Vector Machine implementation for educational purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'classifier'
require_relative '../data/data_set'

module Ai4r
  module Classifiers
    # Educational Support Vector Machine implementation
    #
    # This implementation focuses on educational clarity and step-by-step learning
    # rather than computational efficiency. It includes multiple kernel functions,
    # soft margin support, and detailed explanations of the SVM algorithm.
    #
    # Educational Features:
    # - Step-by-step training visualization
    # - Support vector identification and explanation
    # - Kernel function exploration
    # - Margin visualization and interpretation
    # - Decision boundary analysis
    #
    # = Usage
    #   svm = SupportVectorMachine.new
    #   svm.configure(kernel: :rbf, c: 1.0, gamma: 0.1)
    #   svm.enable_educational_mode
    #   svm.build(training_data)
    #   prediction = svm.eval([feature_vector])
    class SupportVectorMachine < Classifier
      attr_reader :support_vectors, :alphas, :bias, :kernel_type, :kernel_params, :c_parameter, :training_errors,
                  :support_vector_indices, :educational_mode, :training_steps, :decision_function_values

      def initialize
        # Core SVM parameters
        @kernel_type = :rbf
        @kernel_params = { gamma: 1.0 }
        @c_parameter = 1.0
        @tolerance = 1e-3
        @max_iterations = 1000

        # Educational features
        @educational_mode = false
        @training_steps = []
        @verbose = false
        @step_by_step = false

        # Training results
        @support_vectors = []
        @support_vector_indices = []
        @alphas = []
        @bias = 0.0
        @training_errors = []
        @decision_function_values = []

        # Internal state
        @data_set = nil
        @labels = []
        @gram_matrix = nil
      end

      # Configure SVM parameters with educational explanations
      def configure(params = {})
        params.each do |key, value|
          case key
          when :kernel
            set_kernel(value, params)
          when :c, :C
            set_c_parameter(value)
          when :tolerance
            @tolerance = value
          when :max_iterations
            @max_iterations = value
          when :verbose
            @verbose = value
          when :step_by_step
            @step_by_step = value
          end
        end

        explain_configuration if @educational_mode && @verbose
        self
      end

      # Enable educational mode with detailed explanations
      def enable_educational_mode
        @educational_mode = true
        @verbose = true
        puts "\n=== Educational SVM Mode Activated ==="
        puts 'This mode provides detailed explanations of SVM concepts and training process.'
        puts "You'll see step-by-step algorithm execution and conceptual insights."
        self
      end

      # Train the SVM using Sequential Minimal Optimization (SMO)
      def build(data_set)
        @data_set = data_set
        prepare_training_data

        puts "\n=== Starting SVM Training ===" if @verbose
        puts "Training examples: #{@training_data.length}" if @verbose
        puts "Features: #{@training_data.first.length}" if @verbose
        puts "Kernel: #{@kernel_type}" if @verbose
        puts "C parameter: #{@c_parameter}" if @verbose

        if @educational_mode
          explain_svm_concepts
          build_with_educational_steps
        else
          build_normal
        end

        finalize_training
        self
      end

      # Predict class for new data point
      def eval(data_item)
        return nil unless trained?

        decision_value = decision_function(data_item)
        @decision_function_values << decision_value if @educational_mode

        prediction = decision_value >= 0 ? @class_labels[1] : @class_labels[0]

        explain_prediction(data_item, decision_value, prediction) if @educational_mode && @verbose

        prediction
      end

      # Get decision function value (distance from hyperplane)
      def decision_function(data_item)
        return 0.0 unless trained?

        result = @bias
        @support_vectors.each_with_index do |sv, idx|
          result += @alphas[idx] * @labels[@support_vector_indices[idx]] *
                    kernel_function(sv, data_item)
        end
        result
      end

      # Get prediction with confidence score
      def predict_with_confidence(data_item)
        decision_value = decision_function(data_item)
        prediction = decision_value >= 0 ? @class_labels[1] : @class_labels[0]
        confidence = Math.tanh(decision_value.abs) # Sigmoid-like confidence

        {
          prediction: prediction,
          decision_value: decision_value,
          confidence: confidence,
          distance_from_margin: decision_value.abs
        }
      end

      # Identify and return support vectors with explanations
      def get_support_vectors_info
        return {} unless trained?

        info = {
          count: @support_vectors.length,
          percentage: (@support_vectors.length.to_f / @training_data.length * 100).round(2),
          indices: @support_vector_indices,
          alpha_values: @alphas,
          support_vectors: @support_vectors
        }

        if @educational_mode
          puts "\n=== Support Vectors Analysis ==="
          puts "Total support vectors: #{info[:count]} (#{info[:percentage]}% of training data)"
          puts 'Support vectors are the critical examples that define the decision boundary.'
          puts 'They lie on or within the margin and determine the classifier.'
        end

        info
      end

      # Visualize decision boundary (for 2D data)
      def visualize_decision_boundary(resolution = 100)
        return unless @training_data.first.length == 2

        puts "\n=== Decision Boundary Visualization ==="
        puts "Generating #{resolution}x#{resolution} grid for visualization..."

        # Find data bounds
        x_min, x_max = @training_data.map { |point| point[0] }.minmax
        y_min, y_max = @training_data.map { |point| point[1] }.minmax

        # Add padding
        x_padding = (x_max - x_min) * 0.1
        y_padding = (y_max - y_min) * 0.1
        x_min -= x_padding
        x_max += x_padding
        y_min -= y_padding
        y_max += y_padding

        # Generate grid
        grid_points = []
        resolution.times do |i|
          resolution.times do |j|
            x = x_min + ((x_max - x_min) * i / (resolution - 1))
            y = y_min + ((y_max - y_min) * j / (resolution - 1))
            grid_points << [x, y]
          end
        end

        # Calculate decision values for grid
        decision_values = grid_points.map { |point| decision_function(point) }

        {
          x_range: [x_min, x_max],
          y_range: [y_min, y_max],
          grid_points: grid_points,
          decision_values: decision_values,
          resolution: resolution
        }
      end

      # Calculate margin width
      def get_margin_width
        return 0.0 unless trained?

        # For linear SVM, margin width = 2 / ||w||
        # For non-linear, we approximate using support vectors
        if @kernel_type == :linear
          weight_norm = calculate_weight_vector_norm
          margin_width = 2.0 / weight_norm
        else
          margin_width = estimate_margin_width_nonlinear
        end

        if @educational_mode
          puts "\n=== Margin Analysis ==="
          puts "Estimated margin width: #{margin_width.round(4)}"
          puts 'Wider margins indicate better generalization (lower complexity).'
          puts 'The margin is the distance between the decision boundary and nearest points.'
        end

        margin_width
      end

      private

      def set_kernel(kernel_type, params = {})
        @kernel_type = kernel_type

        case kernel_type
        when :linear
          @kernel_params = {}
        when :polynomial, :poly
          @kernel_params = {
            degree: params[:degree] || 3,
            coef0: params[:coef0] || 1.0
          }
        when :rbf, :gaussian
          @kernel_params = {
            gamma: params[:gamma] || ((1.0 / @training_data&.first&.length) || 1.0)
          }
        when :sigmoid
          @kernel_params = {
            gamma: params[:gamma] || 1.0,
            coef0: params[:coef0] || 0.0
          }
        else
          raise ArgumentError, "Unsupported kernel type: #{kernel_type}"
        end
      end

      def set_c_parameter(c_value)
        raise ArgumentError, 'C parameter must be positive' if c_value <= 0

        @c_parameter = c_value
      end

      def prepare_training_data
        @training_data = @data_set.data_items.map { |item| item[0...-1] }
        raw_labels = @data_set.data_items.map(&:last)
        @class_labels = raw_labels.uniq

        raise ArgumentError, 'SVM requires exactly 2 classes' unless @class_labels.length == 2

        # Convert to {-1, +1} labels
        @labels = raw_labels.map { |label| label == @class_labels[1] ? 1 : -1 }

        # Pre-compute Gram matrix for efficiency
        compute_gram_matrix if @educational_mode
      end

      def compute_gram_matrix
        puts 'Computing Gram matrix...' if @verbose
        n = @training_data.length
        @gram_matrix = Array.new(n) { Array.new(n) }

        n.times do |i|
          n.times do |j|
            @gram_matrix[i][j] = kernel_function(@training_data[i], @training_data[j])
          end
        end
      end

      def kernel_function(x1, x2)
        case @kernel_type
        when :linear
          linear_kernel(x1, x2)
        when :polynomial, :poly
          polynomial_kernel(x1, x2)
        when :rbf, :gaussian
          rbf_kernel(x1, x2)
        when :sigmoid
          sigmoid_kernel(x1, x2)
        else
          raise ArgumentError, "Unknown kernel type: #{@kernel_type}"
        end
      end

      def linear_kernel(x1, x2)
        x1.zip(x2).sum { |a, b| a * b }
      end

      def polynomial_kernel(x1, x2)
        dot_product = linear_kernel(x1, x2)
        (dot_product + @kernel_params[:coef0])**@kernel_params[:degree]
      end

      def rbf_kernel(x1, x2)
        squared_distance = x1.zip(x2).sum { |a, b| (a - b)**2 }
        Math.exp(-@kernel_params[:gamma] * squared_distance)
      end

      def sigmoid_kernel(x1, x2)
        dot_product = linear_kernel(x1, x2)
        Math.tanh((@kernel_params[:gamma] * dot_product) + @kernel_params[:coef0])
      end

      def explain_svm_concepts
        puts "\n=== SVM Educational Concepts ==="
        puts "\n1. SUPPORT VECTOR MACHINE OVERVIEW:"
        puts '   - SVMs find the optimal hyperplane that separates classes'
        puts '   - The hyperplane maximizes the margin (distance to nearest points)'
        puts '   - Only support vectors (nearest points) affect the final model'
        puts '   - Kernel trick allows non-linear decision boundaries'

        puts "\n2. KEY PARAMETERS:"
        puts '   - C parameter: Controls trade-off between margin size and training errors'
        puts '     * High C: Hard margin, low training error, may overfit'
        puts '     * Low C: Soft margin, allows some errors, better generalization'
        puts '   - Kernel: Determines the type of decision boundary'
        puts '     * Linear: Straight line/hyperplane boundary'
        puts '     * RBF: Smooth, non-linear boundaries'
        puts '     * Polynomial: Non-linear with specific degree'

        puts "\n3. TRAINING PROCESS:"
        puts '   - Find alpha values for each training example'
        puts '   - Non-zero alphas correspond to support vectors'
        puts '   - Calculate bias term for final decision function'
        puts '   - Decision function: f(x) = Σ(αᵢ * yᵢ * K(xᵢ, x)) + b'
      end

      def build_with_educational_steps
        puts "\n=== Step-by-Step SVM Training ==="

        # Initialize alphas
        @alphas = Array.new(@training_data.length, 0.0)
        @bias = 0.0

        iteration = 0
        changed_alphas = 0

        while iteration < @max_iterations && (changed_alphas > 0 || iteration == 0)
          changed_alphas = 0

          puts "\n--- Iteration #{iteration + 1} ---" if @verbose

          @training_data.length.times do |i|
            # Calculate prediction error
            error_i = decision_function_for_training(i) - @labels[i]

            # Check KKT conditions
            next unless violates_kkt_conditions(i, error_i)

            # Select second alpha using heuristic
            j = select_second_alpha(i, error_i)
            next if j == i

            # Optimize alpha pair
            next unless optimize_alpha_pair(i, j)

            changed_alphas += 1

            next unless @step_by_step

            puts "  Updated alphas for examples #{i} and #{j}"
            puts '  Press Enter to continue...'
            gets
          end

          if @verbose
            sv_count = @alphas.count { |alpha| alpha > @tolerance }
            puts "  Support vectors found: #{sv_count}"
            puts "  Alphas changed: #{changed_alphas}"
          end

          iteration += 1
          @training_steps << {
            iteration: iteration,
            support_vectors: @alphas.count { |alpha| alpha > @tolerance },
            bias: @bias,
            changed_alphas: changed_alphas
          }
        end

        puts "\nTraining completed after #{iteration} iterations" if @verbose
      end

      def build_normal
        # Simplified SMO implementation for non-educational mode
        @alphas = Array.new(@training_data.length, 0.0)
        @bias = 0.0

        # This would contain the full SMO algorithm
        # For educational purposes, we'll use a simplified version
        simple_smo_algorithm
      end

      def simple_smo_algorithm
        # Placeholder for full SMO implementation
        # This is a simplified version for educational clarity

        max_iter = [@max_iterations, 100].min
        max_iter.times do |_iteration|
          alpha_changed = 0

          @training_data.length.times do |i|
            error_i = decision_function_for_training(i) - @labels[i]

            next unless (@labels[i] * error_i < -@tolerance && @alphas[i] < @c_parameter) ||
                        (@labels[i] * error_i > @tolerance && @alphas[i] > 0)

            j = rand(@training_data.length)
            next if i == j

            alpha_changed += 1 if optimize_alpha_pair(i, j)
          end

          break if alpha_changed == 0
        end
      end

      def decision_function_for_training(i)
        result = @bias
        @training_data.length.times do |j|
          next unless @alphas[j] > 0

          kernel_val = if @gram_matrix
                         @gram_matrix[j][i]
                       else
                         kernel_function(@training_data[j], @training_data[i])
                       end
          result += @alphas[j] * @labels[j] * kernel_val
        end
        result
      end

      def violates_kkt_conditions(i, error_i)
        (@labels[i] * error_i < -@tolerance && @alphas[i] < @c_parameter) ||
          (@labels[i] * error_i > @tolerance && @alphas[i] > 0)
      end

      def select_second_alpha(i, _error_i)
        # Simple heuristic: choose random second alpha
        candidates = (0...@training_data.length).to_a - [i]
        candidates.sample
      end

      def optimize_alpha_pair(i, j)
        return false if i == j

        alpha_i_old = @alphas[i]
        alpha_j_old = @alphas[j]

        # Calculate bounds
        if @labels[i] == @labels[j]
          l = [0, @alphas[i] + @alphas[j] - @c_parameter].max
          h = [@c_parameter, @alphas[i] + @alphas[j]].min
        else
          l = [0, @alphas[j] - @alphas[i]].max
          h = [@c_parameter, @c_parameter + @alphas[j] - @alphas[i]].min
        end

        return false if l >= h

        # Calculate kernel values
        k_ii = @gram_matrix ? @gram_matrix[i][i] : kernel_function(@training_data[i], @training_data[i])
        k_jj = @gram_matrix ? @gram_matrix[j][j] : kernel_function(@training_data[j], @training_data[j])
        k_ij = @gram_matrix ? @gram_matrix[i][j] : kernel_function(@training_data[i], @training_data[j])

        eta = k_ii + k_jj - (2 * k_ij)
        return false if eta <= 0

        # Calculate errors
        error_i = decision_function_for_training(i) - @labels[i]
        error_j = decision_function_for_training(j) - @labels[j]

        # Update alpha_j
        @alphas[j] = alpha_j_old + (@labels[j] * (error_i - error_j) / eta)

        # Clip alpha_j
        @alphas[j] = [@alphas[j], h].min
        @alphas[j] = [@alphas[j], l].max

        return false if (@alphas[j] - alpha_j_old).abs < @tolerance

        # Update alpha_i
        @alphas[i] = alpha_i_old + (@labels[i] * @labels[j] * (alpha_j_old - @alphas[j]))

        # Update bias
        update_bias(i, j, error_i, error_j, alpha_i_old, alpha_j_old, k_ii, k_jj, k_ij)

        true
      end

      def update_bias(i, j, error_i, error_j, alpha_i_old, alpha_j_old, k_ii, k_jj, k_ij)
        b1 = @bias - error_i - (@labels[i] * (@alphas[i] - alpha_i_old) * k_ii) -
             (@labels[j] * (@alphas[j] - alpha_j_old) * k_ij)

        b2 = @bias - error_j - (@labels[i] * (@alphas[i] - alpha_i_old) * k_ij) -
             (@labels[j] * (@alphas[j] - alpha_j_old) * k_jj)

        @bias = if @alphas[i] > 0 && @alphas[i] < @c_parameter
                  b1
                elsif @alphas[j] > 0 && @alphas[j] < @c_parameter
                  b2
                else
                  (b1 + b2) / 2.0
                end
      end

      def finalize_training
        # Extract support vectors
        @support_vectors = []
        @support_vector_indices = []

        @alphas.each_with_index do |alpha, idx|
          next unless alpha > @tolerance

          @support_vectors << @training_data[idx]
          @support_vector_indices << idx
          @alphas[@support_vector_indices.length - 1] = alpha
        end

        # Keep only non-zero alphas
        @alphas = @alphas.select { |alpha| alpha > @tolerance }

        return unless @verbose

        puts "\n=== Training Results ==="
        puts "Support vectors: #{@support_vectors.length}/#{@training_data.length}"
        puts "Final bias: #{@bias.round(4)}"
        puts "Margin width: #{get_margin_width.round(4)}"
      end

      def explain_prediction(data_item, decision_value, prediction)
        puts "\n=== Prediction Explanation ==="
        puts "Input: #{data_item.inspect}"
        puts "Decision function value: #{decision_value.round(4)}"
        puts "Prediction: #{prediction}"
        puts "\nDecision rule:"
        puts '  f(x) = Σ(αᵢ * yᵢ * K(support_vectorᵢ, x)) + bias'
        puts "  f(x) = #{decision_value.round(4)}"
        puts "  Class = #{decision_value >= 0 ? '+1' : '-1'} → '#{prediction}'"
        puts "\nInterpretation:"
        puts "  Distance from hyperplane: #{decision_value.abs.round(4)}"
        puts "  Confidence: #{Math.tanh(decision_value.abs).round(4)}"
      end

      def explain_configuration
        puts "\n=== SVM Configuration Explanation ==="
        puts "Kernel: #{@kernel_type}"

        case @kernel_type
        when :linear
          puts '  - Creates linear decision boundaries'
          puts '  - Fastest training and prediction'
          puts '  - Good for linearly separable data'
        when :rbf
          puts '  - Creates smooth, non-linear boundaries'
          puts "  - Gamma = #{@kernel_params[:gamma]} (higher = more complex boundaries)"
          puts '  - Most popular choice for non-linear data'
        when :polynomial
          puts '  - Creates polynomial decision boundaries'
          puts "  - Degree = #{@kernel_params[:degree]}"
          puts '  - Good for polynomial relationships'
        end

        puts "\nC parameter: #{@c_parameter}"
        puts '  - Higher C: Stricter margin, may overfit'
        puts '  - Lower C: Softer margin, better generalization'
      end

      def trained?
        !@support_vectors.empty?
      end

      def calculate_weight_vector_norm
        # Only applicable for linear kernel
        return 0.0 unless @kernel_type == :linear

        weight_vector = Array.new(@training_data.first.length, 0.0)
        @support_vectors.each_with_index do |sv, idx|
          alpha = @alphas[idx]
          label = @labels[@support_vector_indices[idx]]
          sv.each_with_index do |feature, feat_idx|
            weight_vector[feat_idx] += alpha * label * feature
          end
        end

        Math.sqrt(weight_vector.sum { |w| w * w })
      end

      def estimate_margin_width_nonlinear
        # Estimate margin using support vectors
        return 0.0 if @support_vectors.length < 2

        # Find minimum distance between support vectors of different classes
        min_distance = Float::INFINITY

        @support_vectors.each_with_index do |sv1, i|
          label1 = @labels[@support_vector_indices[i]]
          @support_vectors.each_with_index do |sv2, j|
            next if i >= j

            label2 = @labels[@support_vector_indices[j]]
            next if label1 == label2

            # Calculate distance in feature space (approximation)
            distance = Math.sqrt(sv1.zip(sv2).sum { |a, b| (a - b)**2 })
            min_distance = [min_distance, distance].min
          end
        end

        min_distance == Float::INFINITY ? 0.0 : min_distance
      end
    end
  end
end
