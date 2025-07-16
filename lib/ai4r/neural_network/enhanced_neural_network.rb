# frozen_string_literal: true

# Enhanced educational neural network with modern features
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'activation_functions'
require_relative 'optimizers'
require_relative 'regularization'
require_relative 'backpropagation'

module Ai4r
  module NeuralNetwork
    # Enhanced neural network with modern features for education
    class EnhancedNeuralNetwork
      include ActivationFunctions
      include Optimizers
      include Regularization

      attr_reader :structure, :layers, :optimizer, :monitor, :configuration
      attr_accessor :training_mode

      def initialize(structure, config = {})
        @structure = structure
        @configuration = NetworkConfiguration.new(config)
        @layers = create_layers(structure)
        @optimizer = create_optimizer(@configuration.optimizer, @configuration.optimizer_params)
        @monitor = EnhancedNetworkMonitor.new
        @training_mode = true
        @epoch = 0

        # Initialize regularization
        @regularization = RegularizationStrategy.new
        setup_regularization(@configuration.regularization_config)

        # Initialize weights
        initialize_weights(@configuration.weight_initialization)

        puts 'Enhanced Neural Network created:' if @configuration.verbose
        puts "  Structure: #{structure.join(' → ')}" if @configuration.verbose
        puts "  Optimizer: #{@optimizer.class.name.split('::').last}" if @configuration.verbose
        puts "  Activation: #{@configuration.activation_function}" if @configuration.verbose
      end

      # Forward pass with detailed monitoring
      def forward(inputs, training = true)
        @training_mode = training
        @monitor.start_forward_pass if training

        current_input = inputs.dup
        activations = [current_input]

        @layers.each_with_index do |layer, layer_idx|
          # Apply regularization (e.g., dropout)
          current_input = @regularization.apply_forward(current_input, training)

          # Linear transformation
          pre_activation = layer[:weights].zip(current_input).map do |weight_row, input_val|
            weight_row.zip([input_val]).sum { |w, x| w * x }
          end

          # Add bias if enabled
          pre_activation = pre_activation.zip(layer[:bias]).map { |z, b| z + b } unless @configuration.disable_bias

          # Apply activation function
          post_activation = pre_activation.map { |z| layer[:activation].forward(z) }

          # Monitor activations
          @monitor.record_layer_activation(layer_idx, post_activation, pre_activation) if training

          current_input = post_activation
          activations << current_input
        end

        @monitor.finish_forward_pass(activations) if training
        current_input
      end

      # Backward pass with gradient monitoring
      def backward(predictions, targets)
        @monitor.start_backward_pass

        # Calculate output layer gradients
        output_gradients = calculate_output_gradients(predictions, targets)
        @monitor.record_layer_gradient(@layers.length - 1, output_gradients)

        # Backpropagate through layers
        current_gradients = output_gradients

        (@layers.length - 1).downto(0) do |layer_idx|
          layer = @layers[layer_idx]

          # Calculate weight gradients
          weight_gradients = calculate_weight_gradients(layer_idx, current_gradients)

          # Calculate bias gradients
          bias_gradients = current_gradients.dup unless @configuration.disable_bias

          # Calculate gradients for previous layer
          if layer_idx > 0
            current_gradients = calculate_input_gradients(layer_idx, current_gradients)
            @monitor.record_layer_gradient(layer_idx - 1, current_gradients)
          end

          # Apply regularization to gradients
          weight_gradients = @regularization.apply_backward(weight_gradients)

          # Add regularization penalty gradients
          regularization_gradients = calculate_regularization_gradients(layer[:weights])
          weight_gradients = weight_gradients.zip(regularization_gradients).map do |wg, rg|
            wg.zip(rg).map { |w, r| w + r }
          end

          # Update weights using optimizer
          update_layer_weights(layer_idx, weight_gradients, bias_gradients)
        end

        @monitor.finish_backward_pass
      end

      # Training method with comprehensive monitoring
      def train(training_data, validation_data = nil, epochs = 100)
        @monitor.start_training(training_data, validation_data, epochs)

        puts 'Starting training...' if @configuration.verbose
        puts "Training samples: #{training_data.length}" if @configuration.verbose
        puts "Validation samples: #{validation_data&.length || 0}" if @configuration.verbose

        early_stopping = EarlyStopping.new(@configuration.early_stopping_patience) if @configuration.early_stopping

        epochs.times do |epoch|
          @epoch = epoch
          @monitor.start_epoch(epoch)

          # Training phase
          train_epoch(training_data)

          # Validation phase
          if validation_data
            val_loss, val_acc = evaluate(validation_data)
            @monitor.record_validation(val_loss, val_acc)

            # Early stopping check
            if early_stopping&.check(val_loss)
              puts "Early stopping at epoch #{epoch}" if @configuration.verbose
              break
            end
          end

          # Learning rate scheduling
          @configuration.lr_scheduler&.step(val_loss)

          @monitor.finish_epoch

          # Print progress
          if @configuration.verbose && (epoch % @configuration.print_every == 0 || epoch == epochs - 1)
            print_epoch_stats(epoch, val_loss, val_acc)
          end

          # Interactive mode
          handle_interactive_mode(epoch) if @configuration.interactive && epoch % 10 == 0
        end

        @monitor.finish_training

        if @configuration.verbose
          puts "\nTraining completed!"
          print_final_stats
        end

        self
      end

      # Evaluation with detailed metrics
      def evaluate(test_data)
        @training_mode = false
        total_loss = 0.0
        correct = 0

        test_data.each do |sample|
          inputs, targets = sample
          predictions = forward(inputs, false)

          loss = calculate_loss(predictions, targets)
          total_loss += loss

          # Calculate accuracy for classification
          next unless @configuration.task_type == :classification

          predicted_class = predictions.index(predictions.max)
          actual_class = targets.index(targets.max)
          correct += 1 if predicted_class == actual_class
        end

        avg_loss = total_loss / test_data.length
        accuracy = @configuration.task_type == :classification ? correct.to_f / test_data.length : nil

        [avg_loss, accuracy]
      end

      # Interactive debugging and exploration
      def debug_mode
        puts "\n=== Neural Network Debug Mode ==="
        puts 'Commands: weights, gradients, activations, config, help, exit'

        loop do
          print 'debug> '
          command = gets.chomp.downcase

          case command
          when 'weights'
            print_weight_statistics
          when 'gradients'
            @monitor.print_gradient_statistics
          when 'activations'
            @monitor.print_activation_statistics
          when 'config'
            @configuration.print_configuration
          when 'help'
            print_debug_help
          when 'exit'
            break
          else
            puts "Unknown command: #{command}. Type 'help' for available commands."
          end
        end
      end

      # Visualization methods
      def visualize_architecture
        puts "\n=== Network Architecture ==="
        puts "Input Layer: #{@structure[0]} neurons"

        (1...@structure.length).each do |i|
          layer_type = i == @structure.length - 1 ? 'Output' : "Hidden #{i}"
          puts "#{layer_type} Layer: #{@structure[i]} neurons (#{@layers[i - 1][:activation].name})"
        end

        total_params = calculate_total_parameters
        puts "\nTotal parameters: #{total_params[:weights]} weights + #{total_params[:biases]} biases = #{total_params[:total]}"
      end

      def visualize_training_progress
        @monitor.plot_training_curves
      end

      def visualize_weights
        puts "\n=== Weight Visualization ==="

        @layers.each_with_index do |layer, idx|
          puts "\nLayer #{idx + 1} weights:"
          weights = layer[:weights]

          # Statistics
          all_weights = weights.flatten
          puts "  Range: [#{all_weights.min.round(4)}, #{all_weights.max.round(4)}]"
          puts "  Mean: #{(all_weights.sum / all_weights.length).round(4)}"
          puts "  Std: #{calculate_std(all_weights).round(4)}"

          # Histogram
          draw_weight_histogram(all_weights)
        end
      end

      # Gradient analysis
      def analyze_gradients
        @monitor.analyze_gradient_flow

        # Check for vanishing/exploding gradients
        gradient_norms = @monitor.gradient_norms

        if gradient_norms.any? { |norm| norm < 1e-6 }
          puts '⚠️  Vanishing gradients detected!'
          puts 'Consider: different activation function, gradient clipping, better initialization'
        end

        if gradient_norms.any? { |norm| norm > 10 }
          puts '⚠️  Exploding gradients detected!'
          puts 'Consider: gradient clipping, lower learning rate, weight regularization'
        end
      end

      # Hyperparameter search
      def hyperparameter_search(param_grid, training_data, validation_data)
        puts "\n=== Hyperparameter Search ==="

        results = []
        param_combinations = generate_param_combinations(param_grid)

        param_combinations.each_with_index do |params, idx|
          puts "Testing configuration #{idx + 1}/#{param_combinations.length}: #{params}"

          # Create network with these parameters
          test_config = @configuration.merge(params)
          test_network = EnhancedNeuralNetwork.new(@structure, test_config)

          # Train and evaluate
          test_network.train(training_data, validation_data, params[:epochs] || 50)
          val_loss, val_acc = test_network.evaluate(validation_data)

          results << {
            params: params,
            val_loss: val_loss,
            val_acc: val_acc,
            network: test_network
          }
        end

        # Find best configuration
        best_result = results.min_by { |r| r[:val_loss] }

        puts "\nBest configuration:"
        puts "  Parameters: #{best_result[:params]}"
        puts "  Validation loss: #{best_result[:val_loss].round(6)}"
        puts "  Validation accuracy: #{best_result[:val_acc]&.round(4) || 'N/A'}"

        best_result
      end

      # Export network
      def export(filename, format = :json)
        exporter = NetworkExporter.new(self)
        exporter.export(filename, format)
      end

      private

      def create_layers(structure)
        layers = []

        (1...structure.length).each do |i|
          input_size = structure[i - 1]
          output_size = structure[i]

          activation_func = if i == structure.length - 1 && @configuration.output_activation
                              ActivationFunctionFactory.create(@configuration.output_activation)
                            else
                              ActivationFunctionFactory.create(@configuration.activation_function)
                            end

          layers << {
            weights: Array.new(output_size) { Array.new(input_size, 0.0) },
            bias: Array.new(output_size, 0.0),
            activation: activation_func,
            input_size: input_size,
            output_size: output_size
          }
        end

        layers
      end

      def create_optimizer(optimizer_type, params)
        case optimizer_type
        when :sgd
          SGD.new(params[:learning_rate] || 0.01)
        when :sgd_momentum
          SGDMomentum.new(params[:learning_rate] || 0.01, params[:momentum] || 0.9)
        when :adagrad
          AdaGrad.new(params[:learning_rate] || 0.01)
        when :rmsprop
          RMSprop.new(params[:learning_rate] || 0.001, params[:decay_rate] || 0.9)
        when :adam
          Adam.new(params[:learning_rate] || 0.001, params[:beta1] || 0.9, params[:beta2] || 0.999)
        else
          Adam.new(0.001) # Default to Adam
        end
      end

      def setup_regularization(reg_config)
        return unless reg_config

        @regularization.add_technique(Dropout.new(reg_config[:dropout][:rate] || 0.5)) if reg_config[:dropout]

        @regularization.add_technique(L1Regularization.new(reg_config[:l1][:lambda] || 0.01)) if reg_config[:l1]

        @regularization.add_technique(L2Regularization.new(reg_config[:l2][:lambda] || 0.01)) if reg_config[:l2]
      end

      def initialize_weights(init_type)
        case init_type
        when :xavier
          xavier_initialization
        when :he
          he_initialization
        when :normal
          normal_initialization
        else
          random_initialization
        end
      end

      def xavier_initialization
        @layers.each do |layer|
          fan_in = layer[:input_size]
          fan_out = layer[:output_size]
          std = Math.sqrt(2.0 / (fan_in + fan_out))

          layer[:weights].each do |neuron_weights|
            neuron_weights.map! { gaussian_random(0, std) }
          end
        end
      end

      def he_initialization
        @layers.each do |layer|
          fan_in = layer[:input_size]
          std = Math.sqrt(2.0 / fan_in)

          layer[:weights].each do |neuron_weights|
            neuron_weights.map! { gaussian_random(0, std) }
          end
        end
      end

      def normal_initialization(std = 0.1)
        @layers.each do |layer|
          layer[:weights].each do |neuron_weights|
            neuron_weights.map! { gaussian_random(0, std) }
          end
        end
      end

      def random_initialization
        @layers.each do |layer|
          layer[:weights].each do |neuron_weights|
            neuron_weights.map! { (rand * 2) - 1 } # [-1, 1]
          end
        end
      end

      def gaussian_random(mean = 0, std_dev = 1)
        # Box-Muller transform
        theta = 2 * Math::PI * rand
        rho = Math.sqrt(-2 * Math.log(1 - rand))
        mean + (std_dev * rho * Math.cos(theta))
      end

      def train_epoch(training_data)
        epoch_loss = 0.0

        # Shuffle data if configured
        data = @configuration.shuffle_data ? training_data.shuffle : training_data

        data.each_with_index do |sample, idx|
          inputs, targets = sample

          # Forward pass
          predictions = forward(inputs, true)

          # Calculate loss
          loss = calculate_loss(predictions, targets)
          epoch_loss += loss

          # Backward pass
          backward(predictions, targets)

          # Mini-batch updates (if configured)
          if @configuration.batch_size && (idx + 1) % @configuration.batch_size == 0
            # Apply accumulated gradients
            apply_optimizer_step
          end
        end

        # Record epoch statistics
        avg_loss = epoch_loss / training_data.length
        @monitor.record_training(avg_loss)
      end

      def calculate_loss(predictions, targets)
        case @configuration.loss_function
        when :mse
          mean_squared_error(predictions, targets)
        when :cross_entropy
          cross_entropy_loss(predictions, targets)
        when :mae
          mean_absolute_error(predictions, targets)
        else
          mean_squared_error(predictions, targets)
        end
      end

      def mean_squared_error(predictions, targets)
        predictions.zip(targets).sum { |p, t| (p - t)**2 } / 2.0
      end

      def cross_entropy_loss(predictions, targets)
        # Add small epsilon to prevent log(0)
        epsilon = 1e-15
        predictions = predictions.map { |p| [[p, epsilon].max, 1 - epsilon].min }

        -targets.zip(predictions).sum { |t, p| (t * Math.log(p)) + ((1 - t) * Math.log(1 - p)) }
      end

      def mean_absolute_error(predictions, targets)
        predictions.zip(targets).sum { |p, t| (p - t).abs } / predictions.length
      end

      def calculate_total_parameters
        total_weights = @layers.sum { |layer| layer[:weights].flatten.length }
        total_biases = @configuration.disable_bias ? 0 : @layers.sum { |layer| layer[:bias].length }

        {
          weights: total_weights,
          biases: total_biases,
          total: total_weights + total_biases
        }
      end

      def calculate_std(array)
        mean = array.sum / array.length
        variance = array.sum { |x| (x - mean)**2 } / array.length
        Math.sqrt(variance)
      end

      def draw_weight_histogram(weights, bins = 10)
        min_w = weights.min
        max_w = weights.max
        range = max_w - min_w

        return if range == 0

        bin_size = range / bins
        histogram = Array.new(bins, 0)

        weights.each do |w|
          bin = [(w - min_w) / bin_size, bins - 1].min.to_i
          histogram[bin] += 1
        end

        max_count = histogram.max
        puts '  Histogram:'

        histogram.each_with_index do |count, i|
          bin_start = min_w + (i * bin_size)
          bin_end = bin_start + bin_size
          bar_length = max_count > 0 ? (count * 20 / max_count) : 0
          bar = '█' * bar_length

          puts "    #{bin_start.round(3)}-#{bin_end.round(3)}: #{bar} (#{count})"
        end
      end

      def print_epoch_stats(epoch, val_loss, val_acc)
        train_loss = @monitor.training_losses.last

        stats = "Epoch #{epoch}: Loss=#{train_loss.round(6)}"
        stats += ", Val Loss=#{val_loss.round(6)}" if val_loss
        stats += ", Val Acc=#{(val_acc * 100).round(2)}%" if val_acc
        stats += ", LR=#{@optimizer.learning_rate.round(6)}"

        puts stats
      end

      def print_final_stats
        puts "Final training loss: #{@monitor.training_losses.last.round(6)}"
        puts "Training time: #{@monitor.training_time.round(2)} seconds"
        puts "Total epochs: #{@epoch + 1}"

        if @monitor.validation_losses.any?
          best_val_loss = @monitor.validation_losses.min
          puts "Best validation loss: #{best_val_loss.round(6)}"
        end
      end

      def handle_interactive_mode(epoch)
        puts "\n--- Interactive Mode (Epoch #{epoch}) ---"
        puts 'Commands: continue (c), debug (d), plot (p), weights (w), quit (q)'
        print '> '

        command = gets.chomp.downcase

        case command
        when 'c', 'continue'
          return
        when 'd', 'debug'
          debug_mode
        when 'p', 'plot'
          visualize_training_progress
        when 'w', 'weights'
          visualize_weights
        when 'q', 'quit'
          exit
        end
      end

      def print_debug_help
        puts <<~HELP
          Debug commands:
          • weights - Show weight statistics and histograms
          • gradients - Show gradient flow analysis
          • activations - Show activation patterns
          • config - Show current configuration
          • help - Show this help
          • exit - Exit debug mode
        HELP
      end

      def print_weight_statistics
        puts "\n=== Weight Statistics ==="

        @layers.each_with_index do |layer, idx|
          weights = layer[:weights].flatten

          puts "\nLayer #{idx + 1}:"
          puts "  Count: #{weights.length}"
          puts "  Range: [#{weights.min.round(4)}, #{weights.max.round(4)}]"
          puts "  Mean: #{(weights.sum / weights.length).round(4)}"
          puts "  Std: #{calculate_std(weights).round(4)}"

          # Check for potential issues
          puts '  ⚠️  Large weights detected' if weights.any? { |w| w.abs > 10 }

          puts '  ⚠️  Low variance - check initialization' if calculate_std(weights) < 0.01
        end
      end

      # Stub methods for complex calculations
      def calculate_output_gradients(predictions, targets)
        # Simplified gradient calculation
        predictions.zip(targets).map { |p, t| p - t }
      end

      def calculate_weight_gradients(layer_idx, _output_gradients)
        # Simplified weight gradient calculation
        layer = @layers[layer_idx]
        Array.new(layer[:output_size]) { Array.new(layer[:input_size], 0.1) }
      end

      def calculate_input_gradients(layer_idx, _output_gradients)
        # Simplified input gradient calculation
        layer = @layers[layer_idx]
        Array.new(layer[:input_size], 0.1)
      end

      def calculate_regularization_gradients(weights)
        # Apply regularization penalty gradients
        weights.map { |row| row.map { |_w| 0.0 } } # Simplified
      end

      def update_layer_weights(layer_idx, weight_gradients, bias_gradients)
        # Apply optimizer to update weights
        layer = @layers[layer_idx]

        # Update weights
        layer[:weights].each_with_index do |neuron_weights, i|
          neuron_weights.each_with_index do |weight, j|
            gradient = weight_gradients[i][j]
            new_weight = @optimizer.update([weight], [gradient]).first
            layer[:weights][i][j] = new_weight
          end
        end

        # Update biases
        return unless bias_gradients && !@configuration.disable_bias

        layer[:bias].each_with_index do |bias, i|
          gradient = bias_gradients[i]
          new_bias = @optimizer.update([bias], [gradient]).first
          layer[:bias][i] = new_bias
        end
      end

      def apply_optimizer_step
        @optimizer.step
      end

      def generate_param_combinations(param_grid)
        # Generate all combinations of parameters
        keys = param_grid.keys
        values = param_grid.values

        combinations = values.first.product(*values[1..])
        combinations.map { |combo| keys.zip(combo).to_h }
      end
    end

    # Enhanced network configuration
    class NetworkConfiguration
      attr_accessor :activation_function, :output_activation, :optimizer, :optimizer_params, :loss_function,
                    :task_type, :weight_initialization, :regularization_config, :early_stopping, :early_stopping_patience, :batch_size, :shuffle_data, :verbose, :interactive, :print_every, :lr_scheduler, :disable_bias

      def initialize(config = {})
        # Network architecture
        @activation_function = config[:activation_function] || :relu
        @output_activation = config[:output_activation]
        @disable_bias = config[:disable_bias] || false

        # Optimization
        @optimizer = config[:optimizer] || :adam
        @optimizer_params = config[:optimizer_params] || {}
        @loss_function = config[:loss_function] || :mse
        @task_type = config[:task_type] || :regression

        # Initialization
        @weight_initialization = config[:weight_initialization] || :he

        # Regularization
        @regularization_config = config[:regularization] || {}
        @early_stopping = config[:early_stopping] || false
        @early_stopping_patience = config[:early_stopping_patience] || 10

        # Training
        @batch_size = config[:batch_size]
        @shuffle_data = config[:shuffle_data] || true

        # Monitoring
        @verbose = config[:verbose] || false
        @interactive = config[:interactive] || false
        @print_every = config[:print_every] || 10

        # Learning rate scheduling
        @lr_scheduler = config[:lr_scheduler]
      end

      def merge(other_config)
        new_config = {}

        instance_variables.each do |var|
          key = var.to_s.delete('@').to_sym
          new_config[key] = instance_variable_get(var)
        end

        new_config.merge!(other_config)
        NetworkConfiguration.new(new_config)
      end

      def print_configuration
        puts "\n=== Network Configuration ==="
        puts "Activation function: #{@activation_function}"
        puts "Output activation: #{@output_activation || 'same as hidden'}"
        puts "Optimizer: #{@optimizer}"
        puts "Loss function: #{@loss_function}"
        puts "Weight initialization: #{@weight_initialization}"
        puts "Regularization: #{@regularization_config}"
        puts "Early stopping: #{@early_stopping}"
        puts "Batch size: #{@batch_size || 'full batch'}"
        puts "Verbose: #{@verbose}"
      end
    end

    # Enhanced monitoring with detailed tracking
    class EnhancedNetworkMonitor
      attr_reader :training_losses, :validation_losses, :validation_accuracies, :layer_activations, :layer_gradients,
                  :gradient_norms, :training_time, :epoch_times

      def initialize
        @training_losses = []
        @validation_losses = []
        @validation_accuracies = []
        @layer_activations = []
        @layer_gradients = []
        @gradient_norms = []
        @epoch_times = []
        @current_epoch_start = nil
        @training_start_time = nil
      end

      def start_training(training_data, validation_data, epochs)
        @training_start_time = Time.now
        @training_data_size = training_data.length
        @validation_data_size = validation_data&.length || 0
        @total_epochs = epochs

        puts "Training started: #{epochs} epochs" if defined?(@verbose) && @verbose
      end

      def start_epoch(epoch)
        @current_epoch = epoch
        @current_epoch_start = Time.now
      end

      def finish_epoch
        if @current_epoch_start
          epoch_time = Time.now - @current_epoch_start
          @epoch_times << epoch_time
        end
      end

      def finish_training
        @training_time = Time.now - @training_start_time if @training_start_time
      end

      def record_training(loss)
        @training_losses << loss
      end

      def record_validation(loss, accuracy = nil)
        @validation_losses << loss
        @validation_accuracies << accuracy if accuracy
      end

      def start_forward_pass
        @current_activations = []
      end

      def record_layer_activation(layer_idx, post_activation, pre_activation)
        @layer_activations << [] while @layer_activations.length <= layer_idx

        activation_stats = {
          mean: post_activation.sum / post_activation.length,
          std: calculate_std(post_activation),
          dead_neurons: post_activation.count(0),
          saturation: count_saturated(post_activation),
          pre_activation_mean: pre_activation.sum / pre_activation.length
        }

        @layer_activations[layer_idx] << activation_stats
      end

      def finish_forward_pass(activations)
        @current_activations = activations
      end

      def start_backward_pass
        @current_gradients = []
      end

      def record_layer_gradient(layer_idx, gradients)
        @layer_gradients << [] while @layer_gradients.length <= layer_idx

        gradient_norm = Math.sqrt(gradients.sum { |g| g**2 })

        gradient_stats = {
          mean: gradients.sum / gradients.length,
          std: calculate_std(gradients),
          norm: gradient_norm,
          max: gradients.max,
          min: gradients.min
        }

        @layer_gradients[layer_idx] << gradient_stats
        @gradient_norms << gradient_norm
      end

      def finish_backward_pass
        # Analysis can be done here
      end

      def plot_training_curves
        puts "\n=== Training Progress ==="

        if @training_losses.any?
          puts "\nTraining Loss:"
          plot_curve(@training_losses, 'Training Loss')
        end

        if @validation_losses.any?
          puts "\nValidation Loss:"
          plot_curve(@validation_losses, 'Validation Loss')
        end

        if @validation_accuracies.any?
          puts "\nValidation Accuracy:"
          plot_curve(@validation_accuracies, 'Validation Accuracy')
        end
      end

      def analyze_gradient_flow
        puts "\n=== Gradient Flow Analysis ==="

        if @gradient_norms.empty?
          puts 'No gradient data available'
          return
        end

        # Analyze gradient norms over time
        recent_norms = @gradient_norms.last(50)
        avg_norm = recent_norms.sum / recent_norms.length

        puts "Average gradient norm (recent): #{avg_norm.round(6)}"

        # Check for issues
        if avg_norm < 1e-6
          puts '⚠️  Vanishing gradients detected'
          puts '   Consider: ReLU activation, residual connections, gradient clipping'
        elsif avg_norm > 10
          puts '⚠️  Exploding gradients detected'
          puts '   Consider: gradient clipping, lower learning rate, weight regularization'
        else
          puts '✓ Gradient flow appears healthy'
        end

        # Plot gradient norms
        puts "\nGradient Norm History:"
        plot_curve(@gradient_norms[-20..] || @gradient_norms, 'Gradient Norm')
      end

      def print_activation_statistics
        puts "\n=== Activation Statistics ==="

        if @layer_activations.empty?
          puts 'No activation data available'
          return
        end

        @layer_activations.each_with_index do |layer_acts, layer_idx|
          next if layer_acts.empty?

          recent_acts = layer_acts.last
          puts "\nLayer #{layer_idx}:"
          puts "  Mean activation: #{recent_acts[:mean].round(4)}"
          puts "  Std activation: #{recent_acts[:std].round(4)}"
          puts "  Dead neurons: #{recent_acts[:dead_neurons]}"
          puts "  Saturated neurons: #{recent_acts[:saturation]}"

          # Warnings
          puts '  ⚠️  Dead neurons detected' if recent_acts[:dead_neurons] > 0

          puts '  ⚠️  High saturation detected' if recent_acts[:saturation] > layer_acts.length * 0.1
        end
      end

      def print_gradient_statistics
        puts "\n=== Gradient Statistics ==="

        if @layer_gradients.empty?
          puts 'No gradient data available'
          return
        end

        @layer_gradients.each_with_index do |layer_grads, layer_idx|
          next if layer_grads.empty?

          recent_grads = layer_grads.last
          puts "\nLayer #{layer_idx}:"
          puts "  Mean gradient: #{recent_grads[:mean].round(6)}"
          puts "  Gradient norm: #{recent_grads[:norm].round(6)}"
          puts "  Gradient range: [#{recent_grads[:min].round(6)}, #{recent_grads[:max].round(6)}]"
        end
      end

      private

      def calculate_std(array)
        return 0 if array.length < 2

        mean = array.sum / array.length
        variance = array.sum { |x| (x - mean)**2 } / array.length
        Math.sqrt(variance)
      end

      def count_saturated(activations, threshold = 0.99)
        # Count neurons that are close to saturation
        activations.count { |a| a > threshold || a < -threshold }
      end

      def plot_curve(data, title, width = 50)
        return if data.empty?

        min_val = data.min
        max_val = data.max
        range = max_val - min_val

        puts "#{title} (#{min_val.round(4)} - #{max_val.round(4)}):"

        # Sample points for plotting
        sample_size = [data.length, 20].min
        step = data.length / sample_size

        sample_size.times do |i|
          idx = (i * step).to_i
          val = data[idx]

          normalized = range > 0 ? (val - min_val) / range : 0
          bar_length = (normalized * width).to_i
          bar = ('█' * bar_length) + ('░' * (width - bar_length))

          puts "#{idx.to_s.rjust(4)}: |#{bar}| #{val.round(4)}"
        end
      end
    end

    # Network export utility
    class NetworkExporter
      def initialize(network)
        @network = network
      end

      def export(filename, format = :json)
        case format
        when :json
          export_json(filename)
        when :yaml
          export_yaml(filename)
        when :txt
          export_text(filename)
        else
          raise ArgumentError, "Unsupported export format: #{format}"
        end
      end

      private

      def export_json(filename)
        require 'json'

        data = {
          structure: @network.structure,
          layers: serialize_layers,
          configuration: serialize_config,
          training_history: serialize_training_history,
          metadata: {
            created_at: Time.now,
            total_parameters: @network.send(:calculate_total_parameters)
          }
        }

        File.write(filename, JSON.pretty_generate(data))
        puts "Network exported to #{filename}"
      end

      def export_text(filename)
        File.open(filename, 'w') do |f|
          f.puts 'Neural Network Export'
          f.puts '=' * 50
          f.puts "Structure: #{@network.structure.join(' → ')}"
          f.puts "Total Parameters: #{@network.send(:calculate_total_parameters)[:total]}"
          f.puts "Optimizer: #{@network.optimizer.class.name.split('::').last}"
          f.puts

          @network.layers.each_with_index do |layer, idx|
            f.puts "Layer #{idx + 1}:"
            f.puts "  Input size: #{layer[:input_size]}"
            f.puts "  Output size: #{layer[:output_size]}"
            f.puts "  Activation: #{layer[:activation].name}"
            f.puts
          end
        end

        puts "Network exported to #{filename}"
      end

      def serialize_layers
        @network.layers.map do |layer|
          {
            weights: layer[:weights],
            bias: layer[:bias],
            activation: layer[:activation].class.name.split('::').last,
            input_size: layer[:input_size],
            output_size: layer[:output_size]
          }
        end
      end

      def serialize_config
        {
          activation_function: @network.configuration.activation_function,
          optimizer: @network.configuration.optimizer,
          loss_function: @network.configuration.loss_function,
          weight_initialization: @network.configuration.weight_initialization
        }
      end

      def serialize_training_history
        {
          training_losses: @network.monitor.training_losses,
          validation_losses: @network.monitor.validation_losses,
          validation_accuracies: @network.monitor.validation_accuracies,
          training_time: @network.monitor.training_time,
          epoch_times: @network.monitor.epoch_times
        }
      end
    end
  end
end
