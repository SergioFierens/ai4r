# frozen_string_literal: true

# Educational examples for neural networks - demonstrating various use cases
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'educational_neural_network'

module Ai4r
  module NeuralNetwork
    
    # Collection of educational examples for neural networks
    class EducationalExamples
      
      # XOR Problem - Classic neural network example
      # Demonstrates non-linear problem solving with hidden layers
      def self.xor_problem(verbose: true, step_mode: false)
        puts "=== XOR Problem Neural Network ===" if verbose
        puts "Demonstrates learning non-linearly separable patterns" if verbose
        
        # XOR training data
        training_data = [
          [[0, 0], [0]],  # 0 XOR 0 = 0
          [[0, 1], [1]],  # 0 XOR 1 = 1
          [[1, 0], [1]],  # 1 XOR 0 = 1
          [[1, 1], [0]]   # 1 XOR 1 = 0
        ]
        
        # Create network: 2 inputs, 3 hidden neurons, 1 output
        network = EducationalNeuralNetwork.new(:backpropagation, [2, 3, 1], {
          learning_rate: 0.5,
          momentum: 0.2,
          verbose: verbose
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training XOR function..." if verbose
        network.train(training_data, 2000)
        
        puts "\nTesting XOR function:" if verbose
        training_data.each do |input, expected|
          result = network.eval(input)
          puts "#{input.inspect} XOR = #{result.first.round(3)} (expected: #{expected.first})" if verbose
        end
        
        network.visualize if verbose
        network
      end
      
      # Pattern Recognition - Simple digit recognition
      # Demonstrates pattern classification with noisy inputs
      def self.digit_recognition(verbose: true, step_mode: false)
        puts "\n=== Simple Digit Recognition ===" if verbose
        puts "Recognizing 3x3 pixel patterns for digits 0, 1, 2" if verbose
        
        # Simple 3x3 patterns for digits (flattened to 9 inputs)
        patterns = {
          0 => [
            [1, 1, 1, 1, 0, 1, 1, 1, 1],  # Perfect 0
            [1, 1, 0, 1, 0, 1, 0, 1, 1],  # Noisy 0
            [0, 1, 1, 1, 0, 1, 1, 1, 0]   # Another 0 variant
          ],
          1 => [
            [0, 1, 0, 0, 1, 0, 0, 1, 0],  # Perfect 1
            [0, 0, 1, 0, 1, 0, 0, 1, 0],  # Slight variant
            [0, 1, 0, 1, 1, 0, 0, 1, 0]   # Another 1
          ],
          2 => [
            [1, 1, 1, 0, 0, 1, 1, 1, 1],  # Perfect 2
            [1, 1, 0, 0, 1, 1, 1, 1, 1],  # Variant
            [1, 1, 1, 0, 1, 0, 1, 1, 1]   # Another 2
          ]
        }
        
        # Create training data with one-hot encoding
        training_data = []
        patterns.each do |digit, pattern_list|
          pattern_list.each do |pattern|
            output = [0, 0, 0]
            output[digit] = 1
            training_data << [pattern, output]
          end
        end
        
        # Create network: 9 inputs (3x3), 6 hidden, 3 outputs (digits 0,1,2)
        network = EducationalNeuralNetwork.new(:backpropagation, [9, 6, 3], {
          learning_rate: 0.3,
          momentum: 0.1,
          verbose: verbose
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training digit recognition..." if verbose
        network.train(training_data, 1000)
        
        puts "\nTesting digit recognition:" if verbose
        patterns.each do |digit, pattern_list|
          pattern_list.each_with_index do |pattern, i|
            result = network.eval(pattern)
            predicted_digit = result.index(result.max)
            confidence = result.max
            puts "Pattern #{digit}-#{i}: Predicted #{predicted_digit} (confidence: #{confidence.round(3)})" if verbose
          end
        end
        
        # Test with noisy input
        if verbose
          puts "\nTesting with very noisy digit 1:"
          noisy_1 = [1, 1, 0, 0, 1, 1, 0, 1, 1]  # Very noisy 1
          result = network.eval(noisy_1)
          predicted = result.index(result.max)
          puts "Noisy input: Predicted #{predicted} (confidence: #{result.max.round(3)})"
        end
        
        network.visualize if verbose
        network
      end
      
      # Function Approximation - Learning a mathematical function
      # Demonstrates regression capabilities
      def self.function_approximation(verbose: true, step_mode: false)
        puts "\n=== Function Approximation ===" if verbose
        puts "Learning to approximate f(x) = sin(x) + 0.5*cos(2x)" if verbose
        
        # Generate training data
        training_data = []
        (0..50).each do |i|
          x = i * 0.1  # x from 0 to 5
          y = Math.sin(x) + 0.5 * Math.cos(2 * x)
          training_data << [[x], [y]]
        end
        
        # Normalize inputs and outputs
        x_values = training_data.map { |input, _| input.first }
        y_values = training_data.map { |_, output| output.first }
        
        x_min, x_max = x_values.minmax
        y_min, y_max = y_values.minmax
        
        normalized_data = training_data.map do |input, output|
          norm_x = (input.first - x_min) / (x_max - x_min)
          norm_y = (output.first - y_min) / (y_max - y_min)
          [[norm_x], [norm_y]]
        end
        
        # Create network: 1 input, 8 hidden neurons, 1 output
        network = EducationalNeuralNetwork.new(:backpropagation, [1, 8, 1], {
          learning_rate: 0.1,
          momentum: 0.05,
          activation_function: :tanh,
          verbose: verbose
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training function approximation..." if verbose
        network.train(normalized_data, 2000)
        
        if verbose
          puts "\nTesting function approximation:"
          puts "Input    | Expected | Predicted | Error"
          puts "---------|----------|-----------|-------"
          
          test_points = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0]
          test_points.each do |x|
            expected = Math.sin(x) + 0.5 * Math.cos(2 * x)
            
            # Normalize input
            norm_x = (x - x_min) / (x_max - x_min)
            norm_result = network.eval([norm_x]).first
            
            # Denormalize output
            predicted = norm_result * (y_max - y_min) + y_min
            error = (expected - predicted).abs
            
            puts sprintf("%8.2f | %8.3f | %9.3f | %5.3f", x, expected, predicted, error)
          end
        end
        
        network.visualize if verbose
        network
      end
      
      # Hopfield Pattern Completion
      # Demonstrates associative memory capabilities
      def self.hopfield_memory(verbose: true, step_mode: false)
        puts "\n=== Hopfield Associative Memory ===" if verbose
        puts "Storing and recalling binary patterns" if verbose
        
        # Define some 5x5 binary patterns (flattened)
        patterns = [
          # Letter "T"
          [1, 1, 1, 1, 1,
           0, 0, 1, 0, 0,
           0, 0, 1, 0, 0,
           0, 0, 1, 0, 0,
           0, 0, 1, 0, 0],
          
          # Letter "L"  
          [1, 0, 0, 0, 0,
           1, 0, 0, 0, 0,
           1, 0, 0, 0, 0,
           1, 0, 0, 0, 0,
           1, 1, 1, 1, 1],
          
          # Letter "O"
          [0, 1, 1, 1, 0,
           1, 0, 0, 0, 1,
           1, 0, 0, 0, 1,
           1, 0, 0, 0, 1,
           0, 1, 1, 1, 0]
        ]
        
        # Convert to bipolar (-1, 1) representation
        bipolar_patterns = patterns.map do |pattern|
          pattern.map { |bit| bit == 1 ? 1 : -1 }
        end
        
        # Create Hopfield network
        network = EducationalNeuralNetwork.new(:hopfield, [25], {
          verbose: verbose,
          max_iterations: 100
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training Hopfield network with #{bipolar_patterns.length} patterns..." if verbose
        network.train(bipolar_patterns)
        
        if verbose
          puts "\nTesting pattern recall:"
          
          # Test perfect patterns
          bipolar_patterns.each_with_index do |pattern, i|
            result = network.eval(pattern)
            similarity = calculate_pattern_similarity(pattern, result)
            puts "Perfect pattern #{i}: Similarity = #{similarity.round(3)}"
          end
          
          # Test noisy patterns
          puts "\nTesting noisy pattern recall:"
          bipolar_patterns.each_with_index do |pattern, i|
            # Add noise (flip some bits)
            noisy_pattern = pattern.dup
            noise_indices = (0...pattern.length).to_a.sample(5)  # Flip 5 random bits
            noise_indices.each { |idx| noisy_pattern[idx] *= -1 }
            
            result = network.eval(noisy_pattern)
            original_similarity = calculate_pattern_similarity(noisy_pattern, pattern)
            recovered_similarity = calculate_pattern_similarity(result, pattern)
            
            puts "Noisy pattern #{i}: Original similarity = #{original_similarity.round(3)}, " +
                 "Recovered similarity = #{recovered_similarity.round(3)}"
          end
        end
        
        network.visualize if verbose
        network
      end
      
      # Multi-class Classification
      # Demonstrates classification with multiple categories
      def self.iris_classification(verbose: true, step_mode: false)
        puts "\n=== Iris Flower Classification ===" if verbose
        puts "Classifying iris flowers based on measurements" if verbose
        
        # Simplified iris dataset (sepal length, sepal width, petal length, petal width)
        training_data = [
          # Setosa (class 0)
          [[5.1, 3.5, 1.4, 0.2], [1, 0, 0]],
          [[4.9, 3.0, 1.4, 0.2], [1, 0, 0]],
          [[4.7, 3.2, 1.3, 0.2], [1, 0, 0]],
          [[5.4, 3.9, 1.7, 0.4], [1, 0, 0]],
          [[5.0, 3.6, 1.4, 0.2], [1, 0, 0]],
          
          # Versicolor (class 1)
          [[7.0, 3.2, 4.7, 1.4], [0, 1, 0]],
          [[6.4, 3.2, 4.5, 1.5], [0, 1, 0]],
          [[6.9, 3.1, 4.9, 1.5], [0, 1, 0]],
          [[5.5, 2.3, 4.0, 1.3], [0, 1, 0]],
          [[6.5, 2.8, 4.6, 1.5], [0, 1, 0]],
          
          # Virginica (class 2)
          [[6.3, 3.3, 6.0, 2.5], [0, 0, 1]],
          [[5.8, 2.7, 5.1, 1.9], [0, 0, 1]],
          [[7.1, 3.0, 5.9, 2.1], [0, 0, 1]],
          [[6.3, 2.9, 5.6, 1.8], [0, 0, 1]],
          [[6.5, 3.0, 5.8, 2.2], [0, 0, 1]]
        ]
        
        # Normalize input features
        inputs = training_data.map { |input, _| input }
        4.times do |feature|
          values = inputs.map { |input| input[feature] }
          min_val, max_val = values.minmax
          range = max_val - min_val
          
          training_data.each do |input, output|
            input[feature] = (input[feature] - min_val) / range
          end
        end
        
        # Create network: 4 inputs, 6 hidden, 3 outputs
        network = EducationalNeuralNetwork.new(:backpropagation, [4, 6, 3], {
          learning_rate: 0.2,
          momentum: 0.1,
          verbose: verbose
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training iris classification..." if verbose
        network.train(training_data, 1500)
        
        if verbose
          puts "\nTesting classification accuracy:"
          correct = 0
          total = training_data.length
          
          class_names = ["Setosa", "Versicolor", "Virginica"]
          
          training_data.each_with_index do |(input, expected), i|
            result = network.eval(input)
            predicted_class = result.index(result.max)
            expected_class = expected.index(expected.max)
            
            is_correct = predicted_class == expected_class
            correct += 1 if is_correct
            
            puts "Sample #{i+1}: #{class_names[expected_class]} -> " +
                 "#{class_names[predicted_class]} " +
                 "(confidence: #{result.max.round(3)}) " +
                 "#{is_correct ? '✓' : '✗'}"
          end
          
          accuracy = (correct.to_f / total * 100).round(1)
          puts "\nAccuracy: #{correct}/#{total} (#{accuracy}%)"
        end
        
        network.visualize if verbose
        network
      end
      
      # Time Series Prediction
      # Demonstrates sequence learning
      def self.time_series_prediction(verbose: true, step_mode: false)
        puts "\n=== Time Series Prediction ===" if verbose
        puts "Predicting next value in a sine wave sequence" if verbose
        
        # Generate sine wave data
        sequence_length = 5
        training_data = []
        
        (0..100).each do |i|
          t = i * 0.1
          # Create input sequence of 5 values
          input_sequence = []
          sequence_length.times do |j|
            val = Math.sin(t + j * 0.1) + 0.1 * Math.sin(3 * (t + j * 0.1))
            input_sequence << val
          end
          
          # Target is the next value in sequence
          target = Math.sin(t + sequence_length * 0.1) + 0.1 * Math.sin(3 * (t + sequence_length * 0.1))
          training_data << [input_sequence, [target]]
        end
        
        # Normalize data
        all_values = training_data.flat_map { |input, output| input + output }
        min_val, max_val = all_values.minmax
        range = max_val - min_val
        
        normalized_data = training_data.map do |input, output|
          norm_input = input.map { |x| (x - min_val) / range }
          norm_output = output.map { |x| (x - min_val) / range }
          [norm_input, norm_output]
        end
        
        # Create network: 5 inputs (sequence), 8 hidden, 1 output (prediction)
        network = EducationalNeuralNetwork.new(:backpropagation, [5, 8, 1], {
          learning_rate: 0.05,
          momentum: 0.02,
          activation_function: :tanh,
          verbose: verbose
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training time series prediction..." if verbose
        network.train(normalized_data, 1000)
        
        if verbose
          puts "\nTesting prediction accuracy:"
          puts "Input Sequence                    | Expected | Predicted | Error"
          puts "----------------------------------|----------|-----------|-------"
          
          test_samples = normalized_data.sample(5)
          test_samples.each do |input, expected|
            result = network.eval(input)
            
            # Denormalize for display
            denorm_input = input.map { |x| x * range + min_val }
            denorm_expected = expected.first * range + min_val
            denorm_predicted = result.first * range + min_val
            
            error = (denorm_expected - denorm_predicted).abs
            
            input_str = denorm_input.map { |x| sprintf("%.2f", x) }.join(", ")
            puts sprintf("%-33s | %8.3f | %9.3f | %5.3f", 
                        "[#{input_str}]", denorm_expected, denorm_predicted, error)
          end
        end
        
        network.visualize if verbose
        network
      end
      
      # Autoencoder - Dimensionality reduction
      # Demonstrates compression and reconstruction
      def self.autoencoder_compression(verbose: true, step_mode: false)
        puts "\n=== Autoencoder for Data Compression ===" if verbose
        puts "Learning to compress and reconstruct 8-bit patterns" if verbose
        
        # Generate 8-bit binary patterns
        patterns = []
        32.times do
          pattern = 8.times.map { rand(2) }
          patterns << pattern
        end
        
        # For autoencoder, input and output are the same
        training_data = patterns.map { |pattern| [pattern, pattern] }
        
        # Create autoencoder: 8 inputs -> 3 hidden (compression) -> 8 outputs
        # The bottleneck layer forces the network to learn a compressed representation
        network = EducationalNeuralNetwork.new(:backpropagation, [8, 3, 8], {
          learning_rate: 0.3,
          momentum: 0.1,
          verbose: verbose
        })
        
        network.enable_step_mode if step_mode
        network.enable_visualization if verbose
        
        puts "Training autoencoder..." if verbose
        network.train(training_data, 2000)
        
        if verbose
          puts "\nTesting compression and reconstruction:"
          puts "Original    | Reconstructed | Similarity"
          puts "------------|---------------|----------"
          
          test_patterns = patterns.sample(8)
          test_patterns.each do |pattern|
            result = network.eval(pattern)
            
            # Convert continuous outputs back to binary
            reconstructed = result.map { |x| x > 0.5 ? 1 : 0 }
            similarity = calculate_pattern_similarity(pattern, reconstructed)
            
            original_str = pattern.join("")
            reconstructed_str = reconstructed.join("")
            
            puts sprintf("%-11s | %-13s | %8.3f", original_str, reconstructed_str, similarity)
          end
          
          puts "\nNote: The 3-neuron hidden layer creates a compressed representation"
          puts "of the 8-bit input, forcing the network to learn essential features."
        end
        
        network.visualize if verbose
        network
      end
      
      private
      
      # Calculate similarity between two binary patterns
      def self.calculate_pattern_similarity(pattern1, pattern2)
        return 0.0 if pattern1.length != pattern2.length
        matches = pattern1.zip(pattern2).count { |a, b| a == b }
        matches.to_f / pattern1.length
      end
    end
    
    # Interactive tutorial runner
    class NeuralNetworkTutorial
      
      def self.run_all_examples(step_mode: false)
        puts "=== AI4R Neural Network Educational Examples ==="
        puts "This tutorial demonstrates various neural network applications."
        puts "Each example shows different capabilities and use cases.\n"
        
        examples = [
          -> { EducationalExamples.xor_problem(verbose: true, step_mode: step_mode) },
          -> { EducationalExamples.digit_recognition(verbose: true, step_mode: step_mode) },
          -> { EducationalExamples.function_approximation(verbose: true, step_mode: step_mode) },
          -> { EducationalExamples.hopfield_memory(verbose: true, step_mode: step_mode) },
          -> { EducationalExamples.iris_classification(verbose: true, step_mode: step_mode) },
          -> { EducationalExamples.time_series_prediction(verbose: true, step_mode: step_mode) },
          -> { EducationalExamples.autoencoder_compression(verbose: true, step_mode: step_mode) }
        ]
        
        examples.each_with_index do |example, index|
          puts "\n" + "="*60
          puts "Example #{index + 1} of #{examples.length}"
          puts "="*60
          
          example.call
          
          if step_mode && index < examples.length - 1
            puts "\nPress Enter to continue to the next example..."
            gets
          end
        end
        
        puts "\n" + "="*60
        puts "Tutorial completed! You've seen examples of:"
        puts "• Pattern classification (XOR, digits, iris)"
        puts "• Function approximation (sine wave)"
        puts "• Associative memory (Hopfield)"
        puts "• Time series prediction"
        puts "• Data compression (autoencoder)"
        puts "="*60
      end
      
      def self.run_quick_demo
        puts "=== Quick Neural Network Demo ==="
        
        # Run just the XOR problem as a quick demonstration
        network = EducationalExamples.xor_problem(verbose: true, step_mode: false)
        
        puts "\nThis was a quick demo of the XOR problem."
        puts "For more examples, run: NeuralNetworkTutorial.run_all_examples"
        puts "For step-by-step mode: NeuralNetworkTutorial.run_all_examples(step_mode: true)"
        
        network
      end
    end
  end
end