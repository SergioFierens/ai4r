# frozen_string_literal: true

#
# Random Forest Algorithm Implementation for AI4R Educational Framework
#
# This implementation provides a comprehensive, educational version of the Random Forest
# ensemble learning algorithm, designed specifically for students and teachers to understand
# ensemble methods and decision tree concepts.
#
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r
#
# Random Forest combines multiple decision trees to create a robust classifier that
# reduces overfitting and improves generalization. It uses bootstrap aggregating (bagging)
# and random feature selection to create diverse trees.
#
# Key Educational Concepts:
# - Ensemble Learning: Combining multiple weak learners to create a strong learner
# - Bootstrap Sampling: Creating diverse training sets through sampling with replacement
# - Feature Randomness: Selecting random subsets of features for each tree
# - Voting/Averaging: Aggregating predictions from multiple trees
# - Bias-Variance Tradeoff: How ensemble methods reduce variance
#
# Example Usage:
#   # Create dataset
#   data = [
#     [5.1, 3.5, 1.4, 0.2, 'setosa'],
#     [4.9, 3.0, 1.4, 0.2, 'setosa'],
#     [7.0, 3.2, 4.7, 1.4, 'versicolor'],
#     [6.4, 3.2, 4.5, 1.5, 'versicolor']
#   ]
#
#   # Train Random Forest
#   rf = RandomForest.new(n_trees: 10, max_depth: 5)
#   rf.train(data)
#
#   # Make predictions
#   prediction = rf.predict([5.8, 2.7, 4.1, 1.0])
#   puts "Prediction: #{prediction}"
#

