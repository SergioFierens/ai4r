# frozen_string_literal: true

# Factory definitions for AI4R educational testing
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

FactoryBot.define do
  # Basic dataset factory
  factory :dataset, class: Hash do
    transient do
      rows { 10 }
      columns { 3 }
      data_type { :numeric }
    end

    data_items do
      Array.new(rows) do
        case data_type
        when :numeric
          Array.new(columns) { rand(-100.0..100.0) }
        when :categorical
          categories = ['A', 'B', 'C', 'D']
          Array.new(columns) { categories.sample }
        when :mixed
          Array.new(columns) { |i| i.even? ? rand(-100.0..100.0) : ['A', 'B', 'C'].sample }
        when :outlier_prone
          normal_data = Array.new(columns * 0.8) { rand(-10.0..10.0) }
          outlier_data = Array.new(columns * 0.2) { rand > 0.5 ? rand(50.0..100.0) : rand(-100.0..-50.0) }
          (normal_data + outlier_data).shuffle
        end
      end
    end

    data_labels do
      Array.new(columns) { |i| "feature_#{i + 1}" }
    end

    initialize_with { { data_items: data_items, data_labels: data_labels } }
  end

  # Educational dataset with specific properties
  factory :educational_dataset, parent: :dataset do
    transient do
      has_outliers { false }
      has_missing_values { false }
      has_correlations { false }
      seed { 42 }
    end

    data_items do
      Random.srand(seed)
      
      base_data = Array.new(rows) do
        Array.new(columns) { rand(-50.0..50.0) }
      end

      # Add outliers if requested
      if has_outliers
        outlier_count = (rows * 0.1).ceil
        outlier_indices = (0...rows).to_a.sample(outlier_count)
        outlier_indices.each do |idx|
          base_data[idx][0] = rand > 0.5 ? rand(100.0..200.0) : rand(-200.0..-100.0)
        end
      end

      # Add missing values if requested
      if has_missing_values
        missing_count = (rows * columns * 0.05).ceil
        missing_count.times do
          row_idx = rand(rows)
          col_idx = rand(columns)
          base_data[row_idx][col_idx] = nil
        end
      end

      # Add correlations if requested
      if has_correlations && columns >= 2
        base_data.each do |row|
          row[1] = row[0] * 2 + rand(-5.0..5.0)  # Strong correlation with noise
        end
      end

      base_data
    end
  end

  # Small dataset for quick tests
  factory :small_dataset, parent: :dataset do
    rows { 5 }
    columns { 2 }
  end

  # Large dataset for performance tests
  factory :large_dataset, parent: :dataset do
    rows { 1000 }
    columns { 10 }
  end

  # Outlier detection test data
  factory :outlier_test_data, class: Array do
    transient do
      size { 100 }
      outlier_percentage { 0.1 }
      outlier_magnitude { 3.0 }
    end

    initialize_with do
      normal_size = (size * (1 - outlier_percentage)).to_i
      outlier_size = size - normal_size
      
      normal_data = Array.new(normal_size) { rand(-10.0..10.0) }
      outlier_data = Array.new(outlier_size) do
        rand > 0.5 ? rand(10.0 * outlier_magnitude..20.0 * outlier_magnitude) : 
                     rand(-20.0 * outlier_magnitude..-10.0 * outlier_magnitude)
      end
      
      (normal_data + outlier_data).shuffle
    end
  end

  # Normalization test data
  factory :normalization_test_data, class: Array do
    transient do
      size { 50 }
      distribution { :normal }
      mean { 0.0 }
      std { 1.0 }
    end

    initialize_with do
      case distribution
      when :normal
        Array.new(size) { mean + std * rand(-3.0..3.0) }
      when :uniform
        Array.new(size) { rand(-100.0..100.0) }
      when :skewed
        Array.new(size) { |i| i < size * 0.8 ? rand(0.0..10.0) : rand(50.0..100.0) }
      when :bimodal
        Array.new(size) { |i| i < size / 2 ? rand(-20.0..-10.0) : rand(10.0..20.0) }
      else
        Array.new(size) { rand(-50.0..50.0) }
      end
    end
  end

  # Classification test data
  factory :classification_data, class: Hash do
    transient do
      samples_per_class { 20 }
      features { 3 }
      classes { ['A', 'B', 'C'] }
      noise_level { 0.1 }
    end

    data_items do
      all_data = []
      
      classes.each_with_index do |class_label, class_idx|
        # Create cluster center
        center = Array.new(features) { class_idx * 10 + rand(-2.0..2.0) }
        
        # Generate samples around center
        samples_per_class.times do
          sample = center.map { |c| c + rand(-5.0..5.0) * (1 + noise_level) }
          sample << class_label
          all_data << sample
        end
      end
      
      all_data.shuffle
    end

    data_labels do
      Array.new(features) { |i| "feature_#{i + 1}" } + ['class']
    end

    initialize_with { { data_items: data_items, data_labels: data_labels } }
  end

  # Clustering test data
  factory :clustering_data, class: Hash do
    transient do
      clusters { 3 }
      points_per_cluster { 15 }
      dimensions { 2 }
      cluster_separation { 20.0 }
      cluster_tightness { 5.0 }
    end

    data_items do
      all_data = []
      
      clusters.times do |cluster_idx|
        # Create cluster center
        center = Array.new(dimensions) { cluster_idx * cluster_separation + rand(-5.0..5.0) }
        
        # Generate points around center
        points_per_cluster.times do
          point = center.map { |c| c + rand(-cluster_tightness..cluster_tightness) }
          all_data << point
        end
      end
      
      all_data.shuffle
    end

    data_labels do
      Array.new(dimensions) { |i| "dim_#{i + 1}" }
    end

    initialize_with { { data_items: data_items, data_labels: data_labels } }
  end

  # Time series test data
  factory :time_series_data, class: Array do
    transient do
      length { 100 }
      trend { 0.1 }
      seasonality { true }
      noise { 0.1 }
    end

    initialize_with do
      data = Array.new(length) do |i|
        value = trend * i
        value += 10 * Math.sin(2 * Math::PI * i / 12) if seasonality
        value += rand(-noise..noise) * 10
        value
      end
      data
    end
  end

  # Educational configuration factory
  factory :educational_config, class: Hash do
    verbose { false }
    explain_operations { false }
    show_warnings { false }
    interactive_mode { false }
    learning_level { :advanced }
    step_by_step { false }
    show_progress { false }

    trait :beginner do
      verbose { true }
      explain_operations { true }
      show_warnings { true }
      interactive_mode { true }
      learning_level { :beginner }
      step_by_step { true }
      show_progress { true }
    end

    trait :intermediate do
      verbose { true }
      explain_operations { false }
      show_warnings { true }
      interactive_mode { false }
      learning_level { :intermediate }
      step_by_step { false }
      show_progress { true }
    end

    trait :advanced do
      verbose { false }
      explain_operations { false }
      show_warnings { false }
      interactive_mode { false }
      learning_level { :advanced }
      step_by_step { false }
      show_progress { false }
    end

    initialize_with { attributes }
  end
end