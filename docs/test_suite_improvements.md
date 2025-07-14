# Testing Suite Improvement Proposal

This document outlines several ways to improve the current AI4R test suite.

## Use Modern Test Frameworks

The project now uses `Minitest` instead of the older `Test::Unit`. This brings a larger ecosystem of plugins and clearer syntax while still running with `rake test`.

## Centralize Mock Data

Many test files define the same marketing or clustering data using constants or class variables. Consider moving repeated data into helper methods or fixture files (YAML or CSV) under `test/fixtures/`. Loading shared datasets keeps tests concise and avoids duplication.

## Avoid Modifying Classes Under Test

Several tests used to call `send(:public, *Class.protected_instance_methods)` to
expose internals. A cleaner approach keeps the classes untouched and invokes
protected helpers directly with Ruby's `send`:

```ruby
classifier.send(:neighbors_for, data, k)
```

This avoids warnings about method redefinition and keeps class visibility
unchanged.

## Deterministic Randomness

Some algorithms rely on randomness. Tests set global seeds with `srand`, which can lead to fragile ordering. Inject a `Random` instance or allow passing a seed via parameters so each test can initialize its own deterministic RNG.

## Add Edge‑Case Coverage

Current tests focus on typical scenarios. Additional cases to cover include:

- Handling invalid or empty data sets.
- Testing exception messages and parameter validation thoroughly.
- Verifying behavior when unknown attribute values appear and when optional parameters are omitted.

## Measure Coverage

Using a tool like `SimpleCov` during `rake test` helps track which methods lack tests. Aim to increase coverage for algorithms such as IB1, where the current tests do not exercise all branches (e.g., tie‑break logic).

## Continuous Integration

Automate `bundle exec rake test` on every pull request via GitHub Actions or another CI platform. This ensures the test suite always runs against supported Ruby versions.