module Ai4r
  module MachineLearning
    # Random Forest Algorithm Implementation
    #
    # This class implements the Random Forest ensemble learning algorithm with educational
    # features including detailed statistics, feature importance analysis, and
    # comprehensive visualization capabilities.
    #
    # The algorithm works by:
    # 1. Creating multiple bootstrap samples from the training data
    # 2. Training a decision tree on each bootstrap sample
    # 3. Using random feature selection at each tree node
    # 4. Combining predictions through majority voting (classification) or averaging (regression)
    #
    # Educational Features:
    # - Bootstrap sampling visualization
    # - Feature importance calculation
    # - Out-of-bag error estimation
    # - Tree diversity analysis
    # - Performance comparison with single trees
    #
    class RandomForest
      # Training and prediction statistics
      attr_reader :trees, :feature_importances, :oob_error, :training_time
      attr_reader :n_features, :feature_names, :class_labels, :tree_predictions
      attr_reader :bootstrap_samples, :feature_subsets, :diversity_metrics

      # Educational configuration
      attr_accessor :verbose_mode, :track_oob, :calculate_importance

      # Default configuration values
      DEFAULT_N_TREES = 10
      DEFAULT_MAX_DEPTH = 10
      DEFAULT_MIN_SAMPLES_SPLIT = 2
      DEFAULT_MAX_FEATURES = nil # sqrt(n_features) for classification
      DEFAULT_BOOTSTRAP = true

      # Initialize Random Forest with configuration
      #
      # @param n_trees [Integer] Number of trees in the forest
      # @param max_depth [Integer] Maximum depth of each tree
      # @param min_samples_split [Integer] Minimum samples required to split a node
      # @param max_features [Integer, String, nil] Number of features to consider at each split
      # @param bootstrap [Boolean] Whether to use bootstrap sampling
      # @param options [Hash] Additional configuration options
      #
      def initialize(n_trees: DEFAULT_N_TREES, max_depth: DEFAULT_MAX_DEPTH,
                     min_samples_split: DEFAULT_MIN_SAMPLES_SPLIT,
                     max_features: DEFAULT_MAX_FEATURES, bootstrap: DEFAULT_BOOTSTRAP,
                     **options)
        @n_trees = validate_n_trees(n_trees)
        @max_depth = validate_max_depth(max_depth)
        @min_samples_split = validate_min_samples_split(min_samples_split)
        @max_features = max_features
        @bootstrap = bootstrap

        # Educational configuration
        @verbose_mode = options.fetch(:verbose, false)
        @track_oob = options.fetch(:track_oob, true)
        @calculate_importance = options.fetch(:calculate_importance, true)

        # Initialize components
        @trees = []
        @feature_importances = {}
        @bootstrap_samples = []
        @feature_subsets = []
        @tree_predictions = []
        @diversity_metrics = {}

        # Performance metrics
        @oob_error = 0.0
        @training_time = 0.0
      end

      # Train the Random Forest on provided data
      #
      # @param data [Array<Array>] Training data where last column is the target
      # @param feature_names [Array<String>] Optional feature names
      # @return [RandomForest] Self for method chaining
      #
      # Educational Note:
      # This method demonstrates the complete Random Forest training process:
      # 1. Prepare data and extract features/labels
      # 2. Determine optimal number of features per tree
      # 3. Create bootstrap samples for each tree
      # 4. Train individual decision trees
      # 5. Calculate feature importances
      # 6. Estimate out-of-bag error
      # 7. Analyze ensemble diversity
      #
      def train(data, feature_names = nil)
        validate_training_data(data)

        educational_output("🌳 Random Forest Training Starting", <<~MSG)
          Number of trees: #{@n_trees}
          Max depth: #{@max_depth}
          Bootstrap sampling: #{@bootstrap}
          Training samples: #{data.length}
        MSG

        start_time = Time.now

        # Prepare training data
        @training_data = data.map(&:dup)
        @n_features = data[0].length - 1
        @feature_names = feature_names || (0...@n_features).map { |i| "feature_#{i}" }
        @class_labels = data.map(&:last).uniq.sort

        # Determine number of features per tree
        @max_features = calculate_max_features(@max_features, @n_features)

        educational_output("📊 Data Preparation Complete", <<~MSG)
          Features: #{@n_features}
          Classes: #{@class_labels.length} (#{@class_labels.join(', ')})
          Max features per tree: #{@max_features}
        MSG

        # Train individual trees
        @trees = []
        @bootstrap_samples = []
        @feature_subsets = []

        (0...@n_trees).each do |tree_idx|
          educational_progress("Training tree #{tree_idx + 1}/#{@n_trees}")

          # Create bootstrap sample
          bootstrap_sample = create_bootstrap_sample(@training_data)
          @bootstrap_samples << bootstrap_sample

          # Create random feature subset
          feature_subset = select_random_features
          @feature_subsets << feature_subset

          # Train decision tree
          tree = train_decision_tree(bootstrap_sample, feature_subset, tree_idx)
          @trees << tree
        end

        @training_time = Time.now - start_time

        # Post-training analysis
        calculate_feature_importances if @calculate_importance
        calculate_oob_error if @track_oob
        analyze_diversity

        educational_output("🎉 Random Forest Training Complete", <<~MSG)
          Training time: #{@training_time.round(4)} seconds
          OOB error: #{@oob_error.round(4)}
          Average tree depth: #{average_tree_depth.round(2)}
          Diversity index: #{@diversity_metrics[:diversity_index].round(4)}
        MSG

        self
      end

      # Make prediction for a single sample
      #
      # @param sample [Array] Input features
      # @return [Object] Predicted class or value
      #
      def predict(sample)
        validate_prediction_input(sample)

        # Get predictions from all trees
        tree_predictions = @trees.map.with_index do |tree, idx|
          # Apply feature subset used during training
          selected_features = @feature_subsets[idx].map { |i| sample[i] }
          tree.predict(selected_features)
        end

        # Aggregate predictions
        aggregate_predictions(tree_predictions)
      end

      # Make predictions for multiple samples
      #
      # @param samples [Array<Array>] Array of input feature arrays
      # @return [Array] Array of predictions
      #
      def predict_batch(samples)
        samples.map { |sample| predict(sample) }
      end

      # Calculate prediction probabilities (for classification)
      #
      # @param sample [Array] Input features
      # @return [Hash] Class probabilities
      #
      def predict_proba(sample)
        validate_prediction_input(sample)

        # Get predictions from all trees
        tree_predictions = @trees.map.with_index do |tree, idx|
          selected_features = @feature_subsets[idx].map { |i| sample[i] }
          if tree.respond_to?(:predict_proba)
            tree.predict_proba(selected_features)
          else
            # Convert single prediction to probability distribution
            prediction = tree.predict(selected_features)
            { prediction => 1.0 }
          end
        end

        # Average probabilities across trees
        combined_probs = Hash.new(0.0)
        tree_predictions.each do |tree_probs|
          tree_probs.each do |class_label, prob|
            combined_probs[class_label] += prob
          end
        end

        # Normalize probabilities
        combined_probs.transform_values { |prob| prob / @n_trees }
      end

      # Analyze feature importance across the forest
      #
      # @return [Hash] Feature importance scores
      #
      def feature_importance_analysis
        return @feature_importances if @feature_importances.any?

        calculate_feature_importances
        @feature_importances
      end

      # Calculate out-of-bag error estimate
      #
      # @return [Float] OOB error rate
      #
      def oob_error_estimate
        return @oob_error if @oob_error > 0

        calculate_oob_error
        @oob_error
      end

      # Analyze diversity of trees in the forest
      #
      # @return [Hash] Diversity metrics
      #
      def diversity_analysis
        return @diversity_metrics if @diversity_metrics.any?

        analyze_diversity
        @diversity_metrics
      end

      # Compare performance with single decision tree
      #
      # @param test_data [Array<Array>] Test data for comparison
      # @return [Hash] Performance comparison results
      #
      def compare_with_single_tree(test_data)
        validate_training_data(test_data)

        # Train single decision tree on full dataset
        single_tree = train_decision_tree(@training_data, (0...@n_features).to_a, -1)

        # Evaluate both approaches
        rf_predictions = test_data.map { |sample| predict(sample[0...-1]) }
        tree_predictions = test_data.map { |sample| single_tree.predict(sample[0...-1]) }

        true_labels = test_data.map(&:last)

        # Calculate accuracies
        rf_accuracy = calculate_accuracy(rf_predictions, true_labels)
        tree_accuracy = calculate_accuracy(tree_predictions, true_labels)

        {
          random_forest: {
            accuracy: rf_accuracy,
            predictions: rf_predictions,
            trees: @n_trees,
            training_time: @training_time
          },
          single_tree: {
            accuracy: tree_accuracy,
            predictions: tree_predictions,
            trees: 1,
            training_time: single_tree.training_time || 0
          },
          improvement: {
            accuracy_gain: rf_accuracy - tree_accuracy,
            relative_improvement: ((rf_accuracy - tree_accuracy) / tree_accuracy * 100).round(2)
          }
        }
      end

      # Generate educational visualization of the forest
      #
      # @return [String] ASCII visualization
      #
      def visualize_forest
        visualization = "\n🌲 Random Forest Visualization\n"
        visualization += "=" * 40 + "\n\n"

        visualization += "📊 Forest Statistics:\n"
        visualization += "  • Trees: #{@n_trees}\n"
        visualization += "  • Features: #{@n_features}\n"
        visualization += "  • Classes: #{@class_labels.length}\n"
        visualization += "  • OOB Error: #{@oob_error.round(4)}\n"
        visualization += "  • Training Time: #{@training_time.round(4)}s\n\n"

        visualization += "🎯 Feature Importance (Top 5):\n"
        top_features = @feature_importances.sort_by { |_, importance| -importance }.first(5)
        top_features.each_with_index do |(feature, importance), idx|
          bar = "█" * (importance * 50).to_i
          visualization += "  #{idx + 1}. #{feature}: #{importance.round(4)} #{bar}\n"
        end

        visualization += "\n🌳 Tree Diversity:\n"
        if @diversity_metrics.any?
          visualization += "  • Diversity Index: #{@diversity_metrics[:diversity_index].round(4)}\n"
          visualization += "  • Average Agreement: #{@diversity_metrics[:average_agreement].round(4)}\n"
          visualization += "  • Prediction Variance: #{@diversity_metrics[:prediction_variance].round(4)}\n"
        end

        visualization
      end

      private

      # Validate number of trees parameter
      def validate_n_trees(n_trees)
        unless n_trees.is_a?(Integer) && n_trees > 0
          raise ArgumentError, "n_trees must be a positive integer, got: #{n_trees}"
        end
        n_trees
      end

      # Validate maximum depth parameter
      def validate_max_depth(max_depth)
        unless max_depth.is_a?(Integer) && max_depth > 0
          raise ArgumentError, "max_depth must be a positive integer, got: #{max_depth}"
        end
        max_depth
      end

      # Validate minimum samples split parameter
      def validate_min_samples_split(min_samples_split)
        unless min_samples_split.is_a?(Integer) && min_samples_split >= 2
          raise ArgumentError, "min_samples_split must be an integer >= 2, got: #{min_samples_split}"
        end
        min_samples_split
      end

      # Validate training data
      def validate_training_data(data)
        raise ArgumentError, "Training data cannot be empty" if data.empty?
        raise ArgumentError, "Training data must be 2D array" unless data.all? { |row| row.is_a?(Array) }
        
        first_row_length = data[0].length
        unless data.all? { |row| row.length == first_row_length }
          raise ArgumentError, "All training samples must have the same number of features"
        end
        
        raise ArgumentError, "Training data must have at least 2 columns (features + target)" if first_row_length < 2
      end

      # Validate prediction input
      def validate_prediction_input(sample)
        raise ArgumentError, "Sample must be an array" unless sample.is_a?(Array)
        raise ArgumentError, "Sample must have #{@n_features} features, got #{sample.length}" unless sample.length == @n_features
      end

      # Calculate optimal number of features per tree
      def calculate_max_features(max_features, n_features)
        case max_features
        when Integer
          [max_features, n_features].min
        when String
          case max_features
          when 'sqrt'
            Math.sqrt(n_features).ceil
          when 'log2'
            Math.log2(n_features).ceil
          when 'all'
            n_features
          else
            raise ArgumentError, "Invalid max_features string: #{max_features}"
          end
        when nil
          # Default: sqrt for classification
          Math.sqrt(n_features).ceil
        else
          raise ArgumentError, "max_features must be Integer, String, or nil"
        end
      end

      # Create bootstrap sample from training data
      def create_bootstrap_sample(data)
        return data.dup unless @bootstrap

        sample_size = data.length
        bootstrap_sample = []

        sample_size.times do
          random_index = rand(sample_size)
          bootstrap_sample << data[random_index].dup
        end

        bootstrap_sample
      end

      # Select random subset of features
      def select_random_features
        features = (0...@n_features).to_a
        features.sample(@max_features).sort
      end

      # Train individual decision tree
      def train_decision_tree(bootstrap_sample, feature_subset, tree_idx)
        # Create modified dataset with only selected features
        modified_data = bootstrap_sample.map do |sample|
          selected_features = feature_subset.map { |i| sample[i] }
          selected_features << sample.last # Add target
        end

        # Simple decision tree implementation for educational purposes
        tree = DecisionTree.new(
          max_depth: @max_depth,
          min_samples_split: @min_samples_split,
          feature_subset: feature_subset,
          tree_id: tree_idx
        )

        tree.train(modified_data)
        tree
      end

      # Calculate feature importances across all trees
      def calculate_feature_importances
        @feature_importances = Hash.new(0.0)

        @trees.each_with_index do |tree, tree_idx|
          tree_importances = tree.feature_importances
          feature_subset = @feature_subsets[tree_idx]

          tree_importances.each do |local_feature_idx, importance|
            global_feature_idx = feature_subset[local_feature_idx]
            feature_name = @feature_names[global_feature_idx]
            @feature_importances[feature_name] += importance
          end
        end

        # Normalize importances
        total_importance = @feature_importances.values.sum
        if total_importance > 0
          @feature_importances.transform_values! { |importance| importance / total_importance }
        end
      end

      # Calculate out-of-bag error
      def calculate_oob_error
        return unless @bootstrap

        correct_predictions = 0
        total_predictions = 0

        @training_data.each_with_index do |sample, sample_idx|
          # Find trees that didn't use this sample in training
          oob_trees = []
          @bootstrap_samples.each_with_index do |bootstrap_sample, tree_idx|
            unless bootstrap_sample.include?(sample)
              oob_trees << tree_idx
            end
          end

          next if oob_trees.empty?

          # Get predictions from out-of-bag trees
          oob_predictions = oob_trees.map do |tree_idx|
            tree = @trees[tree_idx]
            feature_subset = @feature_subsets[tree_idx]
            selected_features = feature_subset.map { |i| sample[i] }
            tree.predict(selected_features)
          end

          # Aggregate OOB predictions
          oob_prediction = aggregate_predictions(oob_predictions)

          # Check if prediction is correct
          if oob_prediction == sample.last
            correct_predictions += 1
          end
          total_predictions += 1
        end

        @oob_error = total_predictions > 0 ? 1.0 - (correct_predictions.to_f / total_predictions) : 0.0
      end

      # Analyze diversity of trees in the forest
      def analyze_diversity
        return if @training_data.empty?

        # Calculate pairwise agreement between trees
        agreements = []
        tree_pairs = (0...@n_trees).to_a.combination(2).to_a

        tree_pairs.each do |i, j|
          agreement = calculate_tree_agreement(@trees[i], @trees[j], 
                                             @feature_subsets[i], @feature_subsets[j])
          agreements << agreement
        end

        # Calculate diversity metrics
        @diversity_metrics = {
          diversity_index: 1.0 - (agreements.sum / agreements.length),
          average_agreement: agreements.sum / agreements.length,
          prediction_variance: calculate_prediction_variance
        }
      end

      # Calculate agreement between two trees
      def calculate_tree_agreement(tree1, tree2, features1, features2)
        agreements = 0
        total_samples = [@training_data.length, 100].min # Limit for performance

        total_samples.times do |i|
          sample = @training_data[i]
          
          pred1 = tree1.predict(features1.map { |idx| sample[idx] })
          pred2 = tree2.predict(features2.map { |idx| sample[idx] })
          
          agreements += 1 if pred1 == pred2
        end

        agreements.to_f / total_samples
      end

      # Calculate prediction variance across trees
      def calculate_prediction_variance
        return 0.0 if @training_data.empty?

        variances = []
        sample_size = [@training_data.length, 50].min # Limit for performance

        sample_size.times do |i|
          sample = @training_data[i]
          
          # Get predictions from all trees
          predictions = @trees.map.with_index do |tree, tree_idx|
            features = @feature_subsets[tree_idx].map { |idx| sample[idx] }
            tree.predict(features)
          end

          # Calculate variance for this sample
          if predictions.all? { |p| p.is_a?(Numeric) }
            mean = predictions.sum.to_f / predictions.length
            variance = predictions.map { |p| (p - mean) ** 2 }.sum / predictions.length
            variances << variance
          end
        end

        variances.any? ? variances.sum / variances.length : 0.0
      end

      # Aggregate predictions from multiple trees
      def aggregate_predictions(predictions)
        return nil if predictions.empty?

        if predictions.all? { |p| p.is_a?(Numeric) }
          # Regression: average predictions
          predictions.sum.to_f / predictions.length
        else
          # Classification: majority vote
          vote_counts = Hash.new(0)
          predictions.each { |pred| vote_counts[pred] += 1 }
          vote_counts.max_by { |_, count| count }.first
        end
      end

      # Calculate accuracy for predictions
      def calculate_accuracy(predictions, true_labels)
        return 0.0 if predictions.empty?

        correct = predictions.zip(true_labels).count { |pred, true_label| pred == true_label }
        correct.to_f / predictions.length
      end

      # Calculate average tree depth
      def average_tree_depth
        return 0.0 if @trees.empty?

        depths = @trees.map { |tree| tree.depth || 0 }
        depths.sum.to_f / depths.length
      end

      # Educational output helper
      def educational_output(title, content)
        return unless @verbose_mode

        puts "\n#{title}"
        puts '=' * title.length
        puts content
      end

      # Progress indicator
      def educational_progress(message)
        return unless @verbose_mode

        print "\r#{message}"
        $stdout.flush
      end
    end

    # Simple Decision Tree implementation for Random Forest
    class DecisionTree
      attr_reader :max_depth, :min_samples_split, :feature_subset, :tree_id
      attr_reader :root, :feature_importances, :training_time, :depth

      def initialize(max_depth:, min_samples_split:, feature_subset:, tree_id:)
        @max_depth = max_depth
        @min_samples_split = min_samples_split
        @feature_subset = feature_subset
        @tree_id = tree_id
        @feature_importances = Hash.new(0.0)
        @training_time = 0.0
        @depth = 0
      end

      def train(data)
        start_time = Time.now
        @root = build_tree(data, 0)
        @training_time = Time.now - start_time
        calculate_tree_depth
      end

      def predict(sample)
        return nil unless @root
        
        traverse_tree(@root, sample)
      end

      private

      # Build decision tree recursively
      def build_tree(data, current_depth)
        return create_leaf_node(data) if stopping_criteria_met?(data, current_depth)

        best_split = find_best_split(data)
        return create_leaf_node(data) unless best_split

        # Create internal node
        left_data, right_data = split_data(data, best_split)
        
        node = {
          feature_idx: best_split[:feature_idx],
          threshold: best_split[:threshold],
          left: build_tree(left_data, current_depth + 1),
          right: build_tree(right_data, current_depth + 1),
          samples: data.length
        }

        # Update feature importance
        @feature_importances[best_split[:feature_idx]] += best_split[:importance]
        
        node
      end

      # Check if stopping criteria are met
      def stopping_criteria_met?(data, current_depth)
        return true if current_depth >= @max_depth
        return true if data.length < @min_samples_split
        return true if data.map(&:last).uniq.length == 1 # Pure node
        
        false
      end

      # Find best split for the data
      def find_best_split(data)
        best_split = nil
        best_gini = Float::INFINITY
        n_features = data[0].length - 1

        (0...n_features).each do |feature_idx|
          # Get unique values for this feature
          feature_values = data.map { |row| row[feature_idx] }.uniq.sort
          
          # Try each threshold
          feature_values.each do |threshold|
            gini = calculate_split_gini(data, feature_idx, threshold)
            
            if gini < best_gini
              best_gini = gini
              best_split = {
                feature_idx: feature_idx,
                threshold: threshold,
                gini: gini,
                importance: calculate_importance_gain(data, feature_idx, threshold)
              }
            end
          end
        end

        best_split
      end

      # Calculate Gini impurity for a split
      def calculate_split_gini(data, feature_idx, threshold)
        left_data, right_data = split_data(data, { feature_idx: feature_idx, threshold: threshold })
        
        return Float::INFINITY if left_data.empty? || right_data.empty?

        total_samples = data.length
        left_gini = calculate_gini(left_data)
        right_gini = calculate_gini(right_data)

        # Weighted average
        (left_data.length.to_f / total_samples) * left_gini + 
        (right_data.length.to_f / total_samples) * right_gini
      end

      # Calculate Gini impurity for a dataset
      def calculate_gini(data)
        return 0.0 if data.empty?

        label_counts = Hash.new(0)
        data.each { |row| label_counts[row.last] += 1 }

        gini = 1.0
        total = data.length

        label_counts.each do |_, count|
          probability = count.to_f / total
          gini -= probability * probability
        end

        gini
      end

      # Calculate importance gain for a split
      def calculate_importance_gain(data, feature_idx, threshold)
        parent_gini = calculate_gini(data)
        split_gini = calculate_split_gini(data, feature_idx, threshold)
        
        parent_gini - split_gini
      end

      # Split data based on feature and threshold
      def split_data(data, split_info)
        left_data = []
        right_data = []

        data.each do |row|
          if row[split_info[:feature_idx]] <= split_info[:threshold]
            left_data << row
          else
            right_data << row
          end
        end

        [left_data, right_data]
      end

      # Create leaf node
      def create_leaf_node(data)
        return nil if data.empty?

        # Find most common class
        label_counts = Hash.new(0)
        data.each { |row| label_counts[row.last] += 1 }

        {
          prediction: label_counts.max_by { |_, count| count }.first,
          samples: data.length,
          class_distribution: label_counts
        }
      end

      # Traverse tree to make prediction
      def traverse_tree(node, sample)
        return node[:prediction] if node[:prediction] # Leaf node

        if sample[node[:feature_idx]] <= node[:threshold]
          traverse_tree(node[:left], sample)
        else
          traverse_tree(node[:right], sample)
        end
      end

      # Calculate tree depth
      def calculate_tree_depth
        @depth = calculate_node_depth(@root)
      end

      # Calculate depth of a node
      def calculate_node_depth(node)
        return 0 if node.nil? || node[:prediction] # Leaf node

        left_depth = calculate_node_depth(node[:left])
        right_depth = calculate_node_depth(node[:right])

        1 + [left_depth, right_depth].max
      end
    end
  end
end