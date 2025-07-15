# frozen_string_literal: true

# Modern optimization algorithms for neural networks
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module NeuralNetwork
    module Optimizers
      
      # Base class for optimizers
      class Optimizer
        attr_reader :learning_rate, :iteration
        
        def initialize(learning_rate = 0.01)
          @learning_rate = learning_rate
          @iteration = 0
        end
        
        def update(params, gradients)
          raise NotImplementedError, "Subclass must implement update method"
        end
        
        def step
          @iteration += 1
        end
        
        def reset
          @iteration = 0
        end
        
        def educational_notes
          "Base optimizer class"
        end
      end
      
      # Stochastic Gradient Descent
      class SGD < Optimizer
        def update(params, gradients)
          params.zip(gradients).map do |param, grad|
            param - @learning_rate * grad
          end
        end
        
        def educational_notes
          <<~NOTES
            Stochastic Gradient Descent (SGD)
            
            The fundamental optimization algorithm:
            θ = θ - η * ∇L
            
            Pros:
            • Simple and interpretable
            • Guaranteed convergence for convex functions
            • Memory efficient
            
            Cons:
            • Same learning rate for all parameters
            • Can get stuck in local minima
            • Slow convergence
            • Sensitive to learning rate choice
            
            Best practices:
            • Use learning rate scheduling
            • Consider momentum variant
            • Good for initial experimentation
            
            Current learning rate: #{@learning_rate}
          NOTES
        end
      end
      
      # SGD with Momentum
      class SGDMomentum < Optimizer
        attr_reader :momentum, :velocity
        
        def initialize(learning_rate = 0.01, momentum = 0.9)
          super(learning_rate)
          @momentum = momentum
          @velocity = {}
        end
        
        def update(params, gradients)
          params.each_with_index.map do |param, idx|
            # Initialize velocity if needed
            @velocity[idx] ||= 0
            
            # Update velocity
            @velocity[idx] = @momentum * @velocity[idx] - @learning_rate * gradients[idx]
            
            # Update parameters
            param + @velocity[idx]
          end
        end
        
        def reset
          super
          @velocity.clear
        end
        
        def educational_notes
          <<~NOTES
            SGD with Momentum
            
            Accelerates SGD by adding a fraction of previous update:
            v = β * v - η * ∇L
            θ = θ + v
            
            Pros:
            • Accelerates convergence
            • Helps escape shallow local minima
            • Reduces oscillations
            • Smoother convergence path
            
            Cons:
            • Extra hyperparameter (momentum)
            • Can overshoot if momentum too high
            • Still uses fixed learning rate
            
            Momentum interpretation:
            • Physical analogy: ball rolling downhill
            • β = 0.9 means 90% of previous velocity retained
            
            Current settings:
            • Learning rate: #{@learning_rate}
            • Momentum: #{@momentum}
          NOTES
        end
      end
      
      # Adaptive Gradient (AdaGrad)
      class AdaGrad < Optimizer
        attr_reader :epsilon, :accumulator
        
        def initialize(learning_rate = 0.01, epsilon = 1e-8)
          super(learning_rate)
          @epsilon = epsilon
          @accumulator = {}
        end
        
        def update(params, gradients)
          params.each_with_index.map do |param, idx|
            # Initialize accumulator if needed
            @accumulator[idx] ||= 0
            
            # Accumulate squared gradients
            @accumulator[idx] += gradients[idx]**2
            
            # Adaptive learning rate
            adjusted_lr = @learning_rate / (Math.sqrt(@accumulator[idx]) + @epsilon)
            
            # Update parameter
            param - adjusted_lr * gradients[idx]
          end
        end
        
        def reset
          super
          @accumulator.clear
        end
        
        def educational_notes
          <<~NOTES
            Adaptive Gradient Algorithm (AdaGrad)
            
            Adapts learning rate based on historical gradients:
            g_t = g_{t-1} + (∇L)²
            θ = θ - η / √(g_t + ε) * ∇L
            
            Pros:
            • Per-parameter learning rates
            • Good for sparse gradients
            • No manual learning rate tuning
            • Works well for convex optimization
            
            Cons:
            • Learning rate monotonically decreases
            • Can stop learning (accumulated gradient too large)
            • Not ideal for non-convex optimization
            
            Use cases:
            • Sparse data (NLP, recommendations)
            • Convex optimization problems
            
            Current settings:
            • Initial learning rate: #{@learning_rate}
            • Epsilon: #{@epsilon}
          NOTES
        end
      end
      
      # RMSprop
      class RMSprop < Optimizer
        attr_reader :decay_rate, :epsilon, :squared_gradients
        
        def initialize(learning_rate = 0.001, decay_rate = 0.9, epsilon = 1e-8)
          super(learning_rate)
          @decay_rate = decay_rate
          @epsilon = epsilon
          @squared_gradients = {}
        end
        
        def update(params, gradients)
          params.each_with_index.map do |param, idx|
            # Initialize if needed
            @squared_gradients[idx] ||= 0
            
            # Exponential moving average of squared gradients
            @squared_gradients[idx] = @decay_rate * @squared_gradients[idx] + 
                                     (1 - @decay_rate) * gradients[idx]**2
            
            # Adaptive learning rate
            adjusted_lr = @learning_rate / (Math.sqrt(@squared_gradients[idx]) + @epsilon)
            
            # Update parameter
            param - adjusted_lr * gradients[idx]
          end
        end
        
        def reset
          super
          @squared_gradients.clear
        end
        
        def educational_notes
          <<~NOTES
            Root Mean Square Propagation (RMSprop)
            
            Fixes AdaGrad's diminishing learning rate:
            v_t = β * v_{t-1} + (1-β) * (∇L)²
            θ = θ - η / √(v_t + ε) * ∇L
            
            Pros:
            • Adaptive learning rates
            • Doesn't diminish learning rate
            • Works well in practice
            • Good for non-convex optimization
            
            Cons:
            • Not theoretically grounded
            • Still sensitive to initial learning rate
            • No momentum component
            
            Key difference from AdaGrad:
            • Uses exponential moving average
            • Learning rate doesn't monotonically decrease
            
            Current settings:
            • Learning rate: #{@learning_rate}
            • Decay rate: #{@decay_rate}
            • Epsilon: #{@epsilon}
          NOTES
        end
      end
      
      # Adam (Adaptive Moment Estimation)
      class Adam < Optimizer
        attr_reader :beta1, :beta2, :epsilon, :m, :v
        
        def initialize(learning_rate = 0.001, beta1 = 0.9, beta2 = 0.999, epsilon = 1e-8)
          super(learning_rate)
          @beta1 = beta1  # Decay rate for first moment
          @beta2 = beta2  # Decay rate for second moment
          @epsilon = epsilon
          @m = {}  # First moment estimates
          @v = {}  # Second moment estimates
        end
        
        def update(params, gradients)
          step  # Increment iteration
          
          params.each_with_index.map do |param, idx|
            # Initialize moments if needed
            @m[idx] ||= 0
            @v[idx] ||= 0
            
            # Update biased first moment estimate
            @m[idx] = @beta1 * @m[idx] + (1 - @beta1) * gradients[idx]
            
            # Update biased second moment estimate
            @v[idx] = @beta2 * @v[idx] + (1 - @beta2) * gradients[idx]**2
            
            # Compute bias-corrected moments
            m_hat = @m[idx] / (1 - @beta1**@iteration)
            v_hat = @v[idx] / (1 - @beta2**@iteration)
            
            # Update parameters
            param - @learning_rate * m_hat / (Math.sqrt(v_hat) + @epsilon)
          end
        end
        
        def reset
          super
          @m.clear
          @v.clear
        end
        
        def educational_notes
          <<~NOTES
            Adaptive Moment Estimation (Adam)
            
            Combines momentum and RMSprop:
            m_t = β₁ * m_{t-1} + (1-β₁) * ∇L        (momentum)
            v_t = β₂ * v_{t-1} + (1-β₂) * (∇L)²    (RMSprop)
            m̂_t = m_t / (1 - β₁^t)                  (bias correction)
            v̂_t = v_t / (1 - β₂^t)                  (bias correction)
            θ = θ - η * m̂_t / (√v̂_t + ε)
            
            Pros:
            • Combines benefits of momentum and RMSprop
            • Bias correction for initial steps
            • Works well in practice
            • Good default choice
            • Relatively robust to hyperparameters
            
            Cons:
            • More hyperparameters
            • Can miss optimal solution in some cases
            • Not as theoretically grounded as SGD
            
            Hyperparameter meanings:
            • β₁: Exponential decay for momentum (default 0.9)
            • β₂: Exponential decay for squared gradients (default 0.999)
            • ε: Small constant for numerical stability
            
            Current settings:
            • Learning rate: #{@learning_rate}
            • β₁: #{@beta1}
            • β₂: #{@beta2}
            • ε: #{@epsilon}
            • Iteration: #{@iteration}
          NOTES
        end
      end
      
      # Nesterov Accelerated Gradient
      class NAG < Optimizer
        attr_reader :momentum, :velocity
        
        def initialize(learning_rate = 0.01, momentum = 0.9)
          super(learning_rate)
          @momentum = momentum
          @velocity = {}
        end
        
        def update(params, gradients)
          # Note: This requires computing gradients at lookahead position
          # For simplicity, this implementation assumes gradients are already
          # computed at the lookahead position
          
          params.each_with_index.map do |param, idx|
            # Initialize velocity if needed
            @velocity[idx] ||= 0
            
            # Update velocity
            @velocity[idx] = @momentum * @velocity[idx] - @learning_rate * gradients[idx]
            
            # Update parameters
            param + @velocity[idx]
          end
        end
        
        def get_lookahead_params(params)
          # Get parameters at lookahead position for gradient computation
          params.each_with_index.map do |param, idx|
            @velocity[idx] ||= 0
            param + @momentum * @velocity[idx]
          end
        end
        
        def reset
          super
          @velocity.clear
        end
        
        def educational_notes
          <<~NOTES
            Nesterov Accelerated Gradient (NAG)
            
            Look-ahead version of momentum:
            θ_lookahead = θ + β * v
            v = β * v - η * ∇L(θ_lookahead)
            θ = θ + v
            
            Key insight: Compute gradient at "lookahead" position
            
            Pros:
            • Better convergence than standard momentum
            • Reduces overshooting
            • Theoretical convergence guarantees
            • More responsive to changes
            
            Cons:
            • Requires gradient at lookahead position
            • More complex implementation
            • Still uses fixed learning rate
            
            When to use:
            • When standard momentum overshoots
            • For better theoretical guarantees
            • In convex optimization
            
            Current settings:
            • Learning rate: #{@learning_rate}
            • Momentum: #{@momentum}
          NOTES
        end
      end
      
      # Learning rate schedulers
      class LearningRateScheduler
        def initialize(optimizer, schedule_type = :step)
          @optimizer = optimizer
          @schedule_type = schedule_type
          @initial_lr = optimizer.learning_rate
          @epoch = 0
        end
        
        def step(metrics = nil)
          @epoch += 1
          
          new_lr = case @schedule_type
          when :step
            step_decay(@epoch)
          when :exponential
            exponential_decay(@epoch)
          when :cosine
            cosine_annealing(@epoch)
          when :reduce_on_plateau
            reduce_on_plateau(metrics)
          else
            @initial_lr
          end
          
          @optimizer.learning_rate = new_lr
        end
        
        private
        
        def step_decay(epoch, drop_rate = 0.5, epochs_drop = 10)
          @initial_lr * (drop_rate ** (epoch / epochs_drop))
        end
        
        def exponential_decay(epoch, decay_rate = 0.95)
          @initial_lr * (decay_rate ** epoch)
        end
        
        def cosine_annealing(epoch, t_max = 50)
          @initial_lr * 0.5 * (1 + Math.cos(Math::PI * epoch / t_max))
        end
        
        def reduce_on_plateau(metrics, factor = 0.5, patience = 10)
          # Implementation would track metrics and reduce when plateaued
          @initial_lr
        end
      end
      
      # Optimizer comparison tool
      class OptimizerComparison
        def self.compare_convergence(optimizers, loss_function, initial_params, iterations = 100)
          results = {}
          
          optimizers.each do |name, optimizer|
            params = initial_params.dup
            losses = []
            
            iterations.times do
              gradients = compute_gradients(loss_function, params)
              params = optimizer.update(params, gradients)
              loss = loss_function.call(params)
              losses << loss
            end
            
            results[name] = {
              final_params: params,
              final_loss: losses.last,
              loss_history: losses,
              convergence_rate: calculate_convergence_rate(losses)
            }
          end
          
          visualize_results(results)
          results
        end
        
        def self.educational_comparison
          puts <<~COMPARISON
            === Optimizer Comparison Guide ===
            
            SGD:
            • Use when: Simple problems, convex optimization
            • Avoid when: Sparse gradients, need fast convergence
            
            SGD with Momentum:
            • Use when: Standard choice for many problems
            • Avoid when: Need adaptive learning rates
            
            AdaGrad:
            • Use when: Sparse features (NLP, recommendations)
            • Avoid when: Long training, non-convex problems
            
            RMSprop:
            • Use when: Non-stationary objectives, RNNs
            • Avoid when: Need momentum benefits
            
            Adam:
            • Use when: Default first choice, fast convergence needed
            • Avoid when: Simple problems (SGD might generalize better)
            
            Key considerations:
            1. Problem type (convex vs non-convex)
            2. Data sparsity
            3. Training time constraints
            4. Generalization requirements
            
            Practical tips:
            • Start with Adam (lr=0.001)
            • Try SGD+Momentum for better generalization
            • Use learning rate scheduling
            • Monitor gradient norms
          COMPARISON
        end
        
        private
        
        def self.compute_gradients(loss_function, params)
          # Numerical gradient computation for demonstration
          epsilon = 1e-5
          params.map.with_index do |param, i|
            params_plus = params.dup
            params_minus = params.dup
            
            params_plus[i] = param + epsilon
            params_minus[i] = param - epsilon
            
            (loss_function.call(params_plus) - loss_function.call(params_minus)) / (2 * epsilon)
          end
        end
        
        def self.calculate_convergence_rate(losses)
          return 0 if losses.length < 2
          
          # Simple convergence rate: average decrease per iteration
          total_decrease = losses.first - losses.last
          total_decrease / losses.length
        end
        
        def self.visualize_results(results)
          puts "\n=== Optimizer Convergence Comparison ==="
          
          # Find the optimizer with best final loss
          best_optimizer = results.min_by { |_, data| data[:final_loss] }
          
          results.each do |name, data|
            puts "\n#{name}:"
            puts "  Final loss: #{data[:final_loss].round(6)}"
            puts "  Convergence rate: #{data[:convergence_rate].round(6)}"
            puts "  Best: #{'*' if name == best_optimizer[0]}"
            
            # Simple ASCII visualization of convergence
            puts "  Convergence curve:"
            visualize_loss_curve(data[:loss_history])
          end
        end
        
        def self.visualize_loss_curve(losses, width = 50)
          return if losses.empty?
          
          min_loss = losses.min
          max_loss = losses.max
          range = max_loss - min_loss
          
          # Sample points for visualization
          sample_indices = (0...losses.length).step(losses.length / 10.0).map(&:to_i)
          
          sample_indices.each do |i|
            loss = losses[i]
            normalized = range > 0 ? (loss - min_loss) / range : 0
            bar_length = ((1 - normalized) * width).to_i
            bar = "█" * bar_length + "░" * (width - bar_length)
            puts "    #{i.to_s.rjust(4)}: |#{bar}| #{loss.round(4)}"
          end
        end
      end
    end
  end
end