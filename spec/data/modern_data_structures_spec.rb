# frozen_string_literal: true

# RSpec tests for AI4R Modern Data Structures
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe 'Modern Data Structures' do
  before(:all) do
    require_relative '../../lib/ai4r/data/modern_data_structures'
  end

  describe Ai4r::Data::OutlierResult do
    let(:outlier_result) do
      described_class.new(
        count: 5,
        percentage: 12.5,
        indices: [1, 5, 8, 12, 15],
        values: [100.0, 200.0, 150.0, 300.0, 250.0],
        method: :iqr,
        threshold: 1.5,
        boundaries: [10.0, 90.0]
      )
    end

    describe '#educational_summary' do
      it 'provides clear summary with severity indicator' do
        summary = outlier_result.educational_summary
        expect(summary).to include('5 outliers')
        expect(summary).to include('12.5%')
        expect(summary).to include('iqr')
        expect(summary).to match(/🟡|🟢|🟠|🔴/) # Contains severity icon
      end
    end

    describe '#severity' do
      it 'calculates severity based on percentage' do
        expect(outlier_result.severity).to eq(:moderate)
      end

      it 'handles different severity levels' do
        low_severity = described_class.new(
          count: 1, percentage: 2.0, indices: [1], values: [100.0],
          method: :iqr, threshold: 1.5, boundaries: [10.0, 90.0]
        )
        expect(low_severity.severity).to eq(:low)

        high_severity = described_class.new(
          count: 10, percentage: 25.0, indices: [1], values: [100.0],
          method: :iqr, threshold: 1.5, boundaries: [10.0, 90.0]
        )
        expect(high_severity.severity).to eq(:high)
      end
    end

    describe '#severity_icon' do
      it 'returns appropriate icon for severity level' do
        expect(outlier_result.severity_icon).to eq('🟡')
      end
    end

    describe '#empty? and #any?' do
      it 'correctly identifies non-empty result' do
        expect(outlier_result.empty?).to be false
        expect(outlier_result.any?).to be true
      end

      it 'correctly identifies empty result' do
        empty_result = described_class.new(
          count: 0, percentage: 0.0, indices: [], values: [],
          method: :iqr, threshold: 1.5, boundaries: [10.0, 90.0]
        )
        expect(empty_result.empty?).to be true
        expect(empty_result.any?).to be false
      end
    end

    it 'satisfies outlier properties' do
      expect(outlier_result).to satisfy_outlier_properties
    end
  end

  describe Ai4r::Data::MissingValueResult do
    let(:missing_value_result) do
      described_class.new(
        column: 'age',
        count: 8,
        percentage: 15.0,
        pattern: :random,
        recommendation: 'mean imputation'
      )
    end

    describe '#severity' do
      it 'categorizes missing value severity' do
        expect(missing_value_result.severity).to eq(:moderate)
      end
    end

    describe '#actionable?' do
      it 'determines if missing values are actionable' do
        expect(missing_value_result.actionable?).to be true
      end

      it 'identifies non-actionable cases' do
        severe_missing = described_class.new(
          column: 'test', count: 40, percentage: 80.0,
          pattern: :random, recommendation: 'remove column'
        )
        expect(severe_missing.actionable?).to be false
      end
    end

    describe '#educational_summary' do
      it 'provides actionable guidance' do
        summary = missing_value_result.educational_summary
        expect(summary).to include('8 missing values')
        expect(summary).to include('15.0%')
        expect(summary).to include('mean imputation')
        expect(summary).to include('⚠️')
      end
    end

    it 'provides educational value' do
      expect(missing_value_result).to be_educational_result
    end
  end

  describe Ai4r::Data::CorrelationResult do
    describe '.from_coefficient' do
      it 'creates correlation result from coefficient' do
        result = described_class.from_coefficient('height', 'weight', 0.75)

        expect(result.feature1).to eq('height')
        expect(result.feature2).to eq('weight')
        expect(result.coefficient).to eq(0.75)
        expect(result.strength).to eq(:strong)
        expect(result.direction).to eq(:positive)
      end

      it 'handles negative correlations' do
        result = described_class.from_coefficient('temperature', 'coat_sales', -0.65)

        expect(result.strength).to eq(:moderate)
        expect(result.direction).to eq(:negative)
      end

      it 'categorizes correlation strength correctly' do
        weak_result = described_class.from_coefficient('a', 'b', 0.15)
        expect(weak_result.strength).to eq(:weak)

        moderate_result = described_class.from_coefficient('a', 'b', 0.45)
        expect(moderate_result.strength).to eq(:moderate)

        strong_result = described_class.from_coefficient('a', 'b', 0.85)
        expect(strong_result.strength).to eq(:strong)
      end
    end

    describe '#significant?' do
      it 'identifies significant correlations' do
        strong_correlation = described_class.from_coefficient('a', 'b', 0.8)
        expect(strong_correlation.significant?).to be true

        weak_correlation = described_class.from_coefficient('a', 'b', 0.2)
        expect(weak_correlation.significant?).to be false
      end
    end

    describe '#educational_summary' do
      it 'provides comprehensive correlation description' do
        result = described_class.from_coefficient('height', 'weight', 0.75)
        summary = result.educational_summary

        expect(summary).to include('height')
        expect(summary).to include('weight')
        expect(summary).to include('strong')
        expect(summary).to include('positive')
        expect(summary).to include('0.75')
        expect(summary).to match(/🔴.*⬆️/) # Strong positive correlation icons
      end
    end
  end

  describe Ai4r::Data::EducationalConfig do
    describe 'preset configurations' do
      it 'creates beginner configuration' do
        config = described_class.beginner

        expect(config.verbose).to be true
        expect(config.explain_operations).to be true
        expect(config.interactive_mode).to be true
        expect(config.learning_level).to eq(:beginner)
        expect(config.step_by_step).to be true
      end

      it 'creates intermediate configuration' do
        config = described_class.intermediate

        expect(config.verbose).to be true
        expect(config.explain_operations).to be false
        expect(config.learning_level).to eq(:intermediate)
        expect(config.step_by_step).to be false
      end

      it 'creates advanced configuration' do
        config = described_class.advanced

        expect(config.verbose).to be false
        expect(config.explain_operations).to be false
        expect(config.interactive_mode).to be false
        expect(config.learning_level).to eq(:advanced)
        expect(config.show_progress).to be false
      end
    end

    describe 'educational helpers' do
      let(:beginner_config) { described_class.beginner }
      let(:advanced_config) { described_class.advanced }

      it 'identifies educational configurations' do
        expect(beginner_config.educational?).to be true
        expect(advanced_config.educational?).to be false
      end

      it 'determines explanation behavior' do
        expect(beginner_config.should_explain?).to be true
        expect(advanced_config.should_explain?).to be false
      end

      it 'determines interaction behavior' do
        expect(beginner_config.should_interact?).to be true
        expect(advanced_config.should_interact?).to be false
      end
    end
  end

  describe Ai4r::Data::DataQualityResult do
    let(:quality_result) do
      described_class.new(
        overall_score: 85,
        completeness: 90,
        consistency: 85,
        validity: 80,
        uniqueness: 85,
        issues: ['Some missing values', 'Minor inconsistencies'],
        recommendations: ['Impute missing values', 'Standardize formats']
      )
    end

    describe '#grade' do
      it 'assigns letter grades based on score' do
        expect(quality_result.grade).to eq('B')
      end

      it 'handles different grade ranges' do
        excellent = described_class.new(
          overall_score: 95, completeness: 95, consistency: 95,
          validity: 95, uniqueness: 95, issues: [], recommendations: []
        )
        expect(excellent.grade).to eq('A')

        poor = described_class.new(
          overall_score: 55, completeness: 60, consistency: 50,
          validity: 55, uniqueness: 50, issues: ['Many issues'], recommendations: ['Fix everything']
        )
        expect(poor.grade).to eq('F')
      end
    end

    describe '#needs_improvement?' do
      it 'identifies when improvement is needed' do
        expect(quality_result.needs_improvement?).to be false

        poor_quality = described_class.new(
          overall_score: 70, completeness: 70, consistency: 70,
          validity: 70, uniqueness: 70, issues: ['Issues'], recommendations: ['Improve']
        )
        expect(poor_quality.needs_improvement?).to be true
      end
    end

    describe '#educational_summary' do
      it 'provides clear quality assessment' do
        summary = quality_result.educational_summary
        expect(summary).to include('85/100')
        expect(summary).to include('Grade: B')
        expect(summary).to include('🟡') # Grade B icon
      end
    end
  end

  describe Ai4r::Data::DataValidator do
    describe '.validate_data_items' do
      it 'validates correct data format' do
        valid_data = [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9]
        ]

        result = described_class.validate_data_items(valid_data)
        expect(result.success?).to be true
        expect(result.errors).to be_empty
      end

      it 'detects empty data' do
        result = described_class.validate_data_items([])
        expect(result.success?).to be false
        expect(result.errors).to include('Data items cannot be empty')
      end

      it 'detects inconsistent row lengths' do
        invalid_data = [
          [1, 2, 3],
          [4, 5], # Missing column
          [7, 8, 9]
        ]

        result = described_class.validate_data_items(invalid_data)
        expect(result.success?).to be false
        expect(result.errors).to include('Inconsistent row lengths')
      end

      it 'detects non-array items' do
        invalid_data = [
          [1, 2, 3],
          'not an array',
          [7, 8, 9]
        ]

        result = described_class.validate_data_items(invalid_data)
        expect(result.success?).to be false
        expect(result.errors).to include('Data items must be arrays')
      end

      it 'warns about empty rows' do
        data_with_empty = [
          [1, 2, 3],
          [nil, nil, nil],
          [7, 8, 9]
        ]

        result = described_class.validate_data_items(data_with_empty)
        expect(result.has_warnings?).to be true
        expect(result.warnings.first).to include('rows are completely empty')
      end
    end

    describe '.validate_normalization_params' do
      let(:test_data) do
        [
          [1, 10, 100],
          [2, 20, 200],
          [3, 30, 300]
        ]
      end

      it 'validates min_max normalization' do
        result = described_class.validate_normalization_params(
          method: :min_max,
          data_items: test_data
        )
        expect(result.success?).to be true
      end

      it 'validates z_score normalization' do
        result = described_class.validate_normalization_params(
          method: :z_score,
          data_items: test_data
        )
        expect(result.success?).to be true
        expect(result.warnings).to include(/normal distribution/)
      end

      it 'validates robust normalization' do
        result = described_class.validate_normalization_params(
          method: :robust,
          data_items: test_data
        )
        expect(result.success?).to be true
      end

      it 'rejects unknown methods' do
        result = described_class.validate_normalization_params(
          method: :unknown,
          data_items: test_data
        )
        expect(result.success?).to be false
        expect(result.errors).to include('Unknown normalization method: unknown')
      end
    end

    describe 'ValidationResult' do
      it 'provides educational summaries' do
        success_result = described_class::ValidationResult.new(true, [], [])
        expect(success_result.educational_summary).to include('✅ Validation passed')

        warning_result = described_class::ValidationResult.new(true, [], ['Warning'])
        expect(warning_result.educational_summary).to include('✅ Validation passed with warnings')

        error_result = described_class::ValidationResult.new(false, ['Error'], [])
        expect(error_result.educational_summary).to include('❌ Validation failed')
      end
    end
  end

  describe Ai4r::Data::ProgressTracker do
    let(:tracker) { described_class.new }

    describe '#add_step' do
      it 'adds steps to tracker' do
        tracker.add_step('step1', 'First step')
        tracker.add_step('step2', 'Second step')

        expect(tracker.to_a).to have(2).items
        expect(tracker.to_a.first[:name]).to eq('step1')
        expect(tracker.to_a.first[:description]).to eq('First step')
      end

      it 'supports method chaining' do
        result = tracker.add_step('step1', 'First step')
        expect(result).to be(tracker)
      end
    end

    describe '#complete_step' do
      before do
        tracker.add_step('step1', 'First step')
        tracker.add_step('step2', 'Second step')
      end

      it 'marks step as completed' do
        tracker.complete_step('step1')

        step = tracker.to_a.first
        expect(step[:completed]).to be true
        expect(step[:timestamp]).to be_a(Time)
      end

      it 'supports block execution' do
        executed = false
        tracker.complete_step('step1') do |step|
          executed = true
          expect(step[:name]).to eq('step1')
        end

        expect(executed).to be true
      end

      it 'supports method chaining' do
        result = tracker.complete_step('step1')
        expect(result).to be(tracker)
      end
    end

    describe '#current_progress' do
      before do
        tracker.add_step('step1', 'First step')
        tracker.add_step('step2', 'Second step')
        tracker.add_step('step3', 'Third step')
      end

      it 'calculates progress percentage' do
        expect(tracker.current_progress).to eq(0.0)

        tracker.complete_step('step1')
        expect(tracker.current_progress).to be_approximately(33.3, 0.1)

        tracker.complete_step('step2')
        expect(tracker.current_progress).to be_approximately(66.7, 0.1)

        tracker.complete_step('step3')
        expect(tracker.current_progress).to eq(100.0)
      end

      it 'handles empty tracker' do
        empty_tracker = described_class.new
        expect(empty_tracker.current_progress).to eq(0)
      end
    end

    describe '#summary' do
      it 'provides progress summary' do
        tracker.add_step('step1', 'First step')
        tracker.add_step('step2', 'Second step')
        tracker.complete_step('step1')

        summary = tracker.summary
        expect(summary).to include('1/2 steps completed')
        expect(summary).to include('50.0%')
      end
    end
  end

  describe 'Ruby version compatibility' do
    it 'uses Data classes when available' do
      if defined?(Data) && Data.respond_to?(:define)
        expect(Ai4r::Data::OutlierResult.ancestors).to include(Data)
      else
        expect(Ai4r::Data::OutlierResult.ancestors).to include(Struct)
      end
    end

    it 'falls back to Struct for older Ruby versions' do
      # Test that both implementations have the same interface
      result = Ai4r::Data::OutlierResult.new(
        count: 1, percentage: 5.0, indices: [1], values: [100],
        method: :iqr, threshold: 1.5, boundaries: [10, 90]
      )

      expect(result).to respond_to(:count)
      expect(result).to respond_to(:percentage)
      expect(result).to respond_to(:educational_summary)
      expect(result).to respond_to(:severity)
      expect(result).to respond_to(:any?)
      expect(result).to respond_to(:empty?)
    end
  end

  describe 'educational error handling' do
    it 'provides helpful error messages' do
      expect do
        raise Ai4r::Data::DataHandlingError.new(
          'Test error',
          suggestions: ['Try this', 'Or this'],
          help_topic: :testing
        )
      end.to raise_error(Ai4r::Data::DataHandlingError) do |error|
        expect(error.message).to include('Test error')
        expect(error.message).to include('💡 Suggestions:')
        expect(error.message).to include('Try this')
        expect(error.message).to include('📚 Learn more: dataset.help(:testing)')
      end
    end

    it 'provides context and suggestions' do
      error = Ai4r::Data::DataHandlingError.new(
        'Context-aware error',
        context: { operation: 'test' },
        suggestions: ['Suggestion 1', 'Suggestion 2']
      )

      expect(error.context).to eq({ operation: 'test' })
      expect(error.suggestions).to eq(['Suggestion 1', 'Suggestion 2'])
    end
  end
end
