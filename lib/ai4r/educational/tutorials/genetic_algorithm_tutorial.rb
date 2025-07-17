# frozen_string_literal: true

# Comprehensive tutorial system for genetic algorithms
# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r

require_relative '../../genetic_algorithm/educational_genetic_search'
require_relative '../../genetic_algorithm/examples'
require_relative '../../genetic_algorithm/enhanced_operators'

module Ai4r
  module GeneticAlgorithm
    # Interactive tutorial system for learning genetic algorithms
    class GATutorial
      def initialize
        @completed_lessons = []
        @current_lesson = nil
      end

      def start_interactive_tutorial
        puts '=' * 70
        puts 'Welcome to the Interactive Genetic Algorithm Tutorial!'
        puts '=' * 70
        puts
        puts 'This tutorial will guide you through genetic algorithms step by step.'
        puts "You'll learn concepts, see examples, and experiment with parameters."
        puts
        puts 'Available tutorial paths:'
        puts "1. Complete Beginner (start here if you're new to GAs)"
        puts '2. Intermediate Learner (familiar with optimization concepts)'
        puts '3. Advanced Practitioner (want to learn specific techniques)'
        puts '4. Problem-Specific Tutorials (TSP, scheduling, function optimization)'
        puts '5. Custom Tutorial (choose your own topics)'
        puts

        print 'Choose your path (1-5): '
        path = gets.chomp.to_i

        case path
        when 1
          run_beginner_tutorial
        when 2
          run_intermediate_tutorial
        when 3
          run_advanced_tutorial
        when 4
          run_problem_specific_tutorial
        when 5
          run_custom_tutorial
        else
          puts 'Invalid choice. Starting beginner tutorial.'
          run_beginner_tutorial
        end
      end

      def run_beginner_tutorial
        puts "\n#{'=' * 50}"
        puts 'BEGINNER TUTORIAL: Introduction to Genetic Algorithms'
        puts '=' * 50

        lessons = %i[
          introduction_to_optimization
          what_are_genetic_algorithms
          biological_inspiration
          basic_components
          simple_example_onemax
          understanding_fitness
          selection_explained
          crossover_explained
          mutation_explained
          putting_it_together
          first_hands_on_experiment
        ]

        run_lesson_sequence(lessons)
      end

      def run_intermediate_tutorial
        puts "\n#{'=' * 50}"
        puts 'INTERMEDIATE TUTORIAL: GA Components and Parameters'
        puts '=' * 50

        lessons = %i[
          ga_components_review
          selection_operators_comparison
          crossover_operators_comparison
          mutation_strategies
          parameter_tuning
          convergence_analysis
          diversity_management
          real_world_constraints
          hands_on_parameter_experiment
        ]

        run_lesson_sequence(lessons)
      end

      def run_advanced_tutorial
        puts "\n#{'=' * 50}"
        puts 'ADVANCED TUTORIAL: Sophisticated GA Techniques'
        puts '=' * 50

        lessons = %i[
          advanced_operators
          multi_objective_optimization
          dynamic_optimization
          constraint_handling
          hybrid_algorithms
          parallel_genetic_algorithms
          advanced_analysis_techniques
          research_project
        ]

        run_lesson_sequence(lessons)
      end

      def run_problem_specific_tutorial
        puts "\n#{'=' * 40}"
        puts 'PROBLEM-SPECIFIC TUTORIALS'
        puts '=' * 40

        puts 'Choose a problem domain:'
        puts '1. Traveling Salesman Problem (TSP)'
        puts '2. Function Optimization'
        puts '3. Scheduling Problems'
        puts '4. Combinatorial Optimization'
        puts '5. Constraint Satisfaction'

        print 'Choice (1-5): '
        choice = gets.chomp.to_i

        case choice
        when 1
          run_tsp_tutorial
        when 2
          run_function_optimization_tutorial
        when 3
          run_scheduling_tutorial
        when 4
          run_combinatorial_tutorial
        when 5
          run_constraint_tutorial
        else
          puts 'Invalid choice. Running function optimization tutorial.'
          run_function_optimization_tutorial
        end
      end

      def run_custom_tutorial
        puts "\n#{'=' * 40}"
        puts 'CUSTOM TUTORIAL BUILDER'
        puts '=' * 40

        available_topics = {
          selection: 'Selection Operators',
          crossover: 'Crossover Operators',
          mutation: 'Mutation Operators',
          parameters: 'Parameter Tuning',
          convergence: 'Convergence Analysis',
          diversity: 'Population Diversity',
          constraints: 'Constraint Handling',
          multi_objective: 'Multi-Objective Optimization',
          visualization: 'Algorithm Visualization',
          comparison: 'Algorithm Comparison'
        }

        puts 'Available topics:'
        available_topics.each_with_index do |(_key, name), index|
          puts "#{index + 1}. #{name}"
        end

        puts "\nEnter topic numbers separated by commas (e.g., 1,3,5):"
        input = gets.chomp
        topic_indices = input.split(',').map(&:to_i)

        selected_topics = topic_indices.filter_map { |i| available_topics.keys[i - 1] }

        if selected_topics.empty?
          puts 'No valid topics selected. Running basic tutorial.'
          run_beginner_tutorial
        else
          run_selected_topics(selected_topics)
        end
      end

      private

      def run_lesson_sequence(lessons)
        lessons.each_with_index do |lesson, index|
          puts "\n#{'-' * 50}"
          puts "Lesson #{index + 1}/#{lessons.length}: #{lesson.to_s.humanize}"
          puts '-' * 50

          @current_lesson = lesson
          send("lesson_#{lesson}")

          @completed_lessons << lesson

          unless lesson == lessons.last
            puts "\nPress Enter to continue to the next lesson..."
            gets
          end
        end

        puts "\n#{'=' * 50}"
        puts 'Tutorial Complete! 🎉'
        puts '=' * 50
        provide_next_steps
      end

      def lesson_introduction_to_optimization
        puts 'What is Optimization?'
        puts
        puts "Optimization is about finding the 'best' solution to a problem."
        puts 'Examples:'
        puts '• Finding the shortest route between cities'
        puts '• Maximizing profit while minimizing cost'
        puts '• Scheduling tasks to finish as quickly as possible'
        puts
        puts 'Traditional methods work well for simple problems, but real-world'
        puts 'problems are often too complex for traditional approaches.'
        puts
        puts 'This is where genetic algorithms come in!'
      end

      def lesson_what_are_genetic_algorithms
        puts 'What are Genetic Algorithms?'
        puts
        puts 'Genetic Algorithms (GAs) are optimization techniques inspired by'
        puts 'biological evolution. They work by:'
        puts
        puts '1. Creating a population of candidate solutions'
        puts '2. Evaluating how good each solution is (fitness)'
        puts "3. Selecting the best solutions to 'reproduce'"
        puts '4. Creating new solutions by combining good ones'
        puts '5. Occasionally making random changes (mutations)'
        puts '6. Repeating until we find a good solution'
        puts
        puts 'Just like in nature, better solutions survive and reproduce!'
      end

      def lesson_biological_inspiration
        puts 'Biological Inspiration'
        puts
        puts 'GAs are inspired by natural evolution:'
        puts
        puts 'Biology          →  Genetic Algorithm'
        puts 'Individual       →  Candidate Solution'
        puts 'DNA/Genes        →  Solution Representation'
        puts 'Fitness          →  Solution Quality'
        puts 'Reproduction     →  Creating New Solutions'
        puts 'Mutation         →  Random Changes'
        puts 'Natural Selection →  Selecting Best Solutions'
        puts 'Generation       →  Algorithm Iteration'
        puts
        puts 'This biological metaphor helps us understand how GAs work!'
      end

      def lesson_basic_components
        puts 'Basic GA Components'
        puts
        puts 'Every genetic algorithm has these key components:'
        puts
        puts '1. CHROMOSOME: How we represent a solution'
        puts '   Example: [1,0,1,1,0] for binary problems'
        puts
        puts '2. FITNESS FUNCTION: How we measure solution quality'
        puts '   Example: Count of 1s in binary string'
        puts
        puts '3. SELECTION: How we choose parents'
        puts '   Example: Pick better solutions more often'
        puts
        puts '4. CROSSOVER: How we combine solutions'
        puts '   Example: Mix parts from two parent solutions'
        puts
        puts '5. MUTATION: How we make random changes'
        puts '   Example: Flip random bits'
        puts
        puts 'These components work together to evolve better solutions!'
      end

      def lesson_simple_example_onemax
        puts 'Simple Example: OneMax Problem'
        puts
        puts "Let's see a GA in action with the OneMax problem:"
        puts 'Goal: Find a binary string with as many 1s as possible'
        puts
        puts 'Running OneMax example with tutorial mode...'
        puts

        # Create educational GA for OneMax
        ga = EducationalGeneticSearch.new(
          Configuration.new(:default,
                            population_size: 10,
                            max_generations: 20,
                            verbose: true),
          learning_mode: :guided
        )

        ga.run_tutorial(Examples::OneMaxChromosome, 8)

        puts "\nThis example showed you all the basic components in action!"
      end

      def lesson_understanding_fitness
        puts 'Understanding Fitness Functions'
        puts
        puts 'The fitness function is the heart of any GA. It tells the algorithm'
        puts "what makes a solution 'good'."
        puts
        puts 'Key properties of good fitness functions:'
        puts '• Higher values = better solutions'
        puts '• Fast to compute (we evaluate many solutions)'
        puts '• Captures the true objective'
        puts '• Provides meaningful gradients'
        puts
        puts "Let's explore different fitness landscapes..."

        demonstrate_fitness_landscapes
      end

      def lesson_selection_explained
        puts 'Selection Operators Deep Dive'
        puts
        puts 'Selection determines which solutions get to reproduce.'
        puts 'Different methods have different characteristics:'
        puts

        ga = EducationalGeneticSearch.new
        ga.learn_concept(:selection_pressure, Examples::OneMaxChromosome, 10)
      end

      def lesson_crossover_explained
        puts 'Crossover Operators Deep Dive'
        puts
        puts 'Crossover combines genetic material from parents to create offspring.'
        puts "Let's see different crossover methods in action:"
        puts

        demonstrate_crossover_operators
      end

      def lesson_mutation_explained
        puts 'Mutation Operators Deep Dive'
        puts
        puts 'Mutation introduces random changes to maintain diversity.'
        puts "Let's explore how mutation affects evolution:"
        puts

        ga = EducationalGeneticSearch.new
        ga.learn_concept(:exploration_vs_exploitation, Examples::OneMaxChromosome, 10)
      end

      def lesson_putting_it_together
        puts 'Putting It All Together'
        puts
        puts "Now let's see how all components work together in a complete GA."
        puts "We'll run a step-by-step execution to see each phase:"
        puts

        ga = EducationalGeneticSearch.new(
          Configuration.new(:default, population_size: 8, max_generations: 10)
        )

        ga.run_step_by_step(Examples::OneMaxChromosome, 6)
        puts "\nYou've now seen a complete GA execution!"
      end

      def lesson_first_hands_on_experiment
        puts 'Your First Hands-On Experiment'
        puts
        puts "Time to experiment! Let's try different parameter settings"
        puts "and see how they affect the algorithm's behavior."
        puts

        ga = EducationalGeneticSearch.new
        ga.interactive_parameter_tuning(Examples::OneMaxChromosome, 12)
      end

      def lesson_selection_operators_comparison
        puts 'Comparing Selection Operators'
        puts
        puts "Let's systematically compare different selection methods:"
        puts

        ga = EducationalGeneticSearch.new(learning_mode: :comparative)
        ga.run_comparative_analysis(Examples::SphereChromosome, 5)
        ga.visualize_comparisons
      end

      def lesson_parameter_tuning
        puts 'Parameter Tuning and Sensitivity Analysis'
        puts
        puts 'Understanding how parameters affect performance is crucial.'
        puts "Let's analyze parameter sensitivity:"
        puts

        ga = EducationalGeneticSearch.new
        ga.analyze_parameter_sensitivity(Examples::RastriginChromosome, 5)
        ga.visualize_comparisons
      end

      def lesson_multi_objective_optimization
        puts 'Multi-Objective Optimization'
        puts
        puts 'Real-world problems often have multiple conflicting objectives.'
        puts "Let's explore multi-objective concepts:"
        puts

        demo = MultiObjectiveDemo.new
        demo.run_weighted_example
      end

      def lesson_dynamic_optimization
        puts 'Dynamic Optimization'
        puts
        puts "Some problems change over time. Let's see how GAs can adapt:"
        puts

        demo = DynamicOptimizationDemo.new
        demo.run_example
      end

      def run_tsp_tutorial
        puts 'Traveling Salesman Problem Tutorial'
        puts
        puts 'The TSP is a classic combinatorial optimization problem.'
        puts "We'll explore how to represent tours, calculate distances,"
        puts 'and use specialized operators for permutation problems.'
        puts

        # Use existing TSP chromosome if available, or create simple version
        puts 'Running TSP example with educational features...'
        # Implementation would use TSP-specific chromosome
      end

      def run_function_optimization_tutorial
        puts 'Function Optimization Tutorial'
        puts
        puts 'Optimizing mathematical functions is a common GA application.'
        puts "We'll explore different function types and their challenges:"
        puts

        puts '1. Sphere Function (unimodal, easy)'
        Examples.run_sphere_example

        puts "\n2. Custom Function (multimodal, harder)"
        Examples.run_custom_function_example
      end

      def run_scheduling_tutorial
        puts 'Scheduling Problems Tutorial'
        puts
        puts 'Scheduling is a practical application of GAs.'
        puts "Let's explore job scheduling optimization:"
        puts

        demo = JobSchedulingExample.new
        demo.run_example(:beginner)
        demo.run_example(:intermediate)
      end

      def demonstrate_fitness_landscapes
        puts "\nFitness Landscape Examples:"
        puts
        puts '1. Smooth landscape (easy optimization):'
        puts '   Sphere function - single global optimum'
        Examples.run_sphere_example

        puts "\n2. Rugged landscape (harder optimization):"
        puts '   Rastrigin function - many local optima'

        ga = ModernGeneticSearch.new(Configuration.new(:default, verbose: true))
        ga.run(Examples::RastriginChromosome, 5)
        ga.plot_fitness
      end

      def demonstrate_crossover_operators
        puts 'Crossover Operator Comparison:'
        puts

        # Create simple demonstration
        parent1 = Examples::OneMaxChromosome.random_chromosome(8)
        parent2 = Examples::OneMaxChromosome.random_chromosome(8)

        puts "Parent 1: #{parent1.genes}"
        puts "Parent 2: #{parent2.genes}"
        puts

        # Single-point crossover
        single_point = SinglePointCrossover.new
        offspring1 = single_point.crossover(parent1, parent2)
        puts 'Single-point crossover:'
        puts "  Offspring 1: #{offspring1[0].genes}"
        puts "  Offspring 2: #{offspring1[1].genes}"
        puts

        # Two-point crossover
        two_point = EnhancedCrossoverOperators::TwoPointCrossover.new
        offspring2 = two_point.crossover(parent1, parent2)
        puts 'Two-point crossover:'
        puts "  Offspring 1: #{offspring2[0].genes}"
        puts "  Offspring 2: #{offspring2[1].genes}"
        puts

        # Uniform crossover
        uniform = UniformCrossover.new
        offspring3 = uniform.crossover(parent1, parent2)
        puts 'Uniform crossover:'
        puts "  Offspring 1: #{offspring3[0].genes}"
        puts "  Offspring 2: #{offspring3[1].genes}"

        puts "\nNotice how different operators create different offspring!"
      end

      def run_selected_topics(topics)
        puts "\n#{'=' * 50}"
        puts 'CUSTOM TUTORIAL: Selected Topics'
        puts '=' * 50

        topics.each_with_index do |topic, index|
          puts "\n#{'-' * 40}"
          puts "Topic #{index + 1}/#{topics.length}: #{topic.to_s.humanize}"
          puts '-' * 40

          case topic
          when :selection
            lesson_selection_operators_comparison
          when :crossover
            lesson_crossover_explained
          when :mutation
            lesson_mutation_explained
          when :parameters
            lesson_parameter_tuning
          when :convergence
            demonstrate_convergence_analysis
          when :diversity
            demonstrate_diversity_analysis
          when :multi_objective
            lesson_multi_objective_optimization
          when :visualization
            demonstrate_visualization_tools
          when :comparison
            demonstrate_algorithm_comparison
          end

          unless topic == topics.last
            puts "\nPress Enter to continue..."
            gets
          end
        end

        puts "\nCustom tutorial complete!"
      end

      def demonstrate_convergence_analysis
        puts 'Convergence Analysis Deep Dive'
        puts
        puts 'Understanding how and when algorithms converge is crucial.'
        puts "Let's analyze convergence patterns:"
        puts

        ga = EducationalGeneticSearch.new
        ga.learn_concept(:premature_convergence, Examples::SphereChromosome, 5)
        ga.visualize_evolution
      end

      def demonstrate_diversity_analysis
        puts 'Population Diversity Analysis'
        puts
        puts 'Diversity is key to avoiding premature convergence.'
        puts "Let's explore diversity dynamics:"
        puts

        ga = EducationalGeneticSearch.new
        ga.learn_concept(:population_diversity, Examples::RastriginChromosome, 5)
        ga.visualize_evolution
      end

      def demonstrate_visualization_tools
        puts 'Algorithm Visualization Tools'
        puts
        puts 'Visualization helps understand GA behavior.'
        puts "Let's explore available visualization options:"
        puts

        ga = EducationalGeneticSearch.new(
          Configuration.new(:default, max_generations: 50, verbose: false)
        )

        ga.run(Examples::SphereChromosome, 5)

        puts "\n1. Evolution Timeline:"
        ga.visualize_evolution

        puts "\n2. Population Analysis:"
        ga.visualize_population

        puts "\n3. Comparative Analysis:"
        ga.run_comparative_analysis(Examples::SphereChromosome, 5)
        ga.visualize_comparisons
      end

      def demonstrate_algorithm_comparison
        puts 'Algorithm Comparison Framework'
        puts
        puts 'Comparing GAs with other optimization methods provides insight.'
        puts "Let's compare different approaches:"
        puts

        ga = EducationalGeneticSearch.new
        results = ga.compare_with_other_algorithms(Examples::SphereChromosome, 5)

        VisualizationTools.create_algorithm_comparison_chart(results, 'Algorithm Performance Comparison')
      end

      def provide_next_steps
        puts "Congratulations! You've completed the tutorial."
        puts
        puts 'Suggested next steps:'
        puts '• Try the advanced tutorial for more sophisticated techniques'
        puts '• Experiment with different problem types'
        puts '• Explore the research literature on genetic algorithms'
        puts '• Apply GAs to your own optimization problems'
        puts
        puts 'Key resources:'
        puts '• Use EducationalGeneticSearch for continued learning'
        puts '• Explore the enhanced operators for specialized problems'
        puts '• Use visualization tools to analyze algorithm behavior'
        puts '• Run comparative analyses to understand trade-offs'
        puts
        puts 'Happy optimizing! 🧬🔬'
      end
    end
  end
end

# Helper method to humanize symbol names
class Symbol
  def humanize
    to_s.tr('_', ' ').split.map(&:capitalize).join(' ')
  end
end
