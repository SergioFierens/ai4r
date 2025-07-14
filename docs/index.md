= AI4R — Artificial Intelligence for Ruby

A Ruby library of AI algorithms for learning and experimentation.

---

This project is an educational Ruby library for machine learning and artificial intelligence, featuring clean, minimal implementations of classical algorithms such as decision trees, neural networks, k-means, and genetic algorithms. It’s intentionally lightweight—no GPU support, no external dependencies, no production overhead—just a practical way to experiment, compare, and learn the fundamental building blocks of AI. Ideal for small-scale explorations, course demos, or simply understanding how these algorithms actually work, line by line.

Maintained over the years mostly for the joy of it (and perhaps a misplaced sense of duty to Ruby), this open-source library supports developers, students, and educators who want to understand machine learning in Ruby without drowning in complexity.

## Getting Started

Install the gem:

```bash
gem install ai4r
```

Include the library in your code:

```ruby
require 'ai4r'
```

## Practical Examples

* [User Guide](user_guide.md) – start with the basics and explore the library in depth.
* **Genetic Algorithms** – optimization of the Travelling Salesman Problem.
* **Neural Networks** – simple OCR recognition of visual patterns.
* [Hopfield Networks](hopfield_network.md) – memory based recognition of noisy patterns.
* [Hierarchical Clustering](hierarchical_clustering.md) – build dendrograms from merge steps.
* [DBSCAN](dbscan.md) – density-based clustering using a squared distance threshold.
* **Automatic Classifiers** – identify relevant marketing targets using decision trees.
* [PRISM](prism.md) – rule induction algorithm for discrete attributes.
* [Naive Bayes Classifier](naive_bayes.md) – probabilistic classification for categorical data.
* [Hyperpipes](hyperpipes.md) – baseline classifier using value ranges.
* [IB1 Classifier](ib1.md) – instance-based nearest neighbour algorithm.
* [Logistic Regression](logistic_regression.md) – binary classifier trained with gradient descent.
* [Reinforcement Learning](reinforcement_learning.md) – Q-learning and policy iteration.
* [Search Algorithms](search_algorithms.md) – breadth-first and depth-first search implementations.
* [Transformer](transformer.md) – tiny encoder, decoder and seq2seq models.


## Contributing

If you want to modify AI4R or write new tutorials, start with the
[Contributor Guide](contributor_guide.md).

## Contact

Questions and contributions are welcome. Contact [Sergio Fierens](https://github.com/SergioFierens) at `sergio dot fierens at gmail dot com`.

## Contributors

Sergio Fierens maintains the project with help from Thomas Kern, Luis Parravicini and Kevin Menard.

## Disclaimer

This software is provided "as is" without warranties of merchantability or fitness for a particular purpose.
