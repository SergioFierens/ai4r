# frozen_string_literal: true

# RSpec tests for Factory Bot factories validation
# Author:: AI4R Development Team
# License:: MPL 1.1
# Project:: ai4r
# Url:: https://github.com/SergioFierens/ai4r

require 'spec_helper'

RSpec.describe "Factory Bot Factories" do
  describe "dataset factory" do
    it "creates valid dataset with default parameters" do
      dataset = build(:dataset)
      
      expect(dataset).to be_a(Hash)
      expect(dataset).to have_key(:data_items)
      expect(dataset).to have_key(:data_labels)
      expect(dataset[:data_items]).to be_an(Array)
      expect(dataset[:data_labels]).to be_an(Array)
      expect(dataset[:data_items].length).to eq(10)
      expect(dataset[:data_labels].length).to eq(3)
    end

    it "creates dataset with custom parameters" do
      dataset = build(:dataset, rows: 5, columns: 2)
      
      expect(dataset[:data_items].length).to eq(5)
      expect(dataset[:data_labels].length).to eq(2)
    end

    it "creates different data types" do
      numeric_dataset = build(:dataset, data_type: :numeric)
      categorical_dataset = build(:dataset, data_type: :categorical)
      mixed_dataset = build(:dataset, data_type: :mixed)
      
      expect(numeric_dataset[:data_items].flatten).to all(be_a(Numeric))
      expect(categorical_dataset[:data_items].flatten).to all(be_a(String))
      expect(mixed_dataset[:data_items].flatten).to include(a_kind_of(Numeric), a_kind_of(String))
    end
  end

  describe "educational_dataset factory" do
    it "creates educational dataset with outliers" do
      dataset = build(:educational_dataset, has_outliers: true, rows: 20)
      
      expect(dataset).to be_a(Hash)
      expect(dataset[:data_items]).to be_an(Array)
      expect(dataset[:data_items].length).to eq(20)
    end

    it "creates dataset with missing values" do
      dataset = build(:educational_dataset, has_missing_values: true, rows: 10)
      
      missing_count = dataset[:data_items].flatten.count(nil)
      expect(missing_count).to be > 0
    end

    it "creates dataset with correlations" do
      dataset = build(:educational_dataset, has_correlations: true, columns: 3)
      
      expect(dataset[:data_items].first.length).to eq(3)
      # The second column should be correlated with the first
      first_col = dataset[:data_items].map { |row| row[0] }
      second_col = dataset[:data_items].map { |row| row[1] }
      
      # Simple correlation check - second column should generally be larger
      expect(second_col.zip(first_col).count { |s, f| s > f }).to be > dataset[:data_items].length * 0.8
    end

    it "uses reproducible random seed" do
      dataset1 = build(:educational_dataset, seed: 42)
      dataset2 = build(:educational_dataset, seed: 42)
      
      expect(dataset1[:data_items]).to eq(dataset2[:data_items])
    end
  end

  describe "size variants" do
    it "creates small dataset" do
      dataset = build(:small_dataset)
      
      expect(dataset[:data_items].length).to eq(5)
      expect(dataset[:data_labels].length).to eq(2)
    end

    it "creates large dataset" do
      dataset = build(:large_dataset)
      
      expect(dataset[:data_items].length).to eq(1000)
      expect(dataset[:data_labels].length).to eq(10)
    end
  end

  describe "specialized test data" do
    describe "outlier_test_data" do
      it "creates data with known outliers" do
        data = build(:outlier_test_data, size: 100, outlier_percentage: 0.1)
        
        expect(data).to be_an(Array)
        expect(data.length).to eq(100)
        expect(data).to all(be_a(Numeric))
        
        # Should have some extreme values
        normal_range = (-15..15)
        outliers = data.reject { |v| normal_range.cover?(v) }
        expect(outliers.length).to be >= 5  # About 10% should be outliers
      end

      it "creates data with different outlier magnitudes" do
        mild_outliers = build(:outlier_test_data, outlier_magnitude: 2.0)
        extreme_outliers = build(:outlier_test_data, outlier_magnitude: 5.0)
        
        mild_max = mild_outliers.max
        extreme_max = extreme_outliers.max
        
        expect(extreme_max.abs).to be > mild_max.abs
      end
    end

    describe "normalization_test_data" do
      it "creates normal distribution data" do
        data = build(:normalization_test_data, distribution: :normal, size: 100)
        
        expect(data).to be_an(Array)
        expect(data.length).to eq(100)
        expect(data).to all(be_a(Numeric))
        
        # Should be roughly centered around mean
        mean = data.sum / data.length
        expect(mean).to be_within(1.0).of(0.0)
      end

      it "creates uniform distribution data" do
        data = build(:normalization_test_data, distribution: :uniform, size: 50)
        
        expect(data.length).to eq(50)
        expect(data.min).to be >= -100
        expect(data.max).to be <= 100
      end

      it "creates skewed distribution data" do
        data = build(:normalization_test_data, distribution: :skewed, size: 100)
        
        # Most values should be in lower range
        low_values = data.count { |v| v <= 20 }
        expect(low_values).to be >= 60  # At least 60% should be in low range
      end

      it "creates bimodal distribution data" do
        data = build(:normalization_test_data, distribution: :bimodal, size: 100)
        
        # Should have values in two distinct ranges
        negative_values = data.count { |v| v < 0 }
        positive_values = data.count { |v| v > 0 }
        
        expect(negative_values).to be >= 30
        expect(positive_values).to be >= 30
      end
    end

    describe "classification_data" do
      it "creates balanced classification dataset" do
        data = build(:classification_data, samples_per_class: 10, features: 2, classes: ['A', 'B'])
        
        expect(data[:data_items].length).to eq(20)  # 10 samples × 2 classes
        expect(data[:data_labels].length).to eq(3)  # 2 features + 1 class
        expect(data[:data_labels].last).to eq('class')
        
        # Check class distribution
        classes = data[:data_items].map(&:last)
        expect(classes.count('A')).to eq(10)
        expect(classes.count('B')).to eq(10)
      end

      it "creates multi-class dataset" do
        data = build(:classification_data, samples_per_class: 5, classes: ['A', 'B', 'C', 'D'])
        
        expect(data[:data_items].length).to eq(20)  # 5 samples × 4 classes
        
        classes = data[:data_items].map(&:last)
        ['A', 'B', 'C', 'D'].each do |class_label|
          expect(classes.count(class_label)).to eq(5)
        end
      end

      it "adds noise to classification data" do
        clean_data = build(:classification_data, noise_level: 0.0, samples_per_class: 10)
        noisy_data = build(:classification_data, noise_level: 0.5, samples_per_class: 10)
        
        # Noisy data should have more spread
        clean_std = calculate_column_std(clean_data[:data_items], 0)
        noisy_std = calculate_column_std(noisy_data[:data_items], 0)
        
        expect(noisy_std).to be > clean_std
      end
    end

    describe "clustering_data" do
      it "creates well-separated clusters" do
        data = build(:clustering_data, clusters: 3, points_per_cluster: 10, cluster_separation: 30)
        
        expect(data[:data_items].length).to eq(30)  # 10 points × 3 clusters
        expect(data[:data_labels].length).to eq(2)  # 2 dimensions by default
        
        # Check that we have reasonable spread
        first_dim = data[:data_items].map { |point| point[0] }
        expect(first_dim.max - first_dim.min).to be > 20  # Should span reasonable range
      end

      it "creates tightly packed clusters" do
        tight_data = build(:clustering_data, cluster_tightness: 2.0)
        loose_data = build(:clustering_data, cluster_tightness: 10.0)
        
        tight_std = calculate_column_std(tight_data[:data_items], 0)
        loose_std = calculate_column_std(loose_data[:data_items], 0)
        
        expect(loose_std).to be > tight_std
      end

      it "supports multi-dimensional clustering" do
        data = build(:clustering_data, dimensions: 5, clusters: 2, points_per_cluster: 10)
        
        expect(data[:data_items].length).to eq(20)
        expect(data[:data_labels].length).to eq(5)
        expect(data[:data_items].first.length).to eq(5)
      end
    end

    describe "time_series_data" do
      it "creates time series with trend" do
        data = build(:time_series_data, length: 100, trend: 0.5)
        
        expect(data).to be_an(Array)
        expect(data.length).to eq(100)
        
        # Should have upward trend
        first_half_avg = data[0...50].sum / 50
        second_half_avg = data[50..-1].sum / 50
        
        expect(second_half_avg).to be > first_half_avg
      end

      it "creates time series with seasonality" do
        seasonal_data = build(:time_series_data, length: 48, seasonality: true)
        non_seasonal_data = build(:time_series_data, length: 48, seasonality: false)
        
        # Seasonal data should have more regular patterns
        seasonal_std = calculate_std(seasonal_data)
        non_seasonal_std = calculate_std(non_seasonal_data)
        
        expect(seasonal_std).to be > non_seasonal_std * 0.5  # Should have more variation
      end

      it "adds noise to time series" do
        clean_data = build(:time_series_data, noise: 0.01)
        noisy_data = build(:time_series_data, noise: 0.5)
        
        clean_std = calculate_std(clean_data)
        noisy_std = calculate_std(noisy_data)
        
        expect(noisy_std).to be > clean_std
      end
    end
  end

  describe "educational_config factory" do
    it "creates default configuration" do
      config = build(:educational_config)
      
      expect(config).to be_a(Hash)
      expect(config[:verbose]).to be false
      expect(config[:learning_level]).to eq(:advanced)
    end

    it "creates beginner configuration" do
      config = build(:educational_config, :beginner)
      
      expect(config[:verbose]).to be true
      expect(config[:interactive_mode]).to be true
      expect(config[:learning_level]).to eq(:beginner)
      expect(config[:step_by_step]).to be true
    end

    it "creates intermediate configuration" do
      config = build(:educational_config, :intermediate)
      
      expect(config[:verbose]).to be true
      expect(config[:explain_operations]).to be false
      expect(config[:learning_level]).to eq(:intermediate)
    end

    it "creates advanced configuration" do
      config = build(:educational_config, :advanced)
      
      expect(config[:verbose]).to be false
      expect(config[:interactive_mode]).to be false
      expect(config[:learning_level]).to eq(:advanced)
    end
  end

  describe "factory relationships and traits" do
    it "supports inheritance" do
      small_dataset = build(:small_dataset)
      large_dataset = build(:large_dataset)
      
      expect(small_dataset).to have_key(:data_items)
      expect(large_dataset).to have_key(:data_items)
      expect(small_dataset[:data_items].length).to be < large_dataset[:data_items].length
    end

    it "supports traits" do
      beginner_config = build(:educational_config, :beginner)
      intermediate_config = build(:educational_config, :intermediate)
      advanced_config = build(:educational_config, :advanced)
      
      expect(beginner_config[:learning_level]).to eq(:beginner)
      expect(intermediate_config[:learning_level]).to eq(:intermediate)
      expect(advanced_config[:learning_level]).to eq(:advanced)
    end

    it "supports transient attributes" do
      # Transient attributes are used during factory creation but not in final object
      dataset = build(:dataset, rows: 15, columns: 4)
      
      expect(dataset[:data_items].length).to eq(15)
      expect(dataset[:data_labels].length).to eq(4)
      expect(dataset).not_to have_key(:rows)
      expect(dataset).not_to have_key(:columns)
    end
  end

  describe "factory performance" do
    it "creates datasets efficiently" do
      benchmark_performance("Dataset creation") do
        build(:dataset)
      end
    end

    it "creates large datasets efficiently" do
      benchmark_performance("Large dataset creation") do
        build(:large_dataset)
      end
    end

    it "creates complex datasets efficiently" do
      benchmark_performance("Complex dataset creation") do
        build(:educational_dataset, has_outliers: true, has_missing_values: true, has_correlations: true)
      end
    end
  end

  describe "factory validation" do
    it "creates valid data structures" do
      FactoryBot.factories.each do |factory|
        expect { build(factory.name) }.not_to raise_error
      end
    end

    it "creates consistent data" do
      # Test that the same factory with same parameters produces consistent results
      dataset1 = build(:educational_dataset, seed: 123)
      dataset2 = build(:educational_dataset, seed: 123)
      
      expect(dataset1[:data_items]).to eq(dataset2[:data_items])
    end

    it "respects parameter constraints" do
      # Test edge cases and constraints
      expect { build(:dataset, rows: 0) }.not_to raise_error
      expect { build(:dataset, columns: 1) }.not_to raise_error
      expect { build(:outlier_test_data, size: 1) }.not_to raise_error
    end
  end

  # Helper methods
  def calculate_column_std(data, column_index)
    values = data.map { |row| row[column_index] }.compact
    mean = values.sum / values.length
    variance = values.sum { |v| (v - mean) ** 2 } / values.length
    Math.sqrt(variance)
  end

  def calculate_std(data)
    mean = data.sum / data.length
    variance = data.sum { |v| (v - mean) ** 2 } / data.length
    Math.sqrt(variance)
  end
end