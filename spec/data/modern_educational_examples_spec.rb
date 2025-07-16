# frozen_string_literal: true

# RSpec tests for AI4R Modern Educational Examples
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe 'Modern Educational Examples' do
  before(:all) do
    require_relative '../../lib/ai4r/data/modern_educational_examples'
  end

  describe Ai4r::Data::ModernEducationalExamples do
    describe 'TutorialConfig' do
      describe '.for_beginners' do
        it 'creates beginner-friendly configuration' do
          config = described_class::TutorialConfig.for_beginners

          expect(config.level).to eq(:beginner)
          expect(config.interactive).to be true
          expect(config.verbose).to be true
          expect(config.progress_tracking).to be true
          expect(config.property_testing).to be true
          expect(config.performance_testing).to be false
        end
      end

      describe '.for_advanced' do
        it 'creates advanced configuration' do
          config = described_class::TutorialConfig.for_advanced

          expect(config.level).to eq(:advanced)
          expect(config.interactive).to be false
          expect(config.verbose).to be false
          expect(config.progress_tracking).to be false
          expect(config.property_testing).to be false
          expect(config.performance_testing).to be true
        end
      end

      it 'supports Ruby version compatibility' do
        # Test that both Data and Struct versions work
        config = described_class::TutorialConfig.for_beginners

        expect(config).to respond_to(:level)
        expect(config).to respond_to(:interactive)
        expect(config).to respond_to(:verbose)
        expect(config).to respond_to(:progress_tracking)
        expect(config).to respond_to(:property_testing)
        expect(config).to respond_to(:performance_testing)
      end
    end

    describe '.run_tutorial' do
      let(:sample_config) { described_class::TutorialConfig.for_beginners }

      context 'with complete tutorial' do
        it 'runs complete tutorial walkthrough' do
          expect do
            described_class.run_tutorial(topic: :complete, config: sample_config)
          end.to output(/🎓.*Complete Data Science Pipeline/).to_stdout
        end

        it 'supports :all alias' do
          expect do
            described_class.run_tutorial(topic: :all, config: sample_config)
          end.to output(/🎓.*Complete Data Science Pipeline/).to_stdout
        end
      end

      context 'with outlier detection tutorial' do
        it 'runs outlier detection tutorial' do
          expect do
            described_class.run_tutorial(topic: :outlier_detection, config: sample_config)
          end.to output(/🎯.*Outlier Detection/).to_stdout
        end

        it 'supports :outliers alias' do
          expect do
            described_class.run_tutorial(topic: :outliers, config: sample_config)
          end.to output(/🎯.*Outlier Detection/).to_stdout
        end
      end

      context 'with normalization tutorial' do
        it 'runs normalization tutorial' do
          expect do
            described_class.run_tutorial(topic: :normalization, config: sample_config)
          end.to output(/⚖️.*Data Normalization/).to_stdout
        end

        it 'supports :scaling alias' do
          expect do
            described_class.run_tutorial(topic: :scaling, config: sample_config)
          end.to output(/⚖️.*Data Normalization/).to_stdout
        end
      end

      context 'with data quality tutorial' do
        it 'runs data quality tutorial' do
          expect do
            described_class.run_tutorial(topic: :data_quality, config: sample_config)
          end.to output(/📊.*Data Quality/).to_stdout
        end

        it 'supports :quality alias' do
          expect do
            described_class.run_tutorial(topic: :quality, config: sample_config)
          end.to output(/📊.*Data Quality/).to_stdout
        end
      end

      context 'with performance tutorial' do
        it 'runs performance tutorial' do
          expect do
            described_class.run_tutorial(topic: :performance, config: sample_config)
          end.to output(/⚡.*Performance/).to_stdout
        end

        it 'supports :benchmarks alias' do
          expect do
            described_class.run_tutorial(topic: :benchmarks, config: sample_config)
          end.to output(/⚡.*Performance/).to_stdout
        end
      end

      context 'with property testing tutorial' do
        it 'runs property testing tutorial' do
          expect do
            described_class.run_tutorial(topic: :property_testing, config: sample_config)
          end.to output(/🧪.*Property.*Testing/).to_stdout
        end

        it 'supports :properties alias' do
          expect do
            described_class.run_tutorial(topic: :properties, config: sample_config)
          end.to output(/🧪.*Property.*Testing/).to_stdout
        end
      end

      context 'with unknown topic' do
        it 'raises educational error with suggestions' do
          expect do
            described_class.run_tutorial(topic: :unknown_topic, config: sample_config)
          end.to raise_error(ArgumentError) do |error|
            expect(error.message).to include('Unknown tutorial topic: unknown_topic')
            expect(error.message).to include('complete')
            expect(error.message).to include('outlier_detection')
            expect(error.message).to include('normalization')
          end
        end
      end

      context 'with default configuration' do
        it 'uses beginner configuration by default' do
          expect do
            described_class.run_tutorial(topic: :outlier_detection)
          end.to output(/🎯.*Outlier Detection/).to_stdout
        end
      end
    end

    describe '.interactive_tutorial_selector' do
      it 'displays tutorial menu' do
        expect do
          # Mock gets input to avoid hanging
          allow(described_class).to receive(:gets).and_return("1\n")
          described_class.interactive_tutorial_selector
        end.to output(/🎓 AI4R Modern Educational Tutorial System/).to_stdout
      end

      it 'shows tutorial options with difficulty levels' do
        expect do
          allow(described_class).to receive(:gets).and_return("1\n")
          described_class.interactive_tutorial_selector
        end.to output(/Complete Data Science Pipeline.*🟢/).to_stdout
      end

      it 'displays duration estimates' do
        expect do
          allow(described_class).to receive(:gets).and_return("1\n")
          described_class.interactive_tutorial_selector
        end.to output(/Duration: 45 min/).to_stdout
      end

      it 'shows difficulty indicators' do
        expect do
          allow(described_class).to receive(:gets).and_return("1\n")
          described_class.interactive_tutorial_selector
        end.to output(/🟢.*🟡.*🔴/).to_stdout
      end
    end

    describe 'instance methods' do
      let(:config) { described_class::TutorialConfig.for_beginners }
      let(:examples) { described_class.new(config) }

      describe '#complete_tutorial_walkthrough' do
        it 'provides comprehensive data science walkthrough' do
          expect do
            examples.complete_tutorial_walkthrough
          end.to output(/🎓.*Complete Data Science Pipeline/).to_stdout
        end

        it 'covers all major topics' do
          expect do
            examples.complete_tutorial_walkthrough
          end.to output(/Data Loading.*Quality.*Outliers.*Normalization/).to_stdout
        end

        it 'shows progress tracking' do
          expect do
            examples.complete_tutorial_walkthrough
          end.to output(/📊 Progress:/).to_stdout
        end
      end

      describe '#outlier_detection_tutorial' do
        it 'teaches outlier detection concepts' do
          expect do
            examples.outlier_detection_tutorial
          end.to output(/🎯.*Outlier Detection/).to_stdout
        end

        it 'explains different methods' do
          expect do
            examples.outlier_detection_tutorial
          end.to output(/IQR.*Z-Score.*Modified Z-Score/).to_stdout
        end

        it 'provides hands-on examples' do
          expect do
            examples.outlier_detection_tutorial
          end.to output(/🧪.*Hands-on Example/).to_stdout
        end

        it 'demonstrates method comparison' do
          expect do
            examples.outlier_detection_tutorial
          end.to output(/📊.*Method Comparison/).to_stdout
        end
      end

      describe '#normalization_tutorial' do
        it 'teaches normalization concepts' do
          expect do
            examples.normalization_tutorial
          end.to output(/⚖️.*Data Normalization/).to_stdout
        end

        it 'explains different normalization methods' do
          expect do
            examples.normalization_tutorial
          end.to output(/Min-Max.*Z-Score.*Robust/).to_stdout
        end

        it 'shows before/after comparisons' do
          expect do
            examples.normalization_tutorial
          end.to output(/📊.*Before.*After/).to_stdout
        end

        it 'provides method selection guidance' do
          expect do
            examples.normalization_tutorial
          end.to output(/💡.*When to use/).to_stdout
        end
      end

      describe '#data_quality_tutorial' do
        it 'teaches data quality assessment' do
          expect do
            examples.data_quality_tutorial
          end.to output(/📊.*Data Quality/).to_stdout
        end

        it 'covers quality dimensions' do
          expect do
            examples.data_quality_tutorial
          end.to output(/Completeness.*Consistency.*Validity/).to_stdout
        end

        it 'provides quality scoring' do
          expect do
            examples.data_quality_tutorial
          end.to output(/Quality Score.*Grade/).to_stdout
        end

        it 'offers improvement recommendations' do
          expect do
            examples.data_quality_tutorial
          end.to output(/🔧.*Recommendations/).to_stdout
        end
      end

      describe '#performance_tutorial' do
        it 'teaches performance optimization' do
          expect do
            examples.performance_tutorial
          end.to output(/⚡.*Performance/).to_stdout
        end

        it 'demonstrates benchmarking' do
          expect do
            examples.performance_tutorial
          end.to output(/📊.*Benchmark/).to_stdout
        end

        it 'shows lazy evaluation' do
          expect do
            examples.performance_tutorial
          end.to output(/🔄.*Lazy Processing/).to_stdout
        end

        it 'demonstrates concurrent processing' do
          expect do
            examples.performance_tutorial
          end.to output(/🚀.*Concurrent/).to_stdout
        end
      end

      describe '#property_testing_tutorial' do
        it 'teaches property-based testing' do
          expect do
            examples.property_testing_tutorial
          end.to output(/🧪.*Property.*Testing/).to_stdout
        end

        it 'explains testing properties' do
          expect do
            examples.property_testing_tutorial
          end.to output(/Monotonicity.*Consistency.*Reversibility/).to_stdout
        end

        it 'demonstrates property validation' do
          expect do
            examples.property_testing_tutorial
          end.to output(/✅.*Property.*Test/).to_stdout
        end

        it 'shows failure analysis' do
          expect do
            examples.property_testing_tutorial
          end.to output(/🔍.*Analysis/).to_stdout
        end
      end

      describe 'interactive features' do
        context 'with interactive configuration' do
          let(:interactive_config) do
            described_class::TutorialConfig.for_beginners
          end
          let(:interactive_examples) { described_class.new(interactive_config) }

          it 'provides interactive prompts' do
            expect do
              # Mock user input
              allow(interactive_examples).to receive(:gets).and_return("1\n", "y\n")
              interactive_examples.outlier_detection_tutorial
            end.to output(/Press.*continue/).to_stdout
          end

          it 'waits for user input' do
            expect do
              allow(interactive_examples).to receive(:gets).and_return("1\n")
              interactive_examples.normalization_tutorial
            end.to output(/Choose.*method/).to_stdout
          end
        end
      end

      describe 'progress tracking' do
        it 'tracks tutorial progress' do
          expect do
            examples.complete_tutorial_walkthrough
          end.to output(/Progress:.*\d+%/).to_stdout
        end

        it 'shows step completion' do
          expect do
            examples.outlier_detection_tutorial
          end.to output(/✅.*Step.*completed/).to_stdout
        end

        it 'provides progress visualization' do
          expect do
            examples.data_quality_tutorial
          end.to output(/📊.*Progress.*Bar/).to_stdout
        end
      end

      describe 'educational validation' do
        it 'validates learning outcomes' do
          expect do
            examples.property_testing_tutorial
          end.to output(/🎯.*Learning.*Outcome/).to_stdout
        end

        it 'provides knowledge checks' do
          expect do
            examples.normalization_tutorial
          end.to output(/🧠.*Knowledge.*Check/).to_stdout
        end

        it 'offers remediation suggestions' do
          expect do
            examples.outlier_detection_tutorial
          end.to output(/💡.*Review.*Suggestion/).to_stdout
        end
      end
    end

    describe 'tutorial content quality' do
      let(:config) { described_class::TutorialConfig.for_beginners }
      let(:examples) { described_class.new(config) }

      it 'provides comprehensive explanations' do
        expect do
          examples.outlier_detection_tutorial
        end.to output(/Why.*important.*outliers/).to_stdout
      end

      it 'includes practical examples' do
        expect do
          examples.normalization_tutorial
        end.to output(/Example.*dataset/).to_stdout
      end

      it 'shows real-world applications' do
        expect do
          examples.data_quality_tutorial
        end.to output(/Real.*world.*scenario/).to_stdout
      end

      it 'provides best practices' do
        expect do
          examples.performance_tutorial
        end.to output(/Best.*practice/).to_stdout
      end

      it 'includes troubleshooting tips' do
        expect do
          examples.property_testing_tutorial
        end.to output(/Troubleshooting.*tip/).to_stdout
      end
    end

    describe 'educational scaffolding' do
      let(:beginner_config) { described_class::TutorialConfig.for_beginners }
      let(:advanced_config) { described_class::TutorialConfig.for_advanced }

      it 'provides different levels of detail' do
        beginner_output = capture_output { described_class.new(beginner_config).outlier_detection_tutorial }
        advanced_output = capture_output { described_class.new(advanced_config).outlier_detection_tutorial }

        expect(beginner_output.length).to be > advanced_output.length
      end

      it 'includes beginner-friendly explanations' do
        expect do
          described_class.new(beginner_config).normalization_tutorial
        end.to output(/Simple.*terms/).to_stdout
      end

      it 'provides advanced insights' do
        expect do
          described_class.new(advanced_config).performance_tutorial
        end.to output(/Advanced.*technique/).to_stdout
      end
    end

    describe 'error handling in tutorials' do
      it 'handles invalid inputs gracefully' do
        expect do
          # Mock invalid input followed by valid input
          allow_any_instance_of(described_class).to receive(:gets).and_return("invalid\n", "1\n")
          described_class.interactive_tutorial_selector
        end.to output(/Invalid.*choice/).to_stdout
      end

      it 'provides helpful error messages' do
        expect do
          allow_any_instance_of(described_class).to receive(:gets).and_return("99\n", "1\n")
          described_class.interactive_tutorial_selector
        end.to output(/Please.*choose.*1.*6/).to_stdout
      end
    end

    describe 'tutorial accessibility' do
      it 'uses clear, consistent formatting' do
        expect do
          described_class.new(described_class::TutorialConfig.for_beginners).outlier_detection_tutorial
        end.to output(/═.*─/).to_stdout
      end

      it 'provides visual indicators' do
        expect do
          described_class.new(described_class::TutorialConfig.for_beginners).normalization_tutorial
        end.to output(/🎯.*📊.*💡.*✅/).to_stdout
      end

      it 'structures content logically' do
        expect do
          described_class.new(described_class::TutorialConfig.for_beginners).data_quality_tutorial
        end.to output(/Introduction.*Theory.*Practice.*Summary/).to_stdout
      end
    end

    describe 'performance characteristics' do
      it 'loads tutorials efficiently' do
        benchmark_performance('Tutorial loading') do
          described_class.new(described_class::TutorialConfig.for_beginners)
        end
      end

      it 'renders content efficiently' do
        examples = described_class.new(described_class::TutorialConfig.for_beginners)

        benchmark_performance('Tutorial rendering') do
          capture_output { examples.outlier_detection_tutorial }
        end
      end
    end

    describe 'integration with other components' do
      it 'integrates with pattern matching' do
        expect(described_class).to include(Ai4r::Data::PatternMatchers)
      end

      it 'uses modern data structures' do
        config = described_class::TutorialConfig.for_beginners

        expect(config).to respond_to(:level)
        expect(config).to respond_to(:interactive)
        expect(config).to respond_to(:verbose)
      end

      it 'supports educational configurations' do
        examples = described_class.new(described_class::TutorialConfig.for_beginners)

        expect(examples.instance_variable_get(:@config)).to be_a(described_class::TutorialConfig)
      end
    end

    # Helper method to capture output
    def capture_output
      old_stdout = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end
end
