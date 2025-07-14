# Genetic Algorithm Framework Tutorial

## Overview

This tutorial introduces the enhanced genetic algorithm framework in AI4R, designed specifically for educational purposes and research experimentation. The framework provides a modular, extensible architecture that allows students and researchers to easily understand, modify, and experiment with genetic algorithms.

## Architecture

The new genetic algorithm framework consists of several key components:

### 1. **Chromosome Classes** (`chromosome.rb`)
- **Base Chromosome**: Abstract base class for all chromosome types
- **BinaryChromosome**: For binary optimization problems (0s and 1s)
- **PermutationChromosome**: For permutation problems (TSP, scheduling)
- **RealChromosome**: For continuous optimization problems
- **TSPChromosome**: Specialized for traveling salesman problems

### 2. **Operators** (`operators.rb`)
- **Selection Operators**: Tournament, Fitness Proportionate
- **Crossover Operators**: Single Point, Uniform, Edge Recombination
- **Mutation Operators**: Bit Flip, Swap, Gaussian
- **Replacement Operators**: Elitist, Generational

### 3. **Configuration System** (`configuration.rb`)
- Pre-defined parameter sets (exploration, exploitation, balanced)
- Parameter validation and explanation
- Easy configuration modification

### 4. **Evolution Monitor** (`evolution_monitor.rb`)
- Real-time statistics collection
- Fitness evolution tracking
- Population diversity monitoring
- Convergence detection

### 5. **Modern Genetic Search** (`modern_genetic_search.rb`)
- Main algorithm orchestrator
- Strategy pattern implementation
- Step-by-step execution mode

### 6. **Educational Examples** (`examples.rb`)
- Ready-to-run problem examples
- Different problem types and domains
- Comprehensive documentation

## Getting Started

### Basic Usage

```ruby
require 'ai4r'

# Create configuration
config = Ai4r::GeneticAlgorithm::Configuration.new(:default,
  population_size: 50,
  max_generations: 100,
  mutation_rate: 0.02,
  verbose: true
)

# Create and configure genetic algorithm
ga = Ai4r::GeneticAlgorithm::ModernGeneticSearch.new(config)
ga.with_selection(Ai4r::GeneticAlgorithm::TournamentSelection.new(3))
  .with_crossover(Ai4r::GeneticAlgorithm::SinglePointCrossover.new)
  .with_mutation(Ai4r::GeneticAlgorithm::BitFlipMutation.new)

# Run optimization
best = ga.run(Ai4r::GeneticAlgorithm::Examples::OneMaxChromosome, 20)
```

### Running Examples

```ruby
# Run pre-built examples
Ai4r::GeneticAlgorithm::Examples.run_onemax_example
Ai4r::GeneticAlgorithm::Examples.run_knapsack_example
Ai4r::GeneticAlgorithm::Examples.run_nqueens_example
Ai4r::GeneticAlgorithm::Examples.run_all_examples
```

## Educational Features

### 1. **Step-by-Step Execution**

For learning purposes, you can run the algorithm step-by-step:

```ruby
ga = Ai4r::GeneticAlgorithm::ModernGeneticSearch.new(config)
best = ga.run_step_by_step(ChromosomeClass, *args)
```

This mode pauses after each genetic operation, allowing students to observe:
- Population initialization
- Parent selection
- Crossover operations
- Mutation effects
- Replacement strategies

### 2. **Operator Explanations**

All operators include educational descriptions:

```ruby
selection = Ai4r::GeneticAlgorithm::TournamentSelection.new(3)
puts selection.description
# Output: "Selects best individual from random tournament of size 3"
```

### 3. **Configuration Explanations**

```ruby
config = Ai4r::GeneticAlgorithm::Configuration.new
config.explain_parameters
# Provides detailed explanations of all parameters
```

### 4. **Real-time Monitoring**

```ruby
ga.monitor.plot_fitness_evolution  # Terminal-based fitness plot
ga.monitor.summary                 # Evolution statistics
ga.export_data("evolution.csv")    # Export for external analysis
```

## Problem Types and Examples

### 1. **Binary Optimization (OneMax)**

```ruby
class OneMaxChromosome < Ai4r::GeneticAlgorithm::BinaryChromosome
  def calculate_fitness
    @genes.sum.to_f  # Count the number of 1s
  end
end

# Usage
ga.run(OneMaxChromosome, 50)  # 50-bit binary string
```

### 2. **Knapsack Problem**

```ruby
class KnapsackChromosome < Ai4r::GeneticAlgorithm::BinaryChromosome
  def initialize(genes, weights, values, capacity)
    super(genes)
    @weights, @values, @capacity = weights, values, capacity
  end
  
  def calculate_fitness
    # Calculate value with capacity constraint
    # ... (see examples.rb for full implementation)
  end
end
```

### 3. **Continuous Optimization**

```ruby
class SphereChromosome < Ai4r::GeneticAlgorithm::RealChromosome
  def calculate_fitness
    -@genes.sum { |x| x * x }  # Minimize sum of squares
  end
end
```

