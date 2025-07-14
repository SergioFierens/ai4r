= AI4R — Artificial Intelligence for Ruby

A Ruby library of AI algorithms for learning and experimentation.

---

This project is an educational Ruby library for machine learning and artificial intelligence, featuring clean, minimal implementations of classical algorithms such as decision trees, neural networks, k-means, and genetic algorithms. It’s intentionally lightweight—no GPU support, no external dependencies, no production overhead—just a practical way to experiment, compare, and learn the fundamental building blocks of AI. Ideal for small-scale explorations, course demos, or simply understanding how these algorithms actually work, line by line.

Maintained over the years mostly for the joy of it (and perhaps a misplaced sense of duty to Ruby), this open-source library supports developers, students, and educators who want to understand machine learning in Ruby without drowning in complexity.

# AI4R

AI4R is a collection of artificial intelligence algorithms implemented in Ruby. It includes classifiers, clustering methods, neural networks and more. The library is distributed as a gem and works with modern versions of Ruby.

## Installation

Install the gem using RubyGems:

```bash
gem install ai4r
```

Add the library to your code:

```ruby
require 'ai4r'
```

## Documentation

The `docs/` directory contains tutorials on using specific algorithms such as genetic algorithms, neural networks, clustering, and others. Examples under `examples/` showcase how to run several algorithms.

See `README.rdoc` for additional usage notes and examples.

## Running Tests

Install development dependencies with Bundler and run the test suite:

```bash
bundle install
bundle exec rake test
```

