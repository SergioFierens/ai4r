# Contributor Guide

AI4R welcomes contributions of all sizes. This document explains how to get started, then dives into details for a smooth development workflow.

## Quick Start

1. Fork the repository on GitHub and clone your fork.
2. Install dependencies with `bundle install`.
3. Make your changes and add tests when possible.
4. Run `bundle exec rake test`.
5. Commit, push and open a pull request.

## Development Environment

AI4R works with modern versions of Ruby. The `Gemfile` lists all development dependencies. After cloning the project, run `bundle install` to set up your environment. Bundler will install `rake`, `minitest`, `rubocop` and other gems needed to build and test the project.

Use the provided `Rakefile.rb` to run tasks:

```bash
bundle exec rake test    # run the test suite
bundle exec rake rubocop # check style
```

## Running the Test Suite

All changes should pass the test suite. Tests live under the `test/` directory and can be executed with `bundle exec rake test`. When adding features or fixing bugs, include a regression test so the behaviour is verified automatically.

## Code Style

The project uses RuboCop for code style checks. You can run `bundle exec rubocop` to check the entire code base or a subset of files. Use the existing style as a guide when writing new code. Commit messages should be concise but descriptive.

## Documentation

Documentation lives under the `docs/` directory. When you add new features or modify existing behaviour, update or create docs to help others understand the change. The [index](index.md) file lists available documents; add a link there if you create a new page.

## Opening a Pull Request

Before opening a pull request:

1. Ensure `bundle exec rake test` passes.
2. Run `bundle exec rubocop` and fix any reported offences.
3. Provide a clear description of your change and reference any related issues.

Pull requests should remain focused on a single topic whenever possible. Small, self‑contained commits are easier to review.

## Getting Help

Questions and suggestions are welcome. Feel free to open an issue on GitHub or contact the maintainers listed in [docs/index.md](index.md).

