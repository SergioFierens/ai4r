# frozen_string_literal: true

# RSpec configuration for AI4R educational framework
# This file is loaded by default when running RSpec tests
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/test/'
  add_group 'Data Handling', 'lib/ai4r/data'
  add_group 'Classifiers', 'lib/ai4r/classifiers'
  add_group 'Clusterers', 'lib/ai4r/clusterers'
  add_group 'Neural Networks', 'lib/ai4r/neural_network'
  add_group 'Genetic Algorithms', 'lib/ai4r/genetic_algorithm'
  add_group 'SOM', 'lib/ai4r/som'
end

require 'pry'
require 'faker'
require 'factory_bot'
require 'benchmark/ips'
require 'rspec/collection_matchers'

# Load AI4R library
require_relative '../lib/ai4r'

# Load factory definitions
require_relative 'factories'

# Configure RSpec
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  
  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!
  
  # Enable expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  
  # Configure factory bot
  config.include FactoryBot::Syntax::Methods
  
  # Configure shared examples and helpers
  config.shared_context_metadata_behavior = :apply_to_host_groups
  
  # Filter out backtrace from gems
  config.filter_gems_from_backtrace 'factory_bot', 'faker'
  
  # Run specs in random order
  config.order = :random
  
  # Seed random number generator
  Kernel.srand config.seed
  
  # Configure educational testing features
  config.before(:suite) do
    puts "\n🎓 AI4R Educational Testing Framework"
    puts "=" * 50
  end
  
  config.after(:suite) do
    puts "\n✅ Educational Testing Complete!"
    puts "=" * 50
  end
  
  # Add custom matchers for educational testing
  config.before(:each) do
    # Set up educational configuration for consistent testing
    @educational_config = if defined?(Ai4r::Data::EducationalConfig)
      Ai4r::Data::EducationalConfig.advanced
    else
      # Fallback configuration
      {
        verbose: false,
        explain_operations: false,
        show_warnings: false,
        interactive_mode: false,
        learning_level: :advanced,
        step_by_step: false,
        show_progress: false
      }
    end
  end
  
  # Custom helper methods for educational testing
  config.include Module.new {
    # Helper for approximate equality testing
    def be_approximately(expected, delta = 0.01)
      be_within(delta).of(expected)
    end
    
    # Helper for nested array approximate equality
    def match_nested_arrays_approximately(expected, delta = 0.01)
      expected.each_with_index do |row, i|
        row.each_with_index do |value, j|
          if value.is_a?(Numeric)
            expect(subject[i][j]).to be_approximately(value, delta)
          else
            expect(subject[i][j]).to eq(value)
          end
        end
      end
    end
    
    # Helper for educational result validation
    def have_educational_properties
      satisfy do |result|
        result.respond_to?(:educational_summary) &&
        result.educational_summary.is_a?(String) &&
        result.educational_summary.length > 0
      end
    end
    
    # Helper for performance benchmarking
    def benchmark_performance(description, &block)
      puts "\n📊 Performance Benchmark: #{description}"
      Benchmark.ips do |x|
        x.config(time: 1, warmup: 0.2)
        x.report(description, &block)
      end
    end
    
    # Helper for property-based testing
    def satisfy_property(property_name, iterations = 100, &block)
      satisfy do |subject|
        results = []
        iterations.times do
          results << block.call(subject)
        end
        
        success_rate = results.count(true).to_f / iterations
        puts "  🧪 Property '#{property_name}': #{(success_rate * 100).round(1)}% success rate"
        
        success_rate >= 0.95  # 95% success rate required
      end
    end
    
    # Helper for generating test data
    def generate_test_data(size, type = :numeric)
      case type
      when :numeric
        Array.new(size) { rand(-100.0..100.0) }
      when :categorical
        categories = ['A', 'B', 'C', 'D']
        Array.new(size) { categories.sample }
      when :mixed
        Array.new(size) { |i| i.even? ? rand(-100.0..100.0) : ['A', 'B', 'C'].sample }
      when :outlier_prone
        normal_data = Array.new(size * 0.8) { rand(-10.0..10.0) }
        outlier_data = Array.new(size * 0.2) { rand > 0.5 ? rand(50.0..100.0) : rand(-100.0..-50.0) }
        (normal_data + outlier_data).shuffle
      end
    end
    
    # Helper for educational dataset creation
    def create_educational_dataset(rows = 10, columns = 3)
      data_items = Array.new(rows) do
        Array.new(columns) { rand(1..100) }
      end
      
      labels = Array.new(columns) { |i| "feature_#{i + 1}" }
      
      if defined?(Ai4r::Data::DataSet)
        Ai4r::Data::DataSet.new(data_items: data_items, data_labels: labels)
      else
        { data_items: data_items, data_labels: labels }
      end
    end
  }
end

# Custom matchers for educational testing
RSpec::Matchers.define :have_valid_educational_structure do
  match do |actual|
    actual.respond_to?(:educational_summary) &&
    actual.respond_to?(:count) &&
    actual.respond_to?(:percentage) &&
    actual.educational_summary.is_a?(String)
  end
  
  failure_message do |actual|
    "Expected #{actual} to have valid educational structure with educational_summary, count, and percentage methods"
  end
end

RSpec::Matchers.define :be_educational_result do
  match do |actual|
    actual.respond_to?(:educational_summary) &&
    actual.educational_summary.is_a?(String) &&
    actual.educational_summary.length > 0
  end
  
  failure_message do |actual|
    "Expected #{actual} to be an educational result with meaningful educational_summary"
  end
end

RSpec::Matchers.define :satisfy_outlier_properties do
  match do |actual|
    actual.respond_to?(:count) &&
    actual.respond_to?(:percentage) &&
    actual.respond_to?(:indices) &&
    actual.respond_to?(:values) &&
    actual.respond_to?(:method) &&
    actual.respond_to?(:threshold) &&
    actual.respond_to?(:severity) &&
    actual.respond_to?(:any?) &&
    actual.respond_to?(:empty?)
  end
  
  failure_message do |actual|
    "Expected #{actual} to satisfy outlier detection result properties"
  end
end