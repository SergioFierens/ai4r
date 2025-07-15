# frozen_string_literal: true

# Data splitting utilities for machine learning with educational explanations
# Author::    Claude (AI Assistant)
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module Data
    
    # Educational data splitter with comprehensive splitting strategies
    class DataSplitter
      
      def initialize(dataset, educational_config = {})
        @dataset = dataset
        @config = educational_config
        @verbose = educational_config.fetch(:verbose, false)
        @explain_operations = educational_config.fetch(:explain_operations, false)
      end
      
      # Split data into train and test sets
      def split(test_size = 0.2, random_seed = nil, stratify = nil)
        explain_train_test_split(test_size) if @explain_operations
        
        data_items = @dataset.data_items
        return { train: create_empty_dataset, test: create_empty_dataset } if data_items.empty?
        
        # Set random seed for reproducibility
        srand(random_seed) if random_seed
        
        if stratify
          stratified_split(data_items, test_size, stratify)
        else
          random_split(data_items, test_size)
        end
      end
      
      # Create k-fold cross-validation splits
      def k_fold_split(k = 5, random_seed = nil, stratify = nil)
        explain_k_fold_validation(k) if @explain_operations
        
        data_items = @dataset.data_items
        return [] if data_items.empty?
        
        # Set random seed for reproducibility
        srand(random_seed) if random_seed
        
        if stratify
          stratified_k_fold_split(data_items, k, stratify)
        else
          random_k_fold_split(data_items, k)
        end
      end
      
      # Time-based split for time series data
      def time_based_split(test_size = 0.2, time_column = nil)
        explain_time_based_split if @explain_operations
        
        data_items = @dataset.data_items
        return { train: create_empty_dataset, test: create_empty_dataset } if data_items.empty?
        
        if time_column
          time_ordered_split(data_items, test_size, time_column)
        else
          # Assume data is already in chronological order
          sequential_split(data_items, test_size)
        end
      end
      
      # Group-based split (e.g., by user, by location)
      def group_split(group_column, test_size = 0.2, random_seed = nil)
        explain_group_split(group_column) if @explain_operations
        
        data_items = @dataset.data_items
        return { train: create_empty_dataset, test: create_empty_dataset } if data_items.empty?
        
        group_idx = @dataset.get_index(group_column)
        srand(random_seed) if random_seed
        
        group_based_split(data_items, group_idx, test_size)
      end
      
      # Leave-one-out cross-validation
      def leave_one_out_split
        explain_leave_one_out if @explain_operations
        
        data_items = @dataset.data_items
        return [] if data_items.empty?
        
        splits = []
        
        data_items.each_with_index do |test_item, test_idx|
          train_items = data_items.select.with_index { |_, idx| idx != test_idx }
          
          train_dataset = create_dataset_from_items(train_items)
          test_dataset = create_dataset_from_items([test_item])
          
          splits << {
            fold: test_idx + 1,
            train: train_dataset,
            test: test_dataset
          }
        end
        
        if @verbose
          puts "✅ Created #{splits.length} leave-one-out splits"
        end
        
        splits
      end
      
      # Holdout validation (train/validation/test split)
      def holdout_split(test_size = 0.2, validation_size = 0.2, random_seed = nil)
        explain_holdout_split(test_size, validation_size) if @explain_operations
        
        data_items = @dataset.data_items
        return { train: create_empty_dataset, validation: create_empty_dataset, test: create_empty_dataset } if data_items.empty?
        
        srand(random_seed) if random_seed
        
        # First split: separate test set
        shuffled_data = data_items.shuffle
        test_count = (data_items.length * test_size).round
        
        test_items = shuffled_data.last(test_count)
        remaining_items = shuffled_data.first(shuffled_data.length - test_count)
        
        # Second split: separate validation from remaining data
        validation_count = (remaining_items.length * validation_size).round
        
        validation_items = remaining_items.last(validation_count)
        train_items = remaining_items.first(remaining_items.length - validation_count)
        
        result = {
          train: create_dataset_from_items(train_items),
          validation: create_dataset_from_items(validation_items),
          test: create_dataset_from_items(test_items)
        }
        
        if @verbose
          puts "✅ Holdout split created:"
          puts "   Train: #{train_items.length} samples"
          puts "   Validation: #{validation_items.length} samples"
          puts "   Test: #{test_items.length} samples"
        end
        
        result
      end
      
      private
      
      def explain_train_test_split(test_size)
        puts "\n🎯 Train-Test Split Concepts:"
        puts "• Training set: Used to train the model"
        puts "• Test set: Used to evaluate final model performance"
        puts "• Test size: #{(test_size * 100).round(1)}% of data reserved for testing"
        puts "• Goal: Estimate how model performs on unseen data"
        puts "• Never use test data during model development!"
      end
      
      def explain_k_fold_validation(k)
        puts "\n🔄 K-Fold Cross-Validation Concepts:"
        puts "• Data split into #{k} equal folds"
        puts "• Each fold serves as test set once"
        puts "• Remaining #{k-1} folds used for training"
        puts "• Results averaged across all folds"
        puts "• Provides more robust performance estimates"
        puts "• Better utilization of limited data"
      end
      
      def explain_time_based_split
        puts "\n⏰ Time-Based Split Concepts:"
        puts "• Earlier data used for training"
        puts "• Later data used for testing"
        puts "• Respects temporal order"
        puts "• Realistic for time series forecasting"
        puts "• Prevents data leakage from future"
      end
      
      def explain_group_split(group_column)
        puts "\n👥 Group-Based Split Concepts:"
        puts "• Splits based on #{group_column} groups"
        puts "• Ensures no group appears in both train and test"
        puts "• Prevents data leakage between related samples"
        puts "• Important for user-based or location-based data"
        puts "• More realistic evaluation for deployment"
      end
      
      def explain_leave_one_out
        puts "\n🎯 Leave-One-Out Cross-Validation:"
        puts "• Each sample serves as test set once"
        puts "• Maximum utilization of training data"
        puts "• Computationally expensive for large datasets"
        puts "• High variance in performance estimates"
        puts "• Best for very small datasets"
      end
      
      def explain_holdout_split(test_size, validation_size)
        puts "\n🎯 Holdout Validation Split:"
        puts "• Three-way split: train/validation/test"
        puts "• Training: #{((1 - test_size - validation_size) * 100).round(1)}%"
        puts "• Validation: #{(validation_size * 100).round(1)}% (for model selection)"
        puts "• Test: #{(test_size * 100).round(1)}% (for final evaluation)"
        puts "• Validation set used for hyperparameter tuning"
        puts "• Test set remains untouched until final evaluation"
      end
      
      def random_split(data_items, test_size)
        shuffled_data = data_items.shuffle
        test_count = (data_items.length * test_size).round
        
        test_items = shuffled_data.last(test_count)
        train_items = shuffled_data.first(shuffled_data.length - test_count)
        
        result = {
          train: create_dataset_from_items(train_items),
          test: create_dataset_from_items(test_items)
        }
        
        if @verbose
          puts "✅ Random split created:"
          puts "   Train: #{train_items.length} samples"
          puts "   Test: #{test_items.length} samples"
        end
        
        result
      end
      
      def stratified_split(data_items, test_size, stratify_column)
        stratify_idx = @dataset.get_index(stratify_column)
        
        # Group data by stratification column
        groups = group_by_column(data_items, stratify_idx)
        
        train_items = []
        test_items = []
        
        groups.each do |class_value, items|
          shuffled_items = items.shuffle
          test_count = [1, (items.length * test_size).round].max
          
          class_test_items = shuffled_items.last(test_count)
          class_train_items = shuffled_items.first(shuffled_items.length - test_count)
          
          train_items.concat(class_train_items)
          test_items.concat(class_test_items)
        end
        
        result = {
          train: create_dataset_from_items(train_items.shuffle),
          test: create_dataset_from_items(test_items.shuffle)
        }
        
        if @verbose
          puts "✅ Stratified split created:"
          puts "   Train: #{train_items.length} samples"
          puts "   Test: #{test_items.length} samples"
          puts "   Maintained class distribution across splits"
        end
        
        result
      end
      
      def random_k_fold_split(data_items, k)
        shuffled_data = data_items.shuffle
        fold_size = data_items.length / k
        splits = []
        
        k.times do |fold_idx|
          start_idx = (fold_idx * fold_size).round
          end_idx = ((fold_idx + 1) * fold_size).round
          end_idx = data_items.length if fold_idx == k - 1  # Handle remainder
          
          test_items = shuffled_data[start_idx...end_idx]
          train_items = shuffled_data[0...start_idx] + shuffled_data[end_idx..-1]
          
          splits << {
            fold: fold_idx + 1,
            train: create_dataset_from_items(train_items),
            test: create_dataset_from_items(test_items)
          }
        end
        
        if @verbose
          puts "✅ Created #{k}-fold cross-validation splits:"
          splits.each do |split|
            puts "   Fold #{split[:fold]}: #{split[:train].data_items.length} train, #{split[:test].data_items.length} test"
          end
        end
        
        splits
      end
      
      def stratified_k_fold_split(data_items, k, stratify_column)
        stratify_idx = @dataset.get_index(stratify_column)
        groups = group_by_column(data_items, stratify_idx)
        
        # Create stratified folds for each class
        class_folds = {}
        groups.each do |class_value, items|
          shuffled_items = items.shuffle
          fold_size = items.length / k
          
          class_folds[class_value] = []
          k.times do |fold_idx|
            start_idx = (fold_idx * fold_size).round
            end_idx = ((fold_idx + 1) * fold_size).round
            end_idx = items.length if fold_idx == k - 1
            
            class_folds[class_value] << shuffled_items[start_idx...end_idx]
          end
        end
        
        # Combine folds across classes
        splits = []
        k.times do |fold_idx|
          test_items = []
          train_items = []
          
          class_folds.each do |class_value, folds|
            test_items.concat(folds[fold_idx])
            
            # Add all other folds to training
            folds.each_with_index do |fold, idx|
              train_items.concat(fold) if idx != fold_idx
            end
          end
          
          splits << {
            fold: fold_idx + 1,
            train: create_dataset_from_items(train_items.shuffle),
            test: create_dataset_from_items(test_items.shuffle)
          }
        end
        
        if @verbose
          puts "✅ Created stratified #{k}-fold cross-validation splits:"
          splits.each do |split|
            puts "   Fold #{split[:fold]}: #{split[:train].data_items.length} train, #{split[:test].data_items.length} test"
          end
        end
        
        splits
      end
      
      def time_ordered_split(data_items, test_size, time_column)
        time_idx = @dataset.get_index(time_column)
        
        # Sort by time column
        sorted_data = data_items.sort_by { |row| row[time_idx] }
        
        test_count = (sorted_data.length * test_size).round
        split_point = sorted_data.length - test_count
        
        train_items = sorted_data[0...split_point]
        test_items = sorted_data[split_point..-1]
        
        result = {
          train: create_dataset_from_items(train_items),
          test: create_dataset_from_items(test_items)
        }
        
        if @verbose
          puts "✅ Time-ordered split created:"
          puts "   Train: #{train_items.length} samples (earlier data)"
          puts "   Test: #{test_items.length} samples (later data)"
        end
        
        result
      end
      
      def sequential_split(data_items, test_size)
        test_count = (data_items.length * test_size).round
        split_point = data_items.length - test_count
        
        train_items = data_items[0...split_point]
        test_items = data_items[split_point..-1]
        
        result = {
          train: create_dataset_from_items(train_items),
          test: create_dataset_from_items(test_items)
        }
        
        if @verbose
          puts "✅ Sequential split created:"
          puts "   Train: #{train_items.length} samples"
          puts "   Test: #{test_items.length} samples"
        end
        
        result
      end
      
      def group_based_split(data_items, group_idx, test_size)
        groups = group_by_column(data_items, group_idx)
        group_keys = groups.keys.shuffle
        
        test_group_count = [1, (group_keys.length * test_size).round].max
        
        test_groups = group_keys.last(test_group_count)
        train_groups = group_keys.first(group_keys.length - test_group_count)
        
        train_items = train_groups.flat_map { |group| groups[group] }
        test_items = test_groups.flat_map { |group| groups[group] }
        
        result = {
          train: create_dataset_from_items(train_items),
          test: create_dataset_from_items(test_items)
        }
        
        if @verbose
          puts "✅ Group-based split created:"
          puts "   Train: #{train_items.length} samples from #{train_groups.length} groups"
          puts "   Test: #{test_items.length} samples from #{test_groups.length} groups"
          puts "   No group overlap between train and test"
        end
        
        result
      end
      
      def group_by_column(data_items, column_idx)
        groups = {}
        data_items.each do |item|
          key = item[column_idx]
          groups[key] ||= []
          groups[key] << item
        end
        groups
      end
      
      def create_dataset_from_items(items)
        @dataset.class.new(
          data_items: items,
          data_labels: @dataset.data_labels
        )
      end
      
      def create_empty_dataset
        @dataset.class.new(
          data_items: [],
          data_labels: @dataset.data_labels
        )
      end
    end
  end
end