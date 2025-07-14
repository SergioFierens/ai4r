# Neural Network Testing Guide

This document describes how to run the neural network test suite.

## Running tests

```
bundle install
bundle exec rake test
```

## Fixtures

Fixtures live in `test/fixtures/nn`. Each YAML file defines network
parameters and a small dataset. Use `load_fixture(id)` to load them.
If `weight_init` is `fixed_seed`, the loader seeds Ruby's RNG with `1234`.

## Adding new algorithms

Place tests under `test/unit/neural_network` and add fixtures as needed.
Use the helper modules in `test/helpers` for numeric assertions.