### 4. **Permutation Problems (N-Queens)**

```ruby
class NQueensChromosome < Ai4r::GeneticAlgorithm::PermutationChromosome
  def calculate_fitness
    # Count conflicts between queens
    # ... (see examples.rb for full implementation)
  end
end
```

## Operator Customization

### Creating Custom Selection Operators

```ruby
class CustomSelection < Ai4r::GeneticAlgorithm::SelectionOperator
  def initialize(parameter)
    @parameter = parameter
    super("Custom Selection", "Description of custom selection")
  end
  
  def select(population, count)
    # Implement custom selection logic
    # Return array of selected individuals
  end
end
```

### Creating Custom Crossover Operators

```ruby
class CustomCrossover < Ai4r::GeneticAlgorithm::CrossoverOperator
  def crossover(parent1, parent2)
    # Implement custom crossover logic
    # Return array of offspring
  end
end
```

## Configuration Presets

The framework includes several pre-configured parameter sets:

### Default Configuration
- Population: 50, Generations: 100
- Mutation: 0.01, Crossover: 0.8
- Balanced exploration/exploitation

### Exploration Configuration
- Larger population (100)
- Higher mutation rate (0.1)
- More generations (200)
- Good for complex landscapes

### Exploitation Configuration
- Smaller population (30)
- Lower mutation rate (0.005)
- Higher elitism (0.2)
- Good for fine-tuning

### Balanced Configuration
- Medium population (75)
- Moderate parameters
- Good general-purpose settings

## Monitoring and Analysis

### Real-time Statistics
- Best, average, worst fitness per generation
- Population diversity measures
- Convergence detection
- Runtime statistics

### Visualization
- Terminal-based fitness plots
- CSV export for external plotting
- Generation-by-generation analysis

### Performance Analysis
- Timing measurements
- Convergence analysis
- Parameter sensitivity studies

## Advanced Features

### 1. **Custom Fitness Functions**

```ruby
custom_function = lambda do |genes|
  # Define any mathematical function
  -(genes[0]**2 + genes[1]**2 + Math.sin(genes[0]))
end

ga.run(FunctionOptimizationChromosome, 2, -10, 10, custom_function)
```

### 2. **Multi-objective Optimization**

The framework can be extended for multi-objective problems by modifying the fitness calculation and selection operators.

### 3. **Adaptive Parameters**

Parameters can be modified during evolution:

```ruby
# In a custom operator
@mutation_rate *= 0.99  # Decrease mutation rate over time
```

## Teaching Suggestions

### 1. **Progressive Complexity**
Start with simple problems (OneMax) and gradually introduce complexity:
- OneMax → Knapsack → N-Queens → Continuous optimization

### 2. **Operator Comparison**
Compare different operators on the same problem:
- Tournament vs. Roulette selection
- Single-point vs. Uniform crossover
- Different mutation rates

### 3. **Parameter Studies**
Investigate parameter effects:
- Population size impact
- Mutation rate sensitivity
- Selection pressure effects

### 4. **Problem Analysis**
Analyze different problem characteristics:
- Unimodal vs. multimodal landscapes
- Constraint handling
- Convergence patterns

### 5. **Algorithm Variants**
Implement variations:
- Steady-state GA
- Island model GA
- Hybrid algorithms

## Troubleshooting

### Common Issues

1. **Premature Convergence**
   - Increase mutation rate
   - Reduce selection pressure
   - Increase population diversity

2. **Slow Convergence**
   - Increase selection pressure
   - Reduce mutation rate
   - Increase population size

3. **No Improvement**
   - Check fitness function correctness
   - Verify operator compatibility
   - Increase generation limit

### Debugging Tips

- Use verbose mode for detailed output
- Enable step-by-step execution
- Monitor population diversity
- Check convergence criteria

## Research Extensions

The framework can be extended for research purposes:

### 1. **New Operators**
- Implement novel selection, crossover, or mutation operators
- Compare against standard operators

### 2. **Adaptive Mechanisms**
- Self-adaptive parameters
- Learning classifier systems
- Coevolutionary approaches

### 3. **Parallel Processing**
- Island model implementations
- Distributed evolution
- GPU acceleration

### 4. **Hybrid Algorithms**
- Combine with local search
- Incorporate machine learning
- Multi-population strategies

## References and Further Reading

1. Goldberg, D.E. (1989). Genetic Algorithms in Search, Optimization, and Machine Learning.
2. Mitchell, M. (1998). An Introduction to Genetic Algorithms.
3. Eiben, A.E. & Smith, J.E. (2015). Introduction to Evolutionary Computing.
4. Michalewicz, Z. (1996). Genetic Algorithms + Data Structures = Evolution Programs.

## Contributing

The framework is designed to be extensible. Contributions are welcome:
- New chromosome types
- Additional operators
- Educational examples
- Performance improvements
- Documentation enhancements

## License

This genetic algorithm framework is released under the Mozilla Public License 1.1, same as the rest of the AI4R library.