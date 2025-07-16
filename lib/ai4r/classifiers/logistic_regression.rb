# frozen_string_literal: true

# Logistic Regression implementation for educational purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'classifier'
require_relative '../data/data_set'

module Ai4r
  module Classifiers
    # Educational Logistic Regression implementation
    #
    # Implements logistic regression with gradient descent optimization,
    # regularization techniques, and comprehensive educational features.
    # Designed for binary and multinomial classification.
    #
    # Educational Features:
    # - Step-by-step gradient descent visualization
    # - Cost function monitoring and explanation
    # - Regularization effects demonstration
    # - Feature importance analysis
    # - Probability interpretation
    #
    # = Usage
    #   lr = LogisticRegression.new
    #   lr.configure(learning_rate: 0.01, regularization: :l2, lambda: 0.1)
    #   lr.enable_educational_mode
    #   lr.build(training_data)
    #   prediction = lr.eval([feature_vector])
    class LogisticRegression < Classifier
      attr_reader :weights, :bias, :learning_rate, :regularization_type, :lambda, :cost_history, :iteration_count,
                  :feature_importance, :educational_mode, :training_steps, :class_labels

      def initialize
        super
        # Model parameters
        @weights = []
        @bias = 0.0

        # Training hyperparameters
        @learning_rate = 0.01
        @max_iterations = 1000
        @tolerance = 1e-6
        @regularization_type = :none
        @lambda = 0.0

        # Educational features
        @educational_mode = false
        @verbose = false
        @step_by_step = false
        @plot_cost = false

        # Training monitoring
        @cost_history = []
        @training_steps = []
        @iteration_count = 0
        @converged = false

        # Data processing
        @feature_means = []
        @feature_stds = []
        @normalize_features = true
        @add_bias_term = true

        # Results
        @feature_importance = []
        @class_labels = []
        @classification_type = :binary
      end

      # Configure logistic regression parameters
      def configure(params = {})
        params.each do |key, value|
          case key
          when :learning_rate, :lr
            set_learning_rate(value)
          when :max_iterations, :max_iter
            @max_iterations = value
          when :tolerance, :tol
            @tolerance = value
          when :regularization, :reg
            set_regularization(value, params[:lambda] || params[:l] || 0.1)
          when :lambda, :l
            @lambda = value
          when :normalize_features, :normalize
            @normalize_features = value
          when :verbose
            @verbose = value
          when :step_by_step
            @step_by_step = value
          when :plot_cost
            @plot_cost = value
          end
        end

        explain_configuration if @educational_mode && @verbose
        self
      end

      # Enable educational mode with detailed explanations
      def enable_educational_mode
        @educational_mode = true
        @verbose = true
        puts "\n=== Educational Logistic Regression Mode Activated ==="
        puts 'This mode provides detailed explanations of logistic regression concepts.'
        puts "You'll see gradient descent steps, cost function evolution, and feature analysis."
        self
      end

      # Train the logistic regression model
      def build(data_set)
        prepare_training_data(data_set)

        puts "\n=== Starting Logistic Regression Training ===" if @verbose
        puts "Training examples: #{@training_data.length}" if @verbose
        puts "Features: #{@num_features}" if @verbose
        puts "Classes: #{@class_labels.inspect}" if @verbose
        puts "Classification type: #{@classification_type}" if @verbose

        if @educational_mode
          explain_logistic_regression_concepts
          train_with_educational_steps
        else
          train_normal
        end

        finalize_training
        self
      end

      # Predict class for new data point
      def eval(data_item)
        return nil unless trained?

        processed_item = preprocess_features(data_item)

        if @classification_type == :binary
          probability = predict_probability(processed_item)
          prediction = probability >= 0.5 ? @class_labels[1] : @class_labels[0]

          explain_binary_prediction(data_item, processed_item, probability, prediction) if @educational_mode && @verbose

        else
          # Multinomial classification
          probabilities = predict_probabilities_multinomial(processed_item)
          prediction_index = probabilities.each_with_index.max[1]
          prediction = @class_labels[prediction_index]

          explain_multinomial_prediction(data_item, probabilities, prediction) if @educational_mode && @verbose

        end
        prediction
      end

      # Get prediction with probability scores
      def predict_with_probabilities(data_item)
        return nil unless trained?

        processed_item = preprocess_features(data_item)

        if @classification_type == :binary
          prob_positive = predict_probability(processed_item)
          prob_negative = 1.0 - prob_positive
          prediction = prob_positive >= 0.5 ? @class_labels[1] : @class_labels[0]

          {
            prediction: prediction,
            probabilities: {
              @class_labels[0] => prob_negative,
              @class_labels[1] => prob_positive
            },
            confidence: [prob_positive, prob_negative].max
          }
        else
          probabilities = predict_probabilities_multinomial(processed_item)
          prediction_index = probabilities.each_with_index.max[1]
          prediction = @class_labels[prediction_index]

          prob_hash = {}
          @class_labels.each_with_index { |label, i| prob_hash[label] = probabilities[i] }

          {
            prediction: prediction,
            probabilities: prob_hash,
            confidence: probabilities.max
          }
        end
      end

      # Calculate feature importance scores
      def calculate_feature_importance
        return [] unless trained?

        if @classification_type == :binary
          # For binary classification, use absolute weights
          @feature_importance = @weights.map(&:abs)
        else
          # For multinomial, average across all classes
          @feature_importance = Array.new(@num_features, 0.0)
          @weights.each do |class_weights|
            class_weights.each_with_index do |weight, idx|
              @feature_importance[idx] += weight.abs
            end
          end
          @feature_importance.map! { |importance| importance / @class_labels.length }
        end

        explain_feature_importance if @educational_mode

        @feature_importance
      end

      # Plot cost function history
      def plot_cost_history
        return if @cost_history.empty?

        puts "\n=== Cost Function History ==="
        puts 'Iteration | Cost      | Change'
        puts '----------|-----------|----------'

        @cost_history.each_with_index do |cost, idx|
          change = idx > 0 ? @cost_history[idx] - @cost_history[idx - 1] : 0.0
          puts format('%9d | %9.6f | %+9.6f', idx + 1, cost, change)
        end

        puts "\nFinal cost: #{@cost_history.last.round(6)}"
        puts "Converged: #{@converged ? 'Yes' : 'No'}"
        puts "Total iterations: #{@iteration_count}"
      end

      # Evaluate model performance on test set
      def evaluate_performance(test_set)
        return nil unless trained?

        predictions = []
        actual_labels = []
        probabilities = []

        test_set.data_items.each do |item|
          features = item[0...-1]
          actual_class = item.last

          result = predict_with_probabilities(features)
          predictions << result[:prediction]
          actual_labels << actual_class
          probabilities << result[:probabilities]
        end

        # Calculate metrics
        accuracy = calculate_accuracy(predictions, actual_labels)
        log_loss = calculate_log_loss(actual_labels, probabilities)
        class_metrics = calculate_class_metrics(predictions, actual_labels)

        performance = {
          accuracy: accuracy,
          log_loss: log_loss,
          class_metrics: class_metrics,
          predictions: predictions,
          actual_labels: actual_labels,
          test_size: test_set.data_items.length
        }

        explain_performance_metrics(performance) if @educational_mode

        performance
      end

      private

      def set_learning_rate(lr)
        raise ArgumentError, 'Learning rate must be positive' if lr <= 0

        @learning_rate = lr
      end

      def set_regularization(reg_type, lambda_value)
        @regularization_type = reg_type
        @lambda = lambda_value

        unless %i[none l1 l2 elastic_net].include?(reg_type)
          raise ArgumentError, "Unsupported regularization: #{reg_type}"
        end
      end

      def prepare_training_data(data_set)
        @data_set = data_set
        @training_data = data_set.data_items.map { |item| item[0...-1] }
        raw_labels = data_set.data_items.map(&:last)

        @class_labels = raw_labels.uniq.sort
        @classification_type = @class_labels.length == 2 ? :binary : :multinomial

        # Convert labels to appropriate format
        if @classification_type == :binary
          @labels = raw_labels.map { |label| label == @class_labels[1] ? 1 : 0 }
        else
          # One-hot encoding for multinomial
          @labels = []
          raw_labels.each do |label|
            one_hot = Array.new(@class_labels.length, 0)
            one_hot[@class_labels.index(label)] = 1
            @labels << one_hot
          end
        end

        @num_features = @training_data.first.length

        # Normalize features if requested
        normalize_training_features if @normalize_features

        # Initialize weights
        initialize_weights
      end

      def normalize_training_features
        puts 'Normalizing features...' if @verbose

        @feature_means = Array.new(@num_features, 0.0)
        @feature_stds = Array.new(@num_features, 0.0)

        # Calculate means
        @training_data.each do |example|
          example.each_with_index do |feature, idx|
            @feature_means[idx] += feature
          end
        end
        @feature_means.map! { |mean| mean / @training_data.length }

        # Calculate standard deviations
        @training_data.each do |example|
          example.each_with_index do |feature, idx|
            @feature_stds[idx] += (feature - @feature_means[idx])**2
          end
        end
        @feature_stds.map! { |var| Math.sqrt(var / @training_data.length) }

        # Normalize training data
        @training_data.each do |example|
          example.each_with_index do |feature, idx|
            std = @feature_stds[idx]
            example[idx] = std > 0 ? (feature - @feature_means[idx]) / std : 0.0
          end
        end
      end

      def preprocess_features(data_item)
        processed = data_item.dup

        if @normalize_features
          processed.each_with_index do |feature, idx|
            std = @feature_stds[idx]
            processed[idx] = std > 0 ? (feature - @feature_means[idx]) / std : 0.0
          end
        end

        processed
      end

      def initialize_weights
        # Initialize weights with small random values
        if @classification_type == :binary
          @weights = Array.new(@num_features) { rand(-0.01..0.01) }
          @bias = 0.0
        else
          # For multinomial: weights matrix [num_classes x num_features]
          @weights = Array.new(@class_labels.length) do
            Array.new(@num_features) { rand(-0.01..0.01) }
          end
          @bias = Array.new(@class_labels.length, 0.0)
        end
      end

      def explain_logistic_regression_concepts
        puts "\n=== Logistic Regression Educational Concepts ==="
        puts "\n1. LOGISTIC REGRESSION OVERVIEW:"
        puts '   - Uses logistic (sigmoid) function to model probabilities'
        puts '   - Output is always between 0 and 1 (probability)'
        puts '   - Decision boundary is linear in feature space'
        puts '   - Uses maximum likelihood estimation for training'

        puts "\n2. SIGMOID FUNCTION:"
        puts '   - σ(z) = 1 / (1 + e^(-z))'
        puts '   - Maps any real number to [0, 1] range'
        puts '   - z = w₀ + w₁x₁ + w₂x₂ + ... + wₙxₙ (linear combination)'

        puts "\n3. COST FUNCTION (LOG-LIKELIHOOD):"
        puts '   - J(w) = -Σ[y*log(h(x)) + (1-y)*log(1-h(x))]'
        puts '   - Convex function (guaranteed global minimum)'
        puts '   - Penalizes confident wrong predictions heavily'

        puts "\n4. GRADIENT DESCENT:"
        puts '   - Updates weights: w := w - α * ∇J(w)'
        puts '   - Learning rate (α) controls step size'
        puts '   - Converges to optimal solution'

        puts "\n5. REGULARIZATION:"
        case @regularization_type
        when :l1
          puts '   - L1 (Lasso): Adds |w| penalty → sparse solutions'
        when :l2
          puts '   - L2 (Ridge): Adds w² penalty → prevents overfitting'
        when :elastic_net
          puts '   - Elastic Net: Combines L1 and L2 penalties'
        else
          puts '   - None: No regularization (may overfit with many features)'
        end
      end

      def train_with_educational_steps
        puts "\n=== Step-by-Step Training Process ==="

        @iteration_count = 0
        prev_cost = Float::INFINITY

        @max_iterations.times do |iteration|
          @iteration_count = iteration + 1

          # Forward pass: calculate predictions and cost
          if @classification_type == :binary
            cost = calculate_cost_binary
            gradients = calculate_gradients_binary
          else
            cost = calculate_cost_multinomial
            gradients = calculate_gradients_multinomial
          end

          @cost_history << cost

          if @verbose && (iteration % 100 == 0 || iteration < 10)
            puts "\n--- Iteration #{iteration + 1} ---"
            puts "Cost: #{cost.round(6)}"
            puts "Cost change: #{(cost - prev_cost).round(6)}" if iteration > 0

            if @classification_type == :binary
              puts "Weights: #{@weights.map { |w| w.round(4) }.inspect}"
              puts "Bias: #{@bias.round(4)}"
            end
          end

          # Update weights using gradients
          update_weights(gradients)

          # Record training step
          @training_steps << {
            iteration: iteration + 1,
            cost: cost,
            weights: @weights.dup,
            bias: @bias.dup
          }

          if @step_by_step && iteration < 5
            puts 'Press Enter to continue to next iteration...'
            gets
          end

          # Check convergence
          if (prev_cost - cost).abs < @tolerance
            @converged = true
            puts "\nConverged after #{iteration + 1} iterations!" if @verbose
            break
          end

          prev_cost = cost
        end

        puts "\nTraining completed!" if @verbose
        puts "Final cost: #{@cost_history.last.round(6)}" if @verbose
      end

      def train_normal
        # Regular training without educational output
        @iteration_count = 0
        prev_cost = Float::INFINITY

        @max_iterations.times do |iteration|
          @iteration_count = iteration + 1

          if @classification_type == :binary
            cost = calculate_cost_binary
            gradients = calculate_gradients_binary
          else
            cost = calculate_cost_multinomial
            gradients = calculate_gradients_multinomial
          end

          @cost_history << cost
          update_weights(gradients)

          if (prev_cost - cost).abs < @tolerance
            @converged = true
            break
          end

          prev_cost = cost
        end
      end

      def sigmoid(z)
        # Numerical stability improvement
        if z > 500
          1.0
        elsif z < -500
          0.0
        else
          1.0 / (1.0 + Math.exp(-z))
        end
      end

      def softmax(z_vector)
        # Numerical stability: subtract max
        max_z = z_vector.max
        exp_z = z_vector.map { |z| Math.exp(z - max_z) }
        sum_exp = exp_z.sum
        exp_z.map { |exp_zi| exp_zi / sum_exp }
      end

      def calculate_cost_binary
        total_cost = 0.0

        @training_data.each_with_index do |example, idx|
          z = @bias + example.zip(@weights).sum { |x, w| x * w }
          prediction = sigmoid(z)

          # Avoid log(0) by clipping
          prediction = [[prediction, 1e-15].max, 1 - 1e-15].min

          y = @labels[idx]
          cost = (-y * Math.log(prediction)) - ((1 - y) * Math.log(1 - prediction))
          total_cost += cost
        end

        # Add regularization penalty
        total_cost /= @training_data.length
        total_cost += regularization_penalty

        total_cost
      end

      def calculate_gradients_binary
        weight_gradients = Array.new(@num_features, 0.0)
        bias_gradient = 0.0

        @training_data.each_with_index do |example, idx|
          z = @bias + example.zip(@weights).sum { |x, w| x * w }
          prediction = sigmoid(z)
          error = prediction - @labels[idx]

          # Weight gradients
          example.each_with_index do |feature, feat_idx|
            weight_gradients[feat_idx] += error * feature
          end

          # Bias gradient
          bias_gradient += error
        end

        # Average and add regularization
        weight_gradients.map! { |grad| grad / @training_data.length }
        bias_gradient /= @training_data.length

        # Add regularization gradients
        add_regularization_gradients(weight_gradients)

        { weights: weight_gradients, bias: bias_gradient }
      end

      def calculate_cost_multinomial
        total_cost = 0.0

        @training_data.each_with_index do |example, idx|
          z_values = Array.new(@class_labels.length)

          # Calculate z for each class
          @class_labels.length.times do |class_idx|
            z = @bias[class_idx] +
                example.zip(@weights[class_idx]).sum { |x, w| x * w }
            z_values[class_idx] = z
          end

          # Apply softmax
          probabilities = softmax(z_values)

          # Calculate cross-entropy loss
          @class_labels.length.times do |class_idx|
            y = @labels[idx][class_idx]
            next unless y == 1

            prob = [probabilities[class_idx], 1e-15].max
            total_cost -= Math.log(prob)
            break
          end
        end

        total_cost /= @training_data.length
        total_cost += regularization_penalty_multinomial

        total_cost
      end

      def calculate_gradients_multinomial
        weight_gradients = Array.new(@class_labels.length) do
          Array.new(@num_features, 0.0)
        end
        bias_gradients = Array.new(@class_labels.length, 0.0)

        @training_data.each_with_index do |example, idx|
          z_values = Array.new(@class_labels.length)

          # Forward pass
          @class_labels.length.times do |class_idx|
            z = @bias[class_idx] +
                example.zip(@weights[class_idx]).sum { |x, w| x * w }
            z_values[class_idx] = z
          end

          probabilities = softmax(z_values)

          # Calculate gradients for each class
          @class_labels.length.times do |class_idx|
            error = probabilities[class_idx] - @labels[idx][class_idx]

            # Weight gradients
            example.each_with_index do |feature, feat_idx|
              weight_gradients[class_idx][feat_idx] += error * feature
            end

            # Bias gradients
            bias_gradients[class_idx] += error
          end
        end

        # Average gradients
        weight_gradients.each do |class_weights|
          class_weights.map! { |grad| grad / @training_data.length }
        end
        bias_gradients.map! { |grad| grad / @training_data.length }

        # Add regularization
        add_regularization_gradients_multinomial(weight_gradients)

        { weights: weight_gradients, bias: bias_gradients }
      end

      def update_weights(gradients)
        if @classification_type == :binary
          @weights.each_with_index do |_weight, idx|
            @weights[idx] -= @learning_rate * gradients[:weights][idx]
          end
          @bias -= @learning_rate * gradients[:bias]
        else
          @weights.each_with_index do |class_weights, class_idx|
            class_weights.each_with_index do |_weight, feat_idx|
              @weights[class_idx][feat_idx] -= @learning_rate * gradients[:weights][class_idx][feat_idx]
            end
            @bias[class_idx] -= @learning_rate * gradients[:bias][class_idx]
          end
        end
      end

      def regularization_penalty
        return 0.0 if @regularization_type == :none || @lambda == 0.0

        case @regularization_type
        when :l1
          @lambda * @weights.sum(&:abs)
        when :l2
          @lambda * @weights.sum { |w| w * w } / 2.0
        when :elastic_net
          l1_penalty = @lambda * 0.5 * @weights.sum(&:abs)
          l2_penalty = @lambda * 0.5 * @weights.sum { |w| w * w } / 2.0
          l1_penalty + l2_penalty
        else
          0.0
        end
      end

      def regularization_penalty_multinomial
        return 0.0 if @regularization_type == :none || @lambda == 0.0

        case @regularization_type
        when :l1
          @lambda * @weights.sum { |class_weights| class_weights.sum(&:abs) }
        when :l2
          @lambda * @weights.sum { |class_weights| class_weights.sum { |w| w * w } } / 2.0
        else
          0.0
        end
      end

      def add_regularization_gradients(weight_gradients)
        return if @regularization_type == :none || @lambda == 0.0

        case @regularization_type
        when :l1
          weight_gradients.each_with_index do |_grad, idx|
            weight_gradients[idx] += @lambda * (@weights[idx] <=> 0)
          end
        when :l2
          weight_gradients.each_with_index do |_grad, idx|
            weight_gradients[idx] += @lambda * @weights[idx]
          end
        end
      end

      def add_regularization_gradients_multinomial(weight_gradients)
        return if @regularization_type == :none || @lambda == 0.0

        case @regularization_type
        when :l1
          weight_gradients.each_with_index do |class_gradients, class_idx|
            class_gradients.each_with_index do |_grad, feat_idx|
              weight_gradients[class_idx][feat_idx] += @lambda * (@weights[class_idx][feat_idx] <=> 0)
            end
          end
        when :l2
          weight_gradients.each_with_index do |class_gradients, class_idx|
            class_gradients.each_with_index do |_grad, feat_idx|
              weight_gradients[class_idx][feat_idx] += @lambda * @weights[class_idx][feat_idx]
            end
          end
        end
      end

      def predict_probability(features)
        z = @bias + features.zip(@weights).sum { |x, w| x * w }
        sigmoid(z)
      end

      def predict_probabilities_multinomial(features)
        z_values = Array.new(@class_labels.length)

        @class_labels.length.times do |class_idx|
          z = @bias[class_idx] + features.zip(@weights[class_idx]).sum { |x, w| x * w }
          z_values[class_idx] = z
        end

        softmax(z_values)
      end

      def explain_binary_prediction(original_features, processed_features, probability, prediction)
        puts "\n=== Binary Prediction Explanation ==="
        puts "Original input: #{original_features.inspect}"
        puts "Processed input: #{processed_features.map { |f| f.round(4) }.inspect}" if @normalize_features

        z = @bias + processed_features.zip(@weights).sum { |x, w| x * w }
        puts "\nLinear combination (z): #{z.round(4)}"
        puts '  z = bias + Σ(weight_i × feature_i)'
        puts "  z = #{@bias.round(4)} + #{processed_features.zip(@weights).map { |x, w| "#{w.round(4)}×#{x.round(4)}" }.join(' + ')}"

        puts "\nSigmoid probability: σ(#{z.round(4)}) = #{probability.round(4)}"
        puts 'Decision threshold: 0.5'
        puts "Prediction: #{prediction} (probability #{probability >= 0.5 ? '≥' : '<'} 0.5)"
        puts "Confidence: #{([probability, 1 - probability].max * 100).round(1)}%"
      end

      def explain_multinomial_prediction(original_features, probabilities, prediction)
        puts "\n=== Multinomial Prediction Explanation ==="
        puts "Original input: #{original_features.inspect}"

        puts "\nClass probabilities:"
        @class_labels.each_with_index do |label, idx|
          puts "  #{label}: #{(probabilities[idx] * 100).round(2)}%"
        end

        puts "\nPrediction: #{prediction} (highest probability)"
        puts "Confidence: #{(probabilities.max * 100).round(1)}%"
      end

      def explain_feature_importance
        return if @feature_importance.empty?

        puts "\n=== Feature Importance Analysis ==="
        puts 'Importance scores (based on absolute weight magnitudes):'

        if @data_set&.data_labels
          feature_names = @data_set.data_labels[0...-1]
          importance_pairs = feature_names.zip(@feature_importance)
          importance_pairs.sort_by! { |_name, importance| -importance }

          importance_pairs.each_with_index do |(name, importance), idx|
            puts format('%2d. %-20s: %8.4f', idx + 1, name, importance)
          end
        else
          @feature_importance.each_with_index do |importance, idx|
            puts format('Feature %2d: %8.4f', idx + 1, importance)
          end
        end

        puts "\nInterpretation:"
        puts '- Higher values indicate more influential features'
        puts '- Features with near-zero importance contribute little to predictions'
        puts '- Consider feature selection based on importance scores'
      end

      def explain_configuration
        puts "\n=== Logistic Regression Configuration ==="
        puts "Learning rate: #{@learning_rate}"
        puts '  - Higher: Faster learning, risk of overshooting'
        puts '  - Lower: Slower learning, more stable convergence'

        puts "\nRegularization: #{@regularization_type}"
        case @regularization_type
        when :l1
          puts '  - L1 penalty encourages sparse solutions (feature selection)'
        when :l2
          puts '  - L2 penalty prevents overfitting, shrinks weights'
        when :elastic_net
          puts '  - Combines L1 and L2 benefits'
        when :none
          puts '  - No regularization, may overfit with many features'
        end

        if @lambda > 0
          puts "Lambda: #{@lambda}"
          puts '  - Controls regularization strength'
        end

        puts "\nFeature normalization: #{@normalize_features ? 'Enabled' : 'Disabled'}"
        puts '  - Recommended for features with different scales'
      end

      def finalize_training
        calculate_feature_importance

        if @verbose
          puts "\n=== Training Results ==="
          puts "Converged: #{@converged ? 'Yes' : 'No'}"
          puts "Final cost: #{@cost_history.last.round(6)}"
          puts "Iterations: #{@iteration_count}"

          if @classification_type == :binary
            puts "Final weights: #{@weights.map { |w| w.round(4) }.inspect}"
            puts "Final bias: #{@bias.round(4)}"
          else
            puts "Weight matrix shape: #{@weights.length} × #{@weights.first.length}"
          end
        end

        plot_cost_history if @plot_cost && @verbose
      end

      def explain_performance_metrics(performance)
        puts "\n=== Performance Metrics Explanation ==="
        puts "Accuracy: #{(performance[:accuracy] * 100).round(2)}%"
        puts '  - Percentage of correct predictions'
        puts '  - Range: 0% (worst) to 100% (perfect)'

        puts "\nLog Loss: #{performance[:log_loss].round(4)}"
        puts '  - Measures probability calibration quality'
        puts '  - Lower is better (0 = perfect probability estimates)'
        puts '  - Penalizes confident wrong predictions heavily'

        puts "\nClass-specific metrics:"
        performance[:class_metrics].each do |class_name, metrics|
          puts "  #{class_name}:"
          puts "    Precision: #{(metrics[:precision] * 100).round(1)}%"
          puts "    Recall:    #{(metrics[:recall] * 100).round(1)}%"
          puts "    F1-Score:  #{(metrics[:f1_score] * 100).round(1)}%"
        end
      end

      def trained?
        !@weights.empty? && @iteration_count > 0
      end

      def calculate_accuracy(predictions, actual_labels)
        correct = predictions.zip(actual_labels).count { |pred, actual| pred == actual }
        correct.to_f / predictions.length
      end

      def calculate_log_loss(actual_labels, probabilities)
        total_loss = 0.0

        actual_labels.each_with_index do |actual, idx|
          prob_hash = probabilities[idx]
          actual_prob = prob_hash[actual]

          # Avoid log(0)
          actual_prob = [actual_prob, 1e-15].max
          total_loss -= Math.log(actual_prob)
        end

        total_loss / actual_labels.length
      end

      def calculate_class_metrics(predictions, actual_labels)
        classes = (predictions + actual_labels).uniq.sort
        metrics = {}

        classes.each do |class_name|
          tp = predictions.zip(actual_labels).count { |pred, actual| pred == class_name && actual == class_name }
          fp = predictions.zip(actual_labels).count { |pred, actual| pred == class_name && actual != class_name }
          fn = predictions.zip(actual_labels).count { |pred, actual| pred != class_name && actual == class_name }

          precision = tp + fp > 0 ? tp.to_f / (tp + fp) : 0.0
          recall = tp + fn > 0 ? tp.to_f / (tp + fn) : 0.0
          f1_score = precision + recall > 0 ? 2 * (precision * recall) / (precision + recall) : 0.0

          metrics[class_name] = {
            precision: precision,
            recall: recall,
            f1_score: f1_score,
            support: tp + fn
          }
        end

        metrics
      end
    end
  end
end
