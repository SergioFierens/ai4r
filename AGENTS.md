# Development Instructions

This repository contains the AI4R Ruby gem. Follow these guidelines to speed up new development and ensure consistency.

## Setup

1. Ensure Ruby 3.2 or later is installed.
2. Install dependencies using Bundler:

   ```bash
   bundle install
   ```

3. Run the test suite before submitting changes:

   ```bash
   bundle exec rake test
   ```

## Contributing

- Keep pull requests focused and provide clear commit messages.
- Update or add tests when fixing bugs or introducing new features.
- Documentation lives under the `docs/` directory. Update or create new docs as needed.
- Ensure that `bundle exec rake test` succeeds before opening a PR.


## Purpose

This project is an educational Ruby library for machine learning and artificial intelligence, featuring clean, minimal implementations of classical algorithms such as decision trees, neural networks, k-means, and genetic algorithms.

It is intentionally lightweight: no GPU support, no production optimizations, and no large dependencies. The goal is to offer a readable, testable, hands-on way to explore the structure and behavior of fundamental AI algorithms.

## Audience

- Developers exploring classic ML techniques
- Educators using Ruby for instructional demos
- Students learning algorithm trade-offs by example
- AI-curious programmers who prefer clarity over speed

## Philosophy

Maintained over the years mostly for the joy of it (and perhaps a misplaced sense of duty to Ruby), this open-source library supports developers, students, and educators who want to understand machine learning in Ruby without drowning in complexity.

## Limitations

- Not optimized for performance
- No support for GPU, parallelism, or distributed training
- Not intended for production deployment

## Keywords

ruby machine learning, educational AI library, neural networks ruby, decision trees ruby, genetic algorithm ruby, open-source AI ruby, AI4R
