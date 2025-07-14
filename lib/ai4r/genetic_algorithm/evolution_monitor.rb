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
    
    # Evolution monitoring and statistics collection
    class EvolutionMonitor
      attr_reader :generation_stats, :start_time, :end_time
      
      def initialize
        @generation_stats = []
        @start_time = nil
        @end_time = nil
      end
      
      # Start monitoring
      def start
        @start_time = Time.now
        @generation_stats.clear
      end
      
      # End monitoring
      def finish
        @end_time = Time.now
      end
      
      # Record statistics for a generation
      def record_generation(generation, population)
        return if population.empty?
        
        fitnesses = population.map(&:fitness)
        
        stats = {
          generation: generation,
          timestamp: Time.now,
          population_size: population.size,
          best_fitness: fitnesses.max,
          worst_fitness: fitnesses.min,
          average_fitness: fitnesses.sum / fitnesses.size.to_f,
          median_fitness: median(fitnesses),
          fitness_std: standard_deviation(fitnesses),
          diversity: calculate_diversity(population),
          best_individual: population.max_by(&:fitness).clone
        }
        
        @generation_stats << stats
      end
      
      # Get evolution summary
      def summary
        return "No evolution data recorded" if @generation_stats.empty?
        
        first_gen = @generation_stats.first
        last_gen = @generation_stats.last
        
        improvement = last_gen[:best_fitness] - first_gen[:best_fitness]
        runtime = @end_time ? (@end_time - @start_time) : 0
        
        <<~SUMMARY
          Evolution Summary:
          ==================
          Generations: #{@generation_stats.size}
          Runtime: #{runtime.round(2)} seconds
          
          Initial best fitness: #{first_gen[:best_fitness].round(4)}
          Final best fitness: #{last_gen[:best_fitness].round(4)}
          Improvement: #{improvement.round(4)}
          
          Final population diversity: #{last_gen[:diversity].round(4)}
          Average fitness std: #{average_fitness_std.round(4)}
          
          Best individual: #{last_gen[:best_individual]}
        SUMMARY
      end
      
      # Get best fitness evolution
      def best_fitness_evolution
        @generation_stats.map { |stats| stats[:best_fitness] }
      end
      
      # Get average fitness evolution
      def average_fitness_evolution
        @generation_stats.map { |stats| stats[:average_fitness] }
      end
      
      # Get diversity evolution
      def diversity_evolution
        @generation_stats.map { |stats| stats[:diversity] }
      end
      
      # Check if algorithm has converged
      def converged?(last_n_generations = 10, tolerance = 1e-6)
        return false if @generation_stats.size < last_n_generations
        
        recent_best = @generation_stats.last(last_n_generations).map { |s| s[:best_fitness] }
        recent_best.max - recent_best.min < tolerance
      end
      
      # Export data for visualization
      def export_csv(filename)
        require 'csv'
        
        CSV.open(filename, 'w', write_headers: true, headers: %w[
          generation timestamp population_size best_fitness worst_fitness 
          average_fitness median_fitness fitness_std diversity
        ]) do |csv|
          @generation_stats.each do |stats|
            csv << [
              stats[:generation],
              stats[:timestamp],
              stats[:population_size],
              stats[:best_fitness],
              stats[:worst_fitness],
              stats[:average_fitness],
              stats[:median_fitness],
              stats[:fitness_std],
              stats[:diversity]
            ]
          end
        end
      end
      
      # Print generation statistics
      def print_generation_stats(generation_stats)
        puts "Generation #{generation_stats[:generation]}:"
        puts "  Best: #{generation_stats[:best_fitness].round(4)}"
        puts "  Avg:  #{generation_stats[:average_fitness].round(4)}"
        puts "  Div:  #{generation_stats[:diversity].round(4)}"
      end
      
      # Simple plotting for terminal output
      def plot_fitness_evolution(width = 50)
        return "No data to plot" if @generation_stats.empty?
        
        best_fits = best_fitness_evolution
        min_fit = best_fits.min
        max_fit = best_fits.max
        
        puts "Fitness Evolution:"
        puts "#{max_fit.round(2)} |" + "─" * width
        
        best_fits.each_with_index do |fitness, generation|
          normalized = (fitness - min_fit) / (max_fit - min_fit + 1e-10)
          bar_length = (normalized * width).round
          
          bar = "█" * bar_length + "░" * (width - bar_length)
          puts "#{fitness.round(2).to_s.rjust(8)} |#{bar}| Gen #{generation}"
        end
        
        puts "#{min_fit.round(2)} |" + "─" * width
      end
      
      private
      
      # Calculate population diversity using average pairwise distance
      def calculate_diversity(population)
        return 0.0 if population.size <= 1
        
        total_distance = 0.0
        comparisons = 0
        
        population.each_with_index do |individual1, i|
          population.each_with_index do |individual2, j|
            next if i >= j
            
            distance = chromosome_distance(individual1, individual2)
            total_distance += distance
            comparisons += 1
          end
        end
        
        comparisons > 0 ? total_distance / comparisons : 0.0
      end
      
      # Calculate distance between two chromosomes
      def chromosome_distance(chr1, chr2)
        return 0.0 if chr1.genes.length != chr2.genes.length
        
        case chr1
        when BinaryChromosome
          # Hamming distance for binary chromosomes
          chr1.genes.zip(chr2.genes).count { |g1, g2| g1 != g2 }.to_f
        when RealChromosome
          # Euclidean distance for real chromosomes
          Math.sqrt(chr1.genes.zip(chr2.genes).sum { |g1, g2| (g1 - g2) ** 2 })
        when PermutationChromosome
          # Number of different positions for permutations
          chr1.genes.zip(chr2.genes).count { |g1, g2| g1 != g2 }.to_f
        else
          # Generic distance (number of different genes)
          chr1.genes.zip(chr2.genes).count { |g1, g2| g1 != g2 }.to_f
        end
      end
      
      # Calculate median of array
      def median(array)
        sorted = array.sort
        length = sorted.length
        
        if length.odd?
          sorted[length / 2]
        else
          (sorted[length / 2 - 1] + sorted[length / 2]) / 2.0
        end
      end
      
      # Calculate standard deviation
      def standard_deviation(array)
        return 0.0 if array.empty?
        
        mean = array.sum / array.size.to_f
        variance = array.sum { |x| (x - mean) ** 2 } / array.size.to_f
        Math.sqrt(variance)
      end
      
      # Calculate average fitness standard deviation across generations
      def average_fitness_std
        return 0.0 if @generation_stats.empty?
        
        stds = @generation_stats.map { |stats| stats[:fitness_std] }
        stds.sum / stds.size.to_f
      end
    end
    
  end
end