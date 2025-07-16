# frozen_string_literal: true

# Enhanced operators for educational genetic algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative 'operators'

module Ai4r
  module GeneticAlgorithm
    # Enhanced selection operators with educational features
    module EnhancedSelectionOperators
      # Rank-based selection - selects based on rank rather than raw fitness
      class RankSelection
        def name
          'Rank Selection'
        end

        def description
          'Selects individuals based on their rank (position) in the sorted population. ' \
            'This reduces the impact of fitness scaling issues and provides more balanced selection pressure.'
        end

        def select(population, count)
          raise ArgumentError, 'Population cannot be empty' if population.empty?

          # Sort population by fitness (best first)
          sorted_pop = population.sort_by(&:fitness).reverse

          # Assign selection probabilities based on rank
          total_rank = sorted_pop.length * (sorted_pop.length + 1) / 2

          selected = []
          count.times do
            # Weighted random selection based on rank
            target = rand * total_rank
            cumulative = 0

            sorted_pop.each_with_index do |individual, index|
              rank = sorted_pop.length - index # Higher rank for better individuals
              cumulative += rank

              if cumulative >= target
                selected << individual
                break
              end
            end
          end

          selected
        end

        def educational_notes
          [
            'Rank selection eliminates fitness scaling problems',
            'Selection pressure is consistent regardless of fitness values',
            'Good for problems where fitness values vary widely',
            'Less aggressive than tournament selection with high tournament size'
          ]
        end
      end

      # Stochastic Universal Sampling - more uniform selection
      class StochasticUniversalSampling
        def name
          'Stochastic Universal Sampling'
        end

        def description
          'Uses evenly spaced selection points to ensure more uniform selection. ' \
            'Reduces the variance of selection compared to roulette wheel selection.'
        end

        def select(population, count)
          return [] if population.empty?

          # Calculate fitness sum
          fitness_sum = population.sum(&:fitness)
          return population.sample(count) if fitness_sum <= 0

          # Calculate pointer spacing
          pointer_distance = fitness_sum / count.to_f
          start = rand * pointer_distance

          selected = []
          cumulative_fitness = 0
          pointer = start
          pop_index = 0

          count.times do
            # Find individual for current pointer
            while cumulative_fitness < pointer && pop_index < population.length
              cumulative_fitness += population[pop_index].fitness
              pop_index += 1
            end

            selected << population[[pop_index - 1, 0].max]
            pointer += pointer_distance
          end

          selected
        end

        def educational_notes
          [
            'More uniform selection than roulette wheel',
            'Reduces selection variance',
            'Ensures expected number of selections is closer to actual',
            'Good for maintaining population diversity'
          ]
        end
      end

      # Boltzmann selection - adaptive selection pressure
      class BoltzmannSelection
        attr_reader :temperature, :cooling_rate

        def initialize(initial_temperature = 100.0, cooling_rate = 0.95)
          @initial_temperature = initial_temperature
          @temperature = initial_temperature
          @cooling_rate = cooling_rate
        end

        def name
          'Boltzmann Selection'
        end

        def description
          'Adaptive selection that starts with low pressure (high temperature) and ' \
            'gradually increases pressure (cooling) as evolution progresses. ' \
            'Current temperature: ' + @temperature.round(2).to_s
        end

        def select(population, count)
          return [] if population.empty?

          # Calculate Boltzmann probabilities
          boltzmann_fitness = population.map do |individual|
            Math.exp(individual.fitness / @temperature)
          end

          total_boltzmann = boltzmann_fitness.sum
          return population.sample(count) if total_boltzmann <= 0

          selected = []
          count.times do
            target = rand * total_boltzmann
            cumulative = 0

            population.each_with_index do |individual, index|
              cumulative += boltzmann_fitness[index]
              if cumulative >= target
                selected << individual
                break
              end
            end
          end

          # Cool down for next generation
          @temperature *= @cooling_rate

          selected
        end

        def reset_temperature
          @temperature = @initial_temperature
        end

        def educational_notes
          [
            'Adapts selection pressure over time',
            'High temperature = low pressure (more exploration)',
            'Low temperature = high pressure (more exploitation)',
            'Inspired by simulated annealing',
            'Good for avoiding premature convergence early on'
          ]
        end
      end
    end

    # Enhanced crossover operators
    module EnhancedCrossoverOperators
      # Two-point crossover
      class TwoPointCrossover
        def name
          'Two-Point Crossover'
        end

        def description
          'Selects two random crossover points and exchanges the middle segment between parents. ' \
            'Often better than single-point for preserving building blocks.'
        end

        def crossover(parent1, parent2)
          length = [parent1.genes.length, parent2.genes.length].min
          return [parent1.clone, parent2.clone] if length <= 2

          # Select two crossover points
          points = [rand(length - 1), rand(length - 1)].sort
          point1, point2 = points
          point2 = point1 + 1 if point1 == point2 # Ensure different points

          # Create offspring
          offspring1_genes = parent1.genes[0...point1] +
                             parent2.genes[point1..point2] +
                             parent1.genes[(point2 + 1)..]

          offspring2_genes = parent2.genes[0...point1] +
                             parent1.genes[point1..point2] +
                             parent2.genes[(point2 + 1)..]

          [
            parent1.class.new(offspring1_genes),
            parent2.class.new(offspring2_genes)
          ]
        end

        def educational_notes
          [
            'Exchanges middle segment between two points',
            'Better building block preservation than single-point',
            'Good for problems with positional dependencies',
            'More disruptive than single-point crossover'
          ]
        end
      end

      # Arithmetic crossover for real-valued chromosomes
      class ArithmeticCrossover
        attr_reader :alpha

        def initialize(alpha = 0.5)
          @alpha = alpha # Blending parameter
        end

        def name
          'Arithmetic Crossover'
        end

        def description
          'Performs arithmetic combination of parent genes: offspring = α*parent1 + (1-α)*parent2. ' \
            'Alpha parameter: ' + @alpha.to_s + '. Good for real-valued optimization.'
        end

        def crossover(parent1, parent2)
          return [parent1.clone, parent2.clone] unless parent1.genes.first.is_a?(Numeric)

          offspring1_genes = []
          offspring2_genes = []

          parent1.genes.each_with_index do |gene1, index|
            gene2 = parent2.genes[index]

            # Arithmetic combination
            offspring1_genes << ((@alpha * gene1) + ((1 - @alpha) * gene2))
            offspring2_genes << (((1 - @alpha) * gene1) + (@alpha * gene2))
          end

          [
            parent1.class.new(offspring1_genes),
            parent2.class.new(offspring2_genes)
          ]
        end

        def educational_notes
          [
            'Specifically designed for real-valued genes',
            'Creates offspring in the convex hull of parents',
            'Alpha = 0.5 gives equal contribution from both parents',
            'Good for continuous optimization problems',
            'Preserves feasibility if parents are feasible'
          ]
        end
      end

      # Simulated Binary Crossover (SBX)
      class SimulatedBinaryCrossover
        attr_reader :eta

        def initialize(eta = 2.0)
          @eta = eta # Distribution index
        end

        def name
          'Simulated Binary Crossover (SBX)'
        end

        def description
          'Simulates the behavior of single-point crossover for real variables. ' \
            "Distribution index η = #{@eta}. Higher η creates offspring closer to parents."
        end

        def crossover(parent1, parent2)
          return [parent1.clone, parent2.clone] unless parent1.genes.first.is_a?(Numeric)

          offspring1_genes = []
          offspring2_genes = []

          parent1.genes.each_with_index do |x1, index|
            x2 = parent2.genes[index]

            if rand < 0.5 # Crossover probability per gene
              if (x1 - x2).abs > 1e-14
                # Calculate beta
                u = rand
                beta_q = if u <= 0.5
                           (2.0 * u)**(1.0 / (@eta + 1.0))
                         else
                           (1.0 / (2.0 * (1.0 - u)))**(1.0 / (@eta + 1.0))
                         end

                # Create offspring
                c1 = 0.5 * ((x1 + x2) - (beta_q * (x1 - x2).abs))
                c2 = 0.5 * ((x1 + x2) + (beta_q * (x1 - x2).abs))

                offspring1_genes << c1
                offspring2_genes << c2
              else
                offspring1_genes << x1
                offspring2_genes << x2
              end
            else
              offspring1_genes << x1
              offspring2_genes << x2
            end
          end

          [
            parent1.class.new(offspring1_genes),
            parent2.class.new(offspring2_genes)
          ]
        end

        def educational_notes
          [
            'Designed specifically for real-valued optimization',
            'Mimics binary crossover behavior for continuous variables',
            'Distribution index controls spread of offspring',
            'Low η = wide spread, high η = narrow spread',
            'Widely used in real-coded genetic algorithms'
          ]
        end
      end

      # Order Crossover (OX) for permutations
      class OrderCrossover
        def name
          'Order Crossover (OX)'
        end

        def description
          'Preserves the relative order of elements from one parent while incorporating ' \
            'elements from the other. Good for permutation problems like TSP.'
        end

        def crossover(parent1, parent2)
          length = parent1.genes.length
          return [parent1.clone, parent2.clone] if length <= 2

          # Select crossover segment
          point1 = rand(length)
          point2 = rand(length)
          point1, point2 = point2, point1 if point1 > point2

          # Create offspring 1
          offspring1 = Array.new(length)
          offspring1[point1..point2] = parent1.genes[point1..point2]

          # Fill remaining positions with parent2's order
          fill_remaining_ox(offspring1, parent2.genes, point1, point2)

          # Create offspring 2
          offspring2 = Array.new(length)
          offspring2[point1..point2] = parent2.genes[point1..point2]

          # Fill remaining positions with parent1's order
          fill_remaining_ox(offspring2, parent1.genes, point1, point2)

          [
            parent1.class.new(offspring1),
            parent2.class.new(offspring2)
          ]
        end

        private

        def fill_remaining_ox(offspring, source_parent, point1, point2)
          used = Set.new(offspring[point1..point2].compact)
          fill_index = (point2 + 1) % offspring.length

          source_parent.each do |gene|
            next if used.include?(gene)

            # Find next empty position
            fill_index = (fill_index + 1) % offspring.length while offspring[fill_index]

            offspring[fill_index] = gene
            fill_index = (fill_index + 1) % offspring.length
          end
        end

        def educational_notes
          [
            'Specifically designed for permutation chromosomes',
            'Preserves relative ordering from parents',
            'No duplicate elements in offspring',
            'Good for scheduling and routing problems',
            'Maintains feasibility of permutation constraints'
          ]
        end
      end

      # Cycle Crossover (CX) for permutations
      class CycleCrossover
        def name
          'Cycle Crossover (CX)'
        end

        def description
          'Creates offspring by following cycles in the parent permutations. ' \
            'Each element appears in the same position as in one of the parents.'
        end

        def crossover(parent1, parent2)
          length = parent1.genes.length
          return [parent1.clone, parent2.clone] if length <= 1

          offspring1 = Array.new(length)
          offspring2 = Array.new(length)

          used = Array.new(length, false)
          cycle_from_parent1 = true

          (0...length).each do |start|
            next if used[start]

            # Follow the cycle
            current_pos = start
            loop do
              used[current_pos] = true

              if cycle_from_parent1
                offspring1[current_pos] = parent1.genes[current_pos]
                offspring2[current_pos] = parent2.genes[current_pos]
              else
                offspring1[current_pos] = parent2.genes[current_pos]
                offspring2[current_pos] = parent1.genes[current_pos]
              end

              # Find next position in cycle
              target_value = cycle_from_parent1 ? parent2.genes[current_pos] : parent1.genes[current_pos]
              current_pos = (cycle_from_parent1 ? parent1.genes : parent2.genes).index(target_value)

              break if current_pos == start || used[current_pos]
            end

            # Alternate between parents for next cycle
            cycle_from_parent1 = !cycle_from_parent1
          end

          [
            parent1.class.new(offspring1),
            parent2.class.new(offspring2)
          ]
        end

        def educational_notes
          [
            'Maintains absolute positions of elements',
            'Each element comes from exactly one parent',
            'Good for problems where position matters',
            'No illegal permutations created',
            'More conservative than order crossover'
          ]
        end
      end
    end

    # Enhanced mutation operators
    module EnhancedMutationOperators
      # Polynomial mutation for real values
      class PolynomialMutation
        attr_reader :eta, :bounds

        def initialize(eta = 20.0, bounds = nil)
          @eta = eta # Distribution index
          @bounds = bounds # [min, max] bounds for each gene
        end

        def name
          'Polynomial Mutation'
        end

        def description
          'Self-adaptive mutation for real values using polynomial probability distribution. ' \
            "Distribution index η = #{@eta}. Higher η creates smaller mutations."
        end

        def mutate(individual, mutation_rate)
          mutated = individual.clone

          mutated.genes.each_with_index do |gene, index|
            next unless gene.is_a?(Numeric)
            next if rand >= mutation_rate

            # Get bounds for this gene
            if @bounds
              lower_bound = @bounds.is_a?(Array) && @bounds[index].is_a?(Array) ? @bounds[index][0] : @bounds[0]
              upper_bound = @bounds.is_a?(Array) && @bounds[index].is_a?(Array) ? @bounds[index][1] : @bounds[1]
            else
              lower_bound = gene - 1.0
              upper_bound = gene + 1.0
            end

            # Calculate delta
            delta1 = (gene - lower_bound) / (upper_bound - lower_bound)
            delta2 = (upper_bound - gene) / (upper_bound - lower_bound)

            u = rand
            if u <= 0.5
              xy = 1.0 - delta1
              val = (2.0 * u) + ((1.0 - (2.0 * u)) * (xy**(@eta + 1.0)))
              delta_q = (val**(1.0 / (@eta + 1.0))) - 1.0
            else
              xy = 1.0 - delta2
              val = (2.0 * (1.0 - u)) + (2.0 * (u - 0.5) * (xy**(@eta + 1.0)))
              delta_q = 1.0 - (val**(1.0 / (@eta + 1.0)))
            end

            # Apply mutation
            mutated_value = gene + (delta_q * (upper_bound - lower_bound))
            mutated_value = [[mutated_value, lower_bound].max, upper_bound].min

            mutated.genes[index] = mutated_value
          end

          mutated.invalidate_fitness if mutated.respond_to?(:invalidate_fitness)
          mutated
        end

        def educational_notes
          [
            'Designed specifically for real-valued chromosomes',
            'Self-adaptive - mutation size depends on gene value',
            'Respects variable bounds',
            'Distribution index controls mutation spread',
            'Widely used in real-coded genetic algorithms'
          ]
        end
      end

      # Gaussian mutation
      class GaussianMutation
        attr_reader :sigma

        def initialize(sigma = 0.1)
          @sigma = sigma # Standard deviation
        end

        def name
          'Gaussian Mutation'
        end

        def description
          'Adds Gaussian (normal) random noise to real-valued genes. ' \
            "Standard deviation σ = #{@sigma}. Smaller σ = smaller mutations."
        end

        def mutate(individual, mutation_rate)
          mutated = individual.clone

          mutated.genes.each_with_index do |gene, index|
            next unless gene.is_a?(Numeric)
            next if rand >= mutation_rate

            # Add Gaussian noise
            noise = gaussian_random * @sigma
            mutated.genes[index] = gene + noise
          end

          mutated.invalidate_fitness if mutated.respond_to?(:invalidate_fitness)
          mutated
        end

        def educational_notes
          [
            'Simple and effective for real-valued problems',
            'Normally distributed mutations around current value',
            'Standard deviation controls mutation size',
            'Can be adaptive by changing σ over time',
            'Good balance between local and global search'
          ]
        end

        private

        def gaussian_random
          # Box-Muller transformation
          @spare_random ||= nil

          if @spare_random
            result = @spare_random
            @spare_random = nil
            result
          else
            u = rand
            v = rand
            mag = @sigma * Math.sqrt(-2.0 * Math.log(u))
            @spare_random = mag * Math.cos(2.0 * Math::PI * v)
            mag * Math.sin(2.0 * Math::PI * v)
          end
        end
      end

      # Inversion mutation for permutations
      class InversionMutation
        def name
          'Inversion Mutation'
        end

        def description
          'Reverses the order of elements in a randomly selected segment. ' \
            'Good for permutation problems where sequence order matters.'
        end

        def mutate(individual, mutation_rate)
          return individual.clone if rand >= mutation_rate

          mutated = individual.clone
          length = mutated.genes.length
          return mutated if length <= 2

          # Select random segment to invert
          point1 = rand(length)
          point2 = rand(length)
          point1, point2 = point2, point1 if point1 > point2

          # Invert the segment
          mutated.genes[point1..point2] = mutated.genes[point1..point2].reverse

          mutated.invalidate_fitness if mutated.respond_to?(:invalidate_fitness)
          mutated
        end

        def educational_notes
          [
            'Maintains all elements (no loss or duplication)',
            'Changes relative order of elements',
            'Good for routing and scheduling problems',
            'Can help escape local optima',
            'Preserves permutation property'
          ]
        end
      end

      # Scramble mutation for permutations
      class ScrambleMutation
        def name
          'Scramble Mutation'
        end

        def description
          'Randomly shuffles elements in a selected segment. ' \
            'More disruptive than inversion mutation.'
        end

        def mutate(individual, mutation_rate)
          return individual.clone if rand >= mutation_rate

          mutated = individual.clone
          length = mutated.genes.length
          return mutated if length <= 2

          # Select random segment to scramble
          point1 = rand(length)
          point2 = rand(length)
          point1, point2 = point2, point1 if point1 > point2

          # Scramble the segment
          segment = mutated.genes[point1..point2].shuffle
          mutated.genes[point1..point2] = segment

          mutated.invalidate_fitness if mutated.respond_to?(:invalidate_fitness)
          mutated
        end

        def educational_notes
          [
            'More disruptive than inversion mutation',
            'Randomizes order within selected segment',
            'Good for escaping local optima',
            'Higher exploration capability',
            'Use with lower mutation rates'
          ]
        end
      end

      # Adaptive mutation - changes rate based on population diversity
      class AdaptiveMutation
        attr_reader :base_operator, :min_rate, :max_rate

        def initialize(base_operator, min_rate = 0.01, max_rate = 0.1)
          @base_operator = base_operator
          @min_rate = min_rate
          @max_rate = max_rate
          @population_diversity = 1.0
        end

        def name
          "Adaptive #{@base_operator.name}"
        end

        def description
          "#{@base_operator.description} Adapts mutation rate based on population diversity. " \
            "Current rate: #{current_rate.round(4)} (range: #{@min_rate}-#{@max_rate})"
        end

        def mutate(individual, _base_mutation_rate)
          adaptive_rate = current_rate
          @base_operator.mutate(individual, adaptive_rate)
        end

        def update_diversity(diversity)
          @population_diversity = [diversity, 0.001].max # Avoid division by zero
        end

        def educational_notes
          [
            'Automatically adapts mutation rate',
            'High diversity → low mutation rate',
            'Low diversity → high mutation rate',
            'Helps prevent premature convergence',
            'Self-regulating exploration/exploitation'
          ]
        end

        private

        def current_rate
          # Higher diversity = lower mutation rate, lower diversity = higher mutation rate
          # This helps maintain diversity when it's low
          diversity_factor = 1.0 - [@population_diversity, 1.0].min
          @min_rate + (diversity_factor * (@max_rate - @min_rate))
        end
      end
    end

    # Enhanced replacement strategies
    module EnhancedReplacementOperators
      # Steady-state replacement
      class SteadyStateReplacement
        attr_reader :replacement_count

        def initialize(replacement_count = 2)
          @replacement_count = replacement_count
        end

        def name
          'Steady-State Replacement'
        end

        def description
          "Replaces only #{@replacement_count} worst individuals each generation. " \
            'Maintains most of the population, providing more gradual evolution.'
        end

        def replace(population, offspring)
          return population if offspring.empty?

          # Sort population by fitness (worst first)
          sorted_pop = population.sort_by(&:fitness)

          # Sort offspring by fitness (best first)
          sorted_offspring = offspring.sort_by(&:fitness).reverse

          # Replace worst individuals with best offspring
          replace_count = [@replacement_count, offspring.length, population.length].min

          new_population = sorted_pop.dup
          (0...replace_count).each do |i|
            new_population[i] = sorted_offspring[i] if sorted_offspring[i]
          end

          new_population
        end

        def educational_notes
          [
            'Less disruptive than generational replacement',
            'Maintains population stability',
            'Good for preserving diversity',
            'Slower convergence but more exploration',
            'Often used in real-world applications'
          ]
        end
      end

      # Tournament replacement
      class TournamentReplacement
        attr_reader :tournament_size

        def initialize(tournament_size = 3)
          @tournament_size = tournament_size
        end

        def name
          'Tournament Replacement'
        end

        def description
          'Uses tournament selection to determine which individuals to replace. ' \
            "Tournament size: #{@tournament_size}. Each offspring competes with random individuals."
        end

        def replace(population, offspring)
          return population if offspring.empty?

          new_population = population.dup

          offspring.each do |child|
            # Select random individuals for tournament
            tournament = new_population.sample(@tournament_size)

            # Find worst individual in tournament
            worst = tournament.min_by(&:fitness)

            # Replace if child is better
            if child.fitness > worst.fitness
              index = new_population.index(worst)
              new_population[index] = child if index
            end
          end

          new_population
        end

        def educational_notes
          [
            'Localized competition for replacement',
            'Tournament size controls selection pressure',
            'Maintains population size exactly',
            'Good balance of exploration and exploitation',
            'Can maintain multiple niches in population'
          ]
        end
      end

      # Age-based replacement
      class AgeBasedReplacement
        def initialize
          @individual_ages = {}
        end

        def name
          'Age-Based Replacement'
        end

        def description
          'Replaces oldest individuals in the population, regardless of fitness. ' \
            'Prevents any individual from dominating for too long.'
        end

        def replace(population, offspring)
          return population if offspring.empty?

          # Update ages
          population.each do |individual|
            @individual_ages[individual.object_id] ||= 0
            @individual_ages[individual.object_id] += 1
          end

          # Reset ages for new offspring
          offspring.each do |individual|
            @individual_ages[individual.object_id] = 0
          end

          # Sort by age (oldest first)
          aged_population = population.sort_by { |ind| @individual_ages[ind.object_id] }.reverse

          # Replace oldest with offspring
          replace_count = [offspring.length, population.length].min
          new_population = aged_population.dup

          (0...replace_count).each do |i|
            new_population[i] = offspring[i]
          end

          new_population
        end

        def educational_notes
          [
            'Enforces population turnover',
            'Prevents premature convergence',
            'Maintains genetic diversity',
            'Can lose good solutions due to age',
            'Good for dynamic optimization problems'
          ]
        end
      end
    end

    # Include all enhanced operators in the main module
    include EnhancedSelectionOperators
    include EnhancedCrossoverOperators
    include EnhancedMutationOperators
    include EnhancedReplacementOperators
  end
end
