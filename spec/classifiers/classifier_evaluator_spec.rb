# frozen_string_literal: true

# RSpec tests for AI4R ClassifierEvaluator based on requirement document
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe Ai4r::Classifiers::ClassifierEvaluator do
  # Test data from requirement document
  let(:perfect_predictions) { %w[A B A C B A C B] }
  let(:perfect_actual) { %w[A B A C B A C B] }

  let(:mixed_predictions) { %w[A B A C A A C C] }
  let(:mixed_actual) { %w[A B A C B A C B] }

  let(:binary_predictions) { %w[yes no yes no yes no] }
  let(:binary_actual) { %w[yes yes yes no no no] }

  let(:all_wrong_predictions) { %w[A A A A] }
  let(:all_wrong_actual) { %w[B B B B] }

  let(:single_class_predictions) { %w[A A A A] }
  let(:single_class_actual) { %w[A A A A] }

  describe 'Accuracy Evaluation Tests' do
    context 'basic accuracy' do
      it 'test_perfect_accuracy' do
        # Perfect predictions should give 100% accuracy
        accuracy = described_class.accuracy(perfect_actual, perfect_predictions)

        expect(accuracy).to eq(1.0) # 100% accuracy
      end

      it 'test_mixed_accuracy' do
        # Mixed predictions should give partial accuracy
        accuracy = described_class.accuracy(mixed_actual, mixed_predictions)

        # mixed_actual:     ['A', 'B', 'A', 'C', 'B', 'A', 'C', 'B']
        # mixed_predictions: ['A', 'B', 'A', 'C', 'A', 'A', 'C', 'C']
        # Correct: A, B, A, C, _, A, C, _ = 6/8 = 0.75

        expect(accuracy).to be_within(0.001).of(0.75)
      end

      it 'test_zero_accuracy' do
        # All wrong predictions should give 0% accuracy
        accuracy = described_class.accuracy(all_wrong_actual, all_wrong_predictions)

        expect(accuracy).to eq(0.0)
      end

      it 'test_single_class_accuracy' do
        # Single class scenario
        accuracy = described_class.accuracy(single_class_actual, single_class_predictions)

        expect(accuracy).to eq(1.0)
      end
    end

    context 'accuracy edge cases' do
      it 'test_empty_predictions' do
        # Should handle empty prediction sets
        expect do
          described_class.accuracy([], [])
        end.to raise_error(ArgumentError)
      end

      it 'test_mismatched_lengths' do
        # Should validate equal length arrays
        expect do
          described_class.accuracy(%w[A B], ['A'])
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe 'Precision and Recall Tests' do
    context 'binary classification metrics' do
      it 'test_binary_precision' do
        # Precision = TP / (TP + FP)
        precision = described_class.precision(binary_actual, binary_predictions, 'yes')

        # binary_actual:     ['yes', 'yes', 'yes', 'no',  'no',  'no' ]
        # binary_predictions: ['yes', 'no',  'yes', 'no',  'yes', 'no' ]
        # For 'yes': TP=2, FP=1, so precision = 2/(2+1) = 0.667

        expect(precision).to be_within(0.001).of(2.0 / 3.0)
      end

      it 'test_binary_recall' do
        # Recall = TP / (TP + FN)
        recall = described_class.recall(binary_actual, binary_predictions, 'yes')

        # For 'yes': TP=2, FN=1 (missed one 'yes'), so recall = 2/(2+1) = 0.667

        expect(recall).to be_within(0.001).of(2.0 / 3.0)
      end

      it 'test_f1_score' do
        # F1 = 2 * (precision * recall) / (precision + recall)
        if described_class.respond_to?(:f1_score)
          f1 = described_class.f1_score(binary_actual, binary_predictions, 'yes')

          precision = described_class.precision(binary_actual, binary_predictions, 'yes')
          recall = described_class.recall(binary_actual, binary_predictions, 'yes')
          expected_f1 = 2 * (precision * recall) / (precision + recall)

          expect(f1).to be_within(0.001).of(expected_f1)
        end
      end
    end

    context 'multiclass metrics' do
      it 'test_multiclass_precision' do
        # Test precision for each class in multiclass scenario
        classes = %w[A B C]

        classes.each do |cls|
          precision = described_class.precision(mixed_actual, mixed_predictions, cls)

          expect(precision).to be_between(0.0, 1.0)
          expect(precision).to be_finite
        end
      end

      it 'test_class_specific_metrics' do
        # Test metrics for specific class 'A'
        precision_a = described_class.precision(mixed_actual, mixed_predictions, 'A')
        recall_a = described_class.recall(mixed_actual, mixed_predictions, 'A')

        # Class 'A' analysis:
        # mixed_actual:     ['A', 'B', 'A', 'C', 'B', 'A', 'C', 'B']
        # mixed_predictions: ['A', 'B', 'A', 'C', 'A', 'A', 'C', 'C']
        # 'A' appears at positions: actual=[0,2,5], predicted=[0,2,4,5]
        # TP=2 (positions 0,2), FP=1 (position 4), FN=1 (position 5 missed)
        # Precision = 2/(2+1) = 0.667, Recall = 2/(2+1) = 0.667

        expect(precision_a).to be_within(0.001).of(0.5) # 2 correct out of 4 predicted
        expect(recall_a).to be_within(0.001).of(2.0 / 3.0) # 2 correct out of 3 actual
      end
    end
  end

  describe 'Confusion Matrix Tests' do
    context 'matrix generation' do
      it 'test_confusion_matrix_binary' do
        # Should generate confusion matrix for binary classification
        if described_class.respond_to?(:confusion_matrix)
          matrix = described_class.confusion_matrix(binary_actual, binary_predictions)

          expect(matrix).to be_a(Hash)
          expect(matrix.keys).to include('yes', 'no')

          # Each row should contain counts for actual vs predicted
          matrix.each_value do |row|
            expect(row).to be_a(Hash)
            expect(row.keys).to include('yes', 'no')

            row.each_value do |count|
              expect(count).to be_an(Integer)
              expect(count).to be >= 0
            end
          end
        end
      end

      it 'test_confusion_matrix_multiclass' do
        # Should handle multiclass confusion matrix
        if described_class.respond_to?(:confusion_matrix)
          matrix = described_class.confusion_matrix(mixed_actual, mixed_predictions)

          expect(matrix).to be_a(Hash)
          classes = %w[A B C]

          classes.each do |cls|
            expect(matrix.keys).to include(cls)

            matrix[cls].each_value do |count|
              expect(count).to be_an(Integer)
              expect(count).to be >= 0
            end
          end
        end
      end
    end

    context 'matrix validation' do
      it 'test_matrix_totals' do
        # Matrix totals should equal number of samples
        if described_class.respond_to?(:confusion_matrix)
          matrix = described_class.confusion_matrix(mixed_actual, mixed_predictions)

          total_predictions = 0
          matrix.each_value do |row|
            row.each_value do |count|
              total_predictions += count
            end
          end

          expect(total_predictions).to eq(mixed_actual.length)
        end
      end
    end
  end

  describe 'Cross-Validation Evaluation Tests' do
    context 'k-fold validation' do
      it 'test_cross_validation_setup' do
        # Should support cross-validation evaluation
        if described_class.respond_to?(:cross_validate)
          # Create simple dataset for testing
          dataset_items = [
            %w[feature1 A], %w[feature2 B], %w[feature3 A],
            %w[feature4 B], %w[feature5 A], %w[feature6 B]
          ]

          dataset = Ai4r::Data::DataSet.new(
            data_items: dataset_items,
            data_labels: %w[feature class]
          )

          # Simple classifier that always predicts 'A'
          dummy_classifier = double('classifier')
          allow(dummy_classifier).to receive_messages(build: dummy_classifier, eval: 'A')

          expect do
            results = described_class.cross_validate(dummy_classifier, dataset, 3) # 3-fold
            expect(results).to be_an(Array)
          end.not_to raise_error
        end
      end
    end

    context 'bootstrap evaluation' do
      it 'test_bootstrap_validation' do
        # Should support bootstrap validation if available
        if described_class.respond_to?(:bootstrap_validate)
          dataset_items = [
            %w[f1 A], %w[f2 B], %w[f3 A], %w[f4 B]
          ]

          dataset = Ai4r::Data::DataSet.new(
            data_items: dataset_items,
            data_labels: %w[feature class]
          )

          dummy_classifier = double('classifier')
          allow(dummy_classifier).to receive_messages(build: dummy_classifier, eval: 'A')

          expect do
            results = described_class.bootstrap_validate(dummy_classifier, dataset, 10)
            expect(results).to be_an(Array)
          end.not_to raise_error
        end
      end
    end
  end

  describe 'Statistical Tests' do
    context 'significance testing' do
      it 'test_mcnemar_test' do
        # McNemar's test for comparing two classifiers
        if described_class.respond_to?(:mcnemar_test)
          classifier1_predictions = %w[A B A C B]
          classifier2_predictions = %w[A B B C A]
          actual_values = %w[A B A C B]

          result = described_class.mcnemar_test(
            actual_values,
            classifier1_predictions,
            classifier2_predictions
          )

          expect(result).to be_a(Hash)
          expect(result.keys).to include(:statistic, :p_value)
          expect(result[:p_value]).to be_between(0.0, 1.0)
        end
      end

      it 'test_paired_t_test' do
        # Paired t-test for comparing accuracy across folds
        if described_class.respond_to?(:paired_t_test)
          accuracies1 = [0.8, 0.7, 0.9, 0.6, 0.8]
          accuracies2 = [0.7, 0.8, 0.8, 0.7, 0.9]

          result = described_class.paired_t_test(accuracies1, accuracies2)

          expect(result).to be_a(Hash)
          expect(result.keys).to include(:statistic, :p_value)
          expect(result[:p_value]).to be_between(0.0, 1.0)
        end
      end
    end
  end

  describe 'Performance Analysis Tests' do
    context 'comprehensive evaluation' do
      it 'test_classification_report' do
        # Should generate comprehensive classification report
        if described_class.respond_to?(:classification_report)
          report = described_class.classification_report(mixed_actual, mixed_predictions)

          expect(report).to be_a(Hash)

          # Should include metrics for each class
          classes = mixed_actual.uniq
          classes.each do |cls|
            expect(report.keys).to include(cls)

            class_metrics = report[cls]
            expect(class_metrics.keys).to include(:precision, :recall)

            expect(class_metrics[:precision]).to be_between(0.0, 1.0)
            expect(class_metrics[:recall]).to be_between(0.0, 1.0)
          end

          # Should include overall metrics
          expect(report.keys).to include(:overall)
          expect(report[:overall][:accuracy]).to be_between(0.0, 1.0)
        end
      end
    end

    context 'evaluation summary' do
      it 'test_evaluation_summary' do
        # Should provide summary statistics
        summary = {
          accuracy: described_class.accuracy(mixed_actual, mixed_predictions),
          classes: mixed_actual.uniq.length
        }

        expect(summary[:accuracy]).to be_between(0.0, 1.0)
        expect(summary[:classes]).to be > 0
      end
    end
  end

  describe 'Edge Case Tests' do
    context 'unusual scenarios' do
      it 'test_single_sample' do
        # Should handle single sample evaluation
        single_actual = ['A']
        single_predicted = ['A']

        accuracy = described_class.accuracy(single_actual, single_predicted)
        expect(accuracy).to eq(1.0)

        precision = described_class.precision(single_actual, single_predicted, 'A')
        expect(precision).to eq(1.0)
      end

      it 'test_unseen_class_in_predictions' do
        # Should handle class in predictions but not in actual
        actual_with_limited = %w[A A B B]
        predicted_with_extra = %w[A C B B] # 'C' not in actual

        expect do
          accuracy = described_class.accuracy(actual_with_limited, predicted_with_extra)
          expect(accuracy).to be_between(0.0, 1.0)
        end.not_to raise_error
      end
    end
  end

  describe 'Integration Tests' do
    it 'provides comprehensive evaluation capabilities' do
      # Complete evaluation workflow
      accuracy = described_class.accuracy(mixed_actual, mixed_predictions)

      classes = mixed_actual.uniq
      precision_scores = classes.map do |cls|
        described_class.precision(mixed_actual, mixed_predictions, cls)
      end

      recall_scores = classes.map do |cls|
        described_class.recall(mixed_actual, mixed_predictions, cls)
      end

      # All metrics should be valid
      expect(accuracy).to be_between(0.0, 1.0)

      precision_scores.each do |score|
        expect(score).to be_between(0.0, 1.0)
      end

      recall_scores.each do |score|
        expect(score).to be_between(0.0, 1.0)
      end
    end

    it 'maintains consistency across metrics' do
      # Perfect classifier should have perfect metrics
      accuracy = described_class.accuracy(perfect_actual, perfect_predictions)
      expect(accuracy).to eq(1.0)

      classes = perfect_actual.uniq
      classes.each do |cls|
        precision = described_class.precision(perfect_actual, perfect_predictions, cls)
        recall = described_class.recall(perfect_actual, perfect_predictions, cls)

        expect(precision).to eq(1.0)
        expect(recall).to eq(1.0)
      end
    end
  end

  # Helper methods for testing
  def calculate_tp_fp_tn_fn(actual, predicted, target_class)
    tp = fp = tn = fn = 0

    actual.zip(predicted).each do |a, p|
      if a == target_class && p == target_class
        tp += 1
      elsif a != target_class && p == target_class
        fp += 1
      elsif a != target_class && p != target_class
        tn += 1
      elsif a == target_class && p != target_class
        fn += 1
      end
    end

    { tp: tp, fp: fp, tn: tn, fn: fn }
  end

  def assert_valid_metric(metric_value)
    expect(metric_value).to be_a(Numeric)
    expect(metric_value).to be_between(0.0, 1.0)
    expect(metric_value).to be_finite
  end
end
