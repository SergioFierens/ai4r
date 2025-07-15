# Genetic Algorithms

## Overview

The AI4R genetic algorithms group provides implementations of evolutionary computation algorithms inspired by biological evolution. These algorithms demonstrate how principles of natural selection can be applied to solve optimization problems through iterative improvement of candidate solutions.

## Educational Purpose

Genetic algorithms demonstrate key concepts in evolutionary computation:
- **Evolution Simulation**: How populations evolve over generations
- **Selection Pressure**: Survival of the fittest in solution spaces
- **Genetic Operators**: Crossover, mutation, and selection mechanisms
- **Optimization**: Finding optimal or near-optimal solutions without gradient information

## Available Algorithms

### Core Genetic Algorithm

#### Standard Genetic Algorithm
- **File**: `lib/ai4r/genetic_algorithm/genetic_algorithm.rb`
- **Description**: Classic genetic algorithm with configurable operators
- **Use Cases**: Function optimization, combinatorial problems, parameter tuning
- **Educational Value**: Demonstrates basic evolutionary principles

**Key Features:**
- Population-based optimization
- Configurable selection methods
- Multiple crossover operators
- Adaptive mutation strategies

#### Modern Genetic Search
- **File**: `lib/ai4r/genetic_algorithm/modern_genetic_search.rb`
- **Description**: Advanced genetic algorithm with modern enhancements
- **Use Cases**: Complex optimization, multi-objective problems
- **Educational Value**: Shows advanced evolutionary techniques

**Key Features:**
- Elitism preservation
- Niching and speciation
- Adaptive parameter control
- Multi-objective optimization

### Genetic Operators

#### Selection Operators
- **File**: `lib/ai4r/genetic_algorithm/operators.rb`
- **Description**: Various selection methods for choosing parents
- **Methods Available:**
  - Tournament Selection
  - Roulette Wheel Selection
  - Rank Selection
  - Stochastic Universal Sampling

#### Crossover Operators
- **Single-Point Crossover**: Split chromosomes at one point
- **Multi-Point Crossover**: Multiple crossover points
- **Uniform Crossover**: Bit-by-bit random selection
- **Arithmetic Crossover**: Weighted average for real-valued genes

#### Mutation Operators
- **Bit Flip Mutation**: Binary gene modification
- **Gaussian Mutation**: Normal distribution perturbation
- **Uniform Mutation**: Random value replacement
- **Adaptive Mutation**: Self-adjusting mutation rates

### Chromosome Representations

#### Binary Chromosome
- **File**: `lib/ai4r/genetic_algorithm/chromosome.rb`
- **Description**: Binary string representation for discrete problems
- **Use Cases**: Binary optimization, feature selection
- **Educational Value**: Demonstrates classic GA representation

#### Real-Valued Chromosome
- **Description**: Continuous value representation
- **Use Cases**: Function optimization, parameter tuning
- **Educational Value**: Shows adaptation to continuous problems

#### Permutation Chromosome
- **Description**: Ordering-based representation
- **Use Cases**: Traveling salesman, scheduling problems
- **Educational Value**: Demonstrates combinatorial optimization

### Specialized Implementations

#### Educational Genetic Search
- **File**: `lib/ai4r/genetic_algorithm/educational_genetic_search.rb`
- **Description**: Step-by-step GA with detailed visualization
- **Use Cases**: Learning and teaching evolutionary algorithms
- **Educational Value**: Complete transparency of evolutionary process

#### Enhanced Operators
- **File**: `lib/ai4r/genetic_algorithm/enhanced_operators.rb`
- **Description**: Advanced genetic operators with improvements
- **Use Cases**: Complex optimization problems
- **Educational Value**: Shows operator design principles

## Key Components

### Population Management
- **Initialization**: Random and heuristic population creation
- **Diversity Maintenance**: Preventing premature convergence
- **Replacement Strategies**: Generational vs. steady-state
- **Population Sizing**: Balancing exploration and exploitation

### Fitness Evaluation
- **Objective Functions**: Problem-specific fitness measures
- **Fitness Scaling**: Linear, exponential, and rank-based scaling
- **Constraint Handling**: Penalty functions and repair mechanisms
- **Multi-Objective**: Pareto optimality and NSGA-II

