# frozen_string_literal: true

# Enhanced DataSet implementation for comprehensive data science education
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'data_set'
require_relative 'statistics'
require_relative 'proximity'

module Ai4r
  module Data
    # Enhanced DataSet with comprehensive data science education features
    #
    # This implementation provides a complete learning environment for data science
    # concepts, including interactive tutorials, modern data manipulation,
    # comprehensive EDA framework, and real-world data challenges.
    #
    # Educational Features:
    # - Interactive step-by-step learning modules
    # - Complete exploratory data analysis framework
    # - Modern data manipulation operations
    # - Real-world data quality challenges
    # - Comprehensive visualization and reporting
    #
    # = Usage
    #   dataset = EnhancedDataSet.new
    #   dataset.enable_interactive_mode
    #   dataset.load_csv_with_tutorial("data.csv")
    #   dataset.explore_data_interactively
    class EnhancedDataSet < DataSet
      attr_reader :metadata, :quality_report, :transformation_log, :analysis_history, :interactive_mode,
                  :learning_level, :visualization_engine

      def initialize(options = {})
        super

        # Educational configuration
        @interactive_mode = options.fetch(:interactive_mode, false)
        @learning_level = options.fetch(:learning_level, :beginner)
        @verbose_explanations = options.fetch(:verbose_explanations, true)
        @step_by_step = options.fetch(:step_by_step, false)

        # Analysis tracking
        @metadata = EnhancedMetadata.new
        @quality_report = DataQualityAssessment.new
        @transformation_log = TransformationLog.new
        @analysis_history = AnalysisHistory.new
        @performance_monitor = PerformanceMonitor.new

        # Visualization and reporting
        @visualization_engine = VisualizationEngine.new(self)
        @report_generator = ReportGenerator.new(self)

        # Data manipulation engine
        @data_engine = DataManipulationEngine.new(self)

        # Learning modules
        @tutorial_manager = TutorialManager.new(self)

        analyze_initial_data unless @data_items.empty?
      end

      # Enable interactive learning mode with guided tutorials
      def enable_interactive_mode(level: :beginner)
        @interactive_mode = true
        @learning_level = level
        @verbose_explanations = true
        @step_by_step = true

        puts "\n🎓 Interactive Data Science Learning Mode Activated!"
        puts "Learning Level: #{level.to_s.capitalize}"
        puts "Type 'help()' anytime for available commands and explanations."
        puts "Use 'tutorial()' to start guided learning modules."

        self
      end

      # Load CSV with interactive tutorial
      def load_csv_with_tutorial(filepath, encoding: 'utf-8')
        if @interactive_mode
          puts "\n=== Loading Data with Tutorial ==="
          puts "📁 Loading file: #{filepath}"

          explain_csv_loading_concepts if @learning_level == :beginner

          wait_for_user('Press Enter to load the data...') if @step_by_step
        end

        # Performance monitoring
        load_time = @performance_monitor.time_operation do
          load_csv_with_labels(filepath)
        end

        # Immediate analysis
        analyze_initial_data

        if @interactive_mode
          puts '✅ Data loaded successfully!'
          puts "⏱️  Load time: #{load_time.round(3)} seconds"
          puts "📊 Dataset shape: #{shape}"

          if @step_by_step
            puts "\nWould you like to explore the data? (y/n)"
            response = gets.chomp.downcase
            explore_data_interactively if %w[y yes].include?(response)
          end
        end

        self
      end

      # Interactive data exploration framework
      def explore_data_interactively
        return explore_data_basic unless @interactive_mode

        puts "\n🔍 Interactive Data Exploration Started"
        puts 'Available exploration options:'
        puts '1. Basic Info (shape, types, memory usage)'
        puts '2. Data Quality Assessment (missing values, duplicates, outliers)'
        puts '3. Statistical Summary (distributions, correlations)'
        puts '4. Visual Exploration (charts, plots)'
        puts '5. Advanced Analysis (patterns, anomalies)'
        puts '6. Complete EDA Report'
        puts '0. Exit exploration'

        loop do
          puts "\nSelect exploration option (0-6): "
          choice = gets.chomp.to_i

          case choice
          when 1
            show_basic_info_interactive
          when 2
            assess_data_quality_interactive
          when 3
            show_statistical_summary_interactive
          when 4
            visual_exploration_interactive
          when 5
            advanced_analysis_interactive
          when 6
            generate_complete_eda_report
          when 0
            puts '👋 Exploration complete!'
            break
          else
            puts '❌ Invalid option. Please select 0-6.'
          end
        end

        self
      end

      # Advanced data manipulation with educational explanations
      def query(conditions = {})
        explain_querying_concepts if @interactive_mode && @verbose_explanations

        result = @data_engine.query(@data_items, conditions)

        # Log the operation
        @transformation_log.record_operation(
          operation: :query,
          parameters: conditions,
          input_shape: shape,
          output_shape: [result.length, result.first&.length || 0]
        )

        # Return new EnhancedDataSet with filtered data
        EnhancedDataSet.new(
          data_items: result,
          data_labels: @data_labels,
          interactive_mode: @interactive_mode,
          learning_level: @learning_level
        )
      end

      # Group-by operations with educational context
      def group_by(column, &block)
        explain_groupby_concepts if @interactive_mode && @verbose_explanations

        column_index = get_index(column)
        grouped_data = @data_engine.group_by(@data_items, column_index, &block)

        @transformation_log.record_operation(
          operation: :group_by,
          parameters: { column: column },
          input_shape: shape,
          result_groups: grouped_data.keys.length
        )

        grouped_data
      end

      # Pivot table creation with tutorial
      def pivot_table(index_col, value_col, aggfunc: :mean)
        explain_pivot_concepts if @interactive_mode && @verbose_explanations

        result = @data_engine.create_pivot_table(@data_items, index_col, value_col, aggfunc)

        @transformation_log.record_operation(
          operation: :pivot_table,
          parameters: { index: index_col, values: value_col, aggfunc: aggfunc }
        )

        result
      end

      # Advanced data cleaning with interactive guidance
      def clean_data_interactive
        puts "\n🧹 Interactive Data Cleaning Session"

        # Assess current data quality
        quality_issues = @quality_report.comprehensive_assessment(@data_items, @data_labels)

        if quality_issues.empty?
          puts '✅ Great! No major data quality issues detected.'
          return self
        end

        puts '🔍 Data quality issues found:'
        quality_issues.each_with_index do |issue, idx|
          puts "#{idx + 1}. #{issue[:description]} (Severity: #{issue[:severity]})"
        end

        puts "\nWould you like to clean these issues? (y/n)"
        return self unless gets.chomp.downcase.start_with?('y')

        quality_issues.each do |issue|
          handle_quality_issue_interactive(issue)
        end

        puts '✨ Data cleaning complete!'
        analyze_data_after_cleaning
        self
      end

      # Feature engineering with educational guidance
      def engineer_features_interactive(target_column: nil)
        puts "\n⚗️  Interactive Feature Engineering Session"

        explain_feature_engineering_concepts if @learning_level == :beginner

        feature_engineer = FeatureEngineeringEngine.new(self)

        # Analyze current features
        feature_analysis = feature_engineer.analyze_features(@data_items, @data_labels, target_column)

        puts "\n📊 Current Feature Analysis:"
        feature_analysis.each do |feature, analysis|
          puts "  #{feature}: #{analysis[:type]} (#{analysis[:info]})"
        end

        # Suggest feature engineering techniques
        suggestions = feature_engineer.suggest_techniques(feature_analysis, target_column)

        if suggestions.any?
          puts "\n💡 Suggested feature engineering techniques:"
          suggestions.each_with_index do |suggestion, idx|
            puts "#{idx + 1}. #{suggestion[:name]}: #{suggestion[:description]}"
            puts "   Expected benefit: #{suggestion[:benefit]}"
          end

          apply_feature_suggestions_interactive(suggestions, feature_engineer)
        else
          puts 'ℹ️  No specific feature engineering suggestions at this time.'
        end

        self
      end

      # Model-ready data preparation
      def prepare_for_ml(target_column: nil, test_size: 0.2)
        puts "\n🤖 Preparing Data for Machine Learning"

        explain_ml_preparation_concepts if @interactive_mode && @learning_level == :beginner

        # Comprehensive preparation pipeline
        ml_preparer = MLDataPreparer.new(self)
        prepared_data = ml_preparer.prepare(
          data_items: @data_items,
          data_labels: @data_labels,
          target_column: target_column,
          test_size: test_size,
          interactive: @interactive_mode
        )

        @transformation_log.record_operation(
          operation: :ml_preparation,
          parameters: { target: target_column, test_size: test_size }
        )

        prepared_data
      end

      # Advanced visualization with educational context
      def visualize_advanced(chart_type: :auto, columns: nil, **options)
        explain_visualization_concepts(chart_type) if @interactive_mode && @verbose_explanations

        @visualization_engine.create_advanced_chart(
          chart_type: chart_type,
          columns: columns,
          options: options
        )

        @analysis_history.record_visualization(chart_type, columns, options)
        self
      end

      # Performance benchmarking and optimization
      def benchmark_operations
        puts "\n⚡ Performance Benchmarking"

        benchmark_results = @performance_monitor.benchmark_common_operations(self)

        puts "\nOperation Performance Results:"
        benchmark_results.each do |operation, timing|
          puts "  #{operation}: #{timing[:mean].round(4)}s ± #{timing[:std].round(4)}s"

          puts '    ⚠️  Performance warning: Consider optimization' if timing[:mean] > timing[:threshold]
        end

        # Suggest optimizations
        suggestions = @performance_monitor.suggest_optimizations(benchmark_results, self)

        if suggestions.any?
          puts "\n🔧 Optimization suggestions:"
          suggestions.each { |suggestion| puts "  • #{suggestion}" }
        end

        benchmark_results
      end

      # Export analysis notebook
      def export_analysis_notebook(filename)
        puts "\n📓 Generating Analysis Notebook"

        notebook_content = @report_generator.generate_notebook(
          transformation_log: @transformation_log,
          analysis_history: @analysis_history,
          quality_report: @quality_report,
          metadata: @metadata
        )

        File.write(filename, notebook_content)
        puts "✅ Notebook exported to #{filename}"

        self
      end

      # Tutorial system access
      def tutorial(module_name = nil)
        @tutorial_manager.start_tutorial(module_name)
      end

      # Help system
      def help(topic = nil)
        help_system = HelpSystem.new(self)
        help_system.show_help(topic)
      end

      # Get dataset shape with explanation
      def shape
        dimensions = [@data_items.length, @data_items.first&.length || 0]

        if @interactive_mode && @verbose_explanations
          puts "📐 Dataset shape: #{dimensions} (rows, columns)"
          puts "   This means #{dimensions[0]} examples with #{dimensions[1]} features each"
        end

        dimensions
      end

      # Enhanced data types with educational explanations
      def dtypes
        types = @metadata.detailed_type_analysis(@data_items, @data_labels)

        if @interactive_mode
          puts "\n📋 Data Types Analysis:"
          types.each do |column, type_info|
            puts "  #{column}: #{type_info[:detected_type]} (#{type_info[:confidence]}% confidence)"
            puts "    #{type_info[:recommendation]}" if type_info[:recommendation]
          end
        end

        types
      end

      # Memory usage analysis
      def memory_usage
        usage = @performance_monitor.calculate_memory_usage(@data_items, @data_labels)

        if @interactive_mode
          puts "\n💾 Memory Usage Analysis:"
          puts "  Total size: #{usage[:total_mb]} MB"
          puts '  Per column:'
          usage[:by_column].each do |column, size|
            puts "    #{column}: #{size} MB"
          end

          puts '  ⚠️  Large dataset detected. Consider optimization techniques.' if usage[:total_mb] > 100
        end

        usage
      end

      private

      def analyze_initial_data
        @metadata.comprehensive_analysis(@data_items, @data_labels)
        @quality_report.assess(@data_items, @data_labels)
        @performance_monitor.baseline_performance(@data_items)
      end

      def explain_csv_loading_concepts
        puts "\n📚 CSV Loading Concepts:"
        puts '• CSV (Comma-Separated Values) is a simple file format for tabular data'
        puts '• Each row represents a record, columns represent features/attributes'
        puts '• First row often contains column headers (field names)'
        puts '• Data types are inferred automatically from content'
        puts '• Encoding (UTF-8) ensures proper character handling'
      end

      def explore_data_basic
        puts "\n📊 Basic Data Exploration:"
        puts "Shape: #{shape}"
        puts "Columns: #{@data_labels.inspect}"
        puts "Data types: #{dtypes.map { |col, type| "#{col}: #{type[:detected_type]}" }}"
      end

      def show_basic_info_interactive
        puts "\n📋 Dataset Basic Information"
        puts '=' * 50

        shape_info = shape
        memory_info = memory_usage

        puts "\n🔍 Quick insights:"
        puts "• Dataset size: #{format_data_size(shape_info)}"
        puts "• Memory usage: #{memory_info[:total_mb]} MB"
        puts "• Data density: #{calculate_data_density}%"

        explain_basic_info_concepts if @learning_level == :beginner

        wait_for_user if @step_by_step
      end

      def assess_data_quality_interactive
        puts "\n🔍 Data Quality Assessment"
        puts '=' * 50

        quality_assessment = @quality_report.comprehensive_assessment(@data_items, @data_labels)

        if quality_assessment.empty?
          puts '✅ Excellent! No data quality issues detected.'
        else
          puts "Found #{quality_assessment.length} potential issues:"
          quality_assessment.each_with_index do |issue, idx|
            puts "\n#{idx + 1}. #{issue[:title]}"
            puts "   Severity: #{issue[:severity]}"
            puts "   Description: #{issue[:description]}"
            puts "   Recommendation: #{issue[:recommendation]}"
          end
        end

        wait_for_user if @step_by_step
      end

      def show_statistical_summary_interactive
        puts "\n📈 Statistical Summary"
        puts '=' * 50

        # Numeric columns summary
        numeric_summary = calculate_numeric_summary
        categorical_summary = calculate_categorical_summary

        if numeric_summary.any?
          puts "\nNumeric Columns:"
          display_numeric_summary(numeric_summary)
        end

        if categorical_summary.any?
          puts "\nCategorical Columns:"
          display_categorical_summary(categorical_summary)
        end

        # Correlation analysis
        if numeric_summary.length > 1
          puts "\n🔗 Correlation Analysis:"
          show_correlation_insights
        end

        wait_for_user if @step_by_step
      end

      def visual_exploration_interactive
        puts "\n📊 Visual Data Exploration"
        puts '=' * 50

        puts 'Available visualizations:'
        puts '1. Histograms (distribution analysis)'
        puts '2. Box plots (outlier detection)'
        puts '3. Scatter plots (relationship analysis)'
        puts '4. Correlation heatmap'
        puts '5. Custom visualization'

        puts "\nSelect visualization type (1-5): "
        choice = gets.chomp.to_i

        case choice
        when 1
          create_histograms_interactive
        when 2
          create_boxplots_interactive
        when 3
          create_scatterplots_interactive
        when 4
          create_correlation_heatmap
        when 5
          create_custom_visualization_interactive
        end
      end

      def advanced_analysis_interactive
        puts "\n🔬 Advanced Data Analysis"
        puts '=' * 50

        puts 'Advanced analysis options:'
        puts '1. Outlier detection and analysis'
        puts '2. Feature importance analysis'
        puts '3. Data distribution analysis'
        puts '4. Time series analysis (if applicable)'
        puts '5. Clustering analysis'

        puts "\nSelect analysis type (1-5): "
        choice = gets.chomp.to_i

        case choice
        when 1
          perform_outlier_analysis
        when 2
          perform_feature_importance_analysis
        when 3
          perform_distribution_analysis
        when 4
          perform_time_series_analysis
        when 5
          perform_clustering_analysis
        end
      end

      def generate_complete_eda_report
        puts "\n📋 Generating Complete EDA Report"
        puts '=' * 50

        report = @report_generator.generate_complete_eda(
          data_items: @data_items,
          data_labels: @data_labels,
          metadata: @metadata,
          quality_report: @quality_report
        )

        puts report

        puts "\nWould you like to export this report? (y/n)"
        return unless gets.chomp.downcase.start_with?('y')

        filename = "eda_report_#{Time.now.strftime('%Y%m%d_%H%M%S')}.md"
        File.write(filename, report)
        puts "📄 Report exported to #{filename}"
      end

      def explain_querying_concepts
        puts "\n📚 Data Querying Concepts:"
        puts '• Filtering allows you to select specific rows based on conditions'
        puts '• Conditions can be simple (column == value) or complex (multiple criteria)'
        puts '• Efficient querying is essential for large datasets'
        puts '• Always validate results to ensure correct filtering'
      end

      def explain_groupby_concepts
        puts "\n📚 Group-By Operations:"
        puts '• Group-by splits data into groups based on column values'
        puts '• Common aggregations: sum, mean, count, min, max'
        puts '• Useful for summarizing data and finding patterns'
        puts '• Foundation for many analytical operations'
      end

      def explain_pivot_concepts
        puts "\n📚 Pivot Table Concepts:"
        puts '• Pivot tables reorganize data for better analysis'
        puts '• Rows become columns (and vice versa) based on unique values'
        puts '• Aggregation functions summarize grouped data'
        puts '• Excellent for cross-tabulation and summary analysis'
      end

      def explain_feature_engineering_concepts
        puts "\n📚 Feature Engineering Fundamentals:"
        puts '• Feature engineering creates new variables from existing data'
        puts '• Goal: Improve model performance and interpretability'
        puts '• Common techniques: polynomial features, interactions, transformations'
        puts '• Domain knowledge is crucial for effective feature engineering'
        puts '• Always validate that new features add predictive value'
      end

      def explain_ml_preparation_concepts
        puts "\n📚 ML Data Preparation:"
        puts '• Machine learning requires carefully prepared data'
        puts '• Steps: cleaning, encoding, scaling, splitting'
        puts '• Training set: Used to train the model'
        puts '• Test set: Used to evaluate model performance'
        puts '• Validation set: Used for model selection and tuning'
      end

      def explain_visualization_concepts(chart_type)
        explanations = {
          histogram: 'Shows data distribution and frequency patterns',
          boxplot: 'Reveals outliers, quartiles, and data spread',
          scatter: 'Displays relationships between two variables',
          heatmap: 'Visualizes correlation patterns in data',
          bar: 'Compares categorical data values'
        }

        puts "\n📚 #{chart_type.to_s.capitalize} Visualization:"
        puts "• #{explanations[chart_type] || 'Provides insights into data patterns'}"
      end

      def wait_for_user(message = 'Press Enter to continue...')
        return unless @step_by_step

        puts message
        gets
      end

      def format_data_size(shape)
        rows, cols = shape
        if rows < 1000
          "#{rows} rows × #{cols} columns (Small)"
        elsif rows < 100_000
          "#{rows} rows × #{cols} columns (Medium)"
        else
          "#{rows} rows × #{cols} columns (Large)"
        end
      end

      def calculate_data_density
        total_cells = @data_items.length * (@data_items.first&.length || 0)
        return 0 if total_cells == 0

        non_null_cells = @data_items.sum do |row|
          row.count { |cell| !cell.nil? && cell != '' }
        end

        (non_null_cells.to_f / total_cells * 100).round(1)
      end

      # Additional helper methods would continue here...
      # This is a comprehensive foundation for the enhanced data handling system
    end

    # Enhanced metadata analysis with comprehensive type detection
    class EnhancedMetadata
      attr_reader :column_profiles, :data_relationships, :quality_metrics

      def initialize
        @column_profiles = {}
        @data_relationships = {}
        @quality_metrics = {}
      end

      def comprehensive_analysis(data_items, data_labels)
        return if data_items.empty?

        data_labels.each_with_index do |label, index|
          @column_profiles[label] = analyze_column(data_items, index)
        end

        @data_relationships = analyze_relationships(data_items, data_labels)
        @quality_metrics = calculate_quality_metrics(data_items, data_labels)
      end

      def detailed_type_analysis(data_items, data_labels)
        type_analyzer = TypeDetectionEngine.new
        type_analyzer.analyze_all_columns(data_items, data_labels)
      end

      private

      def analyze_column(data_items, index)
        values = data_items.filter_map { |row| row[index] }

        {
          type: detect_enhanced_type(values),
          unique_count: values.uniq.length,
          null_count: data_items.length - values.length,
          sample_values: values.first(5),
          statistics: calculate_column_statistics(values)
        }
      end

      def detect_enhanced_type(values)
        return :empty if values.empty?

        # Enhanced type detection logic
        TypeDetectionEngine.new.detect_type(values)
      end

      def analyze_relationships(data_items, data_labels)
        # Analyze correlations, dependencies, and patterns
        RelationshipAnalyzer.new.analyze(data_items, data_labels)
      end

      def calculate_quality_metrics(data_items, data_labels)
        # Calculate comprehensive quality metrics
        QualityMetricsCalculator.new.calculate(data_items, data_labels)
      end

      def calculate_column_statistics(values)
        return {} if values.empty?

        if values.first.is_a?(Numeric)
          {
            mean: values.sum.to_f / values.length,
            median: calculate_median(values),
            std: calculate_standard_deviation(values),
            min: values.min,
            max: values.max
          }
        else
          {
            mode: values.group_by(&:itself).max_by { |_k, v| v.length }&.first,
            unique_ratio: values.uniq.length.to_f / values.length
          }
        end
      end

      def calculate_median(values)
        sorted = values.sort
        mid = sorted.length / 2
        sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
      end

      def calculate_standard_deviation(values)
        return 0.0 if values.length <= 1

        mean = values.sum.to_f / values.length
        variance = values.sum { |v| (v - mean)**2 } / (values.length - 1)
        Math.sqrt(variance)
      end
    end

    # Additional supporting classes would be implemented here...
    # This provides the foundation for a comprehensive educational data handling system
  end
end
