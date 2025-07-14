# frozen_string_literal: true

# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module GeneticAlgorithm
    
    # Configuration class for genetic algorithm parameters
    class Configuration
      attr_accessor :population_size, :max_generations, :mutation_rate,
                    :crossover_rate, :elitism_rate, :selection_pressure,
                    :convergence_threshold, :convergence_generations,
                    :fitness_goal, :time_limit, :verbose
      
      # Pre-defined configuration sets for educational purposes
      PRESETS = {
        default: {
          population_size: 50,
          max_generations: 100,
          mutation_rate: 0.01,
          crossover_rate: 0.8,
          elitism_rate: 0.1,
          selection_pressure: 2,
          convergence_threshold: 1e-6,
          convergence_generations: 10,
          fitness_goal: nil,
          time_limit: nil,
          verbose: false
        },
        
        exploration: {
          population_size: 100,
          max_generations: 200,
          mutation_rate: 0.1,
          crossover_rate: 0.7,
          elitism_rate: 0.05,
          selection_pressure: 1.5,
          convergence_threshold: 1e-8,
          convergence_generations: 20,
          fitness_goal: nil,
          time_limit: nil,
          verbose: true
        },
        
        exploitation: {
          population_size: 30,
          max_generations: 50,
          mutation_rate: 0.005,
          crossover_rate: 0.9,
          elitism_rate: 0.2,
          selection_pressure: 3,
          convergence_threshold: 1e-4,
          convergence_generations: 5,
          fitness_goal: nil,
          time_limit: nil,
          verbose: false
        },
        
        balanced: {
          population_size: 75,
          max_generations: 150,
          mutation_rate: 0.02,
          crossover_rate: 0.85,
          elitism_rate: 0.15,
          selection_pressure: 2.5,
          convergence_threshold: 1e-5,
          convergence_generations: 15,
          fitness_goal: nil,
          time_limit: nil,
          verbose: false
        }
      }.freeze
      
      def initialize(preset = :default, **options)
        # Load preset configuration
        preset_config = PRESETS[preset] || PRESETS[:default]
        
        # Apply preset values
        preset_config.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
        
        # Override with provided options
        options.each do |key, value|
          if respond_to?("#{key}=")
            send("#{key}=", value)
          else
            raise ArgumentError, "Unknown configuration parameter: #{key}"
          end
        end
        
        validate!
      end
      
      # Validate configuration parameters
      def validate!
        validate_positive(:population_size, "Population size must be positive")
        validate_positive(:max_generations, "Max generations must be positive")
        validate_probability(:mutation_rate, "Mutation rate must be between 0 and 1")
        validate_probability(:crossover_rate, "Crossover rate must be between 0 and 1")
        validate_probability(:elitism_rate, "Elitism rate must be between 0 and 1")
        validate_positive(:selection_pressure, "Selection pressure must be positive")
        validate_positive(:convergence_threshold, "Convergence threshold must be positive")
        validate_positive(:convergence_generations, "Convergence generations must be positive")
        
        if @time_limit && @time_limit <= 0
          raise ArgumentError, "Time limit must be positive"
        end
        
        if @elitism_rate >= 1.0
          raise ArgumentError, "Elitism rate must be less than 1.0"
        end
        
        if @population_size < 2
          raise ArgumentError, "Population size must be at least 2"
        end
      end
      
      # Clone configuration with modifications
      def with(**options)
        new_config = self.class.new
        
        # Copy current values
        instance_variables.each do |var|
          new_config.instance_variable_set(var, instance_variable_get(var))
        end
        
        # Apply modifications
        options.each do |key, value|
          if new_config.respond_to?("#{key}=")
            new_config.send("#{key}=", value)
          else
            raise ArgumentError, "Unknown configuration parameter: #{key}"
          end
        end
        
        new_config.validate!
        new_config
      end
      
      # Get configuration as hash
      def to_h
        {
          population_size: @population_size,
          max_generations: @max_generations,
          mutation_rate: @mutation_rate,
          crossover_rate: @crossover_rate,
          elitism_rate: @elitism_rate,
          selection_pressure: @selection_pressure,
          convergence_threshold: @convergence_threshold,
          convergence_generations: @convergence_generations,
          fitness_goal: @fitness_goal,
          time_limit: @time_limit,
          verbose: @verbose
        }
      end
      
      # String representation
      def to_s
        <<~CONFIG
          Genetic Algorithm Configuration:
          ================================
          Population Size: #{@population_size}
          Max Generations: #{@max_generations}
          Mutation Rate: #{@mutation_rate}
          Crossover Rate: #{@crossover_rate}
          Elitism Rate: #{@elitism_rate}
          Selection Pressure: #{@selection_pressure}
          Convergence Threshold: #{@convergence_threshold}
          Convergence Generations: #{@convergence_generations}
          Fitness Goal: #{@fitness_goal || 'None'}
          Time Limit: #{@time_limit || 'None'}
          Verbose: #{@verbose}
        CONFIG
      end
      
      # Educational method to explain parameters
      def explain_parameters
        explanations = {
          population_size: "Number of individuals in each generation. Larger populations explore more but are slower.",
          max_generations: "Maximum number of generations to evolve. More generations allow better solutions but take longer.",
          mutation_rate: "Probability of mutating each gene. Higher rates increase exploration but may disrupt good solutions.",
          crossover_rate: "Probability of crossing over parent chromosomes. Higher rates increase information mixing.",
          elitism_rate: "Fraction of best individuals guaranteed to survive. Prevents loss of good solutions.",
          selection_pressure: "How strongly fitness influences selection. Higher pressure favors best individuals more.",
          convergence_threshold: "Minimum fitness change to consider algorithm converged. Lower values detect convergence sooner.",
          convergence_generations: "Number of generations to check for convergence. More generations reduce false positives.",
          fitness_goal: "Target fitness value to stop evolution. Useful when optimal fitness is known.",
          time_limit: "Maximum runtime in seconds. Prevents infinite evolution.",
          verbose: "Whether to print detailed progress information during evolution."
        }
        
        puts "Parameter Explanations:"
        puts "======================="
        explanations.each do |param, explanation|
          current_value = instance_variable_get("@#{param}")
          puts "#{param.to_s.capitalize.gsub('_', ' ')}: #{explanation}"
          puts "  Current value: #{current_value}"
          puts
        end
      end
      
      # Suggest parameter adjustments based on problem characteristics
      def suggest_adjustments(problem_type)
        suggestions = case problem_type
        when :exploration
          "For exploration problems, try: higher mutation rate (0.05-0.1), larger population (100+), more generations"
        when :exploitation
          "For exploitation problems, try: lower mutation rate (0.001-0.01), higher elitism (0.2+), fewer generations"
        when :multimodal
          "For multimodal problems, try: higher population diversity, lower selection pressure (1.5-2.0), balanced mutation"
        when :continuous
          "For continuous problems, try: real-valued chromosomes, Gaussian mutation, intermediate crossover"
        when :discrete
          "For discrete problems, try: appropriate crossover (uniform/single-point), bit-flip or swap mutation"
        when :large_scale
          "For large problems, try: smaller population, more generations, adaptive parameters"
        else
          "General advice: Balance exploration (higher mutation) vs exploitation (lower mutation, higher elitism)"
        end
        
        puts "Suggestions for #{problem_type} problems:"
        puts suggestions
      end
      
      private
      
      def validate_positive(param, message)
        value = instance_variable_get("@#{param}")
        raise ArgumentError, message if value <= 0
      end
      
      def validate_probability(param, message)
        value = instance_variable_get("@#{param}")
        raise ArgumentError, message unless value >= 0 && value <= 1
      end
    end
    
  end
end