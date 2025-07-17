# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ai4r::Experiment::ClassifierBench do
  let(:sample_data) do
    Ai4r::Data::DataSet.new(
      data_labels: %w[feature1 feature2 class],
      data_items: [
        [1.0, 2.0, 'A'],
        [1.1, 2.1, 'A'],
        [1.2, 2.2, 'A'],
        [1.3, 2.3, 'A'],
        [1.4, 2.4, 'A'],
        [3.0, 4.0, 'B'],
        [3.1, 4.1, 'B'],
        [3.2, 4.2, 'B'],
        [3.3, 4.3, 'B'],
        [3.4, 4.4, 'B'],
        [5.0, 6.0, 'C'],
        [5.1, 6.1, 'C'],
        [5.2, 6.2, 'C'],
        [5.3, 6.3, 'C'],
        [5.4, 6.4, 'C']
      ]
    )
  end

  let(:iris_data) do
    Ai4r::Data::DataSet.new(
      data_labels: %w[sepal_length sepal_width petal_length petal_width species],
      data_items: [
        # Setosa examples
        [5.1, 3.5, 1.4, 0.2, 'setosa'],
        [4.9, 3.0, 1.4, 0.2, 'setosa'],
        [4.7, 3.2, 1.3, 0.2, 'setosa'],
        [4.6, 3.1, 1.5, 0.2, 'setosa'],
        [5.0, 3.6, 1.4, 0.2, 'setosa'],
        [5.4, 3.9, 1.7, 0.4, 'setosa'],
        [4.6, 3.4, 1.4, 0.3, 'setosa'],
        [5.0, 3.4, 1.5, 0.2, 'setosa'],
        [4.4, 2.9, 1.4, 0.2, 'setosa'],
        [4.9, 3.1, 1.5, 0.1, 'setosa'],

        # Versicolor examples
        [7.0, 3.2, 4.7, 1.4, 'versicolor'],
        [6.4, 3.2, 4.5, 1.5, 'versicolor'],
        [6.9, 3.1, 4.9, 1.5, 'versicolor'],
        [5.5, 2.3, 4.0, 1.3, 'versicolor'],
        [6.5, 2.8, 4.6, 1.5, 'versicolor'],
        [5.7, 2.8, 4.5, 1.3, 'versicolor'],
        [6.3, 3.3, 4.7, 1.6, 'versicolor'],
        [4.9, 2.4, 3.3, 1.0, 'versicolor'],
        [6.6, 2.9, 4.6, 1.3, 'versicolor'],
        [5.2, 2.7, 3.9, 1.4, 'versicolor'],

        # Virginica examples
        [6.3, 3.3, 6.0, 2.5, 'virginica'],
        [5.8, 2.7, 5.1, 1.9, 'virginica'],
        [7.1, 3.0, 5.9, 2.1, 'virginica'],
        [6.3, 2.9, 5.6, 1.8, 'virginica'],
        [6.5, 3.0, 5.8, 2.2, 'virginica'],
        [7.6, 3.0, 6.6, 2.1, 'virginica'],
        [4.9, 2.5, 4.5, 1.7, 'virginica'],
        [7.3, 2.9, 6.3, 1.8, 'virginica'],
        [6.7, 2.5, 5.8, 1.8, 'virginica'],
        [7.2, 3.6, 6.1, 2.5, 'virginica']
      ]
    )
  end

  describe '#initialize' do
    it 'creates a new benchmark with default options' do
      bench = described_class.new

      expect(bench.classifiers).to be_empty
      expect(bench.verbose).to be false
      expect(bench.cross_validation_folds).to eq(5)
    end

    it 'accepts custom options' do
      bench = described_class.new(
        verbose: true,
        cross_validation_folds: 10,
        educational_mode: false
      )

      expect(bench.verbose).to be true
      expect(bench.cross_validation_folds).to eq(10)
    end
  end

  describe '#add_classifier' do
    let(:bench) { described_class.new }
    let(:classifier) { Ai4r::Classifiers::ID3.new }

    it 'adds a classifier to the benchmark' do
      bench.add_classifier(:test_classifier, classifier)

      expect(bench.classifiers).to have_key(:test_classifier)
      expect(bench.classifiers[:test_classifier][:instance]).to eq(classifier)
    end

    it 'accepts custom options and friendly names' do
      bench.add_classifier(
        :test_classifier,
        classifier,
        friendly_name: 'My Test Classifier',
        custom_option: 'value'
      )

      classifier_info = bench.classifiers[:test_classifier]
      expect(classifier_info[:friendly_name]).to eq('My Test Classifier')
      expect(classifier_info[:options][:custom_option]).to eq('value')
    end

    it 'generates friendly names from classifier keys' do
      bench.add_classifier(:decision_tree_classifier, classifier)

      classifier_info = bench.classifiers[:decision_tree_classifier]
      expect(classifier_info[:friendly_name]).to eq('Decision Tree Classifier')
    end

    it 'raises error for invalid classifier' do
      invalid_classifier = Object.new

      expect do
        bench.add_classifier(:invalid, invalid_classifier)
      end.to raise_error(ArgumentError, 'Classifier must implement build and eval methods')
    end
  end

  describe '#run' do
    let(:bench) { described_class.new(verbose: false) }
    let(:id3) { Ai4r::Classifiers::ID3.new }
    let(:naive_bayes) { Ai4r::Classifiers::NaiveBayes.new }

    before do
      bench.add_classifier(:id3, id3)
      bench.add_classifier(:naive_bayes, naive_bayes)
    end

    it 'runs benchmark on a dataset' do
      results = bench.run(sample_data)

      expect(results).to have_key(:id3)
      expect(results).to have_key(:naive_bayes)
    end

    it 'validates dataset before running' do
      empty_dataset = Ai4r::Data::DataSet.new(data_labels: [], data_items: [])

      expect do
        bench.run(empty_dataset)
      end.to raise_error(ArgumentError, 'Dataset cannot be empty')
    end

    it 'requires at least 2 classes' do
      single_class_data = Ai4r::Data::DataSet.new(
        data_labels: %w[feature class],
        data_items: [
          [1.0, 'A'],
          [2.0, 'A'],
          [3.0, 'A']
        ]
      )

      expect do
        bench.run(single_class_data)
      end.to raise_error(ArgumentError, 'Dataset must have at least 2 classes')
    end

    it 'calculates comprehensive metrics' do
      results = bench.run(sample_data)

      results.each_value do |result|
        expect(result[:metrics]).to have_key(:accuracy)
        expect(result[:metrics]).to have_key(:macro_precision)
        expect(result[:metrics]).to have_key(:macro_recall)
        expect(result[:metrics]).to have_key(:macro_f1)
        expect(result[:metrics]).to have_key(:weighted_precision)
        expect(result[:metrics]).to have_key(:weighted_recall)
        expect(result[:metrics]).to have_key(:weighted_f1)
      end
    end

    it 'measures timing information' do
      results = bench.run(sample_data)

      results.each_value do |result|
        expect(result[:timing]).to have_key(:avg_training_time)
        expect(result[:timing]).to have_key(:avg_prediction_time)
        expect(result[:timing]).to have_key(:total_time)

        expect(result[:timing][:avg_training_time]).to be >= 0
        expect(result[:timing][:avg_prediction_time]).to be >= 0
        expect(result[:timing][:total_time]).to be >= 0
      end
    end

    it 'creates confusion matrices' do
      results = bench.run(sample_data)

      results.each_value do |result|
        expect(result[:confusion_matrix]).to be_a(Hash)
        expect(result[:confusion_matrix]).not_to be_empty
      end
    end

    it 'performs cross-validation' do
      results = bench.run(sample_data)

      results.each_value do |result|
        expect(result[:cv_scores]).to be_an(Array)
        expect(result[:cv_scores].length).to eq(5) # default 5-fold CV
        expect(result[:cv_scores]).to all(be_a(Float))
      end
    end

    it 'handles classifier errors gracefully' do
      # Create a classifier that will fail
      failing_classifier = double('FailingClassifier')
      allow(failing_classifier).to receive(:respond_to?).with(:build).and_return(true)
      allow(failing_classifier).to receive(:respond_to?).with(:eval).and_return(true)
      allow(failing_classifier).to receive(:build).and_raise(RuntimeError, 'Test error')

      bench.add_classifier(:failing, failing_classifier)
      results = bench.run(sample_data)

      expect(results[:failing][:errors]).not_to be_empty
    end
  end

  describe '#display_results' do
    let(:bench) { described_class.new(verbose: false) }
    let(:id3) { Ai4r::Classifiers::ID3.new }

    before do
      bench.add_classifier(:id3, id3)
    end

    it 'displays results without errors' do
      results = bench.run(sample_data)

      expect do
        bench.display_results(results)
      end.not_to raise_error
    end

    it 'handles empty results' do
      expect do
        bench.display_results({})
      end.not_to raise_error
    end
  end

  describe '#generate_insights' do
    let(:bench) { described_class.new(verbose: false, educational_mode: true) }
    let(:id3) { Ai4r::Classifiers::ID3.new }
    let(:naive_bayes) { Ai4r::Classifiers::NaiveBayes.new }

    before do
      bench.add_classifier(:id3, id3)
      bench.add_classifier(:naive_bayes, naive_bayes)
    end

    it 'generates educational insights' do
      results = bench.run(sample_data)
      insights = bench.generate_insights(results)

      expect(insights).to be_a(String)
      expect(insights).to include('EDUCATIONAL INSIGHTS')
      expect(insights).to include('Dataset Characteristics')
      expect(insights).to include('Algorithm Observations')
    end

    it 'includes dataset analysis' do
      results = bench.run(sample_data)
      insights = bench.generate_insights(results)

      expect(insights).to include('Balance:')
      expect(insights).to include('Complexity:')
      expect(insights).to include('Feature types:')
    end

    it 'includes classifier-specific insights' do
      results = bench.run(sample_data)
      insights = bench.generate_insights(results)

      expect(insights).to include('ID3:')
      expect(insights).to include('Naive Bayes:')
    end

    it 'provides comparative analysis' do
      results = bench.run(sample_data)
      insights = bench.generate_insights(results)

      expect(insights).to include('Comparative Analysis')
      expect(insights).to include('Learning Recommendations')
    end
  end

  describe '#export_results' do
    let(:bench) { described_class.new(verbose: false) }
    let(:id3) { Ai4r::Classifiers::ID3.new }

    before do
      bench.add_classifier(:id3, id3)
      bench.run(sample_data)
    end

    it 'exports to CSV format' do
      expect do
        bench.export_results(:csv, 'test_results')
      end.not_to raise_error

      # Clean up
      FileUtils.rm_f('test_results.csv')
    end

    it 'exports to JSON format' do
      expect do
        bench.export_results(:json, 'test_results')
      end.not_to raise_error

      # Clean up
      FileUtils.rm_f('test_results.json')
    end

    it 'exports to HTML format' do
      expect do
        bench.export_results(:html, 'test_results')
      end.not_to raise_error

      # Clean up
      FileUtils.rm_f('test_results.html')
    end

    it 'raises error for unsupported format' do
      expect do
        bench.export_results(:xml, 'test_results')
      end.to raise_error(ArgumentError, 'Unsupported format: xml')
    end
  end

  describe 'cross-validation' do
    let(:bench) { described_class.new(verbose: false, cross_validation_folds: 3) }
    let(:id3) { Ai4r::Classifiers::ID3.new }

    before do
      bench.add_classifier(:id3, id3)
    end

    it 'respects custom fold count' do
      results = bench.run(sample_data)

      expect(results[:id3][:cv_scores].length).to eq(3)
    end

    it 'creates stratified folds by default' do
      # Run multiple times to check consistency
      results1 = bench.run(sample_data)
      results2 = bench.run(sample_data)

      # Results should be consistent with stratified sampling
      expect(results1[:id3][:metrics][:accuracy]).to be_within(0.1).of(results2[:id3][:metrics][:accuracy])
    end
  end

  describe 'dataset analysis' do
    let(:bench) { described_class.new(verbose: false) }
    let(:id3) { Ai4r::Classifiers::ID3.new }

    before do
      bench.add_classifier(:id3, id3)
    end

    it 'analyzes balanced datasets' do
      bench.run(sample_data) # Balanced dataset

      expect(bench.dataset_characteristics[:balance]).to eq(:balanced)
    end

    it 'detects imbalanced datasets' do
      imbalanced_data = Ai4r::Data::DataSet.new(
        data_labels: %w[feature class],
        data_items: [
          [1.0, 'A'], [1.1, 'A'], [1.2, 'A'], [1.3, 'A'], [1.4, 'A'],
          [1.5, 'A'], [1.6, 'A'], [1.7, 'A'], [1.8, 'A'], [1.9, 'A'],
          [2.0, 'B'], [2.1, 'B']
        ]
      )

      bench.run(imbalanced_data)

      expect(bench.dataset_characteristics[:balance]).to eq(:imbalanced)
    end

    it 'detects feature types' do
      numeric_data = Ai4r::Data::DataSet.new(
        data_labels: %w[feature1 feature2 class],
        data_items: [
          [1.0, 2.0, 'A'], [1.1, 2.1, 'A'], [1.2, 2.2, 'A'],
          [3.0, 4.0, 'B'], [3.1, 4.1, 'B'], [3.2, 4.2, 'B']
        ]
      )

      bench.run(numeric_data)

      expect(bench.dataset_characteristics[:feature_types]).to eq(:all_numeric)
    end
  end

  describe 'metrics calculation' do
    let(:bench) { described_class.new(verbose: false) }

    it 'calculates accuracy correctly' do
      actuals = %w[A A B B C C]
      predictions = %w[A A B B C C]

      metrics = bench.send(:calculate_metrics, actuals, predictions)

      expect(metrics[:accuracy]).to eq(1.0)
    end

    it 'calculates precision and recall' do
      actuals = %w[A A B B C C]
      predictions = %w[A B B B C A]

      metrics = bench.send(:calculate_metrics, actuals, predictions)

      expect(metrics[:accuracy]).to eq(0.5)
      expect(metrics[:macro_precision]).to be_between(0, 1)
      expect(metrics[:macro_recall]).to be_between(0, 1)
      expect(metrics[:macro_f1]).to be_between(0, 1)
    end

    it 'handles edge cases' do
      # All predictions wrong
      actuals = %w[A A A]
      predictions = %w[B B B]

      metrics = bench.send(:calculate_metrics, actuals, predictions)

      expect(metrics[:accuracy]).to eq(0.0)
    end
  end

  describe 'confusion matrix' do
    let(:bench) { described_class.new(verbose: false) }

    it 'builds confusion matrix correctly' do
      actuals = %w[A A B B C C]
      predictions = %w[A A B B C C]

      matrix = bench.send(:build_confusion_matrix, actuals, predictions)

      expect(matrix['A']['A']).to eq(2)
      expect(matrix['B']['B']).to eq(2)
      expect(matrix['C']['C']).to eq(2)
      expect(matrix['A']['B']).to eq(0)
    end

    it 'handles misclassifications' do
      actuals = %w[A A B B]
      predictions = %w[A B B A]

      matrix = bench.send(:build_confusion_matrix, actuals, predictions)

      expect(matrix['A']['A']).to eq(1)
      expect(matrix['A']['B']).to eq(1)
      expect(matrix['B']['A']).to eq(1)
      expect(matrix['B']['B']).to eq(1)
    end
  end

  describe 'performance benchmarking' do
    let(:bench) { described_class.new(verbose: false) }

    it 'benchmarks multiple classifiers on iris dataset' do
      # Add multiple classifiers
      bench.add_classifier(:id3, Ai4r::Classifiers::ID3.new)
      bench.add_classifier(:naive_bayes, Ai4r::Classifiers::NaiveBayes.new)
      bench.add_classifier(:one_r, Ai4r::Classifiers::OneR.new)

      results = bench.run(iris_data)

      expect(results).to have_key(:id3)
      expect(results).to have_key(:naive_bayes)
      expect(results).to have_key(:one_r)

      # All should have reasonable accuracy on iris dataset
      results.each_value do |result|
        expect(result[:metrics][:accuracy]).to be > 0.5
      end
    end

    it 'measures relative performance differences' do
      # Add a simple baseline
      bench.add_classifier(:baseline, Ai4r::Classifiers::ZeroR.new)
      bench.add_classifier(:decision_tree, Ai4r::Classifiers::ID3.new)

      results = bench.run(iris_data)

      baseline_accuracy = results[:baseline][:metrics][:accuracy]
      tree_accuracy = results[:decision_tree][:metrics][:accuracy]

      # Decision tree should outperform baseline
      expect(tree_accuracy).to be > baseline_accuracy
    end

    it 'provides consistent results across runs' do
      bench.add_classifier(:id3, Ai4r::Classifiers::ID3.new)

      results1 = bench.run(sample_data)
      results2 = bench.run(sample_data)

      accuracy1 = results1[:id3][:metrics][:accuracy]
      accuracy2 = results2[:id3][:metrics][:accuracy]

      # Should be exactly the same for deterministic algorithms
      expect(accuracy1).to eq(accuracy2)
    end
  end

  describe 'error handling' do
    let(:bench) { described_class.new(verbose: false) }

    it 'handles nil datasets' do
      expect do
        bench.run(nil)
      end.to raise_error(ArgumentError, 'Dataset cannot be nil')
    end

    it 'handles invalid dataset types' do
      expect do
        bench.run('not a dataset')
      end.to raise_error(ArgumentError, 'Dataset must be a DataSet instance')
    end

    it 'handles empty datasets' do
      empty_dataset = Ai4r::Data::DataSet.new(data_labels: %w[feature class], data_items: [])

      expect do
        bench.run(empty_dataset)
      end.to raise_error(ArgumentError, 'Dataset cannot be empty')
    end
  end

  # Helper method to benchmark test performance
  def benchmark_performance(description)
    start_time = Time.now
    yield
    end_time = Time.now

    puts "#{description}: #{((end_time - start_time) * 1000).round(2)}ms" if ENV['VERBOSE_TESTS']
  end
end
