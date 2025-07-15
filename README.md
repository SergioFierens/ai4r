# AI4R — Artificial Intelligence for Ruby

🎓 **Welcome to AI4R**

Your Lightweight Lab for AI and Machine Learning in Ruby.

AI4R isn’t just another machine learning library. It’s a learning playground. No black boxes and no bulky dependencies—just clean, readable Ruby implementations of core AI algorithms so you can explore, modify and really understand how they work.

## Installation

AI4R is distributed as a gem and requires Ruby 3.2 or later.

Install the gem using RubyGems:

```bash
gem install ai4r
```

Add the library to your code:

```ruby
require 'ai4r'
```

## 🧭 What’s Inside?

A quick map to AI4R’s built‑in toolkits, grouped by type. Each folder comes with examples and benchmark runners so you can dive right in.

### 🧠 Classifiers – Make Predictions
"What’s the most likely outcome?"

You’ll find:

- `ZeroR`, `OneR` – the simplest baselines
- `LogisticRegression`, `SimpleLinearRegression`
- `SupportVectorMachine`
- `RandomForest`, `GradientBoosting`
- `MultilayerPerceptron`

Code: `lib/ai4r/classifiers/`

Demos: `bench/classifier/`

Try this: run `compare_all.rb` to benchmark classifiers on real datasets.

### 🔍 Clusterers – Find Hidden Patterns
"What belongs together?"

Includes:

- `KMeans`
- `DBSCAN`
- `Hierarchical` clustering variants

Code: `lib/ai4r/clusterers/`

Demos: `bench/clusterer/`

Try this: cluster the Iris dataset using both KMeans and DBSCAN.

### 🧬 Neural Networks – Learn From Data
"What if we build a brain?"

- Backpropagation – classic feedforward network
- Hopfield – associative memory model
- Transformer – a tiny GPT‑style block (encoder, decoder, seq2seq)

Code: `lib/ai4r/neural_network/`

Try this: open `transformer.rb` and trace each step—it’s short enough to grok in one sitting.

### 🔎 Search Algorithms – Explore Possibility Spaces
"What’s the best path?"

- `BreadthFirst`, `DepthFirst`, `IterativeDeepening`
- `A*`
- `MonteCarloTreeSearch`

Code: `lib/ai4r/search/`

Docs: `docs/search_algorithms.md`

Demos: `bench/search/`

Try this: run A* and DFS on a maze and time the difference.

### 🧪 Genetic Algorithms – Evolve a Solution
"Let’s mutate our way to a better answer."

- Generic GA framework
- A Traveling Salesman Problem (TSP) chromosome

Code: `lib/ai4r/genetic_algorithm/`

Try this: tweak the mutation rate in the TSP example.

### 🧭 Reinforcement Learning – Learn by Doing
"Reward me, and I’ll improve."

- Q‑Learning
- Policy Iteration

Code: `lib/ai4r/reinforcement/`

Docs: `docs/reinforcement_learning.md`

Try this: run a grid‑world training loop and watch the agent build its own policy.

### 🕵️ Hidden Markov Models – Guess What’s Hidden
"You can’t see the states—but you can infer them."

Code: `lib/ai4r/hmm/hidden_markov_model.rb`

Docs: `docs/hmm.md`

Try this: model a weather prediction problem with hidden states and visible activities.

### 🧠 Self‑Organizing Maps – Compress Dimensions
"Can we project complex data onto a simpler map?"

- Kohonen‑style SOM

Code: `lib/ai4r/som/`

Try this: reduce high‑dimensional vectors into a 2D neuron grid and color it based on class.

## 🧪 Benchmarks: Experiment & Compare

Each algorithm family has a benchmark runner:

- `bench/classifier/`
- `bench/clusterer/`
- `bench/search/`

Shared tools in `bench/common/` make it easy to run head‑to‑head comparisons, track runtime, accuracy and more, and output clean reports.

Docs: `docs/benches_overview.md`

Try this: run `bench/search/astar_vs_dfs.rb` and explain why A* usually wins.

## 🛠️ Core Utilities

- `DataSet` – your gateway to loading labeled data
- `Parameterizable` – easily tweak hyperparameters
- `Proximity` – distance functions (Euclidean, Manhattan, …)
- `Statistics` – mean, stdev, histograms and more

Everything lives under `lib/ai4r/`.

## 🏁 Getting Started

```bash
git clone https://github.com/SergioFierens/ai4r
cd ai4r
bundle install
ruby bench/classifier/compare_all.rb
```

## 🧠 Suggested First Experiments

| Goal | File |
| --- | --- |
| Predict with classifiers | `bench/classifier/compare_all.rb` |
| Explore clustering behavior | `bench/clusterer/kmeans_vs_dbscan.rb` |
| Navigate with search | `bench/search/astar_vs_dfs.rb` |
| Learn from rewards | See `docs/reinforcement_learning.md` |
| Evolve better TSP routes | `genetic_algorithm/tsp_example.rb` |

## 📚 Want to Learn More?

- Full classifier overview: `docs/index.md`
- Reinforcement intro: `docs/reinforcement_learning.md`
- Search walkthrough: `docs/search_algorithms.md`
- HMM basics: `docs/hmm.md`

Every module is short, readable and ready to hack.

## 💬 Feedback or Questions?

This library is maintained for the joy of it (and perhaps a misplaced sense of duty to Ruby). You can do whatever you want with it—it’s unlicensed. But if you build something cool or just find it useful, [Sergio Fierens](https://github.com/SergioFierens) would love to hear from you.

