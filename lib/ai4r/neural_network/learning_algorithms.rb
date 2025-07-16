# frozen_string_literal: true

# Modular learning algorithms for educational neural networks
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module NeuralNetwork
    # Collection of learning algorithms with educational explanations
    module LearningAlgorithms
      # Standard Gradient Descent - simplest optimization algorithm
      class GradientDescent
        attr_reader :learning_rate

        def initialize(learning_rate = 0.01)
          @learning_rate = learning_rate
        end

        def update_weight(current_weight, gradient, _step = nil)
          current_weight - (@learning_rate * gradient)
        end

        def description
          'Standard Gradient Descent: Simple weight update using fixed learning rate'
        end

        def characteristics
          {
            memory_usage: 'None',
            convergence_speed: 'Slow',
            parameter_sensitivity: 'High',
            computational_cost: 'Low'
          }
        end
      end

      # Momentum - accelerates learning in consistent directions
      class Momentum
        attr_reader :learning_rate, :momentum_factor

        def initialize(learning_rate = 0.01, momentum_factor = 0.9)
          @learning_rate = learning_rate
          @momentum_factor = momentum_factor
          @velocity = {}
        end

        def update_weight(current_weight, gradient, weight_id)
          @velocity[weight_id] ||= 0

          @velocity[weight_id] = (@momentum_factor * @velocity[weight_id]) - (@learning_rate * gradient)
          current_weight + @velocity[weight_id]
        end

        def reset_state
          @velocity.clear
        end

        def description
          'Momentum: Accumulates velocity in consistent gradient directions, speeds up learning'
        end

        def characteristics
          {
            memory_usage: 'One velocity per weight',
            convergence_speed: 'Faster than SGD',
            parameter_sensitivity: 'Medium',
            computational_cost: 'Low'
          }
        end
      end

      # AdaGrad - adapts learning rate per parameter
      class AdaGrad
        attr_reader :learning_rate, :epsilon

        def initialize(learning_rate = 0.01, epsilon = 1e-8)
          @learning_rate = learning_rate
          @epsilon = epsilon
          @sum_squared_gradients = {}
        end

        def update_weight(current_weight, gradient, weight_id)
          @sum_squared_gradients[weight_id] ||= 0

          @sum_squared_gradients[weight_id] += gradient**2
          adaptive_lr = @learning_rate / (Math.sqrt(@sum_squared_gradients[weight_id]) + @epsilon)

          current_weight - (adaptive_lr * gradient)
        end

        def reset_state
          @sum_squared_gradients.clear
        end

        def description
          'AdaGrad: Adapts learning rate based on historical gradients, good for sparse data'
        end

        def characteristics
          {
            memory_usage: 'One accumulator per weight',
            convergence_speed: 'Good early, slows down',
            parameter_sensitivity: 'Low',
            computational_cost: 'Medium'
          }
        end
      end

      # RMSprop - fixes AdaGrad's aggressive learning rate decay
      class RMSprop
        attr_reader :learning_rate, :decay_rate, :epsilon

        def initialize(learning_rate = 0.001, decay_rate = 0.9, epsilon = 1e-8)
          @learning_rate = learning_rate
          @decay_rate = decay_rate
          @epsilon = epsilon
          @moving_avg_squared = {}
        end

        def update_weight(current_weight, gradient, weight_id)
          @moving_avg_squared[weight_id] ||= 0

          @moving_avg_squared[weight_id] = (@decay_rate * @moving_avg_squared[weight_id]) +
                                           ((1 - @decay_rate) * (gradient**2))

          adaptive_lr = @learning_rate / (Math.sqrt(@moving_avg_squared[weight_id]) + @epsilon)
          current_weight - (adaptive_lr * gradient)
        end

        def reset_state
          @moving_avg_squared.clear
        end

        def description
          'RMSprop: Uses moving average of squared gradients, maintains learning throughout training'
        end

        def characteristics
          {
            memory_usage: 'One moving average per weight',
            convergence_speed: 'Consistent',
            parameter_sensitivity: 'Low',
            computational_cost: 'Medium'
          }
        end
      end

      # Adam - combines momentum and adaptive learning rates
      class Adam
        attr_reader :learning_rate, :beta1, :beta2, :epsilon

        def initialize(learning_rate = 0.001, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8)
          @learning_rate = learning_rate
          @beta1 = beta1
          @beta2 = beta2
          @epsilon = epsilon
          @m = {}  # First moment (momentum)
          @v = {}  # Second moment (adaptive learning rate)
          @t = 0   # Time step
        end

        def update_weight(current_weight, gradient, weight_id)
          @m[weight_id] ||= 0
          @v[weight_id] ||= 0
          @t += 1

          # Update biased first moment estimate
          @m[weight_id] = (@beta1 * @m[weight_id]) + ((1 - @beta1) * gradient)

          # Update biased second moment estimate
          @v[weight_id] = (@beta2 * @v[weight_id]) + ((1 - @beta2) * (gradient**2))

          # Compute bias-corrected first moment estimate
          m_corrected = @m[weight_id] / (1 - (@beta1**@t))

          # Compute bias-corrected second moment estimate
          v_corrected = @v[weight_id] / (1 - (@beta2**@t))

          # Update weight
          current_weight - (@learning_rate * m_corrected / (Math.sqrt(v_corrected) + @epsilon))
        end

        def reset_state
          @m.clear
          @v.clear
          @t = 0
        end

        def description
          'Adam: Combines momentum and adaptive learning rates with bias correction'
        end

        def characteristics
          {
            memory_usage: 'Two moments per weight',
            convergence_speed: 'Fast and stable',
            parameter_sensitivity: 'Very Low',
            computational_cost: 'Higher'
          }
        end
      end

      # AdamW - Adam with decoupled weight decay
      class AdamW
        attr_reader :learning_rate, :beta1, :beta2, :epsilon, :weight_decay

        def initialize(learning_rate = 0.001, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8, weight_decay = 0.01)
          @learning_rate = learning_rate
          @beta1 = beta1
          @beta2 = beta2
          @epsilon = epsilon
          @weight_decay = weight_decay
          @m = {}
          @v = {}
          @t = 0
        end

        def update_weight(current_weight, gradient, weight_id)
          @m[weight_id] ||= 0
          @v[weight_id] ||= 0
          @t += 1

          # Update moments (same as Adam)
          @m[weight_id] = (@beta1 * @m[weight_id]) + ((1 - @beta1) * gradient)
          @v[weight_id] = (@beta2 * @v[weight_id]) + ((1 - @beta2) * (gradient**2))

          # Bias correction
          m_corrected = @m[weight_id] / (1 - (@beta1**@t))
          v_corrected = @v[weight_id] / (1 - (@beta2**@t))

          # Adam update with weight decay
          adam_update = @learning_rate * m_corrected / (Math.sqrt(v_corrected) + @epsilon)
          weight_decay_update = @learning_rate * @weight_decay * current_weight

          current_weight - adam_update - weight_decay_update
        end

        def reset_state
          @m.clear
          @v.clear
          @t = 0
        end

        def description
          'AdamW: Adam with proper weight decay regularization'
        end

        def characteristics
          {
            memory_usage: 'Two moments per weight',
            convergence_speed: 'Fast and stable',
            parameter_sensitivity: 'Very Low',
            computational_cost: 'Higher',
            regularization: 'Built-in weight decay'
          }
        end
      end

      # Factory for creating learning algorithms
      class LearningAlgorithmFactory
        AVAILABLE_ALGORITHMS = {
          gradient_descent: GradientDescent,
          sgd: GradientDescent, # Alias
          momentum: Momentum,
          adagrad: AdaGrad,
          rmsprop: RMSprop,
          adam: Adam,
          adamw: AdamW
        }.freeze

        def self.create(algorithm_name, options = {})
          algorithm_class = AVAILABLE_ALGORITHMS[algorithm_name.to_sym]
          raise ArgumentError, "Unknown learning algorithm: #{algorithm_name}" unless algorithm_class

          case algorithm_name.to_sym
          when :gradient_descent, :sgd
            learning_rate = options[:learning_rate] || 0.01
            algorithm_class.new(learning_rate)
          when :momentum
            learning_rate = options[:learning_rate] || 0.01
            momentum_factor = options[:momentum_factor] || 0.9
            algorithm_class.new(learning_rate, momentum_factor)
          when :adagrad
            learning_rate = options[:learning_rate] || 0.01
            epsilon = options[:epsilon] || 1e-8
            algorithm_class.new(learning_rate, epsilon)
          when :rmsprop
            learning_rate = options[:learning_rate] || 0.001
            decay_rate = options[:decay_rate] || 0.9
            epsilon = options[:epsilon] || 1e-8
            algorithm_class.new(learning_rate, decay_rate, epsilon)
          when :adam
            learning_rate = options[:learning_rate] || 0.001
            beta1 = options[:beta1] || 0.9
            beta2 = options[:beta2] || 0.999
            epsilon = options[:epsilon] || 1e-8
            algorithm_class.new(learning_rate, beta1, beta2, epsilon)
          when :adamw
            learning_rate = options[:learning_rate] || 0.001
            beta1 = options[:beta1] || 0.9
            beta2 = options[:beta2] || 0.999
            epsilon = options[:epsilon] || 1e-8
            weight_decay = options[:weight_decay] || 0.01
            algorithm_class.new(learning_rate, beta1, beta2, epsilon, weight_decay)
          end
        end

        def self.list_algorithms
          AVAILABLE_ALGORITHMS.keys.uniq
        end

        def self.compare_algorithms
          puts '=== Learning Algorithm Comparison ==='
          puts

          algorithms = %i[gradient_descent momentum adagrad rmsprop adam adamw]

          algorithms.each do |name|
            algorithm = create(name)
            puts "#{name.to_s.upcase.tr('_', ' ')}:"
            puts "  #{algorithm.description}"
            puts '  Characteristics:'
            algorithm.characteristics.each do |key, value|
              puts "    #{key.to_s.tr('_', ' ').capitalize}: #{value}"
            end
            puts
          end
        end

        def self.recommend_algorithm(_problem_characteristics)
          recommendations = {
            sparse_data: 'AdaGrad - adapts well to infrequent features',
            noisy_gradients: 'Adam or RMSprop - smooths out noise',
            fast_convergence: 'Adam or AdamW - generally fastest',
            memory_constrained: 'SGD or Momentum - minimal memory usage',
            large_dataset: 'SGD with momentum - computationally efficient',
            regularization_needed: 'AdamW - built-in weight decay',
            deep_network: 'Adam or RMSprop - handles vanishing gradients well',
            simple_problem: 'SGD - often sufficient and interpretable'
          }

          puts 'Algorithm Recommendations:'
          recommendations.each do |problem, recommendation|
            puts "• #{problem.to_s.tr('_', ' ').capitalize}: #{recommendation}"
          end
        end
      end

      # Educational tools for understanding learning algorithms
      class LearningAnalyzer
        def self.demonstrate_convergence(algorithm_name, options = {})
          algorithm = LearningAlgorithmFactory.create(algorithm_name, options)

          puts "=== Convergence Demonstration: #{algorithm_name.to_s.upcase} ==="
          puts algorithm.description
          puts

          # Simulate a simple quadratic loss function: f(x) = (x - 5)^2
          target = 5.0
          current_weight = 0.0

          puts 'Optimizing f(x) = (x - 5)² starting from x = 0'
          puts 'Target: x = 5 (minimum at f(5) = 0)'
          puts
          puts 'Step | Weight | Gradient | Loss     | Update'
          puts '-----|--------|----------|----------|--------'

          20.times do |step|
            # Calculate gradient: df/dx = 2(x - 5)
            gradient = 2 * (current_weight - target)
            loss = (current_weight - target)**2

            # Update weight
            old_weight = current_weight
            current_weight = algorithm.update_weight(current_weight, gradient, 'weight_0')
            update = current_weight - old_weight

            puts format('%4d | %6.3f | %8.3f | %8.3f | %7.3f',
                        step, current_weight, gradient, loss, update)

            # Stop if converged
            break if loss < 0.001
          end

          puts
          puts "Final weight: #{current_weight.round(4)} (target: #{target})"
          puts "Final loss: #{((current_weight - target)**2).round(6)}"
        end

        def self.compare_on_problem(problem_type = :quadratic)
          puts "=== Algorithm Comparison on #{problem_type.to_s.capitalize} Problem ==="

          algorithms = %i[gradient_descent momentum adagrad rmsprop adam]
          target = 3.0
          initial_weight = -2.0
          steps = 50

          results = {}

          algorithms.each do |algo_name|
            algorithm = LearningAlgorithmFactory.create(algo_name)
            current_weight = initial_weight

            steps.times do |_step|
              case problem_type
              when :quadratic
                gradient = 2 * (current_weight - target)
              when :noisy_quadratic
                gradient = (2 * (current_weight - target)) + ((rand - 0.5) * 0.5) # Add noise
              end

              current_weight = algorithm.update_weight(current_weight, gradient, 'weight_0')
            end

            final_loss = (current_weight - target)**2
            results[algo_name] = {
              final_weight: current_weight,
              final_loss: final_loss,
              converged: final_loss < 0.01
            }
          end

          puts
          puts "Results after #{steps} steps:"
          puts 'Algorithm    | Final Weight | Final Loss | Converged'
          puts '-------------|--------------|------------|----------'

          results.each do |algo_name, result|
            converged_str = result[:converged] ? 'Yes ✓' : 'No ✗'
            puts format('%-12s | %12.4f | %10.6f | %s',
                        algo_name.to_s.tr('_', ' ').capitalize,
                        result[:final_weight],
                        result[:final_loss],
                        converged_str)
          end
        end

        def self.explain_hyperparameters
          puts '=== Learning Algorithm Hyperparameters ==='
          puts

          explanations = {
            learning_rate: 'Controls step size. Too high: overshooting, too low: slow convergence',
            momentum_factor: 'How much to remember previous updates. 0.9 is typical',
            beta1: 'Exponential decay rate for first moment (momentum). Default: 0.9',
            beta2: 'Exponential decay rate for second moment (variance). Default: 0.999',
            epsilon: 'Small constant to prevent division by zero. Default: 1e-8',
            weight_decay: 'L2 regularization strength. Prevents overfitting',
            decay_rate: 'How quickly to forget old gradients in RMSprop. Default: 0.9'
          }

          explanations.each do |param, explanation|
            puts "#{param.to_s.tr('_', ' ').upcase}:"
            puts "  #{explanation}"
            puts
          end

          puts 'Tuning tips:'
          puts '• Start with default values'
          puts '• Learning rate is most important - try 0.1, 0.01, 0.001'
          puts '• Adam often works well out-of-the-box'
          puts '• Use learning rate decay for long training'
          puts '• Monitor loss curves to detect problems'
        end

        def self.educational_summary
          puts '=== Learning Algorithms Educational Summary ==='
          puts
          puts 'Learning algorithms determine how neural networks update their weights:'
          puts '• Gradient Descent: Follow the negative gradient (steepest descent)'
          puts '• Momentum: Build up velocity in consistent directions'
          puts '• Adaptive methods: Adjust learning rate per parameter'
          puts '• Modern optimizers: Combine multiple techniques'
          puts
          puts 'Key concepts:'
          puts '• Learning rate: How big steps to take'
          puts '• Convergence: Reaching the optimal solution'
          puts '• Local minima: Getting stuck in suboptimal solutions'
          puts '• Saddle points: Flat regions that slow learning'
          puts
          puts 'Choosing an optimizer:'
          puts '• Start with Adam for most problems'
          puts '• Use SGD+momentum for well-understood problems'
          puts '• Consider problem-specific needs (memory, speed, regularization)'
          puts
          puts 'Experiment with different optimizers to see their behavior!'
        end
      end
    end
  end
end
