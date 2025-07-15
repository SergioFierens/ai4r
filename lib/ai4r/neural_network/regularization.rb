# frozen_string_literal: true

# Regularization techniques for neural networks
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module NeuralNetwork
    module Regularization
      
      # Base class for regularization techniques
      class RegularizationTechnique
        def apply_forward(inputs, training = true)
          inputs
        end
        
        def apply_backward(gradients)
          gradients
        end
        
        def penalty(weights)
          0.0
        end
        
        def educational_notes
          "Base regularization technique"
        end
      end
      
      # Dropout regularization
      class Dropout < RegularizationTechnique
        attr_reader :rate, :mask
        
        def initialize(rate = 0.5)
          @rate = rate
          @mask = nil
          @training = true
        end
        
        def apply_forward(inputs, training = true)
          @training = training
          
          if training
            # Create dropout mask
            @mask = inputs.map { rand > @rate ? 1.0 / (1.0 - @rate) : 0.0 }
            
            # Apply mask with scaling
            inputs.zip(@mask).map { |x, m| x * m }
          else
            # No dropout during evaluation
            inputs
          end
        end
        
        def apply_backward(gradients)
          if @training && @mask
            # Apply same mask to gradients
            gradients.zip(@mask).map { |g, m| g * m }
          else
            gradients
          end
        end
        
        def educational_notes
          <<~NOTES
            Dropout Regularization
            
            Randomly "drops" neurons during training:
            • During training: randomly set neurons to 0 with probability p
            • During testing: use all neurons but scale by (1-p)
            
            How it works:
            1. For each training sample, randomly disable neurons
            2. Forces network to be robust to missing neurons
            3. Prevents co-adaptation of neurons
            4. Acts like training ensemble of networks
            
            Key concepts:
            • Dropout rate: probability of dropping a neuron (typically 0.2-0.5)
            • Inverted dropout: scale during training instead of testing
            • Applied only during training, not testing
            
            Benefits:
            • Reduces overfitting significantly
            • Forces redundant representations
            • Improves generalization
            • Simple to implement
            
            Drawbacks:
            • Increases training time
            • Need more epochs to converge
            • Not always helpful for small networks
            
            Best practices:
            • Use 0.5 for hidden layers
            • Use 0.2 for input layer
            • Don't use on output layer
            • Increase training epochs
            
            Current dropout rate: #{@rate}
          NOTES
        end
      end
      
      # L1 Regularization (Lasso)
      class L1Regularization < RegularizationTechnique
        attr_reader :lambda
        
        def initialize(lambda = 0.01)
          @lambda = lambda
        end
        
        def penalty(weights)
          # L1 norm: sum of absolute values
          if weights.is_a?(Array)
            @lambda * weights.flatten.sum { |w| w.abs }
          else
            @lambda * weights.abs
          end
        end
        
        def gradient_adjustment(weight)
          # Derivative of |w| is sign(w)
          @lambda * (weight > 0 ? 1 : -1)
        end
        
        def educational_notes
          <<~NOTES
            L1 Regularization (Lasso)
            
            Adds penalty proportional to absolute value of weights:
            Loss = Original Loss + λ * Σ|w|
            
            Mathematical insight:
            • Penalty term: λ * Σ|w|
            • Gradient: λ * sign(w)
            • Promotes sparsity (weights → 0)
            
            Effects on weights:
            • Pushes small weights to exactly 0
            • Creates sparse models
            • Feature selection effect
            • Non-differentiable at 0
            
            When to use:
            • Feature selection desired
            • Sparse models needed
            • High-dimensional data
            • Interpretability important
            
            Comparison with L2:
            • L1: Sparse solutions, feature selection
            • L2: Small but non-zero weights, no selection
            
            Hyperparameter λ:
            • Higher λ = more sparsity
            • Too high = underfitting
            • Too low = no regularization
            • Typical range: 0.0001 - 0.1
            
            Current λ: #{@lambda}
          NOTES
        end
      end
      
      # L2 Regularization (Ridge/Weight Decay)
      class L2Regularization < RegularizationTechnique
        attr_reader :lambda
        
        def initialize(lambda = 0.01)
          @lambda = lambda
        end
        
        def penalty(weights)
          # L2 norm: sum of squares
          if weights.is_a?(Array)
            @lambda * 0.5 * weights.flatten.sum { |w| w**2 }
          else
            @lambda * 0.5 * weights**2
          end
        end
        
        def gradient_adjustment(weight)
          # Derivative of 0.5*w^2 is w
          @lambda * weight
        end
        
        def educational_notes
          <<~NOTES
            L2 Regularization (Ridge/Weight Decay)
            
            Adds penalty proportional to square of weights:
            Loss = Original Loss + λ/2 * Σw²
            
            Mathematical insight:
            • Penalty term: λ/2 * Σw²
            • Gradient: λ * w
            • Equivalent to weight decay in SGD
            
            Effects on weights:
            • Shrinks all weights proportionally
            • Prevents weights from growing too large
            • Smooth, differentiable everywhere
            • Doesn't create exactly zero weights
            
            When to use:
            • Default choice for regularization
            • When all features might be relevant
            • Collinear features
            • Need stable solutions
            
            Weight decay equivalence:
            • With SGD: w = w - η*(∇L + λ*w)
            • Equivalent to: w = w*(1-η*λ) - η*∇L
            • "Decays" weights each step
            
            Benefits:
            • Improves generalization
            • Handles correlated features well
            • Computationally efficient
            • Well-understood theory
            
            Current λ: #{@lambda}
          NOTES
        end
      end
      
      # Elastic Net (L1 + L2)
      class ElasticNet < RegularizationTechnique
        attr_reader :l1_ratio, :lambda
        
        def initialize(lambda = 0.01, l1_ratio = 0.5)
          @lambda = lambda
          @l1_ratio = l1_ratio
          @l2_ratio = 1.0 - l1_ratio
        end
        
        def penalty(weights)
          if weights.is_a?(Array)
            weights_flat = weights.flatten
            l1_penalty = @l1_ratio * weights_flat.sum { |w| w.abs }
            l2_penalty = @l2_ratio * 0.5 * weights_flat.sum { |w| w**2 }
            @lambda * (l1_penalty + l2_penalty)
          else
            @lambda * (@l1_ratio * weights.abs + @l2_ratio * 0.5 * weights**2)
          end
        end
        
        def gradient_adjustment(weight)
          l1_grad = weight > 0 ? 1 : -1
          l2_grad = weight
          @lambda * (@l1_ratio * l1_grad + @l2_ratio * l2_grad)
        end
        
        def educational_notes
          <<~NOTES
            Elastic Net Regularization
            
            Combines L1 and L2 regularization:
            Loss = Original Loss + λ * [α*Σ|w| + (1-α)/2*Σw²]
            
            Best of both worlds:
            • L1 component: sparsity and feature selection
            • L2 component: handles correlated features
            • α controls the mix (0=pure L2, 1=pure L1)
            
            When to use:
            • Correlated features + need sparsity
            • When pure L1 or L2 insufficient
            • High-dimensional data with groups
            
            Advantages:
            • Grouping effect for correlated features
            • More stable than pure L1
            • Still provides sparsity
            
            Current settings:
            • λ: #{@lambda}
            • L1 ratio: #{@l1_ratio}
            • L2 ratio: #{@l2_ratio}
          NOTES
        end
      end
      
      # Early Stopping
      class EarlyStopping
        attr_reader :patience, :min_delta, :best_loss, :counter
        
        def initialize(patience = 10, min_delta = 0.0001)
          @patience = patience
          @min_delta = min_delta
          @best_loss = Float::INFINITY
          @counter = 0
          @stopped = false
        end
        
        def check(validation_loss)
          if validation_loss < @best_loss - @min_delta
            # Improvement found
            @best_loss = validation_loss
            @counter = 0
            @best_epoch = current_epoch
          else
            # No improvement
            @counter += 1
          end
          
          if @counter >= @patience
            @stopped = true
          end
          
          @stopped
        end
        
        def stopped?
          @stopped
        end
        
        def reset
          @best_loss = Float::INFINITY
          @counter = 0
          @stopped = false
        end
        
        def educational_notes
          <<~NOTES
            Early Stopping
            
            Stop training when validation performance stops improving:
            
            Algorithm:
            1. Monitor validation loss each epoch
            2. If no improvement for 'patience' epochs, stop
            3. Restore best weights from best epoch
            
            Key concepts:
            • Patience: epochs to wait before stopping
            • Min delta: minimum change to qualify as improvement
            • Validation set: separate data to monitor overfitting
            
            Why it works:
            • Training loss always decreases
            • Validation loss increases when overfitting
            • Stop at the "sweet spot"
            
            Benefits:
            • Automatic regularization
            • Saves computation time
            • No hyperparameter in loss function
            • Adapts to problem difficulty
            
            Best practices:
            • Use proper validation split (10-20%)
            • Set patience based on problem (5-20 epochs)
            • Save best model weights
            • Monitor multiple metrics if needed
            
            Current settings:
            • Patience: #{@patience} epochs
            • Min improvement: #{@min_delta}
            • Best loss so far: #{@best_loss == Float::INFINITY ? 'N/A' : @best_loss.round(6)}
            • Counter: #{@counter}/#{@patience}
          NOTES
        end
      end
      
      # Batch Normalization
      class BatchNormalization < RegularizationTechnique
        attr_reader :momentum, :epsilon, :gamma, :beta
        attr_reader :running_mean, :running_var
        
        def initialize(num_features, momentum = 0.9, epsilon = 1e-5)
          @num_features = num_features
          @momentum = momentum
          @epsilon = epsilon
          
          # Learnable parameters
          @gamma = Array.new(num_features, 1.0)  # Scale
          @beta = Array.new(num_features, 0.0)   # Shift
          
          # Running statistics
          @running_mean = Array.new(num_features, 0.0)
          @running_var = Array.new(num_features, 1.0)
          
          @training = true
        end
        
        def apply_forward(inputs, training = true)
          @training = training
          
          if training
            # Calculate batch statistics
            @batch_mean = calculate_mean(inputs)
            @batch_var = calculate_variance(inputs, @batch_mean)
            
            # Update running statistics
            update_running_stats(@batch_mean, @batch_var)
            
            # Normalize
            normalized = normalize(inputs, @batch_mean, @batch_var)
          else
            # Use running statistics
            normalized = normalize(inputs, @running_mean, @running_var)
          end
          
          # Scale and shift
          apply_scale_shift(normalized)
        end
        
        def apply_backward(gradients)
          # Simplified backward pass
          # Full implementation would compute gradients w.r.t. gamma, beta, and inputs
          gradients
        end
        
        def educational_notes
          <<~NOTES
            Batch Normalization
            
            Normalizes inputs to each layer:
            1. Normalize: x̂ = (x - μ) / √(σ² + ε)
            2. Scale and shift: y = γ * x̂ + β
            
            Key insights:
            • Reduces internal covariate shift
            • Each layer receives normalized inputs
            • Allows higher learning rates
            • Acts as regularization
            
            Training vs Inference:
            • Training: use batch statistics
            • Inference: use running averages
            • Maintains estimates across batches
            
            Benefits:
            • Faster training
            • Higher learning rates possible
            • Less sensitive to initialization
            • Some regularization effect
            • Reduces need for dropout
            
            Parameters:
            • γ (gamma): learned scale parameter
            • β (beta): learned shift parameter
            • Running statistics updated with momentum
            
            When to use:
            • Deep networks (> 3 layers)
            • Before activation functions
            • When training is unstable
            • Alternative to careful initialization
            
            Current settings:
            • Features: #{@num_features}
            • Momentum: #{@momentum}
            • Epsilon: #{@epsilon}
          NOTES
        end
        
        private
        
        def calculate_mean(inputs)
          # Assumes inputs is array of samples
          num_samples = inputs.length
          mean = Array.new(@num_features, 0.0)
          
          inputs.each do |sample|
            sample.each_with_index do |value, i|
              mean[i] += value
            end
          end
          
          mean.map { |m| m / num_samples }
        end
        
        def calculate_variance(inputs, mean)
          num_samples = inputs.length
          var = Array.new(@num_features, 0.0)
          
          inputs.each do |sample|
            sample.each_with_index do |value, i|
              var[i] += (value - mean[i])**2
            end
          end
          
          var.map { |v| v / num_samples }
        end
        
        def update_running_stats(batch_mean, batch_var)
          @running_mean = @running_mean.zip(batch_mean).map do |running, batch|
            @momentum * running + (1 - @momentum) * batch
          end
          
          @running_var = @running_var.zip(batch_var).map do |running, batch|
            @momentum * running + (1 - @momentum) * batch
          end
        end
        
        def normalize(inputs, mean, var)
          inputs.map do |sample|
            sample.zip(mean, var).map do |x, m, v|
              (x - m) / Math.sqrt(v + @epsilon)
            end
          end
        end
        
        def apply_scale_shift(normalized)
          normalized.map do |sample|
            sample.zip(@gamma, @beta).map do |x, g, b|
              g * x + b
            end
          end
        end
      end
      
      # Data Augmentation (conceptual implementation)
      class DataAugmentation < RegularizationTechnique
        def initialize(augmentation_types = [:noise])
          @augmentation_types = augmentation_types
        end
        
        def augment(data)
          augmented = data.dup
          
          @augmentation_types.each do |aug_type|
            case aug_type
            when :noise
              augmented = add_noise(augmented)
            when :scale
              augmented = random_scale(augmented)
            when :shift
              augmented = random_shift(augmented)
            end
          end
          
          augmented
        end
        
        def educational_notes
          <<~NOTES
            Data Augmentation
            
            Artificially increase training data by applying transformations:
            
            Common augmentations:
            • Add noise: x' = x + ε, where ε ~ N(0, σ²)
            • Random scaling: x' = α * x
            • Random shifts: x' = x + β
            • Domain-specific: rotations, flips, crops (images)
            
            Why it works:
            • Increases effective dataset size
            • Forces invariance to transformations
            • Reduces overfitting
            • Improves generalization
            
            Best practices:
            • Apply only during training
            • Keep augmentations realistic
            • Don't change labels
            • Can combine multiple augmentations
            
            Implementation tips:
            • Apply on-the-fly during training
            • Different augmentations per epoch
            • Validate on non-augmented data
            
            Current augmentations: #{@augmentation_types.join(', ')}
          NOTES
        end
        
        private
        
        def add_noise(data, std_dev = 0.01)
          data.map do |x|
            x + gaussian_random(0, std_dev)
          end
        end
        
        def random_scale(data, scale_range = [0.9, 1.1])
          scale = rand * (scale_range[1] - scale_range[0]) + scale_range[0]
          data.map { |x| x * scale }
        end
        
        def random_shift(data, shift_range = [-0.1, 0.1])
          shift = rand * (shift_range[1] - shift_range[0]) + shift_range[0]
          data.map { |x| x + shift }
        end
        
        def gaussian_random(mean = 0, std_dev = 1)
          # Box-Muller transform
          theta = 2 * Math::PI * rand
          rho = Math.sqrt(-2 * Math.log(1 - rand))
          mean + std_dev * rho * Math.cos(theta)
        end
      end
      
      # Regularization strategy manager
      class RegularizationStrategy
        attr_reader :techniques
        
        def initialize
          @techniques = []
        end
        
        def add_technique(technique)
          @techniques << technique
          self
        end
        
        def apply_forward(inputs, training = true)
          result = inputs
          @techniques.each do |technique|
            result = technique.apply_forward(result, training)
          end
          result
        end
        
        def apply_backward(gradients)
          result = gradients
          @techniques.reverse.each do |technique|
            result = technique.apply_backward(result)
          end
          result
        end
        
        def total_penalty(weights)
          @techniques.sum { |technique| technique.penalty(weights) }
        end
        
        def educational_notes
          <<~NOTES
            Regularization Strategy Combination
            
            Multiple regularization techniques can be combined:
            
            Common combinations:
            • Dropout + L2: Standard for deep networks
            • Batch Norm + Dropout: Careful with ordering
            • Early Stopping + Any: Always beneficial
            • Data Augmentation + Others: Complementary
            
            Interaction effects:
            • Some techniques redundant (BN reduces need for dropout)
            • Order matters (BN before/after activation?)
            • Hyperparameters may need adjustment
            
            Best practices:
            • Start simple (just L2 or dropout)
            • Add techniques if overfitting persists
            • Monitor validation performance
            • Consider computational cost
            
            Current techniques:
            #{@techniques.map { |t| "• " + t.class.name.split('::').last }.join("\n")}
          NOTES
        end
      end
    end
  end
end