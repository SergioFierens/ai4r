# AI4R Project Structure

## Root Directory

The root directory should only contain:

### Essential Files
- `README.md` - Project documentation
- `LICENSE` or `UNLICENSE` - License information
- `Gemfile` - Ruby dependencies
- `Gemfile.lock` - Locked dependency versions
- `.gitignore` - Git ignore rules
- `ai4r.gemspec` - Gem specification
- `Rakefile` - Build tasks

### Configuration Files
- `.rspec` - RSpec configuration
- `.rubocop.yml` - Code style configuration
- `.simplecov` - Test coverage configuration
- `.travis.yml` - CI configuration (if using Travis CI)

### Documentation
- `PROJECT_STRUCTURE.md` - This file

## Directory Structure

```
ai4r/
├── benchmarks/          # Benchmark results (gitignored)
│   └── results/
├── config/              # Configuration files
│   ├── rubocop_initial.json
│   └── local/          # Local overrides (gitignored)
├── coverage/            # Test coverage reports (gitignored)
├── docs/                # Documentation
│   ├── algorithm-groups/
│   ├── examples/
│   ├── guides/
│   ├── reference/
│   └── tutorials/
├── examples/            # Example scripts
│   ├── classifiers/
│   ├── clusterers/
│   ├── experiment/
│   ├── genetic_algorithm/
│   ├── neural_network/
│   ├── search/
│   └── som/
├── lib/                 # Source code
│   ├── ai4r.rb
│   └── ai4r/
│       ├── classifiers/
│       ├── clusterers/
│       ├── core/
│       ├── data/
│       ├── educational/
│       ├── experiment/
│       ├── genetic_algorithm/
│       ├── machine_learning/
│       ├── neural_network/
│       ├── search/
│       ├── som/
│       └── utilities/
├── pkg/                 # Built gems (gitignored)
└── spec/                # Test specifications
    ├── benchmarks/
    ├── classifiers/
    ├── clusterers/
    ├── data/
    ├── genetic_algorithm/
    ├── integration/
    ├── legacy/          # Legacy test files
    ├── machine_learning/
    ├── neural_network/
    ├── pending/
    ├── search/
    ├── som/
    ├── support/
    └── unit/
```

## Notes

- Build artifacts, test results, and local configurations should never be in the root directory
- All test-related files go in `spec/`
- All example scripts go in `examples/`
- All source code goes in `lib/`
- All documentation goes in `docs/`