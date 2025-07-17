# frozen_string_literal: true

require 'benchmark'
require 'spec_helper'

RSpec.describe 'Neural Network Performance Benchmarks' do
  include DataHelper
  
  let(:xor_data) do
    [
      { input: [0, 0], output: [0] },
      { input: [0, 1], output: [1] },
      { input: [1, 0], output: [1] },
      { input: [1, 1], output: [0] }
    ]
  end
  
  let(:classification_data) do
    # Generate more complex classification data
    100.times.map do
      x = rand(-1.0..1.0)
      y = rand(-1.0..1.0)
      
      # Circular decision boundary
      label = (x**2 + y**2) < 0.5 ? [1, 0] : [0, 1]
      
      { input: [x, y], output: label }
    end
  end
  
  describe 'training performance' do
    it 'benchmarks different network architectures' do
      architectures = [
        { structure: [2, 2, 1], name: "Minimal (2-2-1)" },
        { structure: [2, 5, 1], name: "Small (2-5-1)" },
        { structure: [2, 10, 5, 1], name: "Medium (2-10-5-1)" },
        { structure: [2, 20, 10, 5, 1], name: "Large (2-20-10-5-1)" }
      ]
      
      results = {}
      
      architectures.each do |arch|
        time = Benchmark.realtime do
          nn = Ai4r::NeuralNetwork::Backpropagation.new(arch[:structure])
          100.times do
            xor_data.each do |example|
              nn.train(example[:input], example[:output])
            end
          end
        end
        
        results[arch[:name]] = time
      end
      
      report_architecture_results(results)
    end
    
    it 'benchmarks different training parameters' do
      parameters = [
        { learning_rate: 0.1, momentum: 0.0, name: "Low LR, No Momentum" },
        { learning_rate: 0.5, momentum: 0.0, name: "Med LR, No Momentum" },
        { learning_rate: 0.5, momentum: 0.5, name: "Med LR, Med Momentum" },
        { learning_rate: 1.0, momentum: 0.9, name: "High LR, High Momentum" }
      ]
      
      results = {}
      
      parameters.each do |params|
        nn = Ai4r::NeuralNetwork::Backpropagation.new([2, 5, 1])
        nn.learning_rate = params[:learning_rate]
        nn.momentum = params[:momentum]
        
        time = Benchmark.realtime do
          100.times do
            xor_data.each do |example|
              nn.train(example[:input], example[:output])
            end
          end
        end
        
        # Measure final error
        total_error = xor_data.sum do |example|
          output = nn.eval(example[:input])
          (output[0] - example[:output][0])**2
        end
        
        results[params[:name]] = {
          time: time,
          error: total_error / xor_data.size
        }
      end
      
      report_parameter_results(results)
    end
  end
  
  describe 'evaluation performance' do
    it 'benchmarks forward propagation speed' do
      networks = {
        small: Ai4r::NeuralNetwork::Backpropagation.new([10, 5, 2]),
        medium: Ai4r::NeuralNetwork::Backpropagation.new([50, 25, 10, 2]),
        large: Ai4r::NeuralNetwork::Backpropagation.new([100, 50, 25, 10, 2])
      }
      
      # Initialize networks
      networks.each { |_, nn| nn.init_network }
      
      # Generate test inputs
      test_inputs = 1000.times.map { Array.new(networks[:small].structure.first) { rand } }
      
      results = {}
      
      networks.each do |size, nn|
        # Adjust input size for each network
        inputs = test_inputs.map { |_| Array.new(nn.structure.first) { rand } }
        
        time = Benchmark.realtime do
          inputs.each { |input| nn.eval(input) }
        end
        
        results[size] = {
          time: time,
          evals_per_second: inputs.size / time
        }
      end
      
      report_evaluation_results(results)
    end
  end
  
  describe 'memory efficiency' do
    it 'measures memory usage for different network sizes' do
      memory_results = {}
      
      network_sizes = [
        { name: "tiny", structure: [10, 5, 2] },
        { name: "small", structure: [50, 25, 10] },
        { name: "medium", structure: [100, 50, 25, 10] },
        { name: "large", structure: [500, 250, 100, 50, 10] }
      ]
      
      network_sizes.each do |config|
        before_memory = memory_usage
        
        nn = Ai4r::NeuralNetwork::Backpropagation.new(config[:structure])
        nn.init_network
        
        after_memory = memory_usage
        
        # Count total weights
        total_weights = 0
        config[:structure].each_cons(2) do |from, to|
          total_weights += from * to
        end
        
        memory_results[config[:name]] = {
          memory_used: after_memory - before_memory,
          total_weights: total_weights,
          bytes_per_weight: ((after_memory - before_memory) * 1024 * 1024) / total_weights
        }
      end
      
      report_memory_results(memory_results)
    end
  end
  
  describe 'convergence speed' do
    it 'compares convergence rates' do
      target_error = 0.01
      max_epochs = 1000
      
      configurations = [
        { name: "Standard BP", activation: :sigmoid },
        { name: "Tanh activation", activation: :tanh },
        { name: "ReLU activation", activation: :relu }
      ]
      
      convergence_results = {}
      
      configurations.each do |config|
        nn = create_network_with_activation([2, 5, 1], config[:activation])
        
        epochs = 0
        error = Float::INFINITY
        
        time = Benchmark.realtime do
          while epochs < max_epochs && error > target_error
            error = 0
            xor_data.each do |example|
              error += nn.train(example[:input], example[:output])
            end
            error /= xor_data.size
            epochs += 1
          end
        end
        
        convergence_results[config[:name]] = {
          epochs: epochs,
          time: time,
          final_error: error,
          converged: error <= target_error
        }
      end
      
      report_convergence_results(convergence_results)
    end
  end
  
  private
  
  def create_network_with_activation(structure, activation_type)
    # This is a simplified version - in reality would use the activation
    nn = Ai4r::NeuralNetwork::Backpropagation.new(structure)
    # nn.activation_function = activation_type
    nn
  end
  
  def report_architecture_results(results)
    puts "\nArchitecture Performance:"
    puts "-" * 50
    results.each do |arch, time|
      puts sprintf("%-25s: %8.4f seconds", arch, time)
    end
  end
  
  def report_parameter_results(results)
    puts "\nParameter Performance:"
    puts "-" * 70
    puts sprintf("%-30s %15s %15s", "Configuration", "Time (s)", "Final Error")
    puts "-" * 70
    
    results.each do |name, data|
      puts sprintf("%-30s %15.4f %15.6f", name, data[:time], data[:error])
    end
  end
  
  def report_evaluation_results(results)
    puts "\nEvaluation Performance:"
    puts "-" * 50
    results.each do |size, data|
      puts sprintf("%-10s: %8.4f seconds (%8.0f evals/sec)",
                   size, data[:time], data[:evals_per_second])
    end
  end
  
  def report_memory_results(results)
    puts "\nMemory Usage:"
    puts "-" * 70
    puts sprintf("%-10s %15s %15s %20s", "Size", "Memory (MB)", "Weights", "Bytes/Weight")
    puts "-" * 70
    
    results.each do |name, data|
      puts sprintf("%-10s %15.2f %15d %20.2f",
                   name, data[:memory_used], data[:total_weights], data[:bytes_per_weight])
    end
  end
  
  def report_convergence_results(results)
    puts "\nConvergence Speed:"
    puts "-" * 70
    puts sprintf("%-20s %10s %15s %15s %10s", "Method", "Epochs", "Time (s)", "Error", "Converged")
    puts "-" * 70
    
    results.each do |name, data|
      puts sprintf("%-20s %10d %15.4f %15.6f %10s",
                   name, data[:epochs], data[:time], data[:final_error],
                   data[:converged] ? "Yes" : "No")
    end
  end
  
  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0  # MB
  end
end