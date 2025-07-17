# AI4R Test Suite Organization

This directory contains the comprehensive test suite for the AI4R library. The tests are organized to promote maintainability, reusability, and clarity.

## Directory Structure

```
spec/
├── README.md                    # This file
├── spec_helper.rb              # Main RSpec configuration
├── .rspec                      # RSpec command line options
├── .rspec_status              # RSpec failure tracking
│
├── support/                    # Shared test utilities
│   ├── helpers/               # Test helper modules
│   │   ├── data_helper.rb     # Data generation utilities
│   │   ├── algorithm_helper.rb # Algorithm testing utilities
│   │   └── assertion_helper.rb # Custom assertion methods
│   │
│   ├── shared_examples/       # Reusable test examples
│   │   ├── classifier_examples.rb
│   │   └── clusterer_examples.rb
│   │
│   └── matchers/              # Custom RSpec matchers
│       └── algorithm_matchers.rb
│
├── benchmarks/                 # Performance benchmarks
│   ├── performance/           # Execution time benchmarks
│   │   ├── clusterer_benchmark.rb
│   │   ├── classifier_benchmark.rb
│   │   ├── neural_network_benchmark.rb
│   │   └── search_benchmark.rb
│   │
│   └── memory/                # Memory usage benchmarks
│       └── memory_benchmark.rb
│
├── unit/                      # Unit tests (future)
├── integration/              # Integration tests (future)
│
└── [module_name]/            # Module-specific tests
    ├── classifiers/
    ├── clusterers/
    ├── data/
    ├── experiment/
    ├── genetic_algorithm/
    ├── neural_network/
    ├── search/
    └── som/
```

## Test Helpers

### DataHelper
Provides utilities for generating test data:
- `generate_clustered_data` - Creates clustered data for testing clustering algorithms
- `generate_xor_data` - Standard XOR dataset for neural networks
- `generate_linear_data` - Linearly separable data for classifiers
- `generate_time_series` - Time series data
- `generate_missing_data` - Data with missing values

### AlgorithmHelper
Utilities for testing algorithm behavior:
- `test_convergence` - Tests if an algorithm converges
- `measure_performance` - Measures execution time and memory
- `parameter_sweep` - Tests algorithm with different parameters

### AssertionHelper
Custom assertion methods:
- `expect_symmetric_matrix` - Verifies matrix symmetry
- `expect_in_range` - Checks values are within bounds
- `expect_well_separated_clusters` - Validates cluster separation
- `expect_probability_distribution` - Validates probability constraints

## Shared Examples

### Clusterer Examples
```ruby
it_behaves_like "a clusterer"
it_behaves_like "a hierarchical clusterer"
it_behaves_like "a density-based clusterer"
it_behaves_like "a partitioning clusterer"
```

### Classifier Examples
```ruby
it_behaves_like "a classifier"
it_behaves_like "a probabilistic classifier"
it_behaves_like "a tree-based classifier"
it_behaves_like "a regression model"
```

## Custom Matchers

### Algorithm Matchers
- `converge` - Tests convergence behavior
- `have_well_separated_clusters` - Validates cluster quality
- `be_valid_probability_distribution` - Checks probability constraints
- `be_symmetric_matrix` - Verifies matrix properties
- `be_monotonic` - Checks monotonic sequences
- `complete_within` - Performance time bounds
- `produce_consistent_results` - Deterministic behavior

## Running Tests

### All Tests
```bash
bundle exec rspec
```

### Specific Module
```bash
bundle exec rspec spec/neural_network/
```

### With Coverage Report
```bash
COVERAGE=true bundle exec rspec
```

### Benchmarks Only
```bash
bundle exec rspec spec/benchmarks/ --tag benchmark
```

### Excluding Slow Tests
```bash
bundle exec rspec --tag ~slow
```

## Writing Tests

### Using Helpers
```ruby
require 'spec_helper'

RSpec.describe MyAlgorithm do
  include DataHelper
  
  let(:test_data) { generate_clustered_data(clusters: 3) }
  
  it 'clusters data correctly' do
    result = subject.cluster(test_data)
    expect(result).to have_well_separated_clusters
  end
end
```

### Using Shared Examples
```ruby
require 'spec_helper'

RSpec.describe Ai4r::Clusterers::NewClusterer do
  it_behaves_like "a partitioning clusterer"
  
  # Add specific tests for this clusterer
end
```

### Performance Testing
```ruby
require 'spec_helper'

RSpec.describe 'Algorithm Performance' do
  it 'completes within time limit' do
    expect { algorithm.run(large_dataset) }.to complete_within(5.seconds)
  end
end
```

## Best Practices

1. **Use Helpers**: Leverage the provided helpers for data generation and assertions
2. **Share Examples**: Use shared examples for common behavior
3. **Isolate Tests**: Each test should be independent
4. **Mock External Dependencies**: Use test doubles for external services
5. **Tag Slow Tests**: Mark slow tests with `slow: true` tag
6. **Document Complex Tests**: Add comments explaining complex test logic
7. **Keep Tests Focused**: One assertion per test when possible
8. **Use Descriptive Names**: Test names should clearly state what is being tested

## Coverage Goals

- Unit Test Coverage: 90%+
- Integration Test Coverage: 80%+
- Performance Benchmarks: All critical algorithms
- Edge Cases: Comprehensive coverage

## Contributing

When adding new tests:
1. Place them in the appropriate directory
2. Use existing helpers and shared examples
3. Add new helpers/matchers to the support directory
4. Update this README if adding new test categories
5. Ensure tests pass before submitting PR