### Evolution Monitoring
- **File**: `lib/ai4r/genetic_algorithm/evolution_monitor.rb`
- **Description**: Tracks evolutionary progress and statistics
- **Features:**
  - Fitness convergence tracking
  - Diversity measurements
  - Performance statistics
  - Visualization tools

### Configuration Management
- **File**: `lib/ai4r/genetic_algorithm/configuration.rb`
- **Description**: Centralized parameter management
- **Features:**
  - Parameter validation
  - Default configurations
  - Adaptive parameter adjustment
  - Configuration templates

## Educational Features

### Interactive Demonstrations
- **File**: `lib/ai4r/genetic_algorithm/educational_demos.rb`
- **Description**: Interactive examples and visualizations
- **Features:**
  - Step-by-step evolution
  - Population visualization
  - Fitness landscape exploration
  - Operator comparison

### Practical Examples
- **File**: `lib/ai4r/genetic_algorithm/examples.rb`
- **Description**: Real-world application examples
- **Examples:**
  - Function optimization
  - Traveling salesman problem
  - Knapsack problem
  - Neural network training

### Tutorial System
- **File**: `lib/ai4r/genetic_algorithm/tutorial.rb`
- **Description**: Guided learning experience
- **Features:**
  - Progressive complexity
  - Concept explanations
  - Hands-on exercises
  - Assessment tools

### Visualization Tools
- **File**: `lib/ai4r/genetic_algorithm/visualization_tools.rb`
- **Description**: Visual representation of evolutionary process
- **Features:**
  - Population diversity plots
  - Fitness convergence graphs
  - Chromosome visualization
  - Evolution animation

## Common Usage Patterns

### Basic Genetic Algorithm
```ruby
# Define fitness function
def fitness_function(chromosome)
  # Calculate fitness based on chromosome
  # Return higher values for better solutions
end

# Create and configure GA
ga = Ai4r::GeneticAlgorithm::GeneticAlgorithm.new(
  population_size: 100,
  chromosome_length: 20,
  crossover_probability: 0.8,
  mutation_probability: 0.01,
  fitness_function: method(:fitness_function)
)

# Run evolution
ga.evolve(generations: 1000)

# Get best solution
best_solution = ga.best_chromosome
puts "Best fitness: #{best_solution.fitness}"
```

### Function Optimization
```ruby
# Optimize mathematical function
def objective_function(x)
  # Example: minimize f(x) = x^2 - 10*cos(2*pi*x) + 10
  x.sum { |xi| xi**2 - 10*Math.cos(2*Math::PI*xi) + 10 }
end

# Create real-valued GA
ga = Ai4r::GeneticAlgorithm::ModernGeneticSearch.new(
  chromosome_type: :real_valued,
  dimensions: 5,
  bounds: [-5.0, 5.0],
  minimize: true,
  fitness_function: method(:objective_function)
)

# Run optimization
result = ga.optimize(max_generations: 500)
puts "Optimal solution: #{result.best_chromosome.genes}"
```

### Traveling Salesman Problem
```ruby
# Define TSP problem
cities = [
  [0, 0], [1, 1], [2, 0], [3, 1], [4, 2]
]

def tsp_fitness(chromosome)
  # Calculate total distance for tour
  total_distance = 0
  chromosome.genes.each_with_index do |city, i|
    next_city = chromosome.genes[(i + 1) % chromosome.genes.length]
    total_distance += distance(cities[city], cities[next_city])
  end
  1.0 / total_distance  # Minimize distance
end

# Create TSP-specific GA
ga = Ai4r::GeneticAlgorithm::GeneticAlgorithm.new(
  chromosome_type: :permutation,
  chromosome_length: cities.length,
  fitness_function: method(:tsp_fitness),
  crossover_operator: :order_crossover,
  mutation_operator: :swap_mutation
)

# Solve TSP
solution = ga.evolve(generations: 1000)
puts "Best tour: #{solution.best_chromosome.genes}"
```

