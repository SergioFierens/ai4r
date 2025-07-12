# Testing Prompts

The following prompts guide contributors on how to expand the test suite for each algorithm implementation. For every algorithm, answer the questions in the prompt to ensure that the library has thorough coverage.

## Genetic Algorithms

Provide test scenarios for the genetic algorithm components (`lib/ai4r/genetic_algorithm`) and reference `test/genetic_algorithm`. Follow these steps:

1. Enumerate positive, negative, and edge cases.
2. List existing tests and explain how new cases relate to them.
3. Perform orthogonality analysis to identify independent behaviors.
4. Classify each case as a unit, integration, or end-to-end test.

## Hopfield Networks

Focus on the Hopfield implementation (`lib/ai4r/neural_network/hopfield.rb`). Review tests under `test/neural_network/hopfield_test.rb`.

1. Identify positive outcomes, expected failures, and boundary conditions.
2. Document how existing tests are incorporated or extended.
3. Carry out orthogonality analysis.
4. Label the cases as unit, integration, or end-to-end.

## Hierarchical Clustering

Cover the hierarchical clusterers in `lib/ai4r/clusterers` (e.g., `SingleLinkage`, `CompleteLinkage`). Use examples from `test/clusterers`.

1. Enumerate positive, negative, and edge cases.
2. Describe how current tests are reused or improved.
3. Run orthogonality analysis to avoid overlapping tests.
4. Indicate whether each case is unit, integration, or end-to-end.

## Hyperpipes Classifier

Examine `lib/ai4r/classifiers/hyperpipes.rb` and its tests in `test/classifiers/hyperpipes_test.rb`.

1. List positive, negative, and edge scenarios.
2. Explain how existing test coverage is incorporated.
3. Perform orthogonality analysis.
4. Mark each case as unit, integration, or end-to-end.

## IB1 Instance-Based Classifier

Look at `lib/ai4r/classifiers/ib1.rb` with tests in `test/classifiers/ib1_test.rb`.

1. Describe positive, negative, and edge cases.
2. Incorporate knowledge from existing tests.
3. Apply orthogonality analysis.
4. Categorize each case as unit, integration, or end-to-end.

## ID3 Decision Trees

Target the ID3 algorithm (`lib/ai4r/classifiers/id3.rb`) with tests in `test/classifiers/id3_test.rb`.

1. Enumerate positive, negative, and edge cases.
2. Show how existing tests are leveraged.
3. Conduct orthogonality analysis.
4. Classify each case as unit, integration, or end-to-end.

## Naive Bayes Classifier

Consider `lib/ai4r/classifiers/naive_bayes.rb` and `test/classifiers/naive_bayes_test.rb`.

1. Outline positive, negative, and edge cases.
2. Incorporate existing tests into new scenarios.
3. Perform orthogonality analysis.
4. Mark cases as unit, integration, or end-to-end.

## Neural Networks: Backpropagation

For backpropagation (`lib/ai4r/neural_network/backpropagation.rb`) and tests in `test/neural_network/backpropagation_test.rb`.

1. List positive, negative, and edge cases.
2. Explain how current tests are utilized.
3. Carry out orthogonality analysis.
4. Label each case as unit, integration, or end-to-end.

## PRISM Rule Induction

Study `lib/ai4r/classifiers/prism.rb` with tests in `test/classifiers/prism_test.rb`.

1. Enumerate positive, negative, and edge cases.
2. Reference existing tests and show how to reuse them.
3. Run orthogonality analysis.
4. Identify whether each case is unit, integration, or end-to-end.

## Self-Organizing Maps

Inspect modules under `lib/ai4r/som` and the tests in `test/som`.

1. Detail positive, negative, and edge cases.
2. Incorporate the provided tests when designing new scenarios.
3. Perform orthogonality analysis.
4. Categorize each case as unit, integration, or end-to-end.
