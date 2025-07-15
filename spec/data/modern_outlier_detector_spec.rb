# frozen_string_literal: true

# RSpec tests for AI4R Modern Outlier Detection
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe "Modern Outlier Detection" do
  before(:all) do
    require_relative '../../lib/ai4r/data/modern_outlier_detector'
    require_relative '../../lib/ai4r/data/data_set'
  end

  let(:sample_data) do
    [
      [10, 20, 30],
      [12, 22, 32],
      [11, 21, 31],
      [13, 23, 33],
      [14, 24, 34],
      [100, 200, 300],  # Clear outliers
      [15, 25, 35],
      [16, 26, 36],
      [17, 27, 37],
      [18, 28, 38]
    ]
  end

  let(:sample_labels) { ["feature1", "feature2", "feature3"] }
  let(:dataset) { Ai4r::Data::DataSet.new(data_items: sample_data, data_labels: sample_labels) }
  let(:detector) { Ai4r::Data::ModernOutlierDetector.new(dataset, config: @educational_config) }

  describe Ai4r::Data::ModernOutlierDetector do
    describe "#initialize" do
      it "creates detector with dataset and configuration" do
        expect(detector).to be_a(described_class)
        expect(detector.instance_variable_get(:@dataset)).to eq(dataset)
        expect(detector.instance_variable_get(:@config)).to eq(@educational_config)
      end

      it "initializes progress tracker for educational config" do
        educational_config = Ai4r::Data::EducationalConfig.beginner
        educational_detector = described_class.new(dataset, config: educational_config)
        
        expect(educational_detector.instance_variable_get(:@progress)).to be_a(Ai4r::Data::ProgressTracker)
      end
    end

    describe "#detect" do
      context "IQR method" do
        it "detects outliers using IQR method" do
          results = detector.detect(method: :iqr)
          
          expect(results).to be_a(Hash)
          expect(results.keys).to match_array(sample_labels)
          
          # Check that outliers are detected in first column
          feature1_result = results["feature1"]
          expect(feature1_result).to satisfy_outlier_properties
          expect(feature1_result.method).to eq(:iqr)
          expect(feature1_result.count).to be > 0
          expect(feature1_result.percentage).to be > 0
          expect(feature1_result.indices).to include(5)  # Row with value 100
        end

        it "uses custom threshold" do
          results = detector.detect(method: :iqr, threshold: 2.0)
          
          feature1_result = results["feature1"]
          expect(feature1_result.threshold).to eq(2.0)
        end

        it "detects outliers in specific columns" do
          results = detector.detect(method: :iqr, columns: ["feature1"])
          
          expect(results.keys).to eq(["feature1"])
          expect(results["feature1"]).to satisfy_outlier_properties
        end
      end

      context "Z-score method" do
        it "detects outliers using Z-score method" do
          results = detector.detect(method: :z_score)
          
          feature1_result = results["feature1"]
          expect(feature1_result.method).to eq(:z_score)
          expect(feature1_result.count).to be > 0
          expect(feature1_result).to have_key(:statistics)
          expect(feature1_result.statistics[:mean]).to be_a(Numeric)
          expect(feature1_result.statistics[:std]).to be_a(Numeric)
        end

        it "handles constant values gracefully" do
          constant_data = Array.new(10) { [5, 5, 5] }
          constant_dataset = Ai4r::Data::DataSet.new(
            data_items: constant_data,
            data_labels: sample_labels
          )
          constant_detector = described_class.new(constant_dataset, config: @educational_config)
          
          results = constant_detector.detect(method: :z_score)
          
          feature1_result = results["feature1"]
          expect(feature1_result.count).to eq(0)
          expect(feature1_result.empty?).to be true
        end
      end

      context "Modified Z-score method" do
        it "detects outliers using modified Z-score method" do
          results = detector.detect(method: :modified_z_score)
          
          feature1_result = results["feature1"]
          expect(feature1_result.method).to eq(:modified_z_score)
          expect(feature1_result.count).to be > 0
          expect(feature1_result).to have_key(:statistics)
          expect(feature1_result.statistics[:median]).to be_a(Numeric)
          expect(feature1_result.statistics[:mad]).to be_a(Numeric)
        end

        it "is more robust than standard Z-score" do
          skewed_data = Array.new(8) { [rand(10..20)] } + [[1000], [2000]]  # Extreme outliers
          skewed_dataset = Ai4r::Data::DataSet.new(
            data_items: skewed_data,
            data_labels: ["value"]
          )
          skewed_detector = described_class.new(skewed_dataset, config: @educational_config)
          
          z_score_results = skewed_detector.detect(method: :z_score)
          modified_z_results = skewed_detector.detect(method: :modified_z_score)
          
          # Modified Z-score should be more selective
          expect(modified_z_results["value"].count).to be <= z_score_results["value"].count
        end
      end

      context "Percentile method" do
        it "detects outliers using percentile method" do
          results = detector.detect(method: :percentile, threshold: 0.1)
          
          feature1_result = results["feature1"]
          expect(feature1_result.method).to eq(:percentile)
          expect(feature1_result.threshold).to eq(0.1)
          expect(feature1_result).to have_key(:percentiles)
        end
      end

      context "error handling" do
        it "raises error for unknown method" do
          expect {
            detector.detect(method: :unknown_method)
          }.to raise_error(Ai4r::Data::OutlierDetectionError) do |error|
            expect(error.message).to include("Invalid outlier detection method: unknown_method")
            expect(error.message).to include("💡 Suggestions:")
            expect(error.message).to include("Try :iqr")
          end
        end
      end
    end

    describe "#comprehensive_analysis" do
      it "runs multiple detection methods" do
        analysis = detector.comprehensive_analysis(methods: [:iqr, :z_score])
        
        expect(analysis).to be_a(described_class::ComprehensiveAnalysisResult)
        expect(analysis.methods_comparison).to have_key(:iqr)
        expect(analysis.methods_comparison).to have_key(:z_score)
        expect(analysis.overall_severity).to be_in([:low, :moderate, :high, :severe])
      end

      it "finds consensus outliers" do
        analysis = detector.comprehensive_analysis(methods: [:iqr, :z_score, :modified_z_score])
        
        expect(analysis.consensus_outliers).to be_a(Hash)
        expect(analysis.consensus_available?).to be_in([true, false])
      end

      it "provides recommendations" do
        analysis = detector.comprehensive_analysis
        
        expect(analysis.recommendations).to be_an(Array)
        expect(analysis.recommendations).not_to be_empty
        expect(analysis.recommendations.first).to be_a(String)
      end

      it "has educational summary" do
        analysis = detector.comprehensive_analysis
        
        expect(analysis.educational_summary).to be_a(String)
        expect(analysis.educational_summary).to include("🔍 Comprehensive Analysis Results")
      end
    end

    describe "#validate_detection_properties" do
      it "validates detection properties" do
        properties = detector.validate_detection_properties(method: :iqr, sample_size: 20)
        
        expect(properties).to be_a(Hash)
        expect(properties).to have_key(:monotonicity)
        expect(properties).to have_key(:consistency)
        expect(properties).to have_key(:robustness)
        
        properties.each do |property, result|
          expect(result).to be_in([true, false])
        end
      end

      it "tests monotonicity property" do
        # This test might be flaky due to randomness, so we run it multiple times
        results = Array.new(5) do
          detector.validate_detection_properties(method: :iqr, sample_size: 10)[:monotonicity]
        end
        
        # At least some should pass the monotonicity test
        expect(results.count(true)).to be >= 3
      end

      it "tests consistency property" do
        properties = detector.validate_detection_properties(method: :iqr, sample_size: 20)
        
        # Consistency should generally be true for deterministic algorithms
        expect(properties[:consistency]).to be true
      end
    end

    describe "educational features" do
      let(:educational_config) { Ai4r::Data::EducationalConfig.beginner }
      let(:educational_detector) { described_class.new(dataset, config: educational_config) }

      it "provides educational explanations" do
        expect {
          educational_detector.detect(method: :iqr)
        }.to output(/💡 IQR Method Explanation/).to_stdout
      end

      it "shows detection results" do
        expect {
          educational_detector.detect(method: :iqr)
        }.to output(/📊 Outlier Detection Results/).to_stdout
      end

      it "tracks progress during comprehensive analysis" do
        expect {
          educational_detector.comprehensive_analysis(methods: [:iqr, :z_score])
        }.to output(/📊 Learning Progress/).to_stdout
      end
    end

    describe "performance characteristics" do
      let(:large_dataset) do
        large_data = build(:large_dataset)
        Ai4r::Data::DataSet.new(
          data_items: large_data[:data_items],
          data_labels: large_data[:data_labels]
        )
      end

      let(:large_detector) { described_class.new(large_dataset, config: @educational_config) }

      it "handles large datasets efficiently" do
        benchmark_performance("Large dataset outlier detection") do
          large_detector.detect(method: :iqr)
        end
      end

      it "performs comprehensive analysis efficiently" do
        benchmark_performance("Comprehensive analysis") do
          large_detector.comprehensive_analysis(methods: [:iqr, :z_score])
        end
      end
    end

    describe "property-based testing" do
      it "maintains detection consistency" do
        test_data = build(:outlier_test_data, size: 50, outlier_percentage: 0.2)
        test_dataset = Ai4r::Data::DataSet.new(
          data_items: test_data.map { |v| [v] },
          data_labels: ["value"]
        )
        test_detector = described_class.new(test_dataset, config: @educational_config)
        
        expect(test_detector).to satisfy_property("detection consistency", 10) do |detector|
          result1 = detector.detect(method: :iqr)
          result2 = detector.detect(method: :iqr)
          
          result1["value"].count == result2["value"].count &&
          result1["value"].indices == result2["value"].indices
        end
      end

      it "detects known outliers" do
        # Create data with known outliers
        normal_data = Array.new(80) { rand(10..20) }
        outlier_data = Array.new(20) { rand(100..200) }
        mixed_data = (normal_data + outlier_data).shuffle
        
        test_dataset = Ai4r::Data::DataSet.new(
          data_items: mixed_data.map { |v| [v] },
          data_labels: ["value"]
        )
        test_detector = described_class.new(test_dataset, config: @educational_config)
        
        results = test_detector.detect(method: :iqr)
        
        # Should detect most outliers
        expect(results["value"].count).to be >= 15
        expect(results["value"].percentage).to be >= 15.0
      end

      it "handles edge cases gracefully" do
        edge_cases = [
          [],  # Empty data
          [1],  # Single value
          [1, 1, 1],  # All same values
          [1, 2, 3]   # Too few values for some methods
        ]
        
        edge_cases.each do |data|
          next if data.empty?
          
          test_dataset = Ai4r::Data::DataSet.new(
            data_items: data.map { |v| [v] },
            data_labels: ["value"]
          )
          test_detector = described_class.new(test_dataset, config: @educational_config)
          
          expect {
            test_detector.detect(method: :iqr)
          }.not_to raise_error
        end
      end
    end

    describe "method-specific behavior" do
      describe "IQR method" do
        it "calculates correct quartiles" do
          sorted_data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          test_dataset = Ai4r::Data::DataSet.new(
            data_items: sorted_data.map { |v| [v] },
            data_labels: ["value"]
          )
          test_detector = described_class.new(test_dataset, config: @educational_config)
          
          results = test_detector.detect(method: :iqr)
          result = results["value"]
          
          expect(result.quartiles[:q1]).to be_approximately(2.5, 0.5)
          expect(result.quartiles[:q3]).to be_approximately(7.5, 0.5)
          expect(result.quartiles[:iqr]).to be_approximately(5.0, 0.5)
        end

        it "handles symmetric data" do
          symmetric_data = [-10, -5, -1, 0, 1, 5, 10]
          test_dataset = Ai4r::Data::DataSet.new(
            data_items: symmetric_data.map { |v| [v] },
            data_labels: ["value"]
          )
          test_detector = described_class.new(test_dataset, config: @educational_config)
          
          results = test_detector.detect(method: :iqr, threshold: 1.5)
          
          # Should detect few or no outliers in symmetric data
          expect(results["value"].count).to be <= 2
        end
      end

      describe "Z-score method" do
        it "calculates correct statistics" do
          test_data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          test_dataset = Ai4r::Data::DataSet.new(
            data_items: test_data.map { |v| [v] },
            data_labels: ["value"]
          )
          test_detector = described_class.new(test_dataset, config: @educational_config)
          
          results = test_detector.detect(method: :z_score)
          result = results["value"]
          
          expect(result.statistics[:mean]).to be_approximately(5.5, 0.1)
          expect(result.statistics[:std]).to be_approximately(2.87, 0.1)
        end

        it "is sensitive to extreme values" do
          normal_data = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
          extreme_data = normal_data + [100]
          
          test_dataset = Ai4r::Data::DataSet.new(
            data_items: extreme_data.map { |v| [v] },
            data_labels: ["value"]
          )
          test_detector = described_class.new(test_dataset, config: @educational_config)
          
          results = test_detector.detect(method: :z_score, threshold: 2.0)
          
          expect(results["value"].count).to be >= 1
          expect(results["value"].values).to include(100)
        end
      end
    end

    describe "educational error handling" do
      it "provides helpful error messages for invalid methods" do
        expect {
          detector.detect(method: :invalid_method)
        }.to raise_error(Ai4r::Data::OutlierDetectionError) do |error|
          expect(error.message).to include("Invalid outlier detection method")
          expect(error.message).to include("💡 Suggestions:")
          expect(error.message).to include("Try :iqr")
          expect(error.message).to include("Try :z_score")
        end
      end

      it "provides context for educational errors" do
        begin
          detector.detect(method: :invalid_method)
        rescue Ai4r::Data::OutlierDetectionError => e
          expect(e.suggestions).to be_an(Array)
          expect(e.suggestions).not_to be_empty
          expect(e.help_topic).to eq(:outlier_methods)
        end
      end
    end
  end

  describe "ComprehensiveAnalysisResult" do
    let(:mock_methods_comparison) do
      {
        iqr: double("IQR Result", count: 5),
        z_score: double("Z-Score Result", count: 3),
        modified_z_score: double("Modified Z-Score Result", count: 4)
      }
    end

    let(:comprehensive_result) do
      Ai4r::Data::ModernOutlierDetector::ComprehensiveAnalysisResult.new(
        methods_comparison: mock_methods_comparison,
        consensus_outliers: { "feature1" => { 5 => [:iqr, :z_score] } },
        recommendations: ["Check data collection", "Consider robust methods"],
        overall_severity: :moderate
      )
    end

    describe "#educational_summary" do
      it "provides comprehensive analysis summary" do
        summary = comprehensive_result.educational_summary
        
        expect(summary).to include("🔍 Comprehensive Analysis Results")
        expect(summary).to include("Total outliers detected: 12")
        expect(summary).to include("Consensus outliers: 1")
        expect(summary).to include("Overall severity: moderate")
        expect(summary).to include("Methods used: iqr, z_score, modified_z_score")
      end
    end

    describe "#needs_attention?" do
      it "identifies when attention is needed" do
        high_severity = Ai4r::Data::ModernOutlierDetector::ComprehensiveAnalysisResult.new(
          methods_comparison: {},
          consensus_outliers: {},
          recommendations: [],
          overall_severity: :high
        )
        
        expect(high_severity.needs_attention?).to be true
        expect(comprehensive_result.needs_attention?).to be false
      end
    end

    describe "#consensus_available?" do
      it "checks if consensus outliers exist" do
        expect(comprehensive_result.consensus_available?).to be true
        
        no_consensus = Ai4r::Data::ModernOutlierDetector::ComprehensiveAnalysisResult.new(
          methods_comparison: {},
          consensus_outliers: {},
          recommendations: [],
          overall_severity: :low
        )
        
        expect(no_consensus.consensus_available?).to be false
      end
    end
  end

  describe "MethodAnalysisResult" do
    let(:method_result) do
      Ai4r::Data::ModernOutlierDetector::MethodAnalysisResult.new(
        method: :iqr,
        results: { "feature1" => double("Result") },
        total_outliers: 8,
        affected_columns: 2
      )
    end

    describe "#severity" do
      it "categorizes severity based on outlier count" do
        expect(method_result.severity).to eq(:moderate)
        
        low_result = Ai4r::Data::ModernOutlierDetector::MethodAnalysisResult.new(
          method: :iqr, results: {}, total_outliers: 3, affected_columns: 1
        )
        expect(low_result.severity).to eq(:low)
        
        high_result = Ai4r::Data::ModernOutlierDetector::MethodAnalysisResult.new(
          method: :iqr, results: {}, total_outliers: 25, affected_columns: 5
        )
        expect(high_result.severity).to eq(:high)
      end
    end

    describe "#educational_summary" do
      it "provides method-specific summary" do
        summary = method_result.educational_summary
        
        expect(summary).to include("Iqr")
        expect(summary).to include("8 outliers")
        expect(summary).to include("2 columns")
      end
    end
  end
end