### Educational Exploration
```ruby
# Create educational GA environment
educator = Ai4r::GeneticAlgorithm::EducationalGeneticSearch.new

# Set up interactive demonstration
educator.setup_demonstration(
  problem_type: :function_optimization,
  visualization: true,
  step_by_step: true
)

# Run with detailed explanations
educator.run_with_explanations do |generation, population|
  puts "Generation #{generation}:"
  puts "  Best fitness: #{population.best_fitness}"
  puts "  Average fitness: #{population.average_fitness}"
  puts "  Diversity: #{population.diversity}"
end
```

## Integration with Other Components

### Data Structures
- Works with various chromosome representations
- Supports custom fitness functions
- Integrates with visualization tools
- Compatible with constraint handling

### Optimization
- Multi-objective optimization support
- Constraint satisfaction integration
- Hybrid algorithms with local search
- Parallel and distributed evolution

## Educational Progression

### Beginner Level
1. **Basic GA**: Understand population, selection, crossover, mutation
2. **Binary Problems**: Work with binary chromosome representation
3. **Fitness Functions**: Learn to design problem-specific fitness

### Intermediate Level
1. **Real-Valued GA**: Continuous optimization problems
2. **Permutation Problems**: Combinatorial optimization
3. **Parameter Tuning**: Optimize GA parameters

### Advanced Level
1. **Multi-Objective GA**: Pareto optimization
2. **Hybrid Algorithms**: Combine GA with other methods
3. **Constraint Handling**: Solve constrained optimization

## Performance Considerations

### Time Complexity
- **Per Generation**: O(P × F) where P=population size, F=fitness evaluation cost
- **Total Runtime**: O(G × P × F) where G=generations
- **Selection**: O(P) to O(P log P) depending on method

### Space Complexity
- **Population Storage**: O(P × L) where L=chromosome length
- **Evolution History**: O(G × P × L) if tracking all generations
- **Fitness Cache**: O(P) for current generation

### Optimization Strategies
- **Parallel Fitness Evaluation**: Distribute fitness calculations
- **Elitism**: Preserve best solutions across generations
- **Adaptive Parameters**: Self-adjust during evolution
- **Early Termination**: Stop when convergence criteria met

## Best Practices

### Population Management
- **Size Selection**: Balance exploration and computation cost
- **Diversity Maintenance**: Prevent premature convergence
- **Initialization**: Use problem-specific knowledge when possible
- **Replacement Strategy**: Choose appropriate generational model

### Operator Design
- **Crossover Rate**: Typically 0.6-0.9 for good mixing
- **Mutation Rate**: Usually 0.01-0.1 for diversity
- **Selection Pressure**: Balance exploitation and exploration
- **Elitism**: Preserve small percentage of best solutions

### Parameter Tuning
- **Population Size**: 50-200 for most problems
- **Generations**: Problem-dependent, use convergence criteria
- **Crossover Probability**: High (0.8-0.95) for good solutions
- **Mutation Probability**: Low (0.01-0.1) to maintain diversity

### Problem-Specific Adaptations
- **Representation**: Choose appropriate chromosome encoding
- **Operators**: Design problem-specific crossover and mutation
- **Fitness Function**: Ensure proper scaling and constraints
- **Initialization**: Use domain knowledge for better starting points

## Advanced Topics

### Multi-Objective Optimization
- **NSGA-II**: Non-dominated sorting genetic algorithm
- **Pareto Fronts**: Multiple optimal solutions
- **Hypervolume**: Quality measure for multi-objective
- **SPEA2**: Strength Pareto evolutionary algorithm

### Constraint Handling
- **Penalty Functions**: Add constraint violations to fitness
- **Repair Mechanisms**: Fix infeasible solutions
- **Feasibility Rules**: Prefer feasible over infeasible
- **Constraint Domination**: Specialized comparison operators

### Hybrid Approaches
- **Memetic Algorithms**: GA with local search
- **Genetic Programming**: Evolving programs
- **Differential Evolution**: Alternative evolutionary approach
- **Particle Swarm Optimization**: Swarm intelligence hybrid

This genetic algorithms framework provides a comprehensive foundation for understanding evolutionary computation through hands-on implementation of nature-inspired optimization techniques.