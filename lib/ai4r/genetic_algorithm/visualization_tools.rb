# frozen_string_literal: true

# Visualization tools for genetic algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

module Ai4r
  module GeneticAlgorithm
    # Advanced visualization tools for genetic algorithm analysis
    class VisualizationTools
      def self.plot_evolution_timeline(monitor, title = 'Evolution Timeline')
        puts "\n#{'=' * 60}"
        puts title.center(60)
        puts '=' * 60

        stats = monitor.generation_stats
        return if stats.empty?

        # Extract data series
        generations = (0...stats.length).to_a
        best_fitness = stats.map { |s| s[:best_fitness] }
        avg_fitness = stats.map { |s| s[:average_fitness] }
        diversity = stats.map { |s| s[:diversity] }

        # Plot fitness evolution
        plot_ascii_chart('Best Fitness Evolution', generations, best_fitness)
        plot_ascii_chart('Average Fitness Evolution', generations, avg_fitness)
        plot_ascii_chart('Population Diversity', generations, diversity)

        # Summary statistics
        puts "\nEvolution Summary:"
        puts "• Total generations: #{stats.length}"
        puts "• Initial fitness: #{best_fitness.first.round(4)}"
        puts "• Final fitness: #{best_fitness.last.round(4)}"
        puts "• Improvement: #{((best_fitness.last - best_fitness.first) / best_fitness.first * 100).round(2)}%"
        puts "• Convergence generation: #{find_convergence_generation(best_fitness)}"
        puts "• Final diversity: #{diversity.last.round(4)}"
      end

      def self.plot_population_analysis(population, title = 'Population Analysis')
        puts "\n#{'=' * 50}"
        puts title.center(50)
        puts '=' * 50

        return if population.empty?

        fitnesses = population.map(&:fitness)

        # Fitness distribution
        puts "\nFitness Distribution:"
        plot_histogram(fitnesses, 10)

        # Population statistics
        puts "\nPopulation Statistics:"
        puts "• Population size: #{population.size}"
        puts "• Best fitness: #{fitnesses.max.round(4)}"
        puts "• Worst fitness: #{fitnesses.min.round(4)}"
        puts "• Average fitness: #{(fitnesses.sum / fitnesses.size).round(4)}"
        puts "• Fitness standard deviation: #{standard_deviation(fitnesses).round(4)}"
        puts "• Fitness range: #{(fitnesses.max - fitnesses.min).round(4)}"

        # Diversity analysis
        if population.first.respond_to?(:genes)
          diversity = calculate_population_diversity(population)
          puts "• Population diversity: #{diversity.round(4)}"
        end
      end

      def self.plot_operator_comparison(results, title = 'Operator Comparison')
        puts "\n#{'=' * 60}"
        puts title.center(60)
        puts '=' * 60

        return if results.empty?

        # Sort by performance
        sorted_results = results.sort_by { |_, data| -data[:best_fitness] }

        puts "\nPerformance Ranking:"
        sorted_results.each_with_index do |(name, data), index|
          puts "#{index + 1}. #{name.ljust(25)} Fitness: #{data[:best_fitness].round(4)} " \
               "(#{data[:generations]} gen)"
        end

        # Performance comparison chart
        puts "\nRelative Performance:"
        max_fitness = sorted_results.first[1][:best_fitness]
        min_fitness = sorted_results.last[1][:best_fitness]
        range = max_fitness - min_fitness

        sorted_results.each do |name, data|
          if range > 0
            relative_performance = (data[:best_fitness] - min_fitness) / range
            bar_length = (relative_performance * 40).round
            bar = ('█' * bar_length) + ('▒' * (40 - bar_length))
          else
            bar = '█' * 40
          end

          puts "#{name.ljust(20)} |#{bar}| #{data[:best_fitness].round(4)}"
        end

        # Analysis insights
        puts "\nAnalysis Insights:"
        analyze_operator_performance(sorted_results)
      end

      def self.plot_parameter_sensitivity(sensitivity_data, title = 'Parameter Sensitivity Analysis')
        puts "\n#{'=' * 70}"
        puts title.center(70)
        puts '=' * 70

        sensitivity_data.each do |param_name, results|
          puts "\n#{param_name.to_s.capitalize} Sensitivity:"

          # Sort by parameter value
          sorted_results = results.sort_by { |value, _| value }

          # Find range for normalization
          fitness_values = sorted_results.map { |_, fitness| fitness }
          max_fitness = fitness_values.max
          min_fitness = fitness_values.min
          range = max_fitness - min_fitness

          # Plot parameter effect
          sorted_results.each do |param_value, fitness|
            if range > 0
              normalized = (fitness - min_fitness) / range
              bar_length = (normalized * 30).round
              bar = ('█' * bar_length) + ('▒' * (30 - bar_length))
            else
              bar = '█' * 30
            end

            puts "#{param_value.to_s.ljust(8)} |#{bar}| #{fitness.round(4)}"
          end

          # Best value for this parameter
          best_param, best_fitness = sorted_results.max_by { |_, fitness| fitness }
          puts "Best value: #{best_param} (fitness: #{best_fitness.round(4)})"

          # Sensitivity score
          sensitivity = range / max_fitness
          puts "Sensitivity: #{(sensitivity * 100).round(1)}% - #{interpret_sensitivity(sensitivity)}"
        end
      end

      def self.plot_convergence_analysis(monitor, title = 'Convergence Analysis')
        puts "\n#{'=' * 60}"
        puts title.center(60)
        puts '=' * 60

        stats = monitor.generation_stats
        return if stats.empty?

        best_fitness = stats.map { |s| s[:best_fitness] }
        stats.map { |s| s[:average_fitness] }
        diversity = stats.map { |s| s[:diversity] }

        # Convergence metrics
        convergence_gen = find_convergence_generation(best_fitness)
        stagnation_gens = count_stagnation_generations(best_fitness)
        premature_convergence = detect_premature_convergence(best_fitness, diversity)

        puts "\nConvergence Metrics:"
        puts "• Convergence generation: #{convergence_gen || 'Not converged'}"
        puts "• Stagnation generations: #{stagnation_gens}"
        puts "• Premature convergence: #{premature_convergence ? 'Yes' : 'No'}"

        # Plot convergence indicators
        puts "\nConvergence Indicators:"
        plot_convergence_rate(best_fitness)

        # Recommendations
        puts "\nRecommendations:"
        provide_convergence_recommendations(convergence_gen, stagnation_gens, premature_convergence)
      end

      def self.plot_diversity_evolution(monitor, title = 'Diversity Evolution')
        puts "\n#{'=' * 60}"
        puts title.center(60)
        puts '=' * 60

        stats = monitor.generation_stats
        return if stats.empty?

        diversity = stats.map { |s| s[:diversity] }
        generations = (0...stats.length).to_a

        # Plot diversity over time
        plot_ascii_chart('Population Diversity Over Time', generations, diversity)

        # Diversity analysis
        initial_diversity = diversity.first
        final_diversity = diversity.last
        min_diversity = diversity.min
        max_diversity = diversity.max

        puts "\nDiversity Analysis:"
        puts "• Initial diversity: #{initial_diversity.round(4)}"
        puts "• Final diversity: #{final_diversity.round(4)}"
        puts "• Minimum diversity: #{min_diversity.round(4)}"
        puts "• Maximum diversity: #{max_diversity.round(4)}"
        puts "• Diversity retention: #{(final_diversity / initial_diversity * 100).round(1)}%"

        # Diversity trend analysis
        trend = analyze_diversity_trend(diversity)
        puts "• Diversity trend: #{trend}"

        # Recommendations based on diversity
        provide_diversity_recommendations(initial_diversity, final_diversity, min_diversity)
      end

      def self.create_algorithm_comparison_chart(comparison_results, title = 'Algorithm Comparison')
        puts "\n#{'=' * 60}"
        puts title.center(60)
        puts '=' * 60

        return if comparison_results.empty?

        # Extract algorithm results
        algorithms = comparison_results.keys
        fitnesses = comparison_results.values

        # Normalize for comparison
        max_fitness = fitnesses.max
        min_fitness = fitnesses.min
        range = max_fitness - min_fitness

        puts "\nAlgorithm Performance Comparison:"
        algorithms.zip(fitnesses).each do |algorithm, fitness|
          if range > 0
            normalized = (fitness - min_fitness) / range
            bar_length = (normalized * 40).round
            bar = ('█' * bar_length) + ('▒' * (40 - bar_length))
          else
            bar = '█' * 40
          end

          puts "#{algorithm.to_s.ljust(20)} |#{bar}| #{fitness.round(4)}"
        end

        # Performance analysis
        best_algorithm = algorithms[fitnesses.index(fitnesses.max)]
        worst_algorithm = algorithms[fitnesses.index(fitnesses.min)]

        puts "\nPerformance Analysis:"
        puts "• Best performer: #{best_algorithm} (#{fitnesses.max.round(4)})"
        puts "• Worst performer: #{worst_algorithm} (#{fitnesses.min.round(4)})"
        puts "• Performance gap: #{(fitnesses.max - fitnesses.min).round(4)}"

        if range > 0
          improvement = (fitnesses.max - fitnesses.min) / fitnesses.min * 100
          puts "• Relative improvement: #{improvement.round(1)}%"
        end

        # Algorithm characteristics
        puts "\nAlgorithm Characteristics:"
        provide_algorithm_insights(comparison_results)
      end

      def self.plot_ascii_chart(title, x_data, y_data, _width = 60, height = 15)
        puts "\n#{title}:"
        return if y_data.empty?

        # Normalize data
        min_y = y_data.min
        max_y = y_data.max
        range_y = max_y - min_y

        return if range_y == 0

        # Create chart
        (height - 1).downto(0) do |row|
          line = ''
          y_threshold = min_y + (range_y * row / (height - 1))

          x_data.each_with_index do |_, index|
            y_value = y_data[index]
            char = y_value >= y_threshold ? '█' : ' '
            line += char
          end

          puts "#{y_threshold.round(2).to_s.rjust(8)} |#{line}"
        end

        # X-axis
        x_axis = "#{''.rjust(9)}+#{'-' * x_data.length}"
        puts x_axis

        # Labels
        puts "#{''.rjust(10)}Generation"
      end

      def self.plot_histogram(data, bins = 10)
        return if data.empty?

        min_val = data.min
        max_val = data.max
        range = max_val - min_val

        return if range == 0

        bin_width = range / bins
        histogram = Array.new(bins, 0)

        data.each do |value|
          bin_index = [(value - min_val) / bin_width, bins - 1].min.floor
          histogram[bin_index] += 1
        end

        max_count = histogram.max

        bins.times do |i|
          bin_start = min_val + (i * bin_width)
          bin_end = bin_start + bin_width
          count = histogram[i]

          if max_count > 0
            bar_length = (count * 30 / max_count).round
            bar = '█' * bar_length
          else
            bar = ''
          end

          puts "#{bin_start.round(2).to_s.rjust(6)}-#{bin_end.round(2).to_s.ljust(6)} |#{bar} (#{count})"
        end
      end

      def self.calculate_population_diversity(population)
        return 0.0 if population.size < 2

        total_distance = 0.0
        count = 0

        population.each_with_index do |ind1, i|
          population.each_with_index do |ind2, j|
            next if i >= j

            distance = chromosome_distance(ind1, ind2)
            total_distance += distance
            count += 1
          end
        end

        count > 0 ? total_distance / count : 0.0
      end

      def self.chromosome_distance(chr1, chr2)
        genes1 = chr1.genes
        genes2 = chr2.genes

        if genes1.first.is_a?(Numeric)
          # Euclidean distance for real-valued
          sum = genes1.zip(genes2).sum { |a, b| (a - b)**2 }
          Math.sqrt(sum)
        else
          # Hamming distance for discrete
          genes1.zip(genes2).count { |a, b| a != b }.to_f
        end
      end

      def self.standard_deviation(data)
        return 0.0 if data.empty?

        mean = data.sum / data.size.to_f
        variance = data.sum { |x| (x - mean)**2 } / data.size.to_f
        Math.sqrt(variance)
      end

      def self.find_convergence_generation(fitness_data)
        return nil if fitness_data.length < 10

        # Find when improvement becomes minimal
        (10...fitness_data.length).each do |i|
          recent_improvement = fitness_data[i] - fitness_data[i - 10]
          return i if recent_improvement < 0.01
        end

        nil
      end

      def self.count_stagnation_generations(fitness_data)
        return 0 if fitness_data.length < 2

        stagnation_count = 0
        max_stagnation = 0

        (1...fitness_data.length).each do |i|
          if fitness_data[i] == fitness_data[i - 1]
            stagnation_count += 1
            max_stagnation = [max_stagnation, stagnation_count].max
          else
            stagnation_count = 0
          end
        end

        max_stagnation
      end

      def self.detect_premature_convergence(fitness_data, diversity_data)
        return false if fitness_data.length < 10 || diversity_data.empty?

        # Check if diversity dropped rapidly while fitness plateaued
        final_diversity = diversity_data.last
        initial_diversity = diversity_data.first

        diversity_loss = (initial_diversity - final_diversity) / initial_diversity

        # Check for early fitness plateau
        mid_point = fitness_data.length / 2
        early_fitness = fitness_data[mid_point]
        final_fitness = fitness_data.last

        late_improvement = (final_fitness - early_fitness) / early_fitness

        diversity_loss > 0.8 && late_improvement < 0.05
      end

      def self.plot_convergence_rate(fitness_data)
        return if fitness_data.length < 5

        # Calculate improvement rate over sliding windows
        window_size = [fitness_data.length / 4, 5].max
        rates = []

        (window_size...fitness_data.length).each do |i|
          start_fitness = fitness_data[i - window_size]
          end_fitness = fitness_data[i]
          rate = (end_fitness - start_fitness) / window_size
          rates << rate
        end

        # Plot convergence rate
        puts 'Improvement Rate Over Time:'
        max_rate = rates.map(&:abs).max

        rates.each_with_index do |rate, i|
          if max_rate > 0
            normalized_rate = rate / max_rate
            bar_length = (normalized_rate.abs * 20).round
            bar = rate >= 0 ? '█' * bar_length : '-' * bar_length
          else
            bar = ''
          end

          generation = i + window_size
          puts "Gen #{generation.to_s.rjust(3)}: #{bar} #{rate.round(6)}"
        end
      end

      def self.analyze_diversity_trend(diversity_data)
        return 'insufficient data' if diversity_data.length < 5

        # Compare first quarter vs last quarter
        quarter_size = diversity_data.length / 4
        first_quarter_avg = diversity_data[0...quarter_size].sum / quarter_size
        last_quarter_avg = diversity_data[-quarter_size..].sum / quarter_size

        change_ratio = last_quarter_avg / first_quarter_avg

        case change_ratio
        when 0...0.3
          'rapid decline'
        when 0.3...0.7
          'steady decline'
        when 0.7...0.9
          'gradual decline'
        when 0.9...1.1
          'stable'
        when 1.1...1.5
          'increasing'
        else
          'highly variable'
        end
      end

      def self.analyze_operator_performance(sorted_results)
        best_performance = sorted_results.first[1][:best_fitness]
        worst_performance = sorted_results.last[1][:best_fitness]

        performance_gap = best_performance - worst_performance
        relative_gap = performance_gap / best_performance * 100

        if relative_gap < 5
          puts '• Small performance differences - all operators work similarly'
        elsif relative_gap < 20
          puts '• Moderate performance differences - operator choice matters'
        else
          puts '• Large performance differences - operator choice is critical'
        end

        # Analyze convergence speed
        avg_generations = sorted_results.sum { |_, data| data[:generations] } / sorted_results.length
        fast_convergers = sorted_results.select { |_, data| data[:generations] < avg_generations }

        puts "• Fast converging operators: #{fast_convergers.map(&:first).join(', ')}" unless fast_convergers.empty?
      end

      def self.interpret_sensitivity(sensitivity)
        case sensitivity
        when 0...0.05
          'low impact'
        when 0.05...0.15
          'moderate impact'
        when 0.15...0.3
          'high impact'
        else
          'critical parameter'
        end
      end

      def self.provide_convergence_recommendations(convergence_gen, stagnation_gens, premature)
        if premature
          puts '• Increase mutation rate to maintain diversity'
          puts '• Consider larger population size'
          puts '• Use diversity-preserving selection methods'
        elsif convergence_gen && convergence_gen < 20
          puts '• Good convergence speed - current settings work well'
        elsif stagnation_gens > 10
          puts '• High stagnation - increase exploration'
          puts '• Consider adaptive mutation rates'
        else
          puts '• Convergence behavior appears normal'
        end
      end

      def self.provide_diversity_recommendations(initial, final, minimum)
        retention_rate = final / initial

        if retention_rate < 0.1
          puts '• Very low diversity retention - increase mutation rate'
          puts '• Consider diversity-preserving operators'
        elsif retention_rate < 0.3
          puts '• Moderate diversity loss - monitor for premature convergence'
        else
          puts '• Good diversity maintenance'
        end

        puts '• Population nearly converged - consider re-diversification' if minimum < 0.05
      end

      def self.provide_algorithm_insights(results)
        ga_fitness = results[:genetic_algorithm]
        random_fitness = results[:random_search]
        hc_fitness = results[:hill_climbing]

        if ga_fitness > random_fitness * 1.2
          puts '• GA shows clear advantage over random search'
        else
          puts '• GA advantage over random search is marginal'
        end

        if ga_fitness > hc_fitness * 1.1
          puts '• GA outperforms hill climbing (good for multimodal problems)'
        elsif hc_fitness > ga_fitness * 1.1
          puts '• Hill climbing competitive (problem may be unimodal)'
        else
          puts '• GA and hill climbing show similar performance'
        end
      end
    end
  end
end
