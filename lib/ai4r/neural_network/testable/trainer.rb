# frozen_string_literal: true

module Ai4r
  module NeuralNetwork
    module Testable
      # Trainer class for neural networks
      # Separates training logic from network implementation for better testability
      class Trainer
        attr_reader :network, :validator, :logger

        # Initialize trainer
        # @param network [Backpropagation] Neural network to train
        # @param validator [NetworkValidator] Validator for data validation
        # @param logger [Logger] Logger for training progress (optional)
        def initialize(network, validator: nil, logger: nil)
          @network = network
          @validator = validator || NetworkValidator.new
          @logger = logger || NullLogger.new
          @training_history = []
        end

        # Train the network
        # @param training_data [Array<Hash>] Training examples with :input and :output
        # @param options [Hash] Training options
        # @option options [Integer] :epochs Number of epochs
        # @option options [Integer] :batch_size Batch size for mini-batch training
        # @option options [Float] :validation_split Fraction of data for validation
        # @option options [Proc] :on_epoch_end Callback after each epoch
        # @option options [Boolean] :shuffle Shuffle data each epoch
        # @return [Hash] Training results
        def train(training_data, **options)
          options = default_options.merge(options)
          
          # Validate training data
          @validator.validate_training_data(
            training_data,
            @network.structure.first,
            @network.structure.last
          )
          
          # Split data if validation requested
          train_data, val_data = split_data(training_data, options[:validation_split])
          
          # Initialize network if needed
          @network.init_network unless @network.network_initialized?
          
          # Training loop
          @training_history.clear
          options[:epochs].times do |epoch|
            epoch_result = train_epoch(train_data, epoch, options)
            
            # Validation if available
            if val_data && !val_data.empty?
              epoch_result[:validation] = validate(val_data)
            end
            
            @training_history << epoch_result
            
            # Callback
            options[:on_epoch_end]&.call(epoch, epoch_result)
            
            # Early stopping check
            break if should_stop_early?(options)
          end
          
          # Return training results
          {
            history: @training_history,
            final_error: @training_history.last[:error],
            epochs_trained: @training_history.length
          }
        end

        # Train in batches
        # @param training_data [Array<Hash>] Training data
        # @param batch_size [Integer] Batch size
        # @param options [Hash] Training options
        # @return [Hash] Training results
        def train_batch(training_data, batch_size, **options)
          train(training_data, options.merge(batch_size: batch_size))
        end

        # Evaluate network on data
        # @param data [Array<Hash>] Test data
        # @return [Hash] Evaluation metrics
        def evaluate(data)
          total_error = 0.0
          correct_predictions = 0
          
          data.each do |example|
            output = @network.eval(example[:input])
            error = calculate_error(output, example[:output])
            total_error += error
            
            # Check if prediction is correct (for classification)
            if classification_task?(example[:output])
              predicted = output.index(output.max)
              expected = example[:output].index(example[:output].max)
              correct_predictions += 1 if predicted == expected
            end
          end
          
          {
            mean_error: total_error / data.length,
            accuracy: correct_predictions.to_f / data.length,
            total_examples: data.length
          }
        end

        # Get training history
        # @return [Array<Hash>] Training history
        def training_history
          @training_history.dup
        end

        private

        def default_options
          {
            epochs: 100,
            batch_size: nil,
            validation_split: 0.0,
            shuffle: true,
            early_stopping_patience: nil,
            early_stopping_min_delta: 0.001
          }
        end

        def train_epoch(data, epoch_num, options)
          # Shuffle data if requested
          data = data.shuffle if options[:shuffle]
          
          total_error = 0.0
          examples_trained = 0
          
          # Train in batches or one by one
          if options[:batch_size]
            # Mini-batch training
            data.each_slice(options[:batch_size]) do |batch|
              batch_error = train_batch_examples(batch)
              total_error += batch_error
              examples_trained += batch.size
            end
          else
            # Stochastic training
            data.each do |example|
              error = @network.train(example[:input], example[:output])
              total_error += error
              examples_trained += 1
            end
          end
          
          mean_error = total_error / examples_trained
          
          @logger.log_epoch(epoch_num, mean_error)
          
          {
            epoch: epoch_num,
            error: mean_error,
            examples_trained: examples_trained
          }
        end

        def train_batch_examples(batch)
          # For true mini-batch, we'd accumulate gradients
          # For now, train sequentially
          total_error = 0.0
          
          batch.each do |example|
            error = @network.train(example[:input], example[:output])
            total_error += error
          end
          
          total_error
        end

        def validate(validation_data)
          evaluate(validation_data)
        end

        def split_data(data, validation_split)
          return [data, []] if validation_split <= 0
          
          validation_size = (data.length * validation_split).to_i
          shuffled = data.shuffle
          
          val_data = shuffled.take(validation_size)
          train_data = shuffled.drop(validation_size)
          
          [train_data, val_data]
        end

        def calculate_error(output, expected)
          output.zip(expected).sum { |o, e| (o - e) ** 2 } / 2.0
        end

        def classification_task?(output)
          # Assume classification if output is one-hot encoded
          output.sum == 1.0 && output.all? { |v| v == 0.0 || v == 1.0 }
        end

        def should_stop_early?(options)
          return false unless options[:early_stopping_patience]
          
          # Check if validation error hasn't improved
          return false if @training_history.length < options[:early_stopping_patience]
          
          recent_errors = @training_history
            .last(options[:early_stopping_patience])
            .map { |h| h.dig(:validation, :mean_error) || h[:error] }
          
          # Check if error is not decreasing
          min_error = recent_errors.min
          recent_errors.all? { |e| e >= min_error - options[:early_stopping_min_delta] }
        end

        # Null logger for when no logging is needed
        class NullLogger
          def log_epoch(epoch, error); end
          def log_batch(batch, error); end
          def log_validation(metrics); end
        end

        # Simple console logger
        class ConsoleLogger
          def log_epoch(epoch, error)
            puts "Epoch #{epoch}: Error = #{error.round(6)}"
          end

          def log_batch(batch, error)
            puts "  Batch #{batch}: Error = #{error.round(6)}"
          end

          def log_validation(metrics)
            puts "  Validation: Error = #{metrics[:mean_error].round(6)}, " \
                 "Accuracy = #{(metrics[:accuracy] * 100).round(2)}%"
          end
        end
      end
    end
  end
end