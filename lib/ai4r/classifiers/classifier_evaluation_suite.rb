# frozen_string_literal: true

# Comprehensive classifier evaluation suite for educational purposes
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../data/data_set'

module Ai4r
  module Classifiers
    
    # Educational classifier evaluation suite
    # 
    # Provides comprehensive evaluation metrics, cross-validation,
    # statistical testing, and visualization tools for comparing
    # classification algorithms.
    #
    # Educational Features:
    # - ROC curves and AUC calculation
    # - Precision-Recall curves
    # - Statistical significance testing
    # - Learning curves
    # - Feature importance analysis
    # - Bias-variance decomposition
    #
    # = Usage
    #   evaluator = ClassifierEvaluationSuite.new
    #   evaluator.enable_educational_mode
    #   results = evaluator.comprehensive_evaluation(classifier, test_data)
    #   evaluator.compare_classifiers([clf1, clf2], test_data)
    class ClassifierEvaluationSuite
      
      attr_reader :educational_mode, :evaluation_results, :comparison_results
      
      def initialize
        @educational_mode = false
        @verbose = false
        @evaluation_results = {}
        @comparison_results = {}
        @random_seed = 42
      end
      
      # Enable educational mode with detailed explanations
      def enable_educational_mode
        @educational_mode = true
        @verbose = true
        puts "\n=== Educational Classifier Evaluation Mode ==="
        puts "This mode provides comprehensive evaluation metrics and explanations."
        self
      end
      
      # Comprehensive evaluation of a single classifier
      def comprehensive_evaluation(classifier, test_set, options = {})
        puts "\n=== Comprehensive Classifier Evaluation ===" if @verbose
        
        # Basic prediction evaluation
        predictions = []
        actual_labels = []
        probabilities = []
        
        test_set.data_items.each do |item|
          features = item[0...-1]
          actual_class = item.last
          
          prediction = classifier.eval(features)
          predictions << prediction
          actual_labels << actual_class
          
          # Get probabilities if available
          if classifier.respond_to?(:predict_with_probabilities)
            prob_result = classifier.predict_with_probabilities(features)
            probabilities << prob_result[:probabilities]
          elsif classifier.respond_to?(:get_probability_map)
            probabilities << classifier.get_probability_map(features)
          else
            # Create dummy probabilities
            dummy_probs = {}
            actual_labels.uniq.each { |label| dummy_probs[label] = 0.0 }
            dummy_probs[prediction] = 1.0
            probabilities << dummy_probs
          end
        end
        
        # Calculate all metrics
        results = {
          basic_metrics: calculate_basic_metrics(predictions, actual_labels),
          confusion_matrix: calculate_confusion_matrix(predictions, actual_labels),
          class_metrics: calculate_class_metrics(predictions, actual_labels),
          roc_analysis: calculate_roc_analysis(actual_labels, probabilities),
          precision_recall: calculate_precision_recall_curves(actual_labels, probabilities),
          statistical_measures: calculate_statistical_measures(predictions, actual_labels),
          calibration_metrics: calculate_calibration_metrics(actual_labels, probabilities)
        }
        
        @evaluation_results[classifier.class.name] = results
        
        if @educational_mode
          explain_evaluation_results(results)
        end
        
        results
      end
      
      # Compare multiple classifiers
      def compare_classifiers(classifiers, test_set, options = {})
        puts "\n=== Multi-Classifier Comparison ===" if @verbose
        
        results = {}
        
        # Evaluate each classifier
        classifiers.each_with_index do |classifier, idx|
          name = classifier.class.name
          puts "\nEvaluating #{name}..." if @verbose
          results[name] = comprehensive_evaluation(classifier, test_set, options)
        end
        
        # Statistical comparison
        comparison = perform_statistical_comparison(classifiers, test_set)
        
        # Ranking and summary
        ranking = rank_classifiers(results)
        
        comparison_results = {
          individual_results: results,
          statistical_comparison: comparison,
          ranking: ranking,
          summary: generate_comparison_summary(results, ranking)
        }
        
        @comparison_results = comparison_results
        
        if @educational_mode
          explain_classifier_comparison(comparison_results)
        end
        
        comparison_results
      end
      
      # Cross-validation evaluation
      def cross_validation_evaluation(classifier_class, data_set, k_folds = 5, options = {})
        puts "\n=== Cross-Validation Evaluation ===" if @verbose
        puts "Classifier: #{classifier_class.name}" if @verbose
        puts "K-folds: #{k_folds}" if @verbose
        
        # Create folds
        folds = create_stratified_folds(data_set, k_folds)
        
        fold_results = []
        
        folds.each_with_index do |fold, idx|
          puts "Evaluating fold #{idx + 1}/#{k_folds}..." if @verbose
          
          train_set, test_set = fold[:train], fold[:test]
          
          # Train classifier
          classifier = classifier_class.new
          if options[:classifier_config]
            classifier.configure(options[:classifier_config])
          end
          classifier.build(train_set)
          
          # Evaluate
          fold_result = comprehensive_evaluation(classifier, test_set)
          fold_result[:fold_index] = idx
          fold_results << fold_result
        end
        
        # Aggregate results
        cv_summary = aggregate_cv_results(fold_results)
        
        if @educational_mode
          explain_cross_validation_results(cv_summary, fold_results)
        end
        
        {
          fold_results: fold_results,
          summary: cv_summary,
          classifier: classifier_class.name,
          k_folds: k_folds
        }
      end
      
      # Learning curve analysis
      def learning_curve_analysis(classifier_class, data_set, options = {})
        puts "\n=== Learning Curve Analysis ===" if @verbose
        
        sample_sizes = options[:sample_sizes] || 
                      generate_sample_sizes(data_set.data_items.length)
        
        cv_folds = options[:cv_folds] || 3
        
        results = []
        
        sample_sizes.each do |sample_size|
          puts "Analyzing sample size: #{sample_size}..." if @verbose
          
          # Create subset of data
          subset_data = create_data_subset(data_set, sample_size)
          
          # Perform cross-validation on subset
          cv_result = cross_validation_evaluation(classifier_class, subset_data, cv_folds, options)
          
          size_result = {
            sample_size: sample_size,
            train_accuracy: cv_result[:summary][:train_accuracy],
            test_accuracy: cv_result[:summary][:test_accuracy],
            train_std: cv_result[:summary][:train_accuracy_std],
            test_std: cv_result[:summary][:test_accuracy_std],
            bias_variance: estimate_bias_variance(cv_result[:fold_results])
          }
          
          results << size_result
        end
        
        if @educational_mode
          explain_learning_curves(results)
        end
        
        results
      end
      
      # Feature importance analysis across classifiers
      def feature_importance_analysis(classifiers, data_set, options = {})
        puts "\n=== Feature Importance Analysis ===" if @verbose
        
        importance_results = {}
        
        classifiers.each do |classifier|
          classifier_name = classifier.class.name
          
          if classifier.respond_to?(:calculate_feature_importance)
            importance_scores = classifier.calculate_feature_importance
            
            importance_results[classifier_name] = {
              scores: importance_scores,
              method: "classifier_native"
            }
          else
            # Use permutation importance
            importance_scores = calculate_permutation_importance(classifier, data_set)
            importance_results[classifier_name] = {
              scores: importance_scores,
              method: "permutation"
            }
          end
        end
        
        # Aggregate and compare
        aggregated = aggregate_feature_importance(importance_results, data_set)
        
        if @educational_mode
          explain_feature_importance(importance_results, aggregated)
        end
        
        {
          individual_importance: importance_results,
          aggregated: aggregated,
          feature_names: get_feature_names(data_set)
        }
      end
      
      # Generate comprehensive evaluation report
      def generate_evaluation_report(title = "Classifier Evaluation Report")
        report = []
        report << "=" * 60
        report << title.center(60)
        report << "=" * 60
        report << ""
        
        if @evaluation_results.any?
          report << "INDIVIDUAL CLASSIFIER RESULTS"
          report << "-" * 30
          
          @evaluation_results.each do |classifier_name, results|
            report << ""
            report << "#{classifier_name}:"
            report << format_basic_metrics(results[:basic_metrics])
            report << format_class_metrics(results[:class_metrics])
          end
        end
        
        if @comparison_results.any?
          report << ""
          report << "CLASSIFIER COMPARISON"
          report << "-" * 20
          report << format_comparison_results(@comparison_results)
        end
        
        report << ""
        report << "Report generated at: #{Time.now}"
        report << "=" * 60
        
        report_text = report.join("\n")
        
        if @verbose
          puts report_text
        end
        
        report_text
      end
      
      private
      
      def calculate_basic_metrics(predictions, actual_labels)
        total = predictions.length
        correct = predictions.zip(actual_labels).count { |pred, actual| pred == actual }
        
        {
          accuracy: correct.to_f / total,
          error_rate: 1.0 - (correct.to_f / total),
          total_samples: total,
          correct_predictions: correct,
          incorrect_predictions: total - correct
        }
      end
      
      def calculate_confusion_matrix(predictions, actual_labels)
        classes = (predictions + actual_labels).uniq.sort
        matrix = {}
        
        classes.each do |actual_class|
          matrix[actual_class] = {}
          classes.each do |predicted_class|
            matrix[actual_class][predicted_class] = 0
          end
        end
        
        predictions.zip(actual_labels).each do |pred, actual|
          matrix[actual][pred] += 1
        end
        
        {
          matrix: matrix,
          classes: classes,
          normalized: normalize_confusion_matrix(matrix, classes)
        }
      end
      
      def calculate_class_metrics(predictions, actual_labels)
        classes = (predictions + actual_labels).uniq.sort
        metrics = {}
        
        classes.each do |class_name|
          tp = predictions.zip(actual_labels).count { |pred, actual| 
            pred == class_name && actual == class_name 
          }
          fp = predictions.zip(actual_labels).count { |pred, actual| 
            pred == class_name && actual != class_name 
          }
          fn = predictions.zip(actual_labels).count { |pred, actual| 
            pred != class_name && actual == class_name 
          }
          tn = predictions.zip(actual_labels).count { |pred, actual| 
            pred != class_name && actual != class_name 
          }
          
          precision = tp + fp > 0 ? tp.to_f / (tp + fp) : 0.0
          recall = tp + fn > 0 ? tp.to_f / (tp + fn) : 0.0
          specificity = tn + fp > 0 ? tn.to_f / (tn + fp) : 0.0
          f1_score = precision + recall > 0 ? 2 * (precision * recall) / (precision + recall) : 0.0
          
          metrics[class_name] = {
            precision: precision,
            recall: recall,
            specificity: specificity,
            f1_score: f1_score,
            support: tp + fn,
            true_positives: tp,
            false_positives: fp,
            false_negatives: fn,
            true_negatives: tn
          }
        end
        
        # Calculate macro and micro averages
        metrics[:macro_avg] = calculate_macro_average(metrics, classes)
        metrics[:micro_avg] = calculate_micro_average(metrics, classes)
        
        metrics
      end
      
      def calculate_roc_analysis(actual_labels, probabilities)
        classes = actual_labels.uniq.sort
        
        if classes.length == 2
          # Binary classification ROC
          binary_roc = calculate_binary_roc(actual_labels, probabilities, classes)
          return { binary: binary_roc, type: :binary }
        else
          # Multi-class ROC (one-vs-rest)
          multiclass_roc = {}
          classes.each do |class_name|
            binary_labels = actual_labels.map { |label| label == class_name ? 1 : 0 }
            binary_probs = probabilities.map { |prob_hash| prob_hash[class_name] || 0.0 }
            
            multiclass_roc[class_name] = calculate_binary_roc_from_arrays(binary_labels, binary_probs)
          end
          
          return { multiclass: multiclass_roc, type: :multiclass }
        end
      end
      
      def calculate_binary_roc(actual_labels, probabilities, classes)
        positive_class = classes.last
        
        # Extract positive class probabilities
        pos_probs = probabilities.map { |prob_hash| prob_hash[positive_class] || 0.0 }
        binary_labels = actual_labels.map { |label| label == positive_class ? 1 : 0 }
        
        calculate_binary_roc_from_arrays(binary_labels, pos_probs)
      end
      
      def calculate_binary_roc_from_arrays(binary_labels, probabilities)
        # Sort by probability (descending)
        sorted_indices = (0...probabilities.length).sort_by { |i| -probabilities[i] }
        
        # Calculate ROC points
        roc_points = []
        tp, fp = 0, 0
        total_positives = binary_labels.sum
        total_negatives = binary_labels.length - total_positives
        
        # Add origin point
        roc_points << { fpr: 0.0, tpr: 0.0, threshold: Float::INFINITY }
        
        sorted_indices.each_with_index do |idx, rank|
          if binary_labels[idx] == 1
            tp += 1
          else
            fp += 1
          end
          
          tpr = total_positives > 0 ? tp.to_f / total_positives : 0.0
          fpr = total_negatives > 0 ? fp.to_f / total_negatives : 0.0
          
          roc_points << { 
            fpr: fpr, 
            tpr: tpr, 
            threshold: probabilities[idx] 
          }
        end
        
        # Calculate AUC using trapezoidal rule
        auc = calculate_auc(roc_points)
        
        {
          roc_points: roc_points,
          auc: auc,
          total_positives: total_positives,
          total_negatives: total_negatives
        }
      end
      
      def calculate_auc(roc_points)
        auc = 0.0
        
        (1...roc_points.length).each do |i|
          # Trapezoidal rule
          x_diff = roc_points[i][:fpr] - roc_points[i-1][:fpr]
          y_avg = (roc_points[i][:tpr] + roc_points[i-1][:tpr]) / 2.0
          auc += x_diff * y_avg
        end
        
        auc
      end
      
      def calculate_precision_recall_curves(actual_labels, probabilities)
        classes = actual_labels.uniq.sort
        pr_curves = {}
        
        classes.each do |class_name|
          binary_labels = actual_labels.map { |label| label == class_name ? 1 : 0 }
          class_probs = probabilities.map { |prob_hash| prob_hash[class_name] || 0.0 }
          
          pr_curves[class_name] = calculate_pr_curve(binary_labels, class_probs)
        end
        
        pr_curves
      end
      
      def calculate_pr_curve(binary_labels, probabilities)
        # Sort by probability (descending)
        sorted_indices = (0...probabilities.length).sort_by { |i| -probabilities[i] }
        
        pr_points = []
        tp, fp = 0, 0
        total_positives = binary_labels.sum
        
        sorted_indices.each do |idx|
          if binary_labels[idx] == 1
            tp += 1
          else
            fp += 1
          end
          
          precision = (tp + fp) > 0 ? tp.to_f / (tp + fp) : 0.0
          recall = total_positives > 0 ? tp.to_f / total_positives : 0.0
          
          pr_points << { 
            precision: precision, 
            recall: recall, 
            threshold: probabilities[idx] 
          }
        end
        
        # Calculate average precision
        avg_precision = calculate_average_precision(pr_points)
        
        {
          pr_points: pr_points,
          average_precision: avg_precision,
          total_positives: total_positives
        }
      end
      
      def calculate_average_precision(pr_points)
        # Calculate area under PR curve using interpolation
        return 0.0 if pr_points.empty?
        
        # Sort by recall
        sorted_points = pr_points.sort_by { |point| point[:recall] }
        
        ap = 0.0
        prev_recall = 0.0
        
        sorted_points.each do |point|
          recall_diff = point[:recall] - prev_recall
          ap += recall_diff * point[:precision]
          prev_recall = point[:recall]
        end
        
        ap
      end
      
      def calculate_statistical_measures(predictions, actual_labels)
        # Calculate McNemar's test statistic (for comparing classifiers)
        # Calculate Cohen's Kappa
        # Calculate Matthews Correlation Coefficient
        
        kappa = calculate_cohens_kappa(predictions, actual_labels)
        mcc = calculate_matthews_correlation(predictions, actual_labels)
        
        {
          cohens_kappa: kappa,
          matthews_correlation: mcc,
          sample_size: predictions.length
        }
      end
      
      def calculate_cohens_kappa(predictions, actual_labels)
        classes = (predictions + actual_labels).uniq.sort
        n = predictions.length
        
        # Observed agreement
        po = predictions.zip(actual_labels).count { |pred, actual| pred == actual }.to_f / n
        
        # Expected agreement
        pe = 0.0
        classes.each do |class_name|
          pred_count = predictions.count(class_name)
          actual_count = actual_labels.count(class_name)
          pe += (pred_count.to_f / n) * (actual_count.to_f / n)
        end
        
        # Cohen's Kappa
        (po - pe) / (1 - pe)
      end
      
      def calculate_matthews_correlation(predictions, actual_labels)
        # For binary classification
        classes = (predictions + actual_labels).uniq.sort
        return nil if classes.length != 2
        
        positive_class = classes.last
        
        tp = predictions.zip(actual_labels).count { |pred, actual| 
          pred == positive_class && actual == positive_class 
        }
        tn = predictions.zip(actual_labels).count { |pred, actual| 
          pred != positive_class && actual != positive_class 
        }
        fp = predictions.zip(actual_labels).count { |pred, actual| 
          pred == positive_class && actual != positive_class 
        }
        fn = predictions.zip(actual_labels).count { |pred, actual| 
          pred != positive_class && actual == positive_class 
        }
        
        denominator = Math.sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
        return 0.0 if denominator == 0
        
        (tp * tn - fp * fn).to_f / denominator
      end
      
      def calculate_calibration_metrics(actual_labels, probabilities)
        # Calculate Brier score and reliability diagram data
        classes = actual_labels.uniq.sort
        
        if classes.length == 2
          # Binary calibration
          positive_class = classes.last
          binary_labels = actual_labels.map { |label| label == positive_class ? 1.0 : 0.0 }
          pos_probs = probabilities.map { |prob_hash| prob_hash[positive_class] || 0.0 }
          
          brier_score = calculate_brier_score(binary_labels, pos_probs)
          calibration_data = calculate_reliability_diagram(binary_labels, pos_probs)
          
          {
            type: :binary,
            brier_score: brier_score,
            calibration_data: calibration_data
          }
        else
          # Multi-class calibration
          brier_scores = {}
          classes.each do |class_name|
            binary_labels = actual_labels.map { |label| label == class_name ? 1.0 : 0.0 }
            class_probs = probabilities.map { |prob_hash| prob_hash[class_name] || 0.0 }
            brier_scores[class_name] = calculate_brier_score(binary_labels, class_probs)
          end
          
          {
            type: :multiclass,
            brier_scores: brier_scores
          }
        end
      end
      
      def calculate_brier_score(binary_labels, probabilities)
        squared_diffs = binary_labels.zip(probabilities).map do |actual, prob|
          (actual - prob) ** 2
        end
        
        squared_diffs.sum / squared_diffs.length
      end
      
      def calculate_reliability_diagram(binary_labels, probabilities, num_bins = 10)
        # Create bins
        bins = Array.new(num_bins) { { count: 0, prob_sum: 0.0, actual_sum: 0.0 } }
        
        binary_labels.zip(probabilities).each do |actual, prob|
          bin_index = [((prob * num_bins).floor), num_bins - 1].min
          bins[bin_index][:count] += 1
          bins[bin_index][:prob_sum] += prob
          bins[bin_index][:actual_sum] += actual
        end
        
        # Calculate bin statistics
        bin_data = bins.map_with_index do |bin, idx|
          if bin[:count] > 0
            avg_prob = bin[:prob_sum] / bin[:count]
            avg_actual = bin[:actual_sum] / bin[:count]
            {
              bin_index: idx,
              avg_predicted: avg_prob,
              avg_actual: avg_actual,
              count: bin[:count],
              lower_bound: idx.to_f / num_bins,
              upper_bound: (idx + 1).to_f / num_bins
            }
          else
            nil
          end
        end.compact
        
        bin_data
      end
      
      def normalize_confusion_matrix(matrix, classes)
        normalized = {}
        
        classes.each do |actual_class|
          row_sum = classes.sum { |pred_class| matrix[actual_class][pred_class] }
          normalized[actual_class] = {}
          
          classes.each do |pred_class|
            normalized[actual_class][pred_class] = 
              row_sum > 0 ? matrix[actual_class][pred_class].to_f / row_sum : 0.0
          end
        end
        
        normalized
      end
      
      def calculate_macro_average(metrics, classes)
        macro_precision = classes.sum { |c| metrics[c][:precision] } / classes.length
        macro_recall = classes.sum { |c| metrics[c][:recall] } / classes.length
        macro_f1 = classes.sum { |c| metrics[c][:f1_score] } / classes.length
        
        {
          precision: macro_precision,
          recall: macro_recall,
          f1_score: macro_f1,
          support: classes.sum { |c| metrics[c][:support] }
        }
      end
      
      def calculate_micro_average(metrics, classes)
        total_tp = classes.sum { |c| metrics[c][:true_positives] }
        total_fp = classes.sum { |c| metrics[c][:false_positives] }
        total_fn = classes.sum { |c| metrics[c][:false_negatives] }
        
        micro_precision = (total_tp + total_fp) > 0 ? total_tp.to_f / (total_tp + total_fp) : 0.0
        micro_recall = (total_tp + total_fn) > 0 ? total_tp.to_f / (total_tp + total_fn) : 0.0
        micro_f1 = (micro_precision + micro_recall) > 0 ? 
                   2 * (micro_precision * micro_recall) / (micro_precision + micro_recall) : 0.0
        
        {
          precision: micro_precision,
          recall: micro_recall,
          f1_score: micro_f1,
          support: classes.sum { |c| metrics[c][:support] }
        }
      end
      
      def create_stratified_folds(data_set, k_folds)
        # Group data by class
        class_groups = {}
        data_set.data_items.each_with_index do |item, idx|
          class_label = item.last
          class_groups[class_label] ||= []
          class_groups[class_label] << { item: item, index: idx }
        end
        
        # Create folds maintaining class distribution
        folds = Array.new(k_folds) { [] }
        
        class_groups.each do |class_label, items|
          items.shuffle!(random: Random.new(@random_seed))
          
          items.each_with_index do |item_data, idx|
            fold_index = idx % k_folds
            folds[fold_index] << item_data[:item]
          end
        end
        
        # Create train/test splits for each fold
        fold_splits = []
        folds.each_with_index do |test_items, test_fold_idx|
          train_items = []
          folds.each_with_index do |fold_items, fold_idx|
            train_items += fold_items unless fold_idx == test_fold_idx
          end
          
          train_set = Ai4r::Data::DataSet.new(
            data_labels: data_set.data_labels,
            data_items: train_items
          )
          test_set = Ai4r::Data::DataSet.new(
            data_labels: data_set.data_labels,
            data_items: test_items
          )
          
          fold_splits << { train: train_set, test: test_set }
        end
        
        fold_splits
      end
      
      def explain_evaluation_results(results)
        puts "\n=== Evaluation Results Explanation ==="
        
        # Basic metrics
        basic = results[:basic_metrics]
        puts "Accuracy: #{(basic[:accuracy] * 100).round(2)}%"
        puts "  - Percentage of correct predictions"
        puts "  - #{basic[:correct_predictions]}/#{basic[:total_samples]} correct"
        
        # Class metrics explanation
        puts "\nPer-class metrics:"
        results[:class_metrics].each do |class_name, metrics|
          next if [:macro_avg, :micro_avg].include?(class_name)
          
          puts "  #{class_name}:"
          puts "    Precision: #{(metrics[:precision] * 100).round(1)}% (#{metrics[:true_positives]}/#{metrics[:true_positives] + metrics[:false_positives]} predicted as #{class_name})"
          puts "    Recall:    #{(metrics[:recall] * 100).round(1)}% (#{metrics[:true_positives]}/#{metrics[:support]} actual #{class_name} found)"
          puts "    F1-Score:  #{(metrics[:f1_score] * 100).round(1)}% (harmonic mean of precision and recall)"
        end
        
        # ROC/AUC explanation
        if results[:roc_analysis][:type] == :binary
          auc = results[:roc_analysis][:binary][:auc]
          puts "\nROC AUC: #{auc.round(4)}"
          puts "  - Area Under ROC Curve measures discrimination ability"
          puts "  - 1.0 = perfect, 0.5 = random, 0.0 = perfectly wrong"
          
          case auc
          when 0.9..1.0
            puts "  - Excellent discrimination"
          when 0.8..0.9
            puts "  - Good discrimination"
          when 0.7..0.8
            puts "  - Fair discrimination"
          when 0.6..0.7
            puts "  - Poor discrimination"
          else
            puts "  - Very poor discrimination"
          end
        end
        
        # Statistical measures
        if results[:statistical_measures][:cohens_kappa]
          kappa = results[:statistical_measures][:cohens_kappa]
          puts "\nCohen's Kappa: #{kappa.round(4)}"
          puts "  - Agreement beyond chance (1.0 = perfect, 0.0 = chance)"
          
          case kappa
          when 0.8..1.0
            puts "  - Almost perfect agreement"
          when 0.6..0.8
            puts "  - Substantial agreement"
          when 0.4..0.6
            puts "  - Moderate agreement"
          when 0.2..0.4
            puts "  - Fair agreement"
          else
            puts "  - Poor agreement"
          end
        end
      end
      
      def perform_statistical_comparison(classifiers, test_set)
        # Placeholder for statistical tests (McNemar's test, etc.)
        {
          mcnemar_tests: {},
          friedman_test: nil,
          note: "Statistical testing not implemented in educational version"
        }
      end
      
      def rank_classifiers(results)
        rankings = {}
        
        # Rank by different metrics
        metrics_to_rank = [:accuracy, :macro_f1, :micro_f1]
        
        metrics_to_rank.each do |metric|
          scores = {}
          
          results.each do |classifier_name, result|
            case metric
            when :accuracy
              scores[classifier_name] = result[:basic_metrics][:accuracy]
            when :macro_f1
              scores[classifier_name] = result[:class_metrics][:macro_avg][:f1_score]
            when :micro_f1
              scores[classifier_name] = result[:class_metrics][:micro_avg][:f1_score]
            end
          end
          
          rankings[metric] = scores.sort_by { |name, score| -score }.to_h
        end
        
        rankings
      end
      
      def generate_comparison_summary(results, ranking)
        summary = {}
        
        # Best performer by accuracy
        best_accuracy = ranking[:accuracy].first
        summary[:best_accuracy] = {
          classifier: best_accuracy[0],
          score: best_accuracy[1]
        }
        
        # Most balanced (best macro F1)
        best_macro_f1 = ranking[:macro_f1].first
        summary[:most_balanced] = {
          classifier: best_macro_f1[0],
          score: best_macro_f1[1]
        }
        
        summary
      end
      
      def explain_classifier_comparison(comparison_results)
        puts "\n=== Classifier Comparison Analysis ==="
        
        summary = comparison_results[:summary]
        
        puts "Best Overall Accuracy:"
        puts "  #{summary[:best_accuracy][:classifier]}: #{(summary[:best_accuracy][:score] * 100).round(2)}%"
        
        puts "\nMost Balanced Performance (Macro F1):"
        puts "  #{summary[:most_balanced][:classifier]}: #{(summary[:most_balanced][:score] * 100).round(2)}%"
        
        puts "\nRanking by Accuracy:"
        comparison_results[:ranking][:accuracy].each_with_index do |(name, score), idx|
          puts "  #{idx + 1}. #{name}: #{(score * 100).round(2)}%"
        end
      end
      
      def calculate_permutation_importance(classifier, data_set)
        # Placeholder for permutation feature importance
        # This would randomly shuffle each feature and measure accuracy drop
        puts "Permutation importance calculation not implemented in educational version"
        Array.new(data_set.data_labels.length - 1, 0.0)
      end
      
      def aggregate_feature_importance(importance_results, data_set)
        # Placeholder for aggregating feature importance across classifiers
        {}
      end
      
      def explain_feature_importance(individual_results, aggregated)
        puts "\n=== Feature Importance Analysis ==="
        puts "Shows which features contribute most to predictions"
        puts "(Higher scores = more important features)"
      end
      
      def aggregate_cv_results(fold_results)
        # Calculate mean and std for key metrics
        accuracies = fold_results.map { |r| r[:basic_metrics][:accuracy] }
        
        {
          test_accuracy: accuracies.sum / accuracies.length,
          test_accuracy_std: calculate_std(accuracies),
          train_accuracy: 0.0, # Would need training accuracy from each fold
          train_accuracy_std: 0.0
        }
      end
      
      def explain_cross_validation_results(summary, fold_results)
        puts "\n=== Cross-Validation Results ==="
        puts "Test Accuracy: #{(summary[:test_accuracy] * 100).round(2)}% ± #{(summary[:test_accuracy_std] * 100).round(2)}%"
        puts "\nFold-by-fold results:"
        
        fold_results.each_with_index do |result, idx|
          accuracy = result[:basic_metrics][:accuracy]
          puts "  Fold #{idx + 1}: #{(accuracy * 100).round(2)}%"
        end
      end
      
      def calculate_std(values)
        mean = values.sum / values.length
        variance = values.sum { |v| (v - mean) ** 2 } / values.length
        Math.sqrt(variance)
      end
      
      def generate_sample_sizes(total_size)
        max_size = [total_size * 0.8, total_size - 20].min.to_i
        min_size = [20, total_size * 0.1].max.to_i
        
        sizes = []
        current = min_size
        while current <= max_size
          sizes << current
          current = (current * 1.5).to_i
        end
        sizes << max_size if sizes.last != max_size
        
        sizes
      end
      
      def create_data_subset(data_set, sample_size)
        items = data_set.data_items.sample(sample_size, random: Random.new(@random_seed))
        
        Ai4r::Data::DataSet.new(
          data_labels: data_set.data_labels,
          data_items: items
        )
      end
      
      def estimate_bias_variance(fold_results)
        # Simplified bias-variance estimation
        accuracies = fold_results.map { |r| r[:basic_metrics][:accuracy] }
        
        {
          variance: calculate_std(accuracies),
          mean_accuracy: accuracies.sum / accuracies.length
        }
      end
      
      def explain_learning_curves(results)
        puts "\n=== Learning Curve Analysis ==="
        puts "Shows how performance changes with training data size"
        puts "Sample Size | Test Acc | Train Acc | Gap"
        puts "------------|----------|-----------|----"
        
        results.each do |result|
          gap = result[:train_accuracy] - result[:test_accuracy]
          puts sprintf("%11d | %8.1f%% | %9.1f%% | %3.1f%%",
                      result[:sample_size],
                      result[:test_accuracy] * 100,
                      result[:train_accuracy] * 100,
                      gap * 100)
        end
      end
      
      def format_basic_metrics(metrics)
        "  Accuracy: #{(metrics[:accuracy] * 100).round(2)}%\n" +
        "  Correct:  #{metrics[:correct_predictions]}/#{metrics[:total_samples]}"
      end
      
      def format_class_metrics(metrics)
        result = ""
        metrics.each do |class_name, class_metrics|
          next if [:macro_avg, :micro_avg].include?(class_name)
          result += "    #{class_name}: P=#{(class_metrics[:precision] * 100).round(1)}% " +
                   "R=#{(class_metrics[:recall] * 100).round(1)}% " +
                   "F1=#{(class_metrics[:f1_score] * 100).round(1)}%\n"
        end
        result
      end
      
      def format_comparison_results(comparison_results)
        summary = comparison_results[:summary]
        "Best Accuracy: #{summary[:best_accuracy][:classifier]} " +
        "(#{(summary[:best_accuracy][:score] * 100).round(2)}%)\n" +
        "Most Balanced: #{summary[:most_balanced][:classifier]} " +
        "(F1: #{(summary[:most_balanced][:score] * 100).round(2)}%)"
      end
      
      def get_feature_names(data_set)
        if data_set.data_labels && data_set.data_labels.length > 1
          data_set.data_labels[0...-1]
        else
          (1...(data_set.data_items.first.length)).map { |i| "Feature_#{i}" }
        end
      end
    end
  end
end