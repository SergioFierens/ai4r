# AI4R Library Organization

This document describes the organization of the AI4R library code.

## Directory Structure

```
lib/ai4r/
├── README.md                    # This file
├── version.rb                   # Version information
├── ai4r.rb                     # Main entry point
│
├── core/                       # Core functionality
│   ├── benchmarks/            # Performance benchmarking
│   │   ├── benchmark_runner.rb
│   │   ├── classifier_bench.rb
│   │   └── search_bench.rb
│   │
│   ├── helpers/               # Utility helpers
│   │   ├── array_helper.rb    # Array operations
│   │   ├── math_helper.rb     # Mathematical functions
│   │   └── validation_helper.rb # Input validation
│   │
│   ├── extensions/            # Ruby core extensions
│   │   └── array_extensions.rb
│   │
│   ├── helpers.rb            # Central helpers include
│   └── benchmarks.rb         # Central benchmarks include
│
├── educational/               # Educational resources
│   ├── tutorials/            # Step-by-step tutorials
│   │   └── genetic_algorithm_tutorial.rb
│   │
│   ├── examples/             # Example implementations
│   │   ├── classifier_examples.rb
│   │   ├── clusterer_examples.rb
│   │   ├── data_examples.rb
│   │   ├── genetic_algorithm_examples.rb
│   │   └── neural_network_examples.rb
│   │
│   ├── curricula/            # Structured learning paths
│   │   └── clustering_curriculum.rb
│   │
│   └── demos/                # Interactive demonstrations
│       ├── genetic_algorithm_demos.rb
│       └── interactive_clustering_explorer.rb
│
├── utilities/                 # Utility modules
│   ├── visualization/        # Data visualization tools
│   │   ├── data_visualization.rb
│   │   └── genetic_algorithm_visualization.rb
│   │
│   ├── monitoring/           # Algorithm monitoring
│   │   └── evolution_monitor.rb
│   │
│   └── generators/           # Data generators
│       └── synthetic_dataset_generator.rb
│
├── classifiers/              # Classification algorithms
├── clusterers/               # Clustering algorithms
├── data/                     # Data handling
├── experiment/               # Experimental features
├── genetic_algorithm/        # Genetic algorithms
├── neural_network/           # Neural networks
├── search/                   # Search algorithms
└── som/                      # Self-organizing maps
```

## Core Module

### Helpers

The `core/helpers` directory contains utility functions used throughout the library:

- **ArrayHelper**: Common array operations (mean, variance, normalization)
- **MathHelper**: Mathematical functions (activation functions, distances)
- **ValidationHelper**: Input validation and error checking

Usage:
```ruby
require 'ai4r/core/helpers'

# Use helpers directly
mean = Ai4r::Core::Helpers.mean([1, 2, 3, 4, 5])
distance = Ai4r::Core::Helpers.euclidean_distance([0, 0], [3, 4])

# Or include in your class
class MyAlgorithm
  include Ai4r::Core::Helpers
  
  def process(data)
    normalized = normalize(data)
    # ...
  end
end
```

### Benchmarks

The benchmarking system provides performance analysis tools:

```ruby
require 'ai4r/core/benchmarks'

# Run all benchmarks
Ai4r::Core::Benchmarks.run_all

# Or run specific benchmark
runner = Ai4r::Core::Benchmarks::BenchmarkRunner.new("My Algorithm")
runner.benchmark("small dataset") { algorithm.run(small_data) }
runner.scalability_test([100, 500, 1000]) { |n| algorithm.run(generate_data(n)) }
runner.summary
```

### Extensions

Optional Ruby core extensions (not loaded by default):

```ruby
# Load array extensions
require 'ai4r/core/extensions/array_extensions'
Array.include(Ai4r::Core::Extensions::ArrayExtensions)

# Now use extended methods
[1, 2, 3, 4, 5].mean  # => 3.0
[1, 2, 3].euclidean_distance_to([4, 5, 6])  # => 5.196...
```

## Educational Module

Educational resources are organized by type:

- **Tutorials**: Step-by-step guides for learning concepts
- **Examples**: Complete working examples
- **Curricula**: Structured learning paths
- **Demos**: Interactive demonstrations

## Utilities Module

Reusable utilities:

- **Visualization**: Tools for visualizing data and algorithm behavior
- **Monitoring**: Tools for monitoring algorithm progress
- **Generators**: Synthetic data generators for testing

## Best Practices

1. **Use Core Helpers**: Leverage helpers instead of reimplementing common functions
2. **Benchmark Performance**: Use the benchmark runner for performance testing
3. **Validate Inputs**: Use ValidationHelper for consistent error handling
4. **Educational First**: Include educational examples and documentation
5. **Modular Design**: Keep components loosely coupled

## Adding New Components

When adding new functionality:

1. **Algorithms**: Place in appropriate module directory
2. **Helpers**: Add to `core/helpers/` if generally useful
3. **Educational Content**: Add examples to `educational/`
4. **Utilities**: Add to `utilities/` if not core to algorithms
5. **Benchmarks**: Add benchmark cases to test performance

## Dependencies

Core modules should have minimal dependencies. Educational and utility modules can have additional dependencies for visualization, etc.