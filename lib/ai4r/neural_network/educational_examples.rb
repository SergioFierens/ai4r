# frozen_string_literal: true

# Comprehensive educational examples for neural networks
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'enhanced_neural_network'
require_relative 'activation_functions'
require_relative 'optimizers'
require_relative 'regularization'

module Ai4r
  module NeuralNetwork
    module EducationalExamples
      
      # Progressive learning examples for students
      class ProgressiveLearningPath
        
        def self.run_beginner_sequence
          puts "="*60
          puts "NEURAL NETWORKS BEGINNER LEARNING SEQUENCE"
          puts "="*60
          
          puts "\nThis sequence will teach you neural networks step by step:"
          puts "1. Single Neuron (Perceptron)"
          puts "2. XOR Problem (Need for Hidden Layers)"
          puts "3. Activation Functions Comparison"
          puts "4. Optimizers Comparison"
          puts "5. Regularization Techniques"
          
          wait_for_user
          
          lesson_1_single_neuron
          lesson_2_xor_problem
          lesson_3_activation_functions
          lesson_4_optimizers
          lesson_5_regularization
          
          puts "\n🎉 Congratulations! You've completed the beginner sequence!"
          puts "Next steps: Try the intermediate sequence or experiment with your own data."
        end
        
        private
        
        def self.lesson_1_single_neuron
          puts "\n" + "="*50
          puts "LESSON 1: Single Neuron (Perceptron)"
          puts "="*50
          
          puts <<~EXPLANATION
            A single neuron can learn linear patterns.
            We'll train it to learn the AND logic gate:
            
            AND Truth Table:
            Input 1 | Input 2 | Output
            --------|---------|-------
                0   |    0    |   0
                0   |    1    |   0
                1   |    0    |   0
                1   |    1    |   1
            
            This is linearly separable - a single line can separate
            the classes.
          EXPLANATION
          
          wait_for_user
          
          # Create AND gate data
          and_data = [
            [[0, 0], [0]],
            [[0, 1], [0]],
            [[1, 0], [0]],
            [[1, 1], [1]]
          ]
          
          # Single neuron network (no hidden layer)
          config = NetworkConfiguration.new(
            activation_function: :sigmoid,
            optimizer: :sgd,
            optimizer_params: { learning_rate: 0.5 },
            loss_function: :mse,
            verbose: true,
            print_every: 100
          )
          
          network = EnhancedNeuralNetwork.new([2, 1], config)
          
          puts "\nTraining single neuron on AND gate..."
          network.train(and_data, nil, 1000)
          
          puts "\nTesting the trained neuron:"
          and_data.each do |input, expected|
            prediction = network.forward(input, false)
            puts "Input: #{input} → Expected: #{expected[0]}, Got: #{prediction[0].round(3)}"
          end
          
          puts "\n💡 Key Learning:"
          puts "A single neuron can learn the AND gate because it's linearly separable."
          puts "The neuron learned to draw a line separating the classes."
          
          wait_for_user
        end
        
        def self.lesson_2_xor_problem
          puts "\n" + "="*50
          puts "LESSON 2: XOR Problem - Why We Need Hidden Layers"
          puts "="*50
          
          puts <<~EXPLANATION
            Now let's try the XOR (exclusive OR) problem:
            
            XOR Truth Table:
            Input 1 | Input 2 | Output
            --------|---------|-------
                0   |    0    |   0
                0   |    1    |   1
                1   |    0    |   1
                1   |    1    |   0
            
            This is NOT linearly separable - no single line can
            separate the classes. We need a hidden layer!
          EXPLANATION
          
          wait_for_user
          
          # Create XOR data
          xor_data = [
            [[0, 0], [0]],
            [[0, 1], [1]],
            [[1, 0], [1]],
            [[1, 1], [0]]
          ]
          
          # First, try with single neuron (will fail)
          puts "\nFirst, let's try with a single neuron (this will fail):"
          
          config1 = NetworkConfiguration.new(
            activation_function: :sigmoid,
            optimizer: :sgd,
            optimizer_params: { learning_rate: 0.5 },
            loss_function: :mse,
            verbose: false
          )
          
          network1 = EnhancedNeuralNetwork.new([2, 1], config1)
          network1.train(xor_data, nil, 1000)
          
          puts "\nSingle neuron results:"
          xor_data.each do |input, expected|
            prediction = network1.forward(input, false)
            puts "Input: #{input} → Expected: #{expected[0]}, Got: #{prediction[0].round(3)}"
          end
          
          final_loss = network1.monitor.training_losses.last
          puts "Final loss: #{final_loss.round(6)} (high = failed to learn)"
          
          wait_for_user
          
          # Now try with hidden layer
          puts "\nNow let's add a hidden layer:"
          
          config2 = NetworkConfiguration.new(
            activation_function: :sigmoid,
            optimizer: :sgd,
            optimizer_params: { learning_rate: 1.0 },
            loss_function: :mse,
            verbose: true,
            print_every: 200
          )
          
          network2 = EnhancedNeuralNetwork.new([2, 4, 1], config2)
          network2.train(xor_data, nil, 2000)
          
          puts "\nHidden layer network results:"
          xor_data.each do |input, expected|
            prediction = network2.forward(input, false)
            puts "Input: #{input} → Expected: #{expected[0]}, Got: #{prediction[0].round(3)}"
          end
          
          puts "\n💡 Key Learning:"
          puts "• Single neuron: Failed (linear classifier)"
          puts "• Hidden layer: Success (non-linear classifier)"
          puts "• Hidden layers allow networks to learn complex patterns"
          puts "• XOR requires at least 2 hidden neurons"
          
          wait_for_user
        end
        
        def self.lesson_3_activation_functions
          puts "\n" + "="*50
          puts "LESSON 3: Activation Functions Comparison"
          puts "="*50
          
          puts <<~EXPLANATION
            Activation functions determine what patterns a network can learn.
            Let's compare different activation functions on the XOR problem:
            
            We'll test:
            • Sigmoid: Classic choice, can saturate
            • Tanh: Zero-centered version of sigmoid  
            • ReLU: Modern choice, no saturation
            • Leaky ReLU: Fixes "dying ReLU" problem
          EXPLANATION
          
          wait_for_user
          
          # Create XOR data
          xor_data = [
            [[0, 0], [0]],
            [[0, 1], [1]],
            [[1, 0], [1]],
            [[1, 1], [0]]
          ]
          
          activations = [:sigmoid, :tanh, :relu, :leaky_relu]
          results = {}
          
          activations.each do |activation|
            puts "\nTesting #{activation} activation..."
            
            config = NetworkConfiguration.new(
              activation_function: activation,
              optimizer: :adam,
              optimizer_params: { learning_rate: 0.01 },
              loss_function: :mse,
              verbose: false
            )
            
            network = EnhancedNeuralNetwork.new([2, 8, 1], config)
            network.train(xor_data, nil, 1000)
            
            # Test accuracy
            correct = 0
            xor_data.each do |input, expected|
              prediction = network.forward(input, false)
              predicted_class = prediction[0] > 0.5 ? 1 : 0
              correct += 1 if predicted_class == expected[0]
            end
            
            accuracy = correct.to_f / xor_data.length
            final_loss = network.monitor.training_losses.last
            
            results[activation] = {
              accuracy: accuracy,
              final_loss: final_loss,
              training_time: network.monitor.training_time
            }
            
            puts "  Accuracy: #{(accuracy * 100).round(1)}%"
            puts "  Final loss: #{final_loss.round(6)}"
            puts "  Training time: #{network.monitor.training_time.round(3)}s"
          end
          
          # Show comparison
          puts "\n=== Activation Function Comparison ==="
          puts "Function    | Accuracy | Loss     | Time"
          puts "------------|----------|----------|--------"
          
          results.each do |activation, data|
            puts sprintf("%-11s | %6.1f%% | %8.6f | %6.3fs",
                        activation, data[:accuracy] * 100, data[:final_loss], data[:training_time])
          end
          
          best = results.max_by { |_, data| data[:accuracy] }
          puts "\nBest performer: #{best[0]}"
          
          # Educational notes for each activation
          puts "\n💡 Key Insights:"
          puts "• ReLU often trains faster due to no saturation"
          puts "• Sigmoid/Tanh may struggle with vanishing gradients"
          puts "• Leaky ReLU prevents dead neurons"
          puts "• Choice depends on problem and network depth"
          
          wait_for_user
        end
        
        def self.lesson_4_optimizers
          puts "\n" + "="*50
          puts "LESSON 4: Optimizers Comparison"
          puts "="*50
          
          puts <<~EXPLANATION
            Optimizers determine how the network learns from gradients.
            Let's compare different optimizers on a regression problem:
            
            We'll test:
            • SGD: Basic gradient descent
            • SGD + Momentum: Accelerated version
            • Adam: Adaptive learning rates
            • RMSprop: Another adaptive method
          EXPLANATION
          
          wait_for_user
          
          # Create sine wave data for regression
          sine_data = []
          (0..100).each do |i|
            x = i / 100.0 * 2 * Math::PI
            y = Math.sin(x)
            sine_data << [[x], [y]]
          end
          
          # Split into train/test
          train_data = sine_data[0..79]
          test_data = sine_data[80..-1]
          
          optimizers = [
            [:sgd, { learning_rate: 0.1 }],
            [:sgd_momentum, { learning_rate: 0.1, momentum: 0.9 }],
            [:adam, { learning_rate: 0.01 }],
            [:rmsprop, { learning_rate: 0.01 }]
          ]
          
          results = {}
          
          optimizers.each do |optimizer, params|
            puts "\nTesting #{optimizer} optimizer..."
            
            config = NetworkConfiguration.new(
              activation_function: :relu,
              optimizer: optimizer,
              optimizer_params: params,
              loss_function: :mse,
              verbose: false
            )
            
            network = EnhancedNeuralNetwork.new([1, 16, 16, 1], config)
            network.train(train_data, test_data, 500)
            
            # Evaluate on test set
            test_loss, _ = network.evaluate(test_data)
            
            results[optimizer] = {
              test_loss: test_loss,
              training_time: network.monitor.training_time,
              final_train_loss: network.monitor.training_losses.last,
              convergence_epochs: find_convergence_epoch(network.monitor.training_losses)
            }
            
            puts "  Test loss: #{test_loss.round(6)}"
            puts "  Training time: #{network.monitor.training_time.round(3)}s"
            puts "  Convergence: #{results[optimizer][:convergence_epochs]} epochs"
          end
          
          # Show comparison
          puts "\n=== Optimizer Comparison ==="
          puts "Optimizer     | Test Loss | Time   | Convergence"
          puts "--------------|-----------|--------|------------"
          
          results.each do |optimizer, data|
            convergence = data[:convergence_epochs] || "No"
            puts sprintf("%-13s | %9.6f | %6.3fs | %s",
                        optimizer, data[:test_loss], data[:training_time], convergence)
          end
          
          best = results.min_by { |_, data| data[:test_loss] }
          puts "\nBest performer: #{best[0]}"
          
          puts "\n💡 Key Insights:"
          puts "• Adam often converges faster than SGD"
          puts "• Momentum helps SGD escape local minima"
          puts "• Adaptive optimizers (Adam, RMSprop) handle different learning rates"
          puts "• Best choice depends on problem and network size"
          
          wait_for_user
        end
        
        def self.lesson_5_regularization
          puts "\n" + "="*50
          puts "LESSON 5: Regularization Techniques"
          puts "="*50
          
          puts <<~EXPLANATION
            Regularization prevents overfitting - when a model memorizes
            training data but fails on new data.
            
            We'll create a scenario prone to overfitting and show how
            regularization techniques help:
            
            • No regularization: Baseline
            • Dropout: Randomly disable neurons during training
            • L2 regularization: Penalty for large weights
            • Early stopping: Stop when validation performance deteriorates
          EXPLANATION
          
          wait_for_user
          
          # Create polynomial data (prone to overfitting)
          train_data = []
          test_data = []
          
          # Training data - limited samples
          20.times do |i|
            x = (i - 10) / 10.0
            y = 0.5 * x**3 - 1.5 * x**2 + x + 0.5 + (rand - 0.5) * 0.2  # Add noise
            train_data << [[x], [y]]
          end
          
          # Test data - more comprehensive
          50.times do |i|
            x = (i - 25) / 12.5
            y = 0.5 * x**3 - 1.5 * x**2 + x + 0.5
            test_data << [[x], [y]]
          end
          
          techniques = [
            { name: "No regularization", config: {} },
            { name: "Dropout", config: { regularization: { dropout: { rate: 0.3 } } } },
            { name: "L2 regularization", config: { regularization: { l2: { lambda: 0.01 } } } },
            { name: "Early stopping", config: { early_stopping: true, early_stopping_patience: 20 } }
          ]
          
          results = {}
          
          techniques.each do |technique|
            puts "\nTesting: #{technique[:name]}"
            
            base_config = {
              activation_function: :relu,
              optimizer: :adam,
              optimizer_params: { learning_rate: 0.001 },
              loss_function: :mse,
              verbose: false
            }
            
            config = NetworkConfiguration.new(base_config.merge(technique[:config]))
            
            # Large network (prone to overfitting)
            network = EnhancedNeuralNetwork.new([1, 32, 32, 16, 1], config)
            network.train(train_data, test_data, 200)
            
            train_loss, _ = network.evaluate(train_data)
            test_loss, _ = network.evaluate(test_data)
            overfitting = test_loss / train_loss  # Overfitting ratio
            
            results[technique[:name]] = {
              train_loss: train_loss,
              test_loss: test_loss,
              overfitting_ratio: overfitting,
              epochs_trained: network.monitor.training_losses.length
            }
            
            puts "  Train loss: #{train_loss.round(6)}"
            puts "  Test loss: #{test_loss.round(6)}"
            puts "  Overfitting ratio: #{overfitting.round(3)} (lower is better)"
            puts "  Epochs trained: #{results[technique[:name]][:epochs_trained]}"
          end
          
          # Show comparison
          puts "\n=== Regularization Comparison ==="
          puts "Technique         | Train Loss | Test Loss  | Overfitting | Epochs"
          puts "------------------|------------|------------|-------------|-------"
          
          results.each do |name, data|
            puts sprintf("%-17s | %10.6f | %10.6f | %11.3f | %6d",
                        name, data[:train_loss], data[:test_loss], 
                        data[:overfitting_ratio], data[:epochs_trained])
          end
          
          best = results.min_by { |_, data| data[:overfitting_ratio] }
          puts "\nBest regularization: #{best[0]}"
          
          puts "\n💡 Key Insights:"
          puts "• Overfitting = good training performance, poor test performance"
          puts "• Regularization trades some training performance for better generalization"
          puts "• Dropout is very effective for large networks"
          puts "• Early stopping prevents overtraining"
          puts "• L2 regularization keeps weights small"
          
          wait_for_user
        end
        
        def self.find_convergence_epoch(losses)
          return nil if losses.length < 10
          
          # Find when improvement becomes minimal
          (10...losses.length).each do |i|
            recent_improvement = losses[i-10] - losses[i]
            return i if recent_improvement < 0.001
          end
          
          nil
        end
        
        def self.wait_for_user
          puts "\nPress Enter to continue..."
          gets
        end
      end
      
      # Real-world problem examples
      class RealWorldExamples
        
        def self.run_all_examples
          puts "="*60
          puts "REAL-WORLD NEURAL NETWORK EXAMPLES"
          puts "="*60
          
          puts "\nAvailable examples:"
          puts "1. Iris flower classification"
          puts "2. Boston housing price prediction"
          puts "3. Image recognition (handwritten digits)"
          puts "4. Time series prediction"
          puts "5. Sentiment analysis (text classification)"
          
          iris_classification_example
          housing_regression_example
          digit_recognition_example
          time_series_example
        end
        
        def self.iris_classification_example
          puts "\n" + "="*50
          puts "EXAMPLE 1: Iris Flower Classification"
          puts "="*50
          
          puts <<~DESCRIPTION
            The Iris dataset is a classic machine learning dataset.
            Goal: Classify iris flowers into 3 species based on 4 measurements:
            - Sepal length and width
            - Petal length and width
            
            This demonstrates multi-class classification.
          DESCRIPTION
          
          # Generate synthetic iris-like data
          iris_data = generate_iris_data
          
          # Split data
          train_data = iris_data[0..119]  # 80% for training
          test_data = iris_data[120..-1]   # 20% for testing
          
          config = NetworkConfiguration.new(
            activation_function: :relu,
            output_activation: :softmax,
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.01 },
            loss_function: :cross_entropy,
            task_type: :classification,
            verbose: true,
            print_every: 50
          )
          
          # 4 inputs → 8 hidden → 3 outputs (3 classes)
          network = EnhancedNeuralNetwork.new([4, 8, 3], config)
          
          puts "\nTraining on iris data..."
          network.train(train_data, test_data, 200)
          
          # Evaluate
          test_loss, test_accuracy = network.evaluate(test_data)
          puts "\nTest Results:"
          puts "Accuracy: #{(test_accuracy * 100).round(1)}%"
          puts "Loss: #{test_loss.round(4)}"
          
          # Show some predictions
          puts "\nSample Predictions:"
          test_data[0..4].each_with_index do |sample, i|
            input, target = sample
            prediction = network.forward(input, false)
            
            predicted_class = prediction.index(prediction.max)
            actual_class = target.index(target.max)
            
            puts "Sample #{i+1}: Predicted #{predicted_class}, Actual #{actual_class} #{predicted_class == actual_class ? '✓' : '✗'}"
          end
          
          puts "\n💡 This example shows:"
          puts "• Multi-class classification with softmax output"
          puts "• Cross-entropy loss for classification"
          puts "• How to interpret classification results"
        end
        
        def self.housing_regression_example
          puts "\n" + "="*50
          puts "EXAMPLE 2: Boston Housing Price Prediction"
          puts "="*50
          
          puts <<~DESCRIPTION
            Regression problem: Predict house prices based on features like:
            - Crime rate, room count, age of house
            - Distance to employment centers
            - Property tax rate, etc.
            
            This demonstrates regression with multiple features.
          DESCRIPTION
          
          # Generate synthetic housing data
          housing_data = generate_housing_data
          
          # Split and normalize data
          train_data = housing_data[0..399]
          test_data = housing_data[400..-1]
          
          # Normalize features
          train_data, test_data = normalize_datasets(train_data, test_data)
          
          config = NetworkConfiguration.new(
            activation_function: :relu,
            output_activation: :linear,
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.001 },
            loss_function: :mse,
            task_type: :regression,
            regularization: { l2: { lambda: 0.001 } },
            early_stopping: true,
            early_stopping_patience: 30,
            verbose: true,
            print_every: 100
          )
          
          # Multiple hidden layers for complex regression
          network = EnhancedNeuralNetwork.new([13, 64, 32, 16, 1], config)
          
          puts "\nTraining on housing data..."
          network.train(train_data, test_data, 500)
          
          # Evaluate
          test_loss, _ = network.evaluate(test_data)
          rmse = Math.sqrt(test_loss)
          
          puts "\nTest Results:"
          puts "RMSE: #{rmse.round(2)} (thousands of dollars)"
          puts "MSE Loss: #{test_loss.round(4)}"
          
          # Show some predictions
          puts "\nSample Predictions (in thousands):"
          test_data[0..4].each_with_index do |sample, i|
            input, target = sample
            prediction = network.forward(input, false)
            
            actual_price = target[0] * 50 + 20  # Denormalize
            predicted_price = prediction[0] * 50 + 20
            error = (predicted_price - actual_price).abs
            
            puts "Sample #{i+1}: Predicted $#{predicted_price.round(1)}k, Actual $#{actual_price.round(1)}k (Error: $#{error.round(1)}k)"
          end
          
          puts "\n💡 This example shows:"
          puts "• Regression with multiple features"
          puts "• Feature normalization importance"
          puts "• L2 regularization to prevent overfitting"
          puts "• Early stopping based on validation performance"
        end
        
        def self.digit_recognition_example
          puts "\n" + "="*50
          puts "EXAMPLE 3: Handwritten Digit Recognition"
          puts "="*50
          
          puts <<~DESCRIPTION
            Image classification: Recognize handwritten digits (0-9)
            Input: 28x28 pixel images (784 features)
            Output: 10 classes (digits 0-9)
            
            This demonstrates high-dimensional input processing.
          DESCRIPTION
          
          # Generate synthetic digit-like data
          digit_data = generate_digit_data
          
          train_data = digit_data[0..7999]
          test_data = digit_data[8000..-1]
          
          config = NetworkConfiguration.new(
            activation_function: :relu,
            output_activation: :softmax,
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.001 },
            loss_function: :cross_entropy,
            task_type: :classification,
            regularization: { dropout: { rate: 0.2 } },
            verbose: true,
            print_every: 50
          )
          
          # Deep network for image recognition
          network = EnhancedNeuralNetwork.new([784, 128, 64, 32, 10], config)
          
          puts "\nTraining on digit data..."
          puts "Note: This is computationally intensive..."
          network.train(train_data, test_data, 100)
          
          # Evaluate
          test_loss, test_accuracy = network.evaluate(test_data)
          puts "\nTest Results:"
          puts "Accuracy: #{(test_accuracy * 100).round(1)}%"
          puts "Loss: #{test_loss.round(4)}"
          
          puts "\n💡 This example shows:"
          puts "• High-dimensional input handling"
          puts "• Deep networks for complex pattern recognition"
          puts "• Dropout regularization for large networks"
          puts "• Scalability challenges with image data"
        end
        
        def self.time_series_example
          puts "\n" + "="*50
          puts "EXAMPLE 4: Time Series Prediction"
          puts "="*50
          
          puts <<~DESCRIPTION
            Predict future values based on historical data.
            We'll predict a sine wave with trend and noise.
            
            Input: Last 10 time steps
            Output: Next time step value
            
            This demonstrates sequence prediction.
          DESCRIPTION
          
          # Generate time series data
          series_data = generate_time_series_data
          
          train_data = series_data[0..799]
          test_data = series_data[800..-1]
          
          config = NetworkConfiguration.new(
            activation_function: :tanh,  # Good for time series
            output_activation: :linear,
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.001 },
            loss_function: :mse,
            task_type: :regression,
            regularization: { l2: { lambda: 0.0001 } },
            verbose: true,
            print_every: 100
          )
          
          # Network designed for sequence processing
          network = EnhancedNeuralNetwork.new([10, 20, 15, 1], config)
          
          puts "\nTraining on time series data..."
          network.train(train_data, test_data, 300)
          
          # Evaluate
          test_loss, _ = network.evaluate(test_data)
          puts "\nTest Results:"
          puts "MSE: #{test_loss.round(6)}"
          puts "RMSE: #{Math.sqrt(test_loss).round(4)}"
          
          # Show prediction accuracy
          puts "\nSample Predictions:"
          test_data[0..4].each_with_index do |sample, i|
            input, target = sample
            prediction = network.forward(input, false)
            
            error = (prediction[0] - target[0]).abs
            puts "Sample #{i+1}: Predicted #{prediction[0].round(4)}, Actual #{target[0].round(4)} (Error: #{error.round(4)})"
          end
          
          puts "\n💡 This example shows:"
          puts "• Sequential data processing"
          puts "• Tanh activation for bounded outputs"
          puts "• Time series forecasting challenges"
          puts "• How networks can learn temporal patterns"
        end
        
        private
        
        def self.generate_iris_data
          # Simplified iris-like data generation
          data = []
          
          # Class 0: Setosa-like
          50.times do
            features = [
              4.5 + rand * 1.0,  # Sepal length
              3.0 + rand * 0.6,  # Sepal width
              1.3 + rand * 0.3,  # Petal length
              0.2 + rand * 0.1   # Petal width
            ]
            target = [1, 0, 0]  # One-hot encoded
            data << [features, target]
          end
          
          # Class 1: Versicolor-like
          50.times do
            features = [
              5.5 + rand * 1.0,
              2.5 + rand * 0.6,
              3.8 + rand * 0.8,
              1.2 + rand * 0.3
            ]
            target = [0, 1, 0]
            data << [features, target]
          end
          
          # Class 2: Virginica-like
          50.times do
            features = [
              6.2 + rand * 1.0,
              2.8 + rand * 0.6,
              5.5 + rand * 0.8,
              2.0 + rand * 0.5
            ]
            target = [0, 0, 1]
            data << [features, target]
          end
          
          data.shuffle
        end
        
        def self.generate_housing_data
          data = []
          
          500.times do
            # Synthetic housing features
            crime_rate = rand * 0.8
            rooms = 4 + rand * 4
            age = rand * 100
            distance = rand * 10
            tax_rate = 200 + rand * 500
            
            # Synthetic price calculation
            price = 50 - crime_rate * 20 + rooms * 5 - age * 0.1 - distance * 2 + (rand - 0.5) * 10
            price = [price, 10].max  # Minimum price
            
            features = [
              crime_rate, rooms, age, distance, tax_rate,
              rand, rand, rand, rand, rand, rand, rand, rand  # Additional features
            ]
            
            # Normalize price to 0-1 range for training
            normalized_price = (price - 20) / 50.0
            
            data << [features, [normalized_price]]
          end
          
          data
        end
        
        def self.generate_digit_data
          data = []
          
          # Generate 10,000 samples (simplified digit-like patterns)
          10000.times do
            digit = rand(10)  # 0-9
            
            # Create 784-dimensional "image" (28x28 pixels)
            # Simplified: random pattern with digit-specific characteristics
            pixels = Array.new(784) { rand * 0.1 }  # Background noise
            
            # Add digit-specific pattern (very simplified)
            case digit
            when 0
              # Circle-like pattern
              center_pixels = [392, 393, 420, 421]  # Center area
              center_pixels.each { |i| pixels[i] = 0.1 + rand * 0.2 }
            when 1
              # Vertical line pattern
              (350..450).step(28).each { |i| pixels[i] = 0.8 + rand * 0.2 }
            else
              # Random distinctive pattern for other digits
              (digit * 10).times { |i| pixels[i * 7 % 784] = 0.6 + rand * 0.4 }
            end
            
            # One-hot encode target
            target = Array.new(10, 0)
            target[digit] = 1
            
            data << [pixels, target]
          end
          
          data.shuffle
        end
        
        def self.generate_time_series_data
          data = []
          
          # Generate 1000 time windows
          1000.times do |t|
            # Create sequence of 10 time steps
            sequence = []
            10.times do |i|
              time = (t + i) * 0.1
              value = Math.sin(time) + 0.1 * time + (rand - 0.5) * 0.1  # Sine + trend + noise
              sequence << value
            end
            
            # Target is the next value
            next_time = (t + 10) * 0.1
            target_value = Math.sin(next_time) + 0.1 * next_time
            
            data << [sequence, [target_value]]
          end
          
          data
        end
        
        def self.normalize_datasets(train_data, test_data)
          # Calculate mean and std from training data
          feature_count = train_data.first[0].length
          means = Array.new(feature_count, 0.0)
          stds = Array.new(feature_count, 0.0)
          
          # Calculate means
          train_data.each do |sample|
            sample[0].each_with_index { |val, i| means[i] += val }
          end
          means.map! { |sum| sum / train_data.length }
          
          # Calculate standard deviations
          train_data.each do |sample|
            sample[0].each_with_index { |val, i| stds[i] += (val - means[i])**2 }
          end
          stds.map! { |sum_sq| Math.sqrt(sum_sq / train_data.length) }
          
          # Normalize both datasets
          normalized_train = train_data.map do |sample|
            features, target = sample
            normalized_features = features.each_with_index.map do |val, i|
              stds[i] > 0 ? (val - means[i]) / stds[i] : 0
            end
            [normalized_features, target]
          end
          
          normalized_test = test_data.map do |sample|
            features, target = sample
            normalized_features = features.each_with_index.map do |val, i|
              stds[i] > 0 ? (val - means[i]) / stds[i] : 0
            end
            [normalized_features, target]
          end
          
          [normalized_train, normalized_test]
        end
      end
      
      # Interactive experimentation environment
      class InteractiveExperiments
        
        def self.run_experiment_playground
          puts "="*60
          puts "NEURAL NETWORK EXPERIMENT PLAYGROUND"
          puts "="*60
          
          puts <<~WELCOME
            Welcome to the interactive neural network playground!
            Here you can experiment with different configurations and
            immediately see the results.
            
            Available experiments:
            1. Architecture experiments
            2. Hyperparameter tuning
            3. Custom problem solving
            4. Debugging session
          WELCOME
          
          loop do
            puts "\nChoose an experiment:"
            puts "1. Architecture experiments"
            puts "2. Hyperparameter tuning"
            puts "3. Custom problem solving"
            puts "4. Debugging session"
            puts "5. Exit"
            
            print "Choice (1-5): "
            choice = gets.chomp.to_i
            
            case choice
            when 1
              architecture_experiments
            when 2
              hyperparameter_experiments
            when 3
              custom_problem_solver
            when 4
              debugging_session
            when 5
              break
            else
              puts "Invalid choice. Please try again."
            end
          end
        end
        
        private
        
        def self.architecture_experiments
          puts "\n=== Architecture Experiments ==="
          
          # Generate test data
          test_data = (0..100).map do |i|
            x = i / 100.0 * 4 - 2  # Range [-2, 2]
            y = x**2  # Parabola
            [[x], [y]]
          end
          
          train_data = test_data[0..79]
          val_data = test_data[80..-1]
          
          architectures = [
            [1, 1],           # Linear (no hidden layer)
            [1, 5, 1],        # Small hidden layer
            [1, 20, 1],       # Large hidden layer
            [1, 10, 10, 1],   # Two hidden layers
            [1, 15, 10, 5, 1] # Deep network
          ]
          
          puts "Testing different architectures on y = x² problem:"
          
          results = {}
          
          architectures.each do |arch|
            puts "\nTesting architecture: #{arch.join(' → ')}"
            
            config = NetworkConfiguration.new(
              activation_function: :relu,
              optimizer: :adam,
              optimizer_params: { learning_rate: 0.01 },
              loss_function: :mse,
              verbose: false
            )
            
            network = EnhancedNeuralNetwork.new(arch, config)
            network.train(train_data, val_data, 200)
            
            val_loss, _ = network.evaluate(val_data)
            params = network.send(:calculate_total_parameters)
            
            results[arch.join('-')] = {
              validation_loss: val_loss,
              parameters: params[:total],
              training_time: network.monitor.training_time
            }
            
            puts "  Validation loss: #{val_loss.round(6)}"
            puts "  Parameters: #{params[:total]}"
            puts "  Training time: #{network.monitor.training_time.round(3)}s"
          end
          
          # Analysis
          puts "\n=== Architecture Analysis ==="
          best_arch = results.min_by { |_, data| data[:validation_loss] }
          puts "Best architecture: #{best_arch[0]} (loss: #{best_arch[1][:validation_loss].round(6)})"
          
          puts "\nKey insights:"
          puts "• Too simple (linear): High bias, can't learn non-linear patterns"
          puts "• Too complex (deep): May overfit with limited data"
          puts "• Sweet spot: Enough capacity without overfitting"
        end
        
        def self.hyperparameter_experiments
          puts "\n=== Hyperparameter Tuning Experiments ==="
          
          # XOR data for quick experiments
          xor_data = [
            [[0, 0], [0]], [[0, 1], [1]], [[1, 0], [1]], [[1, 1], [0]]
          ]
          
          puts "Testing hyperparameter combinations on XOR problem:"
          
          param_grid = {
            learning_rate: [0.001, 0.01, 0.1],
            activation_function: [:sigmoid, :relu, :tanh],
            optimizer: [:sgd, :adam]
          }
          
          best_result = nil
          best_accuracy = 0
          
          param_grid[:learning_rate].each do |lr|
            param_grid[:activation_function].each do |activation|
              param_grid[:optimizer].each do |optimizer|
                
                config = NetworkConfiguration.new(
                  activation_function: activation,
                  optimizer: optimizer,
                  optimizer_params: { learning_rate: lr },
                  loss_function: :mse,
                  verbose: false
                )
                
                network = EnhancedNeuralNetwork.new([2, 8, 1], config)
                network.train(xor_data, nil, 1000)
                
                # Test accuracy
                correct = 0
                xor_data.each do |input, expected|
                  prediction = network.forward(input, false)
                  predicted_class = prediction[0] > 0.5 ? 1 : 0
                  correct += 1 if predicted_class == expected[0]
                end
                
                accuracy = correct.to_f / xor_data.length
                
                puts "LR: #{lr}, Activation: #{activation}, Optimizer: #{optimizer} → Accuracy: #{(accuracy * 100).round(1)}%"
                
                if accuracy > best_accuracy
                  best_accuracy = accuracy
                  best_result = { lr: lr, activation: activation, optimizer: optimizer }
                end
              end
            end
          end
          
          puts "\nBest combination:"
          puts "Learning rate: #{best_result[:lr]}"
          puts "Activation: #{best_result[:activation]}"
          puts "Optimizer: #{best_result[:optimizer]}"
          puts "Accuracy: #{(best_accuracy * 100).round(1)}%"
        end
        
        def self.custom_problem_solver
          puts "\n=== Custom Problem Solver ==="
          puts "Define your own problem and let the network solve it!"
          
          puts "\nPre-defined problems:"
          puts "1. Function approximation (y = sin(x))"
          puts "2. Classification (spiral data)"
          puts "3. Enter custom data"
          
          print "Choice (1-3): "
          choice = gets.chomp.to_i
          
          case choice
          when 1
            solve_sine_approximation
          when 2
            solve_spiral_classification
          when 3
            solve_custom_data
          end
        end
        
        def self.solve_sine_approximation
          puts "\nSolving: y = sin(x) approximation"
          
          # Generate sine data
          data = (0..100).map do |i|
            x = i / 100.0 * 2 * Math::PI
            y = Math.sin(x)
            [[x], [y]]
          end
          
          train_data = data[0..79]
          test_data = data[80..-1]
          
          config = NetworkConfiguration.new(
            activation_function: :tanh,  # Good for sine waves
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.01 },
            loss_function: :mse,
            interactive: true,  # Enable interactive mode
            verbose: true,
            print_every: 50
          )
          
          network = EnhancedNeuralNetwork.new([1, 16, 16, 1], config)
          network.train(train_data, test_data, 200)
          
          # Show some predictions
          puts "\nSample predictions:"
          test_data[0..4].each_with_index do |sample, i|
            input, target = sample
            prediction = network.forward(input, false)
            error = (prediction[0] - target[0]).abs
            
            puts "x=#{input[0].round(3)}: predicted=#{prediction[0].round(4)}, actual=#{target[0].round(4)}, error=#{error.round(4)}"
          end
        end
        
        def self.solve_spiral_classification
          puts "\nSolving: Spiral classification"
          
          # Generate spiral data
          data = []
          200.times do |i|
            t = i / 200.0 * 4 * Math::PI
            
            # Class 0: Inner spiral
            if i < 100
              r = t / (4 * Math::PI) * 2
              x = r * Math.cos(t) + (rand - 0.5) * 0.1
              y = r * Math.sin(t) + (rand - 0.5) * 0.1
              data << [[x, y], [1, 0]]
            else
              # Class 1: Outer spiral
              r = (t + Math::PI) / (4 * Math::PI) * 2
              x = r * Math.cos(t + Math::PI) + (rand - 0.5) * 0.1
              y = r * Math.sin(t + Math::PI) + (rand - 0.5) * 0.1
              data << [[x, y], [0, 1]]
            end
          end
          
          data.shuffle!
          train_data = data[0..159]
          test_data = data[160..-1]
          
          config = NetworkConfiguration.new(
            activation_function: :relu,
            output_activation: :softmax,
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.01 },
            loss_function: :cross_entropy,
            task_type: :classification,
            verbose: true,
            print_every: 100
          )
          
          network = EnhancedNeuralNetwork.new([2, 32, 16, 2], config)
          network.train(train_data, test_data, 500)
          
          test_loss, test_accuracy = network.evaluate(test_data)
          puts "\nSpiral classification accuracy: #{(test_accuracy * 100).round(1)}%"
        end
        
        def self.solve_custom_data
          puts "\nEnter your custom data:"
          puts "Format: input1,input2,...:output1,output2,..."
          puts "Example: 0,1:1 (for XOR-like data)"
          puts "Enter 'done' when finished"
          
          custom_data = []
          
          loop do
            print "Data point: "
            line = gets.chomp
            break if line.downcase == 'done'
            
            begin
              input_str, output_str = line.split(':')
              inputs = input_str.split(',').map(&:to_f)
              outputs = output_str.split(',').map(&:to_f)
              
              custom_data << [inputs, outputs]
              puts "Added: #{inputs} → #{outputs}"
            rescue
              puts "Invalid format. Try again."
            end
          end
          
          if custom_data.length < 2
            puts "Need at least 2 data points."
            return
          end
          
          puts "\nTraining network on your custom data..."
          
          input_size = custom_data.first[0].length
          output_size = custom_data.first[1].length
          
          config = NetworkConfiguration.new(
            activation_function: :relu,
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.01 },
            loss_function: output_size == 1 ? :mse : :cross_entropy,
            verbose: true
          )
          
          hidden_size = [8, input_size * 4].max
          network = EnhancedNeuralNetwork.new([input_size, hidden_size, output_size], config)
          network.train(custom_data, nil, 1000)
          
          puts "\nTesting on your data:"
          custom_data.each_with_index do |sample, i|
            input, target = sample
            prediction = network.forward(input, false)
            
            puts "#{i+1}. Input: #{input} → Predicted: #{prediction.map { |p| p.round(4) }}, Target: #{target}"
          end
        end
        
        def self.debugging_session
          puts "\n=== Neural Network Debugging Session ==="
          puts "Let's debug a problematic network together!"
          
          # Create a problem: network that doesn't train well
          problematic_data = [
            [[0, 0], [0]], [[0, 1], [1]], [[1, 0], [1]], [[1, 1], [0]]  # XOR
          ]
          
          # Bad configuration
          bad_config = NetworkConfiguration.new(
            activation_function: :linear,  # Bad: no non-linearity
            optimizer: :sgd,
            optimizer_params: { learning_rate: 10.0 },  # Bad: too high
            loss_function: :mse,
            verbose: true,
            print_every: 50
          )
          
          puts "Training a network with poor configuration..."
          bad_network = EnhancedNeuralNetwork.new([2, 4, 1], bad_config)
          bad_network.train(problematic_data, nil, 200)
          
          puts "\nEntering debug mode..."
          bad_network.debug_mode
          
          puts "\nNow let's fix the issues:"
          good_config = NetworkConfiguration.new(
            activation_function: :relu,  # Fixed: non-linear
            optimizer: :adam,
            optimizer_params: { learning_rate: 0.01 },  # Fixed: reasonable rate
            loss_function: :mse,
            verbose: true,
            print_every: 50
          )
          
          puts "Training with fixed configuration..."
          good_network = EnhancedNeuralNetwork.new([2, 8, 1], good_config)
          good_network.train(problematic_data, nil, 200)
          
          puts "\nComparison:"
          puts "Bad network final loss: #{bad_network.monitor.training_losses.last.round(6)}"
          puts "Good network final loss: #{good_network.monitor.training_losses.last.round(6)}"
          
          puts "\nDebugging lessons:"
          puts "• Linear activation = no non-linearity (can't solve XOR)"
          puts "• High learning rates cause instability"
          puts "• Debug mode helps identify issues"
          puts "• Modern optimizers (Adam) often work better"
        end
      end
    end
  end
end