# frozen_string_literal: true

# Educational neural network framework designed for students and teachers
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'backpropagation'
require_relative 'hopfield'
require_relative '../data/parameterizable'

module Ai4r
  module NeuralNetwork
    # Educational neural network framework designed for students and teachers
    # to understand, experiment with, and visualize neural networks
    class EducationalNeuralNetwork
      attr_reader :network, :monitor, :configuration, :training_history, :network_info

      def initialize(network_type = :backpropagation, structure = [2, 3, 1], config = {})
        @network_type = network_type
        @structure = structure
        @configuration = NeuralNetworkConfiguration.new(config)
        @monitor = NeuralNetworkMonitor.new
        @training_history = []
        @network_info = {}
        @step_mode = false
        @visualization_enabled = false

        # Initialize the specific network
        @network = create_network(network_type, structure)
      end

      # Enable step-by-step execution for educational purposes
      def enable_step_mode
        @step_mode = true
        self
      end

      # Enable visualization output
      def enable_visualization
        @visualization_enabled = true
        self
      end

      # Configure network parameters with educational explanations
      def configure(params)
        @configuration.update(params)
        @configuration.explain_changes if @configuration.verbose
        self
      end

      # Train the network with educational features
      def train(training_data, epochs = 1000)
        @training_data = training_data
        @monitor.start_training(training_data, epochs)

        puts "Starting #{@network_type} training..." if @configuration.verbose
        puts "Training data: #{training_data.length} examples" if @configuration.verbose
        puts "Network structure: #{@structure.join(' → ')}" if @configuration.verbose

        if @step_mode
          train_step_by_step(training_data, epochs)
        else
          train_normal(training_data, epochs)
        end

        @monitor.finish_training(@network)
        collect_network_info
        self
      end

      # Evaluate input with detailed explanation
      def eval(input, explain = false)
        return nil unless @network

        if explain && @configuration.explain_predictions
          explain_prediction(input)
        else
          @network.eval(input)
        end
      end

      # Get network structure information
      def get_network_structure
        case @network_type
        when :backpropagation
          {
            type: 'Multilayer Perceptron',
            layers: @structure.length,
            neurons_per_layer: @structure,
            total_neurons: @structure.sum,
            total_weights: calculate_total_weights,
            activation_function: @configuration.activation_function_name
          }
        when :hopfield
          {
            type: 'Hopfield Network',
            neurons: @network.nodes.length,
            total_weights: @network.nodes.length * (@network.nodes.length - 1) / 2,
            patterns_stored: @network_info[:patterns_stored] || 0
          }
        end
      end

      # Visualize network structure and performance
      def visualize
        NeuralNetworkVisualizer.new(@network, @network_info, @training_history, @configuration).visualize
      end

      # Export network and training data
      def export_network(filename)
        NeuralNetworkExporter.new(@network, @network_info, @training_history).export(filename)
      end

      # Analyze network weights and patterns
      def analyze_weights
        NeuralNetworkAnalyzer.new(@network, @structure, @configuration).analyze
      end

      private

      def create_network(network_type, structure)
        case network_type
        when :backpropagation
          EducationalBackpropagation.new(structure, @configuration, @monitor)
        when :hopfield
          EducationalHopfield.new(@configuration, @monitor)
        else
          raise ArgumentError, "Unknown network type: #{network_type}"
        end
      end

      def train_step_by_step(training_data, epochs)
        puts "\n=== Step-by-step neural network training ===" if @configuration.verbose

        @network.train_with_steps(training_data, epochs) do |step_info|
          @training_history << step_info

          if @configuration.verbose
            puts "\nEpoch #{step_info[:epoch]}/#{epochs}: #{step_info[:description]}"
            puts "  Error: #{step_info[:error].round(6)}" if step_info[:error]
            puts "  #{step_info[:details]}" if step_info[:details]
          end

          visualize_step(step_info) if @visualization_enabled

          if @step_mode && step_info[:epoch] % 10 == 0
            puts 'Press Enter to continue...'
            gets
          end
        end
      end

      def train_normal(training_data, epochs)
        if @network_type == :backpropagation
          epochs.times do |epoch|
            total_error = 0

            training_data.each do |example|
              input, target = example
              error = @network.train(input, target)
              total_error += error
            end

            avg_error = total_error / training_data.length
            @monitor.record_epoch(epoch, avg_error)

            if @configuration.verbose && (epoch % 100 == 0 || epoch == epochs - 1)
              puts "Epoch #{epoch}: Average Error = #{avg_error.round(6)}"
            end
          end
        elsif @network_type == :hopfield
          patterns = training_data.map { |example| example.is_a?(Array) ? example.first : example }
          @network.train_patterns(patterns)
        end
      end

      def explain_prediction(input)
        case @network_type
        when :backpropagation
          explain_backpropagation_prediction(input)
        when :hopfield
          explain_hopfield_prediction(input)
        end
      end

      def explain_backpropagation_prediction(input)
        output = @network.eval(input)

        if @configuration.verbose
          puts "\nBackpropagation Prediction Explanation:"
          puts "Input: #{input.inspect}"
          puts "Network structure: #{@structure.join(' → ')}"

          # Show activation values at each layer
          activations = @network.get_layer_activations(input)
          activations.each_with_index do |layer_activations, layer_index|
            puts "Layer #{layer_index} activations: #{layer_activations.map { |a| a.round(4) }.inspect}"
          end

          puts "Final output: #{output.map { |o| o.round(4) }.inspect}"
        end

        output
      end

      def explain_hopfield_prediction(input)
        output = @network.eval(input)

        if @configuration.verbose
          puts "\nHopfield Network Prediction Explanation:"
          puts "Input pattern: #{input.inspect}"
          puts "Converged to: #{output.inspect}"

          # Calculate energy
          energy = @network.calculate_energy(output)
          puts "Final energy: #{energy.round(4)}"
        end

        output
      end

      def collect_network_info
        @network_info = {
          network_type: @network_type,
          structure: @structure,
          training_examples: @training_data&.length || 0,
          training_time: @monitor.training_time,
          final_error: @monitor.final_error,
          convergence_achieved: @monitor.convergence_achieved?,
          total_weights: calculate_total_weights
        }

        @network_info[:patterns_stored] = @training_data&.length || 0 if @network_type == :hopfield
      end

      def calculate_total_weights
        case @network_type
        when :backpropagation
          total = 0
          (0...(@structure.length - 1)).each do |i|
            input_size = @structure[i]
            output_size = @structure[i + 1]
            # Add bias weights if not disabled
            input_size += 1 unless @configuration.disable_bias
            total += input_size * output_size
          end
          total
        when :hopfield
          n = @structure.first || @network.nodes.length
          n * (n - 1) / 2 # Symmetric matrix without diagonal
        else
          0
        end
      end

      def visualize_step(step_info)
        NeuralNetworkVisualizer.new(@network, @network_info, @training_history,
                                    @configuration).visualize_step(step_info)
      end
    end

    # Configuration class for neural network parameters
    class NeuralNetworkConfiguration
      attr_accessor :learning_rate, :momentum, :activation_function_name, :disable_bias, :verbose,
                    :explain_predictions, :convergence_threshold, :max_iterations, :weight_initialization

      def initialize(params = {})
        # Default parameters
        @learning_rate = params[:learning_rate] || 0.25
        @momentum = params[:momentum] || 0.1
        @activation_function_name = params[:activation_function] || :sigmoid
        @disable_bias = params[:disable_bias] || false
        @verbose = params[:verbose] || false
        @explain_predictions = params[:explain_predictions] || false
        @convergence_threshold = params[:convergence_threshold] || 0.001
        @max_iterations = params[:max_iterations] || 1000
        @weight_initialization = params[:weight_initialization] || :random

        @explanations = {}
      end

      def update(params)
        params.each do |key, value|
          next unless respond_to?("#{key}=")

          old_value = send(key)
          send("#{key}=", value)
          @explanations[key] = explain_parameter_change(key, old_value, value)
        end
      end

      def explain_changes
        @explanations.each do |param, explanation|
          puts "#{param}: #{explanation}"
        end
        @explanations.clear
      end

      def explain_all_parameters
        puts "\n=== Neural Network Parameters Explanation ==="
        puts "learning_rate: Controls how fast the network learns (current: #{@learning_rate})"
        puts "momentum: Helps avoid local minima by using previous weight changes (current: #{@momentum})"
        puts "activation_function: Function used in neurons (current: #{@activation_function_name})"
        puts "disable_bias: Whether to use bias neurons (current: #{@disable_bias})"
        puts "convergence_threshold: Error threshold for stopping training (current: #{@convergence_threshold})"
        puts "max_iterations: Maximum training epochs (current: #{@max_iterations})"
        puts "weight_initialization: How to initialize weights (current: #{@weight_initialization})"
      end

      private

      def explain_parameter_change(param, old_value, new_value)
        case param
        when :learning_rate
          "Learning rate changed from #{old_value} to #{new_value} - affects training speed and stability"
        when :momentum
          "Momentum changed from #{old_value} to #{new_value} - affects convergence behavior"
        when :activation_function_name
          "Activation function changed from #{old_value} to #{new_value} - affects network capability"
        when :disable_bias
          "Bias #{new_value ? 'disabled' : 'enabled'} - affects network expressiveness"
        else
          "Changed #{param} from #{old_value} to #{new_value}"
        end
      end
    end

    # Monitoring class for tracking neural network training
    class NeuralNetworkMonitor
      attr_reader :start_time, :training_time, :error_history, :epoch_data, :final_error

      def initialize
        @error_history = []
        @epoch_data = []
        @convergence_achieved = false
      end

      def start_training(training_data, epochs)
        @start_time = Time.now
        @training_data = training_data
        @total_epochs = epochs
        @error_history.clear
        @epoch_data.clear
        @convergence_achieved = false
      end

      def record_epoch(epoch, error, additional_data = {})
        @error_history << error

        epoch_info = {
          epoch: epoch,
          error: error,
          timestamp: Time.now
        }.merge(additional_data)

        @epoch_data << epoch_info

        # Check for convergence
        if error < 0.001 && !@convergence_achieved
          @convergence_achieved = true
          @convergence_epoch = epoch
        end

        epoch_info
      end

      def finish_training(network)
        @end_time = Time.now
        @training_time = @end_time - @start_time
        @final_network = network
        @final_error = @error_history.last || Float::INFINITY
      end

      def convergence_achieved?
        @convergence_achieved
      end

      def summary
        return 'Training not completed' unless @training_time

        {
          training_time: @training_time,
          total_epochs: @epoch_data.length,
          final_error: @final_error,
          convergence_achieved: @convergence_achieved,
          convergence_epoch: @convergence_epoch,
          error_reduction: calculate_error_reduction
        }
      end

      def plot_error_curve
        return 'No error data available' if @error_history.empty?

        puts "\n=== Training Error Curve ==="
        puts 'Epoch | Error'
        puts '------|------'

        # Sample points for plotting
        sample_indices = if @error_history.length > 20
                           step = @error_history.length / 20
                           (0...@error_history.length).step(step).to_a
                         else
                           (0...@error_history.length).to_a
                         end

        max_error = @error_history.max
        sample_indices.each do |i|
          error = @error_history[i]
          bar_length = max_error > 0 ? [(error / max_error * 30).to_i, 1].max : 1
          bar = '█' * bar_length
          puts format('%5d | %s %.6f', i, bar, error)
        end

        puts "\nFinal error: #{@final_error.round(6)}"
        puts "Convergence: #{@convergence_achieved ? 'Yes' : 'No'}"
      end

      private

      def calculate_error_reduction
        return 0 if @error_history.length < 2

        initial_error = @error_history.first
        final_error = @error_history.last

        return 0 if initial_error == 0

        ((initial_error - final_error) / initial_error * 100).round(2)
      end
    end

    # Enhanced Backpropagation with educational features
    class EducationalBackpropagation < Backpropagation
      def initialize(structure, configuration, monitor)
        super(structure)
        @configuration = configuration
        @monitor = monitor

        # Apply configuration
        self.learning_rate = @configuration.learning_rate
        self.momentum = @configuration.momentum
        self.disable_bias = @configuration.disable_bias

        # Set activation function
        set_activation_function(@configuration.activation_function_name)
      end

      def train_with_steps(training_data, epochs)
        init_network

        epochs.times do |epoch|
          total_error = 0
          weight_changes = []

          training_data.each_with_index do |(input, target), example_index|
            error = train(input, target)
            total_error += error

            # Record weight changes for first few examples
            weight_changes << capture_weight_snapshot if example_index < 3 && epoch % 100 == 0
          end

          avg_error = total_error / training_data.length

          # Record epoch data
          @monitor.record_epoch(epoch, avg_error, {
                                  weight_changes: weight_changes,
                                  learning_rate: @configuration.learning_rate,
                                  momentum: @configuration.momentum
                                })

          # Yield step information
          yield({
            epoch: epoch,
            description: 'Forward pass and backpropagation complete',
            error: avg_error,
            details: "Processed #{training_data.length} training examples",
            weight_changes: weight_changes,
            convergence_check: avg_error < @configuration.convergence_threshold
          })

          # Early stopping if converged
          break if avg_error < @configuration.convergence_threshold
        end
      end

      def get_layer_activations(input)
        self.eval(input) # This populates @activation_nodes
        @activation_nodes.map(&:dup)
      end

      def get_weight_matrix(layer_index)
        return nil unless @weights && layer_index < @weights.length

        @weights[layer_index].map(&:dup)
      end

      def get_network_complexity
        {
          total_neurons: @structure.sum,
          total_weights: calculate_total_weights,
          layers: @structure.length,
          parameters: calculate_total_weights + @structure.sum # weights + biases
        }
      end

      private

      def set_activation_function(function_name)
        case function_name
        when :sigmoid
          @propagation_function = ->(x) { 1.0 / (1.0 + Math.exp(-x)) }
          @derivative_propagation_function = ->(y) { y * (1.0 - y) }
        when :tanh
          @propagation_function = ->(x) { Math.tanh(x) }
          @derivative_propagation_function = ->(y) { 1.0 - (y**2) }
        when :relu
          @propagation_function = ->(x) { [0, x].max }
          @derivative_propagation_function = ->(y) { y > 0 ? 1.0 : 0.0 }
        when :linear
          @propagation_function = ->(x) { x }
          @derivative_propagation_function = ->(_y) { 1.0 }
        else
          # Default to sigmoid
          @propagation_function = ->(x) { 1.0 / (1.0 + Math.exp(-x)) }
          @derivative_propagation_function = ->(y) { y * (1.0 - y) }
        end
      end

      def capture_weight_snapshot
        return nil unless @weights

        {
          layer_0: @weights[0] ? @weights[0].flatten.dup : [],
          layer_1: @weights[1] ? @weights[1].flatten.dup : [],
          timestamp: Time.now
        }
      end

      def calculate_total_weights
        return 0 unless @weights

        @weights.sum { |layer| layer.sum(&:length) }
      end
    end

    # Enhanced Hopfield with educational features
    class EducationalHopfield < Hopfield
      def initialize(configuration, monitor)
        super()
        @configuration = configuration
        @monitor = monitor
      end

      def train_patterns(patterns)
        # Create data set from patterns
        require_relative '../data/data_set'
        data_set = Ai4r::Data::DataSet.new(data_items: patterns)

        train(data_set)

        # Record training information
        @monitor.record_epoch(0, 0, {
                                patterns_stored: patterns.length,
                                pattern_length: patterns.first&.length || 0,
                                storage_capacity: calculate_storage_capacity(patterns.first&.length || 0)
                              })
      end

      def calculate_energy(pattern)
        return 0 if pattern.nil? || @weights.nil?

        energy = 0
        pattern.each_with_index do |xi, i|
          pattern.each_with_index do |xj, j|
            next if i == j

            energy -= 0.5 * read_weight(i, j) * xi * xj
          end
        end
        energy
      end

      def get_pattern_similarities(test_pattern, stored_patterns)
        similarities = []

        stored_patterns.each_with_index do |pattern, index|
          similarity = calculate_pattern_similarity(test_pattern, pattern)
          similarities << {
            pattern_index: index,
            pattern: pattern,
            similarity: similarity
          }
        end

        similarities.sort_by { |s| -s[:similarity] }
      end

      def explain_convergence(input_pattern)
        convergence_steps = []
        current_pattern = input_pattern.dup

        20.times do |step|
          energy = calculate_energy(current_pattern)
          convergence_steps << {
            step: step,
            pattern: current_pattern.dup,
            energy: energy
          }

          old_pattern = current_pattern.dup
          current_pattern = run(current_pattern)

          # Check for convergence
          break if current_pattern == old_pattern
        end

        convergence_steps
      end

      private

      def calculate_storage_capacity(pattern_length)
        # Theoretical capacity is approximately 0.138 * N for random patterns
        (0.138 * pattern_length).to_i
      end

      def calculate_pattern_similarity(pattern1, pattern2)
        return 0 if pattern1.length != pattern2.length

        matches = pattern1.zip(pattern2).count { |a, b| a == b }
        matches.to_f / pattern1.length
      end
    end

    # Visualization helper for neural networks
    class NeuralNetworkVisualizer
      def initialize(network, network_info, training_history, configuration)
        @network = network
        @network_info = network_info
        @training_history = training_history
        @configuration = configuration
      end

      def visualize
        puts "\n=== Neural Network Visualization ==="
        puts "Network Type: #{@network_info[:network_type]}"

        case @network_info[:network_type]
        when :backpropagation
          visualize_backpropagation_network
        when :hopfield
          visualize_hopfield_network
        end

        visualize_training_progress if @training_history.any?
      end

      def visualize_step(step_info)
        puts "\n--- Step #{step_info[:epoch]} Visualization ---"
        puts step_info[:description]

        puts "Training Error: #{step_info[:error].round(6)}" if step_info[:error]

        puts 'Weight changes recorded for analysis' if step_info[:weight_changes]&.any?
      end

      private

      def visualize_backpropagation_network
        structure = @network_info[:structure]
        puts "Structure: #{structure.join(' → ')}"
        puts "Total neurons: #{structure.sum}"
        puts "Total weights: #{@network_info[:total_weights]}"
        puts "Activation function: #{@configuration.activation_function_name}"
        puts "Learning rate: #{@configuration.learning_rate}"
        puts "Momentum: #{@configuration.momentum}"

        # ASCII network diagram
        puts "\nNetwork Architecture:"
        visualize_network_structure(structure)

        # Training summary
        return unless @network_info[:training_time]

        puts "\nTraining Summary:"
        puts "Training time: #{@network_info[:training_time].round(3)} seconds"
        puts "Final error: #{@network_info[:final_error].round(6)}"
        puts "Convergence: #{@network_info[:convergence_achieved] ? 'Yes' : 'No'}"
      end

      def visualize_hopfield_network
        puts "Neurons: #{@network_info[:structure]&.first || 'Unknown'}"
        puts "Total weights: #{@network_info[:total_weights]}"
        puts "Patterns stored: #{@network_info[:patterns_stored]}"

        return unless @network_info[:patterns_stored] && @network_info[:structure]

        capacity = (0.138 * @network_info[:structure].first).to_i
        puts "Theoretical capacity: #{capacity} patterns"
        puts "Capacity utilization: #{(@network_info[:patterns_stored].to_f / capacity * 100).round(1)}%"
      end

      def visualize_network_structure(structure)
        structure.max

        structure.each_with_index do |layer_size, layer_index|
          # Print layer label
          layer_name = case layer_index
                       when 0 then 'Input'
                       when structure.length - 1 then 'Output'
                       else "Hidden #{layer_index}"
                       end

          puts "#{layer_name} Layer (#{layer_size} neurons):"

          # Print neurons
          layer_size.times do |_neuron_index|
            print '  ◯'
            print '─' * 3 if layer_index < structure.length - 1
          end
          puts

          # Print connections
          next unless layer_index < structure.length - 1

          next_layer_size = structure[layer_index + 1]
          puts '  │' * layer_size
          puts "  └─#{'─' * ((next_layer_size * 4) - 2)}┘"
        end
      end

      def visualize_training_progress
        puts "\n=== Training Progress ==="

        if @training_history.length > 10
          # Sample key epochs for display
          sample_epochs = [0, @training_history.length / 4, @training_history.length / 2,
                           3 * @training_history.length / 4, @training_history.length - 1]

          puts 'Key Training Epochs:'
          puts 'Epoch | Error'
          puts '------|----------'

          sample_epochs.each do |index|
            epoch_data = @training_history[index]
            puts format('%5d | %8.6f', epoch_data[:epoch], epoch_data[:error]) if epoch_data && epoch_data[:error]
          end
        else
          puts 'All Training Epochs:'
          puts 'Epoch | Error'
          puts '------|----------'

          @training_history.each do |epoch_data|
            puts format('%5d | %8.6f', epoch_data[:epoch], epoch_data[:error]) if epoch_data[:error]
          end
        end
      end
    end

    # Export neural networks to various formats
    class NeuralNetworkExporter
      def initialize(network, network_info, training_history)
        @network = network
        @network_info = network_info
        @training_history = training_history
      end

      def export(filename)
        case File.extname(filename).downcase
        when '.json'
          export_json(filename)
        when '.csv'
          export_csv(filename)
        else
          export_text(filename)
        end
      end

      private

      def export_json(filename)
        require 'json'

        result = {
          network_info: @network_info,
          training_history: @training_history,
          weights: extract_weights,
          structure: @network_info[:structure]
        }

        File.write(filename, JSON.pretty_generate(result))
        puts "Exported neural network to #{filename}"
      end

      def export_csv(filename)
        require 'csv'

        CSV.open(filename, 'w') do |csv|
          csv << %w[Epoch Error Timestamp]
          @training_history.each do |epoch_data|
            csv << [epoch_data[:epoch], epoch_data[:error], epoch_data[:timestamp]]
          end
        end

        puts "Exported training history to #{filename}"
      end

      def export_text(filename)
        File.open(filename, 'w') do |file|
          file.puts 'Neural Network Export'
          file.puts '=' * 50
          file.puts "Network Type: #{@network_info[:network_type]}"
          file.puts "Structure: #{@network_info[:structure]}"
          file.puts "Total Weights: #{@network_info[:total_weights]}"
          file.puts "Training Time: #{@network_info[:training_time]} seconds"
          file.puts "Final Error: #{@network_info[:final_error]}"
          file.puts

          file.puts 'Training History:'
          @training_history.each do |epoch_data|
            file.puts "Epoch #{epoch_data[:epoch]}: Error = #{epoch_data[:error]}"
          end
        end

        puts "Exported neural network to #{filename}"
      end

      def extract_weights
        case @network_info[:network_type]
        when :backpropagation
          @network.weights if @network.respond_to?(:weights)
        when :hopfield
          @network.weights if @network.respond_to?(:weights)
        end
      end
    end

    # Network analysis tools
    class NeuralNetworkAnalyzer
      def initialize(network, structure, configuration)
        @network = network
        @structure = structure
        @configuration = configuration
      end

      def analyze
        puts "\n=== Neural Network Analysis ==="

        analyze_architecture
        analyze_weights if @network.respond_to?(:weights)
        analyze_complexity
        suggest_improvements
      end

      private

      def analyze_architecture
        puts 'Architecture Analysis:'
        puts "  Layers: #{@structure.length}"
        puts "  Neurons per layer: #{@structure.join(', ')}"
        puts "  Total neurons: #{@structure.sum}"

        # Check for common architectural issues
        if @structure.length == 2
          puts '  ⚠️  No hidden layers - limited learning capability'
        elsif @structure.length > 5
          puts '  ⚠️  Many layers - potential vanishing gradient problem'
        end

        # Check layer sizes
        hidden_layers = @structure[1...-1]
        if hidden_layers.any? { |size| size > @structure.first * 2 }
          puts '  ⚠️  Very wide hidden layers - potential overfitting'
        end
      end

      def analyze_weights
        return unless @network.weights

        puts "\nWeight Analysis:"

        total_weights = @network.weights.flatten.length
        puts "  Total weights: #{total_weights}"

        # Weight statistics
        all_weights = @network.weights.flatten
        mean_weight = all_weights.sum / all_weights.length
        weight_std = Math.sqrt(all_weights.sum { |w| (w - mean_weight)**2 } / all_weights.length)

        puts "  Weight mean: #{mean_weight.round(4)}"
        puts "  Weight std: #{weight_std.round(4)}"

        # Check for weight issues
        puts '  ⚠️  Large weights detected - potential instability' if all_weights.any? { |w| w.abs > 10 }

        puts '  ⚠️  Low weight variance - potential poor initialization' if weight_std < 0.1
      end

      def analyze_complexity
        puts "\nComplexity Analysis:"

        total_params = @structure.zip(@structure[1..] + [0]).sum do |input_size, output_size|
          next 0 if output_size == 0

          (input_size * output_size) + (@configuration.disable_bias ? 0 : output_size)
        end

        puts "  Total parameters: #{total_params}"

        # Complexity warnings
        puts '  ⚠️  High parameter count - ensure sufficient training data' if total_params > 1000

        if @structure.length > 1
          capacity = @structure[1...-1].sum # Hidden neurons
          puts "  Hidden layer capacity: #{capacity} neurons"
        end
      end

      def suggest_improvements
        puts "\nSuggestions:"

        # Learning rate suggestions
        if @configuration.learning_rate > 0.5
          puts "  • Consider reducing learning rate (current: #{@configuration.learning_rate})"
        elsif @configuration.learning_rate < 0.01
          puts "  • Consider increasing learning rate (current: #{@configuration.learning_rate})"
        end

        # Architecture suggestions
        puts '  • Add hidden layers for more complex pattern learning' if @structure.length == 2

        # Activation function suggestions
        if @configuration.activation_function_name == :sigmoid
          puts '  • Consider ReLU for faster training and avoiding vanishing gradients'
        end

        puts '  • Monitor training error to detect overfitting'
        puts '  • Use validation set to assess generalization'
        puts '  • Consider regularization techniques for complex networks'
      end
    end
  end
end
